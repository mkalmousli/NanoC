// NanoC syntax for the site's code blocks (NanoC on top of C).
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
const RAW = 'https://raw.githubusercontent.com/mkalmousli/NanoC/main/';
const $ = s => document.querySelector(s);

// ---- copy buttons on every code block ----
async function copyText(text, btn) {
  try {
    await navigator.clipboard.writeText(text);
    btn.textContent = 'Copied';
  } catch {
    btn.textContent = 'Select & copy';
  }
  setTimeout(() => (btn.textContent = 'Copy'), 1400);
}
document.querySelectorAll('pre').forEach(pre => {
  if (pre.id === 'prompt-text') return;
  const wrap = document.createElement('div');
  wrap.className = 'boxed';
  const b = document.createElement('button');
  b.className = 'copy';
  b.type = 'button';
  b.textContent = 'Copy';
  b.onclick = () => copyText(pre.innerText, b);
  pre.replaceWith(wrap);
  wrap.append(pre, b);
});

// ---- one prompt for any AI assistant ----
const PROMPT = 'Project: ' + REPO + ' (README.md and docs/language.md describe the language; ' +
  'the compiler is in src/**/*.nc).\n\n' +
  'Write a small NanoC program that [goal]. Use @f functions with bare return types and ' +
  'indented blocks, no braces or semicolons. Show the file, the nanoc command that emits C, ' +
  'and the cc command that builds it.';
$('#prompt-text').textContent = PROMPT;
$('#prompt-copy').onclick = e => copyText(PROMPT, e.currentTarget);

// ---- compiler stats, from docs/stats.json (regenerate: sh tools/site/stats.sh) ----
const pct = (a, b) => Math.round((1 - a / b) * 100);
const fmt = n => n.toLocaleString('en-US');
fetch('stats.json').then(r => r.json()).then(s => {
  const set = (k, v) => document.querySelectorAll(`[data-stat="${k}"]`).forEach(el => (el.textContent = v));
  set('lines-saved', '−' + pct(s.nc.lines, s.c.lines) + '%');
  set('bytes-saved', '−' + pct(s.nc.bytes, s.c.bytes) + '%');
  set('nc-lines', fmt(s.nc.lines));
  set('c-lines', fmt(s.c.lines));
  set('files', s.files);
  set('generated', s.generated);
  set('badge', '−' + pct(s.nc.lines, s.c.lines) + '% lines vs C');
  const max = Math.max(...s.areas.map(a => a.c));
  $('#areas').replaceChildren(...s.areas.sort((a, b) => b.c - a.c).map(a => {
    const row = document.createElement('div');
    row.className = 'bar-row';
    row.innerHTML = `<span class="name"></span><div class="track"><i class="c"></i><i class="nc"></i></div><span class="num"></span>`;
    row.querySelector('.name').textContent = a.name;
    row.querySelector('.num').textContent = fmt(a.nc) + ' / ' + fmt(a.c);
    const [c, nc] = row.querySelectorAll('i');
    c.style.width = (a.c / max * 100) + '%';
    nc.style.width = (a.nc / max * 100) + '%';
    return row;
  }));
}).catch(() => {
  $('#areas').textContent = 'Stats unavailable. Run sh tools/site/stats.sh.';
});

// ---- guide: highlight the current lesson in the table of contents ----
const links = [...document.querySelectorAll('.toc a')];
const io = new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (!e.isIntersecting) return;
    links.forEach(a => a.classList.toggle('on', a.getAttribute('href') === '#' + e.target.id));
  });
}, { rootMargin: '-35% 0px -55% 0px' });
document.querySelectorAll('.lesson').forEach(el => io.observe(el));

// ---- source explorer: index from docs/files.json, contents from raw GitHub ----
const list = $('#file-list');
const search = $('#search');
const count = $('#file-count');
let files = [];
let current = null;

function group(path) {
  const map = { 'src/': 'COMPILER', 'bootstrap/': 'C BOOTSTRAP', 'examples/': 'EXAMPLES', 'docs/': 'DOCS',
    'editors/': 'EDITORS', 'tests/': 'TESTS' };
  for (const k in map) if (path.startsWith(k)) return map[k];
  return 'PROJECT';
}

function render() {
  list.replaceChildren();
  const q = search.value.toLowerCase();
  const matches = files.filter(p => p.toLowerCase().includes(q));
  let last = '';
  for (const path of matches) {
    const g = group(path);
    if (g !== last) {
      const h = document.createElement('div');
      h.className = 'folder-label';
      h.textContent = g;
      list.append(h);
      last = g;
    }
    const b = document.createElement('button');
    b.className = 'file-btn' + (path === current ? ' on' : '');
    b.textContent = path;
    b.onclick = () => open(path);
    list.append(b);
  }
  count.textContent = matches.length + ' files';
}

function language(path) {
  if (path.endsWith('.nc')) return 'nanoc';
  if (/\.(c|h|cc|cpp)$/.test(path)) return 'c';
  if (path.endsWith('.sh')) return 'bash';
  return 'clike';
}

async function open(path) {
  current = path;
  render();
  $('#selected-name').textContent = path;
  $('#raw-link').href = REPO + '/blob/main/' + path;
  const view = $('#code-view');
  view.innerHTML = '<div class="loading">Loading…</div>';
  try {
    const r = await fetch(RAW + path);
    if (!r.ok) throw Error(String(r.status));
    const code = document.createElement('code');
    code.className = 'language-' + language(path);
    code.textContent = await r.text();
    const pre = document.createElement('pre');
    pre.append(code);
    view.replaceChildren(pre);
    Prism.highlightElement(code);
  } catch {
    view.innerHTML = '<div class="empty-code">Could not load this file. <a href="' + REPO + '">Open the repository ↗</a></div>';
  }
}

search.oninput = render;
document.addEventListener('keydown', e => {
  if (e.key === '/' && document.activeElement.tagName !== 'INPUT') {
    e.preventDefault();
    search.focus();
  }
});

fetch('files.json').then(r => {
  if (!r.ok) throw Error(String(r.status));
  return r.json();
}).then(paths => {
  files = paths;
  render();
  open(files.includes('src/frontend/expand.nc') ? 'src/frontend/expand.nc' : files[0]);
}).catch(() => {
  list.innerHTML = '<a class="file-btn" href="' + REPO + '/tree/main">Index unavailable. Browse on GitHub ↗</a>';
  count.textContent = '';
});
