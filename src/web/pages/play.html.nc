Page [title="NanoC playground: transpile in your browser" desc="Edit NanoC and watch the real compiler, running as WebAssembly, produce C as you type."]
  Demo [eyebrow=Playground title="NanoC <em>playground</em>" text="The compiler runs in your browser as WebAssembly ($wasmsize). Edit an example to see the generated C."]
    ExTabs
    div
      css
        display:grid
        grid-template-columns:1fr 1fr
        gap:14px
        @media(max-width:900px)
          grid-template-columns:1fr
      Pane [title=NanoC note="edit me"]
        @head
        Chip [as=share] Share link
        Chip [as=copyNc] Copy
        @body
        div
          css
            position:relative
            height:70vh
            min-height:320px
            border:1px solid var(--line)
            border-radius:12px
            background:var(--code)
            overflow:hidden
            & pre, & textarea
              position:absolute
              inset:0
              margin:0!important
              padding:16px 18px!important
              border:0
              border-radius:0
              font:13.5px/1.6 var(--mono)!important
              letter-spacing:0!important
              word-spacing:0!important
              text-shadow:none!important
              tab-size:2!important
              white-space:pre!important
              overflow:auto
            & pre | pointer-events:none;overflow:hidden;background:transparent!important;height:auto;max-height:none;min-height:0
            & pre code | background:transparent!important;border:0;padding:0!important;display:block
            & textarea | background:transparent;color:transparent;caret-color:var(--lime)!important;resize:none;outline:none;z-index:1
            & textarea::selection | background:#d4f66a55;color:transparent
          pre [aria-hidden=true]
            code.language-nanoc [as=hl]
          textarea [as=src spellcheck=false autocomplete=off aria-label="NanoC source"]
      Pane [title=C note="live output"]
        @head
        Chip [as=copyC] Copy
        @body
        Out [lang=c as=out]
    p [as=err hidden]
      css | margin-top:18px;color:var(--rose)
    js
      let worker, seq = 0, timer, killer, lastC = ''
      const { src, hl, out, err } = A
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
        const id = ++seq
        clearTimeout(killer)
        killer = setTimeout(() =>
          worker.terminate()
          spawn()
          done({ ok: false, err: 'Timed out after 5 s: a macro or translate-time loop did not finish.', out: '', ms: 5000 })
        , 5000)
        worker.postMessage({ id, src: src.value })
      function done(r)
        err.hidden = r.ok
        if (!r.ok)
          err.textContent = r.err || 'This source could not be translated. Check the compiler diagnostic.'
          return
        lastC = r.out
        out.textContent = r.out
        Prism.highlightElement(out)
        const nc = src.value
        stats(A.stats, [['NanoC chars', nc.length], ['C chars', r.out.length], ['fewer chars', signed(nc.length, r.out.length), 1], ['NanoC lines', lines(nc)], ['C lines', lines(r.out)], ['translate time', r.ms < 1 ? '<1 ms' : Math.round(r.ms) + ' ms', 1]])
      function schedule()
        highlight()
        clearTimeout(timer)
        timer = setTimeout(run, 200)
      function setSource(text)
        src.value = text
        schedule()
      src.addEventListener('input', schedule)
      src.addEventListener('scroll', () => { hl.parentElement.scrollTop = src.scrollTop; hl.parentElement.scrollLeft = src.scrollLeft })
      src.addEventListener('keydown', e =>
        if (e.key === 'Tab')
          e.preventDefault()
          document.execCommand('insertText', false, '  ')
        else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey))
          e.preventDefault()
          run()
      )
      A.copyNc.onclick = () => copyText(src.value, A.copyNc, 'Copy')
      A.copyC.onclick = () => copyText(lastC, A.copyC, 'Copy')
      A.share.onclick = () =>
        const b64 = btoa(String.fromCharCode(...new TextEncoder().encode(src.value))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
        history.replaceState(null, '', '#code=' + b64)
        copyText(location.href, A.share, 'Share link')
      function fromHash()
        const m = location.hash.match(/^#code=(.+)$/)
        if (!m) return null
        try
          const bin = atob(m[1].replace(/-/g, '+').replace(/_/g, '/'))
          return new TextDecoder().decode(Uint8Array.from(bin, c => c.charCodeAt(0)))
        catch { return null }
      spawn()
      fetch('examples.json').then(r => r.json()).then(all =>
        const tabs = A.tabs
        all.forEach(ex =>
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
