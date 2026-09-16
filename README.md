# Odyssey

Homer’s *Odyssey* as a classic **Monkey Island / CD-ROM point-and-click** adventure, built in **Godot 4.5+**.

First playable episode: **Cyclops** (stake, wine, “Nobody,” blind Polyphemus, escape under the sheep).

## Requirements
- [Godot 4.5.1+](https://godotengine.org/download) (4.5 features enabled in `project.godot`)

## Run
1. Open this folder as a project in Godot (`project.godot` at repo root).
2. Press **F5** (or Play). Main scene: `scenes/main.tscn`.
3. You start on the Cyclops shore with **Maronean Wine** in inventory.

**Display:** native **320×200** VGA base, integer-scaled (SCUMM / MI2-era). See `docs/ART.md`.

### Optional headless smoke check
If the Godot 4.5.1 Linux binary is available:

```bash
/tmp/godot451/Godot_v4.5.1-stable_linux.x86_64 --headless --path . --quit-after 2
```

## Controls
| Input | Action |
|-------|--------|
| Verb bar / keys **W L T U P G** | Walk to / Look at / Talk to / Use / Pick up / Give |
| Click floor | Walk (when Walk is selected) |
| Click hotspot | Apply current verb (walks there first) |
| Click inventory item | Select for **Use** / **Give** |

## Cyclops walkthrough (spoiler)
1. **Use** / walk into the **Cave Mouth**.
2. **Talk** to **Polyphemus** → say you are **Nobody** (guest-gift path).
3. **Give** / **Use** **Maronean Wine** on Polyphemus (or offer wine in dialogue) → he falls asleep.
4. **Pick up** **Olive Wood**.
5. **Use** Olive Wood on the **Fire** → get **Wooden Stake**.
6. **Use** Wooden Stake on the **Fire** → **Burning Stake**.
7. **Use** Burning Stake on sleeping **Polyphemus** → blind him.
8. **Pick up** / **Use** the **Sheep** → hide under the ram.
9. **Use** the **Boulder Door** → escape to shore; episode complete.

## Docs
- [`docs/EPISODES.md`](docs/EPISODES.md) — full voyage map
- [`docs/ART.md`](docs/ART.md) — VGA CD-ROM art direction

## Project layout
```
scenes/main.tscn          # entry
scenes/rooms/cyclops/     # shore + cave
scripts/adventure/        # verbs, flags, hotspots, dialogue
scripts/rooms/            # Cyclops puzzle logic
scripts/ui/               # verb bar, inventory, dialogue UI
```
