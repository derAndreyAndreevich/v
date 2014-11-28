using System;

public static int main (string[] args) {
  try {
    string[] spawn_args = {"valac.exe", "--help"};
    string[] spawn_env = Environ.get ();
    string ls_stdout;
    string ls_stderr;
    int ls_status;

    Process.spawn_sync ("./ ",
              spawn_args,
              spawn_env,
              SpawnFlags.SEARCH_PATH,
              null,
              out ls_stdout,
              out ls_stderr,
              out ls_status);

    // Output: <File list>
    // stdout.printf ("stdout:\n");
    // Output: ````
    // stdout.puts (ls_stdout);

    Console.write_line ("Console.write_line:");
    var hello = ls_stdout;
    Console.write_line (ls_stdout);

    stdout.printf ("stderr:\n");
    stdout.puts (ls_stderr);
    // Output: ``0``
    stdout.printf ("status: %d\n", ls_status);

  } catch (SpawnError e) {
    stdout.printf ("Error: %s\n", e.message);
  }

  return 0;
}