# Sailbox

Urbit Gall app for learning Sail HTML generation and web development patterns.

## What This Is

A minimal Gall agent that demonstrates:
- Sail HTML templating using Hoon runes
- Rudder web framework integration
- Form handling and state management
- Basic CRUD operations (add ships to a list)

Based on a stripped-down version of %pals.

## Core Files

- `desk/app/sailbox.hoon` - Main Gall agent (97 lines)
- `desk/sur/sailbox.hoon` - Data structures (8 lines)
- `desk/mar/sailbox/command.hoon` - Command mark file (13 lines)
- `desk/app/sailbox/webui/index.hoon` - Sail HTML frontend (68 lines)

# Installation

1. **Clone this repo.**

2. **Boot up a ship** (fakezod or moon or whatever you use).

3. **Create new desk:**
   ```bash
   |new-desk %sailbox
   ```

4. **Install immediately (before any commits):**
   ```bash
   |install our %sailbox
   ```

5. **Mount to filesystem:**
   ```bash
   |mount %sailbox
   ```

6. **Copy sailbox files:**
   ```bash
   cp -r desk/* [ship-name]/sailbox/
   ```

7. **Commit the desk:**
   ```bash
   |commit %sailbox
   ```

8. **Access the web interface:** Visit `[ship-url]/sailbox` in your browser.

## Development Workflow

For iterating on sailbox code:

1. **Setup sync configuration:**
   ```bash
   cp config.example.json config.json
   # Edit config.json with your pier path (e.g., "/path/to/pier/sailbox/")
   ```

2. **Start continuous sync:**
   ```bash
   ./sync.sh
   ```

3. **Make changes to files in `desk/`** - they sync automatically

4. **Commit in dojo:**
   ```bash
   |commit %sailbox
   ```

The sync script watches for file changes and automatically syncs them to your ship.

## Learning Resources

- [Sail documentation](https://developers.urbit.org/guides/additional/sail)
- [Sail/XML runes](https://developers.urbit.org/reference/hoon/rune/mic)
- [Rudder library source](https://github.com/Fang-/suite/blob/11b505ef78a65512ed6ccc7ff77551188499d5b7/lib/rudder.hoon)
- [App School I](https://developers.urbit.org/guides/core/app-school)
