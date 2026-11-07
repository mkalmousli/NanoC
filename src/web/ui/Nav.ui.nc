header
  css | position:sticky;top:0;z-index:50;background:rgba(13,13,11,.82);backdrop-filter:blur(12px);border-bottom:1px solid var(--line)
  div
    css
      height:64px
      display:flex
      align-items:center
      gap:26px
      width:min(1120px,calc(100% - 48px))
      margin:0 auto
      @media(max-width:700px)
        width:calc(100% - 36px)
        gap:14px
    Brand [size=26]
    nav
      css
        display:flex
        gap:20px
        font-size:14px
        color:var(--mute)
        overflow-x:auto
        scrollbar-width:none
        flex:1
        &::-webkit-scrollbar | display:none
        & a | text-decoration:none;white-space:nowrap
        & a:hover | color:var(--ink)
        @media(max-width:700px)
          display:none
      a [href=play.html] <b style="color:var(--lime)">Playground</b>
      a [href=compare.html] Compare
      a [href=index.html#guide] Guide
      a [href=index.html#install] Install
    a [href=https://github.com/mkalmousli/NanoC] GitHub ↗
      css
        margin-left:auto
        font-size:14px
        text-decoration:none
        border:1px solid var(--line)
        padding:8px 14px
        border-radius:999px
        white-space:nowrap
        &:hover | border-color:var(--lime);color:var(--lime)
        @media(max-width:700px)
          padding:7px 11px
          font-size:13px
