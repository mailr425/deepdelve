# Deepdelve changelog

How Deepdelve got from a first playable crawler to where it is now, newest first, with the feedback or
finding behind each change. Lessons learned are collected at the bottom.

**Keeping this up to date:** every change that a player would notice gets a line here in the same commit.
Say what changed and why. If something went wrong along the way or we learned something about the tools, add it to Lessons learned.

Builds v1-v16 were made on an iPhone on claude.ai (Nov 15-16, 2026), before the GitHub repo existed. Their
code is the first commit (`c54559b`). From v17 on, every build is a commit, so `git log` has the details.

---

## Builds in the repo

### v28: Skills & perks tab (Nov 17, `9f49b66`)
- Inventory and Skills & Perks are now two tabs in one window. The tab shows unspent perk points, and skills are laid out in five columns on wide screens.
- Pressing I or K opens that tab, and pressing it again closes the window. HERO, the bedroll and the weapon box open the skills tab.
- *Why:* a separate character screen felt disconnected; skills and gear belong together, like in Diablo.

### v27: Inventory fits the screen (Nov 17, `f93f6a1`)
- Landscape layout: paperdoll, stats and backpack sit side by side. The panel scales itself to fit the window and re-fits on resize. Phones keep the stacked, scrollable layout.
- Starter tunic armor restored to 1.
- *Why:* you had to scroll the inventory on a PC.

### v26: Gear slots, jewelry, Diablo-style inventory (Nov 17, `ddd8d03`)
- Armor is now separate pieces: head, chest, arms, both wrists (bracers), hands, legs and feet, plus two rings and a necklace. Jewelry is always magic.
- A full suit adds up to what one suit of armor gave before. Smaller pieces carry weaker affixes.
- Mixed armor counts by weight share (cloth 1, leather 2, metal 3), so stealth, dodge, caster/martial bonuses and armor perks scale with how much of each type you wear.
- Paperdoll with a pixel avatar dressed in your gear, a stats panel with numbers and percentages, and a 10x5 backpack where items have sizes.
  - Drag items to move or equip them; right-click or double-click to quick-equip.
- Crafting recipes for every piece. The Armorer sells pieces, the Mystic sells jewelry.
- Old saves: the old suit becomes the chest piece plus a matching set of the same tier. Pack items that don't fit the new grid move to the stash.
- *Why:* the inventory read like a list; we wanted Diablo-style slots, sized items and visible character stats.

### v25: Show what you're looking at (Nov 17, `444a768`)
- A name card above the [E] prompt for crafting stations (with your craft skill), merchants and visitors (name and wares), camp staff, doors, stairs and the gate.
- The foe under the crosshair shows its name, awareness and a health bar.
- *Why:* you couldn't tell which crafting table or merchant was which.

### v24: Real-time combat overhaul (Nov 16, `7a7db8e`)
- Monsters move freely, surround you, path around walls and wind up before attacking. They show an attack pose, a red glow and a growl, so you can step back and make them miss.
- Melee hits the foe nearest the crosshair. Bows, thrown weapons and bolt spells fly along the crosshair.
- Screen shake when you're hit, and hit-stop on crits and kills.
- Starting health 26 → 32. Corner minimap (TAB). M opens *and* closes the map.
- *Why:* playtest bot finding: right after the real-time switch, 2 of 3 bot runs died on floor 1. Monsters
  hit with no warning and still moved like turn-based pieces.

### Tooling: real-time playtest bot (Nov 16, `7f93766`)
- `test/playtest.py` + `test/rtbot.js`: a bot plays a fresh hero in real time and reports what happened.
- The frame-time clamp was raised so a low frame rate no longer slows the world down.

### v23: Death animations and persistent corpses (Nov 16, `61bcb77`)
- Monsters flash, get knocked back, topple and stay on the floor as darkened corpses. Rats and spiders end up belly-up. Corpses are saved with the floor.
- The camp sky is now a fixed dome sampled by view angle, so the stars stay put.
- *Why:* in real time, monsters vanishing on death felt cheap. The sky slid along with the camera.

