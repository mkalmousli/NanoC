@lang 1
+ "test.h"
+ <dirent.h>

f modules(const char *root) -> static size_t
  DIR *dir = opendir(root)
  CHECK(dir != NULL)
  struct dirent *entry
  size_t count = 0
  while ((entry = readdir(dir)) != NULL)
    if (entry->d_name[0] == '.' || !strcmp(entry->d_name, "assets") || !strcmp(entry->d_name, "cases"))
      continue
    char *path = nc_format(test_state.mem, "%s/%s", root, entry->d_name)
    struct stat st
    CHECK(lstat(path, &st) == 0)
    if (S_ISDIR(st.st_mode))
      count += modules(path)
      continue
    size_t len = strlen(path)
    if (strchr(entry->d_name, '.') != strrchr(entry->d_name, '.'))
      continue
    CHECK(!strstr(entry->d_name, ".c"))
    CHECK(len > 3 && !strcmp(path + len - 3, ".nc"))
    CHECK(strstr(test_read(path), "\nf ") != NULL)
    char *name = nc_string(test_state.mem, path, len - 3)
    char *first = test_read(nc_format(test_state.mem, "build/stage1/%s.c", name))
    char *second = test_read(nc_format(test_state.mem, "build/stage2/%s.c", name))
    char *third = test_read(nc_format(test_state.mem, "build/stage3/%s.c", name))
    CHECK(!strcmp(first, second) && !strcmp(second, third))
    ++count
  closedir(dir)
  return  count

f test_bootstrap(void) -> void
  CHECK(modules("src") > 0)
  const char *self[] = {"build/nanoc", "src/frontend/expand.nc", "-o", test_path("self.c"), NULL}
  (void)test_command(self)
  CHECK(!strcmp(test_read(test_path("self.c")), test_read("build/stage3/src/frontend/expand.c")))
  const char *seed[] = {"build/stage0", "--version", NULL}
  const char *first[] = {"build/stage1-nanoc", "--version", NULL}
  const char *final[] = {"build/nanoc", "--version", NULL}
  (void)test_command(seed)
  CHECK(!strcmp(test_command(first).out, test_command(final).out))
  puts("[OK] every compiler module is NanoC; C seed and two self-hosted generations reach a fixed point")

