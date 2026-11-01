Section [id=editors kicker="Editor support" title="Highlighted <em>where you write.</em>"]
  Sub The installer sets up every editor it detects. Add or remove any of them with the compiler.
  div
    css
      display:grid
      grid-template-columns:repeat(4,1fr)
      gap:12px
      margin-top:36px
      & > div | background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:16px;min-width:0
      & b | display:block
      & span | color:var(--mute);font-size:13px
      & code | display:block;margin-top:10px;font-size:12px;color:var(--lime);background:none;padding:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis
      @media(max-width:1000px)
        grid-template-columns:1fr 1fr
      @media(max-width:700px)
        grid-template-columns:1fr
    div <b>VS Code</b><span>VS Code, VSCodium, Cursor · snippets, icons</span><code>nanoc editor install vscode</code>
    div <b>Vim</b><span>syntax + filetype detection</span><code>nanoc editor install vim</code>
    div <b>Neovim</b><span>syntax + filetype detection</span><code>nanoc editor install neovim</code>
    div <b>Emacs</b><span>nanoc-mode, auto-mode for .nc</span><code>nanoc editor install emacs</code>
    div <b>micro</b><span>terminal editor, yaml syntax</span><code>nanoc editor install micro</code>
    div <b>GNU nano</b><span>nanorc colour rules</span><code>nanoc editor install nano</code>
    div <b>Sublime Text</b><span>Sublime Text 4 syntax</span><code>nanoc editor install sublime</code>
