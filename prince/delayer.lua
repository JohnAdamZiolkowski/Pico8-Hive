function inttobin(b)
 t={}
 a=0
 for i = 0,4 do
  a=2^i
  t[i+1]=band(a,b)/a
 end
 return t
end

chars=" abcdefghijklmnopqrstuvwxyz0123456789"
s2c={}
c2s={}
for i=1,#chars do
 local c=i-2
 local s=sub(chars,i,i)
 c2s[c]=s
 s2c[s]=c
end

function ord(s,i)
 return s2c[sub(s,i or 1,i or 1)]
end

cls(13)

wide = {
 x = 0,
 y = 0,
 tw = 5,
 th = 5,
 layers = 4
}

slim = {
	x = 0,
	y = 5,
 tw = 3,
 th = 5,
 layers = 4
}

enemy = {
	x = 0,
	y = 10,
 tw = 16,
 th = 12,
 layers = 2
}

function print(ps, px, py, pc, draw_wide)
 if draw_wide then
  render(ps, px, py, pc, wide)
 else
  render(ps, px, py, pc, slim)
 end
end

function render(ps, px, py, pc, sheet)

 for char=1,#ps do
  ci = ord(ps,char)

  tw = sheet.tw
  th = sheet.th
  off_x = sheet.x
  off_y = sheet.y
  layers = sheet.layers

  local c = flr(ci / layers)
  local l = ci % layers
  local sx = off_x + c * tw
  local sy = off_y
  local dx = px + (char-1) * (tw+1)
  local dy = py

  for y = 0,th-1 do
   for x = 0,tw-1 do
    local spixel = sget(sx + x, sy + y)
    local b = inttobin(spixel)
    if b[l+1] == 1 then
     spixel = pc
     pset(dx + x, dy + y, spixel)
    end
   end
  end
 end
end

function draw_enemy()

end

print("abcdefghijklm", 1, 10, 0, true)
print("nopqrstuvwxyz", 1, 20, 0, true)
print("0123456789   ", 1, 30, 0, true)

print("abcdefghijklm", 1, 40, 0, false)
print("nopqrstuvwxyz", 1, 50, 0, false)
print("0123456789   ", 1, 60, 0, false)

print("hello world", 1, 80, 0, true)
print("hello world", 1, 90, 0, false)

//draw_enemy(126, 100, 100)