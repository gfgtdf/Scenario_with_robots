-- checks whether a unit was recruited in teh current turn by logging the recruit times of units.
-- i use this in the filter for the "edit robot" menu
function has_just_been_recruited_not(unit)
	local recruited_list = swr_h.deseralize(wesnoth.get_variable("recruited_list") or "{}")
	return  not (recruited_list[unit.id] == wesnoth.current.turn )
end

global_events.add_event_handler("prestart", function(event_context)
	local recruited_list = {}
	for k, v in pairs(wesnoth.get_units()) do
		-- treat unit that were there from he beginning like units that were recruited in turn 1.
		recruited_list[v.id] = 1
	end
	wesnoth.set_variable("recruited_list", swr_h.serialize_oneline(recruited_list))
end)

global_events.add_event_handler("recruit", function(event_context)
	local recruited_list = swr_h.deseralize(wesnoth.get_variable("recruited_list") or "{}")
	local unit = wesnoth.get_unit(event_context.x1, event_context.y1)
	recruited_list[unit.id] = wesnoth.current.turn
	wesnoth.set_variable("recruited_list", swr_h.serialize_oneline(recruited_list))
end)

return has_just_been_recruited_not
