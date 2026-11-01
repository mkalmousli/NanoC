html
  Section [id=editors kicker="Editor support" title="Highlighted <em>where you write.</em>"]
    p.~sub The installer sets up every editor it detects. Add or remove any of them with the compiler.
    div.~eds
      Ed [id=vscode name="VS Code" note="VS Code, VSCodium, Cursor · snippets, icons"]
      Ed [id=vim name="Vim" note="syntax + filetype detection"]
      Ed [id=neovim name="Neovim" note="syntax + filetype detection"]
      Ed [id=emacs name="Emacs" note="nanoc-mode, auto-mode for .nc"]
      Ed [id=micro name="micro" note="terminal editor, yaml syntax"]
      Ed [id=nano name="GNU nano" note="nanorc colour rules"]
      Ed [id=sublime name="Sublime Text" note="Sublime Text 4 syntax"]
css
  .~eds | display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-top:36px
  .~ed | background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:16px;min-width:0
  .~ed b | display:block
  .~ed span | color:var(--mute);font-size:13px
  .~ed code | display:block;margin-top:10px;font-size:12px;color:var(--lime);background:none;padding:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis
  @media(max-width:1000px)
    .~eds | grid-template-columns:1fr 1fr
  @media(max-width:700px)
    .~eds | grid-template-columns:1fr
