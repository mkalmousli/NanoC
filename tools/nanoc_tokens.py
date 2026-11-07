#!/usr/bin/env python3
"""Optional exact text token counts; no character-count estimates or silent fallbacks."""
import argparse, importlib.metadata, json, sys
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('input',nargs='?')
p.add_argument('--encoding',default='o200k_base')
p.add_argument('--capabilities',action='store_true')
p.add_argument('--ids',action='store_true')
a=p.parse_args()
try:
    import tiktoken
    version=importlib.metadata.version('tiktoken')
    if version!='0.8.0':
        raise RuntimeError('tiktoken==0.8.0 is required; install research/requirements.lock')
    result={'schemaVersion':1,'ok':True,'tokenizer':'tiktoken','version':version,'encoding':a.encoding,'scope':'file text; excludes chat protocol and hidden prompts'}
    if not a.capabilities:
        if not a.input:raise RuntimeError('a UTF-8 input file is required')
        text=Path(a.input).read_text(encoding='utf-8')
        tokens=tiktoken.get_encoding(a.encoding).encode(text,disallowed_special=())
        result.update({'tokens':len(tokens),'utf8Bytes':len(text.encode('utf-8'))})
        if a.ids:result['ids']=tokens
    print(json.dumps(result))
except Exception as error:
    print(json.dumps({'schemaVersion':1,'ok':False,'capability':'tokenizer','message':str(error)}))
    sys.exit(2)
