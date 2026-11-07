div
  css | overflow-x:auto;border:1px solid var(--line);border-radius:var(--r);margin-top:8px
  table
    css
      width:100%
      border-collapse:collapse
      font-size:14px
      & :is(th,td) | padding:11px 12px;border-bottom:1px solid var(--line);text-align:left;vertical-align:top
      & th | color:var(--dim);font:600 11px var(--mono);letter-spacing:.1em;text-transform:uppercase
      & tr:last-child>* | border-bottom:0
      & td:first-child code | color:var(--lime);background:none
    thead
      tr
        Slot head
    tbody
      Slot body
