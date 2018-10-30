local on_event = wesnoth.require("on_event")

local advancements = {}

on_event("advance", function(event_context)
	local unit = wesnoth.get_unit(event_context.x1, event_context.y1)
	local advancing_type = wesnoth.unit_types["advancing" .. unit.type]
	if(advancing_type ~= nil) then
		if unit.side == wesnoth.current.side then
			local unit_cfg = unit.__cfg
			-- from heree we cannot use the local "unit" because we deleted it with the put_unit function (do i need the put_unit here?)
			wesnoth.put_unit(event_context.x1, event_context.y1)
			swr_h.remove_from_array(unit_cfg, function (tag) return tag[1] == "advancement" end)
			unit_cfg.type = "advancing" .. unit_cfg.type
			--"put_unit" doesnt trigger the advancement.
			wesnoth.set_variable("advanced_temp_3", unit_cfg)
			--this aborts the ongoing advancement event (but the "advance" event is still fired) and raises a new advancement event itselft
			-- the advance event is 
			wesnoth.wml_actions.unstore_unit { variable = "advanced_temp_3", find_vacant = "no", advance = true, fire_event = true, animate = false}
			--wesnoth.put_unit(unit_cfg)
		else
			-- the advacement fired by unstore_unit will choose a radnom advancement, so that wont wokk in this case.
			-- we could save wich units have advances here, so we don't have to loop though all units later in the on_side_turn event.
		end
	end
end)

--note, that due to the things we do in on_advance, the post_advance event is fired once, while the advance event is fired twice
-- TODO 1.13.2: remove the type changing hack and change the units advancments in lua in pre advance events.
on_event("post_advance", function(event_context)
	local unit = wesnoth.get_unit(event_context.x1, event_context.y1)
	if unit.experience > unit.max_experience then
		-- Don't change the type back if there are still advancementas to do.
		return
	end
	if swr_h.string_starts(unit.type, "advancing") then
		local original_name = string.sub(unit.type, string.len("advancing") + 1)
		local un_advancing_type = wesnoth.unit_types[original_name]
		if un_advancing_type ~= nil then
			local unit_cfg = unit.__cfg
			unit_cfg.type = original_name
			local do_not_continue = true
			-- i use [unstore_unit] becasue wesnoth.put_unit doesn't trigger unit advancing.
			-- TODO 1.13.2: use wesnoth.put_unit and wesnoth.advance_unit
			swr_h.remove_from_array(unit_cfg, function (tag) return tag[1] == "advancement" end)
			wesnoth.set_variable("advanced_temp_4", unit_cfg)
			wesnoth.wml_actions.unstore_unit { variable = "advanced_temp_4", find_vacant = "no", advance = false, fire_event = false, animate = false}
			swr_stats.refresh_all_stats_xy(event_context.x1, event_context.y1)
		end
	end
end)

on_event("turn refresh", function(event_context)
	-- this functions asks the advacement question in case a unit advances during the enmy turn.
	for k,unit in pairs(wesnoth.get_units()) do
		-- is checking unit.side == wesnoth.current.side faster than passing a side = wesnoth.current.side filter to wesnoth.get_units() ?
		if unit.side == wesnoth.current.side then
			local unit_cfg = unit.__cfg
			local modifications_cfg = helper.get_child(unit.__cfg, "modifications")
			local count = 0
			for advancement in wml.child_range(modifications_cfg, "advacement") do
				if advancement.id == "Oooops" then count = count + 1 end
			end
			if count > 0 then
				u:remove_modifications({ id = "Oooops"}, "advacement")
				u.experience = u.experience  + count * u.max_experience
				local hp_percent = u.hitpoints / u.max_hitpoints
				u:advance()
				-- we dont want to give healing twice.
				u.hitpoints = u.max_hitpoints  * hp_percent
			end
		end
	end
end)

