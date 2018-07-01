function inttobin(b)
 t={}
 a=0
 for i = 0,4 do
  a=2^i
  t[i+1]=band(a,b)/a
 end
 return t
end

function get_chars(sheet)
	assert(type(sheet)=="table")
 sheet.s2c={}
 sheet.c2s={}
 for i=1,#sheet.chars do
  local c=i-2
  local s=sub(sheet.chars,i,i)
  sheet.c2s[c]=s
  sheet.s2c[s]=c
 end
end

function get_element(eni)
 en_el_c=enemy.stats[eni+1].e
 for element in all(elements) do
  if sub(element.n, 1, 1) == en_el_c then
   return element
  end
 end
 assert(false, "unknown element:"..eni)
end

function ord(sheet, s, i)
 assert(type(sheet)=="table")
 assert(type(s)=="string")
 assert(type(i)=="number")
 ci = sheet.s2c[sub(s,i or 1,i or 1)]
 assert(ci, s..".."..i)
 return ci
end

palt(0, false)
cls(13)
elements = {
 {n="none", c=5},
 {n="holy", c=14},
 {n="light", c=6},
 {n="dark", c=2},
 {n="fire", c=9},
 {n="elec", c=10},
 {n="air", c=15},
 {n="ice", c=12},
 {n="water", c=1},
 {n="blood", c=8},
 {n="rock", c=4},
 {n="plant", c=3},
 {n="variable", c=11}
}

wide = {
 chars = " abcdefghijklmnopqrstuvwxyz0123456789.,!?:'+-*/(){}[]",
 x = 0,
 y = 0,
 tw = 5,
 th = 5,
 layers = 4
}
get_chars(wide)

slim = {
 chars = " abcdefghijklmnopqrstuvwxyz0123456789.,!?:'+-*/()",
	x = 0,
	y = 5,
 tw = 3,
 th = 5,
 layers = 4
}
get_chars(slim)

enemy = {
 x = 0,
	y = 10,
 tw = 16,
 th = 12,
 layers = 2,
 stats = {{n="^bunny",e="n"},{n="^rabbit",e="n"},{n="^bunny ^girl",e="n"},{n="^horse",e="n"},{n="^unicorn",e="n"},{n="^cenitaur",e="n"},{n="^ghost",e="n"},{n="^poltergeist",e="n"},{n="^zombie",e="n"},{n="^ghoul",e="n"},{n="^skeleton",e="n"},{n="^skull ^army",e="n"},{n="^floating^eye",e="n"},{n="^eye ^beast",e="n"},{n="^willowisp",e="n"},{n="^giant ^skull",e="n"},{n="^sadness",e="n"},{n="^madness",e="n"},{n="^man",e="n"},{n="^woman",e="n"},{n="^child",e="n"},{n="^prince",e="n"},{n="^king",e="n"},{n="^emperor",e="n"},{n="^fighter",e="n"},{n="^general",e="n"},{n="^giant",e="n"},{n="^caster",e="n"},{n="^sorceror",e="n"},{n="^merlin",e="n"},{n="^lizard",e="f"},{n="^dragon",e="f"},{n="^drako",e="f"},{n="^snake",e="e"},{n="^cobra",e="e"},{n="^lamia",e="e"},{n="^bird",e="a"},{n="^crow",e="a"},{n="^harpy",e="a"},{n="^sap",e="p"},{n="^slime",e="p"},{n="^jelly ^girl",e="p"},{n="^fish",e="w"},{n="^shark",e="w"},{n="^mermaid",e="w"},{n="^mouse",e="i"},{n="^rat",e="i"},{n="^mouse^prince",e="i"},{n="^turtle",e="r"},{n="^tortise",e="r"},{n="^kapa",e="r"},{n="^bat",e="b"},{n="^vampire ^bat",e="b"},{n="^vampire",e="b"},{n="^cat",e="l"},{n="^lion",e="l"},{n="^cat ^girl",e="l"},{n="^dog",e="d"},{n="^wolf",e="d"},{n="^werewolf",e="d"},{n="^slug",e="h"},{n="^snail",e="h"},{n="^hermit",e="h"},{n="^mist",e="n"},{n="^blarg",e="n"},{n="^rude ^demon",e="n"},{n="^living^sword",e="n"},{n="^mimic",e="n"},{n="^embers",e="f"},{n="^phoenix",e="f"},{n="^bolt ^rider",e="e"},{n="^android",e="e"},{n="^wind ^rider",e="a"},{n="^marionette",e="a"},{n="^evil ^weed",e="p"},{n="^evil ^tree",e="p"},{n="^rain ^rider",e="w"},{n="^hydra",e="w"},{n="^snow ^rider",e="i"},{n="^polar ^bear",e="i"},{n="^mushroom",e="r"},{n="^golem",e="r"},{n="^death",e="b"},{n="^haunted^tree",e="b"},{n="^cactus",e="l"},{n="^mummy",e="l"},{n="^dark ^hand",e="d"},{n="^dark ^mouth",e="d"},{n="^priest",e="h"},{n="^angel",e="h"},{n="^elder^dragon",e="f"},{n="^blade^master",e="e"},{n="^puppeteer",e="a"},{n="^venus ^trap",e="p"},{n="^kraken",e="w"},{n="^frozen^mimic",e="i"},{n="^raging ^dino",e="r"},{n="^vampiress",e="b"},{n="^sphinx",e="l"},{n="^hatman",e="d"},{n="^bishop",e="h"},{n="^final^bishop",e="h"}}
}


