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
 chars = " abcdefghijklmnopqrstuvwxyz0123456789",
 x = 0,
 y = 0,
 tw = 5,
 th = 5,
 layers = 4
}

slim = {
 chars = " abcdefghijklmnopqrstuvwxyz0123456789.,!?:'+-*/()",
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

function print(string, x, y, pc)
 local offset = 0
 for char=1,#string do

  ci = ord(string, char)
  sheet = slim
  render(sheet, ci, x + offset, y, pc)
 	offset += sheet.tw + 1
 end
end

function render(sheet, ci, dx, dy, pc)

 tw = sheet.tw
 th = sheet.th
 off_x = sheet.x
 off_y = sheet.y
 layers = sheet.layers

 local c = flr(ci / layers)
 local l = ci % layers
 local sx = off_x + c * tw
 local sy = off_y

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

function draw_enemy()

end

print("abcdefghijklm", 1, 10, 0)
print("nopqrstuvwxyz", 1, 20, 1)
print("0123456789   ", 1, 30, 2)

print("abcdefghijklm", 1, 40, 3)
print("nopqrstuvwxyz", 1, 50, 4)
print("0123456789   ", 1, 60, 5)

print("hello world", 1, 80, 6)
print("hello world", 1, 90, 7)

//draw_enemy(126, 100, 100)