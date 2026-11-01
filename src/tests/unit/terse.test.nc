// Terse-syntax tests, written as cases in src/tests/cases/terse.cases.
@use "test"
@ct
  eval(read("src/dsl/cases.bt.nc"))
  emit(cases("test_terse", "src/tests/cases/terse.cases"))
