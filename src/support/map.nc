// Hash map of tokens and fresh names.
// Hashes a string (FNV-1a).
@f hash(cstr s) static usize
  usize h = 2166136261u
  for ; *s; ++s then h = (h ^ (u8)*s) * 16777619u
  h
// Looks up a key in a map.
@f nc_get(const NcMap *m, cstr key) void *
  if not m->cap then return nil
  usize i = hash(key) & (m->cap - 1)
  while m->v[i].key
    if !strcmp(key, m->v[i].key) then return m->v[i].value
    i = (i + 1) & (m->cap - 1)
  nil
// Tells if the map has the token.
@f nc_has_token(const NcMap *m, NcToken t) bool
  if not m->cap then return false
  usize h = 2166136261u
  for i:usize in 0..t.n then h = (h ^ (u8)t.s[i]) * 16777619u
  usize slot = h & (m->cap - 1)
  while m->v[slot].key
    cstr key = m->v[slot].key
    if strlen(key) == t.n and !memcmp(key, t.s, t.n) then return true
    slot = (slot + 1) & (m->cap - 1)
  false
// Stores a key in a map.
@f nc_put(NcContext *c, NcMap *m, cstr key, void *value) void
  if !m->cap || m->n >= m->cap / 2
    NcMap old = *m
    m->cap = old.cap ? old.cap * 2 : 16
    m->v = nc_alloc(c, m->cap * sizeof *m->v)
    m->n = 0
    for i:usize in 0..old.cap
      if old.v[i].key then nc_put(c, m, old.v[i].key, old.v[i].value)
  usize i = hash(key) & (m->cap - 1)
  while m->v[i].key and strcmp(m->v[i].key, key) then i = (i + 1) & (m->cap - 1)
  if !m->v[i].key
    ++m->n
  m->v[i] = (NcEntry){key, value}
// Makes an unused name.
@f nc_fresh(NcContext *c, cstr hint) char *
  char *name
  while 1
    name = nc_format(c, "nanoc_%s_%zu", hint, ++c->serial)
    if !(nc_get(&c->names, name)) then break
  nc_put(c, &c->names, name, (void *)1)
  name
