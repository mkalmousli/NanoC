#ifndef NC_WEB_SYS_WAIT_H
#define NC_WEB_SYS_WAIT_H
int fork(void);
#endif
#undef NC_WEB_SYS_WAIT_H
#ifndef NC_WEB_SYS_WAIT_H2
#define NC_WEB_SYS_WAIT_H2
#include <sys/types.h>
pid_t waitpid(pid_t, int *, int);
#define WIFEXITED(s) (((s) & 0x7f) == 0)
#define WEXITSTATUS(s) (((s) >> 8) & 0xff)
#define WTERMSIG(s) ((s) & 0x7f)
#endif
