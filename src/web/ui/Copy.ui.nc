html
  button.~copy#$id [type=button] Copy
css
  .~copy
    position:absolute
    top:10px
    right:10px
    background:#22231d
    color:var(--mute)
    border:1px solid var(--line)
    border-radius:8px
    font:600 11px var(--mono)
    padding:6px 10px
    cursor:pointer
  .~copy:hover | color:var(--ink);border-color:var(--lime)
