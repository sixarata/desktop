# Steam packaging for Sixarata

## Fill these once, then commit:
- Replace APP_ID, DEPOT_ID_WIN, DEPOT_ID_OSX, DEPOT_ID_LINUX in:
  - steam/build_app.vdf
  - steam/depot_win.vdf
  - steam/depot"appbuild"
{
  "appid" "APP_ID"
  "desc"  "Sixarata desktop build"
  "buildoutput" "steam/steambuild_output"
  "contentroot" "."
  "setlive" "beta" // change to "public" when ready

  "depots"
  {
    "DEPOT_ID_WIN"   "steam/depot_win.vdf"
    "DEPOT_ID_OSX"   "steam/depot_osx.vdf"
    "DEPOT_ID_LINUX" "steam/depot_linux.vdf"
  }
}_osx.vdf
  - steam/depot_linux.vdf
- Confirm the executable names produced by Tauri (usually "Sixarata").

## Local test upload (optional)
1) Build on each OS (or download workflow artifacts).
2) Run gather script for that OS:
   - Windows:   powershell -ExecutionPolicy Bypass -File steam/scripts/gather_win.ps1
   - macOS:     bash steam/scripts/gather_macos.sh
   - Linux:     bash steam/scripts/gather_linux.sh
3) Install SteamCMD locally and run:
   steamcmd +login <user> <pass> +run_app_build steam/build_app.vdf +quit

## CI upload (recommended)
- Set GitHub Secrets:
  - STEAM_USERNAME
  - STEAM_PASSWORD
  - (optional if your account requires it) STEAM_GUARD_CODE
- Push a tag like v0.1.0 or use "Run workflow" on the Actions tab.