#ifndef NC_WEB_SETJMP_H
#define NC_WEB_SETJMP_H
/* The browser build never unwinds: longjmp traps and the host reports c->error. */
typedef int jmp_buf[1];
#define setjmp(b) 0
void longjmp(jmp_buf, int) __attribute__((noreturn));
#endif
