function inttobin(b)
 t={}
 a=0
 for i = 0,15 do
  a=2^i
  t[i+1]=band(a,b)/a
 end
 return t
end


cls(13)
th = 5
tw = 5

sw = tw
sh = th


for r = 0,12 do
 for l = 0,3 do
  sx = 0 * tw
  sy = r * th
  dx = l * (tw+1) + 15
  dy = r * (th+1)

  for y = 0,th-1 do
   for x = 0,tw-1 do
    spixel = sget(sx + x, sy + y)
    b = inttobin(spixel)
    if b[l+1] == 1 then
     spixel = 0
    else
     spixel = 13
    end
    pset(dx + x + 40, dy + y, spixel)
   end
  end

  sspr(sx,sy,sw,sh,dx,dy)
 end
end