swr = {}

-- we want some things to be at "top" level, escecialy for the wesnoth.game_events.on_load/save in case we need them
-- and since we have that at toplevel we can put it all here, i think everyting else wouls just make it more complicated.
function swr.require(script)
	-- I use dofile instead of , require because it allows me to reload the whole lua logics (for my scenarios that means nearly all of the logic)
	-- without having to quit the game and press F5 or close Wesnoth.
	-- thats pretty cool feature for debugging compared to wml debugging.
	-- maybe i'll change that for release but i don't see a good reason to do so, bause the time it needs is not really noticeable i think.
	return wesnoth.dofile('~add-ons/Scenario_with_robots/lua/' .. script .. '.lua')
end

swr_h = swr.require("my_helper")
-- since i don't have any translations yet i use the global "wesnoth"
_ = wesnoth.textdomain 'wesnoth'
T = wml.tag
swr.globals = {}
setmetatable(swr.globals, {
	["__index"] = function(t, k)
		return rawget(_G, k)
	end,
	["__newindex"] = function(t, k, v)
		_G[k] = v
	end,
})
swr.require("effects")
swr.require("utils/units")
swr.Inventory = swr.require("inventory")

swr.EditRobotDialog = swr.require("dialogs/edit_robot_dialog")
swr.BookDialog = swr.require("dialogs/book_dialog")
swr.SellerDialog = swr.require("dialogs/seller_dialog")

swr.component_list = swr.require("component_list")
robot_mechanics = swr.require("robot_mechanics")
swr.require("advancements")
swr.traps = swr.require("traps")
swr.trader = swr.require("trader")

dropping = swr.require("dropping")
unit_types_data = swr.require("unit_data")
swr.require("has_just_been_recruited_not")
swr.require("robot_event_handlers")
swr.require("wesnoth_version_check")


-- there are some other global variables:
--   serialize, serialize_oneline, deserialize, Set, cwo, - importent global functions exported by my_helper
--   min, max - global functions 
--   Dialog3
--   traps - stores the traps object
--   current_event_name - the name of the event we are in
--   has_juts_been_recruited_not - a funciton
