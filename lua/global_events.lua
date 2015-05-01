-- this file contains the base of my lua event handler logic
-- specially it provides the functions 
--   global_events.init()/global_events.preload_start() which initilize the event handler code
--   global_events.add_event_handler() to register a lua event handler, unfortulateley it does not support filters.
--   global_events.disallow_undo() to make undoing of teh current event impossible (which is not the default for lua event handlers)
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
	inventory = inventories[1]
	traps = Traps.new()
	traps.init()
	current_event_name = ""
end

global_events.toplevel_start = function()
	global_events.init()	
end

global_events.is_toplevel_event = function()
	return string.find(debug.traceback(), "[C]: in function 'fire_event'", 0, true) ~= nil
end

global_events.preload_start = function()
	if(not globals.no_toplevel_lua_workaround) then
		error("preload start called when it is not needed, please report this bug")
	end
	-- there are 4 "preload" events that are fired in the following order:
	-- 1) toplevel [lua] tags	
	-- 2) other type of toplevel [lua] tags	(i think on is insie the [scenrio] tag and the other outside)
	-- 3) the wesnoth.game_events.on_load event
	-- 4) the preload wml event
	-- 5) the prestart wml event (if !gameload)
	-- 6) the start wml event (if !gameload)
	
	-- Usually our lua code gets initlized at (2) and our variables are initlized at (3)
	-- However in 1.12.x (not in 1.13.x) [lua] tags inside era are not supported so we need to inilize our lua code in (4)
	-- In that case global_events.init() runs in (4) and we need this function to emulate (3) and (4)
	
	-- Emulate the varaible loading process
	local old_event_name = current_event_name
	local funcs = global_events.event_handlers["luavars_init"] or {}
	for k,v in pairs(funcs) do
		current_event_name = "luavars_init"
		v()
	end
	current_event_name = old_event_name

	-- Since preload handlers were aded after preload was fired we need to explicitly execute the preload  handlers again.
	local old_event_name = current_event_name
	local funcs = global_events.event_handlers["preload"] or {}
	for k,v in pairs(funcs) do
		current_event_name = "preload"
		v()
	end
	current_event_name = old_event_name
end

--quiet obvious
global_events.add_event_handler = function(eventname, func)
	global_events.event_handlers[eventname] = global_events.event_handlers[eventname] or {}
	table.insert(global_events.event_handlers[eventname], func)
end
--a workaround, using a wml event, since there is no lua equivalent to that
global_events.disallow_undo = function()
	global_events.disallow_undo_flag = true
end

if globals.no_toplevel_lua_workaround then
	global_events.register_on_load_reader = function(tagname, f)
		global_events.add_event_handler("luavars_init", function()
			local var = wesnoth.get_variable("srw_lua." .. tagname)	
			if (var) then
				f(var)
			end
		end)
	end
	
	global_events.register_on_save_writer = function(tagname, f)
		local old_on_save = wesnoth.game_events.on_save
		wesnoth.game_events.on_save = function()
			local cfg = old_on_save()
			wesnoth.set_variable("srw_lua." .. tagname, f())
			return cfg
		end
	end
else
	global_events.register_on_load_reader = function(tagname, f)
		local old_on_load = wesnoth.game_events.on_load
		wesnoth.game_events.on_load = function(cfg)
			for i = 1, #cfg do
				if cfg[i][1] == tagname then
					f(cfg[i][2])
					table.remove(cfg, i)
					break
				end
			end
			old_on_load(cfg)
		end
	end
	
	global_events.register_on_save_writer = function(tagname, f)
		local old_on_save = wesnoth.game_events.on_save
		wesnoth.game_events.on_save = function()
			local cfg = old_on_save()
			table.insert(cfg, {tagname, f()})
			return cfg
		end
	end
end

return global_events