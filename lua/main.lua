
-- we want some things to be at "top" level, escecialy for the wesnoth.game_events.on_load/save in case we need them
-- and since we have that at toplevel we can put it all here, i think everyting else wouls just make it more complicated.
function z_require(script)
	-- I use dofile instead of , require because it allows me to reload the whole lua logics (for my scenarios that means nearly all of the logic)
	-- without having to quit the game and press F5 or close Wesnoth.
	-- thats pretty cool feature for debugging compared to wml debugging.
	-- maybe i'll change that for release but i don't see a good reason to do so, bause the time it needs is not really noticeable i think.
	return wesnoth.dofile('~add-ons/Scenario_with_robots/lua/' .. script .. '.lua')
end

helper = z_require("my_helper")
-- since i don't have any rtanslations yet i use the global "wesnoth"
_ = wesnoth.textdomain 'wesnoth'
T = helper.set_wml_tag_metatable {}
globals = {}
setmetatable(globals, {
	["__index"] = function(t, k)
		return rawget(_G, k)
	end,
	["__newindex"] = function(t, k, v)
		_G[k] = v
	end,
})
constants = z_require("constants")
stats = z_require("stats")
wml_codes = z_require("wml_codes")
-- the big letter at the beginning is intendet as part of my coding convention
Inventory = z_require("inventory")
gui = z_require("gui")
component_list = z_require("component_list")
robot_mechanics = z_require("robot_mechanics")
global_events = z_require("global_events")
Gui_test = z_require("gui_test")
Traps = z_require("traps")
trader = z_require("trader")
Seller = z_require("seller")

z_require("has_just_been_recruited_not")
global_events.toplevel_start()

-- there are some other global variables:
--   serialize, serialize_oneline, deseralize, Set, cwo, - importent global functions exported by my_helper
--   min, max - global functions 
--   MyGrig, Dialog1, Dialog2, Dialog3
--   inventory - stores the inventory object
--   traps - stores the traps object
--   current_event_name - the name of the event we are in
--   has_juts_been_recruited_not - a funciton
--   objects_to_add - is only used by stats.lua
--   enter_hex_is_really_there - a varialbe that notives weather the unit (not implmented yet) EDIT: removed, use global_events.last_on_exit_hex to find out the actual location of the event.