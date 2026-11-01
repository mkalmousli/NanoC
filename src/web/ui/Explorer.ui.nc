html
  Section [id=source kicker="Read the source" title="The compiler, <em>in NanoC.</em>"]
    p.~sub Every NanoC file of the compiler beside the C it generates, compiled live in your browser. Press <kbd>/</kbd> to search.
    div.~explorer
      div.~rail
        input#~search [type=search placeholder="Filter files…" aria-label="Filter files"]
        div#~file-count.~file-count
        div#~file-list.~file-list
      div.~viewer
        div.~viewer-head <span id="~selected-name">Loading…</span><span id="~ratio" class="~ratio"></span><a id="~raw-link" href="https://github.com/mkalmousli/NanoC" target="_blank" rel="noopener">Open on GitHub ↗</a>
        div.~pair
          div.~half
            div.~half-head <b>NanoC</b><span id="~nc-stat"></span>
            div#~nc-view.~code-view
          div.~half
            div.~half-head <b>Generated C</b><span id="~c-stat"></span>
            div#~c-view.~code-view
css
  .~explorer
    display:grid
    grid-template-columns:250px 1fr
    border:1px solid var(--line)
    border-radius:18px
    overflow:hidden
    background:var(--panel)
    margin-top:36px
    min-height:520px
  .~rail | border-right:1px solid var(--line);display:flex;flex-direction:column;min-width:0
  .~rail input | margin:12px;background:#0d0d0b;border:1px solid var(--line);border-radius:10px;color:var(--ink);padding:10px 12px;font:14px var(--sans);outline:none
  .~rail input:focus | border-color:var(--lime)
  .~file-count | font:12px var(--mono);color:var(--dim);padding:0 14px 8px
  .~file-list | overflow:auto;flex:1;padding:0 8px 12px;max-height:460px
  .~folder-label | font:600 10px var(--mono);letter-spacing:.14em;color:var(--dim);padding:14px 8px 6px
  .~file-btn
    display:block
    width:100%
    text-align:left
    background:none
    border:0
    color:var(--mute)
    font:13px var(--mono)
    padding:7px 8px
    border-radius:7px
    cursor:pointer
    overflow:hidden
    text-overflow:ellipsis
    white-space:nowrap
  .~file-btn:hover | background:#1d1e18;color:var(--ink)
  .~file-btn.~on | background:#22231d;color:var(--lime)
  .~viewer | display:flex;flex-direction:column;min-width:0
  .~viewer-head
    display:flex
    justify-content:space-between
    gap:12px
    align-items:center
    padding:12px 16px
    border-bottom:1px solid var(--line)
    font:13px var(--mono)
    color:var(--mute)
  .~viewer-head a | color:var(--lime);text-decoration:none;white-space:nowrap
  .~code-view | overflow:auto;flex:1;max-height:560px
  .~pair | display:grid;grid-template-columns:1fr 1fr;min-width:0;flex:1
  .~half | display:flex;flex-direction:column;min-width:0
  .~half+.~half | border-left:1px solid var(--line)
  .~half-head | display:flex;justify-content:space-between;padding:8px 14px;font:12px var(--mono);color:var(--dim);border-bottom:1px solid var(--line)
  .~half-head b | color:var(--lime);font-weight:600
  .~ratio | color:var(--lime);font:12px var(--mono)
  details | margin:0
  summary | cursor:pointer;list-style:none;font:13px var(--mono);color:var(--ink);padding:6px 8px;border-radius:7px
  summary::-webkit-details-marker | display:none
  summary::before | content:"▸";display:inline-block;width:1.1em;color:var(--dim)
  details[open]>summary::before | content:"▾"
  summary:hover | background:#1d1e18
  .~tree-in | margin-left:10px;padding-left:6px;border-left:1px solid var(--line)
  .~code-view pre | border:0;border-radius:0;min-height:100%;max-height:none
  .~loading,.~empty-code | padding:30px;color:var(--mute)
  @media(max-width:1000px)
    .~explorer | grid-template-columns:1fr
    .~rail | border-right:0;border-bottom:1px solid var(--line)
    .~pair | grid-template-columns:1fr
    .~half+.~half | border-left:0;border-top:1px solid var(--line)
    .~file-list | max-height:200px
