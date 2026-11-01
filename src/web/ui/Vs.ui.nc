html
  Section [id=vs kicker="How it compares" title="Not a new world.<br><em>A better door into C.</em>"]
    p.~sub The table is hand-written; the numbers below it are measured by compiling every example in <code>examples/</code> with this build of NanoC.
    div [style=margin-top:44px]
      LangTable
    h3.~h3 Measured per example
    Html [src=build/blocks/ex-table.html]
    p.~method Method: non-blank lines and bytes of each example against the C the compiler emits. Generated at site build time ($built). <a href="compare.html">Read them side by side →</a>
css
  .~h3 | font-size:28px;margin:64px 0 20px
  .~table-wrap | overflow-x:auto;border:1px solid var(--line);border-radius:var(--r)
  table.~vs | border-collapse:collapse;width:100%;min-width:760px;font-size:14px
  table.~vs th,table.~vs td | padding:12px 14px;border-bottom:1px solid var(--line);text-align:left;vertical-align:top
  table.~vs thead th | font:600 12px var(--mono);color:var(--mute);letter-spacing:.06em;text-transform:uppercase
  table.~vs tbody th | color:var(--mute);font-weight:600;white-space:nowrap
  table.~vs td.~us,table.~vs th.~us | background:#d4f66a12;color:var(--ink)
  table.~vs tbody tr:last-child>* | border-bottom:0
  .~bar-row | display:grid;grid-template-columns:150px 1fr 110px;gap:14px;align-items:center;font:13px var(--mono)
  .~bar-row .~tr | display:grid;gap:5px
  .~bar-row i | display:block;height:9px;border-radius:5px;background:var(--lime)
  .~bar-row i.~c | background:#3a3c33
  .~bar-row b | color:var(--lime);text-align:right
  .~builtins | display:flex;flex-wrap:wrap;gap:8px
  .~builtins code | padding:5px 9px;border:1px solid var(--line)
