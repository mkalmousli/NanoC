// Checked 64-bit integer arithmetic.
// Applies an operator, checking overflow.
@f nc_arithmetic(NcContext *c, cstr op, int64_t x, int64_t y, int line) int64_t
  bool overflow = false
  if !strcmp(op, "+")
    overflow = (y > 0 and x > INT64_MAX - y) or (y < 0 and x < INT64_MIN - y)
    if not overflow then return x + y
  elif !strcmp(op, "-")
    overflow = (y < 0 and x > INT64_MAX + y) or (y > 0 and x < INT64_MIN + y)
    if not overflow then return x - y
  elif !strcmp(op, "*")
    if x > 0 then overflow = y > 0 ? x > INT64_MAX / y : y < INT64_MIN / x
    elif x < 0 then overflow = y > 0 ? x < INT64_MIN / y : y < 0 && x < INT64_MAX / y
    if not overflow then return x * y
  elif !strcmp(op, "/") || !strcmp(op, "%")
    if not y then nc_fail(c, line, "division by zero")
    if x == INT64_MIN and y == -1 then overflow = true else return *op == '/' ? x / y : x % y
  if overflow then nc_fail(c, line, "compile-time integer overflow")
  nc_fail(c, line, "unknown operator: %s", op)
  (int64_t){0}
