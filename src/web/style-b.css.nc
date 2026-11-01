.explorer
  display:grid
  grid-template-columns:250px 1fr
  border:1px solid var(--line)
  border-radius:18px
  overflow:hidden
  background:var(--panel)
  margin-top:36px
  min-height:520px
.rail | border-right:1px solid var(--line);display:flex;flex-direction:column;min-width:0
.rail input | margin:12px;background:#0d0d0b;border:1px solid var(--line);border-radius:10px;color:var(--ink);padding:10px 12px;font:14px var(--sans);outline:none
.rail input:focus | border-color:var(--lime)
.file-count | font:12px var(--mono);color:var(--dim);padding:0 14px 8px
.file-list | overflow:auto;flex:1;padding:0 8px 12px;max-height:460px
.folder-label | font:600 10px var(--mono);letter-spacing:.14em;color:var(--dim);padding:14px 8px 6px
.file-btn
  display:block
  width:100%
  text-align:left
  background:none
  border:0
  color:var(--mute)
  font:13px var(--mono)
  padding:7px 8px
  border-radius:7px
  cursor:pointer
  overflow:hidden
  text-overflow:ellipsis
  white-space:nowrap
.file-btn:hover | background:#1d1e18;color:var(--ink)
.file-btn.on | background:#22231d;color:var(--lime)
.viewer | display:flex;flex-direction:column;min-width:0
.viewer-head
  display:flex
  justify-content:space-between
  gap:12px
  align-items:center
  padding:12px 16px
  border-bottom:1px solid var(--line)
  font:13px var(--mono)
  color:var(--mute)
.viewer-head a | color:var(--lime);text-decoration:none;white-space:nowrap
.code-view | overflow:auto;flex:1;max-height:560px
.pair | display:grid;grid-template-columns:1fr 1fr;min-width:0;flex:1
.half | display:flex;flex-direction:column;min-width:0
.half+.half | border-left:1px solid var(--line)
.half-head | display:flex;justify-content:space-between;padding:8px 14px;font:12px var(--mono);color:var(--dim);border-bottom:1px solid var(--line)
.half-head b | color:var(--lime);font-weight:600
.ratio | color:var(--lime);font:12px var(--mono)
details | margin:0
summary | cursor:pointer;list-style:none;font:13px var(--mono);color:var(--ink);padding:6px 8px;border-radius:7px
summary::-webkit-details-marker | display:none
summary::before | content:"▸";display:inline-block;width:1.1em;color:var(--dim)
details[open]>summary::before | content:"▾"
summary:hover | background:#1d1e18
.tree-in | margin-left:10px;padding-left:6px;border-left:1px solid var(--line)
.code-view pre | border:0;border-radius:0;min-height:100%;max-height:none
.loading,.empty-code | padding:30px;color:var(--mute)
// footer
footer | border-top:1px solid var(--line);padding:34px 0;color:var(--dim);font-size:14px
footer .wrap | display:flex;gap:18px;align-items:center;justify-content:space-between;flex-wrap:wrap
// responsive
@media(max-width:1000px)
  .hero | grid-template-columns:1fr;padding-top:56px
  .guide | grid-template-columns:1fr
  .toc
    position:static
    flex-direction:row
    flex-wrap:nowrap
    overflow-x:auto
    max-height:none
    padding:0 0 10px
    margin:0 -24px
    padding-left:24px
    padding-right:24px
    border-bottom:1px solid var(--line)
  .toc a | white-space:nowrap;border-left:0;border:1px solid var(--line);border-radius:999px;padding:7px 14px
  .toc a.on | border-color:var(--lime)
  .stat-grid | grid-template-columns:1fr 1fr
  .eds | grid-template-columns:1fr 1fr
  .explorer | grid-template-columns:1fr
  .rail | border-right:0;border-bottom:1px solid var(--line)
  .pair | grid-template-columns:1fr
  .half+.half | border-left:0;border-top:1px solid var(--line)
  .file-list | max-height:200px
@media(max-width:700px)
  section | padding:70px 0
  .wrap | width:calc(100% - 36px)
  .top-in | width:calc(100% - 36px);gap:14px
  .top nav | display:none
  .gh | padding:7px 11px;font-size:13px
  .hero | gap:40px
  .hero .lede | font-size:16px
  .lesson .pair,.cmds,.try | grid-template-columns:1fr
  .lesson h3 | font-size:28px
  .bar-row | grid-template-columns:90px 1fr 84px;gap:10px;font-size:12px
  .try .go | justify-self:start
  .eds | grid-template-columns:1fr
  .badge | display:none
@media(max-width:420px)
  .stat-grid | grid-template-columns:1fr
  .hero h1 | font-size:46px;letter-spacing:-3px
