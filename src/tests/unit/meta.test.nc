@lang 1
// Meta-programming tests, written as cases in src/tests/cases/meta.cases.
+ "test.h"

@tt
  eval(read("src/dsl/cases.tool.nc"))
  emit(cases("test_meta", "src/tests/cases/meta.cases"))
