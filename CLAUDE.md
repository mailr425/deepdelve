# Deepdelve

A first-person, turn-based, grid dungeon crawler (Eye of the Beholder / Legend of Grimrock style),
built as a family learn-gamedev-with-AI project. The whole game is one file, `index.html`
(about 190 KB, no libraries, no network). It runs on phones, tablets and PCs, and works offline.

## Ground rules

- Keep it a single self-contained file: no external scripts, fonts, images or CDNs. Art is
  ASCII pixel data or procedural code; music and sound are WebAudio synths; the font is embedded base64.
- Keep it mobile-first: portrait, touch controls and swipes (swipe left turns left), 44 px or
  larger tap targets. Keyboard works too.
- Keep it offline: `sw.js` must sit next to `index.html`. Do not add anything that needs a server.
- Any new overlay buttons work with the controller automatically (they are found by query), as long as
  they are real `<button>` elements with `data-cmd`.
- Make small, surgical edits. The file is large, so use targeted edits, not rewrites.
- After a change, open the game and check for console errors. The quickest check is
  `python test/smoke.py`, which loads the page headless and reports errors.
- Resolution: the renderer draws `RW×RH` pixels; the preset sets pixels across the view's shorter
  side (classic = 160, the original look), capped at `RES_CAP` total pixels. New sounds must connect
  to `BUS.sfx` (or `BUS.mus` for music), never straight to `AC.destination`, so the volume sliders work.
- Saves live in localStorage (`deepdelve_slot_0..2`). Any new hero field needs a default in
  `migrateHero` / `ensureSkills` so old saves keep loading.
- Commit after each working change, with a clear message.

## Map of index.html

The script is split by `// ===== SECTION =====` headers. Search for the header to jump there.

| Section | What lives there |
| --- | --- |
| PIXEL ART | `SPR` item sprites, `MONSPR` monster sprites (24 px, mirrored halves, idle/attack/back frames), `TX` wall/floor textures |
| DATA | `MONS` monster table (hp, dmg, floor range, guardian names) |
| ITEMS | `TIERS`, `WTYPES`, `WVAR`, `ATYPES`, `SHIELDS`, `AFFIX`, `rollGear`, `wprop`, `gearDesc` |
| SKILLS & PERKS | `SKILLS` (19 combat), `CRAFT_SK` (7 crafting), `PERKS`, `train`, `skNeed` |
| SPELLS | `SPELLS` (Holy, Nature, Arcane; 3 each), `cast` |
| BALANCE | `BAL`: every difficulty knob in one object |
| STATE | `H` (hero, saved) and `G` (current floor), save/load, `migrateHero` |
| GENERATION | Random floor carving, monster and loot placement, the guardian |
| FLOW | Descend, floor clear, return to camp, `die` |
| ACTIONS | Move, turn, `attack`/`strike`, ranged, sneak, pickup, potions |
| MONSTERS | `monstersAct`: facing, vision cones, sleep, chase, `monAttack` |
| AUDIO / MUSIC | `SFX`, `TRACKS`, `setMusic`, chiptune voices, the Karplus-Strong camp guitar |
| RENDERER | `render(now)`: 160 px wide raycaster, floor/ceiling casting, Bayer-dithered light, sprites |
| HUD / MAP, SCREENS | HUD, minimap, log, title, slot picker, character sheet, death screen |
| GEAR ICONS | `gearIconTex`: procedural item icons |
| CAMP | `CAMP_MAP`, `enterCamp`, NPC visitors (`MERCH`, `EVENTS`), trainer, stash |
| MATERIALS & CRAFTING | `MATCAT`, `STATIONS`, `ELIXIRS`, `craftGear`, salvage, enchant, spellcraft |
| INPUT | Buttons, swipes, keys; the `ovT` guard that stops taps falling through overlays |
| SETTINGS | `SET` (saved as `deepdelve_settings`): resolution preset, brightness, UI scale, layout, flashes, volumes; `applyVideo`, `applyAudio`, audio buses `BUS.mus` / `BUS.sfx` |
| MAIN MENU / OPTIONS | Escape menu: `openMenu(tab)` with main, sound, video, controls and saves tabs |
| SAVE TRANSFER | Save codes `DDSAVE1:<z|p>:<base64>` (gzip via CompressionStream): `packSave`, `unpackSave`, export/import UI (`SV`, `saveCmd`) |
| CONTROLLER | Gamepad API polling (`padLoop`): buttons map onto `ACT` in the dungeon; in overlays the d-pad moves a `.padfocus` highlight (spatial nav), A clicks, B backs out, Start toggles the menu |
| BOOT | Font, service worker, title screen |

Facing codes are 0=N, 1=E, 2=S, 3=W, with `DX=[0,1,0,-1]` and `DY=[-1,0,1,0]`.

## Balance

All difficulty lives in `BAL`. To check a change, run the bot simulator:

```
python test/curve.py '{"deepDmg":1.6}'
```

It plays three heroes to floor 30 (crafting, brewing, spending perks, selling) and prints
average attempts and end-of-floor HP% per floor. Target: hard start, easing as the hero grows,
never trivial late. The last run had floors 27-30 ending at about 65-90% HP, possibly a touch easy.
It needs `pip install playwright` and then `playwright install chromium`.

## Tools

- `tools/mkfont.py` rebuilds the 5x7 Delve font (`pip install fonttools`). Paste the base64 into the `@font-face`.
- `tools/art.py` is the monster sprite source; it writes `sprites.json` and a preview sheet.
- `tools/export_from_html.py` exports all tables to JSON and all art to PNGs (used by the Godot port).

## Backlog

- Phase 4, a richer labyrinth: multi-floor quests (retrieve, rescue, slay), set-piece floors,
  environment variety by depth (caves, crypts, forges, the void), props and decals.
- Phase 5, Trunelro's towns: a surface hub with shops, guilds and quests; Renown; portals.
- Anytime: better art, player weapon animations, and
  `test/camp.py` from the old test set needs rewriting for the current camp layout.
- `godot/` holds a paused Godot 4 port (stage 1 of 11). Ignore it unless asked.

## Full history

The handoff doc on claude.ai has the full build log (v1-v16), the design spec with every number,
and the reasoning behind the design decisions. If `HANDOFF.md` exists in this folder, read it for context.
