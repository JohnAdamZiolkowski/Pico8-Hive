-- draw

function note(string, col1)
 col2 = black

 if not col1 then
  col1 = white
  col2 = black
 end
 print(string, note_pos.x, note_pos.y, col1, col2)
end

function print(string, x, y, pc, bg_col, caps)
 assert(type(string)=="string",type(string))
 assert(type(x)=="number")
 assert(type(y)=="number")
 assert(type(pc)=="number")

 local offset = 0
 local shift = false
 local elem = false
 for char=1,#string do
  if sub(string,char,char) == "^" then
   shift = true
  elseif sub(string,char,char) == "@" then
   elem = true
  else
   if shift or caps then
    sheet = wide
   else
    sheet = slim
   end
   local ci = ord(sheet, string, char)
   if bg_col != nil then
    rectfill(x+offset-1, y-1, x+offset+sheet.tw+1, y+sheet.th, bg_col)
   end
   if elem then
    ci = -1 //space
    local element = element_by_n(sub(string,char,char))
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

function draw_arena()
 cls(clear)

 //draw stones
 for x = 0,15 do
  spr(192, x*8, 0)
 end
 draw_enemies()
 draw_party()
 line(0,94,128,94,black)
 draw_options()
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
                {l=arena.party, x=80}}

 for l = 1,#lists do
  local list = lists[l]
  for e = 1,#list.l do
   local en = list.l[e]
   local element = list.l[e].stats.e
   assert(element)
   local c = black
   local bg = nil
   local icon = "^ "
   local gem = "@"..element
   local subtarget = false
   local attacker = nil
   if cur.s and cur.s.l and cur.s.l[cur.s.i] then
    //assert(false, cur.s.l[cur.s.i])
    attacker = cur.s.l[cur.s.i]

    if attacker.i == caster or
     attacker.i == caster +1 or
      attacker.i == caster +2 then
     if
     list.l[e].s == cur.l[cur.i].s +1 or
     list.l[e].s == cur.l[cur.i].s -1 then
      subtarget = true
     end
    end
   end
   if (cur.s and cur.s.l == list.l and cur.s.i == e) or
    (cur.s and cur.s.l != list.l and cur.i == e and attack_ticks and attack_ticks<20) then
    c = white
    bg = black
     if turn == arena.enemies or
      auto then
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
        and not auto then
    if subtarget then
     icon = "^>"
     gem = "^"..gem
    else
     icon = "^]" //notch
    end
   elseif cur.l == list.l
    and cur.i == e
     and not attack_ticks then
     if turn == arena.enemies or
      auto then
      icon = "^>" //hollow
     else
      icon = "^[" //arrow
     end
    gem = "^"..gem
   end
   print(icon..gem..enemy.stats[en.i].n, list.x, 6*e + 91, c, bg)
  end
 end
end

function element_by_n(n)
 assert(type(n)=="string")
 for element in all(elements) do
	 if n == sub(element.n, 1, 1) then
	  return element
	 end
	end
	assert(false, "unknown element: "..n)
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

function draw_element_chart()
 cls(clear)
 state = "element_chart"

 local chart =
 {{x=-3, y=-1},{x=-3, y=1},
  {x=3, y=-1},{x=3, y=1},
  {x=0, y=-2},{x=1, y=-1},
  {x=2, y=-0},{x=1, y=1},
  {x=0, y=2},{x=-1, y=1},
  {x=-2, y=0},{x=-1, y=-1}}

 local chart_x = 80
 local chart_y = 48

 print("^elements",2,2,0)
 print("^opposition ^chart",49,20,0)
 for e=1,#elements-1 do
  local element = elements[e]
  local e_n_c = sub(element.n,1,1)
  print("^@"..e_n_c.."^"..element.n, 4, 4+e*6, 0)

  //draw chart
  local offset = chart[e]
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