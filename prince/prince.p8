pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- util

table = "table"
number = "number"
string = "string"

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


-- integer

function rnd_int(min_in, max_in)
 //safely generates a random integer
 assert(type(min_in)==number)
 assert(flr(min_in)==min_in)
 assert(min_in>0)
 assert(type(max_in)==number)
 assert(flr(max_in)==max_in)
 assert(min_in<=max_in)
 if min_in == max_in then
  return min_in
 end
 int = flr(rnd(1) * (max_in-min_in+1))+min_in
 assert(int <= max_in, int.." "..max_in)
 assert(int >= min_in, int.." "..min_in)
 return int
end

function cap_int(value_in, min_in, max_in)
 //returns int within bounds
 assert(type(value_in)==number)
 assert(flr(value_in)==value_in)
 assert(type(min_in)==number)
 assert(flr(min_in)==min_in)
 assert(type(max_in)==number)
 assert(flr(max_in)==max_in)
 
 local value_out = value_in
 if value_out < min_in then
  value_out = min_in
 elseif value_out > max_in then
  value_out = max_in
 end
 assert(value_out >= min_in, value_out)
 assert(value_out <= max_in, value_out)
 return value_out
end


-- list

function lget(list, index)
 //safely gets item at list index
 assert(type(list)==table)
 assert(type(index)==number)
 assert(flr(index)==index)
 assert(index!=0)
 assert(index<=#list, index.." "..#list)
 value = list[index]
 assert(value!=nil, "value is nil "..index)
 return value
end

function lset(list, index, value, not_nil)
 //safely sets vaule at list index
 assert(type(list)==table)
 assert(type(index)==number)
 assert(flr(index)==index)
 assert(index!=0)
 if not_nil then
  assert(value, "value is nil")
 end
 list[index] = value
end

function lclr(list)
 //safely clears a list
 //ignores non-list table items
 assert(type(list)==table)
 assert(#list>0)
 local length = #list
 for i=length,1,-1 do
  local item = list[i]
  del(list,item)
 end
end

function linc(list,item)
 //returns whether item is in list
 assert(type(list)==table)
 assert(#list>0)
 assert(type(item)!=nil)
 for i=1,#list do
  if list[i] == item then
   return true
  end
 end
 return false
end

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
	assert(type(sheet)==table)
 sheet.s2c={}
 sheet.c2s={}
 for i=1,#sheet.chars do
  local c=i-2
  local s=sub(sheet.chars,i,i)
  sheet.c2s[c]=s
  sheet.s2c[s]=c
 end
end

function ord(sheet, s, i)
 assert(type(sheet)==table)
 assert(type(s)==string)
 assert(type(i)==number)
 local ci = sheet.s2c[sub(s,i or 1,i or 1)]
 assert(ci, s..".."..i)
 return ci
end


-- state management

function get_state()
 assert(#states.stack>0)
 return lget(states.stack, #states.stack)
end

function set_state(state)
 assert(type(state)==table)
 local index = 1
 if #states.stack > index then
  index = #states.stack
 end
 lset(states.stack, index, state)
 if state.init then
  state.init()
 end
 message = nil
 set_stale()
end

function push_state(state)
 assert(type(state)==table)
 add(states.stack, state)
 if state.init then
  state.init()
 end
 message = nil
 set_stale()
end

function pop_state()
 local prev_state = get_state()
 if prev_state.finish then
  prev_state.finish()
 end
 message = nil
 del(states.stack, prev_state)
 set_stale()
end

-->8
-- init

function _init()
 clear = 13
 cls(clear)
 palt(black, false)

 set_up_settings()
 set_up_elements()
 set_up_arena() 
 set_up_party()
 init_states()
 set_state(states.arena)
 push_state(states.intro)
end

function init_states()
states = {

 intro={name="^intro",
        init=init_intro,
        update=update_intro,
        draw=draw_arena_state,
        finish=finish_intro},

 arena={name="^arena",
        init=init_arena,
        update=update_arena,
        draw=draw_arena_state,
        finish=finish_arena},
        
 settings={name="^settings",
        init=init_settings,
        update=update_settings,
        draw=draw_settings,
        finish=finish_settings},
        
 team_building={name="^team ^building",
        init=init_team_building,
        update=update_team_building,
        draw=draw_team_building,
        finish=finish_team_building},
        
 element_chart={name="^element ^chart",
        init=init_element_chart,
        update=update_element_chart,
        draw=draw_element_chart,
        finish=finish_element_chart},
        
 attacking={name="^attacking",
        init=init_attack,
        update=update_attack,
        draw=draw_arena_state,
        finish=finish_attack},
        
 battle_over={name="^battle ^over",
        init=init_battle_over,
        update=update_battle_over,
        draw=draw_arena_state,
        finish=finish_battle_over},
        
 game_over={name="^game ^over",
        init=init_game_over,
        update=update_game_over,
        draw=draw_game_over,
        finish=finish_game_over},
 stack={}
}
end

settings = {
	{i=1, n="^auto ^turn", 
 	o={"^off", "^on"},
 	v={false, true},
 	s=1},
	{i=2, n="^text ^delay",
	 o={"^1", "^5", "^1^0", "^1^5"},
 	v={1, 5, 10, 15},
	 s=3},
	{i=3, n="^round ^icon",
	 o={"^off", "^on"},
 	v={false, true},
	 s=2},
	{i=4, n="^caps ^l^o^c^k",
	 o={"^off", "^o^n"},
 	v={false, true},
	 s=1},
	{i=5, n="^rand ^level",
	 o={"^off", "^on"},
 	v={false, true},
	 s=1},
	{i=6, n="^rand ^party",
	 o={"^off", "^on"},
 	v={false, true},
	 s=1},
	{i=7, n="^rand ^elem",
	 o={"^0", "^4", "^8", "^1^0"},
 	v={1, 5, 9, 11, 12},
	 s=1},
	{i=8, n="^rand ^enemy",
	 o={"^off", "^on"},
 	v={false, true},
	 s=1},
	{i=9, n="^hit chance",
	 o={"^on", "^hit", "^miss"},
 	v={"on", true, false},
	 s=1},
	{i=10, n="^penalty",
	 o={"^0", "^1", "^2", "^3"},
 	v={0, 1, 2, 3},
	 s=3},
	{i=11, n="^draw stats",
	 o={"^off", "^on"},
 	v={false, true},
	 s=1},
}

function set_up_settings()
 auto = set_up_setting(1)
 delay = set_up_setting(2)
 round = set_up_setting(3)
 caps_lock = set_up_setting(4)
 random_level = set_up_setting(5)
 random_party = set_up_setting(6)
 random_elem = set_up_setting(7)
 random_enemy = set_up_setting(8)
 hit_chance = set_up_setting(9)
 penalty = set_up_setting(10)
 stats = set_up_setting(11)
end
function set_up_setting(index)
 local setting = lget(settings,index)
 local options = setting.v
 local selected = lget(options,setting.s)
 return selected
end

function set_up_elements()
 unlocked_elements = {}
 for i=1,random_elem do
  local element = lget(elements,i)
  add(unlocked_elements,element)
 end
end

prince = 22
fighter = 25
caster = 28

function is_fighter(enemy_id)
 if enemy_id == fighter
  or enemy_id == fighter + 1
   or enemy_id == fighter + 2 then
  return true  
 end
 return false
end

function is_caster(enemy_id)
 if enemy_id == caster
  or enemy_id == caster + 1
   or enemy_id == caster + 2 then
  return true  
 end
end

function is_prince(enemy_id)
 if enemy_id == prince
  or enemy_id == prince + 1
   or enemy_id == prince + 2 then
  return true  
 end
end

function get_element(eni)
 local en_el_c=lget(enemy.stats,eni).e
 for element in all(elements) do
  if sub(element.n, 1, 1) == en_el_c then
   return element
  end
 end
 assert(false, "unknown element:"..eni)
end

function element_by_n(n)
 assert(type(n)==string)
 for element in all(elements) do
	 if n == sub(element.n, 1, 1) then
	  return element
	 end
	end
	assert(false, "unknown element: "..n)
end

elements = {                 //nhldfeaiwprb
 {i=1, n="none", c=dark,    o="444444444444"},

 {i=5, n="fire", c=orange,  o="412412468642"},
 {i=7, n="air", c=sand,     o="412442124686"},
 {i=9, n="water", c=navy,   o="414286421246"},
 {i=11, n="rock", c=brown,  o="414246864212"},

 {i=6, n="elec", c=yellow,  o="412421246864"},
 {i=8, n="ice", c=sky,      o="412464212468"},
 {i=10, n="plant", c=forest,o="414268642124"},
 {i=12, n="blood", c=red,   o="414224686421"},

 {i=3, n="light", c=light,  o="421866666666"},
 {i=4, n="dark", c=purple,  o="428166666666"},

 {i=2, n="holy", c=pink,    o="446688888888"},

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
 stats = {{i=1,n="^bunny",e="n",l=1},{i=2,n="^rabbit",e="n",l=3},{i=3,n="^bunny ^girl",e="n",l=5},{i=4,n="^horse",e="n",l=2},{i=5,n="^unicorn",e="n",l=4},{i=6,n="^centaur",e="n",l=6},{i=7,n="^ghost",e="n",l=1},{i=8,n="^poltergeist",e="n",l=4},{i=9,n="^zombie",e="n",l=2},{i=10,n="^ghoul",e="n",l=5},{i=11,n="^skeleton",e="n",l=3},{i=12,n="^skull ^army",e="n",l=6},{i=13,n="^floating^eye",e="n",l=1},{i=14,n="^eye ^beast",e="n",l=4},{i=15,n="^willowisp",e="n",l=2},{i=16,n="^giant ^skull",e="n",l=5},{i=17,n="^sadness",e="n",l=3},{i=18,n="^madness",e="n",l=7},{i=19,n="^man",e="n",l=0},{i=20,n="^woman",e="n",l=0},{i=21,n="^child",e="n",l=0},{i=22,n="^prince",e="v",l=6},{i=23,n="^king",e="v",l=8},{i=24,n="^emperor",e="v",l=10},{i=25,n="^fighter",e="v",l=7},{i=26,n="^general",e="v",l=9},{i=27,n="^giant",e="v",l=11},{i=28,n="^caster",e="v",l=8},{i=29,n="^sorceror",e="v",l=10},{i=30,n="^merlin",e="v",l=12},{i=31,n="^lizard",e="f",l=2},{i=32,n="^dragon",e="f",l=4},{i=33,n="^drako",e="f",l=6},{i=34,n="^snake",e="e",l=3},{i=35,n="^cobra",e="e",l=5},{i=36,n="^lamia",e="e",l=7},{i=37,n="^bird",e="a",l=2},{i=38,n="^crow",e="a",l=4},{i=39,n="^harpy",e="a",l=6},{i=40,n="^sap",e="p",l=3},{i=41,n="^slime",e="p",l=5},{i=42,n="^jelly ^girl",e="p",l=7},{i=43,n="^fish",e="w",l=2},{i=44,n="^shark",e="w",l=4},{i=45,n="^mermaid",e="w",l=6},{i=46,n="^mouse",e="i",l=3},{i=47,n="^rat",e="i",l=5},{i=48,n="^mouse^prince",e="i",l=7},{i=49,n="^turtle",e="r",l=2},{i=50,n="^tortise",e="r",l=4},{i=51,n="^kapa",e="r",l=6},{i=52,n="^bat",e="b",l=3},{i=53,n="^vampire ^bat",e="b",l=5},{i=54,n="^vampire",e="b",l=7},{i=55,n="^cat",e="l",l=4},{i=56,n="^lion",e="l",l=6},{i=57,n="^cat ^girl",e="l",l=8},{i=58,n="^dog",e="d",l=4},{i=59,n="^wolf",e="d",l=6},{i=60,n="^werewolf",e="d",l=8},{i=61,n="^slug",e="h",l=5},{i=62,n="^snail",e="h",l=7},{i=63,n="^hermit",e="h",l=9},{i=64,n="^mist",e="n",l=7},{i=65,n="^blarg",e="n",l=8},{i=66,n="^rude ^demon",e="n",l=9},{i=67,n="^living^sword",e="n",l=11},{i=68,n="^mimic",e="n",l=10},{i=69,n="^embers",e="f",l=8},{i=70,n="^phoenix",e="f",l=10},{i=71,n="^bolt ^rider",e="e",l=9},{i=72,n="^android",e="e",l=11},{i=73,n="^wind ^rider",e="a",l=8},{i=74,n="^marionette",e="a",l=10},{i=75,n="^evil ^weed",e="p",l=9},{i=76,n="^evil ^tree",e="p",l=11},{i=77,n="^rain ^rider",e="w",l=8},{i=78,n="^hydra",e="w",l=10},{i=79,n="^snow ^rider",e="i",l=9},{i=80,n="^polar ^bear",e="i",l=11},{i=81,n="^mushroom",e="r",l=8},{i=82,n="^golem",e="r",l=10},{i=83,n="^death",e="b",l=9},{i=84,n="^haunted^tree",e="b",l=11},{i=85,n="^cactus",e="l",l=10},{i=86,n="^mummy",e="l",l=12},{i=87,n="^dark ^hand",e="d",l=10},{i=88,n="^dark ^mouth",e="d",l=12},{i=89,n="^priest",e="h",l=11},{i=90,n="^angel",e="h",l=13},{i=91,n="^elder^dragon",e="f",l=12},{i=92,n="^blade^master",e="e",l=13},{i=93,n="^puppeteer",e="a",l=12},{i=94,n="^venus ^trap",e="p",l=13},{i=95,n="^kraken",e="w",l=12},{i=96,n="^frozen^mimic",e="i",l=13},{i=97,n="^raging ^dino",e="r",l=12},{i=98,n="^vampiress",e="b",l=13},{i=99,n="^sphinx",e="l",l=14},{i=100,n="^hatman",e="d",l=14},{i=101,n="^bishop",e="h",l=15},{i=102,n="^final^bishop",e="h",l=16}}
}

boss_sets = {
 {l=12, i={31, 32, 91, 33, 32}}, //elder dragon
 {l=12, i={74, 74, 93, 74, 74}}, //puppeteer
 {l=12, i={44, 78, 95, 45, 43}}, //kraken
 {l=12, i={82, 82, 97, 82, 82}}, //dino
 {l=13, i={35, 72, 92, 36, 34}}, //blademaster
 {l=13, i={76, 75, 94, 75, 76}}, //venus trap
 {l=13, i={68, 48, 96, 47, 68}}, //frozen mimic
 {l=13, i={52, 54, 98, 83, 53}}, //vampiress
 {l=14, i={55, 86, 99, 57, 56}}, //sphinx
 {l=14, i={87, 88, 100, 88, 87}},//hatman
 {l=15, i={89, 89, 101, 89, 89}},//bishop
 {l=16, i={90, 90, 102, 90, 90}} //final bishop
}


levels = {  4,  12,  24,  40,
           64,  84, 108, 136,
          168, 204, 244, 288,
          336, 388, 444, 512}
          
enemies_by_level = {}
for l=1,#levels do
 lset(enemies_by_level,l,{})
end
for e in all(enemy.stats) do
 local l = e.l
 if l != 0 then
  //skip man, woman, child
  if e.i < 91 then
   //skip bosses
  	add(lget(enemies_by_level,l),e)
  end
 end
end

function set_up_enemies()
 local l = 1
 if arena and arena.party and arena.party.level then
  l = arena.party.level
 end

 local boss_set
 local bosses_at_level = {}
 for s=1,#boss_sets do
  local set = lget(boss_sets,s)
  local set_boss_level = set.l
 
  if l == set_boss_level then
   add(bosses_at_level,set)
  end
 end
 
 if #bosses_at_level > 0 then
  local b = rnd_int(1,#bosses_at_level)
  boss_set = lget(bosses_at_level,b)
 end
  
 if boss_set and not random_enemy then
  set_up_boss(boss_set)
 	return
 end

 for s=1,5 do
  if rnd(1) < 0.33 then
   local id
   local e
   if random_enemy then
    id = rnd_int(1,#enemy.stats)
   else
    local l = 1
    if arena and arena.party and arena.party.level then
     l = arena.party.level
    end
    if l > #enemies_by_level then l = #enemies_by_level end
    local enemies_at_level = lget(enemies_by_level,l)
    local e_l = rnd_int(1,#enemies_at_level)
    local enemy = lget(enemies_at_level,e_l)
    id = enemy.i
   end
   e = lget(enemy.stats,id).e
   if e == "v" then
    //humans get random element
    local enemy_l =  lget(enemy.stats,id).l
    local element_i
    if id == prince
     or id == fighter
      or id == caster then
     element_i = rnd_int(2,5)
    elseif id == prince+1
     or id == fighter+1
      or id == caster+1 then
     element_i = rnd_int(6,9)
    elseif id == prince+2
     or id == fighter+2
      or id == caster+2 then
     element_i = rnd_int(10,11)
    end
    assert(element_i)
    local element_n = sub(lget(elements,element_i).n,1,1)
    e = element_n
   end
   local n = lget(enemy.stats,id).n
   local l = lget(enemy.stats,id).l
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

function set_up_boss(boss_set)
 assert(boss_set)

	//populate enemies
 for s=1,5 do
  local id = lget(boss_set.i,s)
  local e = lget(enemy.stats,id).e
  local n = lget(enemy.stats,id).n
  local l = lget(enemy.stats,id).l
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

function set_up_party()
 for s = 1,5 do
  local id
  if s == 3 then
   id = prince
  else
   local filled = true
   if random_party then filled = rnd(3) > 2 end
   if filled then
    id = rnd_int(1,2)
    if id == 1 then
     id = fighter
    else
     id = caster
    end
   end
 	end
 	if id != nil then
 	 //assign random element of basic 8
 	 local e = rnd_int(1,#unlocked_elements)
 	 local element_n = sub(lget(unlocked_elements,e).n,1,1)
 	 local n = lget(enemy.stats,id).n
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
 arena.party.luck = 0
 if random_level then
  arena.party.level = rnd_int(1,#levels)
  if arena.party.level > 1 then
   arena.party.score = lget(levels,arena.party.level-1)
 	end
 end
 arena.party.dead = {}
 
 turn = arena.party
 cur = {l=arena.party, i=1,
        s=nil}
end

function set_up_arena()
 arena = {}
 arena.party = {n="party"} 
 arena.enemies = {n="enemies"}
end

function init_intro()
 intro_ticks = 0
end

function init_auto_turn()
 auto_ticks = 0
end

function init_battle_over()
 over_ticks = 0
end

function init_game_over()
 game_over_ticks = 0
end

function init_settings()
 s_cur = {s=#settings+1, o=1}
 for s=1,#settings do
  setting = lget(settings,s)
  setting.c = setting.s
 end
end

function init_team_building()
 turn = arena.party
 cur.l = arena.party
 cap_cursor()
end
-->8
-- update

function _update()
 local state = get_state()
 if state.update then
  state.update()
 end
end

function update_element_chart()
 if btnp(🅾️) or btnp(❎)
 or btnp(⬅️) or btnp(➡️)
 or btnp(⬆️) or btnp(⬇️) then
  pop_state()
 end
end

function update_arena()

 if turn == arena.party then
  if not auto then
   if btnp(⬅️) then
    push_state(states.element_chart)
   elseif btnp(➡️) then
    push_state(states.settings)
   elseif btnp(⬆️) then
    move_cursor(-1)
   elseif btnp(⬇️) then
    move_cursor(1)
   elseif btnp(🅾️) then
    select()
   elseif btnp(❎) then
    deselect()
  	end
  else
   if btnp(❎) then
    finish_auto_turn()
   else
    update_auto_turn()
   end
  end
 elseif turn == arena.enemies then
  update_auto_turn()
 end
end

function update_settings()
 if btnp(❎) then
  pop_state()
 elseif btnp(🅾️) then
  save_settings()
 elseif btnp(⬅️) then
  change_options(-1)
 elseif btnp(➡️) then
  change_options(1)
 elseif btnp(⬆️) then
  change_settings(-1)
 elseif  btnp(⬇️) then
  change_settings(1)
 end
end

function update_team_building()
 if not auto then
  if btnp(🅾️) then
   pop_state()
  elseif btnp(❎) then
   push_state(states.element_chart)
  elseif btnp(⬅️) then
   change_element(lget(arena.party,cur.i))
  elseif btnp(➡️) then
   change_class(lget(arena.party,cur.i))
  elseif btnp(⬆️) then
   move_cursor(-1)
  elseif btnp(⬇️) then
   move_cursor(1)
  end
 else
  pop_state()
 end
end


-- attack

function init_attack()
 attack_ticks = 0
 
 attacker = lget(turn,cur.s.i)
 attacker_n = attacker.stats.n
 assert(attacker)
 targets = {}
 main_target = {t=lget(opposition(turn),cur.i)}
 main_target_n = main_target.t.stats.n
 add(targets, main_target)
 
 if is_caster(attacker.i) then
  for p_target in all(opposition(turn)) do
   if p_target.s == main_target.t.s +1 or
    p_target.s == main_target.t.s -1 then
    add(targets, {t=p_target})
   end
  end
 end
 
 for target in all(targets) do
 	assert(target)
	
  local hit
  local chance = get_hit_chance(attacker, target)
  if hit_chance != "on" then
   hit = hit_chance
  else
   hit = rnd(1) < chance
   
   if is_prince(attacker.i) then
    if hit and turn==arena.party then
     //prince changes element
     attacker.stats.e = target.t.stats.e
     local unlocking_element = element_by_n(target.t.stats.e)
     if not linc(unlocked_elements, unlocking_element) then
      //unlocks element for later
      add(unlocked_elements, unlocking_element)
     end
    end
   end
  end
  
  if turn == arena.party then
   if chance > 0.5 and not hit then
    arena.party.luck -= chance-0.5
   elseif chance < 0.5 and hit then
    arena.party.luck += 0.5-chance
   end
  else
   if chance < 0.5 and hit then
    arena.party.luck -= 0.5-chance
   elseif chance > 0.5 and not hit then
    arena.party.luck += chance-0.5
   end
  end
  
  target.h = hit
 end
 
end

function update_attack()
 
 attack_ticks += 1
 
 if attack_ticks == 1 then
  local name = main_target_n
  if #targets > 1 then
   name = #targets.." targets"
  end
  message = attacker_n.." attacks "..name
  set_stale()
 elseif attack_ticks == 3*delay then
  
  cur.s = nil
  
  local text = "^but it missed!"
  if #targets==1 then
   if lget(targets,1).h then
    text = "^hit! "..main_target_n.." is gone"
    eliminate(opposition(turn), main_target.t)
   end
  else
   local miss_count=0
   local hit_count=0
   local all_count=0
   for target in all(targets) do
    all_count +=1
    if target.h then
     hit_count += 1
     eliminate(opposition(turn), target.t)
    else
     miss_count += 1
    end
   end
   if miss_count == all_count then
    text = "^magic missed all "..all_count.." targets"
   elseif hit_count == all_count then
    text = "^magic hit all "..all_count.." targets"
   else
    text = "^magic hit "..hit_count.." of "..all_count.." targets"
   end
  end
 
  message = text
  set_stale()

 elseif attack_ticks == 6*delay then
  cur.s = nil
  attack_ticks = nil
  
  attacker = nil
  attacker_n = nil
  
  chance = nil
  main_target = nil
  main_target_n = nil
  targets = nil
  
  toggle_turn()
  pop_state()
  check_over()
 end
end


-- auto turn

function draw_auto_message()
 if turn == arena.party then
  message = "^press (^b) to end auto"
  set_stale()
 end
end

function update_auto_turn()
 if auto_ticks == nil then
  auto_ticks = 0
 end
 auto_ticks += 1
 if auto_ticks == 1 then
  draw_auto_message()
 elseif auto_ticks == 2*delay then
  random_cursor()
  draw_auto_message()
 elseif auto_ticks == 4*delay then
  select()
  draw_auto_message()
 elseif auto_ticks == 6*delay then
  random_cursor()
  draw_auto_message()
 elseif auto_ticks == 8*delay then
  select()
  auto_ticks = nil
 end
end

-- battle over

function update_battle_over()
 over_ticks += 1
 
 if over_ticks == 2*delay then
  set_stale()
  message = "^no more enemies remain!"
 elseif over_ticks == 5*delay then
  set_stale()
  arena.party.battles += 1
  local s = ""
  if arena.party.battles > 1 then s = "s" end
  message = "^finished "..arena.party.battles.." battle"..s
 elseif over_ticks == 10*delay then
  set_stale()
  message = "^total exp: "..arena.party.score
 elseif over_ticks == 15*delay then
  local next_level = lget(levels,arena.party.level)
 	if arena.party.score >= next_level and
 	 arena.party.level < #levels then
 	 arena.party.level += 1
 	 //maybe: lower score on level?
 	 if arena.party.level > #levels then
 	  arena.party.level = #levels
 	 end
   did_level = true
   revive()
   text = "^level up!! ^now at "..arena.party.level 
  else
   text = "^currnent level: "..arena.party.level 
  end
  set_stale()
  message = text
 
 elseif over_ticks == 20*delay then
  if did_level then
   push_state(states.team_building)
   did_level = false
  end
 elseif over_ticks == 21*delay then
  set_up_enemies()
  text = "^new enemies"
  if #arena.enemies == 1 then
   text = "^single "..lget(arena.enemies,1).stats.n
  end
  message = text.." appeared!"
  set_stale()
 elseif over_ticks == 23*delay then
  over_ticks = nil
  pop_state()
 end
end


-- game over

function update_game_over()
 game_over_ticks += 1
 
 if game_over_ticks == 2*delay then
  message = "^your entire party is down!"
  set_stale()
 elseif game_over_ticks == 5*delay then
  local s = "s"
  if arena.party.battles == 1 then s = "" end
  message = "^finished "..arena.party.battles.." battle"..s
 	set_stale()
 elseif game_over_ticks == 10*delay then
  
  message = "^final level: "..arena.party.level
 elseif game_over_ticks == 15*delay then
  lclr(arena.enemies)
  revive()
 	
  turn = arena.party
  cur = {l=arena.party, i=1,
         s=nil}
 	cap_cursor()
 	arena.party.battles = 0
 	old_level = arena.party.level
 	arena.party.level = 1
 	arena.party.score = 0
 	arena.party.luck = 0
 	if old_level > penalty then
 	 arena.party.level = old_level-penalty
 	 arena.party.score = lget(levels,arena.party.level)
 	end
 	message = "^the party is set back to "..arena.party.level.."..."
 	set_stale()
 elseif game_over_ticks == 18*delay then
  push_state(states.team_building)
 
 elseif game_over_ticks == 21*delay then
  message = "^new enemies appear!"
  set_up_enemies()
  set_stale()
 
 elseif game_over_ticks == 24*delay then
  game_over_ticks = nil
  pop_state()
 end
end

-- intro

function update_intro()
 intro_ticks += 1
 
 if intro_ticks == 2*delay then
  set_stale()
  message = "^a new journey begins"
 
 elseif intro_ticks == 5*delay then
  set_stale()
  push_state(states.team_building)
 
 elseif intro_ticks == 8*delay then
  set_up_enemies()
  text = "^new enemies"
  if #arena.enemies == 1 then
   text = "^single "..lget(arena.enemies,1).stats.n
  end
  message = text.." appeared!"
  set_stale()
  
 elseif intro_ticks == 13*delay then
  intro_ticks = nil
  pop_state()
 end
end
-->8
-- draw

function _draw()
 if stale then
  local state = get_state()
  if state.draw then
   state.draw()
   stale = false
  end
  if stats then
   draw_stats()
  end
 end
end

function draw_arena()
 cls(clear)
 
 if message then
  note(message)
 end
 
 //draw stones
 for x = 0,15 do
  spr(192, x*8, 0)
 end
 draw_enemies()
 draw_party()
 line(0,90,128,90,black)
 draw_options()
end

function draw_element_chart()
 cls(clear)
 
 local chart = 
 {{x=-3, y=-1},//none
  {x= 0, y=-2},//fire
  {x= 2, y= 0},//air
  {x= 0, y= 2},//water
  {x=-2, y= 0},//earth
  {x= 1, y=-1},//elec
  {x= 1, y= 1},//ice
  {x=-1, y= 1},//plant
  {x=-1, y=-1},//blood
  {x= 3, y=-1},//light
  {x= 3, y= 1},//dark
  {x=-3, y= 1}}//holy
 
 local chart_x = 80
 local chart_y = 48

 print("^elements",2,2,0)
 print("^opposition ^chart",49,20,0)
 for e=1,#elements-1 do
  local element = lget(elements,e)
  local e_n_c = sub(element.n,1,1)
  print("^@"..e_n_c.."^"..element.n, 4, 4+e*6, 0)
  
  //draw chart
  local offset = lget(chart,e)
  print("^@"..e_n_c, chart_x+offset.x*10, chart_y+offset.y*10, 0)
 end

 local line_x = chart_x+2
 local line_y = chart_y+2
 
 line(line_x, line_y-15, line_x, line_y+15, black)
 line(line_x-15, line_y, line_x+15, line_y, black)
 
 line(line_x-6, line_y-6, line_x+6, line_y+6, black)
 line(line_x-6, line_y+6, line_x+6, line_y-6, black)
 
 line(line_x+30, line_y+6, line_x+30, line_y-6, black)

 print("^opposing elements hurt enemies",2,94,black)
 print("more often. ^same elements will",2,100,black)
 print("rarely hit. ^choose target well!",2,106,black)
 print("^none has no bonus or weakness.",2,114,black)
 print("^holy is good against all!",2,120,black)
end

function draw_settings()
 cls(clear)
 
 print("^settings",2,2,black)
 local bc=nil
 local fc=black
 if s_cur.s == #settings+1 and
  s_cur.o == 1 then
  bc=black
  fc=white
 end
 print("^cancel",50,120,fc,bc)
 bc=nil
 fc=black
 if s_cur.s == #settings+1 and
  s_cur.o == 2 then
  bc=black
  fc=white
 end
 print("^accept",86,120,fc,bc)
 
 for s=1,#settings do
  local setting = lget(settings,s)
  bc=nil
  fc=black
  if s_cur.s == s then
   bc=black
   fc=white
  end
  print(setting.n..":",2,s*7+2,fc,bc)
  
  for o=1,#setting.o do
   local option = lget(setting.o,o)
   bc=nil
   fc=black
   if setting.c == o then
    bc=black
    fc=white
   end
   print(option,20*(o-1)+54,s*7+2,fc,bc)
  
  end
 end
end

function draw_team_building()
 cls(clear)
 draw_party()
 draw_options()
 print("^learned ^elements",2,2,black)
 for e=1,#unlocked_elements do
  local element = lget(unlocked_elements,e)
  local e_n_c = sub(element.n,1,1)
  print("^@"..e_n_c.."^"..element.n, 4, 4+e*6, black) 
 end
 
 print("^party ^l:"..arena.party.level,83,2,black)
 
 if #unlocked_elements > 1 then
  print("^l:^change element",2,95,black)
 end
 if not is_prince(lget(cur.l, cur.i).i) then
  print("^r:^change class",2,103,black)
 end
 print("^b:^element chart",2,111,black)
 print("^a:^finish",2,119, white, black)
end

function draw_arena_state()
 cls(clear)
 draw_arena()
 draw_options()
 if message then
  note(message)
 end
end

function draw_game_over()
 cls(clear)
 draw_arena()
 draw_options()
 if message then
  note(message, red)
 end
end
-->8
-- logic


function check_over()
 if #arena.enemies == 0 then
  push_state(states.battle_over)
 elseif #arena.party == 0 then
  push_state(states.game_over)
 end
end

function opposition(list)
 //returns the opposing list
 if list == arena.enemies then
  return arena.party
 else
  return arena.enemies
 end
end

function toggle_turn()
 if turn == arena.party then
  turn = arena.enemies
  init_auto_turn()
 else
  turn = arena.party
  if auto then
   init_auto_turn()
  end
 end
 cap_cursor()
end

function select()
  
 if cur.l == turn then
  // select attacker
  cur.s = {l=cur.l, i=cur.i}
  toggle_cursor()
  set_stale()
 
 else
  // attack target
  push_state(states.attacking)
 end
end

function deselect()
 if cur.s then
  cur.i = cur.s.i
  cur.s = nil
  toggle_cursor()
  set_stale()
 end
end

function toggle_cursor()
 cur.l = opposition(cur.l)
 cap_cursor()
end

function move_cursor(d)
 cur.i += d
 cap_cursor()
 set_stale()
end

function random_cursor()
 cur.i = rnd_int(1, #cur.l)
 set_stale()
end

function cap_cursor()
 if #cur.l > 0 then
  cur.i = cap_int(cur.i, 1, #cur.l)
 end
end


-- arena

function get_hit_chance(attacker, target)
 if not attacker then return end
 if not target then return end
 if not target.t then return end

	local attack_element = element_by_n(attacker.stats.e)
	local target_element = element_by_n(target.t.stats.e)
	local t_e_i = target_element.i
	local multiplier_char = sub(attack_element.o, t_e_i, t_e_i)
	local chance
	
	if multiplier_char == "1" then
	 chance = 0.25
	elseif multiplier_char == "2" then
	 chance = 0.375  
	elseif multiplier_char == "4" then
	 chance = 0.5
	elseif multiplier_char == "6" then
	 chance = 0.625
	elseif multiplier_char == "8" then
	 chance = 0.75
	else
	 assert(false, chance)
	end
 
 if is_fighter(attacker.i) then
  chance = 1-((1-chance) * (1-chance))
 end
 
 return chance
end

function eliminate(list, target)
 if list == arena.enemies then
  arena.party.score += target.stats.l
 elseif list == arena.party then
  add(arena.party.dead, target)
 end
 del(list, target)
end


-- battle over

function revive()
 local unsorted = {}
 for member in all(arena.party) do
  add(unsorted, member)
  del(arena.party, member)
 end
 //scared to do it in one loop
 for member in all(arena.party.dead) do
  add(unsorted, member)
  del(arena.party.dead, member)
 end
 for s=1,5 do
  for u=1,#unsorted do
   member = lget(unsorted,u)
   if member.s == s then
    add(arena.party, member)
   end
  end
 end
end


-- team building

function change_element(member)
 local member_element_index_in_unlocked
 for u=1,#unlocked_elements do
  local element = lget(unlocked_elements,u)
  local element_n = sub(element.n,1,1)
  if element_n == member.stats.e then
   member_element_index_in_unlocked = u
  end
 end
 assert(member_element_index_in_unlocked)
 member_element_index_in_unlocked += 1
 if member_element_index_in_unlocked > # unlocked_elements then
  member_element_index_in_unlocked = 1
 end
 local new_element = lget(unlocked_elements,member_element_index_in_unlocked)
 member.stats.e = sub(new_element.n,1,1)
 set_stale()
end

function change_class(member)
 if is_fighter(member.i) then
  member.i = caster
  set_stale()
 elseif is_caster(member.i) then
  member.i = fighter
  set_stale()
 end
end


-- settings

function change_settings(d)
 s_cur.s += d
 s_cur.s = cap_int(s_cur.s, 1, #settings+1)
 if s_cur.s > #settings then
  s_cur.o = 1
 else
  s_cur.o = lget(settings,s_cur.s).s
 end
	draw_settings()
end

function change_options(d)
 s_cur.o += d
 if s_cur.s > #settings then
 s_cur.o = cap_int(s_cur.o, 1, 2)
 else
  setting = lget(settings, s_cur.s)
  options = setting.o
  s_cur.o = cap_int(s_cur.o, 1, #options)
		setting.c = s_cur.o
	end
	draw_settings()
end

-->8
-- finish

function finish_auto_turn()
	auto_ticks = nil
 lget(settings,1).s = 1
 set_up_settings()
 message = nil
 set_stale()
end

function save_settings()
 if s_cur.s == #settings + 1 then
  if s_cur.o == 2 then
   for s=1,#settings do
    setting = lget(settings,s)
    setting.s = setting.c
   end
   set_up_settings()
  else
   
  end
  s_cur = nil
  pop_state()
 end
end
-->8
-- graphihcs

function set_stale()
 stale = true
end

note_pos = {x=2, y=83}

function note(string, col1)
 col2 = black
 
 if not col1 then
  col1 = white
  col2 = black
 end
 if caps_lock then
  string = sub(string, 1, 23)
  note_pos.x = 2
 end
 print(string, note_pos.x, note_pos.y, col1, col2, false, caps_lock)
end

function print(s, x, y, pc, bg_col, caps, caps_lock)
 assert(type(s)==string,type(s))
 assert(type(x)==number)
 assert(type(y)==number)
 assert(type(pc)==number)
 
 local offset = 0
 local shift = false
 local elem = false
 for char=1,#s do
  if sub(s,char,char) == "^" then
   shift = true
  elseif sub(s,char,char) == "@" then
   elem = true
  else
   if shift or caps then
    sheet = wide
   else
    sheet = slim
   end
   local ci = ord(sheet, s, char)
   if ci <= 26 and caps_lock then
    sheet = wide
    ci = ord(sheet, s, char)
   end
   if bg_col != nil then
    rectfill(x+offset-1, y-1, x+offset+sheet.tw+1, y+sheet.th, bg_col)
   end
   if elem then
    ci = -1 //space
    local element = element_by_n(sub(s,char,char))
    draw_element(x + offset+2, y+2, element, pc, shift or caps)
   end
   render(sheet, ci, x + offset, y, pc, bg_col)
  	offset += sheet.tw + 1
  	shift = false
  	elem = false
  end
 end
end

function render(sheet, ci, dx, dy, pc1, pc2, pc3, pc4, flipx)
 
 local tw = sheet.tw
 local th = sheet.th
 local off_x = sheet.x
 local off_y = sheet.y
 local layers = sheet.layers
 local rw = flr(128 * layers / sheet.tw) //tiles per row
 
 local c = flr(ci / layers) % (rw / layers)
 local l = ci % layers
 local r = flr(ci / rw)
 local sx = off_x + c * tw
 local sy = off_y + r * th

 for y = 0,th-1 do
  for x = 0,tw-1 do
   local dpixel
   local spixel = sget(sx + x, sy + y)
   if spixel != black then
    local b = inttobin(spixel)
    if layers == 4 then
     if b[l+1] == 1 then
      dpixel = pc1
     end
    elseif layers == 2 then
     local ll = l * 2
     if b[ll+1] == 1 and b[ll+2] == 1 then
      dpixel = pc4
     elseif b[ll+1] == 1 then
      dpixel = pc2
     elseif b[ll+2] == 1 then
      dpixel = pc3
     end
    end
    if dpixel != nil then
     local final_x = dx + x
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
 render(sheet, i-1, x, y, nil, black, nil, white, flipx)
end


function draw_enemies()
 for e in all(arena.enemies) do
  draw_enemy(e.i, e.x, e.y)
 end
end

function draw_party()
 for e in all(arena.party) do
  draw_enemy(e.i, e.x, e.y, true)
 end
 for e in all(arena.party.dead) do
  spr(193, e.x+6, e.y+2)
 end
end


function draw_options()
 local lists = {{l=arena.enemies, x=2},
                {l=arena.party, x=82}}
 if caps_lock then
  lists[2].x = 70
 end

 for l = 1,#lists do
  local list = lget(lists,l)
  for e = 1,#list.l do 
   local en = lget(list.l,e)
   local element = lget(list.l,e).stats.e
   local c = black
   local bg = nil
   local icon = "^ "
   local gem = "@"..element
   local subtarget = false
   local attacker = nil
   if cur.s and cur.s.l and lget(cur.s.l,cur.s.i) then
    attacker = lget(cur.s.l,cur.s.i)
    
    if attacker.i == caster or
     attacker.i == caster +1 or
      attacker.i == caster +2 then
     if
     lget(list.l,e).s == lget(cur.l,cur.i).s +1 or
     lget(list.l,e).s == lget(cur.l,cur.i).s -1 then
      subtarget = true
     end
    end
   end
   if (cur.s and cur.s.l == list.l and cur.s.i == e) or
    (cur.s and cur.s.l != list.l and (cur.i == e or subtarget) and attack_ticks and attack_ticks<20) then
    c = white
    bg = black
     if turn == arena.enemies or
      settings.auto then 
      icon = "^>" //hollow
     else
      icon = "^[" //arrow
     end
    gem = "^"..gem
   elseif cur.l == list.l
    and cur.i != e
     and turn == arena.party
      and not attack_ticks
       and not game_over_ticks 
        and (not settings.auto
         and subtarget) then
    if subtarget then
     icon = "^>"
     gem = "^"..gem
    else
     icon = "^]" //notch
    end
   elseif cur.l == list.l
    and (cur.i == e or subtarget)
     and not attack_ticks then
     if turn == arena.enemies or
      settings.auto then
      icon = "^>" //hollow
     else
      icon = "^[" //arrow
     end
    gem = "^"..gem
   end
   local name = lget(enemy.stats,en.i).n
   if caps_lock then
    name = sub(name,1,10)
   end
   print(icon..gem..name, list.x, 7*e + 86, c, bg, false, caps_lock)
  end
 end
end

function draw_element(x, y, element, ring, wide)
	
	assert(element, x.." "..y.." "..ring)
	local fill = element.c
	
 if wide then
	 if round then
   circfill(x, y, 2, fill)
  end
  circfill(x, y, 1.5, fill)
  if ring != white then
   pset(x, y-1, white)
   pset(x-1, y, white)
  end
  line(x-2, y, x, y-2, ring)
  line(x, y-2, x+2, y, ring)
  line(x+2, y, x, y+2, ring)
  line(x, y+2, x-2, y, ring)
 else
  circ(x-1, y, 1, ring)
  pset(x-1, y, fill)
  if round then
   pset(x-2, y-1, fill)
   pset(x-2, y+1, fill)
   pset(x, y-1, fill)
   pset(x, y+1, fill)
  end
 end
end


function draw_stats()
 local message = ""
 message = message.." l"..arena.party.level
 message = message.." x"..arena.party.score
 message = message.." b"..arena.party.battles
 message = message.." e"..#unlocked_elements
 message = message.." r"..arena.party.luck

 if cur and cur.l and cur.l == opposition(turn) and cur.s and cur.s.i then
  local attacker = lget(turn,cur.s.i)
  local main_target = {t=lget(opposition(turn),cur.i)}

  local hit_chance = get_hit_chance(attacker, main_target)
  hit_chance = sub(""..hit_chance*100,1,2)
  if hit_chance then
   message = message.." h"..hit_chance
  end
 end
 print(message, 0, 0, white, black)

 local state_text = ""
 if states and states.stack then
  for s=1,#states.stack do
   local state = lget(states.stack,s)
   local arrow = " "
   if s == #states.stack then
    arrow = "^["
   end
   print(arrow..state.name, 0, s*7+86, dark, black)
  end
 end
end
__gfx__
affd0b777fdbb37bccc3afffcf000f36e638bff82fff20cac1ceafd2ecf302702001000000000000000000000000000000000000000000000000000000000000
5a02dc3008481427b01fd280b7808769874b4043f000e2c6d2e0d0fe031f65f50110100000000000000000000000000000000000000000000000000000000000
5b339cbbcc4c50278b8716e615282540f04c89f01ddf8f696eb7e7ac6b747fcf7100010000000000000000000000000000000000000000000000000000000000
5a00fc300c6814a78027128165a4a5469066544e5020de120ee1f0e6fce645f52110100000000000000000000000000000000000000000000000000000000000
beee1b775ddbbbdbcc436ffc385358afffa9bbf10fdd07efe63ede27484620720001000000000000000000000000000000000000000000000000000000000000
218872c920008440007e7fbffffcc033080600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24df05484be1c91707d87c07d0e4c83701c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b9bf55d2f1f963f0f4b5dffdffee0ecc0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0bf0c496f87a1d7e568510e52d3301503c100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2fda59fbdb436c1e1dffebbfdfdfd0110a0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444400000000000111000000000000000000444010000000000000000000000000000000000000000055000004000000000000000000011c10c00c00000
0004ccccc4000000000113110044400000000000444450000000005550000000000000455100000000000055550004c000000004040000000010ccddccc00000
004cc4cc4c4000000013311314cc44000000000044dd5000000005557500000000400455571040000000005f5f0004c0000000044444000000c1c44454c0c000
004444ccccc400000015513314c44440000000004dfd71000000055f7d0000000000045d7f1000000044005555004c000004405555cc400000cc5ccccd4cc000
0000445dc5400000004cd5315d44444000011000457533100000057775000000000004577710000004cc555fff504c00004445557fd4c40000c4dcccccc5c000
0000004dddc4000004cd577757544000001751115fd77110000005555555500000000045555510004c4d405555054000045055577dd4c40000c5ccc55d44d000
0001104c5d5c400004c5575555544000017d77775dffd400000055ff5f5f50000004045d7d7710004cc5005000050400040115557fd4c40000c45cddddd4d000
0001555d5554400004c457555544440005f577777777500000005fff555500000000045d7551000004400555000000000040005555cc4000000c5455f5f4c100
0004dd5ddd400000004453571440440004d577555775550000005ff5554000000000045751000000000005005000000000000004444400000000c45d5d54c000
0004dddc5dc400000004415514404440004575554575550000005f555040000000004457710000000000500050000000000000040000440000001cc5dcd4c100
000045ddc5dc40000004415514440000000573551573555000055551404000000044455555100000000055005500000000000040400040000000010c444c1000
000000444444400000001110110000000005514405510000000000000000000000000000000000000000000000000000000000000000000000000001cdc10000
00000400000400000000000000000000000000000000000000000505050000000000000000000000000044510000000000000000000000000000000000000000
00001540444400000000005550000000000004040400000000040555550000000000445110000000000005775000000004555500000000000000000000100000
000005555d444000000005555500000000000444440000000000457ff504000000044dd511044400000015775500000045555550440040000044444011100000
000001575fd4c4000000155df50000000000045544000000000445d55504c0000044cdd7314cc4000001375df71000004055ff50550400000444550511310000
000055775774c400000045fff50000000000055fd40000000000455ff505c0000004cdf7354d4000001337fff7310000005fff50510514040401551544111440
00154555dd5455000000555550000000000015ffd4000000000405fff50540000004455154d5000000113577717500000455550550004c5000055055d40544c4
0001155f75dd5400000045f755000000000005554154000000000555505510000004d7775d500000011355d57575000045575555001434140045404555444444
000015777555c440000005f5540000000000055557d4000000005fd555f500000004df77d500000001137dfd555100004557fd55441000040444444455540400
0000555d55444440000005f5500000000000057d5540000000017d575555000000044df550100000001357f77351100051555500440011404444444445104044
00015554ccc4000000000155500000000000055d404000000004d557500500000004455d54000000000157555373310000555500000000004444544455544440
00155440444000000000055555000000000005555040000000044551550500000004455511000000000055545511110005555550000000000044415551000000
00040000000000000000000000000000000000000000000000000000000000000000000000000000000011110110000000000000000000000444440444400000
00000010100000000000000444000000000400004400000011111011000000000000044400000000000000000000000000000000000000000000000000000000
00000011110000000000004445510000000444044000000001111101110000000000444c400000000000000000f0000000001100000000000000005101000000
000000111110000000000044dd73100000044445504044400011110113100000000044cc40000000000000040000000000011310000000000000444511111400
000000113130000000400044dd5110000000455414c440400001111133101100000444c401100000000000044003f00000113310110000000000044d73314000
000110133354000000040040573141000044555545500000000001111111310000044cdc5331100000000004440330000011111131000100000014dff1140000
0011111115454000004400045d55c4000004445555550400000001377511100000044d7df5333100000004455444400001333111101011000000145537500000
0011011315111000004400444577540000000441510444000011045dfd51000000005d77733131000001055555447400015131110011110000015cddd7510000
00100013155000000454015d44511000000005111500000000015ccdff50000000017f7f7333310000015555355400000401375404015000000575d753110000
001000553144000005c4133755d7100000004044105400000015444555500000001315dd551331000445451111044000041555555c5500000004175533310000
0040155555440000054d7555ff7710000000400404004000000004455510000001155ddddd511000000440011000000000515555555100000000055551111000
000440115550000004d5d4cc55d5000000000000004000000000000110110000044dd55555d50000000040000000000000011511511000000000444154011000
00000000000000000044444444400000000000000000000000000001101100000044444444400000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000404000000000000000000000000000000000000000
00000000000000000000000111000000000000044400000000000000444000000000001010000000000000444411000000000040000000000000004044405000
00000000000000000000041115100000045040445440000000000004ccc400000000001110000000000000545d51100000000444000000000000151544451500
0000000000000000000045517571000000555045dc4040400014004cc44c4000004400113100000000011455fd51000000004444400000000001737354555110
000004440000000000045315515400000015115ddc5105000050005c44c4c40004400113314000000011005ddd500000000004c400000000001735555c4d7500
000444c444000000004131557710400000110554544511000050155dd454440004450111105144000015404555154000000044c4005010000013553575457100
004c4c4c4c4000000001311551011000001100445c40100000505555dd55500004554455557540000055004d5555400000044455500515000013355554d55110
0044c555d44044400000111111111000000110454c400000004555555ddd400000455455755c44000055145dd555000000044555550551000001715754441400
0044575575455400000111111110000000000004450100000045554554551000000055555404444000455555dd51000000044555514550000004151555551100
04455155551555400001101111000000000000044410000000441044144000000004015154004400000555155550000000005555555510000051515151511000
00045500554000000000001111000000000000444440000000445504514400000004515514400000000011554155000000155554555100000115111515001000
00000000000000000000011101100000000000000000000000000000000000000000000000000000000011111111100000000000000000000000004000000000
00000004000000000000000003333300000000000000000000000000000000000000444000000000000044444440000000000000000000000000000000000000
000044444000000000000000331113000044440404470000000000155d00000000000c15554440000004ccccccd5500000000455110044400000001111000000
000004444400000000000003753313000304c4447c43300000c00117571000c000004557571c0000004ccccccdffd5000000c513131c40400004455757144000
0004155c4c04000000000077df73130003034c44f4031300004d131151310c4000011f1d1d750000004ccc44c5fdcc400001575511750000004ddfdddd7d4000
0044554444555000000377fdfdf5300003330074330030000017f3377f71c40000133f377f3d000004cc4cc44ddccc50001337733375400004dffffffffdc400
00045455dcd500000035df5f5d573000031134373334000000055355f514440000011d155d14000004ccc444557dd5100001115515504400044ddddddddc4c40
000055555c5c400000375d7d55f700000311743751570000000047117400400000000c4444400000004ccc4455df7100000010454540000004cccc44cc4ccc40
000115757d5c40000007f555d7f40000003740317570000000000031d700000000001514410000000004cc4d5c4510000044000544400000044cf447cc444400
0011355555d4000000375d5dff44000000044031111300000000000f57000000000104054010000000005455440000000004410045000000004cc404cc440000
00133555515000000035557d5700000000004447531300000000003530400000000000041500000000011155541100000004454545000000044fcc744fc44000
00115551551000000031177713000000000004443330000000000077004400000000000404000000001005545550100000004445400000000444444044444000
00000000000000000003330330000000000000000000000000000000000000000000000000000000000044040444000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000444400000044000000000444000400100000044400000000111100044440000
00000111000000000000045115400000000000444000000000000000011000004cccc404404c5000000014dc0000440100011154c400000001333555cccc4000
00001357551000000040115504104000000004ccc4000000000000010100000004cccc4cc4cc5000114015d111004c500011357dc400000001777fffddccc400
000055ddf7310000000571544440440000000445540000000000000015554000004c4c4cc4d511100d5017d113104c500011155440454100055fd5fffdddc400
00005fffdd5310000041554444440000000104ddd500000000000005554444000004ccc55cc410001d55137517500c41011355444444100005d5df7fd7ff5410
000175d5f551000000101444d500000000015c5757550000000004554451400000004c57f540100011d5515115d144500117737d54110110045df75dd777d411
0005dddffd54000000001045d550000000005ddd5d4d50000004455c40400000000044d7f5d57100111d515557575400011111555403070004d57d5d777d5401
004cd5d7754400000000115575750000000004557544100000444555400000000000455ddd557100110153155551140001155544dc435f50044df555ff55f501
004c405771444000000011555d100000000004d5f50000000444445555040400000015dd5c401000111055034cc70110015ddd4ccc55dd4004455d5f75dd5511
004cc5331354400000001055550000000000045555000000044455555555540000005d7515c410001115451755555011015dddc4c4ccdc4004445555dd551110
00444411111000000000145555500000000045555550000000444455555444400001557315541000131311555555411301155dd4c4c5c5000015455555111100
00000000000000000000440404440000000000000000000000004444444400000000001100000000000000000000000000000440404140000001155511011111
000000000000000000044510011000000000ccc0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000040045111000004453111110000000c300d11ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000044045c51500015445733333100000c00455111c000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000044445cc50440131457331131310000f04455713c000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000400454405040131457333333310003f344d5d110c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005dc400001355577577131100003c5577513ddcc000000000000000000000000000000000000000000000000000000000000000000000000000000000
04404004554440001777577751313100c0345d57f77554cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0044415515504000577775513333110000444dddf7554cc000000000000000000000000000000000000000000000000000000000000000000000000000000000
001411111550000053777773111133500c44c4dd575cc30000000000000000000000000000000000000000000000000000000000000000000000000000000000
001111115550000013775773355577540c44c4555110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001115555451000177775777755577100cc4555551100c000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001011001010000111111111111111000444404440000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d00dd00ddddd000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dd00ddd00d000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d00070dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd0ddd0ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd0dd00dd000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d000ddd000ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0ddd0ddd000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0ddd0ddd000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dd000dddd0ddd0ddddddddddd0dddd0ddddd00000d00ddd0ddddddd0dddddd0dddd00dddddddddddddd0000ddd0dddddd0ddd0d0ddddd000ddd00ddd0ddddddd
ddd0dddd0d0ddd0ddddd00dd0d0ddd0dddddd0ddddd0dd0d0d0d0d0d0d00dd00dd0ddddddddddddddddd0dd0ddd0ddddd00dd0d0dddddd0dddd00dd00ddddddd
ddd0dddd000dd00dd00d0d0d000dd00dddddd00dddd0dd000d000d000d0d0d0dddd0dddddddddddddddd000ddd00dd00d0dddd00dddddd0ddddddddd0ddddddd
ddd0dd0d0ddd0d0d0ddd0d0d0ddd0d0dddddd0ddddd0dd0ddd0d0d0ddd0d0d0d0ddd0ddddddddddddddd0dddd0d0d0ddd0d0ddd0dddddd0dd0d00ddd0ddddddd
dd00000dd00dd00d0ddd0d0dd00dd00ddddd00000d000dd00d0d0dd00d0d0dd0dd00ddddddddddddddd000dddd00d0dddd0dd00dddddd00000d00dd000dddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddd505dd0ddd0dddddddddd0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddd50705d00dd0dd0dd00dd0d0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddd07550d0d0d0d0d0d0d0d000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddd50505d0dd00d0d0d0d0d0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddddddddddddddddddd
ddddd505dd0ddd0dd0dd0d0dd00ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd07700dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd07770dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00d0000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000700ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0007770ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d00700ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d00000ddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000000ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd07700dddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d07770dddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00d0000dddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0007770ddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd007770ddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d0070dddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d0d0dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd07700dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd07770dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00d0000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0700000dddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000700dddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d0700dddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d0000dddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd07700dddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d07770dddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00d0000dddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0007770ddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd007770ddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d0070dddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd07700dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd07770dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00d0000dddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000700ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0007770ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d00700ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0d00000ddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000000ddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddd0dddd505dd000ddddddddddddddd0d0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddd0ddd00d0dddd0dddddddddddddddd
dd00d0dd50705dd0d0dd0d0d00dd00dd0d0ddddddddddddddddddddddddddddddddddddddddddddddddddddd505d0ddd0ddd0d0ddd00dd0d0ddddddddddddddd
dd000d0d00550000000d0d000d0d0d00d000ddddddd0dd00ddd0ddddddd0dddddd0ddddddddddddddddddddd050d0dddddd00dd0dd0ddd000dd00ddddddddddd
dd00d0dd00500dd00d0d0d0d0d000d0d0d0d0ddddd0d0dd0dd0d0d0d0d0d0d00dd00dddddddddddddddddddd505d0ddd0d0d0ddd0d0d0d0ddd0ddddddddddddd
ddd00dddd5050d000000d0000d0d0d0000000ddddd000dd0dd000d000d000d0d0d0dddddddddddddddddddddddddd000ddd00d00ddd0ddd00d0ddddddddddddd
ddd0dd0d00dd0ddd0d0d0d0d0d0d0d0d0d0ddddddd0dddd0dd0ddd0d0d0ddd0d0d0d0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dd00000d00ddd000dd0d0dd00d0d0dd0ddd00dddddd00d000dd00d0d0dd00d0d0dd0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddd0000d0dddddddd00d0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000dd0ddd0dd0ddd0dddd0dddddddddddd
dddddddd505d0ddddd0dddd0dd0ddd00dddddddddddddddddddddddddddddddddddddddddddddddddddddddd505dd0dddddddd0d0d0ddd00dd0d0ddddddddddd
dddddddd050d0dd00d00dd0d0dd0dd0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddd050dd00ddd00ddd00d00dd0ddd000dd00ddddddd
dd0000dd005d00000d0d0d000ddd0d000dd0dddddddddd00ddd0ddd00dd00ddddddddddddddddddddddddddd505dd0ddddd0dd0d0d0d0d0d0d0ddd0ddddddddd
ddd0dd0d00dd00000d0d0dd00d00dd000d0d0dddddd00dd0dddd0d0ddd0ddddddddddddddddddddddddddddddddd000ddd000dd0dd0d0dd0ddd00d0ddddddddd
ddd000dddddd0ddddd00ddd00d0d0dd00d000ddddd0dddd0ddd00dd0ddd0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddd0dd0d00dd0ddd0d0d0d0d0d0d0d0d0d0ddddddd0dddd0dd0d0ddd0ddd0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dd000d0d00ddd000dd0d0dd00d0d0dd0ddd00dddddd00d000dd00d00dd00dddddddddddddddddddddddddddddddd0000ddddddd0ddddddddddd0dddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd505dd0dd0ddddddddd00ddd00d0d0ddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd050dd000ddd00d00dd0d0d0ddd000ddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd505dd0dddd0dddd0dd0d0d0ddd0ddddddddddddd
dd000ddd00dd00000d00ddd0ddddddd0dddddd0ddddddddddd0dddd0dddddd0ddddddddddddddddddddddddddddd000ddd0ddd000d0d0dd00dd00ddddddddddd
ddd0d0dd00ddd0ddddd0dd0d0d0d0d0d0d00dd00ddddddd00d0ddddd0ddddd00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddd000ddddddd00dddd0dd000d000d000d0d0d0ddddddd0ddd00ddd00dd00d0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddd0dd0d00ddd0ddddd0dd0ddd0d0d0ddd0d0d0d0ddddd0ddd0d0d0d0d0ddd0d0ddddddddddddddddddddddddddd00000dd0ddd0dd0ddd0dddd0dddddddddddd
dd0000dd00dd00000d000dd00d0d0dd00d0d0dd0ddddddd00d0d0dd00d0dddd0dddddddddddddddddddddddd505dd0dddddddd0d0d0ddd00dd0d0ddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd050dd00ddd00ddd00d00dd0ddd000dd00ddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd505dd0ddddd0dd0d0d0d0d0d0d0ddd0ddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddd000dd0dd0d0dd0ddd00d0ddddddddd
ddd000dd00dd00000dd0ddddddd0ddd00d0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dd0ddd0d00ddd0dddddddd00dddddd0ddd0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dd00000dddddd00ddd00dd0d0d00ddd0dd00ddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddd0ddd00d0dddd0dddddddddddddddd
dd0ddd0d00ddd0ddddd0dd0d0dd0dddd0d0d0ddddddddddddddddddddddddddddddddddddddddddddddddddd505d0ddd0ddd0d0ddd00dd0d0ddddddddddddddd
dd0ddd0d00dd000ddd000d0d0d000d00dd0d0ddddddddddddddddddddddddddddddddddddddddddddddddddd050d0dddddd00dd0dd0ddd000dd00ddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd505d0ddd0d0d0ddd0d0d0d0ddd0ddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddd00d00ddd0ddd00d0ddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

