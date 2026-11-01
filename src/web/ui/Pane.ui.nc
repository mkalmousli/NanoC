html
  section.~pane
    div.~pane-head
      span $title <small>($note)</small>
      span
        Slot head
    Slot body
css
  .~pane | min-width:0
  .~pane-head | display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;font:600 13px var(--mono)
  .~pane-head small | color:var(--dim);font-weight:400
  .~pane pre | max-height:70vh;min-height:320px
  .~pane-head .~copy | position:static
  .~pane | padding:0;border:0
