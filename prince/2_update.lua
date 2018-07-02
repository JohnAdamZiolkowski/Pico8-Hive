-- update

function check_over()
 if #arena.enemies == 0 then
  print("^no more enemies remain!", 2, 118, 7, false, 0)
  state = "over"
 elseif #arena.party == 0 then
  print("^no more party members remain!", 2, 118, 8, false, 0)
  state = "over"
 end
end

function _update()
 if state == "arena" then
  if attacking then
   update_attack()
  else
   if turn == "party" then
    if btnp(⬅️) or btnp(➡️) then
     //toggle_cursor()
     //cap_cursor()
     //draw_arena()
     //draw_cursor()
    elseif btnp(⬆️) then
     cur.i -= 1
     cap_cursor()
     draw_arena()
     draw_options()
    elseif btnp(⬇️) then
     cur.i += 1
     cap_cursor()
     draw_arena()
     draw_options()
    elseif btnp(🅾️) then
     select()
    elseif btnp(❎) then
     deselect()
   	end
   elseif turn == "enemies" then
    update_enemy_turn()
   else
    assert(false, turn)
   end
  end
 elseif state == "over" then

 end
end

function toggle_turn()
 if turn == "party" then
  enemy_turn()
 else
  turn = "party"
 end
 cap_cursor()
end

function select()
 local sets = {{"party", "enemies"},
               {"enemies", "party"}}

 for set in all(sets) do
  if turn == set[1] then
   if cur.l == set[1] then
    cur.s = {l=cur.l, i=cur.i}
    toggle_cursor()
    draw_arena()
    draw_options()
    return
   else
    attack()
    return
   end
  end
 end
end

function deselect()
 if cur.s.l and cur.s.i then
  cur.s = {l=nil, i=nil}
  toggle_cursor()
  draw_arena()
  draw_options()
 end
end

function toggle_cursor()
 if cur.l == "enemies" then
  cur.l = "party"
 else
  cur.l = "enemies"
 end
 cap_cursor()
end

function cap_cursor()
 local sets = {{n="enemies", l=arena.enemies},
               {n="party", l=arena.party}}
 for set in all(sets) do
  if cur.l == set.n then
   if cur.i < 1 then
    cur.i = 1
   elseif cur.i > #set.l then
    cur.i = #set.l
   end
  end
 end
end

function attack()
 attacking = true
 attack_ticks = 0

 a_id = nil
 t_id = nil
 attacker = nil
 target = nil

 if turn == "party" then
  a_id = arena.party[cur.s.i].i+1
  t_id = arena.enemies[cur.i].i+1
 else
  a_id = arena.enemies[cur.s.i].i+1
  t_id = arena.party[cur.i].i+1
 end
 attacker = enemy.stats[a_id].n
 target = enemy.stats[t_id].n

	draw_arena()
	draw_options()
end

function update_attack()

 if attack_ticks == 0 then
  print(attacker.." attacks "..target, 0,0, 7, false, 0)

 elseif attack_ticks == 30 then

  cur.s = {l=nil, i=nil}

  local hit = rnd(2) > 1
  local text = "^but it missed!"
  if hit then
   text = "^hit! "..target.." is gone"
   eliminate()
  end

  draw_arena()
  draw_options()
  print(text, 0, 0, 7, false, 0)

 elseif attack_ticks == 60 then
  cur.s = {l=nil, i=nil}
  attacking = false
  toggle_turn()
  draw_arena()
  draw_options()
  check_over()
 end
 attack_ticks += 1
end

function eliminate()
 if cur.l == "enemies" then
  del(arena.enemies, arena.enemies[cur.i])
 else
  del(arena.party, arena.party[cur.i])
 end
end

function enemy_turn()
 enemy_ticks = 0
 turn = "enemies"
end

function update_enemy_turn()
 enemy_ticks += 1

 if enemy_ticks == 20 then
  cur.i = flr(rnd(#arena.enemies)) + 1
  draw_arena()
  draw_options()
 elseif enemy_ticks == 40 then
  select()
 elseif enemy_ticks == 60 then
  cur.i = flr(rnd(#arena.party)) + 1
  draw_arena()
  draw_options()
 elseif enemy_ticks == 80 then
  select()
 end
end