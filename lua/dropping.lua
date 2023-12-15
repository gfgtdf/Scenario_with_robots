local on_event = wesnoth.require("on_event")

local dropping = {}


dropping.remove_current_item = function()
	local ec = wesnoth.current.event_context

	wesnoth.interface.remove_item(ec.x1, ec.y1, dropping.current_item.name)
	dropping.item_taken = true
end

on_event("moveto", function(event_context)
	local x = event_context.x1
	local y = event_context.y1
	local items = wesnoth.interface.get_items(x, y)
	for i, item in ipairs(items) do
		dropping.current_item = item
		dropping.item_taken = nil
		wesnoth.game_events.fire("swr_pickup_item", x, y)
		if dropping.item_taken then
			wesnoth.interface.remove_item(x,y, item.name)
			swr_h.disallow_undo()
		end
		dropping.current_item = nil
		dropping.item_taken = nil
	end
end)

on_event("enter_hex", function(ec)
	local x = ec.x1
	local y = ec.y1
	local items = wesnoth.interface.get_items(x, y)
	if x ~= ec.unit_x or y ~= ec.unit_y then
		-- here the unit is moving ofer the tile but the tile is occupied
		-- by an allied unit (so one unit moves over another unit)
		-- don't fire the event in this case.
		return
	end
	for i, item in ipairs(items) do
		dropping.current_item = item
		dropping.item_taken = nil
		wesnoth.game_events.fire("swr_step_on_item", x, y)
		if dropping.item_taken then
			wesnoth.interface.remove_item(x,y, item.name)
			swr_h.disallow_undo()
		end
		dropping.current_item = nil
		dropping.item_taken = nil
	end
end)
return dropping
