// The say statement: prints its arguments separated by spaces, then a newline.
extern int nc_std;
// Expands "say a, b" to printf calls whose formats follow the C types (needs C11 _Generic).
@f nc_say(NcContext *c, cstr args, int line) char *
  NcGroups parts = nc_split(c, nc_lex(c, args, line), ",")
  NcBuffer out = {0}
  c->need_stdio = true
  bool lead = false
  for i:usize in 0..parts.n
    char *a = nc_trim(c, nc_join(c, parts.v[i]))
    bool last = i + 1 == parts.n
    if lead and *a != '"' then nc_add(c, &out, "putchar(' ');\n")
    if *a == '"'
      usize n = strlen(a)
      char *inner = nc_string(c, a + 1, n - 2)
      if last then nc_printf(c, &out, "puts(\"%s%s\");\n", lead ? " " : "", inner); return out.v
      nc_printf(c, &out, "fputs(\"%s%s \", stdout);\n", lead ? " " : "", inner)
      lead = false
      continue
    lead = false
    if nc_std == 89 or nc_std == 99 then nc_fail(c, line, "say of a value needs --std c11 or newer")
    nc_printf(c, &out, "printf(_Generic((%s), char *: \"%%s\", const char *: \"%%s\", "
      "float: \"%%g\", double: \"%%g\", long double: \"%%Lg\", char: \"%%c\", "
      "unsigned char: \"%%u\", unsigned short: \"%%u\", unsigned: \"%%u\", long: \"%%ld\", "
      "unsigned long: \"%%lu\", long long: \"%%lld\", unsigned long long: \"%%llu\", "
      "default: \"%%d\"), %s);\n", a, a)
    lead = not last
  nc_add(c, &out, "putchar('\\n');")
  out.v
