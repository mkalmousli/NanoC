// Raw C islands are opaque to both emitters, including preprocessing and line splicing.
@lang 1
+ "nanoc/nanoc.h"

// Emits one compiler-owned raw island without token or whitespace transformations.
f nc_emit_raw(NcContext *c, NcBuffer *out, NcToken token) bool
  if token.kind != NC_WORD || !c->raw.n
    < 0
  char *text = nc_get(&c->raw, nc_text(c, token))
  if !text
    < 0
  if out->n && out->v[out->n - 1] != '\n'
    nc_add(c, out, "\n")
  nc_add(c, out, text)
  if out->n && out->v[out->n - 1] != '\n'
    nc_add(c, out, "\n")
  < 1
