# Installing Sixarata on macOS

## Quick Start

After downloading the macOS build, you need to remove the quarantine attribute that macOS applies to downloaded files:

### Option 1: Terminal Command (Recommended)
```bash
xattr -cr /path/to/Sixarata.app
```

Then double-click the app to run it.

### Option 2: Using Finder
1. Right-click (or Control+click) on `Sixarata.app`
2. Select "Open" from the menu
3. Click "Open" in the security dialog that appears
4. The app will run and be trusted going forward

## Why is this needed?

macOS Gatekeeper marks all downloaded files with a "quarantine" attribute for security. Since this app is not notarized with Apple (which requires a paid developer account), you need to explicitly tell macOS that you trust it.

This is a one-time step - after doing this once, the app will launch normally.

## For Production Releases

Future signed and notarized releases won't require this step.
