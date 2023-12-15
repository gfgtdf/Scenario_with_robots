local on_event = wesnoth.require("on_event")

local advancements = {}

function advancements.get_extra_advancements(type_id, res)
	local res = res or {}
	local t = wesnoth.unit_types[type_id]
	local variables = wml.get_child(t.__cfg, "type_variables") or {}
	for advancement in wml.child_range(variables, "advancement") do
		res[#res + 1] = advancement
	end
	return res
end

on_event("pre_advance", function(event_context)
	local unit = wesnoth.units.get(event_context.x1, event_context.y1)
	if unit.side ~= wesnoth.current.side then
		return
	end

	unit.variables["mods.pre_advance_flag"] = true
	local new_advacenemnts = advancements.get_extra_advancements(unit.type)
	if #new_advacenemnts > 0 then
		unit.advancements = new_advacenemnts
	end
end)

on_event("post_advance", function(event_context)
	local unit = wesnoth.units.get(event_context.x1, event_context.y1)
	-- if the advancement did not rebuild the type do so now.
	if unit.variables["mods.pre_advance_flag"] == true then
		unit:transform(unit.type)
	end
	assert(unit.variables["mods.pre_advance_flag"] ~= true)
end)

on_event("turn refresh", function(event_context)
	-- this functions asks the advacement question in case a unit advances during the enmy turn.
	for k,unit in pairs(wesnoth.units.find_on_map()) do
		-- is checking unit.side == wesnoth.current.side faster than passing a side = wesnoth.current.side filter to wesnoth.get_units() ?
		if unit.side == wesnoth.current.side then
			local unit_cfg = unit.__cfg
			local modifications_cfg = wml.get_child(unit.__cfg, "modifications")
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

