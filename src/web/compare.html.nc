| <!doctype html>
html [lang=en]
  head
    meta [charset=utf-8]
    meta [name=viewport content=width=device-width,initial-scale=1]
    title NanoC vs C: side by side
    meta [name=description content="The same program in NanoC and the C the compiler generates from it, with line and byte counts."]
    link [rel=icon href=favicon.svg type=image/svg+xml]
    link [rel=stylesheet href=style.css]
    link [rel=stylesheet href=https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism-tomorrow.min.css]
  body
    | {{nav}}
    main.compare
      p.eyebrow Compare
      h1 Same program, two languages
      p.lede Each example is compiled by the real NanoC compiler on every site build. Left is the NanoC you write; right is the C it generates. Nothing here is hand-edited.
      div#tabs.ex-tabs [role=tablist]
      div#ex-stats.ex-stats
      div.panes
        section.pane
          div.pane-head <span>NanoC <small>(what you write)</small></span><button class="copy" id="copy-nc" type="button">Copy</button>
          pre
            code#nc-code.language-nanoc
        section.pane
          div.pane-head <span>C <small>(what cc builds)</small></span><button class="copy" id="copy-c" type="button">Copy</button>
          pre
            code#c-code.language-c
      p.build <a href="play.html">Edit any of these live in the playground →</a> Or build one yourself: <code>nanoc examples/hello.nc -o out.c &amp;&amp; cc out.c -o hello</code>
      div#ex-error.ex-error [hidden]
    | {{footer}} {{prism}}
    script [src=compare.js] 
