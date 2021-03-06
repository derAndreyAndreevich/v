string array_to_string (string[] arr) {
  var result = "";
  for (var i = 0; i < arr.length; ++i) {
    if (i == 0) result += @"[";
    if (i < arr.length) result += i < arr.length - 1 ? @"$(arr[i])," : @"$(arr[i])";
    if (i == arr.length - 1) result += "]";
  }
  return result;
}



void main () {
  var 
    files = new string[0], 
    pkgs = new string[0], 
    valaflags = new string[0], 
    cflags = new string[0], 
    clibs = new string[0],
    sfiles = "", 
    spkgs = "", 
    svalaflags = "", 
    scflags = "", 
    sclibs = "", 
    command_out = "", 
    command_error = "", 
    command_status = 0;

  try {
    var file = new KeyFile();

    file.load_from_file("gccbuild", KeyFileFlags.NONE);
    file.set_list_separator(',');

    foreach (var pname in file.get_string_list("Projects", "names")) {
      pname = pname.strip();

      if (file.has_group(pname) && file.has_key(pname, "files")) {
        files = file.get_string_list(pname, "files");
        foreach (var f in files) {
          f = f.strip();
          sfiles += @" $f.vala";
        }
      }

      if (file.has_group(pname) && file.has_key(pname, "pkgs")) {
        pkgs = file.get_string_list(pname, "pkgs");
        foreach (var p in pkgs) {
          p = p.strip();
          spkgs += @" --pkg=$p";
        }
      }

      if (file.has_group(pname) && file.has_key(pname, "valaflags")) {
        valaflags = file.get_string_list(pname, "valaflags");
        foreach (var f in valaflags) {
          f = f.strip();
          svalaflags += @" $f";
        }
      }

      if (file.has_group(pname) && file.has_key(pname, "cflags")) {
        cflags = file.get_string_list(pname, "cflags");
        foreach (var f in cflags) {
          f = f.strip();
          scflags += @" --Xcc=$f";
        }
      }

      if (file.has_group(pname) && file.has_key(pname, "clibs")) {
        clibs = file.get_string_list(pname, "clibs");
        foreach (var l in clibs) {
          l = l.strip();
          sclibs += @" --Xcc=-l$l";
        }
      }

      stdout.printf(@"project: $pname\n");
      stdout.printf(@"  files: $(array_to_string(files))\n");
      stdout.printf(@"  pkgs: $(array_to_string(pkgs))\n");
      stdout.printf(@"  valaflags: $(array_to_string(valaflags))\n");
      stdout.printf(@"  cflags: $(array_to_string(cflags))\n");
      stdout.printf(@"  clibs: $(array_to_string(clibs))\n");
    }

  } catch (KeyFileError e) {
    stdout.printf(@"read error: $(e.message)");
  } catch (FileError e) {
    stdout.printf(@"read error: $(e.message)");
  }

  try {
    Process.spawn_command_line_sync(@"valac $sfiles $spkgs $svalaflags $scflags $sclibs", out command_out, out command_error, out command_status);
    stdout.printf(@"run: \n  valac $sfiles $spkgs $svalaflags $scflags $sclibs");
  } catch (Error e) {
    stdout.printf("command error: $(e.message)");
  }

}