article#$id
  css
    padding:0 0 64px
    margin-bottom:64px
    border-bottom:1px dashed var(--line)
    &:last-child | border:0
    & p | color:var(--mute);margin:0 0 18px;max-width:680px
    & ul | color:var(--mute);margin:14px 0 0;padding-left:20px
    & li | margin:6px 0
    & h3 | font-size:34px;margin:10px 0 14px
    & pre | max-height:420px
    @media(max-width:700px)
      & h3 | font-size:28px
  div $n
    css | font:600 12px var(--mono);color:var(--violet);letter-spacing:.1em
  h3 $title
  Slot
