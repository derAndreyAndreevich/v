function Compile-Vala($options) {
  $output = "--output=.\build\" + $options.item("projectName")

  if ($options.item("pkgs")) { $pkgs = $options.item("pkgs") | % {"--pkg=$_"} }
  if ($options.item("clibs")) { $clibs = $options.item("clibs") | % {"--Xcc=-l$_"} }
  if ($options.item("coptions")) { $coptions = $options.item("coptions") | % {"--Xcc=$_"} }
  if ($options.item("files")) { $files = $options.item("files") | % {"$_.vala"} }

  switch ($options.item("type")) {
    "shared-library" {
      $output += ".dll"
      $library = "--library=./build/" + $options.item("projectName")
      $header = "--header=./build/" + $options.item("projectName") + ".h"
      $coptions += "--Xcc=-shared"
    }

    "window-application" {
      $coptions += "--Xcc=-mwindows"
    }

    "console-application" {
      $coptions += "--Xcc=-mconsole"
    }

    default {
      $coptions += "--Xcc=-mconsole"
    }
  }

  if ($options.item("type") -eq "library") {
  }

  # echo "valac $files $output $library $header $pkgs $coptions $clibs"
  valac $output $library $header $pkgs $clibs $coptions $files
}

function Install-Library-Vala($name) {
  cp "build\$name.dll"  "$valaDir\bin\$name.dll"
  cp "build\$name.dll"  "$valaDir\lib\lib$name.a"
  cp "build\$name.h"    "$valaDir\include\$name.h"
  cp "build\$name.vapi" "$valaVapiDir\$name.vapi"
}

function Clean-Vala {
  rm -Recurse -force .\build
  mkdir build | out-null
}


function Start-Task() {
  $global:compileTime = [Diagnostics.Stopwatch]::StartNew();
}

function End-Task() {
  $global:compileTime.Stop()
  $elapsed = $compileTime.Elapsed

  foreach ($arg in $global:args) { if ($fw -lt $arg.Length) { $fw = $arg.Length } }
  
  $fw = ($fw + 1) * -1
  $str = "{0, $fw}" -f $global:task
  $elapsed = "{0:00}:{1:00}:{2:00}.{3:000}" -f $elapsed.Hours, $elapsed.Minutes, $elapsed.Seconds, $elapsed.Milliseconds

  write-host $str -foreground "White" -nonewline
  write-host "[" -foreground "White" -nonewline
  write-host "$elapsed" -foreground "green" -nonewline
  write-host "]" -foreground "White"
}

$global:valaDir = "C:\vala-0.20.1"
$global:valaBin = "$valaDir\bin\"
$global:valaVapiDir = "c:\ProgramData\vala-0.20\vapi\"
$global:args = $args

$env:PATH += ";$valaBin"
foreach ($global:task in $args) {
  switch ($task) {
    "build-framework" {
      Start-Task; Compile-Vala @{
        "type" = "shared-library";
        "projectName" = "Vala.Game.Framework";
        "pkgs" = @("System", "sdl", "sdl-gfx");
        "clibs" = @("System", "SDL_gfx");
        "files" = @("System/Application");
      }; End-Task
    }
    "install-framework" { Start-Task; Install-Library-Vala "Vala.Game.Framework"; End-Task }
    "clean" { Start-Task; Clean-Vala; End-Task }
    "all" { .\build clean build-framework install-framework }
  }
}