div
  css | background:var(--panel);border:1px solid var(--line);border-radius:18px;padding:30px;display:grid;grid-template-columns:1fr auto;gap:22px;align-items:start
  css
    & p | margin:0;color:var(--mute);font-size:15px
    & pre | margin-top:18px;font-size:13.5px;white-space:pre-wrap;max-height:260px
    & > :last-child | align-self:center
    @media(max-width:700px)
      & > :last-child | justify-self:start
  Slot
