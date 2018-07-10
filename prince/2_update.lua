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

 attacker = turn[cur.s.i]
 attacker_n = attacker.stats.n
 assert(attacker)
 targets = {}
 main_target = {t=opposition(turn)[cur.i]}
 main_target_n = main_target.t.stats.n
 add(targets, main_target)

 if attacker.i == caster or
  attacker.i == caster +1 or
  attacker.i == caster +2 then
  for p_target in all(opposition(turn)) do
   if p_target.s == main_target.t.s +1 or
    p_target.s == main_target.t.s -1 then
    add(targets, {t=p_target})
   end
  end
 end

 for target in all(targets) do
 	assert(target)

 	local attack_element = element_by_n(attacker.stats.e)
 	local target_element = element_by_n(target.t.stats.e)
 	local t_e_i = target_element.i
 	local multiplier_char = sub(attack_element.o, t_e_i, t_e_i)

 	if multiplier_char == "1" then
 	 chance = 0.25
 	elseif multiplier_char == "2" then
 	 chance = 0.375
 	elseif multiplier_char == "4" then
 	 chance = 0.5
 	elseif multiplier_char == "6" then
 	 chance = 0.625
 	elseif multiplier_char == "8" then
 	 chance = 0.75
 	else
 	 assert(false, chance)
 	end

  local hit = rnd(1) < chance
  if attacker.i == fighter or
   attacker.i == fighter +1 or
   attacker.i == fighter +2 then
   if not hit then
    hit = rnd(1) < chance
   end
  elseif attacker.i == prince or
   attacker.i == prince +1 or
   attacker.i == prince +2 then
   if hit then
    attacker.stats.e = target.t.stats.e
   end
  end

  target.h = hit
 end

	draw_arena()
	draw_options()
end

function update_attack()

 attack_ticks += 1

 if attack_ticks == 1 then
  local name = main_target_n
  if #targets > 1 then
   name = #targets.." targets"
  end
  note(attacker_n.." attacks "..name)

 elseif attack_ticks == 3*delay then

  cur.s = nil

  local text = "^but it missed!"
  if #targets==1 then
   if targets[1].h then
    text = "^hit! "..main_target_n.." is gone"
    eliminate(opposition(turn), main_target.t)
   end
  else
   local miss_count=0
   local hit_count=0
   local all_count=0
   for target in all(targets) do
    all_count +=1
    if target.h then
     hit_count += 1
     eliminate(opposition(turn), target.t)
    else
     miss_count += 1
    end
   end
   if miss_count == all_count then
    text = "^magic missed all "..all_count.." targets"
   elseif hit_count == all_count then
    text = "^magic hit all "..all_count.." targets"
   else
    text = "^magic hit "..hit_count.." of "..all_count.." targets"
   end
  end

  draw_arena()
  draw_options()
  note(text)

 elseif attack_ticks == 6*delay then
  cur.s = nil
  attack_ticks = nil

  attacker = nil
  attacker_n = nil

  chance = nil
  main_target = nil
  main_target_n = nil
  targets = nil

  toggle_turn()
  draw_arena()
  draw_options()
  check_over()
 end
end

function eliminate(list, target)

 if list == arena.enemies then
  arena.party.score += target.stats.l
 	local next_level = levels[arena.party.level]
 	if arena.party.score >= next_level then
 	 arena.party.level += 1
 	 did_level_up = true
 	 //maybe: lower score on level?
 	 if arena.party.level > #levels then
 	  arena.party.level = #levels
 	 end
 	end
 elseif list == arena.party then
  add(arena.party.dead, target)
 end
 del(list, target)
end

function revive()
 local unsorted = {}
 for member in all(arena.party) do
  add(unsorted, member)
  del(arena.party, member)
 end
 //scared to do it in one loop
 for member in all(arena.party.dead) do
  add(unsorted, member)
  del(arena.party.dead, member)
 end
 for i=1,5 do
  for u=1,5 do
   member = unsorted[u]
   if member.s == i then
    add(arena.party, member)
   end
  end
 end
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
  if did_level_up then
   revive()
   did_level_up = nil
   text = "^level up!! ^now at "..arena.party.level
  else
   text = "^currnent level: "..arena.party.level
  end
  draw_arena()
  draw_options()
  note(text)

 elseif over_ticks == 20*delay then
  set_up_enemies()
  draw_arena()
  draw_options()
  text = "^new enemies"
  if #arena.enemies == 1 then
   text = "^single "..arena.enemies[1].stats.n
  end
  note(text.." appeared!")
 elseif over_ticks == 23*delay then
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
  note("^final level: "..arena.party.level, red)
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