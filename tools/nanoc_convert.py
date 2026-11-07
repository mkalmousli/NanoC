#!/usr/bin/env python3
"""Optional Clang AST conversion. Unsupported constructs remain opaque C islands."""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


def raw(text, indent=0):
    return ' ' * indent + '@c ' + json.dumps(text, ensure_ascii=False) + '\n'


class Converter:
    def __init__(self, text):
        self.data = text.encode('utf-8')
        self.mapping = []

    @staticmethod
    def point(point):
        return point.get('expansionLoc', point)

    def bounds(self, node):
        span = node['range']
        start, end = self.point(span['begin']), self.point(span['end'])
        return start['offset'], end['offset'] + end.get('tokLen', 0)

    def text(self, node):
        start, end = self.bounds(node)
        return self.data[start:end].decode('utf-8')

    def full(self, node):
        start, end = self.bounds(node)
        if node.get('kind') in ['CompoundStmt', 'IfStmt', 'WhileStmt', 'ForStmt', 'SwitchStmt']:
            return self.data[start:end].decode()
        while end < len(self.data) and self.data[end:end+1] in [b' ', b'\t']:
            end += 1
        if self.data[end:end+1] == b';':
            end += 1
        return self.data[start:end].decode()

    def header(self, node):
        start, _ = self.bounds(node)
        data = self.data
        first = data.find(b'(', start)
        depth, pos, quote = 0, first, None
        while pos < len(data):
            ch = data[pos]
            if quote is not None:
                if ch == 92:
                    pos += 2
                    continue
                if ch == quote:
                    quote = None
            elif ch in [34, 39]:
                quote = ch
            elif data[pos:pos+2] == b'/*':
                pos = data.index(b'*/', pos+2) + 2
                continue
            elif ch == 40:
                depth += 1
            elif ch == 41:
                depth -= 1
                if depth == 0:
                    return data[first:pos+1].decode()
            pos += 1
        raise ValueError('unterminated control header')

    def body(self, node, indent):
        if node.get('kind') == 'CompoundStmt':
            children = node.get('inner', [])
            return ''.join(self.statement(child, indent) for child in children) or ' '*indent + '@c ";"\n'
        return self.statement(node, indent)

    def statement(self, node, indent):
        kind, children = node.get('kind'), node.get('inner', [])
        prefix = ' ' * indent
        begin = node.get('range', {}).get('begin', {})
        if 'expansionLoc' in begin:
            # Macro AST ranges omit call arguments; keep the containing function body intact.
            raise ValueError('macro-generated statement')
        if kind == 'IfStmt' and len(children) in [2, 3]:
            out = prefix + 'if ' + self.header(node) + '\n' + self.body(children[1], indent+2)
            if len(children) == 3:
                out += prefix + 'else\n' + self.body(children[2], indent+2)
            return out
        if kind == 'WhileStmt' and len(children) == 2:
            return prefix + 'while ' + self.header(node) + '\n' + self.body(children[-1], indent+2)
        if kind == 'ForStmt' and len(children) == 5:
            return prefix + 'for ' + self.header(node) + '\n' + self.body(children[-1], indent+2)
        if kind in ['ReturnStmt', 'BreakStmt', 'ContinueStmt', 'DeclStmt', 'NullStmt'] or kind.endswith('Expr') or kind.endswith('Operator'):
            text = self.full(node).rstrip().removesuffix(';').strip()
            if '\n' in text or '# ' in text or '#\n' in text:
                return raw(self.full(node), indent)
            return prefix + (text or ';') + '\n'
        return raw(self.full(node), indent)

    def function(self, node):
        children = node.get('inner', [])
        body = next((child for child in children if child.get('kind') == 'CompoundStmt'), None)
        if body is None or any(child.get('kind', '').endswith('Attr') for child in children):
            return None
        result = node['type']['qualType'].split(' (', 1)[0]
        if '(' in result or ')' in result:
            return None
        params = []
        for child in children:
            if child.get('kind') == 'ParmVarDecl':
                declaration = self.text(child)
                if not child.get('name') or '(' in declaration or '[' in declaration:
                    return None
                params.append(declaration)
        if node.get('variadic'):
            params.append('...')
        storage = node.get('storageClass', '')
        result = (' '.join(x for x in [storage, 'inline' if node.get('inline') else '', result] if x))
        try:
            if re.search(r'^\s*#', self.text(body), re.M):
                raise ValueError("directives inside function")
            converted = self.body(body, 2)
        except (KeyError, ValueError):
            converted = raw(self.text(body)[1:-1], 2)
        return '// ' + node['name'] + ': converted from a parsed C function.\n' + 'f ' + node['name'] + '(' + ', '.join(params) + ') -> ' + result + '\n' + converted

    def convert(self, ast):
        functions = []
        for node in ast.get('inner', []):
            if node.get('kind') != 'FunctionDecl' or node.get('loc', {}).get('includedFrom'):
                continue
            location = node.get('loc', {})
            if 'offset' not in location or location['offset'] >= len(self.data):
                continue
            try:
                converted = self.function(node)
                if converted:
                    start, end = self.bounds(node)
                    functions.append((start, end, converted))
            except (KeyError, ValueError, UnicodeDecodeError):
                continue
        out, previous = [], 0
        for start, end, converted in sorted(functions):
            if start < previous:
                continue
            gap = self.data[previous:start].decode()
            if gap.strip():
                out.append(raw(gap))
            nano_start = len(('\n'.join(out)+'\n' if out else '').encode())
            out.append(converted)
            self.mapping.append({'cStart': start, 'cEnd': end, 'nanocStart': nano_start, 'nanocEnd': nano_start+len(converted.encode()), 'function': converted.split('\n', 1)[0]})
            previous = end
        tail = self.data[previous:].decode()
        if tail.strip():
            out.append(raw(tail))
        return '\n'.join(out) if out else raw(self.data.decode())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('--compact', action='store_true')
    parser.add_argument('--conservative', action='store_true')
    parser.add_argument('--clang', default='clang')
    parser.add_argument('--map')
    args, extra = parser.parse_known_args()
    text = Path(args.input).read_text()
    converter = Converter(text)
    # A single configuration's C AST cannot safely compact conditional source.
    conditional = re.search(r'^\s*#\s*(if|ifdef|ifndef|elif|else|endif)\b', text, re.M)
    if args.compact and not args.conservative and not conditional:
        command = [args.clang, '-std=c11', '-Xclang', '-ast-dump=json', '-fsyntax-only', args.input] + [arg for arg in extra if arg != '--']
        parsed = subprocess.run(command, capture_output=True, text=True)
        if parsed.returncode:
            sys.stderr.write(parsed.stderr)
            return 2
        output = converter.convert(json.loads(parsed.stdout))
    else:
        output = raw(text)
        if args.compact and conditional:
            sys.stderr.write('Conditional C preprocessing preserved as one opaque island.\n')
    if args.map:
        Path(args.map).write_text(json.dumps({'schemaVersion': 1, 'parser': args.clang, 'functions': converter.mapping}, indent=2)+'\n')
    sys.stdout.write(output)
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
