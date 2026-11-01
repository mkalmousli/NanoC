// Checked 64-bit integer arithmetic.
#include "nanoc/nanoc.h"
// Applies an operator, checking overflow.
@f nc_arithmetic(
  NcContext *c, const char *op, int64_t x, int64_t y,
  int line
) int64_t
  bool overflow = false
  if !strcmp(op, "+")
    overflow = ((y > 0 && x > INT64_MAX - y)
      || (y < 0 && x < INT64_MIN - y))
    if !overflow
      return x + y
  elif !strcmp(op, "-")
    overflow = ((y < 0 && x > INT64_MAX + y)
      || (y > 0 && x < INT64_MIN + y))
    if !overflow
      return x - y
  elif !strcmp(op, "*")
    if x > 0
      overflow = (y > 0 ? x > INT64_MAX / y
        : y < INT64_MIN / x)
    elif x < 0
      overflow = (y > 0 ? x < INT64_MIN / y : y < 0
        && x < INT64_MAX / y)
    if !overflow
      return x * y
  elif !strcmp(op, "/") || !strcmp(op, "%")
    if !y
      nc_fail(c, line, "division by zero")
    if x == INT64_MIN && y == -1
      overflow = true
    else
      return *op == '/' ? x / y : x % y
  if overflow
    nc_fail(c, line, "compile-time integer overflow")
  nc_fail(c, line, "unknown operator: %s", op)
  (int64_t){0}
