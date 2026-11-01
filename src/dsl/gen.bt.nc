// Shared generator DSL for @bt programs: eval(read("src/dsl/gen.bt.nc")).
// JSON:  o([k,v,k,v..]) object, a([..]) array, r(text) raw token (true, 1, null).
//        Plain strings become JSON strings; nested o/a/r results pass through.
// Files: put(path, text) creates parent directories first (named out below).
f q(s) = "\""+replace(replace(s,"\\","\\\\"),"\"","\\\"")+"\""
f raw(s) = "\t"+s
f r(s) = "\t"+s
f j(v)
  if slice(v,0,1)=="\t"
    slice(v,1,len(v))
  else
    q(v)
f o(kv)
  ps:=[]
  for i range(len(kv)/2)
    ps=push(ps,q(kv[2*i])+":"+j(kv[2*i+1]))
  "\t{"+join(ps,",")+"}"
f a(xs)
  ps:=[]
  for x xs
    ps=push(ps,j(x))
  "\t["+join(ps,",")+"]"
f json(v) = j(v)
f out(path, text)
  parts:=split(path,"/")
  if len(parts)>1
    exec(["mkdir","-p",join(slice(parts,0,len(parts)-1),"/")])
  write(path,text)
