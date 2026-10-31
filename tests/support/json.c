#include "test.h"
static void whitespace(const char **s) { while (isspace((unsigned char)**s)) ++*s; }
static bool string(const char **s) {
    if (*(*s)++ != '"') return false;
    while (**s && **s != '"') {
        if ((unsigned char)**s < 32) return false;
        if (*(*s)++ != '\\') continue;
        if (**s == 'u') {
            ++*s;
            for (int i = 0; i < 4; ++i) { if (!isxdigit((unsigned char)**s)) return false; ++*s; }
        } else {
            if (!**s || !strchr("\"\\/bfnrt", **s)) return false;
            ++*s;
        }
    }
    if (**s != '"') return false;
    ++*s;
    return true;
}
static bool value(const char **s, int depth) {
    if (depth > 128) return false;
    whitespace(s);
    if (**s == '"') return string(s);
    if (**s == '{' || **s == '[') {
        bool object = **s == '{';
        char close = object ? '}' : ']';
        ++*s;
        whitespace(s);
        if (**s == close) { ++*s; return true; }
        for (;;) {
            if (object) {
                whitespace(s);
                if (!string(s)) return false;
                whitespace(s);
                if (*(*s)++ != ':') return false;
            }
            if (!value(s, depth + 1)) return false;
            whitespace(s);
            if (**s == close) { ++*s; return true; }
            if (*(*s)++ != ',') return false;
        }
    }
    const char *words[] = {"true", "false", "null"};
    for (size_t i = 0; i < 3; ++i) if (!strncmp(*s, words[i], strlen(words[i]))) {
        *s += strlen(words[i]);
        return true;
    }
    char *end;
    (void)strtod(*s, &end);
    if (end == *s) return false;
    *s = end;
    return true;
}
bool test_json(const char *source) {
    if (!value(&source, 0)) return false;
    whitespace(&source);
    return !*source;
}
