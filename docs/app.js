// Syntax for the site's code blocks (NanoC on top of C).
Prism.languages.nanoc = Prism.languages.extend('clike', {});
Prism.languages.insertBefore('nanoc', 'keyword', {
  directive: { pattern: /@(f|fn|m|macro|ct|bt|asm)\b/, alias: 'keyword' },
  macro: { pattern: /@[A-Za-z_]\w*/, alias: 'function' },
  capture: { pattern: /\$\$|\$[A-Za-z_]\w*(?::[A-Za-z]+|\.\.\.)?/, alias: 'variable' },
  control: { pattern: /\b(if|elif|else|for|while|break|continue|return|goto)\b/, alias: 'keyword' },
  inferred: { pattern: /:=/, alias: 'operator' },
  builtin: { pattern: /\b(emit|quote|ident|fresh|rewrite|again|source|eval|assert|fail)\b/, alias: 'function' }
});
Prism.highlightAll();

const REPO = 'https://github.com/mkalmousli/NanoC';
const HEAD = 'Project: ' + REPO + ' (README.md and docs/language.md describe the language; ' +
  'the compiler is in src/**/*.nc).\n\n';

const prompts = {
  build: ['YOUR FIRST PROGRAM', 'Build a small C program in NanoC.\n\nUse @f functions with bare return types and indentation based blocks. Use ordinary C expressions and headers. A value function returns its final expression.\n\nStart with main printing a greeting, then show the build command for the nanoc compiler and the C compiler.'],
  macro: ['MAKE A REUSABLE MACRO', 'Help me write a NanoC macro for [repeated C pattern]. Prefer an @m token template with $ captures. Use $fresh(name) when generated identifiers could collide. Show a call and its expanded C. Keep macro bodies indented.'],
  ct: ['GENERATE CODE AT COMPILE TIME', 'Write a NanoC @ct program to generate [declarations/functions] from [inputs]. Use small functions, loops, emit, and quote. Show the generated C and compile command. Assume --check disables BT writes and commands.'],
  bt: ['AUTOMATE THE BUILD', 'Write a NanoC @bt build step that [build task]. Use write, mkdir, env, exists, or run with an argument list. Explain which files and commands it touches. Keep the step deterministic and show how to validate expansion with --check.'],
  asm: ['USE INLINE ASSEMBLY', 'Add inline assembly for [operation] on [target architecture and ABI]. Use indented @asm and explicitly declare output, input, clobber, and jump-label constraints. Explain constraints and side effects; include a portable C fallback when practical. Assembly is target-specific; NanoC forwards it to the GCC/Clang inline assembler.'],
  interop: ['CALL C OR C++ DIRECTLY', 'Show how to use this C/C++ API from NanoC: [paste declaration or header]. Preserve its ABI and ownership rules. Use C-compatible types for C, or --lang c++ for C++17 features. Provide the compiler and link commands.'],
  contribute: ['EXPLORE THE COMPILER', 'Explore the compiler. Read docs/architecture.md and docs/language.md. Compiler code is in src/**/*.nc; bootstrap/build/tests are C. Trace [feature] from parsing to C emission, implement a focused change, then run ./builder test and ./builder bootstrap.']
};

const text = document.querySelector('#prompt-text');
const label = document.querySelector('#prompt-label');
function choose(k) {
  document.querySelectorAll('.tab').forEach(b => b.classList.toggle('active', b.dataset.prompt === k));
  label.textContent = prompts[k][0];
  text.textContent = HEAD + prompts[k][1];
}
document.querySelectorAll('.tab').forEach(b => b.onclick = () => choose(b.dataset.prompt));
choose('build');

async function copy(s, b) {
  try {
    await navigator.clipboard.writeText(s);
    const old = b.textContent;
    b.textContent = 'Copied';
    setTimeout(() => b.textContent = old, 1000);
  } catch {
    b.textContent = 'Select and copy';
  }
}
document.querySelectorAll('[data-copy]').forEach(b => b.onclick = () => copy(document.getElementById(b.dataset.copy).innerText, b));
document.querySelector('#prompt-copy').onclick = e => copy(text.textContent, e.currentTarget);

// Source explorer: file index from docs/files.json (regenerate: sh tools/site/files.sh),
// file contents from raw.githubusercontent.com (no API rate limit).
const list = document.querySelector('#file-list');
const search = document.querySelector('#search');
const count = document.querySelector('#file-count');
const raw = 'https://raw.githubusercontent.com/mkalmousli/NanoC/main/';
let files = [];

function group(path) {
  if (path.startsWith('src/')) return 'COMPILER';
  if (path.startsWith('bootstrap/')) return 'C BOOTSTRAP';
  if (path.startsWith('examples/')) return 'EXAMPLES';
  if (path.startsWith('docs/')) return 'DOCS';
  if (path.startsWith('editors/')) return 'EDITORS';
  if (path.startsWith('tests/')) return 'TESTS';
  return 'PROJECT';
}

function render() {
  list.replaceChildren();
  const q = search.value.toLowerCase();
  const matches = files.filter(f => f.path.toLowerCase().includes(q));
  let last = '';
  for (const f of matches) {
    const g = group(f.path);
    if (g !== last) {
      const h = document.createElement('div');
      h.className = 'folder-label';
      h.textContent = g;
      list.append(h);
      last = g;
    }
    const b = document.createElement('button');
    b.className = 'file-btn';
    b.textContent = f.path;
    b.onclick = () => open(f);
    list.append(b);
  }
  count.textContent = matches.length + ' files';
}

function language(path) {
  if (path.endsWith('.nc')) return 'nanoc';
  if (/\.(c|h|cc|cpp)$/.test(path)) return 'c';
  return 'clike';
}

async function open(f) {
  document.querySelector('#selected-name').textContent = f.path;
  document.querySelector('#raw-link').href = REPO + '/blob/main/' + f.path;
  const view = document.querySelector('#code-view');
  view.innerHTML = '<div class="loading">Loading…</div>';
  try {
    const r = await fetch(raw + f.path);
    if (!r.ok) throw Error(String(r.status));
    const code = document.createElement('code');
    code.className = 'language-' + language(f.path);
    code.textContent = await r.text();
    const pre = document.createElement('pre');
    pre.append(code);
    view.replaceChildren(pre);
    Prism.highlightElement(code);
  } catch {
    view.innerHTML = '<div class="empty-code">Could not load this file. <a href="' + REPO + '">Open repository ↗</a></div>';
  }
}

search.oninput = render;
document.addEventListener('keydown', e => {
  if (e.key === '/' && document.activeElement.tagName !== 'INPUT') {
    e.preventDefault();
    search.focus();
  }
});

fetch('docs/files.json').then(r => {
  if (!r.ok) throw Error(String(r.status));
  return r.json();
}).then(paths => {
  files = paths.map(path => ({ path }));
  render();
  open(files.find(f => f.path === 'src/frontend/expand.nc') || files[0]);
}).catch(() => {
  list.innerHTML = '<a class="file-btn" href="' + REPO + '/tree/main">Index unavailable — browse on GitHub ↗</a>';
  count.textContent = 'Offline fallback';
});
