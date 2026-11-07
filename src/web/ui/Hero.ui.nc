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
    Kicker C, with less ceremony
    h1 Write closer<br>to the <em>idea.</em>
    p A compact, self-hosted language that generates plain C11 or C++17. Indented blocks, macros that run, compile-time transformations, compact C preprocessing.
      css | font-size:18px;color:var(--mute);margin:24px 0 30px;max-width:520px
    div
      css | display:flex;gap:12px;flex-wrap:wrap
      Solid [href=play.html] Try it in your browser
      Btn [href=#guide] Start the guide
      Btn [href=#stats] See the numbers
  div
    css
      position:relative
      & pre | font-size:13px
    Code [lang=nanoc]
      | f clamp(int x, int lo, int hi) -&gt; int
      |   if x&lt;lo
      |     return lo
      |   elif x&gt;hi
      |     return hi
      |   else
      |     return x
      | f main() -&gt; int
      |   total:=0
      |   for i:=0; i&lt;10; i++
      |     total+=clamp(i,2,7)
      |   return total!=45
    span [data-stat=badge] fewer characters than C
      css
        position:absolute
        right:14px
        bottom:-14px
        background:var(--panel)
        border:1px solid var(--lime)
        color:var(--lime)
        font:600 12px var(--mono)
        padding:7px 12px
        border-radius:999px
        @media(max-width:700px)
          display:none
