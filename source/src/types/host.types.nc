// Host portability: the few OS facilities NanoC uses, spelled for POSIX and for Windows.
@lang 1
#ifdef _WIN32
#include <direct.h>
#include <io.h>
#include <process.h>
#include <sys/stat.h>
#define NC_WINDOWS 1
#define NC_MKDIR(p) _mkdir(p)
#define NC_RMDIR(p) _rmdir(p)
#define NC_ISATTY(fd) _isatty(fd)
#define NC_REALPATH(p, out) (_fullpath(out, p, PATH_MAX) != NULL)
#define NC_RUNNABLE(p) (_access(p, 0) == 0)
#define NC_PATH_LIST ';'
#define NC_HOME_VAR "USERPROFILE"
#define NC_TEMP_VAR "TEMP"
#define NC_TEMP_DEFAULT "."
#define NC_SHELL_RMTREE "rmdir /s /q \"%s\""
#define NC_CONFIG_DIR "%s/AppData/Roaming"
#define NC_SUBLIME_DIR "%s/AppData/Roaming/Sublime Text/Packages/User"
#else
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#define NC_MKDIR(p) mkdir(p, 0755)
#define NC_RMDIR(p) rmdir(p)
#define NC_ISATTY(fd) isatty(fd)
#define NC_REALPATH(p, out) (realpath(p, out) != NULL)
#define NC_RUNNABLE(p) (access(p, X_OK) == 0)
#define NC_PATH_LIST ':'
#define NC_HOME_VAR "HOME"
#define NC_TEMP_VAR "TMPDIR"
#define NC_TEMP_DEFAULT "/tmp"
#define NC_SHELL_RMTREE "rm -rf '%s'"
#define NC_CONFIG_DIR "%s/.config"
#ifdef __APPLE__
#define NC_SUBLIME_DIR "%s/Library/Application Support/Sublime Text/Packages/User"
#else
#define NC_SUBLIME_DIR "%s/.config/sublime-text/Packages/User"
#endif
#endif
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
