html
  section.~hero.~wrap [style=border:0;padding-bottom:70px]
    div
      p.~kicker C, with less ceremony
      h1 Write closer<br>to the <em>idea.</em>
      p.~lede A compact, self-hosted language that generates plain C11 or C++17. Indented blocks, macros that run, compile-time and build-time code, inline assembly.
      div.~cta <a class="~btn ~solid" href="play.html">Try it in your browser</a><a class="~btn" href="#guide">Start the guide</a><a class="~btn" href="#stats">See the numbers</a>
    div.~hero-code.~boxed
      Code [lang=nanoc]
        | @f clamp(int x,lo,hi) int
        |   if x&lt;lo
        |     lo
        |   elif x&gt;hi
        |     hi
        |   else
        |     x
        | @f main int
        |   total:=0
        |   for i 0..10
        |     total+=clamp(i,2,7)
        |   total!=45
      span.~badge [data-stat=badge] −7% lines vs C
css
  .~hero | padding:88px 0 80px;display:grid;grid-template-columns:1.05fr .95fr;gap:56px;align-items:center
  .~hero h1 | font-size:clamp(50px,7.5vw,92px);letter-spacing:-.05em
  .~hero .~lede | font-size:18px;color:var(--mute);margin:24px 0 30px;max-width:520px
  .~cta | display:flex;gap:12px;flex-wrap:wrap
  .~hero-code | position:relative
  .~hero-code pre | font-size:13px
  .~badge
    position:absolute
    right:14px
    bottom:-14px
    background:var(--panel)
    border:1px solid var(--lime)
    color:var(--lime)
    font:600 12px var(--mono)
    padding:7px 12px
    border-radius:999px
  @media(max-width:1000px)
    .~hero | grid-template-columns:1fr;padding-top:56px
  @media(max-width:700px)
    .~hero | gap:40px
    .~hero .~lede | font-size:16px
    .~badge | display:none
  @media(max-width:420px)
    .~hero h1 | font-size:46px;letter-spacing:-3px
