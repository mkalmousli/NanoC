div [as=$as]
  css
    display:grid
    gap:14px
    & .bar-row | display:grid;grid-template-columns:150px 1fr 110px;gap:14px;align-items:center;font:13px var(--mono)
    & .bar-row > span | color:var(--mute)
    & .tr | position:relative;display:grid;gap:5px
    & .tr i | display:block;height:9px;border-radius:5px;background:var(--lime);transition:width 1.2s cubic-bezier(.2,.7,.2,1)
    & .tr i.c | background:#3a3c33
    & .bar-row b | color:var(--mute);text-align:right;font-weight:400
    & .legend | display:flex;gap:18px;font-size:13px;color:var(--mute);flex-wrap:wrap
    & .legend i | display:inline-block;width:12px;height:12px;border-radius:3px;margin-right:6px;vertical-align:-1px
    @media(max-width:700px)
      & .bar-row | grid-template-columns:90px 1fr 70px;gap:10px;font-size:12px
  Slot
