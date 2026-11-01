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
const RAW = 'source/'; // copied into the site by tools/site/site.nc
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
const signed = (a, b) => { const p = pct(a, b); return (p >= 0 ? '−' : '+') + Math.abs(p) + '%'; };
const fmt = n => n.toLocaleString('en-US');
fetch('stats.json').then(r => r.json()).then(s => {
  const set = (k, v) => document.querySelectorAll(`[data-stat="${k}"]`).forEach(el => (el.textContent = v));
  set('lines-saved', signed(s.nc.lines, s.c.lines));
  set('bytes-saved', signed(s.nc.bytes, s.c.bytes));
  set('nc-lines', fmt(s.nc.lines));
  set('c-lines', fmt(s.c.lines));
  set('files', s.files);
  set('generated', s.generated);
  set('badge', signed(s.nc.lines, s.c.lines) + ' lines vs C');
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

// ---- source explorer: folder tree of .nc files; NanoC beside the C the compiler generates ----
const list = $('#file-list');
const search = $('#search');
const count = $('#file-count');
let files = [];
let current = null;
const openDirs = new Set(['src', 'src/frontend']);
let worker, seq = 0, killer;

function spawn() {
  worker = new Worker('worker.js');
  worker.onmessage = e => {
    if (e.data.id !== seq) return;
    clearTimeout(killer);
    showC(e.data);
  };
}

function buildTree(paths) {
  const root = { dirs: {}, files: [] };
  for (const p of paths) {
    const parts = p.split('/');
    let node = root;
    for (const d of parts.slice(0, -1)) node = node.dirs[d] ||= { dirs: {}, files: [] };
    node.files.push(p);
  }
  return root;
}

function renderNode(node, parent, prefix, force) {
  for (const d of Object.keys(node.dirs).sort()) {
    const path = prefix + d;
    const det = document.createElement('details');
    det.open = force || openDirs.has(path);
    det.ontoggle = () => { if (!force) det.open ? openDirs.add(path) : openDirs.delete(path); };
    const sum = document.createElement('summary');
    sum.textContent = d;
    det.append(sum);
    const inner = document.createElement('div');
    inner.className = 'tree-in';
    det.append(inner);
    renderNode(node.dirs[d], inner, path + '/', force);
    parent.append(det);
  }
  for (const p of node.files.sort()) {
    const b = document.createElement('button');
    b.className = 'file-btn' + (p === current ? ' on' : '');
    b.textContent = p.split('/').pop();
    b.title = p;
    b.onclick = () => open(p);
    parent.append(b);
  }
}

function render() {
  list.replaceChildren();
  const q = search.value.toLowerCase();
  const matches = files.filter(p => p.toLowerCase().includes(q));
  renderNode(buildTree(matches), list, '', q.length > 0);
  count.textContent = matches.length + ' NanoC files';
}

const countLines = t => t.split('\n').filter(l => l.trim()).length;

function show(view, text, lang) {
  const code = document.createElement('code');
  code.className = 'language-' + lang;
  code.textContent = text;
  const pre = document.createElement('pre');
  pre.append(code);
  view.replaceChildren(pre);
  Prism.highlightElement(code);
}

let ncLines = 0;
function showC(r) {
  const view = $('#c-view');
  if (!r.ok) {
    view.innerHTML = '<div class="empty-code">No C preview: ' + (r.err ? r.err.split('\n')[0].replace(/[<&]/g, '') : 'this file needs build-time (@bt) host access, which the browser build does not have') + '.</div>';
    $('#c-stat').textContent = '';
    return;
  }
  show(view, r.out, 'c');
  const c = countLines(r.out);
  $('#c-stat').textContent = c + ' lines · ' + Math.round(r.ms < 1 ? 1 : r.ms) + ' ms';
  $('#ratio').textContent = c && ncLines ? (ncLines <= c ? Math.round((1 - ncLines / c) * 100) + '% fewer lines than C' : 'longer than its C') : '';
}

async function open(path) {
  current = path;
  render();
  $('#selected-name').textContent = path;
  $('#raw-link').href = REPO + '/blob/main/' + path;
  $('#nc-view').innerHTML = '<div class="loading">Loading…</div>';
  $('#c-view').innerHTML = '<div class="loading">Compiling in your browser…</div>';
  $('#ratio').textContent = '';
  try {
    let r = await fetch('source/' + path);
    if (!r.ok) r = await fetch(RAW + path);
    if (!r.ok) throw Error(String(r.status));
    const text = await r.text();
    if (current !== path) return;
    ncLines = countLines(text);
    $('#nc-stat').textContent = ncLines + ' lines';
    show($('#nc-view'), text, 'nanoc');
    const id = ++seq;
    clearTimeout(killer);
    killer = setTimeout(() => {
      worker.terminate();
      spawn();
      showC({ ok: false, err: 'timed out', out: '', ms: 5000 });
    }, 5000);
    worker.postMessage({ id, src: text });
  } catch {
    $('#nc-view').innerHTML = '<div class="empty-code">Could not load this file. <a href="' + REPO + '">Open the repository ↗</a></div>';
  }
}

search.oninput = render;
document.addEventListener('keydown', e => {
  if (e.key === '/' && document.activeElement.tagName !== 'INPUT') {
    e.preventDefault();
    search.focus();
  }
});

spawn();
fetch('files.json').then(r => {
  if (!r.ok) throw Error(String(r.status));
  return r.json();
}).then(paths => {
  files = paths.filter(p => p.endsWith('.nc'));
  render();
  open(files.includes('src/frontend/expand.nc') ? 'src/frontend/expand.nc' : files[0]);
}).catch(() => {
  list.innerHTML = '<a class="file-btn" href="' + REPO + '/tree/main">Index unavailable. Browse on GitHub ↗</a>';
  count.textContent = '';
});
