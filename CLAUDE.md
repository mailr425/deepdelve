# Deepdelve

A first-person, real-time dungeon crawler on a tile map (Legend of Grimrock / Dungeon Master style),
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
- Gear: weapon (`H.weapon`), off-hand (`H.shield`) and `H.eq` = head, neck, chest, arms, lwrist, rwrist, hands, legs,
  feet, ring1, ring2. Armor pieces carry `sl` (slot) and decimal armor (`pieceA`); jewelry is `kind:'j'` (`jt` ring/neck),
  always magic. Armor-type rules (metal hurts stealth/dodge, cloth helps casters and martial, perks) scale with
  `armShare(type)`. Use `slotItem`/`setSlot`/`targetSlot`/`equip` rather than touching slots directly. Items in the
  pack have `gx/gy`; add them with `bagAdd`/`stash` (never `H.bag.push`), check room with `bagFits`.
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
| GEAR SLOTS | `SLOTDEF` (armor pieces: share of a full suit `sh`, affix strength `am`), `EQSLOTS`, `APIECE` names, jewelry `JMAT`, `armShare(type)` (mixed armor by weight), `setupEq` (slots, save migration, `H.armor` = chest accessor) |
| INVENTORY | `openBag`: paperdoll (`DOLLSLOTS`) + `drawAvatar`, `invStats`, backpack grid (`BAGW`x`BAGH`, `isz`, `bagGrid`, `fitsAt`, `findSpot`, `bagAdd`, `stash`), drag and drop (`IDR`), `invEquipBag`, `invUnequip` |
| SKILLS & PERKS | `SKILLS` (19 combat), `CRAFT_SK` (7 crafting), `PERKS`, `train`, `skNeed` |
| SPELLS | `SPELLS` (Holy, Nature, Arcane; 3 each), `cast` |
| BALANCE | `BAL`: every difficulty knob in one object |
| STATE | `H` (hero, saved) and `G` (current floor), save/load, `migrateHero` |
| GENERATION | Random floor carving, monster and loot placement, the guardian |
| FLOW | Descend, floor clear, return to camp, `die` |
| ACTIONS | `attack`/`strike`, ranged, sneak, pickup, potions (`tryMove`/`turn` are legacy grid moves) |
| MONSTERS | `monstersAct`: facing, vision cones, sleep, chase, `monAttack` |
| AUDIO / MUSIC | `SFX`, `TRACKS`, `setMusic`, chiptune voices, the Karplus-Strong camp guitar |
| RENDERER | `render(now)`: 160 px wide raycaster, floor/ceiling casting, Bayer-dithered light, sprites |
| HUD / MAP, SCREENS | HUD, minimap, log, title, slot picker, character sheet, death screen |
| GEAR ICONS | `gearIconTex`: procedural item icons |
| CAMP | `CAMP_MAP`, `enterCamp`, NPC visitors (`MERCH`, `EVENTS`), trainer, stash |
| MATERIALS & CRAFTING | `MATCAT`, `STATIONS`, `ELIXIRS`, `craftGear`, salvage, enchant, spellcraft |
| INPUT | Buttons, swipes, keys; the `ovT` guard that stops taps falling through overlays |
| REAL-TIME MOVEMENT | `RT` (tick, speed, turn rate, collision radius), `rtUpdate` (free movement, collision, world clock), `rtAttack` (weapon cooldowns, auto-aim at adjacent foes), `drawWeapon` (weapon in view) |
| SETTINGS | `SET` (saved as `deepdelve_settings`): resolution preset, brightness, UI scale, layout, flashes, volumes; `applyVideo`, `applyAudio`, audio buses `BUS.mus` / `BUS.sfx` |
| MAIN MENU / OPTIONS | Escape menu: `openMenu(tab)` with main, sound, video, controls and saves tabs |
| SAVE TRANSFER | Save codes `DDSAVE1:<z|p>:<base64>` (gzip via CompressionStream): `packSave`, `unpackSave`, export/import UI (`SV`, `saveCmd`) |
| CONTROLLER | Gamepad API polling (`padLoop`): buttons map onto `ACT` in the dungeon; in overlays the d-pad moves a `.padfocus` highlight (spatial nav), A clicks, B backs out, Start toggles the menu |
| BOOT | Font, service worker, title screen |

