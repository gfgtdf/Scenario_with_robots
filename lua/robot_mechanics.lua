-- this file gives the "edit_robot_at_xy" function with allows to change a robot by a cutom dialog defindet in gui.lua
-- and the "reapply_bonuses_at_xy" that should be called if the robots variable was changed without this dialog
local robot_mechanics = {}
--local gui = z_require("gui")
--local component_list = z_require("component_list")
--local wml_codes = z_require("wml_codes")
--local helper = z_require("my_helper")
max = function(a, b) return a > b and a or b end
min = function(a, b) return a < b and a or b end



local function create_component_image(comp)
	local min_x = 2
	local max_x = 4
	local min_y = 2
	local max_y = 4
	
	--caclualte teh size for the image but make it at lest 3x3.
	for i_x = 1, 5 do
		for i_y = 1, 5 do
			if (comp.field[i_x] or {})[i_y] or (comp.field_images[i_x] or {})[i_y] then
				min_x = min(min_x, i_x)
				max_x = max(max_x, i_x)
				min_y = min(min_y, i_y)
				max_y = max(max_y, i_y)
			end
		end
	end
	local res = { "misc/tpixel.png~SCALE(" , 40 * (max_x - min_x + 1) , "," , 40 * (max_y - min_y + 1), ")" }
	for i_x = 1, 5 do
		for i_y = 1, 5 do
			local is_field = (comp.field[i_x] or {})[i_y]
			local image = (comp.field_images[i_x] or {})[i_y]
			local pos_x = (i_x  - min_x) * 40
			local pos_y = (i_y  - min_y) * 40
			if is_field then
				table.insert(res, "~BLIT(misc/twhitesqare40.png,")
				table.insert(res, tostring(pos_x))
				table.insert(res, ",")
				table.insert(res, tostring(pos_y))
				table.insert(res, ")")
			end
			if image then
				table.insert(res, "~BLIT(")
				table.insert(res, image)
				table.insert(res, ",")
				table.insert(res, tostring(pos_x))
				table.insert(res, ",")
				table.insert(res, tostring(pos_y))
				table.insert(res, ")")
			end
		end
	end
	table.insert(res, "~BLIT(cursors/normal.png,")
	table.insert(res, tostring(16 + 40 * (3 - min_x)))
	table.insert(res, ",")
	table.insert(res, tostring(16 + 40 * (3 - min_y)))
	table.insert(res, ")")
	if min_x ~= 2 or  max_x ~= 4 or  min_y ~= 2 or  max_x ~= 4 then
		table.insert(res, "~SCALE(120,120)")
	end
	return table.concat(res)
end

robot_mechanics.edit_robot_at_xy = function(x, y)
	local unit_cfg = wesnoth.get_unit(x, y).__cfg
	local variables = helper.get_child(unit_cfg, "variables")
	local default_size = {}
	-- we check if the robot has gottten bigger for example by levelup.
	for dummy in helper.child_range(helper.get_child(unit_cfg, "abilities"), "dummy") do
		if(dummy.id == "robot_ability") then
			default_size.x = dummy.sizex
			default_size.y = dummy.sizey
		end
	end
	default_size.x = default_size.x or 2
	default_size.y = default_size.y or 2
	-- here we load the "robot" variable from the units variablres
	local robot_string = variables.robot or "{ size = { x = " .. tostring(default_size.x) ..", y = " .. tostring(default_size.y) .." }, components = {} }"
	local robot = loadstring("return " .. robot_string )()
	
	r_sizeX_delta = max(default_size.x - robot.size.x, 0)
	r_sizeY_delta = max(default_size.y - robot.size.y, 0)
	
	robot.size.x = max(robot.size.x, default_size.x)
	robot.size.y = max(robot.size.y, default_size.y)
	for i =1, #robot.components do
		-- in case the field grows i want to grow it to above not at down
		local pos = robot.components[i].pos
		pos.y = pos.y + r_sizeY_delta
		pos.x = pos.x
		robot.components[i].component = component_list.list_by_name[robot.components[i].component]
	end
	--
	local has_inventory_fierd = false
	local inv = inventories[wesnoth.current.side]
	inv.open()
	local edit_result = wesnoth.synchronize_choice(function ()
		
		local inv_delta = robot_mechanics.edit_robot(robot, inv)
		
		local robot_to_seralize = {}
		-- copy only on first level
		for k,v in pairs(robot) do
			robot_to_seralize[k] = v
		end
		robot_to_seralize.components = {}
		for i =1, #robot.components do
			local new_comp = {}
			local old_comp = robot.components[i]
			robot_to_seralize.components[i] = new_comp
			for k,v in pairs(old_comp) do
				new_comp[k] = v
			end
			new_comp.component = old_comp.component.name
		end
		-- by doing that we dont need to unseralize the robot unnessesarily.
		has_inventory_fierd = true
		robotstring = swr_h.serialize_oneline(robot_to_seralize)
		return { robotstring = robotstring, T.inv_delta (inv_delta)}
	end,
	function()
		error("edit robot called by ai.")
	end)
	
	for k, v in pairs(edit_result[1][2]) do
		inv.add_amount(k, v)
	end
	inv.close()
	
	if not has_inventory_fierd then
		robot = loadstring("return " .. edit_result.robotstring )()
		for i =1, #robot.components do
			robot.components[i].component = component_list.list_by_name[robot.components[i].component]
		end
	end
	
	variables.robot = edit_result.robotstring
	robot_mechanics.apply_bonuses(unit_cfg, robot)
	wesnoth.put_unit(unit_cfg)
