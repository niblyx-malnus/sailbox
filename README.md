# sailbox

simple sandbox to play around with sail

a stripped down version of [%pals](https://github.com/Fang-/suite/blob/11b505ef78a65512ed6ccc7ff77551188499d5b7/app/pals.hoon)


- Learn about Sail [here](https://developers.urbit.org/guides/additional/sail).
- Learn about Sail/XML runes [here](https://developers.urbit.org/reference/hoon/rune/mic).
- Find the rudder library [here](https://github.com/Fang-/suite/blob/11b505ef78a65512ed6ccc7ff77551188499d5b7/lib/rudder.hoon).
- See more examples of using the rudder library [here](https://github.com/Fang-/suite/tree/11b505ef78a65512ed6ccc7ff77551188499d5b7/lib/rudder).
- If new to gall agents, use in conjunction with App School I [here](https://developers.urbit.org/guides/core/app-school).

Files to mess around with:

- `/app/sailbox.hoon`
- `/sur/sailbox.hoon`
- `/mar/sailbox/command.hoon`
- `/app/sailbox/webui/index.hoon`

# Installation
1. Clone this repo.
2. Boot up a ship (fakezod or moon or whatever you use).
4. `|merge %sailbox our %webterm` to create a new desk called `%sailbox` forked from the `%webterm` desk.
5. `|mount %sailbox` to access the `%sailbox` desk from the unix command line.
6. At the unix command line `rm -rf [ship-name]/sailbox/*` to empty out the contents of the desk.
7. `cp -r sailbox/* [ship-name]/sailbox` to copy the contents of this repo into your new desk.
8. At the dojo command line `|commit %sailbox`.
9. Install with `|install our %sailbox`.
10. A purple tile should have appeared in Grid marked "sailbox" and a webpage should now be live at `[ship-url]/sailbox`.
