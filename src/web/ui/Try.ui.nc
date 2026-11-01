html
  Section [id=try kicker="Try it" title="Run the compiler <em>right here.</em>"]
    p.~sub [style=margin-bottom:28px] NanoC is compiled to WebAssembly ($wasmsize). Edit a program and watch the C appear: no install, no server, works offline.
    div.~try [style=margin-bottom:56px]
      div
        p Macros, generics, compile-time code and more, all transpiled live in your tab.
      a.~btn.~solid.~go [href=play.html] Open the playground →
    p.~kicker Or with your AI
    h2 One prompt. <em>Any model.</em>
    p.~sub [style=margin-bottom:36px] Paste this into your assistant. It links the repo, so the model can read the language card and compiler source.
    div.~try
      div
        p Replace the bracketed goal, then send it.
        pre#~prompt-text
          code
      button#~prompt-copy.~btn.~solid.~go [type=button] Copy prompt
css
  .~try | background:var(--panel);border:1px solid var(--line);border-radius:18px;padding:30px;display:grid;grid-template-columns:1fr auto;gap:22px;align-items:start
  .~try p | margin:0;color:var(--mute);font-size:15px
  .~try pre | margin-top:18px;font-size:13.5px;white-space:pre-wrap;max-height:260px
  .~try .~go | align-self:center
  @media(max-width:700px)
    .~try .~go | justify-self:start
js
  // ---- one prompt for any AI assistant ----
  const PROMPT = 'Project: ' + REPO + ' (README.md and docs/language.md describe the language; ' +
  'the compiler is in src/**/*.nc).\n\n' +
  'Write a small NanoC program that [goal]. Use @f functions with bare return types and ' +
  'indented blocks, no braces or semicolons. Show the file, the nanoc command that emits C, ' +
  'and the cc command that builds it.'
  $('#~prompt-text').textContent = PROMPT
  $('#~prompt-copy').onclick = e => copyText(PROMPT, e.currentTarget)
