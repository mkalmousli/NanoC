div
  css
    & [role=tablist] | display:flex;flex-wrap:wrap;gap:8px;margin:26px 0 16px
    & [role=tablist] button | background:var(--panel);color:var(--mute);border:1px solid var(--line);border-radius:999px;padding:7px 14px;font:13px var(--mono);cursor:pointer
    & [role=tablist] button.on | color:#11110f;background:var(--lime);border-color:var(--lime)
    & [data-a=stats] | display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:16px
    & .stat | background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:12px 14px
    & .stat b | display:block;font:600 22px var(--mono)
    & .stat span | color:var(--mute);font-size:12px
    & .stat.hi | border-color:var(--lime)
    & .stat.hi b | color:var(--lime)
    @media(max-width:900px)
      & [data-a=stats] | grid-template-columns:repeat(2,1fr)
  div [as=tabs role=tablist]
  div [as=stats]
