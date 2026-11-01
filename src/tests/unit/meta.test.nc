// Meta-programming tests, written as cases in src/tests/cases/meta.cases.
#include "test.h"
@ct
  eval(read("src/dsl/cases.bt.nc"))
  emit(cases("test_meta", "src/tests/cases/meta.cases"))
