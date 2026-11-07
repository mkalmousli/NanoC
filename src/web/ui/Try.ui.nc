Section [id=try kicker="Try it" title="Run the compiler <em>right here.</em>"]
  Sub NanoC is compiled to WebAssembly ($wasmsize). Edit a program and watch the C appear: no install, no server, works offline.
    css | margin-bottom:28px
  Panel
    css | margin-bottom:56px
    p Macros, generics, compile-time code and more, all transpiled live in your tab.
    Solid [href=play.html] Open the playground →
  Kicker Or with your AI
  h2 One prompt. <em>Any model.</em>
  Sub Paste this into your assistant. It links the repo, so the model can read the language card and compiler source.
    css | margin-bottom:36px
  Panel
    div
      p Replace the bracketed goal, then send it.
      pre [as=prompt]
        code
    Solid [href=#try as=copy] Copy prompt
  js
    const PROMPT = 'Project: ' + REPO + ' (README.md and docs/language.md describe the language; ' +
      'the compiler is in src/**/*.nc).\n\n' +
      'Write a small NanoC program that [goal]. Use f name(args) -> CType functions, explicit return, C expression operators and ' +
      'indented blocks, no braces or semicolons. Show the file, the nanoc command that emits C, ' +
      'and the cc command that builds it.'
    A.prompt.textContent = PROMPT
    A.copy.onclick = e => { e.preventDefault(); copyText(PROMPT, A.copy) }
