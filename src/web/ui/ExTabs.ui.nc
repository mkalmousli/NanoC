html
  div#$tabs.~ex-tabs [role=tablist]
  div#$stats.~ex-stats
css
  .~ex-tabs | display:flex;flex-wrap:wrap;gap:8px;margin:26px 0 16px
  .~ex-tabs button | background:var(--panel);color:var(--mute);border:1px solid var(--line);border-radius:999px;padding:7px 14px;font:13px var(--mono);cursor:pointer
  .~ex-tabs button.~on | color:#11110f;background:var(--lime);border-color:var(--lime)
  .~ex-stats | display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:16px
  .~ex-stat | background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:12px 14px
  .~ex-stat b | display:block;font:600 22px var(--mono)
  .~ex-stat span | color:var(--mute);font-size:12px
  .~ex-stat.~hi | border-color:var(--lime)
  .~ex-stat.~hi b | color:var(--lime)
  @media(max-width:900px)
    .~ex-stats | grid-template-columns:repeat(2,1fr)
