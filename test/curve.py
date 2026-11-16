import os, pathlib
import asyncio, json, sys
from playwright.async_api import async_playwright
BOT=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'bot.js')).read()
async def main():
    bal=sys.argv[1] if len(sys.argv)>1 else '{}'
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await (await b.new_context(viewport={'width':390,'height':844})).new_page()
        errs=[]; pg.on('pageerror', lambda e: errs.append(str(e)))
        await pg.goto(pathlib.Path(__file__).resolve().parent.parent.joinpath('index.html').as_uri()); await pg.wait_for_timeout(300)
        await pg.evaluate(f"Object.assign(BAL,{bal})")
        agg={}
        for hero in range(3):
            res=await pg.evaluate(BOT, 30)
            for f,(att,hp) in res['floors'].items():
                a=agg.setdefault(int(f),[0,0,0]); a[0]+=att; a[1]+=hp; a[2]+=1
            print('hero',hero,'reached',res['reached'],'runs',res['runs'],'lvl',res['lvl'],'gear',res['gear'],'craftsk',res.get('cs'))
        print('floor: avgAttempts avgEndHP%')
        line=[]
        for f in sorted(agg):
            a=agg[f]; line.append(f"{f}:{a[0]/a[2]:.1f}/{int(100*a[1]/a[2])}%")
        print('  '.join(line))
        print('ERRS',errs[:3])
        await b.close()
asyncio.run(main())
