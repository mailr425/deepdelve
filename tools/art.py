# Monster sprite source (24px-class). Half-rows are mirrored around the centre.
# 'k' = outline. Attack frames override specific rows.
import json

def mir(rows, w=12):
    return [r.ljust(w, '.') + r.ljust(w, '.')[::-1] for r in rows]

M = {}

M['rat'] = dict(full=[
 "........................",
 "....kk..................",
 "...kpak.................",
 "..kpaak..kkkkkk.........",
 ".kbaaaakkbbbbbbkk.......",
 "kbaeaaaabbbbbbbbbk......",
 "kbkeaaaaabbbbbbbbbk.....",
 "taaaaaaaaabbbbbbbbbk....",
 ".kcaaaaaaaabbbbbbbbk..tt",
 "..kccaaaaaaaabbbbbk..t..",
 "...kkccccaaaaaabbk..t...",
 "....kkkkkkkkkkkkkkttt...",
 "....kpk.kpk...kpk.kpk...",
 "....kk..kk....kk..kk....",
], pal=dict(a='#8a7a68', b='#6a5c4e', c='#b0a08c', e='#ff3a2a', p='#e8a0a8', t='#d89aa0', w='#f0ecd8'),
 atk={5: "kbaeaaaabbbbbbbbbk......", 7: "tkaaaaaaaabbbbbbbbbk....", 8: ".kwkaaaaaaabbbbbbbbk..tt"})

M['spider'] = dict(half=[
 "............",
 "............",
 ".........kkk",
 "......kkkbbb",
 "..kkk.kbbaab",
 ".kbbbkkbaaab",
 "kbk.kbkbbbbb",
 "kbk..kbbbbbb",
 "kk..kbkkkkkk",
 "k..kbk.kbbbb",
 "..kbk.kbeekb",
 ".kbk..kbbeee",
 ".kk...kbbbbb",
 "kbk....kbkww",
 "kk.....kk.kw",
 "k..........k",
], pal=dict(a='#7a6488', b='#4a3a58', e='#ff2a2a', w='#ece4d4'),
 atk={13: "kbk....kbkkk", 14: "kk.....kkwww", 15: "k........kwk"})

M['goblin'] = dict(half=[
 "............",
 "............",
 ".........kkk",
 "........kaaa",
 "k......kaaaa",
 "kak....kaaaa",
 ".kak..kaaaaa",
 ".kbakkbaaaaa",
 "..kbbbbaeeka",
 "...kkbbbaaaa",
 ".....kbbaaab",
 ".....kbkwkwk",
 "......kbbkkk",
 "....kkkkbbbk",
 "...kbbktttuu",
 "..kbbktttutt",
 "..kbkkttuttt",
 "..kakktttttt",
 "..kakkyyyyyy",
 ".kwkk.kttttu",
 ".kwk..kttkkk",
 "..k...kbbk..",
 "......kbbk..",
 ".....kkkkk..",
], pal=dict(a='#86c452', b='#5a9a32', e='#ffe030', w='#e8e8f0', t='#7a5230', u='#54381e', y='#c8a040'),
 atk={11: ".....kbkkkkk", 12: "......kbkwkw", 8: "..kbbbbaeeea"})

M['skeleton'] = dict(half=[
 "............",
 ".........kkk",
 "........kwww",
 ".......kwwww",
 ".......kwwww",
 ".......kwkkw",
 ".......kwkrw",
 ".......kwwwk",
 "........kwkw",
 "........kwww",
 ".........kkk",
 "..........kw",
 "......kwwwww",
 ".....kwk.www",
 ".....kwk..kw",
 ".....kwk.www",
 ".....kwk..kw",
 "....kwk..www",
 "....kwk...kw",
 "...kwwk.kwww",
 "...kkk..kwkw",
 ".........kw.",
 ".........kw.",
 "........kww.",
], pal=dict(w='#e8e0cc', r='#ff4020'),
 atk={6: ".......kwkRw", 7: "....kw.kwwwk", 8: "....kw..kkkk", 9: ".....kw.kwkw", 10: ".....kw..kkk",
      11: "......kw..kw", 12: "......kwwwww", 13: ".........www", 14: "..........kw", 15: ".........www",
      16: "..........kw", 17: ".........www", 18: "..........kw", 19: "........kwww", 20: "........kwkw"},
 extra=dict(R='#ffd040'))

M['zombie'] = dict(half=[
 "............",
 ".........kkk",
 "........kaaa",
 ".......kaaaa",
 ".......kabaa",
 ".......kakka",
 ".......kakea",
 ".......kaaab",
 "........kbbb",
 "........kbkk",
 ".........kaa",
 "kk....kkkccc",
 "kaakkkcccddc",
 ".kaaakccdccc",
 "..kkakcccccc",
 "....kccdcccc",
 "....kcccccdc",
 "....kccccccc",
 "....kddddddd",
 ".....kdddkdd",
 ".....kddk.kd",
 ".....kaak...",
 ".....kaak...",
 "....kkkkk...",
], pal=dict(a='#93aa78', b='#6a805a', c='#5c5874', d='#3a3650', e='#ffff80'),
 atk={8: "........kkkk", 9: "........kbkb", 11: "kkkk..kkkccc", 12: "kaaakkcccddc"})

