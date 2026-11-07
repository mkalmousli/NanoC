// Editor names and their install targets.
@lang 1
+ "nanoc/nanoc.h"

+ "nanoc/manage.h"

// Gets the name of editor i.
f nc_editor_name(size_t i) const char *
  static const char *ids[] = {"vscode", "vim", "neovim", "emacs", "micro", "nano", "sublime", NULL}
  < ids[i]

// Tells if an editor name exists.
f nc_known_editor(const char *name) bool
  for size_t i = 0; nc_editor_name(i); ++i
    if !strcmp(name, nc_editor_name(i))
      < 1
  < 0

// Lists install targets of an editor.
f nc_targets(const char *editor, NcTarget *t) int
  char home[PATH_MAX]
  char cfg[PATH_MAX]
  char dir[PATH_MAX]
  if !nc_known_editor(editor) || !mg_home(home) || !mg_config(cfg)
    < -1
  int n = 0
  if !strcmp(editor, "vscode")
    mg_vscode(t, &n, home)
  if !strcmp(editor, "vim") || !strcmp(editor, "neovim")
    if !strcmp(editor, "vim")
      snprintf(dir, sizeof dir, "%s/.vim", home)
    else
      snprintf(dir, sizeof dir, "%s/nvim", cfg)
    mg_add(t, &n, "editors/vim/nanoc.vim", dir, "syntax/nanoc.vim")
    mg_add(t, &n, "editors/vim/ftdetect/nanoc.vim", dir, "ftdetect/nanoc.vim")
  if !strcmp(editor, "emacs")
    char emacs[PATH_MAX]
    snprintf(emacs, sizeof emacs, "%s/.emacs.d", home)
    if nc_exists(emacs)
      snprintf(dir, sizeof dir, "%s/lisp", emacs)
    else
      snprintf(dir, sizeof dir, "%s/emacs/lisp", cfg)
    mg_add(t, &n, "editors/emacs/nanoc-mode.el", dir, "nanoc-mode.el")
  if !strcmp(editor, "micro")
    snprintf(dir, sizeof dir, "%s/micro/syntax", cfg)
    mg_add(t, &n, "editors/micro/nanoc.yaml", dir, "nanoc.yaml")
  if !strcmp(editor, "nano")
    snprintf(dir, sizeof dir, "%s/.nano", home)
    mg_add(t, &n, "editors/nano/nanoc.nanorc", dir, "nanoc.nanorc")
  if !strcmp(editor, "sublime") && mg_sublime_dir(dir)
    mg_add(t, &n, "editors/sublime/NanoC.sublime-syntax", dir, "NanoC.sublime-syntax")
  < n
