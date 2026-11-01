html
  header.~top
    div.~top-in
      a.~brand [href=index.html] <img src="logo.svg" width="26" height="26" alt=""> NanoC
      nav <a href="play.html"><b class="~lime">Playground</b></a><a href="compare.html">Compare</a><a href="index.html#stats">Stats</a><a href="index.html#vs">Vs. others</a><a href="index.html#guide">Guide</a><a href="index.html#install">Install</a><a href="index.html#source">Source</a>
      a.~gh [href=https://github.com/mkalmousli/NanoC] GitHub ↗
css
  .~top | position:sticky;top:0;z-index:50;background:rgba(13,13,11,.82);backdrop-filter:blur(12px);border-bottom:1px solid var(--line)
  .~top-in | height:64px;display:flex;align-items:center;gap:26px;width:min(1120px,calc(100% - 48px));margin:0 auto
  .~brand | display:flex;align-items:center;gap:10px;font-weight:800;text-decoration:none;letter-spacing:-.02em
  .~top nav | display:flex;gap:20px;font-size:14px;color:var(--mute);overflow-x:auto;scrollbar-width:none;flex:1
  .~top nav::-webkit-scrollbar | display:none
  .~top nav a | text-decoration:none;white-space:nowrap
  .~top nav a:hover | color:var(--ink)
  .~gh | margin-left:auto;font-size:14px;text-decoration:none;border:1px solid var(--line);padding:8px 14px;border-radius:999px;white-space:nowrap
  .~gh:hover | border-color:var(--lime);color:var(--lime)
  .~lime | color:var(--lime)
  @media(max-width:700px)
    .~top-in | width:calc(100% - 36px);gap:14px
    .~top nav | display:none
    .~gh | padding:7px 11px;font-size:13px
