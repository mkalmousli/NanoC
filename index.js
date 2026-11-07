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
Prism.highlightElement(el.querySelector('code'));
}
);
J(1, el => {
el.addEventListener('click', e => {
copyText(el.parentElement.querySelector('pre').innerText, el);
}
);
}
);
J(2, el => {
const links = [...el.querySelectorAll('a')];
const io = new IntersectionObserver(entries => {
entries.forEach(e => {
if (!e.isIntersecting) return;
links.forEach(a => a.toggleAttribute('aria-current', a.getAttribute('href') === '#' + e.target.id));
}
);
}
, { rootMargin: '-35% 0px -55% 0px' });
document.querySelectorAll('article[id]').forEach(a => io.observe(a));
}
);
