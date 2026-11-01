#include "build.h"
static const char *installed[] = {
    "bin/nanoc", "share/nanoc/README.md", "share/nanoc/docs/language.md",
    "share/nanoc/docs/benchmarks.md", "share/nanoc/docs/agents.md", "share/nanoc/docs/architecture.md",
    "share/nanoc/examples/hello.nc", "share/nanoc/examples/generic.nc",
    "share/nanoc/examples/compile_time.nc", "share/nanoc/examples/interop.nc",
    "share/nanoc/examples/meta.nc", "share/nanoc/examples/build.nc",
    "share/nanoc/examples/compact.nc", "share/nanoc/docs/assembly.md",
    "share/nanoc/docs/bootstrap.md",
    "share/nanoc/install.sh",
    "share/nanoc/editors/vscode/package.json", "share/nanoc/editors/vscode/language-configuration.json",
    "share/nanoc/editors/vscode/syntaxes/nanoc.tmLanguage.json",
    "share/nanoc/editors/vim/nanoc.vim", "share/nanoc/editors/vim/ftdetect/nanoc.vim",
    "share/nanoc/editors/emacs/nanoc-mode.el", "share/nanoc/editors/micro/nanoc.yaml",
    "share/nanoc/editors/nano/nanoc.nanorc", "share/nanoc/editors/sublime/NanoC.sublime-syntax",
    "share/nanoc/install.manifest"
};
enum { INSTALLED_COUNT = sizeof installed / sizeof installed[0] };
static bool manifest(const char *prefix, bool owned[INSTALLED_COUNT]) {
    char path[PATH_MAX];
    b_path(path, prefix, installed[INSTALLED_COUNT - 1]);
    FILE *f = fopen(path, "rb");
    if (!f) { if (errno == ENOENT) return false; b_die("cannot read install manifest"); }
    char line[PATH_MAX];
    while (fgets(line, sizeof line, f)) {
        line[strcspn(line, "\r\n")] = 0;
        if (!*line) continue;
        size_t i;
        for (i = 0; i < INSTALLED_COUNT; ++i) if (!strcmp(line, installed[i])) break;
        if (i == INSTALLED_COUNT) b_die("invalid install manifest entry");
        owned[i] = true;
    }
    if (ferror(f) || fclose(f)) b_die("cannot read install manifest");
    return true;
}
void b_install(const char *prefix) {
    bool owned[INSTALLED_COUNT] = {0};
    (void)manifest(prefix, owned);
    char path[PATH_MAX];
    for (size_t i = 0; i < INSTALLED_COUNT; ++i) {
        b_path(path, prefix, installed[i]);
        if (b_exists(path) && !owned[i]) b_die("refusing to overwrite unmanaged installation file");
    }
    for (size_t i = 0; i + 1 < INSTALLED_COUNT; ++i) {
        b_path(path, prefix, installed[i]);
        b_copy(i ? installed[i] + 12 : "build/nanoc", path);
    }
    b_path(path, prefix, installed[INSTALLED_COUNT - 1]);
    FILE *f = fopen(path, "wb");
    if (!f) b_die("cannot create install manifest");
    for (size_t i = 0; i < INSTALLED_COUNT; ++i) if (fprintf(f, "%s\n", installed[i]) < 0) b_die("cannot write manifest");
    if (fclose(f)) b_die("cannot write manifest");
    printf("Installed to %s\n", prefix);
}
void b_uninstall(const char *prefix) {
    bool owned[INSTALLED_COUNT] = {0};
    if (!manifest(prefix, owned)) { printf("No NanoC installation at %s\n", prefix); return; }
    for (size_t i = 0; i < INSTALLED_COUNT; ++i) if (owned[i]) {
        char path[PATH_MAX];
        b_path(path, prefix, installed[i]);
        if (unlink(path) && errno != ENOENT) b_die("cannot remove installed file");
    }
    printf("Removed recorded NanoC files from %s\n", prefix);
}