end
-- we collect all compnents from the inventory and from the robot 
robot_mechanics.get_accesible_components = function(inventory ,robot)
	local ac = {}
	table.insert(ac, { component = component_list.list_by_name["core"], number = 1 })
	for k,v in pairs(inventory.inv_set) do
		-- note that items that were in the inventory once still have an entry there even if their number is 0
		if v ~= 0 then
			table.insert(ac, { component = component_list.list_by_name[k], number = v })
		end
	end
	for k,v in pairs(robot.components) do
		local has_this_component_already = false
		for k2, v2 in pairs(ac) do	
			if v2.component.name == v.component.name then
				has_this_component_already = true
			end
		end
		if v.component.name == "core" then
			ac[1].number = 0
		end
		if not has_this_component_already then
			table.insert(ac, { component = v.component, number = 0 })
		end
	end
	local sorter = function(comp1, comp2)
		comp1 = comp1.component
		comp2 = comp2.component
		local order_1 = comp1.toolbox_order or 0
		local order_2 = comp2.toolbox_order or 0
		if order_1 == order_2 then
			return comp1.name < comp2.name
		else
			return order_1 < order_2
		end
	end
	table.sort(ac, sorter)
	return ac
end
-- shows the robot edit dialog and writes the canges into the robot variable
-- this function changes the robot variable, and returns wich items are taken from the inventory
-- this function assumes that the inventory is open but doesn't change it(because this is called in a sync_context).
robot_mechanics.edit_robot = function(robot, inv)
	local invenory_delta = {}
	local sizeX = robot.size.x
	local sizeY = robot.size.y
	local imagelist = {}
	local tooltiplist = {}
	local down_labels = {}
	local field = {}
	-- im still note sure weather i need this.
	local components_reference_field = {}
	-- later the won't be all components accessible.
	-- saving the max number of alowed comonents of 1 type in this list seems also useful to me.
	local accessible_components = robot_mechanics.get_accesible_components(inv ,robot)
	for ix = 1, sizeX do 
		field [ix] = {} 
		components_reference_field[ix] = {} 
		for iy = 1, sizeY do 
			field [ix][iy] = "empty"
		end
	end
	table.insert(imagelist, "c/empty.png")
	table.insert(down_labels, "del")
	table.insert(tooltiplist, "removes a component")
	for k,v in pairs(accessible_components) do
		table.insert(imagelist, v.component.image)
		table.insert(down_labels, tostring(v.number))
		tooltiplist[#imagelist] = v.component.tooltip
	end
	-- classic topdown programming here ..
	local dialog = gui.Dialog3.new(sizeX, sizeY, imagelist, 1, tooltiplist, 6, down_labels)
	--for i = 1, # imagelist do
	--	dialog.set_down_label(i, tostring(i))
	--end
	-- this function does no checks so it asummes it is all right.
	function place_component(pos, component, graphic_only)
		graphic_only = graphic_only or false
		local ix_start = max(1, 4 - pos.x)
		local ix_end = min(5, sizeX - pos.x + 3)
		local iy_start = max(1, 4 - pos.y)
		local iy_end = min(5, sizeY - pos.y + 3)
		for ix = ix_start, ix_end do 
			for iy = iy_start, iy_end do
				if (component.field_images[ix] or {}) [iy] ~= nil then
					dialog.set_image(pos.x + ix - 3, pos.y + iy - 3, component.field_images[ix][iy])
				end
				if (component.field[ix] or {}) [iy] ~= nil then
					field[pos.x + ix - 3][pos.y + iy - 3] = component.field[ix][iy]
				end
			end
		end
		components_reference_field[pos.x][pos.y] = component
		if not graphic_only then
			table.insert(robot.components, { pos = pos, component = component })
		end
	end
	-- this function does no checks so it asummes it is all right.
	function remove_component(pos, component, graphic_only)
		graphic_only = graphic_only or false
		local ix_start = max(1, 4 - pos.x)
		local ix_end = min(5, sizeX - pos.x + 3)
		local iy_start = max(1, 4 - pos.y)
		local iy_end = min(5, sizeY - pos.y + 3)
		for ix = ix_start, ix_end do 
			for iy = iy_start, iy_end do
				if (component.field_images[ix] or {}) [iy] ~= nil then
					dialog.set_image(pos.x + ix - 3, pos.y + iy - 3, imagelist[1])
				end
				if (component.field[ix] or {}) [iy] ~= nil then
					field[pos.x + ix - 3][pos.y + iy - 3] = "empty"
				end
			end
		end 
		components_reference_field[pos.x][pos.y] = nil
		if not graphic_only then
			swr_h.remove_from_array(robot.components, function(rcomp) return rcomp.pos.x == pos.x and rcomp.pos.y == pos.y end)
		end
	end
	for k,v in pairs(robot.components) do
		place_component(v.pos, v.component, true)
	end
	-- if we pass imageid to on_field_clicked this is not needed
	function on_image_chosen(imageid)
		if imageid == 1 then
			dialog.set_selected_item_image("misc/tpixel.png~SCALE(120,120)")
		else
			dialog.set_selected_item_image(create_component_image(accessible_components[imageid - 1].component))
		end
	end
	function on_field_clicked(pos, imageid)
		-- the imageid is also the coresponding comonent index in that array
		if imageid == 1 then
			if robot_mechanics.can_remove_that_there(components_reference_field, pos, robot) then
				local old_name = components_reference_field[pos.x][pos.y].name
				remove_component(pos, components_reference_field[pos.x][pos.y])
				-- add the component in the accessible_components list
				for k, v in pairs(accessible_components) do
					if old_name == v.component.name then
						v.number = v.number + 1
						if old_name ~= "core" then
							invenory_delta[old_name] = (invenory_delta[old_name] or 0) + 1
							
						end
						
						dialog.set_down_label(k + 1, tostring(v.number))
					end
				end
				
			end
		elseif imageid ~= 1 then
			-- -1 because we have the empy at first place
			-- TODO because can_put_that_there only checks if it fitts in the field we also have to check weather the player is alowwed to do that, 
			-- for example placing two cores shoudln't be alowed or the player shouldn't be able to place an ithen wich he doesn't have 
			-- i tihnk doing this all together with the fixed fields and the inventory is the best.
			-- EDIT it is done
			if robot_mechanics.can_put_that_there(field, accessible_components[imageid - 1].component, pos) and accessible_components[imageid - 1].number > 0 then
				place_component(pos, accessible_components[imageid - 1].component)
				accessible_components[imageid - 1].number = accessible_components[imageid - 1].number - 1
				dialog.set_down_label(imageid, tostring(accessible_components[imageid - 1].number))
				--cores cannot be put in inventory
				if(imageid ~= 2) then
					local compname = accessible_components[imageid - 1].component.name
					invenory_delta[compname] = (invenory_delta[compname] or 0) - 1
				end
			end
		end
	end
	--initilize the image
	on_image_chosen(1)
	dialog.on_image_chosen = on_image_chosen
	dialog.on_field_clicked = on_field_clicked
	dialog.show_dialog()
	--it's still not over
	local pos_of_core = nil
	for k,v in pairs(robot.components) do
		if v.component.name == "core" then 
			pos_of_core = v.pos
		end
	end
	--does this work when no core is found? (pos_of_core = nil).
	local connected_comonents = robot_mechanics.find_connected_items(field, robot, pos_of_core)
	for k1,v1 in pairs(robot.components) do
		local is_connected = false
		for k2, v2 in pairs(connected_comonents) do
			if(v1.pos.x == v2.pos.x and v1.pos.y == v2.pos.y) then
				is_connected = true
			end
		end
		if not is_connected then
			--we dont want to loose our comonents.
			if(v1.component.name == "core") then
				error("a core is not connected to the core :S")
			end
			invenory_delta[v1.component.name] = (invenory_delta[v1.component.name] or 0) + 1
		end
	end
	robot.components = connected_comonents
	--TODO change stats acording to the robot structure, i thought about adding an "object" or "advance" to the robot that contains all the efects and might be quite long.
	--(is there a major diefference between "object" and "advance"?)
	--EDIT: if i use stats.lua there IS one because some effect tags are only acceptd form "advance" others only from "object", i could fix that but i don't have the time do to.
	--EDIT2: im changing stats.lua to make that difference disappear
	--maybe i'll use stats.lua to ensure everythings alright.
	--EDIT3: ocf stats.lua is called (was it really me writing the comment before?), but by te caller of this method here
	
	return invenory_delta
end

robot_mechanics.can_put_that_there = function(robot_field, item, position)
	for ix = 1 , 5 do
		for iy = 1,5 do
			if ((item.field[ix] or {})[iy] ~= nil 
				and ( robot_field[ix + position.x - 3] 
					or {})[iy + position.y - 3] ~= "empty") then
				return false
			end
		end
	end
	return true
end
-- i added this functionto support fixed comonents that cannot be removed by the player.
robot_mechanics.can_remove_that_there = function(components_reference_field, position, robot)
	if components_reference_field[position.x][position.y] == nil then
		return false
	end
	for k,v in pairs(robot.components) do
		if (v.pos.x == position.x and v.pos.y == position.y ) then
			if v.fixed ~= true then
				return true
			else
				return false
			end
		end
	end
	error("error in can_remove_that_there")
end

robot_mechanics.find_connected_items = function(field, robot, startpos)
	local found_objects = {}
	local pos_todo = {}
	local pos_done = {}
	local sizeY = robot.size.y
	local sizeX = robot.size.x
	local distance = 0
	local open_ends_count = 0
	local rings_count = 0
	if startpos ~= nil then
		pos_todo[1] = { x = startpos.x, y = startpos.y, distance = 0 }
		pos_done[startpos.x * sizeY + startpos.y] = true
	end
	while #pos_todo > 0 do
		--removing the last element is the fastest, at least i think so.
		--using the first element has the benefit of also giving us the "distance" to the startpos.
		local posnow = table.remove(pos_todo, #pos_todo) 
		for k,v in pairs(robot.components) do
			if(v.pos.x == posnow.x and v.pos.y == posnow.y) then
				v.distance = posnow.distance
				table.insert(found_objects, v)
			end
		end
		--TODO: im not sure weather the nullpoint is in the upper or the downer corner.
		if field[posnow.x][posnow.y]["n"] == true then
			if ((field[posnow.x] or {})[posnow.y - 1] or {})["s"] == true and (pos_done[posnow.x * sizeY + posnow.y - 1] == nil) then
				--this means we have found a new connected comonent
				pos_done[posnow.x * sizeY + posnow.y - 1] = "sighted"
				table.insert(pos_todo, { x = posnow.x, y = posnow.y - 1, distance = posnow.distance  + 1 })
			elseif ((field[posnow.x] or {})[posnow.y - 1] or {})["s"] == true and (pos_done[posnow.x * sizeY + posnow.y - 1] == "sighted") then
				--we have found a connected component that was already known but not processed yet.
				--rings infrease the units def.
				rings_count = rings_count + 1
			elseif not (((field[posnow.x] or {})[posnow.y - 1] or {})["s"] == true) then
				--we have found an open end
				--too much open endpoints lower the units def.
				open_ends_count = open_ends_count + 1
			end
		end
		if field[posnow.x][posnow.y]["s"] == true then
			if ((field[posnow.x] or {})[posnow.y + 1] or {})["n"] == true and (pos_done[posnow.x * sizeY + posnow.y + 1] == nil) then
				pos_done[posnow.x * sizeY + posnow.y + 1] = "sighted"
				table.insert(pos_todo, { x = posnow.x, y = posnow.y + 1, distance = posnow.distance  + 1  })
			elseif ((field[posnow.x] or {})[posnow.y + 1] or {})["n"] == true and (pos_done[posnow.x * sizeY + posnow.y + 1] == "sighted") then
				rings_count = rings_count + 1
			elseif not (((field[posnow.x] or {})[posnow.y + 1] or {})["n"] == true) then
				open_ends_count = open_ends_count + 1
			end
		end
		if field[posnow.x][posnow.y]["e"] == true then
			if ((field[posnow.x + 1] or {})[posnow.y] or {})["w"] == true and (pos_done[(posnow.x + 1) * sizeY + posnow.y] == nil) then
				pos_done[(posnow.x + 1) * sizeY + posnow.y] = "sighted"
				table.insert(pos_todo, { x = posnow.x + 1, y = posnow.y, distance = posnow.distance  + 1 })
			elseif ((field[posnow.x + 1] or {})[posnow.y] or {})["w"] == true and (pos_done[(posnow.x + 1) * sizeY + posnow.y] == "sighted") then
				rings_count = rings_count + 1
			elseif not (((field[posnow.x + 1] or {})[posnow.y] or {})["w"] == true) then
				open_ends_count = open_ends_count + 1
			end
		end
		if field[posnow.x][posnow.y]["w"] == true then
			if	((field[posnow.x - 1] or {})[posnow.y] or {})["e"] == true and (pos_done[(posnow.x - 1) * sizeY + posnow.y] == nil) then
				pos_done[(posnow.x - 1) * sizeY + posnow.y] = "sighted"
				table.insert(pos_todo, { x = posnow.x - 1, y = posnow.y, distance = posnow.distance  + 1 })
			elseif ((field[posnow.x - 1] or {})[posnow.y] or {})["e"] == true and (pos_done[(posnow.x - 1) * sizeY + posnow.y] == "sighted") then
				rings_count = rings_count + 1
			elseif not (((field[posnow.x - 1] or {})[posnow.y] or {})["e"] == true) then
				open_ends_count = open_ends_count + 1
			end
				
		end
		pos_done[(posnow.x ) * sizeY + posnow.y] = "done"
	end
	robot.open_ends_count = open_ends_count
	robot.rings_count = rings_count
	return found_objects
end
-- this function applys the bonusses
-- returns: 
--   effects: the effects that shoudl be applied
--   advanced: advances that should be applied this is to mak eth ecomonents reqwuirements for advances.
robot_mechanics.calcualte_bonuses = function(field, robot, unit_type)

	local open_ends_count = robot.open_ends_count
	local rings_count = robot.rings_count
	
	open_ends_count = max (1, open_ends_count ) - 1
	local aggregator = {}
	local apply_functions = {}
	aggregator.component_images = {}
	aggregator.movement = 0
	aggregator.movement_costs = {}
	aggregator.terrain_defenses_delta = {}
	aggregator.resitances_delta = {}
	aggregator.resitances_delta.arcane = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.cold = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.fire = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.blade = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.pierce = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.impact = (open_ends_count - rings_count) * 4
	for k, v in pairs(robot.components) do
		if v.component.check_function(field, robot, v.pos) then
		
			if v.component.aggregate_function ~= nil then
				v.component.aggregate_function(robot, v, aggregator)
			end
			if v.component.apply_function ~= nil then
				apply_functions[v.component.apply_function] = true
			end
		end
	end
	local all_effects = {}
	local all_advances = {}
	for k, v in pairs(apply_functions) do
		local new_effects, new_advances = k(robot, aggregator)
		for k2, v2 in pairs(new_effects or {}) do
			table.insert(all_effects, v2)
		end
		for k2, v2 in pairs(new_advances or {}) do
			table.insert(all_advances, v2)
		end
	end
	table.insert(all_effects, wml_codes.get_ad_movement_code(aggregator.movement)[1])
	table.insert(all_effects, wml_codes.get_ad_movement_costs_code(aggregator.movement_costs)[1])
	table.insert(all_effects, wml_codes.get_ad_resistances_code(aggregator.resitances_delta.arcane, aggregator.resitances_delta.cold, aggregator.resitances_delta.fire, aggregator.resitances_delta.blade, aggregator.resitances_delta.pierce, aggregator.resitances_delta.impact)[1])
	local ipfs = { }
	local type_image_mods = (unit_types_data[unit_type] or {}).image_mods or {}
	for k,v in pairs(aggregator.component_images) do
		local f = type_image_mods[k]
		if f ~= nil then
			f(v, ipfs)
		end
	end
	table.insert(all_effects, wml_codes.get_ipfs_code(ipfs)[1])
	return all_effects, all_advances
end

robot_mechanics.reapply_bonuses_at_xy = function(x, y)
	local unit_cfg = wesnoth.get_unit(x, y).__cfg
	local variables = helper.get_child(unit_cfg, "variables")
	local robot_string = variables.robot
	if not robot_string then
	else
		local robot = loadstring("return " .. robot_string )()
		for i =1, #robot.components do
			robot.components[i].component = component_list.list_by_name[robot.components[i].component]
		end
		robot_mechanics.apply_bonuses(unit_cfg, robot)
		wesnoth.put_unit(unit_cfg)
	end
end


robot_mechanics.apply_bonuses = function(unit_cfg, robot, unit_type)
	local sizeX = robot.size.x
	local sizeY = robot.size.y
	local field = {}
	local startpos = {}
	for ix = 1, sizeX do 
		field [ix] = {} 
		for iy = 1, sizeY do 
			field [ix][iy] = "empty"
		end
	end
	function place_component_on_field(pos, component)
		local ix_start = max(1, 4 - pos.x)
		local ix_end = min(5, sizeX - pos.x + 3)
		local iy_start = max(1, 4 - pos.y)
		local iy_end = min(5, sizeY - pos.y + 3)
		for ix = ix_start, ix_end do 
			for iy = iy_start, iy_end do
				if (component.field[ix] or {}) [iy] ~= nil then
					field[pos.x + ix - 3][pos.y + iy - 3] = component.field[ix][iy]
				end
			end
		end
	end
	for k,v in pairs(robot.components) do
		place_component_on_field(v.pos, v.component)
		if v.component.name == "core" then
			startpos = v.pos
		end
	end
	if (robot.open_ends_count == nil or robot.rings_count == nil) then
		local found_objects = robot_mechanics.find_connected_items(field, robot, startpos)
		if #found_objects ~= #robot.components then
			error("found_objects=" .. tostring(#found_objects) .. " but #robot.components=" .. tostring(#robot.components))
		end
		robot.components = found_objects
	end	
	local effects, new_advancements = robot_mechanics.calcualte_bonuses(field, robot, unit_cfg.type)
	robot_mechanics.replace_robot_advancements(unit_cfg, effects, new_advancements)	
end

robot_mechanics.replace_robot_advancements = function(unit_cfg, effects, new_advancements)
	local modifications_cfg = helper.get_child(unit_cfg, "modifications")
	swr_h.remove_from_array(modifications_cfg, function(a) 
		--remove the old new_advancements
		if(a[2].id ~= nil and swr_h.string_starts(a[2].id, "robot_imp_")) then
			return true
		end
		-- remove the robot_improvements
		return a[2].name == "robot_improvements"
	end)
		
	local obj_cfg = wml_codes.get_robot_object(effects)
	table.insert(modifications_cfg, 1, obj_cfg)
	for k,v in pairs(new_advancements) do
		table.insert(modifications_cfg, 2, v)
	end
end



















return robot_mechanics