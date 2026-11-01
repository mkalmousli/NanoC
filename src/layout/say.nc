// The say statement: prints its arguments separated by spaces, then a newline.
@use "nanoc/nanoc"
extern int nc_std;
// Expands "say a, b" to printf calls whose formats follow the C types (needs C11 _Generic).
@f nc_say(NcContext *c, cstr args, int line) char *
  NcGroups parts = nc_split(c, nc_lex(c, args, line), ",")
  NcBuffer out = {0}
  c->need_stdio = true
  nc_add(c, &out, "{ ")
  for i:usize in 0..parts.n
    char *a = nc_trim(c, nc_join(c, parts.v[i]))
    if i
      nc_add(c, &out, "putchar(' '); ")
    if *a == '"'
      nc_printf(c, &out, "fputs(%s, stdout); ", a)
      continue
    if nc_std == 89 or nc_std == 99
      nc_fail(c, line, "say of a value needs --std c11 or newer")
    nc_printf(c, &out, "printf(_Generic((%s), char *: \"%%s\", const char *: \"%%s\", "
      "float: \"%%g\", double: \"%%g\", long double: \"%%Lg\", char: \"%%c\", "
      "unsigned char: \"%%u\", unsigned short: \"%%u\", unsigned: \"%%u\", long: \"%%ld\", "
      "unsigned long: \"%%lu\", long long: \"%%lld\", unsigned long long: \"%%llu\", "
      "default: \"%%d\"), %s); ", a, a)
  nc_add(c, &out, "putchar('\\n'); }")
  out.v
