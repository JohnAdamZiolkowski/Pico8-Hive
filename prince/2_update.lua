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
   if turn == arena.party then
    if not auto then
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
    else
     update_auto_turn()
    end
   elseif turn == arena.enemies then
    update_enemy_turn()
   else
    assert(false, turn)
   end
  end
 elseif state == "over" then

 end
end

function opposition(list)

 if list == arena.enemies then
  return arena.party
 else
  return arena.enemies
 end

end

function toggle_turn()
 if turn == arena.party then
  enemy_turn()
 else
  turn = arena.party
  if auto then
   auto_turn()
  end
 end
 cap_cursor()
end

function select()

 if cur.l == turn then
  // select attacker
  cur.s = {l=cur.l, i=cur.i}
  toggle_cursor()
  draw_arena()
  draw_options()

 else
  // attack target
  attack()
 end
end

function deselect()
 if cur.s then
  cur.s = nil
  toggle_cursor()
  draw_arena()
  draw_options()
 end
end

function toggle_cursor()
 cur.l = opposition(cur.l)
 cap_cursor()
end

function cap_cursor()
 local sets = {arena.enemies,
               arena.party}
 for set in all(sets) do
  if cur.i < 1 then
   cur.i = 1
  elseif cur.i > #set then
   cur.i = #set
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

 a_id = turn[cur.s.i].i+1
 t_id = opposition(turn)[cur.i].i+1

 attacker = enemy.stats[a_id].n
 target = enemy.stats[t_id].n

	draw_arena()
	draw_options()
end

function update_attack()

 if attack_ticks == 0 then
  print(attacker.." attacks "..target, 0,0, 7, false, 0)

 elseif attack_ticks == 30 then

  cur.s = nil

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
  cur.s = nil
  attacking = false
  toggle_turn()
  draw_arena()
  draw_options()
  check_over()
 end
 attack_ticks += 1
end

function eliminate()
 del(cur.l, cur.l[cur.i])
end

function enemy_turn()
 enemy_ticks = 0
 turn = arena.enemies
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


function auto_turn()
 auto_ticks = 0
end

function update_auto_turn()
 auto_ticks += 1

 if auto_ticks == 20 then
  cur.i = flr(rnd(#cur.l)) + 1
  draw_arena()
  draw_options()
 elseif auto_ticks == 40 then
  select()
 elseif auto_ticks == 60 then
  cur.i = flr(rnd(#cur.l)) + 1
  draw_arena()
  draw_options()
 elseif auto_ticks == 80 then
  select()
 end
end