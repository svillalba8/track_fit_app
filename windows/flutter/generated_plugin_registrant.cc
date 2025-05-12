//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <app_links/app_links_plugin_c_api.h>
<<<<<<< HEAD
=======
#include <file_selector_windows/file_selector_windows.h>
>>>>>>> origin/pantalla_login_singin
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AppLinksPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AppLinksPluginCApi"));
<<<<<<< HEAD
=======
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
>>>>>>> origin/pantalla_login_singin
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
