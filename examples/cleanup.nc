@use std
// Cleanup is just a macro: open, run the indented body, always close.
@m with_file($f, $path, $body:block)
  for (FILE *$f = fopen($path, "r"), *done_ = $f; done_; done_ = ($f ? (fclose($f), (FILE *)0) : (FILE *)0))
    $body
@f count(cstr path) int
  n:=0
  @with_file(f, path)
    while fgetc(f) != EOF then ++n
  n
@f main int
  printf("bytes: %d\n", count("/dev/null"))
  printf("missing: %d\n", count("/no/such/file"))
  0
