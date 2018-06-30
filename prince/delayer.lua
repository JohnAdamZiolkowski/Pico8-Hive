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
th = 5
tw = 5

sw = tw
sh = th

function print(ps, px, py, pc)
 for char=1,#ps do
  ci = ord(ps,char)

  local l= ci % 4
  local r= flr(ci / 4)
  local sx = 0 * tw
  local sy = r * th
  local dx = px + (char-1) * (tw+1)
  local dy = py

  for y = 0,th-1 do
   for x = 0,tw-1 do
    local spixel = sget(sx + x, sy + y)
    local b = inttobin(spixel)
    if b[l+1] == 1 then
     spixel = 0
    else
     spixel = 13
    end
    pset(dx + x, dy + y, spixel)
   end
  end
 end
end

print("hello world", 1, 10, 0)
print("0123456789", 1, 20, 0)