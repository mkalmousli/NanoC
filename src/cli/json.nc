#include "nanoc/nanoc.h"
@f nc_json_string(FILE *out, const char *s) void
  fputc('"', out)
  for ; *s; ++s
    unsigned char ch = (unsigned char)*s
    if ch == '"' || ch == '\\'
      fputc('\\', out)
      fputc(ch, out)
    else
      if ch < 32
        fprintf(out, "\\u%04x", ch)
      else
        fputc(ch, out)
  fputc('"', out)
@f nc_report(FILE *out, NcContext *c, size_t bytes) void
  fputs("{\"schemaVersion\":1,\"ok\":true,\"file\":", out)
  nc_json_string(out, c->file)
  fprintf(out, ",\"validation\":\"expansion-only\",\"language\":\"%s\",\"generatedBytes\":%zu,\"symbols\":[", c->cpp ? "c++17" : "c11", bytes)
  for size_t i = 0; i < c->symbols.n; ++i
    NcSymbol s = c->symbols.v[i]
    if i
      fputc(',', out)
    fputs("{\"name\":", out)
    nc_json_string(out, s.name)
    fprintf(out, ",\"line\":%d,\"parameters\":", s.line)
    nc_json_string(out, s.params)
    fputs(",\"returnType\":", out)
    nc_json_string(out, s.returns)
    fputs(",\"intent\":", out)
    nc_json_string(out, s.intent)
    fputc('}', out)
  fprintf(out, "],\"passes\":%zu,\"logs\":[", c->pass)
  for size_t i = 0; i < c->logs.n; ++i
    if i
      fputc(',', out)
    nc_json_string(out, c->logs.v[i])
  fputs("],\"diagnostics\":[]}\n", out)
@f nc_diagnostic(FILE *out, NcContext *c) void
  fputs("{\"schemaVersion\":1,\"ok\":false,\"diagnostics\":[{\"code\":", out)
  nc_json_string(out, c->code ? c->code : "NC_INPUT")
  fputs(",\"severity\":\"error\",\"file\":", out)
  nc_json_string(out, c->file)
  fprintf(out, ",\"line\":%d,\"message\":", c->error_line)
  nc_json_string(out, c->detail)
  fputs(",\"trace\":[", out)
  for size_t i = c->frame_count; i; --i
    if i != c->frame_count
      fputc(',', out)
    nc_json_string(out, c->frames[i - 1])
  fputs("]}],\"logs\":[", out)
  for size_t i = 0; i < c->logs.n; ++i
    if i
      fputc(',', out)
    nc_json_string(out, c->logs.v[i])
  fputs("]}\n", out)
