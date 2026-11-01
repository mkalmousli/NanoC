html
  main.~compare.~play
    p.~eyebrow Playground
    h1 The real compiler, <em>in your tab</em>
    p.~lede This is not a mock-up: the NanoC compiler is compiled to WebAssembly ($wasmsize) and runs here, offline, as you type. Pick an example or write your own; the C appears on the right.
    ExTabs [tabs=~tabs stats=~stats]
    div.~panes
      Pane [title=NanoC note="edit me"]
        @head
        button.~copy#~share [type=button] Share link
        Copy [id=~copy-nc]
        @body
        div.~editor
          pre [aria-hidden=true]
            code#~hl.language-nanoc
          textarea#~src [spellcheck=false autocomplete=off aria-label="NanoC source"]
      Pane [title=C note="live output"]
        @head
        Copy [id=~copy-c]
        @body
        Out [lang=c id=~out]
    div#~err.~ex-error [hidden]
css
  .~editor | position:relative;height:70vh;min-height:320px;border:1px solid var(--line);border-radius:12px;background:var(--code);overflow:hidden
  .~editor pre,.~editor textarea
    position:absolute
    inset:0
    margin:0
    padding:16px 18px
    border:0
    border-radius:0
    font:13.5px/1.6 var(--mono)
    white-space:pre
    overflow:auto
    tab-size:2
  .~editor pre | pointer-events:none;overflow:hidden
  .~editor textarea | background:transparent;color:transparent;caret-color:var(--lime);resize:none;outline:none;z-index:1
  .~editor textarea::selection | background:#d4f66a55;color:transparent
  .~play .~pane pre | height:70vh
  .~play .~ex-stats .~stat | padding:14px
  .~play .~ex-stats .~stat b | font-size:26px
  .~editor pre,.~editor code | background:transparent!important;border:0
  .~editor | margin:0
  .~editor pre,.~editor pre code,.~editor textarea
    font:13.5px/1.6 var(--mono)!important
    letter-spacing:0!important
    word-spacing:0!important
    text-shadow:none!important
    tab-size:2!important
    white-space:pre!important
  .~editor pre | padding:16px 18px!important;margin:0!important
  .~editor pre code | padding:0!important;display:block
  .~editor textarea | padding:16px 18px!important;caret-color:var(--lime)!important
js
  // NanoC playground: editor + the compiler running as WebAssembly in a worker.
  const src = $('#~src'), hl = $('#~hl'), out = $('#~out'), err = $('#~err')
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
      const stat = (k, v, cls = '') => `<div class="~stat ${cls}"><b>${v}</b><span>${k}</span></div>`
      const ln = lines(nc), lc = lines(r.out)
      $('#~stats').innerHTML = stat('NanoC lines', ln) + stat('C lines', lc) + stat('NanoC bytes', bytes(nc)) + stat('C bytes', bytes(r.out)) +
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
  $('#~copy-nc').onclick = e => copyText(src.value, e.target, 'Copy')
  $('#~copy-c').onclick = e => copyText(lastC, e.target, 'Copy')
  $('#~share').onclick = e =>
    const b64 = btoa(String.fromCharCode(...new TextEncoder().encode(src.value))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
    history.replaceState(null, '', '#code=' + b64)
    copyText(location.href, e.target, 'Share link')
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
    const tabs = $('#~tabs')
    list.forEach((ex, i) =>
      const b = document.createElement('button')
      b.type = 'button'
      b.textContent = ex.name.replace(/^examples\//, '').replace(/\.nc$/, '')
      b.onclick = () =>
        tabs.querySelectorAll('button').forEach(x => x.classList.toggle('~on', x === b))
        history.replaceState(null, '', location.pathname)
        setSource(ex.nc)
      tabs.append(b)
    )
    const shared = fromHash()
    if (shared !== null) setSource(shared)
    else tabs.firstChild.click()
  )
