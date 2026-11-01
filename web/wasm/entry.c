/* Browser entry: transpile one NanoC source string to C. Errors trap (no
   longjmp in the browser build); the host reads the message with nc_web_error. */
#include "nanoc/cli.h"
#include <string.h>

static NcContext *last;
static char *last_out;
static size_t last_len;

void nc_host_write(int fd, const char *s, size_t n) { (void)fd; (void)s; (void)n; }
void nc_host_trap(void) { __builtin_trap(); }

int nc_web_transpile(const char *src, size_t len) {
    NcContext *c = calloc(1, sizeof *c);
    nc_init(c, "playground.nc");
    last = c;
    char *copy = malloc(len + 1);
    memcpy(copy, src, len);
    copy[len] = 0;
    last_out = nc_transpile(c, copy);
    last_len = strlen(last_out);
    return 0;
}
const char *nc_web_output(void) { return last_out; }
size_t nc_web_output_len(void) { return last_len; }
const char *nc_web_error(void) { return last ? last->error : ""; }
