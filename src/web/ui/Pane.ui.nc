section
  css
    min-width:0
    & header | display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;font:600 13px var(--mono)
    & small | color:var(--dim);font-weight:400
    & header span:last-child | display:flex;gap:6px
  header
    span $title <small>($note)</small>
    span
      Slot head
  Slot body