Facing codes are 0=N, 1=E, 2=S, 3=W, with `DX=[0,1,0,-1]` and `DY=[-1,0,1,0]`.

## Real-time model

- The hero moves freely: `P.px/P.py` (tile units, tile centre = x+.5) and `P.a` (view angle, 0 = north,
  `fx=sin(a)`, `fy=-cos(a)`). `P.x/P.y` is the tile under the hero and `P.dir` the nearest facing, so all
  grid rules (items, doors, stairs, stealth, monster adjacency) still work. Code that teleports the hero
  just sets `P.x/P.y`; `rtUpdate` notices and re-syncs.
- The world advances every `RT.tick` ms (700) through `worldTick()` (monsters act, regen, autosave every
  4 ticks), and pauses while any overlay is open. `endTurn()` is now a light HUD refresh.
- Monsters move freely every frame (`monUpdate`): `m.px/m.py` is their position, `m.x/m.y` the tile under them.
  They steer along the shortest path (straight at you when close and in sight), keep apart from each other,
  and telegraph attacks: a wind-up (`m.wind`, attack frame + red glow + growl, `MON.wind` ms) after which the
  blow lands only if you are still within `MON.reach`. The world tick (`monstersAct`) now only handles
  noticing/waking/losing track and status-effect countdowns.
- Aiming: melee hits the foe nearest the crosshair within reach (`meleeTarget`); bows, thrown weapons and bolt
  spells fly along the crosshair ray (`lineMons`).
- Hit feedback: `shake(amp,ms)` on taking damage, and hit-stop (`HS`, world frozen ~70-160 ms) on crits and kills.
- Minimap: corner map in the modern HUD (`SET.mini`, TAB toggles). M opens and closes the full map.
- Look info (`lookTarget`, `drawLookInfo`): a name card (station + craft skill, merchant name + wares, door, stairs,
  gate) above the [E] prompt, and the name + health bar of the foe under the crosshair at the top of the view.
- Player attacks use per-weapon cooldowns (`weaponCD`, about one tick). Nothing happens on collision: doors, NPCs,
  stations, the gate and stairs are used with USE (E key, B on a controller, the USE button, or tapping the
  view). A prompt like `[E] OPEN` shows in the view when something is usable (`useMode`).
- HUD: `body.imm` (default, `SET.hud`) is the modern full-screen layout: compass strip (`drawCompass`), crosshair,
  fading notifications (the `#log` restyled), bars + XP, weapon box (left) and readied-spell box (right) around the
  hotbar (`immHud`, `hotbarSlots`, `hotbarUse`; keys 1-9: 1 = potion, 2+ = spells;
  mouse wheel cycles spells, right-click casts). `body.touch` (coarse pointer) shows the stick and action buttons
  over the view; on PCs the cursor only exists in menus (`tryLock` re-captures the mouse after any click/key while
  playing). `SET.hud='classic'` restores the original panel layout.
- Look up/down is a y-shear: the horizon `HZ` moves by `P.pitch*F` (clamped to `PITCH_MAX`).
- Escape: in fullscreen started from the menu, Chrome/Edge's Keyboard Lock passes Escape to the game
  (hold Escape to leave fullscreen). Opening any overlay releases pointer lock (`show()`).

## Balance

All difficulty lives in `BAL` (plus `RT.tick` and `weaponCD` for pacing). For real time, `python test/playtest.py 120`
runs a bot (`test/rtbot.js`) that explores and fights from floor 1. NOTE: the bot simulator below was
written for the turn-based version (tag `turn-based-v16`) and needs updating for real time.
To check a change, run the bot simulator:

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
