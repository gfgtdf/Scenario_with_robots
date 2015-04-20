local moving_unit = {}
moving_unit.move_info = {}
globals.currently_moving_unit_info = {}


-- in a move from hex a to hex b the "exit_hex" (exit from a) it fired first and then the "enter_hex" (enter b) is fired
-- in version <= 1.11.4 it is like this:
-- x1, y1 always contain the location of the unit.
--   in the "exit_hex" x2, y2 is the location to where the unit goes.
--   in the "enter_hex" x2,y2 is the location from where the unit comes.
-- In version 1.11.4 jamit pushed "bugfix" (see http://forums.wesnoth.org/viewtopic.php?f=58&t=38930 ) so for wesnoth >= 1.11.5 it is like:
--   in the "exit_hex" x2, y2 is the location to where the unit goes, x1,y1 is the location from where the unit comes.
--   in the "enter_hex" x2,y2 is the location from where the unit comes, x1,y1 is the location to where the unit goes.
--   so we dont have any information about the current location of the unit


-- in enter_hex and exit_hex events the location of the moving unit can be different
-- than the location x1,y1 that the unit entered/exited, this is becasue units can 'jump' over 
-- other allied units and while they enter the hex where that other unit is on they are
-- actually still on the previous hex.

-- event_context.x1/y1/x2/y2 are the location where the unit entered/left so there is no
-- direct way to know where the unit actually currently is.

-- This file offers 2 possible workaround for that problem:
-- 1) moving_unit.move_info.id contains the id of the currently moving unit
--    It is calculated on move begin and deleted on "moveto" events
-- 2) moving_unit.move_info.enter_x/enter_y/exit_x/exit_y are teh locationwhere
--    where the currently moving unit is, we calculate this by ourself independent from the
--    game engine, to that might be not 100% corrent in some corner cases.

-- This must be executd before other "exit_hex" handlers, becasue other exit_hex events need this data.
global_events.add_event_handler("exit_hex", function (event_context)
	if moving_unit.move_info.id == nil then
		-- no moving info yet => it is teh first step of teh move and we can assume that the unit is standing on (x1,y1)
		local unit = wesnoth.get_unit(event_context.x1, event_context.y1)
		-- Start of teh move: hbehave liek ew preovious succesfully moved to x1, y1 
		moving_unit.move_info = {
			id = unit.id,
			start_x = event_context.x1,
			start_y = event_context.y1,
			enter_x = event_context.x1,
			enter_y = event_context.y1,
		}
	end
	-- the hex where we come from teh teh hex where we previoisly succesfully stepped on.
	moving_unit.move_info.exit_x = moving_unit.move_info.enter_x
	moving_unit.move_info.exit_y = moving_unit.move_info.enter_y
	moving_unit.move_info.exit_normal = moving_unit.move_info.enter_normal
	if(not wesnoth.get_unit(event_context.x2, event_context.y2)) then
		-- the next hex is no occupied succesfully entered that location
		moving_unit.move_info.enter_y = event_context.y2
		moving_unit.move_info.enter_x = event_context.x2
		moving_unit.move_info.enter_normal = true
	else
		moving_unit.move_info.enter_normal = false	
	end
end)

-- This must be executd before other "exit_hex" handlers 
global_events.add_event_handler("moveto", function (event_context)
	--move has ended, reset move_info.
	moving_unit.move_info = {}
end)

moving_unit.assert_correct_calculations = function(eventname)
	local currently_moving_unit = wesnoth.get_units({ id = moving_unit.move_info.id })[1]
	if eventname == "enter_hex" then
		if currently_moving_unit.x ~= moving_unit.move_info.enter_x or currently_moving_unit.y ~= moving_unit.move_info.enter_y then
			error("wrong calculations about enter_hex events: by id =  (" ..  currently_moving_unit.x .. "," .. currently_moving_unit.y .. ") our calculation = (" .. moving_unit.move_info.enter_x .. "," .. moving_unit.move_info.enter_y ..")" )
		end
	elseif eventname == "exit_hex" then
		if currently_moving_unit.x ~= moving_unit.move_info.exit_x or currently_moving_unit.y ~= moving_unit.move_info.exit_y then
			error("wrong calculations about exit_hex events")
		end
	else
		error("wrong eventname: " .. tostring(eventname))
	end
end

moving_unit.enters_normal = function()
	moving_unit.assert_correct_calculations("enter_hex")
	local event_context = wesnoth.current.event_context
	return event_context.x1 == moving_unit.move_info.enter_x and event_context.y1 == moving_unit.move_info.enter_y
end

moving_unit.exits_normal = function()
	moving_unit.assert_correct_calculations("exit_hex")
	local event_context = wesnoth.current.event_context
	return event_context.x1 == moving_unit.move_info.exit_x and event_context.y1 == moving_unit.move_info.exit_y
end
return moving_unit