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
| Sentence line | 146–158 | “Walk to Cave Mouth” command line |
| Verb grid | 160–198 left | 3×2: Walk to / Look at / Talk to / Use / Pick up / Give |
| Inventory | 160–198 right | Token strip for held items |

## Palette
- Aegean sky blues, olive/terracotta earth, charcoal cave, gold sentence accents.
- Verb bar sits on deep indigo (`~#000059`), selected verb highlighted warm yellow — MI-era readability, not glass UI.

## Placeholders (shippable)
- **Painted-bg bands:** stacked `ColorRect` silhouettes (sky / cliff / surf / cave wall / floor) stand in for hand-painted rooms.
- **Chunky hotspots:** oversized clickable blocks with short labels (CAVE, FIRE, SHEEP…).
- Odysseus = tiny two-rect avatar; Polyphemus = big body + single red eye.

## Out of scope
- No Batter’s Eye / LCD / Tron / neon HUD.
- No modern flat Material UI, blur, or HD chrome.
- Final sprite/paint pass should still read at 320×200 before upscale.
