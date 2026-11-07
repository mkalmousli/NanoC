@lang 1
+ "test.h"

f test_install(void) -> void
  char *prefix = test_path("prefix with spaces")
  bool sanitized = strstr(test_read("build/config"), "sanitize=1") != NULL
  const char *install[] = {"./builder", "install", "--prefix", prefix, sanitized ? "--sanitize" : NULL, NULL}
  (void)test_command(install)
  char *binary = nc_format(test_state.mem, "%s/bin/nanoc", prefix)
  const char *version[] = {binary, "--version", NULL}
  (void)test_command(version)
  char *keep = nc_format(test_state.mem, "%s/share/nanoc/keep.txt", prefix)
  test_write(keep, "keep")
  (void)test_command(install)
  const char *uninstall[] = {"./builder", "uninstall", "--prefix", prefix, NULL}
  (void)test_command(uninstall)
  CHECK(!test_exists(binary))
  CHECK(!strcmp(test_read(keep), "keep"))
  (void)test_command(uninstall)
  test_write(binary, "unrelated")
  CHECK(test_run(install).status != 0)
  CHECK(!strcmp(test_read(binary), "unrelated"))
  char *manifest = nc_format(test_state.mem, "%s/share/nanoc/install.manifest", prefix)
  test_write(manifest, "../../outside\n")
  CHECK(test_run(uninstall).status != 0)
  CHECK(!strcmp(test_read(binary), "unrelated"))
  puts("[OK] C build-driver install/upgrade/uninstall and unmanaged-file protection")

