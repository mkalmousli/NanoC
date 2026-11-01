// Side-by-side view of examples/*.nc and the C NanoC generates from them (examples.json).
const $ = s => document.querySelector(s)
const pct = (a, b) => Math.round((1 - a / b) * 100)
const lines = t => t.split('\n').filter(l => l.trim()).length
const bytes = t => new TextEncoder().encode(t).length
let data = []
Prism.languages.nanoc = Prism.languages.extend('clike', {})
Prism.languages.insertBefore('nanoc', 'keyword', {
  directive: { pattern: /@(f|fn|m|macro|ct|bt|asm)\b/, alias: 'keyword' },
  macro: { pattern: /@[A-Za-z_]\w*/, alias: 'function' },
  capture: { pattern: /\$\$|\$[A-Za-z_]\w*(?::[A-Za-z]+|\.\.\.)?/, alias: 'variable' },
  control: { pattern: /\b(if|elif|else|for|while|break|continue|return|goto)\b/, alias: 'keyword' },
  inferred: { pattern: /:=/, alias: 'operator' },
  builtin: { pattern: /\b(emit|quote|ident|fresh|rewrite|again|source|eval|assert|fail)\b/, alias: 'function' }
})
function copy(text, btn)
  navigator.clipboard.writeText(text).then(() =>
    btn.textContent = 'Copied'
    setTimeout(() => (btn.textContent = 'Copy'), 1400)
  ).catch(() => (btn.textContent = 'Select & copy'))
function show(i)
  const ex = data[i]
  document.querySelectorAll('.ex-tabs button').forEach((b, j) =>
    b.classList.toggle('on', j === i)
    b.setAttribute('aria-selected', j === i)
  )
  const nl = lines(ex.nc), cl = lines(ex.c)
  const nb = bytes(ex.nc), cb = bytes(ex.c)
  $('#ex-stats').innerHTML = ''
  [
    ['NanoC lines', nl], ['C lines', cl],
    ['NanoC bytes', nb], ['C bytes', cb]
    ].forEach(([k, v]) =>
      const d = document.createElement('div')
      d.className = 'ex-stat'
      d.innerHTML = '<b></b><span></span>'
      d.querySelector('b').textContent = v.toLocaleString('en-US')
      d.querySelector('span').textContent = k
      $('#ex-stats').append(d)
  );
  const save = document.createElement('div')
  save.className = 'ex-stat hi'
  save.innerHTML = '<b></b><span></span>'
  save.querySelector('b').textContent = '−' + pct(nl, cl) + '%'
  save.querySelector('span').textContent = 'fewer lines'
  $('#ex-stats').append(save)
  const code = $('#nc-code')
  code.textContent = ex.nc
  code.className = 'language-nanoc'
  const cc = $('#c-code')
  cc.textContent = ex.c
  cc.className = 'language-c'
  Prism.highlightElement(code)
  Prism.highlightElement(cc)
  history.replaceState(null, '', '#' + ex.name.replace('examples/', '').replace('.nc', ''))
fetch('examples.json').then(r =>
  if (!r.ok) throw Error(String(r.status))
  return r.json()
).then(list =>
  data = list
  const tabs = $('#tabs')
  list.forEach((ex, i) =>
    const b = document.createElement('button')
    b.type = 'button'
    b.role = 'tab'
    b.textContent = ex.name.replace('examples/', '')
    b.onclick = () => show(i)
    tabs.append(b)
  )
  const want = location.hash.slice(1)
  const start = Math.max(0, list.findIndex(ex => ex.name === 'examples/' + want + '.nc'))
  show(start)
).catch(() =>
  const e = $('#ex-error')
  e.hidden = false
  e.textContent = 'Examples are unavailable right now.'
)
$('#copy-nc').onclick = e => copy($('#nc-code').textContent, e.currentTarget)
$('#copy-c').onclick = e => copy($('#c-code').textContent, e.currentTarget)