js
  const RAW = 'source/'; // sources copied into the site by the site build
  // ---- source explorer: folder tree of .nc files; NanoC beside the C the compiler generates ----
  const list = $('#~file-list')
  const search = $('#~search')
  const count = $('#~file-count')
  let files = []
  let current = null
  const openDirs = new Set(['src', 'src/frontend'])
  let worker, seq = 0, killer
  function spawn()
    worker = new Worker('worker.js')
    worker.onmessage = e =>
      if (e.data.id !== seq) return
      clearTimeout(killer)
      showC(e.data)
  function buildTree(paths)
    const root = { dirs: {}, files: [] }
    for (const p of paths)
      const parts = p.split('/')
      let node = root
      for (const d of parts.slice(0, -1)) node = node.dirs[d] ||= { dirs: {}, files: [] }
      node.files.push(p)
    return root
  function renderNode(node, parent, prefix, force)
    for (const d of Object.keys(node.dirs).sort())
      const path = prefix + d
      const det = document.createElement('details')
      det.open = force || openDirs.has(path)
      det.ontoggle = () => { if (!force) det.open ? openDirs.add(path) : openDirs.delete(path); }
      const sum = document.createElement('summary')
      sum.textContent = d
      det.append(sum)
      const inner = document.createElement('div')
      inner.className = '~tree-in'
      det.append(inner)
      renderNode(node.dirs[d], inner, path + '/', force)
      parent.append(det)
    for (const p of node.files.sort())
      const b = document.createElement('button')
      b.className = '~file-btn' + (p === current ? ' ~on' : '')
      b.textContent = p.split('/').pop()
      b.title = p
      b.onclick = () => open(p)
      parent.append(b)
  function render()
    list.replaceChildren()
    const q = search.value.toLowerCase()
    const matches = files.filter(p => p.toLowerCase().includes(q))
    renderNode(buildTree(matches), list, '', q.length > 0)
    count.textContent = matches.length + ' NanoC files'
  function show(view, text, lang)
    const code = document.createElement('code')
    code.className = 'language-' + lang
    code.textContent = text
    const pre = document.createElement('pre')
    pre.append(code)
    view.replaceChildren(pre)
    Prism.highlightElement(code)
  let ncLines = 0
  function showC(r)
    const view = $('#~c-view')
    if (!r.ok)
      view.innerHTML = '<div class="~empty-code">No C preview: ' + (r.err ? r.err.split('\n')[0].replace(/[<&]/g, '') : 'this file needs build-time (@bt) host access, which the browser build does not have') + '.</div>'
      $('#~c-stat').textContent = ''
      return
    show(view, r.out, 'c')
    const c = lines(r.out)
    $('#~c-stat').textContent = c + ' lines · ' + Math.round(r.ms < 1 ? 1 : r.ms) + ' ms'
    $('#~ratio').textContent = c && ncLines ? (ncLines <= c ? Math.round((1 - ncLines / c) * 100) + '% fewer lines than C' : 'longer than its C') : ''
  async function open(path)
    current = path
    render()
    $('#~selected-name').textContent = path
    $('#~raw-link').href = REPO + '/blob/main/' + path
    $('#~nc-view').innerHTML = '<div class="~loading">Loading…</div>'
    $('#~c-view').innerHTML = '<div class="~loading">Compiling in your browser…</div>'
    $('#~ratio').textContent = ''
    try
      let r = await fetch('source/' + path)
      if (!r.ok) r = await fetch(RAW + path)
      if (!r.ok) throw Error(String(r.status))
      const text = await r.text()
      if (current !== path) return
      ncLines = lines(text)
      $('#~nc-stat').textContent = ncLines + ' lines'
      show($('#~nc-view'), text, 'nanoc')
      const id = ++seq
      clearTimeout(killer)
      killer = setTimeout(() =>
        worker.terminate()
        spawn()
        showC({ ok: false, err: 'timed out', out: '', ms: 5000 })
      , 5000)
      worker.postMessage({ id, src: text })
    catch
      $('#~nc-view').innerHTML = '<div class="~empty-code">Could not load this file. <a href="' + REPO + '">Open the repository ↗</a></div>'
  search.oninput = render
  document.addEventListener('keydown', e =>
    if (e.key === '/' && document.activeElement.tagName !== 'INPUT')
      e.preventDefault()
      search.focus()
  )
  spawn()
  fetch('files.json').then(r =>
    if (!r.ok) throw Error(String(r.status))
    return r.json()
  ).then(paths =>
    files = paths.filter(p => p.endsWith('.nc'))
    render()
    open(files.includes('src/frontend/expand.nc') ? 'src/frontend/expand.nc' : files[0])
  ).catch(() =>
    list.innerHTML = '<a class="~file-btn" href="' + REPO + '/tree/main">Index unavailable. Browse on GitHub ↗</a>'
    count.textContent = ''
  )
