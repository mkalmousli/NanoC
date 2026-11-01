@use "test", dirent
@f test_remove(cstr path) void
  struct stat st
  if lstat(path, &st)
    return
  if !S_ISDIR(st.st_mode)
    CHECK(unlink(path) == 0)
    return
  DIR *dir = opendir(path)
  CHECK(dir != nil)
  struct dirent *entry
  while (entry = readdir(dir)) != nil
    if !strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")
      continue
    char *child = nc_format(test_state.mem, "%s/%s", path, entry->d_name)
    test_remove(child)
  closedir(dir)
  CHECK(rmdir(path) == 0)
