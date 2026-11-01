              p An indented <code>@ct</code> block runs during expansion. <code>emit</code> writes NanoC back into the source, so you can generate functions in a loop.
              pre
                code.language-nanoc
                  | #include &lt;stdio.h&gt;
                  | @ct
                  |   f square(n) = n*n
                  |   for i 1..5
                  |     emit("@f square_"+str(i)+" int = "+str(square(i))+"\n")
                  | @f main int
                  |   printf("%d\n",square_4())
                  |   0
            article#g7.lesson
              div.n 07 · BUILD TIME
              h3 Files and commands with <code>@bt</code>
              p <code>@bt</code> is the only phase that may write files or run host commands. It runs before expansion. Use <code>--check</code> to validate a file without side effects; it rejects these calls.
              pre
                code.language-nanoc
                  | @bt
                  |   mkdir("build")
                  |   write("build/nanoc-generated.h","#define GENERATED 42\n")
                  |   emit(read("build/nanoc-generated.h"))
                  | @f main int = GENERATED!=42
            article#g8.lesson
              div.n 08 · ASSEMBLY
              h3 Inline assembly
              p An indented <code>@asm</code> block forwards instructions to the GCC or Clang inline assembler, with explicit <code>out</code>, <code>in</code>, <code>clobber</code> and <code>labels</code> sections. Assembly is the one target-specific part of NanoC.
              p Full syntax and examples: <code>nanoc --describe asm</code> or the <a class="textlink" href="https://github.com/mkalmousli/NanoC/blob/main/docs/assembly.md">assembly card ↗</a>.
            article#g9.lesson
              div.n 09 · INTEROP
              h3 C++17 and C headers
              p Headers work unchanged. Use <code>--lang c++</code> to emit C++17 and get range loops over standard containers.
              pre
                code.language-nanoc
                  | #include &lt;vector&gt;
                  | #include &lt;iostream&gt;
                  | @f main int
                  |   values:=std::vector&lt;int&gt;(3,2)
                  |   sum:=0
                  |   for value values
                  |     sum+=value
                  |   std::cout&lt;&lt;sum&lt;&lt;'\n'
                  |   0
              p.note [style=margin-top:16px] Build: <code>nanoc app.nc --lang c++ -o app.cc &amp;&amp; c++ -std=c++17 app.cc -o app</code>
            article#g10.lesson
              div.n 10 · REFERENCE
              h3 Cheat sheet
              table.cards
                tr
                  th Syntax
                  th Meaning
                tr
                  td <code>@f name(args) T</code>
                  td Function; bare return type; <code>= expr</code> for one line
                tr
                  td <code>x:=expr</code>
                  td Infer a local's type from a scalar literal
                tr
                  td <code>for i a..b</code>
                  td Range loop, exclusive upper bound
                tr
                  td <code>if / elif / else</code>
                  td Branches; as a final expression they return a value
                tr
                  td <code>@m name($x) body</code>
                  td Macro template; <code>$x</code> captures, <code>$fresh(t)</code>
                tr
                  td <code>@ct</code>
                  td Compile-time program; <code>emit</code> writes source
                tr
                  td <code>@bt</code>
                  td Build-time program; files and commands
                tr
                  td <code>@asm</code>
                  td Inline assembly block
              p.note [style=margin-top:20px] CLI: <code>nanoc f.nc -o f.c</code> · <code>--check --diagnostics json</code> · <code>--lang c++</code> · <code>--describe syntax|builtins|asm</code>
      section#try.wrap
        p.kicker Try it
        h2 Run the compiler <em>right here.</em>
        p.sub [style=margin-bottom:28px] NanoC is compiled to WebAssembly ({{wasm-size}}). Edit a program and watch the C appear: no install, no server, works offline.
        div.try [style=margin-bottom:56px]
          div
            p Macros, generics, compile-time code and more, all transpiled live in your tab.
          a.btn.solid.go [href=play.html] Open the playground →
        p.kicker Or with your AI
        h2 One prompt. <em>Any model.</em>
        p.sub [style=margin-bottom:36px] Paste this into your assistant. It links the repo, so the model can read the language card and compiler source.
        div.try
          div
            p Replace the bracketed goal, then send it.
            pre#prompt-text
              code
          button#prompt-copy.btn.solid.go [type=button] Copy prompt
      section#install.wrap
        p.kicker Install in one line
        h2 Works on any <em>POSIX host.</em>
        div.cmds [style=margin-top:40px]
          div
            h4 Install
            pre
              code.language-bash git clone --depth 1 https://github.com/mkalmousli/NanoC &amp;&amp; cd NanoC &amp;&amp; cc -std=c11 -O2 build.c -o builder &amp;&amp; ./builder install
          div
            h4 Update
            pre
              code.language-bash nanoc update
            p.method [style=margin-top:10px] Fetches the latest source, rebuilds and reinstalls.
          div
            h4 Uninstall
            pre
              code.language-bash nanoc uninstall
            p.method [style=margin-top:10px] Asks first. <code>nanoc uninstall --yes</code> skips the prompt.
          div
            h4 Editors
            pre
              code.language-bash
                | nanoc editor list
                | nanoc editor install vim
        p.method Needs git and a C11 compiler (<code>cc</code>, <code>gcc</code> or <code>clang</code>). Installs to <code>~/.local</code> by default; <code>--prefix DIR</code> changes it, <code>--no-editors</code> skips editor setup. Installs only the files it creates.
      section#editors.wrap
        p.kicker Editor support
        h2 Highlighted <em>where you write.</em>
        p.sub The installer sets up every editor it detects. Add or remove any of them with the compiler.
        div.eds
          div.ed <b>VS Code</b><span>VS Code, VSCodium, Cursor · snippets, icons</span><code>nanoc editor install vscode</code>
          div.ed <b>Vim</b><span>syntax + filetype detection</span><code>nanoc editor install vim</code>
          div.ed <b>Neovim</b><span>syntax + filetype detection</span><code>nanoc editor install neovim</code>
          div.ed <b>Emacs</b><span>nanoc-mode, auto-mode for .nc</span><code>nanoc editor install emacs</code>
          div.ed <b>micro</b><span>terminal editor, yaml syntax</span><code>nanoc editor install micro</code>
          div.ed <b>GNU nano</b><span>nanorc colour rules</span><code>nanoc editor install nano</code>
          div.ed <b>Sublime Text</b><span>Sublime Text 4 syntax</span><code>nanoc editor install sublime</code>
      section#source.wrap
        p.kicker Read the source
        h2 The compiler, <em>in NanoC.</em>
        p.sub Every NanoC file of the compiler beside the C it generates, compiled live in your browser. Press <kbd>/</kbd> to search.
        div.explorer
          div.rail
            input#search [type=search placeholder="Filter files…" aria-label="Filter files"]
            div#file-count.file-count
            div#file-list.file-list
          div.viewer
            div.viewer-head <span id="selected-name">Loading…</span><span id="ratio" class="ratio"></span><a id="raw-link" href="https://github.com/mkalmousli/NanoC" target="_blank" rel="noopener">Open on GitHub ↗</a>
            div.pair
              div.half
                div.half-head <b>NanoC</b><span id="nc-stat"></span>
                div#nc-view.code-view
              div.half
                div.half-head <b>Generated C</b><span id="c-stat"></span>
                div#c-view.code-view
    | {{footer}}
