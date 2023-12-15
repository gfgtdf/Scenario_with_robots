local on_event = wesnoth.require("on_event")

-- checks whether a unit was recruited in teh current turn by logging the recruit times of units.
-- i use this in the filter for the "edit robot" menu
function has_just_been_recruited_not(unit)
	local recruited_list = swr_h.deserialize(wml.variables.recruited_list or "{}")
	return  not (recruited_list[unit.id] == wesnoth.current.turn )
end

on_event("prestart", function(event_context)
	local recruited_list = {}
	for k, v in pairs(wesnoth.get_units()) do
		-- treat unit that were there from he beginning like units that were recruited in turn 1.
		recruited_list[v.id] = 1
	end
	wml.variables["recruited_list"] = swr_h.serialize_oneline(recruited_list)
end)

on_event("recruit", function(event_context)
	local recruited_list = swr_h.deserialize(wml.variables.recruited_list or "{}")
	local unit = wesnoth.units.get(event_context.x1, event_context.y1)
	recruited_list[unit.id] = wesnoth.current.turn
	wml.variables["recruited_list"] = swr_h.serialize_oneline(recruited_list)
end)

return has_just_been_recruited_not
