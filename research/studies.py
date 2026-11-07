#!/usr/bin/env python3
"""Executable trial protocol. Requires an explicitly supplied external agent runner or real participant responses."""
import argparse, hashlib, json, random, shlex, subprocess, tempfile, time
from pathlib import Path
from run import ROOT, SEED, CARDS, tokenizers


def agent(args):
    if not args.runner or not args.model:
        raise SystemExit('Real trials require --runner and an immutable --model identifier; no observations were generated.')
    enc = tokenizers()[args.encoding]
    command = json.loads(args.runner)
    if not isinstance(command, list) or not command or not all(isinstance(s, str) for s in command):
        raise SystemExit('--runner must be an explicit JSON argv array')
    tasks = json.loads((ROOT/'research/datasets/exploratory.json').read_text())['tasks']
    compilers = json.loads(args.compilers) if args.compilers else {'hybrid': [args.compiler]}
    if any(g not in CARDS or not isinstance(v,list) or not v for g,v in compilers.items()):
        raise SystemExit('--compilers maps grammar names to explicit compiler argv arrays')
    # Missing candidate compilers are excluded, never scored as grammar failures.
    order = [(t, grammar, trial) for t in tasks for grammar in compilers for trial in range(args.trials)]
    random.Random(SEED).shuffle(order)
    rows = []
    for task, grammar, trial in order:
        # All conditions receive the same task and budget. The external runner owns its model integration.
        messages = [{'role':'system','content':CARDS[grammar]}, {'role':'user','content':'Implement the behavior of this C reference as NanoC. Return JSON with a source string.\n'+task['reference_c']}]
        started = time.monotonic()
        tool_calls, repairs, success, stdout = 0, 0, False, ''
        request_tokens, response_tokens = 0, 0
        provider_usage = []
        with tempfile.TemporaryDirectory(prefix='nanoc-agent-trial-') as temp:
            folder = Path(temp)
            (folder/'reference.c').write_text(task['reference_c'])
            reference_build = subprocess.run([args.cc,'-std=c11',str(folder/'reference.c'),'-lm','-o',str(folder/'reference')],capture_output=True,text=True)
            if reference_build.returncode:
                raise SystemExit('Invalid reference task: '+task['id']+'\n'+reference_build.stderr)
            expected = subprocess.run([str(folder/'reference')],capture_output=True,text=True,timeout=10)
            for attempt in range(args.repairs + 1):
                request = {'schemaVersion':1,'model':args.model,'seed':SEED+trial,'grammar':grammar,'messages':messages}
                request_tokens += len(enc.encode(json.dumps(request)))
                run = subprocess.run(command,input=json.dumps(request),text=True,capture_output=True,timeout=args.timeout)
                response_tokens += len(enc.encode(run.stdout))
                tool_calls += 1
                if run.returncode:
                    messages.append({'role':'tool','content':'runner failed: '+run.stderr})
                    break
                answer = json.loads(run.stdout)
                source = answer['source']
                provider_usage.append(answer.get('usage'))
                messages.append({'role':'assistant','content':source})
                (folder/'main.nc').write_text(source)
                emitted = subprocess.run(compilers[grammar]+['emit',str(folder/'main.nc'),'-o',str(folder/'main.c')],capture_output=True,text=True)
                tool_calls += 1
                diagnostic = emitted.stderr
                if emitted.returncode == 0:
                    built = subprocess.run([args.cc,'-std=c11',str(folder/'main.c'),'-lm','-o',str(folder/'program')],capture_output=True,text=True)
                    tool_calls += 1
                    diagnostic = built.stderr
                    if built.returncode == 0:
                        executed = subprocess.run([str(folder/'program')],capture_output=True,text=True,timeout=10)
                        tool_calls += 1
                        stdout = executed.stdout
                        success = executed.returncode == expected.returncode and executed.stdout == expected.stdout
                        if success: break
                        diagnostic = 'Program exited '+str(executed.returncode)+'\n'+executed.stderr
                if attempt < args.repairs:
                    repairs += 1
                    messages.append({'role':'tool','content':diagnostic})
        rows.append({'task':task['id'],'grammar':grammar,'trial':trial,'model':args.model,'success':success,'toolCalls':tool_calls,'repairIterations':repairs,'wireRequestTokens':request_tokens,'wireResponseTokens':response_tokens,'providerUsage':provider_usage,'transcriptTokens':sum(len(enc.encode(m['content'])) for m in messages),'elapsedSeconds':time.monotonic()-started,'stdout':stdout,'messages':messages})
        Path(args.output).write_text(json.dumps({'schemaVersion':1,'encoding':args.encoding,'tokenizer':'tiktoken==0.8.0','trials':rows,'limitations':['Only explicitly registered compiler conditions are run. Default hybrid-only trials do not establish comparative grammar superiority.','Reference output and exit status equivalence cover each task test execution, not all possible inputs or correctness.','Wire token counts use pinned text encodings, exclude hidden model reasoning and provider chat framing; provider usage is separate.','Exploratory tasks were seen during grammar selection; these are not held-out evidence.']},indent=2)+'\n')


def human(args):
    tasks=json.loads((ROOT/'research/datasets/exploratory.json').read_text())['tasks']
    conditions=list(CARDS)
    assignment=[]
    participant_hash=int(hashlib.sha256(args.participant.encode()).hexdigest()[:8],16)
    for i,task in enumerate(tasks):
        grammar=conditions[(i+participant_hash)%len(conditions)]
        assignment.append({'task':task['id'],'grammar':grammar,'card':CARDS[grammar],'source':task['candidates'][grammar], 'questions':['Predict observable output and exit status.','Identify a seeded defect supplied by the study facilitator.','Perform the specified edit; record start/end monotonic timestamps and compile attempts.']})
    report={'schemaVersion':1,'participant':args.participant,'assignment':assignment,'observations':None,'status':'assigned, not completed'}
    if args.responses:
        responses=json.loads(Path(args.responses).read_text())
        for response in responses:
            if response['ended_ns'] < response['started_ns']:
                raise SystemExit('Invalid participant timing')
        report['observations']=responses
        report['status']='responses supplied; accuracy requires blinded scoring against preregistered answers'
    Path(args.output).write_text(json.dumps(report,indent=2)+'\n')

if __name__=='__main__':
    p=argparse.ArgumentParser();sub=p.add_subparsers(dest='mode',required=True)
    a=sub.add_parser('agent');a.add_argument('--compilers',help='JSON object of grammar to compiler argv; omit for hybrid only');a.add_argument('--runner');a.add_argument('--model');a.add_argument('--compiler',default=str(ROOT/'build/nanoc'));a.add_argument('--cc',default='cc');a.add_argument('--trials',type=int,default=5);a.add_argument('--repairs',type=int,default=3);a.add_argument('--timeout',type=int,default=180);a.add_argument('--encoding',default='o200k_base');a.add_argument('--output',default='research/results/agent.json')
    h=sub.add_parser('human');h.add_argument('--participant',required=True);h.add_argument('--responses');h.add_argument('--output',default='research/results/human-assignment.json')
    args=p.parse_args();agent(args) if args.mode=='agent' else human(args)