### v22: Native resolution and fullscreen by default (Nov 16, `9135fe9`)
- PCs default to native resolution; phones and tablets default to HD for speed.
- "Start in fullscreen" is on by default and kicks in on your first click, tap or key press. `play.bat` launches Edge fullscreen.

### v21: HUD scaling, weapon and spell boxes (Nov 16, `922a1f2`)
- The HUD scales from one CSS variable instead of CSS `zoom`. This fixed uneven text and misplaced click targets at 1080p.
- Weapon box (name underneath) on the left of the hotbar, readied-spell box on the right. Hotbar: 1 = potion, 2+ = spells.

### v20: Modern HUD (Nov 16, `8324d51`)
- Full-screen view, crosshair, Skyrim-style compass, fading notifications, bars, an XP strip and a hotbar. The classic layout is kept as an option.
- PC: the cursor only appears in menus. Click-and-drag look is gone.
- *Why:* the game should feel like Minecraft/Skyrim, not a classic CRPG panel.

### v19: Look up/down, E to interact, quit (Nov 16, `1db1be6`)
- Look up and down, with an invert option.
- E interacts with doors, NPCs, stations, the gate and stairs. Walking into things no longer uses them. An [E] prompt shows when something is usable.
- Q/E no longer turn. QUIT GAME added. Fullscreen started from the menu keeps Escape for the game; hold Escape to leave.

### Tooling: auto-sync (Nov 16, `ab73afe`)
- `play.bat` pulls the latest version before launching. `autosync.bat` pulls every 60 seconds. Both only fast-forward.

### v18: Real-time play (Nov 16, `48dd430`)
- Turn-based play is replaced entirely by free movement: WASD + mouse, a virtual stick + drag on touch, analog sticks on a controller.
- The world runs on a 700 ms clock and pauses in menus. Weapons have per-weapon cooldowns.
- The weapon is drawn in view with a walk bob and a swing. FOV and look sensitivity settings added.
- Jumping was considered and dropped.
- *Why:* the big swing: fluid movement and animated attacks. The last turn-based build is commit `af9c9ac`.

### v17: Save transfer and controller (Nov 16, `af9c9ac`)
- Export a hero as a compressed save code (copy, share or download) and import it on another device.
- Gamepad support: play with any standard controller, d-pad/A/B navigate every menu, Start opens the menu.

### v16 + options: first repo commit (Nov 16, `c54559b`)
- The game moved from the phone to a PC and onto GitHub Pages.
- Added the Escape main menu (sound, video and controls tabs) and native-resolution rendering.
- *Why:* an auto-converted Godot port came out as a shell of the real game, so we kept developing in the browser (see Lessons learned).

---

## Builds before the repo (v1-v16, Nov 15-16, made on an iPhone)

