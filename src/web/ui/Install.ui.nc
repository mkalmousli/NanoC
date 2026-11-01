html
  Section [id=install kicker="Install in one line" title="Works on any <em>POSIX host.</em>"]
    div.~cmds [style=margin-top:40px]
      div
        h4 Install
        pre
          code.language-bash git clone --depth 1 https://github.com/mkalmousli/NanoC &amp;&amp; cd NanoC &amp;&amp; cc -std=c11 -O2 build.c -o builder &amp;&amp; ./builder install
      div
        h4 Update
        pre
          code.language-bash nanoc update
        p.~method [style=margin-top:10px] Fetches the latest source, rebuilds and reinstalls.
      div
        h4 Uninstall
        pre
          code.language-bash nanoc uninstall
        p.~method [style=margin-top:10px] Asks first. <code>nanoc uninstall --yes</code> skips the prompt.
      div
        h4 Editors
        Code [lang=bash]
          | nanoc editor list
          | nanoc editor install vim
    p.~method Needs git and a C11 compiler (<code>cc</code>, <code>gcc</code> or <code>clang</code>). Installs to <code>~/.local</code> by default; <code>--prefix DIR</code> changes it, <code>--no-editors</code> skips editor setup. Installs only the files it creates.
css
  .~cmds | display:grid;grid-template-columns:1fr 1fr;gap:14px
  .~cmds>div | background:var(--panel);border:1px solid var(--line);border-radius:var(--r);padding:20px;min-width:0
  .~cmds h4 | margin:0 0 12px;font-size:15px
  .~cmds pre | font-size:12.5px;white-space:pre-wrap;word-break:break-all
