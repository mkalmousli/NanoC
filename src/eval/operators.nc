// Binary operators and precedence.
@lang 1
+ "nanoc/nanoc.h"

// Gets the binding power of an operator.
f nc_precedence(NcToken t) -> int
  if (nc_is(t, "||"))
    return 1
  if (nc_is(t, "&&"))
    return 2
  if (nc_is(t, "==") || nc_is(t, "!="))
    return 3
  if (nc_is(t, "<") || nc_is(t, "<=") || nc_is(t, ">") || nc_is(t, ">="))
    return 4
  if (nc_is(t, "+") || nc_is(t, "-"))
    return 5
  if (nc_is(t, "*") || nc_is(t, "/") || nc_is(t, "%"))
    return 6
  return -1

// Applies a binary operator.
f nc_binary(NcContext *c, NcToken op, NcValue a, NcValue b, int line) -> NcValue
  if (nc_is(op, "=="))
    return nc_boolean(nc_equal(c, a, b, 0, line))
  if (nc_is(op, "!="))
    return nc_boolean(!nc_equal(c, a, b, 0, line))
  if (nc_is(op, "&&"))
    return nc_boolean(nc_truth(a) && nc_truth(b))
  if (nc_is(op, "||"))
    return nc_boolean(nc_truth(a) || nc_truth(b))
  if (nc_is(op, "+") && a.kind == b.kind)
    if (a.kind == NC_STRING || a.kind == NC_CODE)
      nc_check(c, strlen(a.text) + strlen(b.text), line)
      return nc_value_text(a.kind, nc_format(c, "%s%s", a.text, b.text))
    if (a.kind == NC_LIST)
      nc_check(c, (a.count + b.count) * 8, line)
      NcValues list = {0}
      for (size_t i = (0), nanoc_bound_1 = (a.count); i < nanoc_bound_1; ++i)
        NC_PUSH(c, list, a.items[i])
      for (size_t i = (0), nanoc_bound_2 = (b.count); i < nanoc_bound_2; ++i)
        NC_PUSH(c, list, b.items[i])
      return nc_list(list)
  int64_t x = nc_numeric(c, a, line), y = nc_numeric(c, b, line)
  if (nc_is(op, "<"))
    return nc_boolean(x < y)
  if (nc_is(op, "<="))
    return nc_boolean(x <= y)
  if (nc_is(op, ">"))
    return nc_boolean(x > y)
  if (nc_is(op, ">="))
    return nc_boolean(x >= y)
  return nc_integer(nc_arithmetic(c, nc_text(c, op), x, y, line))
