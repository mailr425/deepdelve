@echo off
rem Opens Deepdelve in its own window with Microsoft Edge (built into Windows).
rem Saves made here stay on this PC (they are separate from the hosted version).
start "" msedge --app="file:///%~dp0index.html" --window-size=440,900
