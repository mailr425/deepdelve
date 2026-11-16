window.BOT={log:[],floorStart:0,stats:{},on:true,lastPos:null,stuck:0};
function botTick(){
  if(!BOT.on||!G||!H)return;
  const ov=topOverlay();
  if(ov){ // handle overlays
    if(ov.id==='deadov'){BOT.on=false;BOT.log.push({ev:'dead',depth:G.depth,t:(performance.now()-BOT.floorStart)/1000,kills:G.kills});return}
    if(ov.id==='stairov'){const b=[...ov.querySelectorAll('button')].find(x=>/DESCEND/.test(x.textContent));if(b){BOT.log.push({ev:'floor',depth:G.depth,t:(performance.now()-BOT.floorStart)/1000,hp:G.P.hp,max:maxHP(),kills:G.kills,pots:H.potions});ovT=0;b.click();BOT.floorStart=performance.now()}return}
    ov.classList.remove('show');return}
  const P=G.P;
  if(P.hp<maxHP()*.35&&H.potions>0)ACT.pot();
  // adjacent monster?
  let adj=null;{let bd=9;for(const m of G.mons){const dd=Math.hypot((m.px??m.x+.5)-P.px,(m.py??m.y+.5)-P.py);if(dd<1.35&&dd<bd){bd=dd;adj={m}}}}
  IN.sx=0;IN.sy=0;KEYS.delete(' ');
  const face=(tx,ty)=>{P.a=Math.atan2(tx+.5-P.px,-(ty+.5-P.py))};
  if(adj){P.a=Math.atan2((adj.m.px??adj.m.x+.5)-P.px,-((adj.m.py??adj.m.y+.5)-P.py));KEYS.add(' ');// stay centered-ish
    return}
  // target: nearest reachable monster seen, else stairs if open, else nearest unseen tile
  const pass=t=>t!==WALL&&t!==GATE;
  const dist=bfs(G.map,P.x,P.y,pass);
  let tgt=null,best=1e9;
  for(const m of G.mons){const dd=dist[idx(m.x,m.y)];if(dd>=0&&G.seen[idx(m.x,m.y)]&&dd<best){best=dd;tgt=[m.x,m.y,'mon']}}
  if(!tgt&&!G.sealed){for(let i=0;i<G.map.length;i++)if(G.map[i]===STAIRS){tgt=[i%MW,Math.floor(i/MW),'stairs']}}
  if(!tgt){for(let i=0;i<G.map.length;i++){if(G.seen[i]||G.map[i]===WALL)continue;const dd=dist[i];if(dd>=0&&dd<best){best=dd;tgt=[i%MW,Math.floor(i/MW),'explore']}}}
  if(!tgt){for(const m of G.mons){const dd=dist[idx(m.x,m.y)];if(dd>=0&&dd<best){best=dd;tgt=[m.x,m.y,'mon']}}}
  if(!tgt)return;
  if(tgt[2]==='stairs'&&P.x===tgt[0]&&P.y===tgt[1]){useAction();return}
  // path step: neighbor with smallest distance-to-target
  const back=bfs(G.map,tgt[0],tgt[1],pass);let nx=null,nd=1e9;
  for(let d=0;d<4;d++){const x=P.x+DX[d],y=P.y+DY[d],v=back[idx(x,y)];if(v>=0&&v<nd&&!monAt(x,y)){nd=v;nx=[x,y,d]}}
  if(!nx)return;
  if(cell(nx[0],nx[1])===DOOR){P.dir=nx[2];face(nx[0],nx[1]);useAction();return}
  // steer toward center of next tile (with centering on current tile when turning corners)
  const cx=nx[0]+.5,cy=nx[1]+.5;face(nx[0],nx[1]);
  const off=Math.abs(nx[2]%2?P.py-(P.y+.5):P.px-(P.x+.5));
  IN.sy=-1;
  if(off>.12){ // strafe to recentre
    const r=(nx[2]+1)%4,ox=P.x+.5-P.px,oy=P.y+.5-P.py;IN.sx=Math.sign(ox*DX[r]+oy*DY[r])*.8}
  const pos=P.px.toFixed(2)+P.py.toFixed(2);if(pos===BOT.lastPos){BOT.stuck++;if(BOT.stuck>40){P.px=P.x+.5;P.py=P.y+.5;BOT.stuck=0;BOT.log.push({ev:'unstuck',depth:G.depth})}}else BOT.stuck=0;BOT.lastPos=pos;
}
setInterval(botTick,50);
