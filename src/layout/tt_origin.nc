// Retains TT token coordinates while a runtime body is lowered and expanded again.
@lang 1
+ "nanoc/nanoc.h"

// Stores a TT island behind a compiler-owned identifier until recursive expansion restores it.
f nc_tt_island(NcContext *c, NcLayoutLine line) char *
  NcTokens sig = nc_significant(c, line.ts)
  if sig.n < 2 || !nc_is(sig.v[0], "@") || !nc_is(sig.v[1], "tt")
    < NULL
  char *id
  for ;;
    if c->tt_serial == SIZE_MAX
      nc_fail(c, line.line, "TT island count limit exceeded")
    id = nc_format(c, "nanoc_tt_origin_%zu", ++c->tt_serial)
    if !nc_get(&c->names, id)
      !
  nc_put(c, &c->names, id, (void *)1)
  NcTokens *original = nc_alloc(c, sizeof *original)
  *original = line.ts
  nc_put(c, &c->tt_sources, id, original)
  < id
