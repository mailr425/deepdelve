@echo off
rem Opens Deepdelve in its own window with Microsoft Edge (built into Windows).
rem First grabs the latest version from GitHub, if Git is installed and you have no unsaved local edits.
cd /d "%~dp0"
where git >nul 2>nul && git pull --ff-only --quiet
rem Saves made here stay on this PC (they are separate from the hosted version).
start "" msedge --app="file:///%~dp0index.html" --window-size=440,900
