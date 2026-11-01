div
  css
    display:grid
    grid-template-columns:1fr 1fr
    gap:14px
    margin-top:8px
    & > div | min-width:0
    & b | display:block;font:600 11px var(--mono);color:var(--dim);letter-spacing:.1em;text-transform:uppercase;margin:0 0 8px
    @media(max-width:700px)
      grid-template-columns:1fr
  div
    b NanoC
    Code [lang=nanoc]
      Slot nc
  div
    b Generated C
    Code [lang=c]
      Slot c
