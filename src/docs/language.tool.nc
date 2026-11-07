// All reference pages render maintained sections from the same guide used by the website.
f guide_section(id)
  ls:=meaningful_lines(read("src/content/guide.doc.nc"))
  start:=-1
  end:=len(ls)
  for i range(len(ls))
    if starts(ls[i],"lesson "+id+" ")
      start=i
    elif start>=0 && starts(ls[i],"lesson ")
      end=i
      break
  assert(start>=0,"unknown guide section: "+id)
  put("doc:n",0)
  join(render_doc(slice(ls,start,end),false),"\n\n")
page("docs/language.md",[h(1,"NanoC language guide"),doc_md("src/content/guide.doc.nc")])
page("docs/preprocessor.md",[h(1,"C preprocessing"),guide_section("preprocessor")])
page("docs/interop.md",[h(1,"C interoperability"),guide_section("raw"),guide_section("output")])
page("docs/macros.md",[h(1,"Macros and compile-time transformations"),guide_section("macros"),guide_section("ct")])
