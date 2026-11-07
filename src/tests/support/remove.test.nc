@lang 1
+ "test.h"
+ <dirent.h>

f test_remove(const char *path)
  struct stat st
  if lstat(path, &st)
    <
  if !S_ISDIR(st.st_mode)
    CHECK(unlink(path) == 0)
    <
  DIR *dir = opendir(path)
  CHECK(dir != NULL)
  struct dirent *entry
  while (entry = readdir(dir)) != NULL
    if !strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")
      ^
    char *child = nc_format(test_state.mem, "%s/%s", path, entry->d_name)
    test_remove(child)
  closedir(dir)
  CHECK(rmdir(path) == 0)

