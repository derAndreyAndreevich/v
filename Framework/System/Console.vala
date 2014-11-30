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

  public class Colorize {
    public static string black(string str) {
      return @"\x1b[30;40m$str\x1b[0m";
    }

    public static string red(string str) {
      return @"\x1b[31;49m$str\x1b[0m"; 
    }

    public static string green(string str) {
      return @"\x1b[32;49m$str\x1b[0m";
    }

    public static string yellow(string str) {
      return @"\x1b[33;49m$str\x1b[0m";
    }

    public static string blue(string str) {
      return @"\x1b[34;49m$str\x1b[0m";
    }

    public static string magenta(string str) {
      return @"\x1b[35;49m$str\x1b[0m";
    }

    public static string cyan(string str) {
      return @"\x1b[36;49m$str\x1b[0m";
    }

    public static string gray(string str) {
      return @"\x1b[37;49m$str\x1b[0m";
    }

    public static string white(string str) {
      return @"\x1b[1;37;49m$str\x1b[0m";
    }

    public static string darkgray(string str) {
      return @"\x1b[1;30;49m$str\x1b[0m";
    }

    public static string light_red(string str) {
      return @"\x1b[1;31;49m$str\x1b[0m"; 
    }

    public static string light_green(string str) {
      return @"\x1b[1;32;49m$str\x1b[0m";
    }

    public static string light_yellow(string str) {
      return @"\x1b[1;33;49m$str\x1b[0m";
    }

    public static string light_blue(string str) {
      return @"\x1b[1;34;49m$str\x1b[0m";
    }

    public static string light_magenta(string str) {
      return @"\x1b[1;35;49m$str\x1b[0m";
    }

    public static string light_cyan(string str) {
      return @"\x1b[1;36;49m$str\x1b[0m";
    }

    public static void print_colors() {
      Console.write_line (@"$(Colorize.red("red")) $(Colorize.green("green")) $(Colorize.yellow("yellow")) $(Colorize.blue("blue")) $(Colorize.magenta("magenta")) $(Colorize.cyan("cyan")) $(Colorize.gray("gray")) $(Colorize.white("white")) $(Colorize.darkgray("darkgray"))");
      Console.write_line (@"$(Colorize.light_red("light_red")) $(Colorize.light_green("light_green")) $(Colorize.light_yellow("light_yellow")) $(Colorize.light_blue("light_blue")) $(Colorize.light_magenta("light_magenta")) $(Colorize.light_cyan("light_cyan"))");
    }

  }
}
