-- this file contains the base of my lua event handler logic
-- specially it provides the functions 
--   global_events.init() which initilizes the event handler code
--   global_events.add_event_handler() to register a lua event handler, it does not support filters.
--   global_events.disallow_undo() to make undoing of the current event impossible (which is not the default for lua event handlers)
--   global_events.register_on_load_reader()/global_events.register_on_save_writer() to manage persistant lua variables

local global_events = {}
global_events.event_handlers = {}
global_events.init = function()
	-- this is the main function that is called everytime a new scenario is started or loadet.
	current_event_name = "lua_init"
	-- wesnoth.game_events.on_event might be nil
	local old_on_event = wesnoth.game_events.on_event or function(eventname) end
	wesnoth.game_events.on_event = function(eventname)
		-- a global variable to know in what type of ewvent we are in everywhere.
		-- the intention was to check in some functions for example that should be used in preload event or in a toplevel event.
		local old_event_name = current_event_name
		local event_context = wesnoth.current.event_context
		local funcs = global_events.event_handlers[eventname] or {}
		for k,v in pairs(funcs) do
			current_event_name = event_context.name
			-- although we could always get the event context with wesnoth.current we still pass it th the calee
			v(event_context)
		end
		if global_events.is_toplevel_event and global_events.disallow_undo_flag then
			global_events.disallow_undo_flag = false
			-- note: it is not possible to do this in the nested event handlers because of http://gna.org/bugs/?23556
			wesnoth.wml_actions.event { name = wesnoth.current.event_context.name }
		end
		current_event_name = old_event_name
		old_on_event(eventname)
	end
	
	if wesnoth.get_variable("component_inventory") ~= nil and wesnoth.get_variable("component_inventory_1") == nil then
		--	compability code
		wesnoth.set_variable("component_inventory_1", wesnoth.get_variable("component_inventory"))
		wesnoth.set_variable("component_inventory")
	end
	inventories = {}
	for i,side in ipairs(wesnoth.sides) do
		inventories[side.side] = Inventory.new("component_inventory_" .. tostring(side.side))
	end
	current_event_name = ""
end

global_events.toplevel_start = function()
	global_events.init()
end

global_events.is_toplevel_event = function()
	return string.find(debug.traceback(), "[C]: in function 'fire_event'", 0, true) ~= nil
end

--quiet obvious
global_events.add_event_handler = function(eventname, func)
	if wesnoth.compare_versions(wesnoth.game_config.version, ">", "1.13.2") then
		eventname = string.gsub(eventname, " ", "_")
	end

	global_events.event_handlers[eventname] = global_events.event_handlers[eventname] or {}
	table.insert(global_events.event_handlers[eventname], func)
end
--a workaround, using a wml event, since there is no lua equivalent to that
global_events.disallow_undo = function()
	global_events.disallow_undo_flag = true
end

return global_events