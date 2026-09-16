# Odyssey — Episode Map

Full voyage architecture for the Monkey Island–style point-and-click adaptation of Homer’s *Odyssey*.  
**Episode 1 (playable): Cyclops.** Later episodes are stubs in this map.

| # | Episode | Setting | Core puzzles / beats | Status |
|---|---------|---------|----------------------|--------|
| 0 | Leaving Troy / Ismarus | Beach camps, Cicones | Raid fallout, load ships, choose crew fate | Planned |
| 1 | Lotus-Eaters | Dreamy shore | Resist lotus, wake crew, leave before forgetting | Planned |
| 2 | **Cyclops** | Shore + Polyphemus’ cave | Stake, wine, “Nobody,” blind giant, escape under sheep | **Playable** |
| 3 | Aeolus | Floating island palace | Bag of winds; crew curiosity / storm relapse | Planned |
| 4 | Laestrygonians | Cliff harbor | Ambush giants; save one ship | Planned |
| 5 | Circe | Aeaea | Moly herb, men-as-swine, year of delay | Planned |
| 6 | Underworld | Edge of Oceanus | Blood rite, Tiresias, shades of the dead | Planned |
| 7 | Sirens | Open sea | Wax / mast; hear the song safely | Planned |
| 8 | Scylla & Charybdis | Strait | Choose losses; navigate the twin threats | Planned |
| 9 | Helios | Thrinacia | Forbid the cattle; starve vs. doom | Planned |
| 10 | Calypso | Ogygia | Seven years; raft; divine release | Planned |
| 11 | Phaeacia / Ithaca | Scheria → home | Games, disguise, bow, suitors | Planned |

## Cyclops (Episode 2) — design

### Rooms
1. **Shore & Cave Mouth** — ship, cave entrance, status of escape.
2. **Cave Interior** — Polyphemus, olive wood, fire, sheep, boulder door, exit.

### Flags (engine)
- `episode_started`, `entered_cave`
- `gave_nobody_name`, `revealed_true_name`
- `took_olive_wood`, `carved_stake`, `stake_heated`
- `polyphemus_drunk`, `polyphemus_asleep`, `polyphemus_blinded`
- `hiding_under_sheep`, `cave_open`, `cyclops_escaped`

### Inventory chain
`wine` (start) → `olive_wood` → `stake` → `hot_stake` → (consumed) → `sheep_disguise` → escape

### Victory
Blind Polyphemus, hide under a ram, use the boulder at dawn → return to shore → episode complete (hook toward Aeolus).

## Framework verbs
Walk to / Look at / Talk to / Use / Pick up / Give — plus inventory item selection for Use/Give.

## Art lock
Cyclops ships at **320×200** VGA / SCUMM MI2-era presentation (see `docs/ART.md`). Puzzle logic is independent of final paint.
