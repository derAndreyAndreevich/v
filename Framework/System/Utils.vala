using System;
using GLib.Environment;

namespace System.Utils {
  public string get_current_dir() {
    return GLib.Environment.get_current_dir();
  }

  public string exec(string[] command, string path = get_current_dir()) {

    try {
      string exec_stdout;
      string exec_err;
      int exec_status;

      Process.spawn_sync(path, command, Environ.get (), SpawnFlags.SEARCH_PATH, null,
        out exec_stdout,
        out exec_err,
        out exec_status
      );

      return exec_stdout;
    } catch (SpawnError e) {
      Console.write_line(@"except: $(e.message)");
      return "";
    }

  }
}