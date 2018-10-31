-- this file contains the base of my lua event handler logic
-- specially it provides the functions 
--   global_events.init() which initilizes the event handler code
--   global_events.disallow_undo() to make undoing of the current event impossible (which is not the default for lua event handlers)

local on_event = wesnoth.require("on_event")

local global_events = {}
global_events.event_handlers = {}
global_events.init = function()
	-- this is the main function that is called everytime a new scenario is started or loadet.
	-- wesnoth.game_events.on_event might be nil

	inventories = {}
	for i,side in ipairs(wesnoth.sides) do
		inventories[side.side] = Inventory:create("component_inventory", side.side)
	end
end

global_events.toplevel_start = function()
	global_events.init()
end

--a workaround, using a wml event, since there is no lua equivalent to that
global_events.disallow_undo = function()
	-- sicne the behviour of enter_hex/exit_hex was fixed we can implenent it this way.
	wesnoth.wml_actions.event { name = wesnoth.current.event_context.name }
end

return global_events