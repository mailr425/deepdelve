"""Quick check after an edit: loads index.html headless, starts a game, and
reports any JavaScript errors. Usage: python test/smoke.py
Needs: pip install playwright  and  playwright install chromium
"""
import asyncio
import pathlib
from playwright.async_api import async_playwright

GAME = pathlib.Path(__file__).resolve().parent.parent.joinpath("index.html").as_uri()


async def main() -> None:
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(viewport={"width": 390, "height": 844})
        errors = []
        page.on("pageerror", lambda e: errors.append(str(e)))
        page.on("console", lambda m: errors.append(m.text) if m.type == "error" else None)
        await page.goto(GAME)
        await page.wait_for_timeout(1000)
        shot = pathlib.Path(__file__).with_name("smoke.png")
        await page.screenshot(path=str(shot))
        await browser.close()
    if errors:
        print("ERRORS:")
        for e in errors:
            print("  ", e)
        raise SystemExit(1)
    print(f"OK: no errors. Screenshot: {shot}")


asyncio.run(main())