M['orc'] = dict(half=[
 "............",
 "........kkkk",
 ".......kbbbb",
 "......kbaaaa",
 "......kbaaaa",
 "......kbkkaa",
 "......kbekaa",
 "......kbaaab",
 "......kbwaab",
 ".....kkbwkkk",
 "....kkkkkbbb",
 "..kkssssktkt",
 ".kssssssmttt",
 ".ksmmmmmmttt",
 ".kmkbbbkttct",
 ".kbkbbbktttt",
 ".kbkbbkttttt",
 ".kakkkyyyyyy",
 ".kak.kttmttt",
 ".kak.ktttttk",
 ".....kbbbk..",
 ".....kbbbk..",
 ".....kccccc.",
 ".....kkkkkk.",
], pal=dict(a='#6e9e4c', b='#4f7a3a', c='#35552a', w='#f0ecd8', e='#ff3020', s='#a8a8b0', m='#6a6a74', t='#6a4a2a', y='#c8a040'),
 atk={6: "......kbeeaa", 8: "......kbwkkk", 9: ".....kkbkwkw"})

M['wraith'] = dict(half=[
 "..........kk",
 "........kkaa",
 ".......kaabb",
 "......kaabbb",
 ".....kaabkkk",
 ".....kabkkkk",
 ".....kabkkek",
 ".....kabkkkk",
 "....kaabbkkk",
 "....kaabbbkk",
 "...kaabbbbbb",
 "..kaaabbbbbb",
 ".kaaabbbbbbb",
 "kaa.kabbbbbb",
 "ka..kabbbbbb",
 "k...kabbbbbb",
 "....kaabbbbb",
 "....kaabbbbb",
 "....kabbbbbb",
 "...kabbbbbbb",
 "...kab.bbb.b",
 "..kab..bb..b",
 "..ka...b....",
 "..k.........",
], pal=dict(a='#a6b4c8', b='#56627c', e='#80f0ff'),
 atk={6: ".....kabkeee", 13: "kaaaaabbbbbb", 12: "kaaaabbbbbbb", 14: "k...kabbbbbb", 15: "....kabbbbbb"})

M['troll'] = dict(half=[
 "............",
 "............",
 ".........kkk",
 "........kaaa",
 ".......kaaaa",
 "......kbkkaa",
 "......kbekaa",
 "......kbaaaa",
 "......kbaaab",
 ".....kkbawaa",
 "....kaakkkbb",
 "...kaaaaaaaa",
 "..kaaabaaaaa",
 ".kaakbaaabaa",
 ".kaak.kaaaaa",
 "kaak..kaaaaa",
 "kaak..kttttt",
 "kak...kttutt",
 "kak...kttttt",
 "kk....kaaakk",
 "......kaaak.",
 "......kbbbk.",
 ".....kbbbbk.",
 ".....kkkkkk.",
], pal=dict(a='#7a9a86', b='#58786a', e='#ffd020', w='#ece4c4', t='#6a4a30', u='#4a3020'),
 atk={9: ".....kkbakkk", 10: "....kaakwkwk", 6: "......kbeeaa"})

M['dragon'] = dict(half=[
 "k...........",
 "kk......kk..",
 "kak....kck..",
 "kaak...kck..",
 "kaaak..kaak.",
 "kaaaak.kaaak",
 "kaaaaakkaaaa",
 "kaaaaakaekaa",
 "kaaaaaakaaaa",
 "kaaaaaakaaaa",
 ".kaaaaakkwkw",
 ".kaaaakbkaaa",
 "..kaaakbbaaa",
 "...kaakbbbbb",
 "....kakbbbbb",
 ".....kkbbbbb",
 "......kabbbb",
 "......kaabbb",
 "......kaaaaa",
 "......kaaaaa",
 ".....kaaak.k",
 ".....kaak...",
 ".....kccck..",
 ".....kkkkk..",
], pal=dict(a='#b8342a', b='#e8b048', c='#f0e8d0', e='#ffe020', w='#f8f8ec'),
 atk={10: ".kaaaaakkkkk", 11: ".kaaaakbkwkw", 7: "kaaaaakaeeaa"})

out = {}
for k, v in M.items():
    rows = v['full'] if 'full' in v else mir(v['half'])
    W = max(len(r) for r in rows)
    rows = [r.ljust(W, '.') for r in rows]
    atk = [r for r in rows]
    for i, hr in v.get('atk', {}).items():
        atk[i] = hr.ljust(W, '.') if 'full' in v else mir([hr])[0]
    pal = dict(v['pal']); pal.update(v.get('extra', {}))
    out[k] = dict(rows=rows, atk=atk, pal=pal)
json.dump(out, open('/home/claude/sprites.json', 'w'))

if __name__ == '__main__':
    from PIL import Image
    S = 6
    tiles = []
    for k, v in out.items():
        for frame in ('rows', 'atk'):
            rows = v[frame]; h = len(rows); w = len(rows[0])
            im = Image.new('RGB', (26 * S, 26 * S), (40, 32, 26))
            for y, r in enumerate(rows):
                for x, ch in enumerate(r):
                    if ch == '.': continue
                    c = '#140e0a' if ch == 'k' else v['pal'].get(ch, '#ff00ff')
                    col = tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))
                    for yy in range(S):
                        for xx in range(S):
                            im.putpixel((S + x * S + xx, (26 - h - 1) * S + y * S + yy), col)
            tiles.append(im)
    sheet = Image.new('RGB', (26 * S * 6, 26 * S * 3), (0, 0, 0))
    for i, t in enumerate(tiles):
        sheet.paste(t, ((i % 6) * 26 * S, (i // 6) * 26 * S))
    sheet.save('/home/claude/test/sheet.png')