| Build | What changed | Why |
| --- | --- | --- |
| v16 | Gi (fighter cloth armor); bonus for martial fighters in cloth; bo staff; wizard staff; cleric's mace; Fletching renamed Woodworking, staves made there | Martial needed a cloth identity; requests for staves and caster weapons |
| v15 | Phase 3b: 7 crafting stations and skills, 6 materials in 9 grades, salvaging, enchanting, spell empowerment; deep floors retuned | Crafting phase; the late game was too easy in simulation |
| v14 | Throwing knives, shurikens, handwraps; item cards show skills used and armor build effects | More thrown/martial weapons, clearer cards |
| v13 | Camp music rebuilt (warm 12-string guitar, reverb); material-tinted gear icons with rarity frames | Camp music was loud and harpsichord-like; gear needed real icons |
| v12 | Phase 3a: walkable camp (palisade, night sky, campfire), trainer, quartermaster, stash, gate, bedroll; Bazaar-style visitors (pick 1 of 3) | Camp should be a place, not a menu |
| v11 | Tap-to-expand log removed | It popped open by accident |
| v10 | Death animations (flash, squash, dither fade), blood spray and stains, bouncing loot; armor materials per type | Requests for juice; "Iron Robe" naming bug |
| v9 | Sleeping monsters, steadier idle facing, full log viewer | Monster backs were rarely visible; wanted to read the log |
| v8 | Scrollable log with a LATEST button | Wanted to scroll back |
| v7 | Sneak toggle, monster facing + vision cones, back sprites, losing track; metal hurts sneaking; one-tap casting; 5 retrievable javelins; calmer boss music | Stealth unclear, javelins overpowered, casting clunky |
| v6 | Phase 2: 19 use-based skills, perks, weapon/armor types, shields, ranged, 9 spells and mana, magic/rare items, character sheet, sneak multipliers; 8-bit metal soundtrack | Elder Scrolls-style progression |
| v5 | Phase 1: loot fix (gear stopped improving past floor ~12), difficulty reshaped (hard start, eases), redrawn monsters, minimap arrow, 3 save slots | 6-hour playtest feedback |
| v4 | Clearing a floor returns you to camp; clearer merchant; new rat and skeleton; procedural chiptune | The continue/return choice had no risk or reward |
| v3 | Built-in pixel font, no network, offline service worker | Playing on a flight |
| v2 | Low-res raycaster, pixel textures, dithered light, pixel monsters, guardians, camp upgrades, persistent hero | More classic look; roguelite progression |
| v1 | First playable: grid movement, touch + swipes, turn-based combat, 9 monsters, loot, random floors, minimap, autosave | An Arena/Daggerfall-style crawler for iPhone |

---

## Lessons learned

### Process
- **A playtest bot pays for itself.** It caught the late-game ease in v15 and the floor-1 death spike after the real-time switch, both before a human hit them.
- **Big rewrites rot the tests.** `test/curve.py` (balance simulator) and `test/camp.py` still assume turn-based play and the old camp layout. When the mechanics change, update or retire the tests in the same change.
- **Porting by auto-translation doesn't work.** The first Godot port lost most of the game. If we port, we move the rules and data (tables in JSON via `tools/export_from_html.py`) and rebuild the presentation natively. We don't translate the renderer line by line.
- **History belongs in the repo.** v1-v16 lived only in a claude.ai doc. This file exists so the story travels with the code.
- **Commit small, one feature per commit.** Every bad change is then one `git revert` away. We record commit hashes here, because pushing tags through the sandbox proxy failed.

### Browser and engine gotchas
- **CSS `zoom` breaks click targets** on positioned elements. Scale with `calc(px * var(--u))` instead.
- **Fullscreen and Keyboard Lock need a user gesture.** Escape only stays with the game in Chrome/Edge when fullscreen is entered from inside the page with `navigator.keyboard.lock`. F11 fullscreen can't keep it.
- **Sample skies by view angle, not by screen row.** Row-based sampling skewed when looking up and down, and clamping made streaks.
- **Clamp frame time generously.** A tight clamp made the whole world run slow on slow devices.
- **Collision-triggered interaction is a trap in real time.** Bumping a door or NPC by accident opened it. An explicit USE button fixed that.
- **Real time needs telegraphs.** Instant monster hits in real time feel unfair. A visible wind-up you can dodge fixes it.
- **Grid math: `Math.floor`, not `Math.round`,** when turning a pixel position into a grid cell (the drag-and-drop bug).
- **Check return shapes.** `gearIconTex` returns `{tex, u}`. Using it as a texture crashed the weapon box.

### Saves
- **Every data-shape change needs a migration** in `migrateHero` / `setupEq`, and it should be tested on an old save. The armor-suit → pieces split worked because we turned the old suit into a chest piece plus a matching set, and overflowed the pack into the stash instead of deleting items.

### Setup (Windows)
- After installing Git, **reopen PowerShell** so it's on PATH.
- When pasting several commands, check they ran in order.
