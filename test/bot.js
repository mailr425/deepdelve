(target) => {
  H=newHero(); curSlot=2; window.__x=0; const floors={}; let runs=0;
  while(H.waypoint<=target && runs<70){
    runs++; const fl=H.waypoint; startRun(fl); let steps=0;
    while(G && !G.dead && steps<5000){
      steps++;
      const P=G.P, fx=P.x+DX[P.dir], fy=P.y+DY[P.dir];
      const adj=G.mons.find(m=>Math.abs(m.x-P.x)+Math.abs(m.y-P.y)===1);
      if(monAt(fx,fy)){ if(P.hp<maxHP()*0.35&&H.potions) quaff(); else attack(); continue;}
      if(adj){ for(let k=0;k<4;k++) if(adj.x-P.x===DX[k]&&adj.y-P.y===DY[k]){ while(P.dir!==k) turn(1);} continue;}
      if(P.hp<maxHP()*0.35&&H.potions){quaff();continue}
      if(cell(P.x,P.y)===STAIRS&&!G.sealed&&!itemsAt(P.x,P.y).length){ const f=floors[fl]||(floors[fl]=[0,0]); f[0]++; f[1]=P.hp/maxHP(); completeFloor(); break}
      const boss=G.mons.find(m=>m.boss);
      const d=bfs(G.map,P.x,P.y,t=>t!==WALL);
      let target=null,best=1e9;
      for(let y=0;y<MH;y++)for(let x=0;x<MW;x++){const i=idx(x,y); if(d[i]<0) continue;
        let sc=1e9;
        if(G.seen[i]&&G.map[i]===STAIRS) sc=d[i]-(G.sealed?0:1000);
        if(boss&&boss.x===x&&boss.y===y&&G.seen[i]&&P.hp>maxHP()*.6) sc=Math.min(sc,d[i]-500);
        if(!G.seen[i]) sc=Math.min(sc,d[i]);
        if(G.items.some(it=>it.x===x&&it.y===y)) sc=Math.min(sc,d[i]-5);
        if(sc<best){best=sc;target=[x,y];}}
      if(!target||(target[0]===P.x&&target[1]===P.y)){useAction();continue}
      const dt=bfs(G.map,target[0],target[1],t=>t!==WALL);
      let mv=-1,bd=dt[idx(P.x,P.y)];
      for(let k=0;k<4;k++){const v=dt[idx(P.x+DX[k],P.y+DY[k])]; if(v>=0&&v<bd){bd=v;mv=k}}
      if(mv<0){useAction();continue}
      while(P.dir!==mv) turn(1);
      tryMove(0);
    }
    if(G&&G.dead){const f=floors[fl]||(floors[fl]=[0,0]); f[0]++; f[1]+=0; }
    while(H.bag.length){const g=H.bag.pop(); H.bank+=sellVal(g)}
    // crafting: best gear of its own types, potions and elixirs
    {const wt=H.weapon.wt,wv=H.weapon.var,at=H.armor.at;
     for(const st in STATIONS){const S=STATIONS[st];if(!S.r)continue;S.r.forEach(([n,o],i)=>{
       if(!((o.kind==='w'&&o.wt===wt&&(!o.var||o.var===(wv||o.var)))||(o.kind==='a'&&o.at===at)))return;
       for(let ti=8;ti>=0;ti--){const k=matKey(S.mat,ti);if(matCount(k)>=craftCost(st,S.r[i][2])){const g=craftGear(st,i,ti);if(g&&isUpgrade(g)){H.bag.splice(H.bag.indexOf(g),1);equip(g,true)}break}}})}
     while(matCount('herb')>=2&&H.potions<4){H.mats.herb-=2;H.potions++;train('alchemy',3)}
     if(sk('alchemy')>=15&&matCount('herb')>=3&&matCount('dust')>=1){H.mats.herb-=3;H.mats.dust--;addBuff('dmg',.25)}
     while(matCount('dust')>=4&&H.weapon.rar===0&&!H.weapon.starter&&sk('enchant')>=5){doEnchant('weapon','imbue')}}
    // camp: sell pack, buy cheapest upgrades, keep 3 potions
    while(H.bank>=POTION_COST&&H.potions<3){H.bank-=POTION_COST;H.potions++}
    let spent=true; while(spent){spent=false; let bk=null,bc=1e9; for(const k in UPS){const c=upCost(k); if(c<bc&&H.up[k]<UPMAX){bc=c;bk=k}} if(bk&&H.bank>=bc){H.bank-=bc;H.up[bk]++;spent=true}}
    {const ks=Object.keys(SKILLS).sort((a,b)=>sk(b)-sk(a));for(const k of ks)for(let i=0;i<4;i++){const id=perkId(k,i);if(H.pp>0&&!has(id)&&sk(k)>=[25,50,75,100][i]){H.pp--;H.perks.push(id)}}}
    G=null;
  }
  return {floors, runs, reached:H.waypoint, lvl:H.lvl, gear:H.weapon.n+' / '+H.armor.n, cs:CRAFT_SK.map(k=>sk(k)).join(',')};
}
