local on_event = wesnoth.require("on_event")

on_event("menu_item menu_edit_robot", function(event_context)
	swr.mechanics.edit_robot_at_xy(event_context.x1,event_context.y1)
	swr_h.disallow_undo()
end)

on_event("start", function(event_context)
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
on_event("die", function(event_context)
	local drop_item_on_die = wml.variables.wc2_config_drop_item_on_die
	local u = wesnoth.units.get(event_context.x1, event_context.y1)
	local unit_cfg = u.__cfg
	local variables = wml.get_child(unit_cfg, "variables")
	local little_inventory = {}
	if variables.robot ~= nil and drop_item_on_die then
		local robot2 = swr.RobotEditor:create_from_unit(u)
		for k,v in ipairs(robot2.robot.components) do
			if v.component.name ~= "core" then
				little_inventory[v.component.name] = (little_inventory[v.component.name] or 0) + 1
			end
		end
		-- TODO: find a better image.

		wesnoth.wml_actions.item {
			x = event_context.x1,
			y = event_context.y1,
			image = "items/box.png",
			z_order = 15,
			wml.tag.variables { wml.tag.swr_components(little_inventory) },
		}
		--dropping.add_item(event_context.x1, event_context.y1, { image = "items/box.png", dropped_components = little_inventory })
	end
end)

on_event("post advance", function(event_context)
	-- This is needed to adjust the overlay for the animatiosn for the new unit type.
	wesnoth.wml_actions.swr_update_unit { x = event_context.x1, y = event_context.y1}
end)

on_event("swr_pickup_item", function(event_context)
	local dropped_items = wml.get_child(swr.dropping.current_item.variables or {}, "swr_components")

	if dropped_items == nil then
		return
	end

	if #wesnoth.units.find_on_map ({ side = wesnoth.current.side, ability = "robot_ability"}) == 0 then
		-- robot components can only be picked up from sides that own robots.
		return
	end
	local inventory = swr.Inventory:get_open(wesnoth.current.side, "component_inventory")
	for k,v in pairs(dropped_items) do
		inventory:add_amount(k,v)
	end
	inventory:close()
	swr.dropping.item_taken = true
end)

