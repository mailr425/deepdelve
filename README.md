# Deepdelve

A pixel dungeon crawler that runs anywhere there is a browser, with no install and no internet
needed. The whole game is `index.html`.

## Play it on this PC

Double-click **`play.bat`**. The game opens fullscreen through Microsoft Edge (F11 leaves fullscreen), with no tabs
or address bar. You can also just open `index.html` in any browser.

Keyboard: W/S move, A/D strafe, Q/E or the arrow keys turn. Or click the on-screen buttons.

Saves stay in the browser on each device. Your iPhone saves don't carry over to the PC, and saves
from `play.bat` are separate from saves on the hosted version below.

## Put it on everyone's devices (free, about 10 minutes)

Host it on GitHub Pages and install it like an app on any phone, tablet or PC:

1. Make a free account at github.com, then click **New repository**, name it `deepdelve`, and
   set it to Public.
2. Upload the contents of this folder: on the repo page, choose **Add file → Upload files** and
   drag everything in. Or use Git, below.
3. In the repo, go to **Settings → Pages**. Under "Branch" choose `main`, then **Save**.
4. After a minute the game is live at `https://<your-username>.github.io/deepdelve/`.
5. Install it:
   - **iPhone/iPad:** open the link in Safari, then Share → Add to Home Screen.
   - **Android:** open the link in Chrome, then the ⋮ menu → Install app (or Add to Home screen).
   - **PC:** open the link in Edge or Chrome, then click the install icon in the address bar.

It works offline after the first visit. When you push an update, devices pick it up the next time
they open the game online.

## Work on it with Claude Code

Install Git for Windows and Claude Code (docs.claude.com has the installer). Then:

```
cd C:\Dev\Deepdelve
git init
git add .
git commit -m "Deepdelve v16"
claude
```

Claude Code reads `CLAUDE.md` automatically. It covers how the game is organized, the rules for
editing it, the balance simulator and the backlog. Then just ask for things, for example:
"make goblins steal gold" or "add a fourth spell school". Double-click `play.bat` to try each change.

`CHANGELOG.md` is the build history from v1 on, with the reasons behind each change and lessons learned.
The handoff doc on claude.ai has the full design spec (export it as `HANDOFF.md` if you want it here).

## Folder

| Path | What |
| --- | --- |
| `CHANGELOG.md` | Every build, why it changed, and lessons learned |
| `index.html` | The game |
| `sw.js` | Offline support (keep next to `index.html`) |
| `manifest.webmanifest`, `icon-*.png` | Lets phones and PCs install it as an app |
| `play.bat` | Pulls the latest version from GitHub, then opens the game fullscreen (F11 leaves fullscreen) |
| `autosync.bat` | Keeps the folder in step with GitHub (pulls every 60 seconds while its window is open) |
| `CLAUDE.md` | Instructions for Claude Code |
| `test/` | `smoke.py` (quick error check) and `curve.py` + `bot.js` (balance simulator) |
| `tools/` | Font and sprite generators, data/art exporter |
| `godot/` | A paused Godot 4 port for the future (open `godot/project.godot` in Godot) |