@media(prefers-reduced-motion:reduce)
  * | transition:none!important;scroll-behavior:auto!important
.token.comment | color:#777b73
.token.keyword,.token.control | color:var(--violet)
.token.function | color:var(--amber)
.token.string | color:#b9d987
.token.number,.token.boolean | color:var(--rose)
.token.operator | color:#c2bcf4
.token.class-name | color:var(--mint)
// compare page
.compare | max-width:1180px;margin:0 auto;padding:110px 24px 60px
.compare h1 | font-size:clamp(30px,4.6vw,48px);margin:6px 0 10px;letter-spacing:-.02em
.compare .lede | color:var(--mute);max-width:70ch
.ex-tabs | display:flex;flex-wrap:wrap;gap:8px;margin:26px 0 16px
.ex-tabs button | background:var(--panel);color:var(--mute);border:1px solid var(--line);border-radius:999px;padding:7px 14px;font:13px var(--mono);cursor:pointer
.ex-tabs button.on | color:#11110f;background:var(--lime);border-color:var(--lime)
.ex-stats | display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:16px
.ex-stat | background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:12px 14px
.ex-stat b | display:block;font:600 22px var(--mono)
.ex-stat span | color:var(--mute);font-size:12px
.ex-stat.hi | border-color:var(--lime)
.ex-stat.hi b | color:var(--lime)
.panes | display:grid;grid-template-columns:1fr 1fr;gap:14px
.pane | min-width:0
.pane-head | display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;font:600 13px var(--mono)
.pane-head small | color:var(--dim);font-weight:400
.pane pre | max-height:70vh;min-height:320px
.build | color:var(--mute);margin-top:18px
.ex-error | margin-top:18px;color:var(--rose)
@media(max-width:900px)
  .panes | grid-template-columns:1fr
  .ex-stats | grid-template-columns:repeat(2,1fr)
// playground
.editor | position:relative;height:70vh;min-height:320px;border:1px solid var(--line);border-radius:12px;background:var(--code);overflow:hidden
.editor pre,.editor textarea
  position:absolute
  inset:0
  margin:0
  padding:16px 18px
  border:0
  border-radius:0
  font:13.5px/1.6 var(--mono)
  white-space:pre
  overflow:auto
  tab-size:2
.editor pre | pointer-events:none;overflow:hidden
.editor textarea | background:transparent;color:transparent;caret-color:var(--lime);resize:none;outline:none;z-index:1
.editor textarea::selection | background:#d4f66a55;color:transparent
.play .pane pre | height:70vh
.pane-head .copy | position:static
.lime | color:var(--lime)
.play .ex-stats .stat | padding:14px
.play .ex-stats .stat b | font-size:26px
// comparison blocks
.h3 | font-size:28px;margin:64px 0 20px
.table-wrap | overflow-x:auto;border:1px solid var(--line);border-radius:var(--r)
table.vs | border-collapse:collapse;width:100%;min-width:760px;font-size:14px
table.vs th,table.vs td | padding:12px 14px;border-bottom:1px solid var(--line);text-align:left;vertical-align:top
table.vs thead th | font:600 12px var(--mono);color:var(--mute);letter-spacing:.06em;text-transform:uppercase
table.vs tbody th | color:var(--mute);font-weight:600;white-space:nowrap
table.vs td.us,table.vs th.us | background:#d4f66a12;color:var(--ink)
table.vs tbody tr:last-child>* | border-bottom:0
.bars | display:grid;gap:14px;margin:0
.bar-row | display:grid;grid-template-columns:150px 1fr 110px;gap:14px;align-items:center;font:13px var(--mono)
.bar-row .tr | display:grid;gap:5px
.bar-row i | display:block;height:9px;border-radius:5px;background:var(--lime)
.bar-row i.c | background:#3a3c33
.bar-row b | color:var(--lime);text-align:right
.builtins | display:flex;flex-wrap:wrap;gap:8px
.builtins code | padding:5px 9px;border:1px solid var(--line)
@media(max-width:700px)
  .bar-row | grid-template-columns:90px 1fr 70px
.pane | padding:0;border:0
.editor pre,.editor code | background:transparent!important;border:0
.editor | margin:0
// editor: keep the highlight layer pixel-identical to the textarea so the caret lines up
.editor pre,.editor pre code,.editor textarea
  font:13.5px/1.6 var(--mono)!important
  letter-spacing:0!important
  word-spacing:0!important
  text-shadow:none!important
  tab-size:2!important
  white-space:pre!important
.editor pre | padding:16px 18px!important;margin:0!important
.editor pre code | padding:0!important;display:block
.editor textarea | padding:16px 18px!important;caret-color:var(--lime)!important
