// Target-standard selection affects only generated NanoC constructs, never arbitrary C islands.
@lang 1
+ "nanoc/nanoc.h"

int nc_std;
// Returns the selected ISO C language level for structured CLI metadata.
f nc_standard_name(void) -> const char *
  if (nc_std == 89)
    return "c89"
  if (nc_std == 99)
    return "c99"
  if (nc_std == 17)
    return "c17"
  return "c11"
