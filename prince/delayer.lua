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

function ord(sheet, s, i)
 assert(type(sheet)=="table")
 assert(type(s)=="string")
 assert(type(i)=="number")
 ci = sheet.s2c[sub(s,i or 1,i or 1)]
 assert(ci, s..".."..i)
 return ci
end

cls(13)

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
 layers = 2
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

print("abcdefghijklm", 1, 10, 0, true)
print("nopqrstuvwxyz", 1, 20, 1, true)
print("0123456789   ", 1, 30, 2, true)
print(".,!? :'+- */() {}[]", 1, 40, 10, true)

print("abcdefghijklm", 1, 50, 11)
print("nopqrstuvwxyz", 1, 60, 4)
print("0123456789.,!?:'+-*/()", 1, 70, 5)

print("hello world", 1, 90, 6, true)
print("hello world", 1, 100, 7)
print("^]^{^]^hello ^world!^]^{^]", 1, 110, 9)
//draw_enemy(126, 100, 100)