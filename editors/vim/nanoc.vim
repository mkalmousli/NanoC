if exists("b:current_syntax") | finish | endif
syntax match nanocDirective /@\%(f\|fn\|m\|macro\|ct\|bt\|asm\)\>/
syntax match nanocMacro /@[A-Za-z_][A-Za-z_0-9]*/
syntax match nanocCapture /\$\$\?\w\+\%(:\w\+\|\.\.\.\)\?/
syntax keyword nanocControl if elif else for while break continue return goto
syntax keyword nanocType void bool char short int long float double signed unsigned auto const volatile static struct union enum typedef size_t
syntax keyword nanocBuiltin emit quote ident fresh rewrite again source eval
syntax region nanocString start=/"/ skip=/\\./ end=/"/
syntax region nanocChar start=/'/ skip=/\\./ end=/'/
syntax region nanocComment start=/\/\*/ end=/\*\//
syntax match nanocComment /\/\/.*$/
highlight default link nanocDirective PreProc
highlight default link nanocMacro Function
highlight default link nanocCapture Special
highlight default link nanocControl Conditional
highlight default link nanocType Type
highlight default link nanocBuiltin Function
highlight default link nanocString String
highlight default link nanocChar Character
highlight default link nanocComment Comment
let b:current_syntax = "nanoc"
