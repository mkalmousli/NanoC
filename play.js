const J = (n, f) => document.querySelectorAll(`[data-j="${n}"]`).forEach(f);
const A = new Proxy({}, { get: (_, k) => document.querySelector(`[data-a="${k}"]`) });
const REPO = 'https://github.com/mkalmousli/NanoC';
const $ = s => document.querySelector(s);
const lines = t => t.split('\n').filter(l => l.trim()).length;
const bytes = t => new TextEncoder().encode(t).length;
const pct = (a, b) => (b ? Math.round((1 - a / b) * 100) : 0);
const signed = (a, b) => (pct(a, b) >= 0 ? '−' : '+') + Math.abs(pct(a, b)) + '%';
async function copyText(text, btn, label = 'Copy') {
try {
await navigator.clipboard.writeText(text);
btn.textContent = 'Copied';
}
catch {
btn.textContent = 'Select & copy';
}
setTimeout(() => (btn.textContent = label), 1400);
}
Prism.languages.nanoc = Prism.languages.extend('clike', {});
Prism.languages.insertBefore('nanoc', 'keyword', {
directive: { pattern: /@(m|tt|c)\b/, alias: 'keyword' },
macro: { pattern: /@[A-Za-z_]\w*/, alias: 'function' },
capture: { pattern: /\$\$|\$[A-Za-z_]\w*(?::[A-Za-z]+|\.\.\.)?/, alias: 'variable' },
control: { pattern: /\b(if|elif|else|for|while|goto)\b/, alias: 'keyword' },
compact: { pattern: /^\s*(?:[?:+!^#$=<~]|[fsue]\b)/m, alias: 'keyword' },
inferred: { pattern: /:=/, alias: 'operator' },
builtin: { pattern: /\b(emit|quote|ident|fresh|rewrite|again|source|eval|assert|fail)\b/, alias: 'function' }
});
const stats = (box, items) => box.replaceChildren(...items.map(([k, v, hi]) => {
const d = document.createElement('div');
d.className = 'stat' + (hi ? ' hi' : '');
d.innerHTML = '<b></b><span></span>';
d.firstChild.textContent = typeof v === 'number' ? v.toLocaleString('en-US') : v;
d.lastChild.textContent = k;
return d;
}
));
J(0, el => {
let worker, seq = 0, timer, killer, lastC = '';
const { src, hl, out, err } = A;
function spawn() {
worker = new Worker('worker.js');
worker.onmessage = e => {
if (e.data.id !== seq) return;
clearTimeout(killer);
done(e.data);
}
}
function highlight() {
hl.textContent = src.value + '\n';
Prism.highlightElement(hl);
}
function run() {
const id = ++seq;
clearTimeout(killer);
killer = setTimeout(() => {
worker.terminate();
spawn();
done({ ok: false, err: 'Timed out after 5 s: a macro or translate-time loop did not finish.', out: '', ms: 5000 });
}
, 5000);
worker.postMessage({ id, src: src.value });
}
function done(r) {
err.hidden = r.ok;
if (!r.ok) {
err.textContent = r.err || 'This source could not be translated. Check the compiler diagnostic.';
return;
}
lastC = r.out;
out.textContent = r.out;
Prism.highlightElement(out);
const nc = src.value;
stats(A.stats, [['NanoC chars', nc.length], ['C chars', r.out.length], ['fewer chars', signed(nc.length, r.out.length), 1], ['NanoC lines', lines(nc)], ['C lines', lines(r.out)], ['translate time', r.ms < 1 ? '<1 ms' : Math.round(r.ms) + ' ms', 1]]);
}
function schedule() {
highlight();
clearTimeout(timer);
timer = setTimeout(run, 200);
}
function setSource(text) {
src.value = text;
schedule();
}
src.addEventListener('input', schedule);
src.addEventListener('scroll', () => { hl.parentElement.scrollTop = src.scrollTop; hl.parentElement.scrollLeft = src.scrollLeft });
src.addEventListener('keydown', e => {
if (e.key === 'Tab') {
e.preventDefault();
document.execCommand('insertText', false, '  ');
}
else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
e.preventDefault();
run();
}
}
);
A.copyNc.onclick = () => copyText(src.value, A.copyNc, 'Copy');
A.copyC.onclick = () => copyText(lastC, A.copyC, 'Copy');
A.share.onclick = () => {
const b64 = btoa(String.fromCharCode(...new TextEncoder().encode(src.value))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
history.replaceState(null, '', '#code=' + b64);
copyText(location.href, A.share, 'Share link');
}
function fromHash() {
const m = location.hash.match(/^#code=(.+)$/);
if (!m) return null;
try {
const bin = atob(m[1].replace(/-/g, '+').replace(/_/g, '/'));
return new TextDecoder().decode(Uint8Array.from(bin, c => c.charCodeAt(0)));
}
catch { return null };
}
spawn();
fetch('examples.json').then(r => r.json()).then(all => {
const tabs = A.tabs;
all.forEach(ex => {
const b = document.createElement('button');
b.type = 'button';
b.textContent = ex.name.replace(/^examples\//, '').replace(/\.nc$/, '');
b.onclick = () => {
tabs.querySelectorAll('button').forEach(x => x.classList.toggle('on', x === b));
history.replaceState(null, '', location.pathname);
setSource(ex.nc);
}
tabs.append(b);
}
);
const shared = fromHash();
if (shared !== null) setSource(shared);
else tabs.firstChild.click();
}
);
}
);
