#include <locale.h>
#include <gtk/gtk.h>

void writeln (gchar *str) {
  g_print("%s\n", str);
}

int main (gint argc, gchar *argv[]) {
  setlocale(LC_ALL, "ru_RU.utf8");

  g_print ("hello world\nПривет мир!\n");
  
  g_print("Processors count: %d\n", g_get_num_processors ());
  return 0;
}