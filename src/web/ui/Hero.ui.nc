section
  css
    width:min(1120px,calc(100% - 48px))
    margin:0 auto
    padding:88px 0 80px
    display:grid
    grid-template-columns:1.05fr .95fr
    gap:56px
    align-items:center
    & h1 | font-size:clamp(50px,7.5vw,92px);letter-spacing:-.05em
    @media(max-width:1000px)
      grid-template-columns:1fr
      padding-top:56px
    @media(max-width:700px)
      gap:40px
      width:calc(100% - 36px)
  div
    Kicker NanoC · language version 1
    h1 Compact syntax.<br>Plain <em>C output.</em>
    p A compact, self-hosted language that generates plain C11 or C++17. Indented blocks, macros that run, compile-time transformations, compact C preprocessing.
      css | font-size:18px;color:var(--mute);margin:24px 0 30px;max-width:520px
    div
      css | display:flex;gap:12px;flex-wrap:wrap
      Solid [href=play.html] Try it in your browser
      Btn [href=#guide] Start the guide
  div
    css
      position:relative
      & pre | font-size:13px
    Code [lang=nanoc]
      | f clamp(x: int, lo: int, hi: int) int
      |   if x&lt;lo
      |     &lt; lo
      |   elif x&gt;hi
      |     &lt; hi
      |   else
      |     &lt; x
      | f main()
      |   total:=0
      |   for i:=0; i&lt;10; i++
      |     total+=clamp(i,2,7)
      |   &lt; total!=45
