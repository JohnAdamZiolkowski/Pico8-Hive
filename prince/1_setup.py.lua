-- set up

clear = 13
cls(clear)

auto = true

⬅️ = 0
➡️ = 1
⬆️ = 2
⬇️ = 3
❎ = 4
🅾️ = 5

function inttobin(b)
 local t={}
 local a=0
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
 local en_el_c=enemy.stats[eni+1].e
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
 local ci = sheet.s2c[sub(s,i or 1,i or 1)]
 assert(ci, s..".."..i)
 return ci
end

palt(0, false)
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

arena = nil

function set_up_arena()
 state = "arena"
 arena = {}
 arena.enemies = {n="enemies"}
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

 arena.party = {n="party"}
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

 turn = arena.party
 cur = {l=arena.party, i=1,
        s=nil}
 if auto then auto_turn() end
end
