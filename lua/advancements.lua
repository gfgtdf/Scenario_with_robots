local advancements = {}

global_events.add_event_handler("advance", function(event_context)
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
global_events.add_event_handler("post_advance", function(event_context)
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
			stats.refresh_all_stats_xy(event_context.x1, event_context.y1)
		end
	end
end)
global_events.add_event_handler("turn refresh", function(event_context)
	-- this functions asks the advacement question in case a unit advances during the enmy turn.
	for k,unit in pairs(wesnoth.get_units()) do
		-- is checking unit.side == wesnoth.current.side faster than passing a side = wesnoth.current.side filter to wesnoth.get_units() ?
		if unit.side == wesnoth.current.side then
			local unit_cfg = unit.__cfg
			local modifications_cfg = helper.get_child(unit_cfg, "modifications")
			
			local index = 1
			local untore_needed = false
			-- we remove all the "Ooops" advacements and give the unit his exp back.
			while index <= #modifications_cfg do
				if(modifications_cfg[index][2].id == "Oooops") then
					table.remove(modifications_cfg, index)
					-- unit_cfg.max_experience  because the Ooops advancement doesn't increase the units max_experience
					unit_cfg.experience = unit_cfg.experience  + unit_cfg.max_experience 
					untore_needed = true
				else
					index = index + 1
				end
			end
			if untore_needed then
				local hp_percent = unit_cfg.hitpoints / unit_cfg.max_hitpoints
				-- i use [unstore_unit] becasue wesnoth.put_unit doesn't trigger unit advancing.
				-- TODO 1.13.2: use wesnoth.put_unit and wesnoth.advance_unit
				wesnoth.set_variable("advanced_temp_6", unit_cfg)
				--this start the normal advancing process i handle in on_advance
				
				wesnoth.wml_actions.unstore_unit { variable = "advanced_temp_6", find_vacant = "no", advance = true, fire_event = true, animate = false}
				local new_unit = wesnoth.get_unit(unit_cfg.x,unit_cfg.y)
				-- we dont want to give healing twice.
				new_unit.hitpoints = new_unit.hitpoints  * hp_percent
				-- i could add a loop here for the case there ar multiple advancements. shouldn't be too hard
			end
		end
	end
end)

