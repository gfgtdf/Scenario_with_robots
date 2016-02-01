
global_events.add_event_handler("menu_item menu_edit_robot", function(event_context)
	robot_mechanics.edit_robot_at_xy(event_context.x1,event_context.y1)
	swr_stats.refresh_all_stats_xy(event_context.x1, event_context.y1)
	global_events.disallow_undo()
end)

global_events.add_event_handler("start", function(event_context)
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
end)

-- I want to make an option to return components from killed robots.
-- Specially becasue i thought about of making some components nescesary if i'd make a real campaign.

-- i think the unit CAN be brought back to life with in a die event from wml, or from lua.
-- so we have to watch out here, since we cannot be 100% sure that the unit is dead.
-- A possible workaround might be to check whether the robot is still alive when picking up the items.
global_events.add_event_handler("die", function(event_context)
	local drop_item_on_die = wesnoth.get_variable("drop_item_on_die")
	local unit_cfg = wesnoth.get_unit(event_context.x1, event_context.y1).__cfg
	local variables = helper.get_child(unit_cfg, "variables")
	local little_inventory = {}
	if variables.robot ~= nil and drop_item_on_die then
		local robot_string = variables.robot or "{ size = { x = " .. tostring(default_size.x) ..", y = " .. tostring(default_size.y) .." }, components = {} }"
		local robot = loadstring("return " .. robot_string )()
		for k,v in ipairs(robot.components) do
			if v.component ~= "core" then
				little_inventory[v.component] = (little_inventory[v.component] or 0) + 1
			end
		end
		-- TODO: find a better item.
		dropping.add_item(event_context.x1, event_context.y1, { image = "items/box.png", dropped_components = little_inventory })
	end
end)
global_events.add_event_handler("post advance", function(event_context)
	-- This is needed to adjust the overlay for the animatiosn for the new unit type.
	if robot_mechanics.reapply_bonuses_at_xy(event_context.x1,event_context.y1) then
		swr_stats.refresh_all_stats_xy(event_context.x1, event_context.y1)
	end
end)

global_events.add_event_handler("drop_pickup", function(event_context)
	local dropped_items = dropping.current_item.dropped_components
	if dropped_items == nil then
		return
	end
	if #wesnoth.get_units ({ side = wesnoth.current.side, ability = "robot_ability"}) == 0 then
		-- robot components can only be picked up from sides that own robots.
		return
	end
	local inventory = inventories[wesnoth.current.side]
	inventory.open()
	for k,v in pairs(dropped_items) do
		inventory.add_amount(k,v)
	end
	inventory.close()
	dropping.item_taken = true
end)

local endlevel_eventname = "victory"
local function version_is_sufficient(required)
 if not wesnoth.compare_versions then return false end
 return wesnoth.compare_versions(wesnoth.game_config.version, ">=", required)
end
if version_is_sufficient("1.13.0") then
	endlevel_eventname = "endlevel"
end

-- TODO 1.13.2: use side variables feature
global_events.add_event_handler(endlevel_eventname, function(event_context)
	-- fix carryover for teams in case side numbers change between scenarios.
	for i, v in ipairs(wesnoth.sides) do
		-- TODO 1.13.2: use v.save_id directly
		local save_id = v.__cfg.save_id
		local side_inventory_key = "component_inventory_" .. tostring(v.side)
		local carryover_side_inventory_key = "carryover_component_inventory_" .. save_id
		local inventory_data = wesnoth.get_variable(side_inventory_key)
		wesnoth.set_variable(side_inventory_key)
		wesnoth.set_variable(carryover_side_inventory_key, inventory_data)
	end
end)

-- TODO 1.13.2: use side variables feature
global_events.add_event_handler("prestart", function(event_context)
	for i, v in ipairs(wesnoth.sides) do
		-- TODO 1.13.2: use v.save_id directly
		local save_id = v.__cfg.save_id
		local side_inventory_key = "component_inventory_" .. tostring(v.side)
		local carryover_side_inventory_key = "carryover_component_inventory_" .. save_id
		local inventory_data = wesnoth.get_variable(carryover_side_inventory_key)
		if inventory_data then
			wesnoth.set_variable(carryover_side_inventory_key)
			wesnoth.set_variable(carryover_side_inventory_key, side_inventory_key)
		end
	end
end)
