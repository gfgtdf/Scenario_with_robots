

-- i use this to ceck weather a unit has been recruited in this turn
-- i use this in the filter for weather to show the "edit robot" menu
function has_just_been_recruited_not(unit)
	local recruited_list = swr_h.deseralize(wesnoth.get_variable("recruited_list") or "{}")
	return  not (recruited_list[unit.id] == wesnoth.current.turn )
end

return has_just_been_recruited_not