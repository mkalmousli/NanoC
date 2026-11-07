// Streaming JSON writer: callers describe structure, punctuation and escaping happen here.
@lang 1
+ "nanoc/nanoc.h"

// Starts a writer on a stream.
f jw_start(NcJson *w, FILE *out) -> void
  w->out = out
  w->depth = 0
  w->more[0] = 0

// Writes the comma owed before the next value, if any.
f jw_sep(NcJson *w) -> static void
  if (w->more[w->depth])
    fputc(',', w->out)
  w->more[w->depth] = 1

// Writes a JSON string literal.
f jw_text(NcJson *w, const char *s) -> void
  fputc('"', w->out)
  for (; *s; ++s)
    unsigned char ch = (unsigned char)*s
    if (ch == '"' || ch == '\\')
      fputc('\\', w->out); fputc(ch, w->out)
    elif (ch < 32)
      fprintf(w->out, "\\u%04x", ch)
    else
      fputc(ch, w->out)
  fputc('"', w->out)

// Opens an object or array (open is '{' or '[').
f jw_open(NcJson *w, char open) -> void
  jw_sep(w)
  fputc(open, w->out)
  w->more[++w->depth] = 0

// Closes the innermost object or array.
f jw_close(NcJson *w, char close) -> void
  --w->depth
  fputc(close, w->out)

// Writes an object key; the next value belongs to it.
f jw_key(NcJson *w, const char *key) -> void
  jw_sep(w)
  jw_text(w, key)
  fputc(':', w->out)
  w->more[w->depth] = 0

// Writes a string value.
f jw_str(NcJson *w, const char *s) -> void
  jw_sep(w)
  jw_text(w, s)

// Writes an integer value.
f jw_int(NcJson *w, long n) -> void
  jw_sep(w)
  fprintf(w->out, "%ld", n)

// Writes a boolean value.
f jw_bool(NcJson *w, bool b) -> void
  jw_sep(w)
  fputs(b ? "true" : "false", w->out)

// Writes pre-rendered JSON as one value.
f jw_raw(NcJson *w, const char *json) -> void
  jw_sep(w)
  fputs(json, w->out)

// Key/value shortcuts: "k": string, integer, boolean, raw.
f jw_ks(NcJson *w, const char *k, const char *s) -> void
  jw_key(w, k)
  jw_str(w, s)

f jw_ki(NcJson *w, const char *k, long n) -> void
  jw_key(w, k)
  jw_int(w, n)

f jw_kb(NcJson *w, const char *k, bool b) -> void
  jw_key(w, k)
  jw_bool(w, b)

f jw_kr(NcJson *w, const char *k, const char *json) -> void
  jw_key(w, k)
  jw_raw(w, json)
