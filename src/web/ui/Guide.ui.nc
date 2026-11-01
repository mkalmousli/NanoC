html
  Section [id=guide kicker="Language guide" title="Learn it in <em>ten minutes.</em>"]
    p.~sub Every example compiles and runs with the current compiler. Unmarked C stays valid, so you can adopt NanoC one function at a time.
    div.~guide [style=margin-top:56px]
      nav.~toc [aria-label="Guide sections"] <a href="#g1"><span>01</span>Hello</a> <a href="#g2"><span>02</span>Functions</a> <a href="#g3"><span>03</span>Values</a> <a href="#g4"><span>04</span>Locals &amp; loops</a> <a href="#g5"><span>05</span>Macros</a> <a href="#g6"><span>06</span>Compile time</a> <a href="#g7"><span>07</span>Build time</a> <a href="#g8"><span>08</span>Assembly</a> <a href="#g9"><span>09</span>C++ &amp; C interop</a> <a href="#g10"><span>10</span>Cheat sheet</a>
      div
        Lesson [id=g1 n="01 · START" title="Hello, NanoC"]
          p Save this as <code>hello.nc</code>. Lines starting with <code>#</code> pass through unchanged, so any C header works.
          Code [lang=nanoc]
            | #include &lt;stdio.h&gt;
            | @f main int
            |   puts("Hello from NanoC!")
            |   0
          p.~note [style=margin-top:16px] Build: <code>nanoc hello.nc -o hello.c &amp;&amp; cc hello.c -o hello &amp;&amp; ./hello</code>
        Lesson [id=g2 n="02 · FUNCTIONS" title="Bare return types"]
          p The return type goes after the parameters, with no arrow. Omit it for <code>void</code>. Group parameters that share a type with a comma. A one-line body can be an <code>=</code> expression.
          Code [lang=nanoc]
            | #include &lt;stdio.h&gt;
            | @f add(int a,b) int = a+b
            | @f greet(char *name)
            |   printf("hi %s\n",name)
            | @f main int
            |   greet("NanoC")
            |   printf("%d\n",add(2,3))
            |   0
          ul
            li An indented body returns its final expression. No <code>return</code> needed.
            li No braces, no semicolons, no parentheses around conditions.
        Lesson [id=g3 n="03 · VALUES" title="Blocks produce values"]
          p An <code>if</code>/<code>elif</code>/<code>else</code> that covers every branch returns the value of whichever branch runs.
          Code [lang=nanoc]
            | @f sign(int x) int
            |   if x&lt;0
            |     -1
            |   elif x&gt;0
            |     1
            |   else
            |     0
            | @f main int = sign(-9)!=-1
        Lesson [id=g4 n="04 · LOCALS &amp; LOOPS" title="Inference and ranges"]
          p <code>:=</code> infers the type of a scalar literal. <code>for i 1..6</code> counts from 1 up to but not including 6.
          Code [lang=nanoc]
            | #include &lt;stdio.h&gt;
            | @f main int
            |   total:=0
            |   for i 1..6
            |     total+=i
            |   printf("%d\n",total)
            |   0
          ul
            li Spell the type when you need it: <code>int x=call()</code>.
            li Typed range: <code>for i:size_t 0..n</code>. Bounds are evaluated once.
            li Plain C loops still work: <code>for int i=0;i&lt;n;i++</code>.
            li C++ iterates containers: <code>for value values</code>.
        Lesson [id=g5 n="05 · MACROS" title="Token templates"]
          p <code>@m</code> defines a template. <code>$x</code> captures a token. A macro with <code>=</code> and no parameters is a named constant.
          Code [lang=nanoc]
            | #include &lt;stdio.h&gt;
            | @m twice($x)
            |   (($x)*2)
            | @m answer = 42
            | @m maxfn($name,$type)
            |   @f $name($type a,b) $type = a&gt;b?a:b
            | @maxfn(max_int,int)
            | @f main int
            |   printf("%d %d\n",@twice(@answer),max_int(2,3))
            |   0
          p.~note [style=margin-top:16px] Use <code>$fresh(tmp)</code> for generated names that must not collide. <code>$$</code> writes a literal <code>$</code>.
        Lesson [id=g6 n="06 · COMPILE TIME" title="Generate code with <code>@ct</code>"]
          p An indented <code>@ct</code> block runs during expansion. <code>emit</code> writes NanoC back into the source, so you can generate functions in a loop.
          Code [lang=nanoc]
            | #include &lt;stdio.h&gt;
            | @ct
            |   f square(n) = n*n
            |   for i 1..5
            |     emit("@f square_"+str(i)+" int = "+str(square(i))+"\n")
            | @f main int
            |   printf("%d\n",square_4())
            |   0
        Lesson [id=g7 n="07 · BUILD TIME" title="Files and commands with <code>@bt</code>"]
          p <code>@bt</code> is the only phase that may write files or run host commands. It runs before expansion. Use <code>--check</code> to validate a file without side effects; it rejects these calls.
          Code [lang=nanoc]
            | @bt
            |   mkdir("build")
            |   write("build/nanoc-generated.h","#define GENERATED 42\n")
            |   emit(read("build/nanoc-generated.h"))
            | @f main int = GENERATED!=42
        Lesson [id=g8 n="08 · ASSEMBLY" title="Inline assembly"]
          p An indented <code>@asm</code> block forwards instructions to the GCC or Clang inline assembler, with explicit <code>out</code>, <code>in</code>, <code>clobber</code> and <code>labels</code> sections. Assembly is the one target-specific part of NanoC.
          p Full syntax and examples: <code>nanoc --describe asm</code> or the <a class="~textlink" href="https://github.com/mkalmousli/NanoC/blob/main/docs/assembly.md">assembly card ↗</a>.
        Lesson [id=g9 n="09 · INTEROP" title="C++17 and C headers"]
          p Headers work unchanged. Use <code>--lang c++</code> to emit C++17 and get range loops over standard containers.
          Code [lang=nanoc]
            | #include &lt;vector&gt;
            | #include &lt;iostream&gt;
            | @f main int
            |   values:=std::vector&lt;int&gt;(3,2)
            |   sum:=0
            |   for value values
            |     sum+=value
            |   std::cout&lt;&lt;sum&lt;&lt;'\n'
            |   0
          p.~note [style=margin-top:16px] Build: <code>nanoc app.nc --lang c++ -o app.cc &amp;&amp; c++ -std=c++17 app.cc -o app</code>
        Lesson [id=g10 n="10 · REFERENCE" title="Cheat sheet"]
          table.~cards
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
          p.~note [style=margin-top:20px] CLI: <code>nanoc f.nc -o f.c</code> · <code>--check --diagnostics json</code> · <code>--lang c++</code> · <code>--describe syntax|builtins|asm</code>
