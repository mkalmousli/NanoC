html
  main.~compare
    p.~eyebrow Compare
    h1 Same program, two languages
    p.~lede Each example is compiled by the real NanoC compiler on every site build. Left is the NanoC you write; right is the C it generates. Nothing here is hand-edited.
    ExTabs [tabs=~tabs stats=~ex-stats]
    div.~panes
      Pane [title=NanoC note="what you write"]
        @head
        Copy [id=~copy-nc]
        @body
        Out [lang=nanoc id=~nc-code]
      Pane [title=C note="what cc builds"]
        @head
        Copy [id=~copy-c]
        @body
        Out [lang=c id=~c-code]
    p.~build <a href="play.html">Edit any of these live in the playground →</a> Or build one yourself: <code>nanoc examples/hello.nc -o out.c &amp;&amp; cc out.c -o hello</code>
    div#~ex-error.~ex-error [hidden]
css
  .~compare | max-width:1180px;margin:0 auto;padding:110px 24px 60px
  .~compare h1 | font-size:clamp(30px,4.6vw,48px);margin:6px 0 10px;letter-spacing:-.02em
  .~compare .~lede | color:var(--mute);max-width:70ch
  .~panes | display:grid;grid-template-columns:1fr 1fr;gap:14px
  .~build | color:var(--mute);margin-top:18px
  .~ex-error | margin-top:18px;color:var(--rose)
  @media(max-width:900px)
    .~panes | grid-template-columns:1fr
js
  // Side-by-side view of examples/*.nc and the C NanoC generates from them (examples.json).
  let data = []
  function show(i)
    const ex = data[i]
    document.querySelectorAll('.~ex-tabs button').forEach((b, j) =>
      b.classList.toggle('~on', j === i)
      b.setAttribute('aria-selected', j === i)
    )
    const nl = lines(ex.nc), cl = lines(ex.c)
    const nb = bytes(ex.nc), cb = bytes(ex.c)
    $('#~ex-stats').innerHTML = ''
    [
      ['NanoC lines', nl], ['C lines', cl],
      ['NanoC bytes', nb], ['C bytes', cb]
      ].forEach(([k, v]) =>
        const d = document.createElement('div')
        d.className = '~ex-stat'
        d.innerHTML = '<b></b><span></span>'
        d.querySelector('b').textContent = v.toLocaleString('en-US')
        d.querySelector('span').textContent = k
        $('#~ex-stats').append(d)
    );
    const save = document.createElement('div')
    save.className = '~ex-stat ~hi'
    save.innerHTML = '<b></b><span></span>'
    save.querySelector('b').textContent = '−' + pct(nl, cl) + '%'
    save.querySelector('span').textContent = 'fewer lines'
    $('#~ex-stats').append(save)
    const code = $('#~nc-code')
    code.textContent = ex.nc
    code.className = 'language-nanoc'
    const cc = $('#~c-code')
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
    const tabs = $('#~tabs')
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
    const e = $('#~ex-error')
    e.hidden = false
    e.textContent = 'Examples are unavailable right now.'
  )
  $('#~copy-nc').onclick = e => copyText($('#~nc-code').textContent, e.currentTarget)
  $('#~copy-c').onclick = e => copyText($('#~c-code').textContent, e.currentTarget)
