Section [id=source kicker="Read the source" title="The compiler, <em>in NanoC.</em>"]
  Sub Every NanoC file of the compiler beside the C it generates, pre-translated when the site is built. Press <kbd>/</kbd> to search.
  div
    css
      display:grid
      grid-template-columns:250px 1fr
      border:1px solid var(--line)
      border-radius:18px
      overflow:hidden
      background:var(--panel)
      margin-top:36px
      min-height:520px
      & .file-btn
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
        text-decoration:none
      & .file-btn:hover | background:#1d1e18;color:var(--ink)
      & .file-btn.on | background:#22231d;color:var(--lime)
      & details | margin:0
      & summary | cursor:pointer;list-style:none;font:13px var(--mono);color:var(--ink);padding:6px 8px;border-radius:7px
      & summary::-webkit-details-marker | display:none
      & summary::before | content:"▸";display:inline-block;width:1.1em;color:var(--dim)
      & details[open]>summary::before | content:"▾"
      & summary:hover | background:#1d1e18
      & .tree-in | margin-left:10px;padding-left:6px;border-left:1px solid var(--line)
      & pre | border:0;border-radius:0;min-height:100%;max-height:none
      & :is(.loading,.empty-code) | padding:30px;color:var(--mute)
      @media(max-width:1000px)
        grid-template-columns:1fr
    div
      css
        border-right:1px solid var(--line)
        display:flex
        flex-direction:column
        min-width:0
        & input | margin:12px;background:#0d0d0b;border:1px solid var(--line);border-radius:10px;color:var(--ink);padding:10px 12px;font:14px var(--sans);outline:none
        & input:focus | border-color:var(--lime)
        @media(max-width:1000px)
          border-right:0
          border-bottom:1px solid var(--line)
      input [as=search type=search placeholder="Filter files…" aria-label="Filter files"]
      div [as=count]
        css | font:12px var(--mono);color:var(--dim);padding:0 14px 8px
      div [as=list]
        css | overflow:auto;flex:1;padding:0 8px 12px;max-height:460px
        css
          @media(max-width:1000px)
            max-height:200px
    div
      css | display:flex;flex-direction:column;min-width:0
      div
        css
          display:flex
          justify-content:space-between
          gap:12px
          align-items:center
          padding:12px 16px
          border-bottom:1px solid var(--line)
          font:13px var(--mono)
          color:var(--mute)
          & a | color:var(--lime);text-decoration:none;white-space:nowrap
          & [data-a=ratio] | color:var(--lime);font-size:12px
        span [as=name] Loading…
        span [as=ratio]
        a [as=raw href=https://github.com/mkalmousli/NanoC target=_blank rel=noopener] Open on GitHub ↗
      div
        css
          display:grid
          grid-template-columns:1fr 1fr
          min-width:0
          flex:1
          & > div | display:flex;flex-direction:column;min-width:0
          & > div + div | border-left:1px solid var(--line)
          & header | display:flex;justify-content:space-between;padding:8px 14px;font:12px var(--mono);color:var(--dim);border-bottom:1px solid var(--line)
          & header b | color:var(--lime);font-weight:600
          & [data-a$=view] | overflow:auto;flex:1;max-height:560px
          @media(max-width:1000px)
            grid-template-columns:1fr
            & > div + div | border-left:0;border-top:1px solid var(--line)
        div
          header <b>NanoC</b><span data-a="ncstat"></span>
          div [as=ncview]
        div
          header <b>Generated C</b><span data-a="cstat"></span>
          div [as=cview]
  js
    const RAW = 'source/'; // sources copied into the site by the site build
    let files = []
    let current = null
    const openDirs = new Set(['src', 'src/frontend'])
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
        inner.className = 'tree-in'
        det.append(inner)
        renderNode(node.dirs[d], inner, path + '/', force)
        parent.append(det)
      for (const p of node.files.sort())
        const b = document.createElement('button')
        b.className = 'file-btn' + (p === current ? ' on' : '')
        b.textContent = p.split('/').pop()
        b.title = p
        b.onclick = () => open(p)
        parent.append(b)
    function render()
      A.list.replaceChildren()
      const q = A.search.value.toLowerCase()
      const matches = files.filter(p => p.toLowerCase().includes(q))
      renderNode(buildTree(matches), A.list, '', q.length > 0)
      A.count.textContent = matches.length + ' NanoC files'
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
      const view = A.cview
      if (!r.ok)
        view.innerHTML = '<div class="empty-code">No C preview: ' + 'this file needs build-time (@bt) host access, so it has no standalone C' + '.</div>'
        A.cstat.textContent = ''
        return
      show(view, r.out, 'c')
      const c = lines(r.out)
      A.cstat.textContent = c + ' lines'
      A.ratio.textContent = c && ncLines ? (ncLines <= c ? Math.round((1 - ncLines / c) * 100) + '% fewer lines than C' : 'longer than its C') : ''
    async function open(path)
      current = path
      render()
      A.name.textContent = path
      A.raw.href = REPO + '/blob/main/' + path
      A.ncview.innerHTML = '<div class="loading">Loading…</div>'
      A.cview.innerHTML = '<div class="loading">Loading…</div>'
      A.ratio.textContent = ''
      try
        let r = await fetch('source/' + path)
        if (!r.ok) r = await fetch(RAW + path)
        if (!r.ok) throw Error(String(r.status))
        const text = await r.text()
        if (current !== path) return
        ncLines = lines(text)
        A.ncstat.textContent = ncLines + ' lines'
        show(A.ncview, text, 'nanoc')
        const cr = await fetch('c/' + path)
        if (current !== path) return
        const cout = cr.ok ? await cr.text() : ''
        showC({ ok: cout.length > 0, out: cout })
      catch
        A.ncview.innerHTML = '<div class="empty-code">Could not load this file. <a href="' + REPO + '">Open the repository ↗</a></div>'
    A.search.oninput = render
    document.addEventListener('keydown', e =>
      if (e.key === '/' && document.activeElement.tagName !== 'INPUT')
        e.preventDefault()
        A.search.focus()
    )
    fetch('files.json').then(r =>
      if (!r.ok) throw Error(String(r.status))
      return r.json()
    ).then(paths =>
      files = paths.filter(p => p.endsWith('.nc'))
      render()
      open(files.includes('src/frontend/expand.nc') ? 'src/frontend/expand.nc' : files[0])
    ).catch(() =>
      A.list.innerHTML = '<a class="file-btn" href="' + REPO + '/tree/main">Index unavailable. Browse on GitHub ↗</a>'
      A.count.textContent = ''
    )
