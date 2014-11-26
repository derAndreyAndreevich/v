using System;

namespace Vala.Game.Framework {
  public class Application: Object {
    private int _width = 800;
    public int get_width () { return _width; }
    public Application set_width (int _value = 800) { _width = _value; return this; }

    private int _height = 600;
    public int get_height () { return _height; }
    public Application set_height (int _value = 600) { _height = _value; return this; }

    private string _caption = "vala-game-framework";
    public string get_caption () { return _caption; }
    public Application set_caption (string _value = "vala-game-framework") { _caption = _value; return this; }

    public Application run () {
      Console.write_line ("Application run");
      return this;
    }

    public string to_string () {
      return @"Application { width: $_width, height: $_height, caption: $_caption }";
    }

    
  }
}
