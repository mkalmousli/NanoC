#include <string.h>
@ct {
  let name = fresh("greet");
  let message = "hello\nworld";
  emit(quote { @fn $name()->const char* { return $message; } });
  emit(quote { @fn main()->int { return strcmp($name(), $message); } });
}
