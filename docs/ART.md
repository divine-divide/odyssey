# Art Direction — VGA CD-ROM Vibe

Target feel: early–mid 90s adventure CD-ROMs (*Monkey Island 1/2*, *Fate of Atlantis*, *Broken Sword* VGA era).

## Palette & resolution
- Native layout **960×640** (logical), pixel-art friendly; default texture filter **Nearest**.
- Limited earth-and-wine palette: Aegean blues, olive greens, terracotta, charcoal, gold UI accents.
- Hotspots readable as silhouettes even as colored rects (current placeholders).

## Characters
- Odysseus: compact hero sprite, clear walk cycle, exaggerated click-to-move readability.
- Polyphemus: oversized cave silhouette, single glowing eye (red → ruined after the stake).
- Sheep: fluffy blocking shapes; ram used for escape gag should read instantly.

## Rooms
- **Painterly backgrounds** with strong warm cave light vs. cool shore sky.
- Depth via parallax bands (sky / cliff / surf) once art lands.
- Interactive props slightly oversaturated so verbs feel fair.

## UI
- Verb bar like SCUMM: chunky buttons, high-contrast labels.
- Inventory as labeled tokens (icons later).
- Dialogue in a parchment panel; speaker name in gold.

## Placeholders
Until final art: solid `ColorRect`s + `Label`s are intentional and shippable for puzzle QA.