function print(string, x, y, pc, caps)
 assert(type(string)=="string")
 local offset = 0
 local shift = false
 for char=1,#string do
  if sub(string,char,char) == "^" then
   shift = true
  else
   if shift or caps then
    sheet = wide
   else
    sheet = slim
   end
   ci = ord(sheet, string, char)
   render(sheet, ci, x + offset, y, pc)
  	offset += sheet.tw + 1
  	shift = false
  end
 end
end

function render(sheet, ci, dx, dy, pc1, pc2, pc3, pc4, flipx)

 tw = sheet.tw
 th = sheet.th
 off_x = sheet.x
 off_y = sheet.y
 layers = sheet.layers
 rw = flr(128 * layers / sheet.tw) //tiles per row

 local c = flr(ci / layers) % (rw / layers)
 local l = ci % layers
 local r = flr(ci / rw)
 local sx = off_x + c * tw
 local sy = off_y + r * th

 for y = 0,th-1 do
  for x = 0,tw-1 do
   local dpixel
   local spixel = sget(sx + x, sy + y)
   if spixel != 0 then
    local b = inttobin(spixel)
    if layers == 4 then
     if b[l+1] == 1 then
      dpixel = pc1
     end
    elseif layers == 2 then
     ll = l * 2
     if b[ll+1] == 1 and b[ll+2] == 1 then
      dpixel = pc4
     elseif b[ll+1] == 1 then
      dpixel = pc2
     elseif b[ll+2] == 1 then
      dpixel = pc3
     end
    end
    if dpixel != nil then
     final_x = dx + x
     if flipx then
      final_x = dx - x + tw
     end
     pset(final_x, dy + y, dpixel)
    end
   end
  end
 end

end

function draw_enemy(i, x, y, flipx)
 local sheet = enemy
 local c = get_element(i).c
 render(sheet, i, x, y, nil, 0, nil, 7, flipx)
end

arena = nil

function set_up_arena()
 arena = {}
 arena.enemies = {}
 for s=0,4 do
  if rnd(5) > 2 then
   local id = flr(rnd(102))
  	local enemy = {
  		i = id,
  		x = 16 + (s % 2) * 12 ,
  		y = s * 16 + 16
  	}
  	add(arena.enemies, enemy)
 	end
 end

 arena.party = {}
 for s = 0,4 do
  local id
  if s == 2 then
   id = 21
  elseif rnd(5) > 2 then
   id = flr(rnd(2))
   if id == 0 then
    id = 24
   else
    id = 27
   end
 	end
 	if id != nil then
  	local member = {
  		i = id,
  		x = 96 - (s % 2) * 12,
  		y = s * 16 + 16
  	}
  	add(arena.party, member)
 	end
 end

 cur = {l="party", i=1}
end

function draw_arena()
 cls(13)
 for x = 0,15 do
  spr(192, x*8, 0)
 end
 draw_enemies()
 draw_party()
 line(0,94,128,94)
 draw_cursor()
end

function draw_enemies()
 for e in all(arena.enemies) do
  draw_enemy(e.i, e.x, e.y)
 end
 for e = 1,#arena.enemies do
  local en = arena.enemies[e]
  //local c = get_element(en.i).c
  local c = 0
  print("^]"..enemy.stats[en.i+1].n, 1, 6*e + 91, c)
 end
end

function draw_party()
 for e in all(arena.party) do
  draw_enemy(e.i, e.x, e.y, true)
 end
 for m = 1,#arena.party do
  local en = arena.party[m]
  //local c = get_element(en.i).c
  local c = 0
  print("^]"..enemy.stats[en.i+1].n, 80, 6*m + 91, c)
 end
end


function check_over()
 if #arena.enemies == 0 then
  print("^no more enemies remain!", 1, 118, 9)

 //elseif #arena.party == 0 then

 end
end

⬅️ = 0
➡️ = 1
⬆️ = 2
⬇️ = 3

function _update()
 if btnp(⬅️) or btnp(➡️) then
  toggle_cursor()
  cap_cursor()
  draw_arena()
  draw_cursor()
 elseif btnp(⬆️) then
  cur.i -= 1
  cap_cursor()
  draw_arena()
  draw_cursor()
 elseif btnp(⬇️) then
  cur.i += 1
  cap_cursor()
  draw_arena()
  draw_cursor()
 end
end

function toggle_cursor()
 if cur.l == "enemies" then
  cur.l = "party"
 else
  cur.l = "enemies"
 end
end

function cap_cursor()
 if cur.l == "enemies" then
  if cur.i < 1 then
   cur.i = 1
  elseif cur.i > #arena.enemies then
   cur.i = #arena.enemies
  end
 else
  if cur.i < 1 then
   cur.i = 1
  elseif cur.i > #arena.party then
   cur.i = #arena.party
  end
 end
end

function draw_cursor()
 local x
 local y
 if cur.l == "enemies" then
  x = 1
 else
  x = 80
 end
 y = 91 + 6 * cur.i
 print("^[", x, y, 0)
end

set_up_arena()
draw_arena()
check_over()