main
  css
    max-width:1180px
    margin:0 auto
    padding:110px 24px 60px
    & h1 | font-size:clamp(30px,4.6vw,48px);margin:6px 0 10px;letter-spacing:-.02em
    & > p:not(:first-child) | color:var(--mute);max-width:70ch
  Kicker $eyebrow
  h1 $title
  p $text
  Slot
