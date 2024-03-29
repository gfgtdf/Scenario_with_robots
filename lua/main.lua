swr = {}

function swr.require(script)
	return wesnoth.require('~add-ons/Scenario_with_robots/lua/' .. script .. '.lua')
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
swr.RobotEditor = swr.require("robot_editor")

swr.component_list = swr.require("component_list")
swr.mechanics = swr.require("robot_mechanics")
swr.require("advancements")
swr.traps = swr.require("traps")
swr.trader = swr.require("trader")

swr.dropping = swr.require("dropping")
swr.unit_types_data = swr.require("unit_data")
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
