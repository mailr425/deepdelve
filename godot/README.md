# Deepdelve: Godot port (paused)

On hold while development continues on the browser game in the parent folder.


The Godot 4 port of the browser dungeon crawler. This starter is stage 1 of the porting plan:
you can walk a test dungeon in real 3D with chunky pixels and open doors. Four monsters stand in
it, and you can strike them down (combat comes in stage 4). The full game data and placeholder
art are already in the project.

## First run (about 10 minutes)

1. Install **Godot 4, Standard build** (not .NET) from godotengine.org. Unzip it anywhere, for
   example `C:\Tools\Godot\`.
2. Unzip this folder somewhere permanent, for example `C:\Dev\Deepdelve\`.
3. Open Godot, click **Import**, choose `C:\Dev\Deepdelve\project.godot`, then **Import & Edit**.
   The first import takes a minute while it processes the art. If it asks to convert or upgrade
   the project, say yes.
4. Press **F5** (or the play button at the top right).

Controls:
- **Keyboard:** W/S move, A/D strafe, Q/E or the arrow keys turn, Space attacks.
- **Controller:** the d-pad or left stick moves, the shoulder buttons or right stick turn, A attacks.
- **Mouse or touch:** swipe on the view; swipe left turns left, swipe up steps forward, and a tap attacks.
- **On screen:** the nine buttons at the bottom.

If something errors on first run, open the **Output** panel at the bottom, copy the red lines, and
paste them to Claude. This starter was written without a Godot install to test against.

## Set up Git and Claude Code

```
cd C:\Dev\Deepdelve
git init
git add .
git commit -m "Godot starter (stage 1)"
```

Install Claude Code (see docs.claude.com), then run `claude` in this folder. It reads `CLAUDE.md`
automatically, which explains the project, the conventions and the porting stages. A good first ask:

> Read CLAUDE.md, then do stage 2: port the GENERATION section of ../index.html
> into scripts/dungeon_gen.gd so each floor is random, using the same map format Dungeon.build() takes.

Optional: in the handoff doc on claude.ai, use Export → Markdown and save it as
`HANDOFF.md`. It holds the full build history and design spec.

## Android (later)

Install OpenJDK 17 and Android Studio (for the SDK). Then in Godot, set both paths under
Editor → Editor Settings → Export → Android, and add an Android preset under Project → Export.
Plug in your phone with USB debugging on, and use the one-click deploy button. iOS needs a Mac with
Xcode, so leave it for near the end.
