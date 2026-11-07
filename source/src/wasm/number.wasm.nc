// Numeric conversion for the freestanding browser compiler.
@lang 1
+ "nanoc/nanoc.h"
+ <ctype.h>
+ <stdlib.h>

// Implements strtoll for the freestanding browser compiler.
f strtoll(const char *s, char **e, int b) long long
  long long v = 0
  int neg = 0
  while isspace((unsigned char)*s)
    ++s
  if *s == '-' || *s == '+'
    neg = *s++ == '-'
  if !b
    b = 10
  for ; isalnum((unsigned char)*s); ++s
    int d = isdigit((unsigned char)*s) ? *s - '0' : tolower(*s) - 'a' + 10
    if d >= b
      !
    v = v * b + d
  if e
    *e = (char *)s
  <  neg ? -v : v

// Implements strtoull for the freestanding browser compiler.
f strtoull(const char *s, char **e, int b) unsigned long long
  <  (unsigned long long)strtoll(s, e, b)

// Implements strtoimax for the freestanding browser compiler.
f strtoimax(const char *s, char **e, int b) intmax_t
  <  strtoll(s, e, b)

// Parses decimal floating literals, preserving the end pointer used by type inference.
f strtod(const char *input, char **end) double
  const char *s = input
  while isspace((unsigned char)*s)
    ++s
  bool negative = false
  if *s == '+' || *s == '-'
    negative = *s++ == '-'
  double value = 0
  bool digits = false
  while isdigit((unsigned char)*s)
    digits = true
    value = value * 10 + (*s++ - '0')
  if *s == '.'
    ++s
    double place = 0.1
    while isdigit((unsigned char)*s)
      digits = true
      value += (*s++ - '0') * place
      place *= 0.1
  if !digits
    if end
      *end = (char *)input
    < 0
  if *s == 'e' || *s == 'E'
    const char *exponent_start = s++
    bool down = false
    if *s == '+' || *s == '-'
      down = *s++ == '-'
    if !isdigit((unsigned char)*s)
      s = exponent_start
    else
      int exponent = 0
      while isdigit((unsigned char)*s)
        if exponent < 4096
          exponent = exponent * 10 + (*s - '0')
        ++s
      for int i = 0; i < exponent; ++i
        value *= down ? 0.1 : 10
  if end
    *end = (char *)s
  < negative ? -value : value
