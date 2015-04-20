-- here are all the event handers for side_turn, post_advance etc, it also contains the main routine "toplevel_start"
-- there is also a workaaround for disallow_undo but it is not implmented yet.
-- local helper = z_require("my_helper")
-- local stats = z_require("stats")
-- local Inventory = z_require("inventory")


-- TODO since some events don't fire under cirumastances we need a workarounf for that(for examle the attack_end event wich is not fired if thre attaack is aborted.(at least thats what i think))
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
		local event_context = wesnoth.current.event_context
		local funcs = global_events.event_handlers[eventname] or {}
		for k,v in pairs(funcs) do
			current_event_name = event_context.name
			-- although we could always get the event context with wesnoth.current we still pass it th the calee
			v(event_context)
		end
		old_on_event(eventname)
		current_event_name = ""
	end
	-- registering general events, implemented via wesnoth.game_events.on_event, in some rare cases i still might need to use [event] because of the filters though
	global_events.add_event_handler("die", global_events.on_die)
	global_events.add_event_handler("recruit", global_events.on_recruit_log_time)
	global_events.add_event_handler("moveto", global_events.on_moveto)
	global_events.add_event_handler("exit_hex", global_events.on_exit_hex)
	global_events.add_event_handler("enter_hex", global_events.on_enter_hex)
	global_events.add_event_handler("menu_item menu_edit_robot", function(event_context)
		robot_mechanics.edit_robot_at_xy(event_context.x1,event_context.y1)
		stats.refresh_all_stats_xy(event_context.x1, event_context.y1)
		global_events.disallow_undo_flag = true
	end)
	global_events.create_disallow_undo_workaround("menu_item menu_edit_robot")
	-- see global_events.on_enter_hex
	enter_hex_is_really_there = true
	-- things that only have to initalized one every game, mosty because the save their data in wml are there.
	global_events.add_event_handler("prestart", global_events.on_prestart)
	global_events.add_event_handler("start", global_events.on_start)
	
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
	traps = Traps.new("")
	traps.init()
	current_event_name = ""
end
global_events.toplevel_start = function()
	global_events.init()	
end

global_events.preload_start = function()
	if(not globals.no_toplevel_lua_workaround) then
		error("preload start called when it is not needed, please report this bug")
	end
	-- there are 4 "preload" events that are fired in the following order: (this code mormaly executes in 1 or 2)
	-- 1) toplevel [lua] tags	
	-- 2) other type of toplevel [lua] tags	(i think on is insie the [scenrio] tag and the other outside)
	-- 3) the wesnoth.game_events.on_load event
	-- 4) the preload wml event
	-- 5) the prestart wml event (if !gameload)
	-- 6) the start wml event (if !gameload)
	
	-- Usually our lus code gets initlized at (2) and our variables are initlized at (3)
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

-- in a move from hex a to hex b the "exit_hex" (exit from a) it fired and then the "enter_hex" (enter b) is fired
-- in version <= 11.4 it is like this:
-- x1, y1 always contain the location of the unit.
-- in the "exit_hex" x2, y2 is the location to where the unit goes.
-- in the "enter_hex" x2,y2 is the location from where the unit comes.
-- vesion > 11.4:
-- in the "exit_hex" x2, y2 is the location to where the unit goes, x1,y1 is the location from where the unit comes.
-- in the "enter_hex" x2,y2 is the location from where the unit comes, x1,y1 is the location to where the unit goes.
-- so we dont have any information about the current location of the unit
-- 
-- the "on_exit_hex"/"on_enter_hex" workaround for the new version:
-- in the first "on_exit_hex" of the move we can x1,y1 is the location of the unit, and remember the id if the unit then
-- to know weather we are in the first part of a move we need the  current_moving_info variable, wich is set to nil in the "move_to" event.
-- the problem is, im still not 100% sure weather the "move_to" event is ALWAYS fired after the end of a move.

global_events.on_exit_hex = function(event_context)
	--local stamp = wesnoth.get_time_stamp()
	if(globals.current_moving_info == nil) then
		local unit = wesnoth.get_unit(event_context.x1, event_context.y1)
		current_moving_info = { id = unit.id, ref = unit, start_x = unit.x, start_y = unit.y, is_first_move = true}
	else
		current_moving_info.is_first_move = false
	end
	global_events.last_on_exit_hex_2 = global_events.last_on_exit_hex
	global_events.last_on_exit_hex = event_context
