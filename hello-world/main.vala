using System;
using Vala.Game.Framework;

void main () {
  var application = new Vala.Game.Framework.Application ()
    .set_width (300)
    .set_height (200);

  Console.write_line (@"$application");
  Console.read_line ();
  
}