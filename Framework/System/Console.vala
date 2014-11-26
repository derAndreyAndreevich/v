namespace System {
  public class Console {
    public static void write_line (string text) {
      stdout.printf(text + "\n");
    }

    public static string read_line () {
      string str = stdin.read_line ();

      if (str == null) 
        str = "";


      return str;
    }
  }
}
