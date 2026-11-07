#!/usr/bin/env python3
"""Reproducible grammar token experiment. No agent or human observations are synthesized."""
import argparse, hashlib, importlib.metadata, json, platform, random, re, statistics
import subprocess, tempfile, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEED = 20261106
CARDS = {
    'sigils': 'f name(args) -> T; s Name; x := literal; x: T = expr; = expr; ? cond; :? cond; :; ~ cond; # init; cond; step; !; ^; + <x.h>; @m templates; @ct programs; @c raw C.',
    'hybrid': 'f name(args) -> T; s Name; x := literal; x: T = expr; return expr; if cond; elif cond; else; while cond; for init; cond; step; break; continue; + <x.h>; @m templates; @ct programs; @c raw C.',
    'compact_keywords': 'f name(args) -> T; s Name; x := literal; x: T = expr; r expr; if cond; elif cond; else; while cond; for init; cond; step; break; continue; + <x.h>; @m templates; @ct programs; @c raw C.',
    'keywords': 'function name(args) -> T; struct Name; x := literal; x: T = expr; return expr; if cond; elif cond; else; while cond; for init; cond; step; break; continue; include <x.h>; @m templates; @ct programs; @c raw C.',
}

def hybrid(source):
    replacements = [(r'\? ', 'if '), (r':\? ', 'elif '), 
                    (r'~ ', 'while '), (r'# ', 'for '), (r'!$', 'break'), (r'\^$', 'continue')]
    for pattern, target in replacements:
        source = re.sub(r'(?m)^(\s*)' + pattern, lambda m: m[1] + target, source)
    families, lines = {}, []
    for original, line in zip(source.splitlines(), source.splitlines()):
        depth = len(line) - len(line.lstrip())
        text = line.strip()
        if re.match(r'\?[+#-]', text):
            families[depth] = 'preprocessor'
        elif text.startswith('if '):
            families[depth] = 'runtime'
        if text == ':' and families.get(depth) != 'preprocessor':
            line = line[:depth] + 'else'
        lines.append(line)
    source = '\n'.join(lines) + ('\n' if source.endswith('\n') else '')
    return re.sub(r'(?m)^(\s*)=(?=\s|$)', r'\1return', source)

def variants(source):
    word = hybrid(source)
    compact = re.sub(r'(?m)^(\s*)return(?=\s|$)', r'\1r', word)
    verbose = re.sub(r'(?m)^(\s*)f ', r'\1function ', compact)
    verbose = re.sub(r'(?m)^(\s*)s ', r'\1struct ', verbose)
    verbose = re.sub(r'(?m)^(\s*)r(?=\s|$)', r'\1return', verbose)
    verbose = re.sub(r'(?m)^(\s*)\+ ', r'\1include ', verbose)
    return {'sigils': source, 'hybrid': word, 'compact_keywords': compact, 'keywords': verbose}

def interval(values):
    if not values:
        return None
    rng = random.Random(SEED)
    means = sorted(statistics.mean(rng.choices(values, k=len(values))) for _ in range(4000))
    return [means[100], means[3899]]

def digest(text):
    return hashlib.sha256(text.encode()).hexdigest()

def tokenizers():
    import tiktoken
    if importlib.metadata.version('tiktoken') != '0.8.0':
        raise SystemExit('Use version-pinned research/requirements.lock')
    return {name: tiktoken.get_encoding(name) for name in ['cl100k_base', 'o200k_base']}

def run(args):
    encodings = tokenizers()
    dataset_path = ROOT / 'research/datasets/exploratory.json'
    dataset = json.loads(dataset_path.read_text())
    tasks = list(dataset['tasks'])
    rows = []
    compiler = str(Path(args.compiler).resolve())
    rng = random.Random(SEED)
    rng.shuffle(tasks)
    for task in tasks:
        source = task['source']
        candidates = task['candidates']
        record = {'task': task['id'], 'split': 'exploratory',
                  'source_sha256': digest(source), 'measurements': {}, 'agent': None, 'human': None}
        for name, text in candidates.items():
            record['measurements'][name] = {
                encoding: {'code_tokens': len(enc.encode(text)), 'code_and_card_tokens': len(enc.encode(CARDS.get(name, '') + '\n' + text))}
                for encoding, enc in encodings.items()}
        with tempfile.TemporaryDirectory(prefix='nanoc-research-') as temp:
            c = Path(temp) / 'main.c'
            executable = Path(temp) / 'main'
            # Frozen reference C makes token/reference results reproducible after breaking v1 changes.
            text = task['reference_c']
            c.write_text(text)
            record['reference_source'] = 'frozen exploratory C; not a claim that final v1 accepts each candidate'
            record['c_tokens'] = {name: len(enc.encode(text)) for name, enc in encodings.items()}
            built = subprocess.run([args.cc, '-std=c11', '-Wall', '-Wextra', '-Werror', '-pedantic-errors', str(c), '-lm', '-o', str(executable)], capture_output=True, text=True)
            record['reference_compiles'] = built.returncode == 0
            if built.returncode == 0:
                executed = subprocess.run([str(executable)], capture_output=True, text=True, timeout=10)
                record['reference_exit_status'] = executed.returncode
                record['reference_stdout'] = executed.stdout
            else:
                record['reference_error'] = built.stderr
            # Measure the final compiler on the current canonical counterpart separately.
            canonical = ROOT / task['id']
            times = []
            for _ in range(args.trials):
                start = time.perf_counter_ns()
                checked = subprocess.run([compiler, str(canonical), '--check'], capture_output=True, text=True)
                if checked.returncode:
                    record['compiler_error'] = checked.stderr
                    break
                times.append((time.perf_counter_ns() - start) / 1e6)
            record['compiler_ms'] = times
            record['canonical_sha256'] = digest(canonical.read_text())
        rows.append(record)
    summaries = {}
    for encoding in encodings:
        for name in CARDS:
            paired = [r['measurements'][name][encoding]['code_and_card_tokens'] - r['measurements']['sigils'][encoding]['code_and_card_tokens'] for r in rows]
            summaries[encoding + ':' + name] = {'mean_difference_vs_sigils_tokens': statistics.mean(paired), 'paired_task_bootstrap_95_ci': interval(paired), 'tasks': len(paired)}
    results = {'schemaVersion': 1, 'seed': SEED, 'dataset_sha256': hashlib.sha256(dataset_path.read_bytes()).hexdigest(), 'tokenizer': {'package': 'tiktoken', 'version': '0.8.0',
                'encodings': list(encodings), 'vocabulary_sha256': {name: hashlib.sha256(b''.join(k + v.to_bytes(4, 'big') for k, v in sorted(enc._mergeable_ranks.items()))).hexdigest() for name, enc in encodings.items()}},
               'environment': {'platform': platform.platform(), 'python': platform.python_version(), 'compiler': subprocess.check_output([compiler, '--version'], text=True).strip(), 'cc': args.cc},
               'design': 'Paired deterministic token counts across tasks; repeated compiler timings. Native grammar variants are NOT all implemented. Compilation columns validate only the reference source, not candidate grammars or agent success.',
               'missing': ['model agent trials', 'human participants', 'human comprehension/review/editing measurements', 'independent learnability measurements'],
               'summaries': summaries, 'tasks': rows}
    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    Path(args.output).write_text(json.dumps(results, indent=2) + '\n')
    print(json.dumps(summaries, indent=2))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--compiler', default='build/nanoc')
    parser.add_argument('--cc', default='cc')
    parser.add_argument('--trials', type=int, default=15)
    parser.add_argument('--output', default='research/results/grammar.json')
    run(parser.parse_args())
