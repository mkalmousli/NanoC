// The editors install/list commands.
@use "nanoc/manage", stdlib, string
// Prints an ok/fail status line.
@f nc_ui_line(bool ok, cstr name, cstr where) void
  bool tty = NC_ISATTY(1)
  const char *mark = ok ? (tty ? "\033[32m✓\033[0m" : "✓") : (tty ? "\033[31m✗\033[0m" : "✗")
  printf("  %s %-9s %s\n", mark, name, where)
// Installs editor files for a name.
@f mg_install(cstr prefix, cstr name) static bool
  NcTarget t[16]
  int n = nc_targets(name, t)
  if n <= 0 then return false
  char share[PATH_MAX * 2]
  snprintf(share, sizeof share, "%s/share/nanoc", prefix)
  mg_forget(prefix, name)
  bool ok = true
  for i in 0..n
    char from[PATH_MAX * 2]
    snprintf(from, sizeof from, "%s/%s", share, t[i].src)
    if nc_copy_file(from, t[i].dst) then mg_remember(prefix, name, t[i].dst); nc_ui_line(true, name, t[i].dst)
    else nc_ui_line(false, name, t[i].dst); ok = false
  ok
// Tells if name is among the args.
@f mg_named(int argc, char **argv, int first, cstr name) static bool
  for i in first..argc
    if !strcmp(argv[i], name) then return true
  false
// Lists known editors.
@f nc_editor_list(cstr prefix) static int
  printf("  %-9s %-10s %s\n", "EDITOR", "DETECTED", "INSTALLED")
  for usize i = 0; nc_editor_name(i); ++i
    cstr name = nc_editor_name(i)
    printf("  %-9s %-10s %s\n", name, mg_detected(name) ? "yes" : "no",
      mg_installed(prefix, name) ? "yes" : "no")
  0
// Runs the editors subcommand.
@f nc_editor_command(int argc, char **argv, cstr prefix) int
  int first = 0
  bool remove = argc && (!strcmp(argv[0], "remove") || !strcmp(argv[0], "uninstall"))
  if argc && (remove || !strcmp(argv[0], "install")) then first = 1
  if argc && !strcmp(argv[0], "list") then return nc_editor_list(prefix)
  bool all = false
  int named = 0
  for i in first..argc
    if !strcmp(argv[i], "--all") then all = true
    else
      if !nc_known_editor(argv[i])
        fprintf(stderr, "nanoc editor: unknown editor %s (try: nanoc editor list)\n", argv[i])
        return 2
      named += 1
  if remove and !all and !named then fputs("usage: nanoc editor remove NAME|--all\n", stderr); return 2
  int status = 0
  int acted = 0
  for usize i = 0; nc_editor_name(i); ++i
    cstr name = nc_editor_name(i)
    bool picked = (all or mg_named(argc, argv, first, name)
      or (!named and !remove and mg_detected(name)))
    if not picked then continue
    acted += 1
    if remove
      if mg_installed(prefix, name) then mg_forget(prefix, name); printf("  - %s removed\n", name)
    elif !mg_install(prefix, name) then status = 1
  if !acted and !remove then puts("No supported editors detected. Name one: nanoc editor install vim")
  status
