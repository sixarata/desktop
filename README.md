```
  ■  □  ■   ■    ■    ■ ■      ■    ■ ■ ■    ■
■    ■    ■    ■   ■  ■   ■  ■   ■    ■    ■   ■
  ■  ■    ■    ■ ■ ■  ■ ■    ■ ■ ■    ■    ■ ■ ■
■    ■  ■   ■  ■   ■  ■   ■  ■   ■    ■    ■   ■
```

# Sixarata Desktop

The cross-platform desktop distribution of **Sixarata**, the open-source 2D adventure game engine.

Built with [Tauri](https://tauri.app/), this repo packages the Sixarata web game as a native desktop application for **Linux**, **macOS**, and **Windows**.

## About Sixarata

Sixarata is an MIT-licensed 2D platformer game engine coded entirely in vanilla JavaScript with zero external dependencies. It draws inspiration from classic platformers and metroidvanias, featuring:

- Double jumps, wall jumps, dash mechanics
- Physics-based collision detection
- Tile-based room system
- Gamepad and keyboard input support
- Built-in HUD, camera, and particle systems
- Audio management

## Features

✨ **Native Desktop Experience** - Run as a standalone application with native OS integration
🎮 **Cross-Platform** - Supports Linux (AppImage, Deb, RPM), macOS (DMG, App), and Windows (MSI, NSIS)
⚡ **Lightweight** - Small footprint using Tauri's Rust core
🔧 **No Dependencies** - The game engine uses pure vanilla JavaScript
🚀 **Steam-Ready** - Includes depot configuration for Steam distribution

## Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/) (for development)
- [Rust](https://rustup.rs/) (for building Tauri apps)

### Development

```bash
# Clone the repository
git clone https://github.com/sixarata/desktop.git
cd desktop

# Initialize the game submodule
git submodule update --init --recursive

# Run in development mode
npm run dev
```

### Building

```bash
# Build for your current platform
npm run build

# Or use the convenience script
./build.sh
```

Compiled binaries will be in `src-tauri/target/release/bundle/`.

## Project Structure

```
desktop/
├── app/               # Game source (synced from vendor/sixarata)
│   ├── scripts/       # Game engine and logic
│   │   ├── core/      # Engine systems (physics, inputs, etc.)
│   │   └── custom/    # Game-specific implementations
│   └── styles/        # CSS styling
├── src-tauri/         # Tauri Rust backend
│   ├── src/           # Rust source code
│   └── icons/         # Application icons
├── release/           # Distribution builds
│   ├── linux/         # Linux AppImage
│   ├── macos/         # macOS .app bundle
│   └── win64/         # Windows installer
├── steam/             # Steam distribution configs
└── vendor/sixarata/   # Git submodule of core game
```

## Platform-Specific Notes

### macOS

After downloading, remove the quarantine attribute:

```bash
xattr -cr /path/to/Sixarata.app
```

Or right-click → Open → confirm in the security dialog. See `helpers/macos/INSTALL.md` for details.

### Linux

The AppImage should work out of the box. For system-wide installation:

```bash
# Debian/Ubuntu
sudo dpkg -i sixarata_*.deb

# Fedora/RHEL
sudo rpm -i sixarata-*.rpm
```

### Windows

Run the MSI installer or NSIS setup executable. Windows Defender may show a warning for unsigned applications.

## Steam Distribution

This repo includes Steam depot configurations in the `steam/` directory:

- `build_app.vdf` - Main app configuration
- `depot_*.vdf` - Platform-specific depot configs
- `scripts/` - Build gathering scripts for each platform

## Engine Architecture

The Sixarata game engine is organized into modular systems:

- **Physics** - Position, velocity, acceleration, collision, gravity
- **Components** - Camera, room, buffer, clock, frame, HUD
- **Controls** - Combo detection, input history
- **Inputs** - Gamepad and keyboard device abstraction
- **Mechanics** - Walk, jump, wall jump, dash, fall, coyote time
- **Tiles** - Door, enemy, particle systems
- **Interfaces** - Audio, screen, input management

## Contributing

Fork. Jam. Discuss. Merge. Repeat.

All are welcome. Intolerance is not tolerated.

Ideas for contributions:

- New game mechanics and features
- Performance optimizations
- Platform-specific enhancements
- Documentation improvements
- Bug fixes and testing

## Inspiration

Roguelikes. Metroidvanias. Megas. Contras. Guacs. Plumbers. Knights. Dragons. Fighters. Fantasies.

Your favorite platforming games are our favorites, too.

## Principles

Simplicity. Fun. Learning. Experimentation. Growth.

Consideration. Compassion. Collaboration.

## License

MIT License - See [LICENSE](app/LICENSE) for details.

## Links

- **Main Game Repository**: [sixarata/sixarata](https://github.com/sixarata/sixarata)
- **Web Version**: Play directly in your browser at the main repo
- **Issues**: Report bugs and request features on GitHub

## Development Tools

### Recommended IDE Setup

- [VS Code](https://code.visualstudio.com/) + [Tauri Extension](https://marketplace.visualstudio.com/items?itemName=tauri-apps.tauri-vscode) + [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)

### Available Scripts

```bash
npm run sync:web  # Sync game files from vendor/sixarata to app/
npm run dev       # Run in development mode with hot reload
npm run build     # Build production binaries for current platform
npm run tauri     # Direct access to Tauri CLI
```

---

**Enable everyone to see their name in the credits of an iconic video game.** 🎮
