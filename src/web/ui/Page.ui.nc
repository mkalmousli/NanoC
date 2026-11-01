| <!doctype html>
html [lang=en]
  head
    meta [charset=utf-8]
    meta [name=viewport content=width=device-width,initial-scale=1]
    title $title
    meta [name=description content="$desc"]
    link [rel=icon href=favicon.svg type=image/svg+xml]
    link [rel=stylesheet href=$bundle.css]
    link [rel=stylesheet href=https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism-tomorrow.min.css]
    Prism
    script [src=$bundle.js defer]
  body
    css
      :root
        --bg:#0d0d0b
        --panel:#161612
        --line:#2c2d26
        --ink:#f3f2ec
        --mute:#9b9c92
        --dim:#64665d
        --lime:#d4f66a
        --violet:#b6a4ff
        --amber:#e0c487
        --mint:#88c8c2
        --rose:#e89b79
        --code:#11110f
        --r:14px
        --mono:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace
        --sans:-apple-system,BlinkMacSystemFont,"Segoe UI",Inter,Roboto,sans-serif
      * | box-sizing:border-box;scrollbar-width:thin;scrollbar-color:#3a3c33 transparent
      html | scroll-behavior:smooth;scroll-padding-top:72px;-webkit-text-size-adjust:100%
      margin:0
      background:var(--bg)
      color:var(--ink)
      font:16px/1.6 var(--sans)
      overflow-x:hidden
      a | color:inherit
      code,pre | font-family:var(--mono)
      pre
        margin:0
        background:var(--code)
        border:1px solid var(--line)
        border-radius:12px
        padding:16px 18px
        overflow:auto
        font-size:13.5px
        line-height:1.6
        color:#dcdcd2
      code | background:#1d1e18;border-radius:6px;padding:.1em .35em;font-size:.9em
      pre code | background:none;padding:0
      ::selection | background:var(--lime);color:#11110f
      ::-webkit-scrollbar | width:10px;height:10px
      ::-webkit-scrollbar-track | background:transparent
      ::-webkit-scrollbar-thumb | background:linear-gradient(#4a4c40,#2c2d26);border-radius:10px;border:2px solid var(--bg)
      ::-webkit-scrollbar-thumb:hover | background:linear-gradient(var(--lime),#7d9a3a)
      ::-webkit-scrollbar-corner | background:transparent
      h1,h2,h3 | font-weight:800;letter-spacing:-.03em;line-height:1.05;margin:0
      h2 | font-size:clamp(36px,5vw,58px)
      h2 em,h1 em | font-style:normal;color:var(--lime)
      section | padding:96px 0;border-top:1px solid var(--line)
      @media(max-width:700px)
        section | padding:70px 0
      @media(prefers-reduced-motion:reduce)
        * | transition:none!important;scroll-behavior:auto!important
    Nav
    Slot
    Footer
