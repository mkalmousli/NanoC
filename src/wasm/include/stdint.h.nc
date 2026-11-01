#ifndef NC_WEB_STDINT_H
#define NC_WEB_STDINT_H
#include <stddef.h>
typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;
typedef long long intmax_t;
typedef unsigned long long uintmax_t;
typedef long intptr_t;
typedef unsigned long uintptr_t;
#define INT64_MAX 9223372036854775807LL
#define INT64_MIN (-9223372036854775807LL-1)
#define UINT64_MAX 18446744073709551615ULL
#define INT32_MAX 2147483647
#define INT32_MIN (-2147483647-1)
#define UINT32_MAX 4294967295U
#define INTMAX_MAX INT64_MAX
#define UINTMAX_MAX UINT64_MAX
#define INTMAX_MIN INT64_MIN
#define SIZE_MAX 4294967295U
#define PRId64 "lld"
#define PRIu64 "llu"
#define PRIx64 "llx"
#define PRIdMAX "lld"
#define PRIuMAX "llu"
#define SCNd64 "lld"
#endif
