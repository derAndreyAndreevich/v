#include <glib.h>
#include <glib-object.h>
#include <stdio.h>

#include <Service.h>

void main() {
  g_type_init();
  service_dll_main();
}