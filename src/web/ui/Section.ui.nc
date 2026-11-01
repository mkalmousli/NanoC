html
  section#$id.~wrap
    p.~kicker $kicker
    h2 $title
    Slot
css
  .~kicker | font:600 12px/1 var(--mono);letter-spacing:.14em;text-transform:uppercase;color:var(--lime);margin:0 0 16px;display:flex;gap:10px;align-items:center
  .~kicker:before | content:"";width:22px;height:2px;background:var(--lime)
