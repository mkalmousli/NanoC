@lang 1
// Terse-syntax tests, written as cases in src/tests/cases/terse.cases.
+ "test.h"

@tt
  eval(read("src/dsl/cases.tool.nc"))
  emit(cases("test_terse", "src/tests/cases/terse.cases"))
