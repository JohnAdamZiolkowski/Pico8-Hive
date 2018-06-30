function inttobin(b,d)
 t={}
 a=0
 for i = 0,15 do
  if d==1 then a=0.5^(16-i) else a=2^i end
  t[i+1]=band(a,b)/a
 end
 return t
end


cls(1)
th = 5
tw = 5

for x=1,16 do
for y=1,8 do
 print(inttobin(x, 0)[y], x*4, y*6+72)
end
end
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
    //if spixel == 16 then spixel = 16
    //if l == 0 then
     //spixel = spixel % 2
     //spixel = spixel - l * 2
     //spixel = spixel % 4
     //spixel = spixel + l
    //spixel = spixel+(l*4)
    //if spixel < 0 then spixel = 0 end
     b = inttobin(spixel+1)
     if b[l+1] == 0 then
     	spixel = 0
     else
      spixel = 13
     end
    //end


    //elseif l == 1 then
    // if spixel ==
    //elseif l == 2 then
    //
    //elseif l == 3 then
    //
    //end
    //spixel =
    pset(dx + x + 40, dy + y, spixel)
   end
  end

  sspr(sx,sy,sw,sh,dx,dy)
 end
end