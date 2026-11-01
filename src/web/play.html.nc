| <!doctype html>
html [lang=en]
  head
    meta [charset=utf-8]
    meta [name=viewport content=width=device-width,initial-scale=1]
    title NanoC playground: transpile in your browser
    meta [name=description content="Edit NanoC and watch the real compiler, running as WebAssembly, produce C as you type."]
    link [rel=icon href=favicon.svg type=image/svg+xml]
    link [rel=stylesheet href=style.css]
    link [rel=stylesheet href=https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism-tomorrow.min.css]
  body
    | {{nav}}
    main.compare.play
      p.eyebrow Playground
      h1 The real compiler, <em>in your tab</em>
      p.lede This is not a mock-up: the NanoC compiler is compiled to WebAssembly ({{wasm-size}}) and runs here, offline, as you type. Pick an example or write your own; the C appears on the right.
      div#tabs.ex-tabs [role=tablist]
      div#stats.ex-stats
      div.panes
        section.pane
          div.pane-head <span>NanoC <small>(edit me)</small></span><span><button class="copy" id="share" type="button">Share link</button> <button class="copy" id="copy-nc" type="button">Copy</button></span>
          div.editor
            pre [aria-hidden=true]
              code#hl.language-nanoc
            textarea#src [spellcheck=false autocomplete=off aria-label="NanoC source"] 
        section.pane
          div.pane-head <span>C <small>(live output)</small></span><button class="copy" id="copy-c" type="button">Copy</button>
          pre
            code#out.language-c
      div#err.ex-error [hidden]
      p.build Take it home: <code>nanoc file.nc -o out.c &amp;&amp; cc out.c -o prog</code>. Build-time (<code>@bt</code>) file and process access is disabled in the browser.
    | {{footer}} {{prism}}
    script [src=play.js] 
