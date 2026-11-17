@echo off
rem Creates the v0.N version tags on past commits and pushes them to GitHub.
rem Run once from the repo folder (tag pushes are blocked from the Claude sandbox).
cd /d "%~dp0\.."
git pull --ff-only
git tag -f v0.16 c54559b
git tag -f v0.17 af9c9ac
git tag -f v0.18 48dd430
git tag -f v0.19 1db1be6
git tag -f v0.20 8324d51
git tag -f v0.21 922a1f2
git tag -f v0.22 9135fe9
git tag -f v0.23 61bcb77
git tag -f v0.24 7a7db8e
git tag -f v0.25 444a768
git tag -f v0.26 ddd8d03
git tag -f v0.27 f93f6a1
git tag -f v0.28 83935c0
git tag -f turn-based-v16 af9c9ac
git push origin --tags
pause
