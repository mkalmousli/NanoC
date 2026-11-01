// NanoC playground: editor + the compiler running as WebAssembly in a worker.
const $ = s => document.querySelector(s)
const lines = t => t.split('\n').filter(l => l.trim()).length
const bytes = t => new TextEncoder().encode(t).length
const pct = (a, b) => (b ? Math.round((1 - a / b) * 100) : 0)
Prism.languages.nanoc = Prism.languages.extend('clike', {})
Prism.languages.insertBefore('nanoc', 'keyword', {
  directive: { pattern: /@(f|fn|m|macro|ct|bt|asm)\b/, alias: 'keyword' },
  macro: { pattern: /@[A-Za-z_]\w*/, alias: 'function' },
  capture: { pattern: /\$\$|\$[A-Za-z_]\w*(?::[A-Za-z]+|\.\.\.)?/, alias: 'variable' },
  control: { pattern: /\b(if|elif|else|for|while|break|continue|return|goto)\b/, alias: 'keyword' },
  inferred: { pattern: /:=/, alias: 'operator' },
  builtin: { pattern: /\b(emit|quote|ident|fresh|rewrite|again|source|eval|assert|fail)\b/, alias: 'function' }
})
const src = $('#src'), hl = $('#hl'), out = $('#out'), err = $('#err')
let worker, seq = 0, timer, killer, lastC = ''
function spawn()
  worker = new Worker('worker.js')
  worker.onmessage = e =>
    if (e.data.id !== seq) return
    clearTimeout(killer)
    done(e.data)
function highlight()
  hl.textContent = src.value + '\n'
  Prism.highlightElement(hl)
function run()
  const id = ++seq, text = src.value
  clearTimeout(killer)
  killer = setTimeout(() =>
    worker.terminate()
    spawn()
    done({ ok: false, err: 'Timed out after 5 s: a macro or compile-time loop did not finish.', out: '', ms: 5000 })
  , 5000)
  worker.postMessage({ id, src: text })
function done(r)
  const nc = src.value
  if (r.ok)
    lastC = r.out
    out.textContent = r.out
    Prism.highlightElement(out)
    err.hidden = true
    const stat = (k, v, cls = '') => `<div class="stat ${cls}"><b>${v}</b><span>${k}</span></div>`
    const ln = lines(nc), lc = lines(r.out)
    $('#stats').innerHTML = stat('NanoC lines', ln) + stat('C lines', lc) + stat('NanoC bytes', bytes(nc)) + stat('C bytes', bytes(r.out)) +
    stat('compile time', r.ms < 1 ? '<1 ms' : Math.round(r.ms) + ' ms', 'hi')
  else
    err.hidden = false
    err.textContent = r.err || 'This program needs build-time (@bt) host access, which the browser build does not have. Install nanoc to run it.'
function schedule()
  highlight()
  clearTimeout(timer)
  timer = setTimeout(run, 200)
function setSource(text)
  src.value = text
  schedule()
src.addEventListener('input', schedule)
src.addEventListener('scroll', () => { hl.parentElement.scrollTop = src.scrollTop; hl.parentElement.scrollLeft = src.scrollLeft; })
src.addEventListener('keydown', e =>
  if (e.key === 'Tab')
    e.preventDefault()
    document.execCommand('insertText', false, '  ')
  else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey))
    e.preventDefault()
    run()
)
function copy(text, btn, label)
  navigator.clipboard.writeText(text).then(() => (btn.textContent = 'Copied')).catch(() => (btn.textContent = 'Select & copy'))
  setTimeout(() => (btn.textContent = label), 1400)
$('#copy-nc').onclick = e => copy(src.value, e.target, 'Copy')
$('#copy-c').onclick = e => copy(lastC, e.target, 'Copy')
$('#share').onclick = e =>
  const b64 = btoa(String.fromCharCode(...new TextEncoder().encode(src.value))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
  history.replaceState(null, '', '#code=' + b64)
  copy(location.href, e.target, 'Share link')
function fromHash()
  const m = location.hash.match(/^#code=(.+)$/)
  if (!m) return null
  try
    const bin = atob(m[1].replace(/-/g, '+').replace(/_/g, '/'))
    return new TextDecoder().decode(Uint8Array.from(bin, c => c.charCodeAt(0)))
  catch { return null; }
spawn()
fetch('examples.json').then(r => r.json()).then(all =>
  const list = all.filter(x => !x.bt)
  const tabs = $('#tabs')
  list.forEach((ex, i) =>
    const b = document.createElement('button')
    b.type = 'button'
    b.textContent = ex.name.replace(/^examples\//, '').replace(/\.nc$/, '')
    b.onclick = () =>
      tabs.querySelectorAll('button').forEach(x => x.classList.toggle('on', x === b))
      history.replaceState(null, '', location.pathname)
      setSource(ex.nc)
    tabs.append(b)
  )
  const shared = fromHash()
  if (shared !== null) setSource(shared)
  else tabs.firstChild.click()
)
