#!/usr/bin/env python3
"""Repeated CLI timing of the compiler."""
import argparse, json, platform, statistics, subprocess, time
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('input');p.add_argument('--compiler',required=True)
p.add_argument('--trials',type=int,default=15);p.add_argument('--json',action='store_true')
a=p.parse_args()
if not 2<=a.trials<=10000:p.error('--trials must be between 2 and 10000')
source=Path(a.input).read_bytes()
# One warm-up is excluded from the reported repeated samples.
command=[a.compiler,'check',a.input,'--json']
first=subprocess.run(command,capture_output=True,text=True)
if first.returncode:
 print(first.stderr,end='',file=__import__('sys').stderr);raise SystemExit(first.returncode)
samples=[]
for _ in range(a.trials):
 start=time.perf_counter_ns();r=subprocess.run(command,capture_output=True,text=True)
 if r.returncode:raise SystemExit(r.stderr)
 samples.append((time.perf_counter_ns()-start)/1e6)
print(json.dumps({'schemaVersion':1,'input':a.input,'sourceBytes':len(source),'scope':'subprocess startup and expansion check; excludes C compilation','environment':platform.platform(),'samplesMs':samples,'medianMs':statistics.median(samples),'meanMs':statistics.mean(samples),'sampleStdevMs':statistics.stdev(samples),'agent':None,'human':None}))
