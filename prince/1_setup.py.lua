-- set up

clear = 13
cls(clear)

auto = false
random = false
delay = 10
round = true

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

prince = 22
fighter = 25
caster = 28

note_pos = {x=2, y=83}

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
 {i=1, n="none", c=dark,    o="444444444444"},
 {i=2, n="holy", c=pink,    o="418888888888"},
 {i=3, n="light", c=light,  o="441866666666"},
 {i=4, n="dark", c=purple,  o="448166666666"},
 {i=5, n="fire", c=orange,  o="412212468642"},
 {i=6, n="elec", c=yellow,  o="412221246864"},
 {i=7, n="air", c=sand,     o="412242124686"},
 {i=8, n="ice", c=sky,      o="412264212468"},
 {i=9, n="water", c=navy,   o="412286421246"},
 {i=10, n="plant", c=forest,o="412268642124"},
 {i=11, n="rock", c=brown,  o="412246864212"},
 {i=12, n="blood", c=red,   o="412224686421"},
 {i=13, n="variable", c=neon}
}

wide = {
 chars = " abcdefghijklmnopqrstuvwxyz0123456789.,!?:'+-*/(){}[]>",
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
 stats = {{i=1,n="^bunny",e="n",l=1},{i=2,n="^rabbit",e="n",l=3},{i=3,n="^bunny ^girl",e="n",l=5},{i=4,n="^horse",e="n",l=2},{i=5,n="^unicorn",e="n",l=4},{i=6,n="^cenitaur",e="n",l=6},{i=7,n="^ghost",e="n",l=1},{i=8,n="^poltergeist",e="n",l=4},{i=9,n="^zombie",e="n",l=2},{i=10,n="^ghoul",e="n",l=5},{i=11,n="^skeleton",e="n",l=3},{i=12,n="^skull ^army",e="n",l=6},{i=13,n="^floating^eye",e="n",l=1},{i=14,n="^eye ^beast",e="n",l=4},{i=15,n="^willowisp",e="n",l=2},{i=16,n="^giant ^skull",e="n",l=5},{i=17,n="^sadness",e="n",l=3},{i=18,n="^madness",e="n",l=7},{i=19,n="^man",e="n",l=0},{i=20,n="^woman",e="n",l=0},{i=21,n="^child",e="n",l=0},{i=22,n="^prince",e="v",l=6},{i=23,n="^king",e="v",l=8},{i=24,n="^emperor",e="v",l=10},{i=25,n="^fighter",e="v",l=7},{i=26,n="^general",e="v",l=9},{i=27,n="^giant",e="v",l=11},{i=28,n="^caster",e="v",l=8},{i=29,n="^sorceror",e="v",l=10},{i=30,n="^merlin",e="v",l=12},{i=31,n="^lizard",e="f",l=2},{i=32,n="^dragon",e="f",l=4},{i=33,n="^drako",e="f",l=6},{i=34,n="^snake",e="e",l=3},{i=35,n="^cobra",e="e",l=5},{i=36,n="^lamia",e="e",l=7},{i=37,n="^bird",e="a",l=2},{i=38,n="^crow",e="a",l=4},{i=39,n="^harpy",e="a",l=6},{i=40,n="^sap",e="p",l=3},{i=41,n="^slime",e="p",l=5},{i=42,n="^jelly ^girl",e="p",l=7},{i=43,n="^fish",e="w",l=2},{i=44,n="^shark",e="w",l=4},{i=45,n="^mermaid",e="w",l=6},{i=46,n="^mouse",e="i",l=3},{i=47,n="^rat",e="i",l=5},{i=48,n="^mouse^prince",e="i",l=7},{i=49,n="^turtle",e="r",l=2},{i=50,n="^tortise",e="r",l=4},{i=51,n="^kapa",e="r",l=6},{i=52,n="^bat",e="b",l=3},{i=53,n="^vampire ^bat",e="b",l=5},{i=54,n="^vampire",e="b",l=7},{i=55,n="^cat",e="l",l=4},{i=56,n="^lion",e="l",l=6},{i=57,n="^cat ^girl",e="l",l=8},{i=58,n="^dog",e="d",l=4},{i=59,n="^wolf",e="d",l=6},{i=60,n="^werewolf",e="d",l=8},{i=61,n="^slug",e="h",l=5},{i=62,n="^snail",e="h",l=7},{i=63,n="^hermit",e="h",l=9},{i=64,n="^mist",e="n",l=7},{i=65,n="^blarg",e="n",l=8},{i=66,n="^rude ^demon",e="n",l=9},{i=67,n="^living^sword",e="n",l=11},{i=68,n="^mimic",e="n",l=10},{i=69,n="^embers",e="f",l=8},{i=70,n="^phoenix",e="f",l=10},{i=71,n="^bolt ^rider",e="e",l=9},{i=72,n="^android",e="e",l=11},{i=73,n="^wind ^rider",e="a",l=8},{i=74,n="^marionette",e="a",l=10},{i=75,n="^evil ^weed",e="p",l=9},{i=76,n="^evil ^tree",e="p",l=11},{i=77,n="^rain ^rider",e="w",l=8},{i=78,n="^hydra",e="w",l=10},{i=79,n="^snow ^rider",e="i",l=9},{i=80,n="^polar ^bear",e="i",l=11},{i=81,n="^mushroom",e="r",l=8},{i=82,n="^golem",e="r",l=10},{i=83,n="^death",e="b",l=9},{i=84,n="^haunted^tree",e="b",l=11},{i=85,n="^cactus",e="l",l=10},{i=86,n="^mummy",e="l",l=12},{i=87,n="^dark ^hand",e="d",l=10},{i=88,n="^dark ^mouth",e="d",l=12},{i=89,n="^priest",e="h",l=11},{i=90,n="^angel",e="h",l=13},{i=91,n="^elder^dragon",e="f",l=12},{i=92,n="^blade^master",e="e",l=13},{i=93,n="^puppeteer",e="a",l=12},{i=94,n="^venus ^trap",e="p",l=13},{i=95,n="^kraken",e="w",l=12},{i=96,n="^frozen^mimic",e="i",l=13},{i=97,n="^raging ^dino",e="r",l=12},{i=98,n="^vampiress",e="b",l=13},{i=99,n="^sphinx",e="l",l=14},{i=100,n="^hatman",e="d",l=14},{i=101,n="^bishop",e="h",l=15},{i=102,n="^final^bishop",e="h",l=16},}
}

