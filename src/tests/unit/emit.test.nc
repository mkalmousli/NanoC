@use "test"
@f emit(cstr source, bool mini) static char *
  NcContext *c = calloc(1, sizeof *c)
  CHECK(c != nil)
  nc_init(c, "test.nc")
  c->mini = mini
  if setjmp(c->trap)
    fprintf(stderr, "%s\n", c->error)
    CHECK(false)
  char *generated = nc_transpile(c, source)
  char *out = nc_string(test_state.mem, generated, strlen(generated))
  nc_dispose(c)
  free(c)
  ret out
@f test_emit void
  const char *source = "@f pick(int *a, int b) int\n  if b > 0\n    return a[0]\n  else\n    b\n"
  const char *normal = "int pick(int *a, int b) {\n    if (b > 0) {\n        return a[0];\n" "    } else {\n        return b;\n    }\n}\n"
  CHECK(!strcmp(emit(source, false), normal))
  CHECK(!strcmp(emit(source, true),
    "int pick(int*a,int b){if(b>0){return a[0];}else{return b;}}\n"))
  const char *types = "@f f int\n  switch (1)\n    case 1:\n      break\n  0\n"
  char *out = emit("@f g int\n  int x[2] = {1, 2}\n  x[0]\n", false)
  CHECK(strstr(out, "{1, 2};") != NULL)
  out = emit("#include <a.h>\n@f g int = 1\n", false)
  CHECK(!strncmp(out, "#include <a.h>\n\nint g(", 22))
  (void)types
  out = emit("@inc stdio, \"a.h\", <b/c.h>\n@f g(int *p) int\n  unless p\n    ret nil\n  loop\n    ret 1\n  0\n", false)
  CHECK(strstr(out, "#include <stdio.h>\n#include \"a.h\"\n#include <b/c.h>\n") != NULL)
  CHECK(strstr(out, "if (!(p)) {\n        return NULL;") != NULL)
  CHECK(strstr(out, "for (;;) {") != NULL)
  puts("[OK] normal and mini emit modes")