css
  .~guide | display:grid;grid-template-columns:220px 1fr;gap:56px;align-items:start
  .~toc | position:sticky;top:96px;display:flex;flex-direction:column;gap:2px;max-height:calc(100vh - 120px);overflow:auto;padding-right:6px
  .~toc a | text-decoration:none;color:var(--mute);font-size:14px;padding:7px 10px;border-radius:8px;border-left:2px solid transparent
  .~toc a:hover | color:var(--ink);background:#181913
  .~toc a.~on | color:var(--lime);border-left-color:var(--lime);background:#181913
  .~toc a span | font:600 11px var(--mono);color:var(--dim);margin-right:8px
  .~lesson | padding:0 0 64px;margin-bottom:64px;border-bottom:1px dashed var(--line)
  .~lesson:last-child | border:0
  .~lesson .~n | font:600 12px var(--mono);color:var(--violet);letter-spacing:.1em
  .~lesson h3 | font-size:34px;margin:10px 0 14px
  .~lesson p | color:var(--mute);margin:0 0 18px;max-width:680px
  .~lesson ul | color:var(--mute);margin:14px 0 0;padding-left:20px
  .~lesson li | margin:6px 0
  .~lesson .~pair | display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-top:8px
  .~lesson .~pair>div | min-width:0
  .~lesson .~label | font:600 11px var(--mono);color:var(--dim);letter-spacing:.1em;text-transform:uppercase;margin:0 0 8px
  .~note | font-size:14px;color:var(--mute);border-left:2px solid var(--violet);padding:4px 0 4px 14px;margin:16px 0 0
  table.~cards | width:100%;border-collapse:collapse;font-size:14px;margin-top:8px;display:block;overflow-x:auto
  table.~cards td,table.~cards th | text-align:left;padding:11px 12px;border-bottom:1px solid var(--line);vertical-align:top
  table.~cards th | color:var(--dim);font:600 11px var(--mono);letter-spacing:.1em;text-transform:uppercase
  table.~cards td:first-child code | color:var(--lime);background:none
  @media(max-width:1000px)
    .~guide | grid-template-columns:1fr
    .~toc
      position:static
      flex-direction:row
      flex-wrap:nowrap
      overflow-x:auto
      max-height:none
      padding:0 0 10px
      margin:0 -24px
      padding-left:24px
      padding-right:24px
      border-bottom:1px solid var(--line)
    .~toc a | white-space:nowrap;border-left:0;border:1px solid var(--line);border-radius:999px;padding:7px 14px
    .~toc a.~on | border-color:var(--lime)
js
  // ---- guide: highlight the current lesson in the table of contents ----
  const links = [...document.querySelectorAll('.~toc a')]
  const io = new IntersectionObserver(entries =>
    entries.forEach(e =>
      if (!e.isIntersecting) return
      links.forEach(a => a.classList.toggle('~on', a.getAttribute('href') === '#' + e.target.id))
    )
  , { rootMargin: '-35% 0px -55% 0px' })
  document.querySelectorAll('.~lesson').forEach(el => io.observe(el))