arena = nil

levels = {  4,  12,  24,  40,
           64,  84, 108, 136,
          168, 204, 244, 288,
          336, 388, 444}

enemies_by_level = {}
for l=1,#levels do
 enemies_by_level[l] = {}
end
for e in all(enemy.stats) do
 l = e.l
 add(enemies_by_level[l],e)
end

function set_up_enemies()
 for s=1,5 do
  if rnd(1) < 0.33 then
   local id
   local e
   if random then
    id = ceil(rnd(#enemy.stats))
   else
    local l = 1
    if arena and arena.party and arena.party.level then
     l = arena.party.level
    end
    if l > #enemies_by_level then l = #enemies_by_level end
    local e_l = ceil(rnd(#enemies_by_level[l]))
    local enemy = enemies_by_level[l][e_l]
    id = enemy.i
   end
   e = enemy.stats[id].e
   if e == "v" then
    //humans get random element
    element_i = ceil(rnd(8))+4
    element_n = sub(elements[element_i].n,1,1)
    e = element_n
   end
   local n = enemy.stats[id].n
   local l = enemy.stats[id].l
  	local enemy = {
  	 s = s,
  		i = id,
  		x = 16 + ((s-1) % 2) * 12,
  		y = (s-1) * 14 + 13,
  		stats = {e=e, n=n, l=l}
  	}
  	add(arena.enemies, enemy)
 	end
 end
 if #arena.enemies == 0 then
  set_up_enemies()
 end
end

function set_up_party()
 for s = 1,5 do
  local id
  if s == 3 then
   id = prince
  else
   local filled = true
   if random then filled = rnd(6) > 2 end
   if filled then
    id = flr(rnd(2))
    if id == 0 then
     id = fighter
    else
     id = caster
    end
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
  	 s = s,
  		i = id,
  		x = 96 - ((s-1) % 2) * 12,
  		y = (s-1) * 14 + 13,
  		stats = {e=element_n, n=n, l=l}
  	}
  	add(arena.party, member)
 	end
 end

 arena.party.score = 0
 arena.party.battles = 0
 arena.party.level = 1
 arena.party.dead = {}

 turn = arena.party
 cur = {l=arena.party, i=1,
        s=nil}
end

function set_up_arena()
 state = "arena"
 arena = {}

 arena.party = {n="party"}
 set_up_party()

 arena.enemies = {n="enemies"}
 set_up_enemies()

 if auto then auto_turn() end
end
