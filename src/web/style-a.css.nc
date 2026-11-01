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
* | box-sizing:border-box
html | scroll-behavior:smooth;scroll-padding-top:72px;-webkit-text-size-adjust:100%
body | margin:0;background:var(--bg);color:var(--ink);font:16px/1.6 var(--sans);overflow-x:hidden
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
  scrollbar-width:thin
  scrollbar-color:#3a3c33 transparent
code | background:#1d1e18;border-radius:6px;padding:.1em .35em;font-size:.9em
pre code | background:none;padding:0
::selection | background:var(--lime);color:#11110f
// custom scrollbars
* | scrollbar-width:thin;scrollbar-color:#3a3c33 transparent
::-webkit-scrollbar | width:10px;height:10px
::-webkit-scrollbar-track | background:transparent
::-webkit-scrollbar-thumb | background:linear-gradient(#4a4c40,#2c2d26);border-radius:10px;border:2px solid var(--bg)
::-webkit-scrollbar-thumb:hover | background:linear-gradient(var(--lime),#7d9a3a)
::-webkit-scrollbar-corner | background:transparent
.wrap | width:min(1120px,calc(100% - 48px));margin:0 auto
.kicker | font:600 12px/1 var(--mono);letter-spacing:.14em;text-transform:uppercase;color:var(--lime);margin:0 0 16px;display:flex;gap:10px;align-items:center
.kicker:before | content:"";width:22px;height:2px;background:var(--lime)
h1,h2,h3 | font-weight:800;letter-spacing:-.03em;line-height:1.05;margin:0
h2 | font-size:clamp(36px,5vw,58px)
h2 em,h1 em | font-style:normal;color:var(--lime)
.sub | color:var(--mute);max-width:620px;font-size:17px
section | padding:96px 0;border-top:1px solid var(--line)
// top bar
.top | position:sticky;top:0;z-index:50;background:rgba(13,13,11,.82);backdrop-filter:blur(12px);border-bottom:1px solid var(--line)
.top-in | height:64px;display:flex;align-items:center;gap:26px;width:min(1120px,calc(100% - 48px));margin:0 auto
.brand | display:flex;align-items:center;gap:10px;font-weight:800;text-decoration:none;letter-spacing:-.02em
.top nav | display:flex;gap:20px;font-size:14px;color:var(--mute);overflow-x:auto;scrollbar-width:none;flex:1
.top nav::-webkit-scrollbar | display:none
.top nav a | text-decoration:none;white-space:nowrap
.top nav a:hover | color:var(--ink)
.gh | margin-left:auto;font-size:14px;text-decoration:none;border:1px solid var(--line);padding:8px 14px;border-radius:999px;white-space:nowrap
.gh:hover | border-color:var(--lime);color:var(--lime)
// hero
.hero | padding:88px 0 80px;display:grid;grid-template-columns:1.05fr .95fr;gap:56px;align-items:center
.hero h1 | font-size:clamp(50px,7.5vw,92px);letter-spacing:-.05em
.hero .lede | font-size:18px;color:var(--mute);margin:24px 0 30px;max-width:520px
.cta | display:flex;gap:12px;flex-wrap:wrap
.btn | text-decoration:none;font-weight:700;font-size:14px;padding:13px 20px;border-radius:999px;border:1px solid var(--line);transition:.2s
.btn.solid | background:var(--lime);color:#11110f;border-color:var(--lime)
.btn:hover | transform:translateY(-1px);border-color:var(--lime)
.hero-code | position:relative
.hero-code pre | font-size:13px
.badge
  position:absolute
  right:14px
  bottom:-14px
  background:var(--panel)
  border:1px solid var(--lime)
  color:var(--lime)
  font:600 12px var(--mono)
  padding:7px 12px
  border-radius:999px
// copy button
.copy
  position:absolute
  top:10px
  right:10px
  background:#22231d
  color:var(--mute)
  border:1px solid var(--line)
  border-radius:8px
  font:600 11px var(--mono)
  padding:6px 10px
  cursor:pointer
.copy:hover | color:var(--ink);border-color:var(--lime)
.boxed | position:relative
// stats
.stat-grid | display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin:44px 0
.stat | background:var(--panel);border:1px solid var(--line);border-radius:var(--r);padding:24px
.stat b | display:block;font:800 clamp(34px,4vw,50px)/1 var(--sans);letter-spacing:-.04em;color:var(--ink)
.stat b.hi | color:var(--lime)
.stat span | display:block;margin-top:10px;color:var(--mute);font-size:14px
div.compare | background:var(--panel);border:1px solid var(--line);border-radius:var(--r);padding:28px
.bar-row | display:grid;grid-template-columns:150px 1fr 110px;gap:14px;align-items:center;margin:14px 0;font-size:14px
.bar-row .name | font-family:var(--mono);color:var(--mute)
.track | position:relative;height:22px;background:#1d1e18;border-radius:6px;overflow:hidden
.track i | position:absolute;inset:0 auto 0 0;border-radius:6px;background:#3a3c33;transition:width 1.2s cubic-bezier(.2,.7,.2,1)
.track i.nc | background:linear-gradient(90deg,var(--lime),#a5d64a)
.bar-row .num | font-family:var(--mono);text-align:right;color:var(--mute)
.legend | display:flex;gap:18px;font-size:13px;color:var(--mute);margin-bottom:6px;flex-wrap:wrap
.legend i | display:inline-block;width:12px;height:12px;border-radius:3px;margin-right:6px;vertical-align:-1px
.method | color:var(--dim);font-size:13px;margin-top:18px
// guide
.guide | display:grid;grid-template-columns:220px 1fr;gap:56px;align-items:start
.toc | position:sticky;top:96px;display:flex;flex-direction:column;gap:2px;max-height:calc(100vh - 120px);overflow:auto;padding-right:6px
.toc a | text-decoration:none;color:var(--mute);font-size:14px;padding:7px 10px;border-radius:8px;border-left:2px solid transparent
.toc a:hover | color:var(--ink);background:#181913
.toc a.on | color:var(--lime);border-left-color:var(--lime);background:#181913
.toc a span | font:600 11px var(--mono);color:var(--dim);margin-right:8px
.lesson | padding:0 0 64px;margin-bottom:64px;border-bottom:1px dashed var(--line)
.lesson:last-child | border:0
.lesson .n | font:600 12px var(--mono);color:var(--violet);letter-spacing:.1em
.lesson h3 | font-size:34px;margin:10px 0 14px
.lesson p | color:var(--mute);margin:0 0 18px;max-width:680px
.lesson ul | color:var(--mute);margin:14px 0 0;padding-left:20px
.lesson li | margin:6px 0
.lesson .pair | display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-top:8px
.lesson .pair>div | min-width:0
.lesson .label | font:600 11px var(--mono);color:var(--dim);letter-spacing:.1em;text-transform:uppercase;margin:0 0 8px
.note | font-size:14px;color:var(--mute);border-left:2px solid var(--violet);padding:4px 0 4px 14px;margin:16px 0 0
table.cards | width:100%;border-collapse:collapse;font-size:14px;margin-top:8px;display:block;overflow-x:auto
table.cards td,table.cards th | text-align:left;padding:11px 12px;border-bottom:1px solid var(--line);vertical-align:top
table.cards th | color:var(--dim);font:600 11px var(--mono);letter-spacing:.1em;text-transform:uppercase
table.cards td:first-child code | color:var(--lime);background:none
// try it
.try | background:var(--panel);border:1px solid var(--line);border-radius:18px;padding:30px;display:grid;grid-template-columns:1fr auto;gap:22px;align-items:start
.try p | margin:0;color:var(--mute);font-size:15px
.try pre | margin-top:18px;font-size:13.5px;white-space:pre-wrap;max-height:260px
.try .go | align-self:center
// install
.cmds | display:grid;grid-template-columns:1fr 1fr;gap:14px
.cmds>div | background:var(--panel);border:1px solid var(--line);border-radius:var(--r);padding:20px;min-width:0
.cmds h4 | margin:0 0 12px;font-size:15px
.cmds pre | font-size:12.5px;white-space:pre-wrap;word-break:break-all
// editors
.eds | display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-top:36px
.ed | background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:16px;min-width:0
.ed b | display:block
.ed span | color:var(--mute);font-size:13px
.ed code | display:block;margin-top:10px;font-size:12px;color:var(--lime);background:none;padding:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis
// explorer
