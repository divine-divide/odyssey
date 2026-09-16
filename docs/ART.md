# Art Direction — VGA CD-ROM / SCUMM (MI2 era)

**AD LOCK for Cyclops (and voyage baseline):** classic LucasArts VGA adventure look — *Monkey Island 2* / early CD-ROM point-and-click. Not modern HD UI, not LCD/Tron chrome, not Batter’s Eye styling.

## Resolution
- **Base:** `320×200` logical pixels.
- **Upscale:** integer nearest-neighbor (`stretch/mode=viewport`, `scale_mode=integer`, texture filter **Nearest**).
- Window override defaults to 1280×800 (4×) for comfortable play; keep pixels crisp.

## Layout (SCUMM-like)
| Band | Y range | Role |
|------|---------|------|
| Playfield | 0–144 | Painted room + chunky hotspots + walk box |
| Sentence line | 146–166 | “Walk to Cave Mouth” command/narration (wrap ≤2 lines; never into inventory) |
| Verb grid | 168–198 left | 3×2: Walk to / Look at / Talk to / Use / Pick up / Give |
| Inventory | 168–198 right | Token strip for held items |

## Typography
- Bundle **Tiny5** (SIL OFL) under `assets/fonts/` for verbs, sentence line, inventory, and dialogue.
- Default Godot UI font is banned at 4× — it kills VGA read. Pixel font only.

## Palette
- Aegean sky blues, olive/terracotta earth, charcoal cave, gold sentence accents.
- Verb bar sits on deep indigo (`~#000059`), **selected verb = warm yellow** text/border — MI-era readability, not purple chrome, not glass UI.

## Hotspots & debug chrome
- **No always-on hotspot nameplates** (no CAVE / SHIP / WOOD on the playfield). Names appear only on the **sentence line** on hover.
- Room **Title** + **StatusLabel** stay hidden in play; set `GameState.debug_show_room_chrome = true` for debug.

## Placeholders (shippable)
- **Painted-bg bands:** stacked `ColorRect` silhouettes (sky / cliff / surf / cave wall / floor) stand in for hand-painted rooms.
- **Chunky hotspots:** oversized clickable blocks (visual silhouette only).
- Odysseus = tiny two-rect avatar; Polyphemus = big body + single red eye.

## Dialogue chrome
- Continue is MI-style text / click-through — no Material button chrome.

## Out of scope
- No Batter’s Eye / LCD / Tron / neon HUD.
- No modern flat Material UI, blur, or HD chrome.
- Final sprite/paint pass should still read at 320×200 before upscale.
