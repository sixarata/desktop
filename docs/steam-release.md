# Steam beta release

Steam uploads are intentionally manual. Scheduled desktop builds verify that
the wrappers still compile, but they do not create GitHub releases or contact
Steam.

## One-time Steamworks setup

Confirm these values in Steamworks before the first upload:

- App ID: `3974440`
- Windows depot: `3974442`
- macOS depot: `3974443`
- Linux depot: `3974444`
- Beta branch: `beta`

Create a `steam-beta` GitHub environment and require a reviewer. Add
`STEAM_USERNAME` and `STEAM_PASSWORD` as environment secrets. Use a dedicated
Steam build account that has permission to edit the application.

Configure these Steamworks launch options on the Installation page:

| Operating system | Executable |
| --- | --- |
| Windows | `Sixarata/Sixarata.exe` |
| macOS | `Sixarata/Sixarata.app/Contents/MacOS/app` |
| Linux | `Sixarata/Sixarata.AppImage` |

Assign all three depots to the development package used by the test account.

## Create the candidate

1. Push the intended desktop revision to `main`.
2. Wait for `1. Build Tauri Bundles` to pass on macOS, Windows, and Linux.
3. Wait for `2. Release Tauri Builds` to create the prerelease and the
   `steam-release-folders` artifact.
4. Record the numeric run ID from the release workflow URL.
5. Download and launch each GitHub release archive outside Steam before upload.

The macOS build is universal. The Steam artifact is tarred before upload so
the macOS and Linux executable permissions survive the GitHub artifact round
trip.

## Upload to the beta branch

1. Open `3. Upload to Steam` in GitHub Actions and choose **Run workflow**.
2. Enter the successful release workflow run ID.
3. Approve the `steam-beta` environment deployment.
4. Keep the Steam mobile app available. Approve the Steam Guard login request
   as soon as it appears.
5. Confirm the job reports a Steam BuildID and that the build is live on the
   `beta` branch.

This workflow uses a fresh SteamCMD session. A persistent build machine is the
next step if uploads become frequent. Steam's CI guidance is to authenticate
that machine once, preserve its `config/config.vdf`, and use username-only
logins afterward. Do not store that authentication file in a GitHub Actions
cache.

## Test through Steam

For each supported operating system:

1. Select the `beta` branch in the Steam client.
2. Install the game into an empty library folder.
3. Launch it from the Steam Play button.
4. Verify keyboard and controller input, audio, resizing, room transitions,
   save data, and clean exit.
5. Uninstall it and confirm Steam removes the depot payload.

Promote the tested BuildID to `public` from Steamworks only after all three
platform checks pass.

## Store and library artwork

Run `steam/assets/build.sh` after changing either source file. The generated
directory contains correctly sized capsule and library artwork. Upload actual
gameplay screenshots separately at 1920 by 1080 or larger, in 16:9 format.
Do not use generated gameplay images as screenshots.
