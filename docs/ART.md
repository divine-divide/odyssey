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
| Sea | `#2E598F`, foam `#B3CCE6`, **deeper sea `#244773`** *(v2)* |
| Cliff / earth | `#6B5C47`, `#473C2E`, `#80734A`, **mid rock `#5A4E3A`** *(v2)* |
| Cave | `#2E1F14`, `#1F170F`, `#47331F` |
| Skin | `#D9A673`, **skin shadow `#C48E5C`** *(v2)* |
| Odysseus tunic | `#2659B3` |
| Wood | `#52381A`, `#3D2B14` |
| Fire | `#D95914`, `#FFD940` |
| Sheep | `#D1CCB8`, `#26201A` |
| Polyphemus | `#85664D`, eye `#E6261A`, **shade `#6E523C`** *(v2)* |
| Ship | hull `#14100D`, sail `#BFB8A6` |
| UI gold accent | `#F2E040` (icons / buckle) |
| Cheese (prop clutter) | **`#E8C85A`** *(v2, gold-adjacent)* |
| Transparent | fully transparent for sprites/icons |

### v2 palette additions (4 related shades)
Documented for dither / silhouette only — stay hard-edged VGA, no new hue families:
1. `#244773` — deeper sea (wave dither)
2. `#5A4E3A` — mid cliff grain
3. `#C48E5C` — skin shadow / sandal strap
4. `#6E523C` — Polyphemus body shade / tunic dither  
Plus cheese `#E8C85A` for cave prop clutter (warm gold neighbor).

## Hotspots & debug chrome
- **No always-on hotspot nameplates** (no CAVE / SHIP / WOOD on the playfield). Names appear only on the **sentence line** on hover.
- Room **Title** + **StatusLabel** stay hidden in play; set `GameState.debug_show_room_chrome = true` for debug.
- **CollisionShape2D sizes stay fixed** — art swaps ColorRect visuals only (Sprite2D / TextureRect). Align sprites over existing colliders.

## Cyclops pixel pack (`assets/cyclops/`) — **v2 denser MI detail**
Early-90s CD-ROM VGA: **Monkey Island 1/2 VGA** outdoor/interior read + **Legend of Zelda CD-ROM** chunky prop silhouettes.

- Chunky **visible pixels**; hard edges only
- **Limited fixed palette** (no blending, no gradients that invent new colors)
- **NO** modern HD, smooth anti-alias, Batter’s Eye LCD sheen, or Tron neon
- **v2 denser MI detail** — dithered terrain/prop texture, prop clutter, readable silhouettes (not flat color bands)

### Sprite scale rules
- **Odysseus** = **12×22** (idle + walk1/walk2; optional **walk3**) — hair, nose profile, two eyes, belt, sandals
- Props stay **chunky and hit-readable** at VGA (ship 56×34, cave mouth 48×56, Polyphemus 52×72, sheep 48×28, fire 28×28, wood 36×24, stake 16×28)
- **Polyphemus** optional extras: `polyphemus_idle.png`, `polyphemus_blink.png` (same 52×72)
- Inventory icons exactly **16×16**, transparent BG

### Background rules
- Painted **bands / big shapes** plus **dense dither** (sky → sea foam → beach pebbles → cliff grain; cave wall rock → stalactites → floor debris)
- No photo reference paste, no HD detail, no soft fog
- Cave interiors: rock texture, stalactites, cheese wheels, bone pile, sheep-pen rails — clear floor strip so props read on top
- Shore: left sea/beach/sky with foam dither + distant hills; right rocky cliff with **recessed** cave mouth (depth/shadow, not a flat door)

### Z-order
| Layer | z |
|-------|---|
| Background | `0` |
| Props / hotspot visuals | `1`–`5` |
| Player | `10` |

### Integration
- Shore: single `bg_shore` Sprite2D @ `(0,0)` (top-left); `cave_mouth` on EnterCave; `ship` sprite; Odysseus idle + walk frames (walk3 optional)
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
