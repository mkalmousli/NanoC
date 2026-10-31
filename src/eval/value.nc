#include "nanoc/eval.h"
#include <inttypes.h>
@f nc_integer(int64_t n) NcValue
  (NcValue){.kind = NC_INT, .n = n}
@f nc_boolean(bool n) NcValue
  (NcValue){.kind = NC_BOOL, .n = n}
@f nc_value_text(NcValueKind kind, char *s) NcValue
  (NcValue){.kind = kind, .text = s}
@f nc_list(NcValues items) NcValue
  NcValue v = {.kind = NC_LIST, .items = items.v, .count = items.n, .height = 1}
  for size_t i = 0; i < items.n; ++i
    if items.v[i].height + 1 > v.height
      v.height = items.v[i].height + 1
  v
@f nc_truth(NcValue v) bool
  if v.kind == NC_LIST
    return v.count != 0
  if v.kind == NC_STRING || v.kind == NC_CODE
    return *v.text != 0
  v.n != 0
@f nc_numeric(NcContext *c, NcValue v, int line) int64_t
  if v.kind != NC_INT && v.kind != NC_BOOL
    nc_fail(c, line, "expected an integer")
  v.n
@f nc_display(NcContext *c, NcValue v, size_t depth, int line) char *
  nc_depth(c, depth, line, "value")
  if v.kind == NC_INT
    return nc_format(c, "%" PRId64, v.n)
  if v.kind == NC_BOOL
    return v.n ? "true" : "false"
  if v.kind == NC_STRING || v.kind == NC_CODE
    return v.text
  NcBuffer b = {0}
  nc_add(c, &b, "[")
  for size_t i = 0; i < v.count; ++i
    if i
      nc_add(c, &b, ", ")
    nc_add(c, &b, nc_display(c, v.items[i], depth + 1, line))
    nc_check(c, b.n, line)
  nc_add(c, &b, "]")
  b.v
@f nc_value_code(NcContext *c, NcValue v, int line) char *
  if v.kind == NC_LIST
    nc_fail(c, line, "lists require explicit repetition before emission")
  if v.kind == NC_STRING
    return nc_quote(c, v.text)
  if v.kind == NC_BOOL
    return v.n ? "1" : "0"
  nc_display(c, v, 0, line)
@f nc_equal(NcContext *c, NcValue a, NcValue b, size_t depth, int line) bool
  nc_depth(c, depth, line, "value")
  if a.kind != b.kind
    return false
  if a.kind == NC_INT || a.kind == NC_BOOL
    return a.n == b.n
  if a.kind == NC_STRING || a.kind == NC_CODE
    return !strcmp(a.text, b.text)
  if a.count != b.count
    return false
  for size_t i = 0; i < a.count; ++i
    if !nc_equal(c, a.items[i], b.items[i], depth + 1, line)
      return false
  true
