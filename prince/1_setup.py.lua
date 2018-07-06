-- set up

clear = 13
cls(clear)

auto = false

⬅️ = 0
➡️ = 1
⬆️ = 2
⬇️ = 3
❎ = 4
🅾️ = 5

black = 0
navy = 1
purple = 2
forest = 3
brown = 4
dark = 5
light = 6
white = 7
red = 8
orange = 9
yellow = 10
neon = 11
sky = 12
pale = 13
pink = 14
sand = 15

note_pos = {x=2, y=87}

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
 local en_el_c=enemy.stats[eni].e
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

palt(black, false)
elements = {
 {n="none", c=dark},
 {n="holy", c=pink},
 {n="light", c=light},
 {n="dark", c=purple},
 {n="fire", c=orange},
 {n="elec", c=yellow},
 {n="air", c=sand},
 {n="ice", c=sky},
 {n="water", c=navy},
 {n="blood", c=red},
 {n="rock", c=brown},
 {n="plant", c=forest},
 {n="variable", c=neon}
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
 stats = {{n="^bunny",e="n",l=1},{n="^rabbit",e="n",l=3},{n="^bunny ^girl",e="n",l=5},{n="^horse",e="n",l=2},{n="^unicorn",e="n",l=4},{n="^cenitaur",e="n",l=6},{n="^ghost",e="n",l=1},{n="^poltergeist",e="n",l=4},{n="^zombie",e="n",l=2},{n="^ghoul",e="n",l=5},{n="^skeleton",e="n",l=3},{n="^skull ^army",e="n",l=6},{n="^floating^eye",e="n",l=1},{n="^eye ^beast",e="n",l=4},{n="^willowisp",e="n",l=2},{n="^giant ^skull",e="n",l=5},{n="^sadness",e="n",l=3},{n="^madness",e="n",l=6},{n="^man",e="n",l=0},{n="^woman",e="n",l=0},{n="^child",e="n",l=0},{n="^prince",e="v",l=4},{n="^king",e="v",l=8},{n="^emperor",e="v",l=12},{n="^fighter",e="v",l=4},{n="^general",e="v",l=8},{n="^giant",e="v",l=12},{n="^caster",e="v",l=4},{n="^sorceror",e="v",l=8},{n="^merlin",e="v",l=12},{n="^lizard",e="f",l=2},{n="^dragon",e="f",l=4},{n="^drako",e="f",l=6},{n="^snake",e="e",l=2},{n="^cobra",e="e",l=4},{n="^lamia",e="e",l=6},{n="^bird",e="a",l=2},{n="^crow",e="a",l=4},{n="^harpy",e="a",l=6},{n="^sap",e="p",l=2},{n="^slime",e="p",l=4},{n="^jelly ^girl",e="p",l=6},{n="^fish",e="w",l=2},{n="^shark",e="w",l=4},{n="^mermaid",e="w",l=6},{n="^mouse",e="i",l=2},{n="^rat",e="i",l=4},{n="^mouse^prince",e="i",l=6},{n="^turtle",e="r",l=2},{n="^tortise",e="r",l=4},{n="^kapa",e="r",l=6},{n="^bat",e="b",l=2},{n="^vampire ^bat",e="b",l=4},{n="^vampire",e="b",l=6},{n="^cat",e="l",l=3},{n="^lion",e="l",l=5},{n="^cat ^girl",e="l",l=7},{n="^dog",e="d",l=3},{n="^wolf",e="d",l=5},{n="^werewolf",e="d",l=7},{n="^slug",e="h",l=4},{n="^snail",e="h",l=6},{n="^hermit",e="h",l=8},{n="^mist",e="n",l=6},{n="^blarg",e="n",l=9},{n="^rude ^demon",e="n",l=7},{n="^living^sword",e="n",l=10},{n="^mimic",e="n",l=8},{n="^embers",e="f",l=7},{n="^phoenix",e="f",l=9},{n="^bolt ^rider",e="e",l=7},{n="^android",e="e",l=9},{n="^wind ^rider",e="a",l=7},{n="^marionette",e="a",l=9},{n="^evil ^weed",e="p",l=7},{n="^evil ^tree",e="p",l=9},{n="^rain ^rider",e="w",l=7},{n="^hydra",e="w",l=9},{n="^snow ^rider",e="i",l=7},{n="^polar ^bear",e="i",l=9},{n="^mushroom",e="r",l=7},{n="^golem",e="r",l=9},{n="^death",e="b",l=7},{n="^haunted^tree",e="b",l=9},{n="^cactus",e="l",l=8},{n="^mummy",e="l",l=10},{n="^dark ^hand",e="d",l=8},{n="^dark ^mouth",e="d",l=10},{n="^priest",e="h",l=11},{n="^angel",e="h",l=11},{n="^elder^dragon",e="f",l=12},{n="^blade^master",e="e",l=12},{n="^puppeteer",e="a",l=12},{n="^venus ^trap",e="p",l=12},{n="^kraken",e="w",l=12},{n="^frozen^mimic",e="i",l=12},{n="^raging ^dino",e="r",l=12},{n="^vampiress",e="b",l=12},{n="^sphinx",e="l",l=13},{n="^hatman",e="d",l=13},{n="^bishop",e="h",l=14},{n="^final^bishop",e="h",l=15}},
}

arena = nil

function set_up_enemies()
 for s=0,4 do
  if rnd(5) > 2 then
   local id = ceil(rnd(#enemy.stats))
   local e = enemy.stats[id].e
   if e == "v" then
    //humans get random element
    element_i = ceil(rnd(8))+4
    element_n = sub(elements[element_i].n,1,1)
    e = element_n
   end
   local n = enemy.stats[id].n
   local l = enemy.stats[id].l
  	local enemy = {
  		i = id,
  		x = 16 + (s % 2) * 12,
  		y = s * 16 + 16,
  		stats = {e=e, n=n, l=l}
  	}
  	add(arena.enemies, enemy)
 	end
 end
end

function set_up_party()
 for s = 0,4 do
  local id
  if s == 2 then
   id = 22
  elseif rnd(5) > 2 then
   id = flr(rnd(2))
   if id == 0 then
    id = 25
   else
    id = 28
   end
 	end
 	if id != nil then
 	 //assign random element of basic 8
 	 local e = ceil(rnd(8))+4
 	 local element_n = sub(elements[e].n,1,1)
 	 local n = enemy.stats[id].n
 	 local l = 1
 	 assert(e)
  	local member = {
  		i = id,
  		x = 96 - (s % 2) * 12,
  		y = s * 16 + 16,
  		stats = {e=element_n, n=n, l=l}
  	}
  	add(arena.party, member)
 	end
 end

 arena.party.score = 0
 arena.party.battles = 0

 turn = arena.party
 cur = {l=arena.party, i=1,
        s=nil}
end

function set_up_arena()
 state = "arena"
 arena = {}

 arena.enemies = {n="enemies"}
 set_up_enemies()

 arena.party = {n="party"}
 set_up_party()
 if auto then auto_turn() end
end
