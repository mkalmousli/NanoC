@lang 1
#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
int nc_memcmp(const void *, const void *, size_t);
void *nc_memchr(const void *, int, size_t);
size_t nc_strlen(const char *);
size_t nc_strspn(const char *, const char *);
void *nc_bsearch(const void *, const void *, size_t, size_t,
int (*)(const void *, const void *));
static uint32_t seed = 0x31415926u;
f next(void) static unsigned
  seed ^= seed << 13
  seed ^= seed >> 17
  seed ^= seed << 5
  <  seed

f sign(int n) static int
  <  (n > 0) - (n < 0)

f compare(const void *a, const void *b) static int
  int x = *(const int *)a, y = *(const int *)b
  <  (x > y) - (x < y)

f main(void)
  char a[512], b[512], accept[64]
  char empty[64] = {0}
  int sorted[128], duplicates[128]
  for int i = 0; i < 128; ++i
    sorted[i] = i * 2
    duplicates[i] = (i / 2) * 2
  for int trial = 0; trial < 20000; ++trial
    size_t n = next() % 200, offset = next() % 16
    for size_t i = 0; i < sizeof a; ++i
      a[i] = (char)(1 + next() % 255)
      b[i] = (char)(1 + next() % 255)
    a[n + offset] = 0
    b[n + offset] = 0
    if trial % 3 == 0
      memcpy(b, a, sizeof a)
    for size_t i = 0; i < sizeof accept - 1; ++i
      accept[i] = (char)(1 + next() % 255)
    accept[trial % sizeof accept] = 0
    accept[sizeof accept - 1] = 0
    assert(sign(nc_memcmp(a + offset, b + offset, n)) == sign(memcmp(a + offset, b + offset, n)))
    int c = (int)(next() % 512) - 128
    assert(nc_memchr(a + offset, c, n) == memchr(a + offset, c, n))
    assert(nc_strlen(a + offset) == strlen(a + offset))
    assert(nc_strspn(a + offset, accept) == strspn(a + offset, accept))
    int key = (int)(next() % 300) - 20
    size_t count = next() % 129
    int *base = trial % 2 ? sorted : duplicates
    int *actual = nc_bsearch(&key, base, count, sizeof(int), compare)
    int *expected = bsearch(&key, base, count, sizeof(int), compare)
    assert((actual != NULL) == (expected != NULL))
    if actual
      assert(*actual == key)
  assert(nc_memcmp("", "", 0) == 0)
  assert(nc_memchr("", 0, 0) == NULL)
  assert(nc_strlen(empty) == 0)
  assert(nc_strspn("abc", "") == 0)
  assert(nc_bsearch(sorted, sorted, 0, sizeof(int), compare) == NULL)
  <  0

