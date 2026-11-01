Page [title="NanoC vs C: side by side" desc="The same program in NanoC and the C the compiler generates from it, with line and byte counts."]
  Demo [eyebrow=Compare title="Same program, two languages" text="Each example is compiled by the real NanoC compiler on every site build. Left is the NanoC you write; right is the C it generates. Nothing here is hand-edited."]
    ExTabs
    div
      css
        display:grid
        grid-template-columns:1fr 1fr
        gap:14px
        @media(max-width:900px)
          grid-template-columns:1fr
      Pane [title=NanoC note="what you write"]
        @head
        Chip [as=copyNc] Copy
        @body
        Out [lang=nanoc as=ncCode]
      Pane [title=C note="what cc builds"]
        @head
        Chip [as=copyC] Copy
        @body
        Out [lang=c as=cCode]
    Fine <a href="play.html">Edit any of these live in the playground →</a> Or build one yourself: <code>nanoc examples/hello.nc -o out.c &amp;&amp; cc out.c -o hello</code>
    p [as=error hidden]
      css | margin-top:18px;color:var(--rose)
    js
      let data = []
      function show(i)
        const ex = data[i]
        A.tabs.querySelectorAll('button').forEach((b, j) => b.classList.toggle('on', j === i))
        const nl = lines(ex.nc), cl = lines(ex.c)
        stats(A.stats, [['NanoC lines', nl], ['C lines', cl], ['NanoC bytes', bytes(ex.nc)], ['C bytes', bytes(ex.c)], ['fewer lines', signed(nl, cl), 1]])
        for (const [el, text, lang] of [[A.ncCode, ex.nc, 'nanoc'], [A.cCode, ex.c, 'c']])
          el.textContent = text
          Prism.highlightElement(el)
        history.replaceState(null, '', '#' + ex.name.replace('examples/', '').replace('.nc', ''))
      fetch('examples.json').then(r => r.json()).then(list =>
        data = list
        list.forEach((ex, i) =>
          const b = document.createElement('button')
          b.type = 'button'
          b.textContent = ex.name.replace('examples/', '')
          b.onclick = () => show(i)
          A.tabs.append(b)
        )
        show(Math.max(0, list.findIndex(ex => ex.name === 'examples/' + location.hash.slice(1) + '.nc')))
      ).catch(() =>
        A.error.hidden = false
        A.error.textContent = 'Examples are unavailable right now.'
      )
      A.copyNc.onclick = () => copyText(A.ncCode.textContent, A.copyNc, 'Copy')
      A.copyC.onclick = () => copyText(A.cCode.textContent, A.copyC, 'Copy')
