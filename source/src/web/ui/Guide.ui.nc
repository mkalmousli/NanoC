Section [id=guide kicker="Language guide" title="Learn it in <em>ten minutes.</em>"]
  Sub Every example compiles and runs with the current compiler, and the C beside it is what that compiler produces right now. Unmarked C stays valid, so you can adopt NanoC one function at a time.
  div
    css
      display:grid
      grid-template-columns:220px 1fr
      gap:56px
      align-items:start
      margin-top:56px
      @media(max-width:1000px)
        grid-template-columns:1fr
    nav [aria-label="Guide sections"]
      css
        position:sticky
        top:96px
        display:flex
        flex-direction:column
        gap:2px
        max-height:calc(100vh - 120px)
        overflow:auto
        padding-right:6px
        & a | text-decoration:none;color:var(--mute);font-size:14px;padding:7px 10px;border-radius:8px;border-left:2px solid transparent
        & a:hover | color:var(--ink);background:#181913
        & a[aria-current] | color:var(--lime);border-left-color:var(--lime);background:#181913
        & span | font:600 11px var(--mono);color:var(--dim);margin-right:8px
        @media(max-width:1000px)
          position:static
          flex-direction:row
          overflow-x:auto
          max-height:none
          margin:0 -24px
          padding:0 24px 10px
          border-bottom:1px solid var(--line)
          & a | white-space:nowrap;border:1px solid var(--line);border-radius:999px;padding:7px 14px
          & a[aria-current] | border-color:var(--lime)
      js
        const links = [...el.querySelectorAll('a')]
        const io = new IntersectionObserver(entries =>
          entries.forEach(e =>
            if (!e.isIntersecting) return
            links.forEach(a => a.toggleAttribute('aria-current', a.getAttribute('href') === '#' + e.target.id))
          )
        , { rootMargin: '-35% 0px -55% 0px' })
        document.querySelectorAll('article[id]').forEach(a => io.observe(a))
      Doc [src=src/content/guide.doc.nc toc]
    div
      Doc [src=src/content/guide.doc.nc]
