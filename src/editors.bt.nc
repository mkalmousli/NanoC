// Every editor integration, generated from ONE token table into build/editors/.
// Row: class ~ regex ~ vim group ~ nano color ~ textmate scope ~ micro group ~ emacs face
// Run: build/nanoc src/editors.bt.nc -o build/editors.c
@bt
  eval(read("src/dsl/gen.bt.nc"))
  DIR:="f|fn|m|macro|ct|bt|asm"
  CTL:="if|elif|else|unless|until|loop|for|while|break|continue|ret|return|goto"
  BLT:="emit|quote|ident|fresh|rewrite|again|source|eval|assert|fail|inc"
  TYP:="void|bool|char|short|int|long|float|double|signed|unsigned|auto|const|volatile|static|struct|union|enum|typedef|size_t"
  table:=["dir~@(DIR)\\b~PreProc~brightmagenta~keyword.control.directive~preproc~font-lock-keyword-face",
    "mac~@[A-Za-z_]\\w*~Function~brightcyan~entity.name.function.macro~special~font-lock-function-name-face",
    "cap~\\$\\$|\\$[A-Za-z_]\\w*(:[A-Za-z_]+|\\.\\.\\.)?~Special~brightyellow~variable.parameter~special~font-lock-variable-name-face",
    "ctl~\\b(CTL)\\b~Conditional~magenta~keyword.control~statement~font-lock-keyword-face",
    "blt~\\b(BLT)\\b~Function~blue~support.function.builtin~statement~font-lock-builtin-face",
    "typ~\\b(TYP)\\b~Type~green~storage.type~type~font-lock-type-face",
    "cst~\\b(true|false|nil|NULL|nullptr)\\b~Constant~red~constant.language~constant~font-lock-constant-face",
    "num~\\b(0[xX][0-9a-fA-F]+|[0-9]+(\\.[0-9]+)?)\\b~Number~yellow~constant.numeric~constant~font-lock-constant-face",
    "str~\"([^\"\\\\]|\\\\.)*\"~String~yellow~string.quoted.double~constant.string~font-lock-string-face",
    "cmt~//.*~Comment~brightblack~comment.line~comment~font-lock-comment-face"]
  vim:=["if exists(\"b:current_syntax\") | finish | endif"]
  nano:=["syntax \"nanoc\" \"\\.nc$\""]
  micro:=["filetype: nanoc","detect:","    filename: \"\\\\.nc$\"","rules:"]
  tm:=[]
  sub:=["%YAML 1.2","---","name: NanoC","file_extensions: [nc]","scope: source.nanoc","contexts:","  main:"]
  el:=["(defconst nanoc-font-lock","  '("]
  for row table
    f:=split(row,"~")
    re:=replace(replace(replace(replace(f[1],"DIR",DIR),"CTL",CTL),"BLT",BLT),"TYP",TYP)
    d:=replace(re,"\\","\\\\")
    v:=replace(re,"/","\\/")
    if slice(v,0,2)=="\\b"
      v="<"+slice(v,2,len(v))
    if slice(v,len(v)-2,len(v))=="\\b"
      v=slice(v,0,len(v)-2)+">"
    vim=push(vim,"syntax match nc_"+f[0]+" /\\v"+v+"/")
    vim=push(vim,"highlight default link nc_"+f[0]+" "+f[2])
    nano=push(nano,"color "+f[3]+" \""+replace(re,"\"","\\\"")+"\"")
    micro=push(micro,"    - "+f[5]+": \""+replace(d,"\"","\\\"")+"\"")
    tm=push(tm,o(["name",f[4]+".nanoc","match",re]))
    sub=push(sub,"    - match: '"+replace(re,"'","''")+"'")
    sub=push(sub,"      scope: "+f[4]+".nanoc")
    el=push(el,"    (\""+replace(d,"\"","\\\"")+"\" . "+f[6]+")")
  vim=push(vim,"let b:current_syntax = \"nanoc\"")
  el=push(el,"    ))")
  el=push(el,"(define-derived-mode nanoc-mode prog-mode \"NanoC\" (setq-local font-lock-defaults '(nanoc-font-lock)))")
  el=push(el,"(add-to-list 'auto-mode-alist '(\"\\\\.nc\\\\'\" . nanoc-mode))")
  el=push(el,"(provide 'nanoc-mode)")
  E:="build/editors/"
  V:=E+"vscode/"
  out(V+"syntaxes/nanoc.tmLanguage.json",json(o(["scopeName","source.nanoc","patterns",a(push(tm,o(["include","source.c"])))])))
  out(V+"package.json",json(o(["name","nanoc-language","displayName","NanoC","version","0.3.0","publisher","mkalmousli",
    "icon","icon.png","engines",o(["vscode",">=1.75.0"]),"categories",a(["Programming Languages","Snippets"]),
    "contributes",o(["languages",a([o(["id","nanoc","aliases",a(["NanoC"]),"extensions",a([".nc"]),
      "configuration","./language-configuration.json","icon",o(["light","./icons/nanoc.svg","dark","./icons/nanoc.svg"])])]),
      "grammars",a([o(["language","nanoc","scopeName","source.nanoc","path","./syntaxes/nanoc.tmLanguage.json",
        "embeddedLanguages",o(["source.c","c"])])]),
      "snippets",a([o(["language","nanoc","path","./snippets/nanoc.code-snippets"])])])])))
  out(V+"language-configuration.json",json(o(["comments",o(["lineComment","//","blockComment",a(["/*","*/"])]),
    "brackets",a([a(["(",")"]),a(["[","]"]),a(["{","}"])]),
    "indentationRules",o(["increaseIndentPattern","^\\s*(@"+replace(DIR,"|","|@")+"|"+CTL+")\\b.*$"])])))
  snips:=[]
  for s ["f~@f ${1:name}(${2:args}) ${3:int}~  ${0:ret}","m~@m ${1:name}($${2:x})~  ${0:body}","ct~@ct ${1:name}(${2:args})~  ${0:emit(quote())}","bt~@bt~  ${0:log(\"hi\")}","main~@f main int~  ${0:ret 0}"]
    p:=split(s,"~")
    pre:="@"+p[0]
    if p[0]=="main"
      pre="main"
    snips=push(snips,p[0])
    snips=push(snips,o(["prefix",pre,"body",a(slice(p,1,len(p)))]))
  svg:="<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'><rect width='64' height='64' rx='14' fill='#11110f'/><path d='M14 46V22h6.5v4.2c2.3-3 5.3-4.9 9.2-4.9 6.6 0 10.3 4.3 10.3 11.2V46h-6.6V33.4c0-4-1.9-6.1-5.3-6.1-3.6 0-6.1 2.4-6.1 6.4V46z' fill='#f3f2ec'/><circle cx='49' cy='46' r='5' fill='#d4f66a'/></svg>"
  out(V+"snippets/nanoc.code-snippets",json(o(snips)))
  out(V+"icons/nanoc.svg",svg)
  out(V+"README.md","# NanoC for VS Code\n\nHighlighting and snippets. Run `nanoc editor install vscode`.\n")
  out(E+"vim/nanoc.vim",join(vim,"\n")+"\n")
  out(E+"vim/ftdetect/nanoc.vim","au BufNewFile,BufRead *.nc setfiletype nanoc\n")
  out(E+"nano/nanoc.nanorc",join(nano,"\n")+"\n")
  out(E+"micro/nanoc.yaml",join(micro,"\n")+"\n")
  out(E+"sublime/NanoC.sublime-syntax",join(sub,"\n")+"\n")
  out(E+"emacs/nanoc-mode.el",join(el,"\n")+"\n")
