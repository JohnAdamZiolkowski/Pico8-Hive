-- draw

function print(string, x, y, pc, caps, bg_col)
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
   local ci = ord(sheet, string, char)
   if bg_col != nil then
    rectfill(x+offset-1, y-1, x+offset+sheet.tw+1, y+sheet.th, bg_col)
   end
   render(sheet, ci, x + offset, y, pc, bg_col)
  	offset += sheet.tw + 1
  	shift = false
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
   if spixel != 0 then
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
 render(sheet, i, x, y, nil, 0, nil, 7, flipx)
end

function draw_arena()
 cls(13)
 for x = 0,15 do
  spr(192, x*8, 0)
 end
 draw_enemies()
 draw_party()
 line(0,94,128,94)
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
end

function draw_options()
 local lists = {{l=arena.enemies, n="enemies", x=2},
          {l=arena.party, n="party", x=80}}

 for l = 1,#lists do
  local list = lists[l]
  for e = 1,#list.l do
   local en = list.l[e]
   //local c = get_element(en.i).c
   local c = 0
   local bg = nil
   local icon = "^ "
   if (cur.s.l == list.n and cur.s.i == e) or
    (cur.s.l != list.n and cur.i == e and attacking and attack_ticks<20) then
    c = 7
    bg = 0
    icon = "^{"
   elseif cur.l == list.n and cur.i != e and turn == "party" and not attacking then
    icon = "^]" //notch
   elseif cur.l == list.n and cur.i == e and not attacking then
    icon = "^[" //arrow
   end
   print(icon..enemy.stats[en.i+1].n, list.x, 6*e + 91, c, false, bg)
  end
 end
end
