"""Real-time playtest bot. Plays a fresh hero from floor 1 for N seconds (explore, fight,
drink potions, open doors, take the stairs) and prints what happened.
Usage: python test/playtest.py [seconds]   (needs: pip install playwright; playwright install chromium)
Note: headless browsers render slowly, so game time runs a bit slower than real time here."""
import asyncio, json, pathlib, sys
from playwright.async_api import async_playwright

ROOT = pathlib.Path(__file__).resolve().parent
GAME = ROOT.parent.joinpath("index.html").as_uri()


async def main(secs: int) -> None:
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(viewport={"width": 800, "height": 600})
        errors = []
        pg.on("pageerror", lambda e: errors.append(str(e)))
        await pg.goto(GAME)
        await pg.evaluate("localStorage.clear();localStorage.setItem('deepdelve_settings',JSON.stringify({res:'retro',fsStart:0}))")
        await pg.reload()
        await pg.wait_for_timeout(400)
        await pg.click("[data-cmd=newslot]")
        await pg.wait_for_timeout(600)
        await pg.evaluate("hideAll();startRun(1)")
        await pg.add_script_tag(path=str(ROOT / "rtbot.js"))
        await pg.evaluate("BOT.floorStart=performance.now()")
        for i in range(max(1, secs // 5)):
            await pg.wait_for_timeout(5000)
            st = await pg.evaluate("[BOT.on,G&&G.depth,G&&G.P.hp,G&&G.kills,H&&H.lvl,H&&H.potions]")
            print(f"{(i+1)*5:4d}s  alive={st[0]} floor={st[1]} hp={st[2]} kills={st[3]} lvl={st[4]} potions={st[5]}", flush=True)
            if not st[0]:
                break
        print(json.dumps(await pg.evaluate("BOT.log"), indent=1))
        if errors:
            print("JS ERRORS:", errors[:5])
        await b.close()


asyncio.run(main(int(sys.argv[1]) if len(sys.argv) > 1 else 120))
