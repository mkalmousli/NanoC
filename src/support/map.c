#include "nanoc/core.h"
static size_t hash(const char *s) {
    size_t h = 2166136261u;
    for (; *s; ++s) h = (h ^ (unsigned char)*s) * 16777619u;
    return h;
}
void *nc_get(const NcMap *m, const char *key) {
    if (!m->cap) return NULL;
    size_t i = hash(key) & (m->cap - 1);
    while (m->v[i].key) {
        if (!strcmp(key, m->v[i].key)) return m->v[i].value;
        i = (i + 1) & (m->cap - 1);
    }
    return NULL;
}
bool nc_has_token(const NcMap *m, NcToken t) {
    if (!m->cap) return false;
    size_t h = 2166136261u;
    for (size_t i = 0; i < t.n; ++i) h = (h ^ (unsigned char)t.s[i]) * 16777619u;
    size_t slot = h & (m->cap - 1);
    while (m->v[slot].key) {
        const char *key = m->v[slot].key;
        if (strlen(key) == t.n && !memcmp(key, t.s, t.n)) return true;
        slot = (slot + 1) & (m->cap - 1);
    }
    return false;
}
void nc_put(NcContext *c, NcMap *m, const char *key, void *value) {
    if (!m->cap || m->n >= m->cap / 2) {
        NcMap old = *m;
        m->cap = old.cap ? old.cap * 2 : 16;
        m->v = nc_alloc(c, m->cap * sizeof *m->v);
        m->n = 0;
        for (size_t i = 0; i < old.cap; ++i)
            if (old.v[i].key) nc_put(c, m, old.v[i].key, old.v[i].value);
    }
    size_t i = hash(key) & (m->cap - 1);
    while (m->v[i].key && strcmp(m->v[i].key, key)) i = (i + 1) & (m->cap - 1);
    if (!m->v[i].key) ++m->n;
    m->v[i] = (NcEntry){key, value};
}
char *nc_fresh(NcContext *c, const char *hint) {
    char *name;
    do { name = nc_format(c, "nanoc_%s_%zu", hint, ++c->serial); }
    while (nc_get(&c->names, name));
    nc_put(c, &c->names, name, (void *)1);
    return name;
}
