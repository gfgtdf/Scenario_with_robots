local on_event = wesnoth.require("on_event")

local traps = {}
local traptypes = {}
traps.traplist = {}
-- TODO: It would be nice if there were amlas to update traps in multiple ways
--  More damage, allies take less damage, explisive damage.


traps.execute_trap = function(trap, x, y, taget_ref)
	local traptype = traptypes[trap.type]
	local anim = {}
	if traptype.animation == "spikes" then
		anim = {
			T.item { x = x, y = y, halo="animation/spikes.png" },
			T.delay { time = 50 },
			T.item { x = x, y = y, halo="animation/spikes2.png" },
			T.delay { time = 100 },
			T.item { x = x, y = y, halo="animation/spikes3.png" },
			T.delay { time = 50 },
			T.remove_item { x= x, y = y, image = "animation/spikes3.png" },
			T.item { x = x, y = y, halo="animation/spikes2.png" },
			T.delay { time = 50 },
			T.remove_item { x= x, y = y, image = "animation/spikes2.png" },
			T.item { x = x, y = y, halo="animation/spikes.png" },
			T.delay { time = 50 },
			T.remove_item { x= x, y = y, image = "animation/spikes.png" }
		}
	elseif traptype.animation == "explosion" then
		-- TODO place the animation for the explosion trap here.
	end
	for k,v in pairs(anim) do
		wesnoth.wml_actions[v[1]](v[2])
	end
	local resist = wesnoth.unit_resistance(taget_ref, traptype.damagetype or "pierce")
	wesnoth.wml_actions.harm_unit {
		T.filter { x = x, y = y},
		amount = traptype.amount * trap.power,
		resistance_multiplier = resist / 100,
		animate = false,
		kill = false,
		poisoned = traptype.poisoned,
		slowed = traptype.slowed,
	}
	local trapcount = 0
	for k, other_trap in pairs(traps.traplist) do
		if trap.x == other_trap.x and trap.y == other_trap.y then
			trapcount = trapcount + 1
		end
	end
	-- remove this if it was the last trap on this hex
	-- TODO 1.13.3: Use item names to remove this item in case multiple traps were put to this location.
	if trapcount == 1 then
		wesnoth.wml_actions.remove_item {
			x = trap.x,
			y = trap.y,
			image = "misc/red_border.png"
		}
	end
end

traps.set_trap = function(trap, max_times)
	local firstfound = false
	local firstfound_loc = nil
	local firstfound_count = 0
	local count = 0
	for k, v in pairs(traps.traplist) do
		if v.sender_unit_id == trap.sender_unit_id then
			count = count + 1
			firstfound = firstfound or k
			firstfound_loc = firstfound_loc or {x = v.x, y = v.y}
		end
	end
	if count >= max_times then
		table.remove(traps.traplist,firstfound)
		for k, v in pairs(traps.traplist) do
			if v.x == (firstfound_loc or {}).x and   v.y == (firstfound_loc or {}).y then
				firstfound_count = firstfound_count + 1
			end
		end
		if firstfound_count == 0 then
			wesnoth.wml_actions.remove_item {
				x = firstfound_loc.x,
				y = firstfound_loc.y,
				image = "misc/red_border.png"
			}
		end
	end
	table.insert(traps.traplist, trap)
	local allied_sides = {}
	for k,v in ipairs(wesnoth.sides.find { T.allied_with { side = trap.sender_side } }) do
		table.insert(allied_sides, v.team_name)
	end
	wesnoth.wml_actions.item {
		x = trap.x,
		y = trap.y,
		image = "misc/red_border.png",
		visible_in_fog = false,
		team_name = table.concat(allied_sides, ","),
	}
end

function wesnoth.persistent_tags.swr_traps.read(cfg)
    traps.traplist = swr_h.deserialize(cfg.value)
end

function wesnoth.persistent_tags.swr_traps.write(add)
	add { value = swr_h.serialize_oneline( traps.traplist ) }
end


on_event("enter_hex", function(ec)
	local remove_traps = {}
	-- i dont want to event to fire if there is another unit on that hex.
	if ec.x1 == ec.unit_x and ec.y1 == ec.unit_y then
		for k, trap in pairs(traps.traplist) do
			-- i caould also check weather the units are allied here
			if trap.x == ec.x1 and trap.y == ec.y1 then
				local unit_ref = wesnoth.units.get(trap.x,trap.y)
				traps.execute_trap(trap, trap.x, trap.y, unit_ref)
				if traptypes[trap.type].permanent ~= true then
					table.insert(remove_traps, k)
				end
				-- forcing them to move on would be unfair i think
				wesnoth.cancel_action()
				global_events.disallow_undo()
			end
		end
		while #remove_traps > 0 do
			table.remove(traps.traplist, remove_traps[#remove_traps])
			table.remove(remove_traps, #remove_traps)
		end
	end
end)

on_event("moveto", function(event_context)
	unit = wesnoth.units.get(event_context.x1,event_context.y1)
	if unit:ability("ab_trapper") then
		unit_cfg = unit.__cfg
		local unit_abilities = swr_h.get_or_create_child(unit_cfg, "abilities")
		for ab_trapper in wml.child_range(unit_abilities, "ab_trapper") do
			local traptype = unit.variables["mods.swr_traptype"] or ab_trapper.traptype 
			traps.set_trap({
				x = event_context.x1,
				y = event_context.y1,
				power = ab_trapper.damage,
				type = traptype,
				sender_side = unit.side,
				sender_unit_id = unit.id
			}, ab_trapper.maxtraps)
			global_events.disallow_undo()
			break
		end
	end
end)

traptypes["spikes"] =
{
	animation = "spikes",
	amount = 10,
	damagetype = "pierce",
}

traptypes["poison_spikes"] =
{
	animation = "spikes",
	amount = 10,
	damagetype = "pierce",
	poisoned = true
}

return traps