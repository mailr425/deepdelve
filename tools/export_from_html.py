import asyncio, json, base64, os, sys, pathlib
from playwright.async_api import async_playwright
# Usage: python tools/export_from_html.py reference/deepdelve.html .
#   Rewrites data/game_data.json and assets/art/** from the browser build.
#   Needs: pip install playwright && playwright install chromium
HTML=pathlib.Path(sys.argv[1]).resolve().as_uri()
OUT=sys.argv[2] if len(sys.argv)>2 else '.'
JS=r"""()=>{
const out={tex:{},data:{}};
const FR={'':'_idle1','_i':'_idle2','_a':'_attack','_b':'_back1','_bi':'_back2'};const U=t=>t&&t.w?texURL(t):null;
TX.walls.forEach((t,i)=>out.tex['env/wall_'+i]=U(t));
for(const k of ['door','floor','ceil','stairs','stairsS'])out.tex['env/'+k]=U(TX[k]);
for(const k in TEX)out.tex['items/'+k]=U(TEX[k]);
for(const k in MONTEX){const f=MONTEX[k];for(const n in f){const u=U(f[n]);if(u)out.tex['monsters/'+k+FR[n]]=u}}
for(const k in MONSPR){for(const n in MONTEX[k]){try{const u=U(bossTex(k,n));if(u)out.tex['bosses/'+k+FR[n]]=u}catch(e){}}}
try{for(const k in NPCTEX){const u=U(NPCTEX[k]);if(u)out.tex['npcs/'+k]=u}}catch(e){}
const fn=v=>typeof v==='function'?v.toString().replace(/^\(?t\)?=>/,'').replace(/Math\./g,'').replace(/(^|[^0-9])\.(\d)/g,'$10.$2'):v;
const clean=o=>JSON.parse(JSON.stringify(o,(k,v)=>typeof v==='function'?fn(v):v));
const names=['BAL','TIERS','WTYPES','WVAR','ATYPES','ATRAIT','MATS','SHIELDS','AFFIX','SKILLS','CRAFT_SK','PERKS','SPELLS','MONS','STATIONS','MATCAT','ELIXIRS','MERCH','EVENTS','CAMP_MAP','RARNAME','DX','DY'];
for(const n of names){try{out.data[n]=clean(eval(n))}catch(e){out.data[n]='ERR '+e}}
const C={};for(const n of ['UPMAX','POTION_COST','POTION_MAX','TRAIN_CAP','BAG_MAX','SLOTS','GATE','COX','COY']){try{C[n]=eval(n)}catch(e){}}out.data.CONST=C;
return out}"""
async def main():
  async with async_playwright() as p:
    b=await p.chromium.launch(); pg=await b.new_page()
    await pg.goto(HTML); await pg.wait_for_timeout(800)
    r=await pg.evaluate(JS); await b.close()
  for k,u in r['tex'].items():
    if not u: continue
    path=os.path.join(OUT,'assets','art',k+'.png'); os.makedirs(os.path.dirname(path),exist_ok=True)
    open(path,'wb').write(base64.b64decode(u.split(',')[1]))
  os.makedirs(os.path.join(OUT,'data'),exist_ok=True)
  for k,v in r['data'].items():
    if isinstance(v,str) and v.startswith('ERR'): print('miss',k,v); continue
  json.dump({k:v for k,v in r['data'].items() if not(isinstance(v,str) and v.startswith('ERR'))},open(os.path.join(OUT,'data','game_data.json'),'w'),indent=1)
  print(len(r['tex']),'textures')
asyncio.run(main())
