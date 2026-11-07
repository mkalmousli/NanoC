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
let data = [];
function show(i) {
const ex = data[i];
A.tabs.querySelectorAll('button').forEach((b, j) => b.classList.toggle('on', j === i));
stats(A.stats, [['NanoC chars', ex.nc.length], ['C chars', ex.c.length], ['NanoC lines', lines(ex.nc)], ['C lines', lines(ex.c)], ['fewer chars', signed(ex.nc.length, ex.c.length), 1]]);
for (const [el, text, lang] of [[A.ncCode, ex.nc, 'nanoc'], [A.cCode, ex.c, 'c']]) {
el.textContent = text;
Prism.highlightElement(el);
}
history.replaceState(null, '', '#' + ex.name.replace('examples/', '').replace('.nc', ''));
}
fetch('examples.json').then(r => r.json()).then(list => {
data = list;
list.forEach((ex, i) => {
const b = document.createElement('button');
b.type = 'button';
b.textContent = ex.name.replace('examples/', '');
b.onclick = () => show(i);
A.tabs.append(b);
}
);
show(Math.max(0, list.findIndex(ex => ex.name === 'examples/' + location.hash.slice(1) + '.nc')));
}
).catch(() => {
A.error.hidden = false;
A.error.textContent = 'Examples are unavailable right now.';
}
);
A.copyNc.onclick = () => copyText(A.ncCode.textContent, A.copyNc, 'Copy');
A.copyC.onclick = () => copyText(A.cCode.textContent, A.copyC, 'Copy');
}
);
