# Deepdelve (Godot 4 port) - PAUSED

This port is on hold; the main project is the browser game one folder up (`../index.html`).
It was started as stage 1 of 11 and is kept here for later.

First-person, turn-based, grid dungeon crawler (Eye of the Beholder / Legend of Grimrock style).
It is being ported from a finished single-file browser build, `../index.html` (v16).
Targets: Windows first, then Android, then iOS. Portrait, touch-first; keyboard and controller too.

## Ground rules

- `../index.html` is the source of truth for rules and numbers. When porting a system,
  read the matching section there first and keep the numbers identical unless asked to change them.
  The file is marked with `// ===== SECTION =====` headers (ITEMS, SKILLS & PERKS, MONSTERS, ...).
- Port the rules, not the renderer. The JS raycaster, canvas drawing and WebAudio synth are replaced
  by Godot's 3D scene, sprites and AudioStreamPlayers.
- GDScript only (no C#). Godot 4 syntax, static types where reasonable.
- Keep tunable numbers in `data/game_data.json` (`BAL` and the tables), not hard-coded in scripts.
- Commit after each working stage.

## Layout

| Path | What |
| --- | --- |
| `project.godot` | Pixel settings: 320x480 base, viewport stretch, integer scale, nearest filtering, Compatibility renderer |
| `autoload/controls.gd` | Registers every Input Map action (keys, controller buttons, sticks) |
| `autoload/data.gd` | Loads `data/game_data.json`: `Data.BAL`, `Data.table("MONS")`, `Data.affix_value()` |
| `autoload/hero.gd` | The persistent hero (JS `H`), JSON save slots in `user://slot_N.json`, `train()` |
| `scenes/main.tscn` + `scripts/main.gd` | Game screen: 160x120 SubViewport shown at 2x, log, minimap, touch pad, swipes |
| `scripts/dungeon.gd` | 3D grid: builds one ArrayMesh from a text map, camera step/turn tweens, monsters as Sprite3D billboards |
| `scripts/minimap.gd` | Minimap with facing arrow |
| `data/game_data.json` | Every table from the JS: BAL, TIERS, WTYPES, WVAR, ATYPES, MATS, SHIELDS, AFFIX, SKILLS, CRAFT_SK, PERKS, SPELLS, MONS, STATIONS, MATCAT, ELIXIRS, MERCH, EVENTS, CAMP_MAP, CONST |
| `assets/art/` | Placeholder art exported from the browser build: `env/` walls/floor/ceiling/door/stairs (32px), `monsters/` and `bosses/` (24px; frames `_idle1 _idle2 _attack _back1 _back2`), `items/` |
| `assets/fonts/delve.ttf` | 5x7 pixel font, 10 px to the em (use size 10 or 20) |
| `tools/export_from_html.py` | Re-exports data and art from the browser game: `python tools/export_from_html.py ../index.html .` |

## Conventions that must match the JS

- Facing: 0=N, 1=E, 2=S, 3=W. `Data.DX = [0,1,0,-1]`, `Data.DY = [-1,0,1,0]`.
- World axes: map x -> +X, map y -> +Z, so north is -Z. One tile = 1 unit, wall height 1.1, eye 0.5.
- JSON numbers load as floats: wrap with `int()` for tiers, counts and indices.
- AFFIX values are expression strings of the tier `t` (for example `2+floor(t*0.8)`); use `Data.affix_value(expr, tier)`.
- Skill XP to next level: `round(4 + 0.8 * level)` (`Data.skill_need`). Perks at 25 and 50; 75/100 add +15%/+25%.
- Death keeps level, skills, perks, equipped gear and training; loses half the carried gold and
  materials, all potions and the pack.

## Porting stages

1. DONE (starter): walk a test room; step/turn tweens; touch, swipe, keyboard, controller.
2. Generate floors: port the GENERATION section into `scripts/dungeon_gen.gd` producing the same
   text-map format `Dungeon.build()` takes; explored-tiles minimap; stairs/exit.
3. Data and hero: slot picker screen, `newHero`/`migrateHero`/`ensureSkills` from the STATE section.
4. Combat: turn manager, `attack`/`strike`, monster turns (`monstersAct`), hit rolls, damage floats, death.
5. Loot and gear: `rollGear`, item cards, equip, pack (12 slots).
6. Skills, perks, spells, stealth (facing, vision cones, sneak multipliers, back sprites).
7. Floor guardian and death screen (roguelite keep/lose rules).
8. Camp: walkable room from `CAMP_MAP`, visitors (MERCH/EVENTS, pick one of three), trainer, stash.
9. Crafting: stations, materials, elixirs, enchanting, spellcraft.
10. Balance check against `../test/curve.py` results.
11. Art pack, audio, Android build, then the backlog (Phase 4 labyrinth quests, Phase 5 Trunelro towns).

## Known loose ends from the browser build

- Floors 27-30 may be a little easy (sim ended at ~65-90% HP). Nudge `deepDmg`/`deepHit`.
- `the old camp test` uses camp coordinates from before the camp relayout.
- The starter was written without a Godot install to test against. If the first run shows errors,
  fix them before stage 2.
