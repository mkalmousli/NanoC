html
  article#$id.~lesson
    div.~n $n
    h3 $title
    Slot
css
  @media(max-width:700px)
    .~lesson .~pair,.~cmds,.~try | grid-template-columns:1fr
    .~lesson h3 | font-size:28px
