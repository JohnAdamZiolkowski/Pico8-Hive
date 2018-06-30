cls(1)
th = 5
tw = 5

sw = tw
sh = th

for r = 0, 12 do
for l = 0, 3 do
sx = 0 * tw
sy = r * th
dx = l * (tw + 1) + 15
dy = r * (th + 1)

for y = 0, th-1 do
for x = 0, tw-1 do
spixel = sget(sx + x, sy + y)
pset(dx + x + 40, dy + y, spixel)
end
end

sspr(sx, sy, sw, sh, dx, dy)
end
end