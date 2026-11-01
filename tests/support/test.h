#ifndef NC_TEST_H
#define NC_TEST_H
#include "nanoc/nanoc.h"
#include <unistd.h>
#include <sys/stat.h>
typedef struct { int status; char *out, *err; } TestResult;
typedef struct { NcContext *mem; char *dir; size_t assertions; } TestState;
extern TestState test_state;
void test_check(bool, const char *, const char *, int);
#define CHECK(x) test_check((x), #x, __FILE__, __LINE__)
char *test_path(const char *);
char *test_read(const char *);
void test_write(const char *, const char *);
char *test_translate(const char *, bool);
void test_reject(const char *, const char *, size_t, size_t, size_t);
TestResult test_run(const char *const *);
TestResult test_command(const char *const *);
bool test_exists(const char *);
void test_program(const char *, const char *, bool);
void test_remove(const char *);
bool test_json(const char *);
void test_programs(void);
void test_invalid(void);
void test_preservation(void);
void test_emit(void);
void test_arithmetic(void);
void test_generated(void);
void test_cli(void);
void test_agents(void);
void test_install(void);
void test_corpus(void);
void test_integrity(void);
void test_interop(void);
void test_benchmark(void);
void test_meta(void);
void test_build_programs(void);
void test_terse(void);
void test_terse_meta(void);
void test_assembly(void);
void test_bootstrap(void);
#endif
