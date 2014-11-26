namespace Service {
  public int dll_main () {
      try {
          // an output file in the current working directory
          var file = File.new_for_path ("out.txt");

          // delete if file already exists
          if (file.query_exists ()) {
              file.delete ();
          }

          // creating a file and a DataOutputStream to the file
          /*
              Use BufferedOutputStream to increase write speed:
              var dos = new DataOutputStream (new BufferedOutputStream.sized (file.create (FileCreateFlags.REPLACE_DESTINATION), 65536));
          */
          var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

          // writing a short string to the stream
          dos.put_string ("this is the first line\n");
          
          string text = "this is the second line\n";
          // For long string writes, a loop should be used, because sometimes not all data can be written in one run
          // 'written' is used to check how much of the string has already been written
          uint8[] data = text.data;
          long written = 0;
          while (written < data.length) { 
              // sum of the bytes of 'text' that already have been written to the stream
              written += dos.write (data[written:data.length]);
          }
      } catch (Error e) {
          stderr.printf ("%s\n", e.message);
          return 1;
      }

      return 0;
  }
}