#include "nanoc/core.h"
@f hash(const char *s) static size_t
  size_t h = 2166136261u
  for ; *s; ++s
    h = (h ^ (unsigned char)*s) * 16777619u
  h
@f nc_get(const NcMap *m, const char *key) void *
  if !m->cap
    return NULL
  size_t i = hash(key) & (m->cap - 1)
  while m->v[i].key
    if !strcmp(key, m->v[i].key)
      return m->v[i].value
    i = (i + 1) & (m->cap - 1)
  NULL
@f nc_has_token(const NcMap *m, NcToken t) bool
  if !m->cap
    return false
  size_t h = 2166136261u
  for size_t i = 0; i < t.n; ++i
    h = (h ^ (unsigned char)t.s[i]) * 16777619u
  size_t slot = h & (m->cap - 1)
  while m->v[slot].key
    const char *key = m->v[slot].key
    if strlen(key) == t.n && !memcmp(key, t.s, t.n)
      return true
    slot = (slot + 1) & (m->cap - 1)
  false
@f nc_put(NcContext *c, NcMap *m, const char *key, void *value) void
  if !m->cap || m->n >= m->cap / 2
    NcMap old = *m
    m->cap = old.cap ? old.cap * 2 : 16
    m->v = nc_alloc(c, m->cap * sizeof *m->v)
    m->n = 0
    for size_t i = 0; i < old.cap; ++i
      if old.v[i].key
        nc_put(c, m, old.v[i].key, old.v[i].value)
  size_t i = hash(key) & (m->cap - 1)
  while m->v[i].key && strcmp(m->v[i].key, key)
    i = (i + 1) & (m->cap - 1)
  if !m->v[i].key
    ++m->n
  m->v[i] = (NcEntry){key, value}
@f nc_fresh(NcContext *c, const char *hint) char *
  char *name
  while 1
    name = nc_format(c, "nanoc_%s_%zu", hint, ++c->serial)
    if !(nc_get(&c->names, name))
      break
  nc_put(c, &c->names, name, (void *)1)
  name
