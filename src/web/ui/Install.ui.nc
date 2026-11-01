Section [id=install kicker="Install in one line" title="Works on any <em>POSIX host.</em>"]
  div
    css
      display:grid
      grid-template-columns:1fr 1fr
      gap:14px
      margin-top:40px
      & > div | background:var(--panel);border:1px solid var(--line);border-radius:var(--r);padding:20px;min-width:0
      & h4 | margin:0 0 12px;font-size:15px
      & pre | font-size:12.5px;white-space:pre-wrap;word-break:break-all
      & p | margin:10px 0 0
      @media(max-width:700px)
        grid-template-columns:1fr
    div
      h4 Install
      Code [lang=bash]
        | git clone --depth 1 https://github.com/mkalmousli/NanoC &amp;&amp; cd NanoC &amp;&amp; cc -std=c11 -O2 build.c -o builder &amp;&amp; ./builder install
    div
      h4 Update
      Code [lang=bash]
        | nanoc update
      Fine Fetches the latest source, rebuilds and reinstalls.
    div
      h4 Uninstall
      Code [lang=bash]
        | nanoc uninstall
      Fine Asks first. <code>nanoc uninstall --yes</code> skips the prompt.
    div
      h4 Editors
      Code [lang=bash]
        | nanoc editor list
        | nanoc editor install vim
  Fine Needs git and a C11 compiler (<code>cc</code>, <code>gcc</code> or <code>clang</code>). Installs to <code>~/.local</code> by default; <code>--prefix DIR</code> changes it, <code>--no-editors</code> skips editor setup. Installs only the files it creates.
