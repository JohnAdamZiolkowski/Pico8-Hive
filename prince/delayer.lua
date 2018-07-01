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
 en_el_c=sub(enemy.elements,eni+1,eni+1)
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

cls(13)
elements = {
 {n="none", c=5},
 {n="god", c=14},
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
 elements = "nnnnnnnnnnnnvvvvvvvvvvvvvvvvvvfffeeeaaapppwwwiiirrrbbbllldddgggnnnnnffeeaappwwiirrbbllddggfeapwirbldgg",
	x = 0,
	y = 10,
 tw = 16,
 th = 12,
 layers = 2,
}


function print(string, x, y, pc, caps)
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

//print("^]^{^]^hello ^world!^]^{^]", 1, 118, 9)

//for r = 0,8 do
// for c = 0,7 do
//  i = (r+4) * 8 + c
//  if i < 102 then
//   draw_enemy(i, c*16, r*12+8)
//  end
// end
//end

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
  if s == 2 then
   local member = {
  		i = 21,
  		x = 80 - (s % 2) * 12 ,
  		y = s * 16 + 16
  	}
  	add(arena.party, member)
  elseif rnd(5) > 2 then
   local id = flr(rnd(2))
   if id == 0 then
    id = 24
   else
    id = 27
    end
  	local member = {
  		i = id,
  		x = 80 - (s % 2) * 12 ,
  		y = s * 16 + 16
  	}
  	add(arena.party, member)
 	end
 end
end

function draw_arena()
 draw_enemies()
 draw_party()
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
end

set_up_arena()

draw_arena()

function check_over()
 if #arena.enemies == 0 then
  print("^no more enemies remain!", 1, 118, 9)

 //elseif #arena.party == 0 then

 end
end

check_over()