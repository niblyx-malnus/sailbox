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

Total core implementation: ~186 lines of code.

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

## Testing via Dojo

Once installed, you can test the app via dojo:

```bash
# Check app state
:sailbox +dbug

# Add ships
:sailbox &sailbox-command [%add-ship ~zod]
:sailbox &sailbox-command [%add-ship ~nec]

# Test other commands
:sailbox &sailbox-command [%do-a-thing ~]
:sailbox &sailbox-command [%do-another ~]
```

## Technical Details

- **Kelvin**: Supports zuse 410+
- **Dependencies**: Rudder library (included in lib/)
- **Installation**: Uses `|new-desk` pattern with immediate `|install`

## Learning Resources

- [Sail documentation](https://developers.urbit.org/guides/additional/sail)
- [Sail/XML runes](https://developers.urbit.org/reference/hoon/rune/mic)
- [Rudder library source](https://github.com/Fang-/suite/blob/11b505ef78a65512ed6ccc7ff77551188499d5b7/lib/rudder.hoon)
- [App School I](https://developers.urbit.org/guides/core/app-school)