end
-- the "on_exit_hex" workaround for the "old" version:
--
-- note that you cannot simply use last_on_enter_hex to check the position of the on_exit_hex event.
-- you have to watch out: if it is al least the second movepart_you can do it
-- in the first movepart you an take it as gauenteed thatwhere the unit actualy stats is also tghe location of the event
-- leaves only to find out wather it is the first part of a move.
-- and that is when enter_hex_is_really_there becomes useful another time.
-- not enter_hex_is_really_there => we can assume turn > 2, because every turn ends with enter_hex_is_really_there == true
-- to ensure that is always right ew initalize enter_hex_is_really_there = true
-- enter_hex_is_really_there => unit exits the field it is really on
global_events.on_enter_hex = function(event_context)
	global_events.last_on_enter_hex = event_context
	enter_hex_is_really_there = (event_context.x1 == global_events.last_on_exit_hex.x2 and event_context.y1 == global_events.last_on_exit_hex.y2) 
	--	or (event_context.x1 == event_context.x2 and event_context.y2 == event_context.y2) 
end

-- there is a new way for firering the enter_hex, exit_hex events in lua, because of a "bugfix" by Jamit
-- see (http://forums.wesnoth.org/viewtopic.php?f=58&t=38930)
-- the "fix", gives the user accces to the place where the event is fired but, it removes the access to the unit wich caused the event.
-- i suppose the workaround for the new version is a bit easerer if you want to use the "exit_hex" too, but, a workaroung for "enter_hex" was easier with the old version.
-- this new workaroung works with both version (before and after the "fix".) since it doesnt use event.context.x1/y1 at all.
-- (exept one i the first part of the move when we can assume the units standing hex it the hex he leaves)
global_events.on_enter_hex_workaround = function()
	local retcfg = {}
	if(current_event_name == "exit_hex") then
		if (current_moving_info.is_first_move) then
			retcfg.from_x = current_moving_info.start_x
			retcfg.from_y = current_moving_info.start_y
			retcfg.to_x = global_events.last_on_exit_hex.x2
			retcfg.to_y = global_events.last_on_exit_hex.y2
			retcfg.info = current_moving_info
			return retcfg
		else
			retcfg.from_x = global_events.last_on_exit_hex_2.x2
			retcfg.from_y = global_events.last_on_exit_hex_2.y2
			retcfg.to_x = global_events.last_on_exit_hex.x2
			retcfg.to_y = global_events.last_on_exit_hex.y2
			retcfg.info = current_moving_info
			return retcfg
			
		end
	elseif (current_event_name == "enter_hex") then
		retcfg.from_x = global_events.last_on_enter_hex.x2
		retcfg.from_y = global_events.last_on_enter_hex.y2
		retcfg.to_x = global_events.last_on_exit_hex.x2
		retcfg.to_y = global_events.last_on_exit_hex.y2
		retcfg.info = current_moving_info
		return retcfg
	else
		error ("on_enter_hex_workaround not called from within right event.")
	end
end

-- used for testing right now
-- and as part of the on_enter_hex workaround
global_events.on_moveto = function(event_context)
	current_moving_info = nil
end
--quiet obvious
global_events.add_event_handler = function(eventname, func)
	global_events.event_handlers[eventname] = global_events.event_handlers[eventname] or {}
	table.insert(global_events.event_handlers[eventname], func)
end
--a workaround, using a wml event, since there is no lua equivalent to that
--not implemented yet. (or at least not tested), edit tested, bot only once
global_events.disallow_undo = function(current_event_name)
	global_events.disallow_undo_flag = true
end
-- a workaround, using a wml event, since there is no lua equivalent to that
-- not implemented yet/not tested yet
-- event_name may be a comma seperated list.
-- note that the wml event doesnt need to be created everytime the game is loadet. but the f_workaroubd_event function does,
-- to this needs to be called on toplevel.
global_events.create_disallow_undo_workaround = function(event_name) 
	--create event with lua code that calls f_workaroubd_event
	--note, that since this is a local fun tion have to make it accesible somehow to the caller.
	--maybe using one event with a very long comma,sperated list at name paramerter ist the best option.
	if global_events.disallow_undo_effected_events == nil then
		global_events.disallow_undo_effected_events = event_name
	else
		global_events.disallow_undo_effected_events = global_events.disallow_undo_effected_events .. "," ..event_name
	end
	wesnoth.wml_actions.event { 
		id = "lua_disallow_undo", 
		remove = true
	}
	wesnoth.wml_actions.event { 
		id = "lua_disallow_undo", 
		first_time_only = false,
		name = global_events.disallow_undo_effected_events, 
		T.lua { code = "global_events.f_workaroubd_event()"} 
	}
	local f_workaroubd_event = function()
		if(global_events.disallow_undo_flag == nil) then
			--cwo("global_events.disallow_undo_flag == nil")
			wesnoth.wml_actions.allow_undo({})
		end
		--cwo("global_events.disallow_undo_flag")
		global_events.disallow_undo_flag = nil
	end
	global_events.f_workaroubd_event = f_workaroubd_event
end

-- i think the unit CAN be brought back to life with in an die event from wml, or from lua.
-- so we have to watch out here, since we cant be 100% sure that the unit is dead.
-- i tihnk it is good peractise to put all "ressurects" in the last_breath event.
global_events.on_die = function(event_context)
	-- i want to maka an option give retrun components from dead robots, ecseialy since i thought about of making some components nescesary id i'w make a real campaign
	local unit_cfg = wesnoth.get_unit(event_context.x1, event_context.y1).__cfg
	local variables = helper.get_child(unit_cfg, "variables")
	local little_inventory = {}
	if(variables.robot ~= nil and global_events.restore_components_after_unit_death == true) then
		local robot_string = variables.robot or "{ size = { x = " .. tostring(default_size.x) ..", y = " .. tostring(default_size.y) .." }, components = {} }"
		local robot = loadstring("return " .. robot_string )()
		for k,v in robot.components do
			if v.component.name ~= "core" then
				little_inventory[v.component.name] = (little_inventory[v.component.name] or 0) + 1
			end
		end
		global_events.components_of_the_dead = global_events.components_of_the_dead or {}
		global_events.components_of_the_dead[unit.id] = little_inventory
		-- we check lster in the next new turn event if the unit is still alive and if not give then items to the players inventory.
		-- todo: to make this work in multiplayer we should also store ple units side.
	end
end

-- why not treating prestart just like all the other events?
global_events.on_prestart = function(event_context)
	-- put thinkgs that only have to be initailzed here (register_wml_event_funcname)
	local recruited_list = {}
	for k, v in pairs(wesnoth.get_units()) do
		recruited_list[v.id] = 1
	end
	wesnoth.set_variable("recruited_list", swr_h.serialize_oneline(recruited_list))
end

-- why not treating prestart just like all the other events?
global_events.on_start = function(event_context)
	wesnoth.wml_actions.set_menu_item {
		description = "edit robot",
		id = "menu_edit_robot",
		T.show_if {
			T.have_unit {
				x = "$x1",
				y = "$y1",
				side = "$side_number",
				ability = "robot_ability",
				T["not"] {
					T.filter_wml {
						attacks_left = 0,
					},
					T["and"] {
						lua_function = "has_just_been_recruited_not"
					},
				},
			},
		},
		T.filter_location {
			terrain = "C*,C*^*,*^C*,K*,K*^*,*^K*",
		},
	}
end

global_events.register_wml_event = function(eventname, eventfilter_wml, event_id, func)
	-- the problem is that the fucntion have to be created every time the game is loaded but the wml event only once.
	local funcname = "wml_event_" .. eventname .. event_id
end
-- not implemented/tested/used yet
global_events.register_wml_event_funcname = function(eventname, eventfilter_wml, event_id, funcname)
	-- the intention is to make use of the useful "filter" tag in wml events, 
	-- this should be used in the prestart event, but because of the "id" key i suppose it won't cause troulbe if used anywhere else
	wesnoth.fire("event", {
		name = eventname,
		T.filter(eventfilter_wml),
		id = event_id,
		T.lua { code = funcname .. "()"}
	})
end
-- i use this, to know when wich unit was recruited
global_events.on_recruit_log_time = function(event_context)
	local recruited_list = swr_h.deseralize(wesnoth.get_variable("recruited_list") or "{}")
	local unit = wesnoth.get_unit(event_context.x1, event_context.y1)
	recruited_list[unit.id] = wesnoth.current.turn
	wesnoth.set_variable("recruited_list", swr_h.serialize_oneline(recruited_list))
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