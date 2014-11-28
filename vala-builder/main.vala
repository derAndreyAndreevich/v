using System;
using System.Utils;

public static int main (string[] args) {
  // try {
    // string[] spawn_args = {"ls"};
    // string[] spawn_env = Environ.get ();
    // string ls_stdout;
    // string ls_stderr;
    // int ls_status;

    // Process.spawn_sync ("c:/",
    //           spawn_args,
    //           spawn_env,
    //           SpawnFlags.SEARCH_PATH,
    //           null,
    //           out ls_stdout,
    //           out ls_stderr,
    //           out ls_status);

    // // Output: <File list>
    // // stdout.printf ("stdout:\n");
    // // Output: ````
    // // stdout.puts (ls_stdout);

    // Console.write_line ("Console.write_line:");
    // var hello = ls_stdout;
    // Console.write_line (ls_stdout);

    // stdout.printf ("stderr:\n");
    // stdout.puts (ls_stderr);
    // // Output: ``0``
    // stdout.printf ("status: %d\n", ls_status);
    Console.write_line(exec({"valac", "./main.vala", "--ccode", "--pkg=System"}, "C:\\projects\\vala\\v\\vala-builder"));
    Console.write_line(exec({"pkg-config", "--libs", "--cflags", "glib-2.0"}));
    

  // } catch (SpawnError e) {
  //   stdout.printf ("Error: %s\n", e.message);
  // }

  return 0;
}