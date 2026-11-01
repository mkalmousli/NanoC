// Terse-syntax tests, written as cases in src/tests/cases/terse.cases.
#include "test.h"
@ct
  eval(read("src/dsl/cases.bt.nc"))
  emit(cases("test_terse", "src/tests/cases/terse.cases"))
