html
  pre
    code.language-$lang
      Slot
css
  .~boxed | position:relative
js
  // Every <pre> gets a copy button; NanoC blocks are highlighted.
  Prism.highlightAll()
  document.querySelectorAll('pre').forEach(pre =>
    if (pre.id === '~prompt-text') return
    const wrap = document.createElement('div')
    wrap.className = '~boxed'
    const b = document.createElement('button')
    b.className = '~copy'
    b.type = 'button'
    b.textContent = 'Copy'
    b.onclick = () => copyText(pre.innerText, b)
    pre.replaceWith(wrap)
    wrap.append(pre, b)
  )
