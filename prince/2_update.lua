-- update

function check_over()
 if #arena.enemies == 0 then
  battle_over()
 elseif #arena.party == 0 then
  game_over()
 end
end

function _update()
 if state == "arena" then
  if attack_ticks then
   update_attack()
  elseif over_ticks then
   update_battle_over()
  elseif game_over_ticks then
   update_game_over()
  else
   if turn == arena.party then
    if not auto then
     if btnp(⬅️) or btnp(➡️) then
      draw_element_chart()
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
    update_auto_turn()
   else
    assert(false, turn)
   end
  end
 elseif state == "element_chart" then
  if btnp(🅾️) or btnp(❎)
   or btnp(⬅️) or btnp(➡️)
   or btnp(⬆️) or btnp(⬇️) then
   draw_arena()
   draw_options()
   state = "arena"
  end
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
  turn = arena.enemies
  auto_turn()
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
 if cur.i < 1 then
  cur.i = 1
 elseif cur.i > #cur.l then
  cur.i = #cur.l
 end
end

function attack()
 attack_ticks = 0

 attacker = turn[cur.s.i].stats.n
 assert(attacker)
 target = opposition(turn)[cur.i].stats.n
	assert(target)

	draw_arena()
	draw_options()
end

function update_attack()

 attack_ticks += 1

 if attack_ticks == 1 then
  note(attacker.." attacks "..target)

 elseif attack_ticks == 3*delay then

  cur.s = nil

  local hit = rnd(2) > 1
  local text = "^but it missed!"
  if hit then
   text = "^hit! "..target.." is gone"
   eliminate()
  end

  draw_arena()
  draw_options()
  note(text)

 elseif attack_ticks == 6*delay then
  cur.s = nil
  attack_ticks = nil

  attacker = nil
  target = nil

  toggle_turn()
  draw_arena()
  draw_options()
  check_over()
 end
end

function eliminate()
 local target = cur.l[cur.i]
 if cur.l == arena.enemies then
  arena.party.score += target.stats.l
 	local next_level = levels[arena.party.level]
 	if arena.party.score >= next_level then
 	 arena.party.level += 1
 	 //maybe: lower score on level?
 	 if arena.party.level > #levels then
 	  arena.party.level = #levels
 	 end
 	end
 end
 del(cur.l, target)
end

function auto_turn()
 auto_ticks = 0
end

function update_auto_turn()
 auto_ticks += 1

 if auto_ticks == 2*delay then
  cur.i = ceil(rnd(#cur.l))
  draw_arena()
  draw_options()
 elseif auto_ticks == 4*delay then
  select()
 elseif auto_ticks == 6*delay then
  cur.i = ceil(rnd(#cur.l))
  draw_arena()
  draw_options()
 elseif auto_ticks == 8*delay then
  select()
 end
end

function battle_over()
 over_ticks = 0
end

function update_battle_over()
 over_ticks += 1

 if over_ticks == 2*delay then
  draw_arena()
  note("^no more enemies remain!")
 elseif over_ticks == 5*delay then
  draw_arena()
  arena.party.battles += 1
  local s = ""
  if arena.party.battles > 1 then s = "s" end
  note("^finished "..arena.party.battles.." battle"..s)
 elseif over_ticks == 10*delay then
  draw_arena()
  note("^total exp: "..arena.party.score)
 elseif over_ticks == 15*delay then
  set_up_enemies()
  draw_arena()
  draw_options()
  note("^new enemies appeared!")
 elseif over_ticks == 18*delay then
  over_ticks = nil
 end
end

function game_over()
 game_over_ticks = 0
end

function update_game_over()
 game_over_ticks += 1

 if game_over_ticks == 2*delay then
  draw_arena()
  note("^your entire party is down!", red)
 elseif game_over_ticks == 5*delay then
  draw_arena()
  local s = "s"
  if arena.party.battles == 1 then s = "" end
  note("^finished "..arena.party.battles.." battle"..s, red)
 elseif game_over_ticks == 10*delay then
  draw_arena()
  note("^total exp: "..arena.party.score, red)
 elseif game_over_ticks == 15*delay then
  set_up_party()
  draw_arena()
  draw_options()
  note("^a new party appeared!")
 elseif game_over_ticks == 18*delay then
  game_over_ticks = nil
  draw_arena()
  draw_options()
 end
end