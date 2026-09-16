# Art Direction — VGA CD-ROM / SCUMM (MI2 era)

**AD LOCK for Cyclops (and voyage baseline):** classic LucasArts VGA adventure look — *Monkey Island 2* / early CD-ROM point-and-click. Not modern HD UI, not LCD/Tron chrome, not Batter’s Eye styling.

## Resolution
- **Base:** `320×200` logical pixels.
- **Playfield art:** `320×144` backgrounds / room paint.
- **Upscale:** integer nearest-neighbor (`stretch/mode=viewport`, `scale_mode=integer`, texture filter **Nearest**, mipmaps **off**).
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

### Cyclops fixed palette (hex — use only these)
| Role | Hex |
|------|-----|
| Sky | `#739ED1`, `#8CB2D9` |
| Sea | `#2E598F`, foam `#B3CCE6`, deeper `#244773`, **deepest trough `#1A365C`** *(v3)* |
| Cliff / earth | `#6B5C47`, `#473C2E`, `#80734A`, mid `#5A4E3A` |
| Grass tufts | **`#6A7A3A`** *(v3)* |
| Cave | `#2E1F14`, `#1F170F`, `#47331F` |
| Skin | `#D9A673`, shadow `#C48E5C` |
| Odysseus tunic | `#2659B3`, **fold shade `#1A3F8A`** *(v3)* |
| Wood | `#52381A`, `#3D2B14` |
| Fire | `#D95914`, `#FFD940` |
| Sheep | `#D1CCB8`, `#26201A` |
| Polyphemus | `#85664D`, eye `#E6261A`, shade `#6E523C` |
| Ship | hull `#14100D`, sail `#BFB8A6` |
| UI gold accent | `#F2E040` (icons / buckle) |
| Cheese (prop clutter) | `#E8C85A` |
| Bone / bleach clutter | **`#C8C0A8`** *(v3)* |
| Transparent | fully transparent for sprites/icons |

### Palette additions by version
**v2:** `#244773`, `#5A4E3A`, `#C48E5C`, `#6E523C`, `#E8C85A`

**v3 (4 related shades):**
1. `#1A365C` — deepest sea trough / wave dither
2. `#1A3F8A` — Odysseus tunic fold shade
3. `#C8C0A8` — bone piles / bleached clutter
4. `#6A7A3A` — beach / cliff-top grass tufts

## Hotspots & debug chrome
- **No always-on hotspot nameplates** (no CAVE / SHIP / WOOD on the playfield). Names appear only on the **sentence line** on hover.
- Room **Title** + **StatusLabel** stay hidden in play; set `GameState.debug_show_room_chrome = true` for debug.
- **CollisionShape2D sizes stay fixed** — art swaps ColorRect visuals only (Sprite2D / TextureRect). Align sprites over existing colliders; larger art may overhang — do not grow colliders.

## Cyclops pixel pack (`assets/cyclops/`) — **v3 denser MI detail + size bumps**
Early-90s CD-ROM VGA: **Monkey Island 1/2 VGA** outdoor/interior read + **Legend of Zelda CD-ROM** chunky prop silhouettes.

- Chunky **visible pixels**; hard edges only
- **Limited fixed palette** (no blending, no gradients that invent new colors)
- **NO** modern HD, smooth anti-alias, Batter’s Eye LCD sheen, or Tron neon
- **v3 denser MI detail** — dithered terrain/prop texture, prop clutter, readable silhouettes; **larger characters** than v1/v2

### Sprite scale rules (v3 — SIZE CHANGES)
| Asset | Size | Notes |
|-------|------|--------|
| **Odysseus** idle + walk1/2/3 | **20×36** | Was 12×22 — STOP using old size |
| **Polyphemus** + idle + blink | **72×100** | Was 52×72 — STOP using old size |
| ship | **64×40** | Was 56×34 |
| cave_mouth | **56×64** | Was 48×56 |
| sheep | **56×34** | Was 48×28 |
| fire | **32×32** | Was 28×28 |
| olive_wood | **40×28** | Was 36×24 |
| stake / hot_stake | **18×32** | Was 16×28 |
| inv_* icons | **16×16** | Unchanged — richer but legible |

### Background rules
- Painted **bands / big shapes** plus **dense dither** (sky → sea foam → beach pebbles → cliff grain; cave wall rock → stalactites → floor debris)
- No photo reference paste, no HD detail, no soft fog
- **Shore:** ship silhouette **painted ON the water** (left); richer foam/wave dither; rock strata on cliff; beach debris/rocks/grass; cave mouth **carved** with rim + recess + dark interior
- **Cave:** cheese racks, sheep pens with rails, fire pit area, bone/clutter piles, wall depth + stalactites — clear floor strip so props read on top

### Z-order
| Layer | z |
|-------|---|
| Background | `0` |
| Props / hotspot visuals | `1`–`5` |
| Player | `10` |

### Integration
- Shore: single `bg_shore` Sprite2D @ `(0,0)` (top-left); `cave_mouth` on EnterCave; `ship` sprite; Odysseus idle + walk frames (walk3)
- Cave: `bg_cave`; Polyphemus / sheep / fire / olive wood sprites (optional idle/blink frames for Polyphemus)
- **Boulder:** no asset — ColorRect placeholder OK
- InventoryBar: wine / olive_wood / stake / hot_stake → `inv_*.png`
- Import: **Nearest**, mipmaps **off**, lossless/uncompressed preferred
- Art replaces ColorRect placeholders only. Keep SCUMM verb bar chrome, 320×200 layout bands, hotspot CollisionShapes, and puzzle/dialogue/Homer fidelity unchanged.

## Dialogue chrome
- Continue is MI-style text / click-through — no Material button chrome.

## Out of scope
- No Batter’s Eye / LCD / Tron / neon HUD.
- No modern flat Material UI, blur, or HD chrome.
- No filtered/smoothed textures on cyclops pack.
- No puzzle / dialogue / layout retunes for art.
- Final sprite/paint pass should still read at 320×200 before upscale.
