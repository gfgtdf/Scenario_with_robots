-- this file contains all the components, and most of their logic.
-- local wml_codes = z_require("wml_codes")
local component_list = {}
local the_list = {}
component_list.the_list = the_list
component_list.list_by_name = {}


table.insert(the_list, {
	field = { [3] = { [3] = { n = true, s = true, w = true, e = true } } },
	name = "core",
	tooltip = "any component that is not connected to the core will drop away",
	--maybe i should change the function to default bo since pipes don't do anything.
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/core.png",
	field_images = { [3] = { [3] = "c/core.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true, s = true } } },
	name = "pipe_ns",
	tooltip = "too many open ends wil cause a serious drop in the robots defense",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_ns.png",
	field_images = { [3] = { [3] = "c/pipe_ns.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { e = true, w = true } } },
	name = "pipe_ew",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_ew.png",
	field_images = { [3] = { [3] = "c/pipe_ew.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { e = true, s = true } } },
	name = "pipe_es",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_es.png",
	field_images = { [3] = { [3] = "c/pipe_es.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true, e = true } } },
	name = "pipe_ne",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_ne.png",
	field_images = { [3] = { [3] = "c/pipe_ne.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { s = true, w = true } } },
	name = "pipe_sw",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_sw.png",
	field_images = { [3] = { [3] = "c/pipe_sw.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true, w = true } } },
	name = "pipe_nw",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_nw.png",
	field_images = { [3] = { [3] = "c/pipe_nw.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true, e = true, s = true } } },
	name = "pipe_nes",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_nes.png",
	field_images = { [3] = { [3] = "c/pipe_nes.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { e = true, s = true, w = true } } },
	name = "pipe_esw",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_esw.png",
	field_images = { [3] = { [3] = "c/pipe_esw.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true, s = true, w = true } } },
	name = "pipe_nsw",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_nsw.png",
	field_images = { [3] = { [3] = "c/pipe_nsw.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true, e = true, w = true } } },
	name = "pipe_new",
	check_function = function(r_field, robot, objpos) return true end,
	image = "c/pipe_new.png",
	field_images = { [3] = { [3] = "c/pipe_new.png" } }
})
table.insert(the_list, {
	field = { [2] = { [3] = { e = true } }, [3] = { [3] = { e = true, w = true } } },
	name = "simplepike",
	tooltip  = "Pike: the Farther away from the core, the better is the effect, there shouldn't be any items left to it to wirk properly",
	check_function = function(r_field, robot, objpos) 
		for i = 1 , objpos.x - 2 do
			if(r_field[i][objpos.y] ~= "empty") then return false end
		end
		return true 
	end,
	-- id accumulate better i don't know the difference
	aggregate_function = function (robot, comp, aggregator) 
		aggregator.simplepike = aggregator.simplepike or {}
		aggregator.simplepike.damage = max(comp.distance * (2 / 3) + 5, (aggregator.simplepike.damage or 1))
		aggregator.simplepike.number = (aggregator.simplepike.number or 1) + 1
	end,
	apply_function = function(robot, aggregator)
		return wml_codes.get_attack_spear_code(aggregator.simplepike.number, aggregator.simplepike.damage)  , wml_codes.get_imp_advancement("pike")
	end,
	image = "c/simplespear_c.png",
	-- some components (bootsers of other components) are dependant on other components 
	-- so i have to force the order the apply functions are called,
	-- for example an increase damage effect will have no effect if before the new attack effect.
	-- the higher order_apply the later the apply function is called
	-- not implemented yet.
	order_apply = 1,
	field_images = { [2] = { [3] = "c/simplespear_1.png" }, [3] = { [3] = "c/simplespear_c.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { e = true } } },
	name = "simplelaser",
	tooltip = "similar to simplepike but a ranged attack",
	check_function = function(r_field, robot, objpos) 
		for i = 1 , objpos.x - 1 do
			if(r_field[i][objpos.y] ~= "empty") then return false end
		end
		return true 
	end,
	aggregate_function = function (robot, comp, aggregator) 
		aggregator.simplelaser = aggregator.simplelaser or {}
		aggregator.simplelaser.damage = max(8 + (comp.distance / 2), (aggregator.simplelaser.damage or 1))
		aggregator.simplelaser.number = (aggregator.simplelaser.number or 0) + 1
	end,
	apply_function = function(robot, aggregator)
		return wml_codes.get_attack_laser_code(aggregator.simplelaser.number, aggregator.simplelaser.damage) , wml_codes.get_imp_advancement("laser")
	end,
	image = "c/simplelaser.png",
	order_apply = 1,
	field_images = { [3] = { [3] = "c/simplelaser.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { s = true } } },
	name = "propeller",
	tooltip = "can cause huge storms or make the robot fly",
	check_function = function(r_field, robot, objpos) 
		for i = 1 , objpos.y - 1 do
			if(r_field[objpos.y][i] ~= "empty") then return false end
		end
		return true 
	end,
	aggregate_function = function (robot, comp, aggregator) 
		aggregator.propeller = aggregator.propeller or {}
		aggregator.propeller.count = (aggregator.propeller.count or 0) + 1
	end,
	apply_function = function(robot, aggregator)
		local effects = {}
		if aggregator.propeller.count > 2 then
			aggregator.movement_costs.mountains = 2
			aggregator.movement_costs.frozen = 1
			aggregator.movement_costs.swamp_water = 2
			aggregator.movement_costs.shallow_water = 2
			aggregator.movement_costs.unwalkable = 2
			aggregator.movement_costs.deep_water = 2
		end
		if aggregator.propeller.count > 3 then
			aggregator.terrain_defenses_delta.frozen = (aggregator.terrain_defenses_delta.frozen or 0) + 20
			aggregator.terrain_defenses_delta.swamp_water = (aggregator.terrain_defenses_delta.swamp_water or 0) + 20
			aggregator.terrain_defenses_delta.shallow_water = (aggregator.terrain_defenses_delta.shallow_water or 0) + 20
			aggregator.terrain_defenses_delta.unwalkable = (aggregator.terrain_defenses_delta.unwalkable or 0) + 20
			aggregator.terrain_defenses_delta.deep_water = (aggregator.terrain_defenses_delta.deep_water or 0) + 20
		end
		if aggregator.propeller.count > 4 then
			table.insert(effects,wml_codes.get_attack_propellerstorm_code(2, 18)[1] )
		end
		if aggregator.propeller.count > 5 then
			aggregator.movement_costs.mountains = 1
			aggregator.movement_costs.frozen = 1
			aggregator.movement_costs.swamp_water = 1
			aggregator.movement_costs.shallow_water = 1
			aggregator.movement_costs.unwalkable = 1
			aggregator.movement_costs.deep_water = 1
		end
		return effects,  wml_codes.get_imp_advancement("propeller")
	end,
	image = "c/propeller.png",
	field_images = { [3] = { [3] = "c/propeller.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true } } },
	name = "simplewheel",
	tooltip = "makes the robot faster",
	check_function = function(r_field, robot, objpos)
		for i = objpos.y + 1 , robot.size.y do
			if(r_field[objpos.y][i] ~= "empty") then return false end
		end
		return true 
	end,
	aggregate_function = function (robot, comp, aggregator) 
		aggregator.movement = (aggregator.movement < 10) and (aggregator.movement + 3) or (aggregator.movement + 2)
	end,
	image = "c/wheel.png",
	field_images = { [3] = { [3] = "c/wheel.png" } }
})
table.insert(the_list, {
	field = { [3] = { [2] = { s = true }, [3] = { n = true, s = true, e = true }, [4] = { n = true } } },
	name = "bigbow",
	tooltip = "gives abow attack.",
	check_function = function(r_field, robot, objpos)
		for i = 1 , objpos.x - 1 do
			if(r_field[i][objpos.y] ~= "empty") then return false end
		end
		return true 
	end,
	aggregate_function = function (robot, comp, aggregator) 
		aggregator.bigbow = aggregator.bigbow or {}
		aggregator.bigbow.count = (aggregator.bigbow.count or 0) + 1
	end,
	apply_function = function(robot, aggregator)
		local effects = {}
		effects[1] = wml_codes.get_attack_bigbow_code(aggregator.bigbow.count, 20)[1]
		local advancements = wml_codes.get_imp_advancement("bigbow")
		return effects, advancements
	end,
	image = "c/bigbow_c.png",
	field_images = { [3] = { [2] = "c/bigbow_1.png", [3] = "c/bigbow_c.png", [4] = "c/bigbow_2.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { e = true } } },
	name = "four_parted_healing_es_e",
	tooltip = "all partes together provide a powerful healing and regenerateion ability",
	check_function = function(r_field, robot, objpos)
		local heigbours_count = 0
		for k,v in pairs(robot.components) do
			if v.pos.x == objpos.x - 1 and v.pos.y == objpos.y and v.component.name == "four_parted_healing_sw_w"
			or v.pos.x == objpos.x and v.pos.y == objpos.y - 1 and v.component.name == "four_parted_healing_ne_e"
			or v.pos.x == objpos.x - 1 and v.pos.y == objpos.y - 1 and v.component.name == "four_parted_healing_nw_w" then
				heigbours_count = heigbours_count + 1
			end
		end
		--cwo(heigbours_count)
		return  heigbours_count == 3
	end,
	aggregate_function = function (robot, comp, aggregator)
		--nothing here, so a second one is uselesss
	end,
	apply_function = function(robot, aggregator)
		local effects = {}
		effects[1] = wml_codes.get_healing_ability_code(12)[1]
		effects[2] = wml_codes.get_regenerate_ability_code(4)[1]
		return effects, wml_codes.get_imp_advancement("4_part_heal")
	end,
	order_apply = 1,
	image = "c/four_parted_1_es_e.png",
	field_images = { [3] = { [3] = "c/four_parted_1_es_e.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { e = true } } },
	name = "four_parted_healing_ne_e",
	tooltip = "all partes together provide a powerful healing and regenerateion ability",
	check_function = function(r_field, robot, objpos)
		-- the logics are all in four_parted_healing_es_e
		return  true
	end,
	order_apply = 1, -- 1 = no dependecies 
	image = "c/four_parted_1_ne_e.png",
	field_images = { [3] = { [3] = "c/four_parted_1_ne_e.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { w = true } } },
	name = "four_parted_healing_nw_w",
	tooltip = "all partes together provide a powerful healing and regenerateion ability",
	check_function = function(r_field, robot, objpos)
		-- the logics are all in four_parted_healing_es_e
		return  true
	end,
	order_apply = 1, -- 1 = no dependecies 
	image = "c/four_parted_1_nw_w.png",
	field_images = { [3] = { [3] = "c/four_parted_1_nw_w.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { w = true } } },
	name = "four_parted_healing_sw_w",
	tooltip = "all partes together provide a powerful healing and regenerateion ability",
	check_function = function(r_field, robot, objpos)
		-- the logics are all in four_parted_healing_es_e
		return  true
	end,
	order_apply = 1, -- 1 = no dependecies 
	image = "c/four_parted_1_sw_w.png",
	field_images = { [3] = { [3] = "c/four_parted_1_sw_w.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true, w = true } } },
	name = "spear_fire_modier",
	tooltip = "sets spear damage to fire, has to be places near a spear",
	check_function = function(r_field, robot, objpos)
		-- the chach is in the aggregate_function
		return true
	end,
	aggregate_function = function (robot, comp, aggregator)
		local nigbour_type = nil
		for k,v in pairs(robot.components) do
			if v.pos.x == comp.pos.x - 1 and v.pos.y == comp.pos.y and (v.component.name == "simplepike" or v.component.name == "simplelaser") then
				nigbour_type = v.component.name
			end
		end
		aggregator.spear_fire_modier = aggregator.spear_fire_modier  or {}
		if(nigbour_type ~= nil) then	
			aggregator.spear_fire_modier[nigbour_type] = (aggregator.spear_fire_modier[nigbour_type] or 0) + 1
		end
	end,
	apply_function = function(robot, aggregator)
		local effects = {}
		if(aggregator.spear_fire_modier["simplepike"] ~= nil) then
			table.insert(effects, wml_codes.get_change_attack_type_code("spear", "fire", 0, -30)[1])
		end
		if(aggregator.spear_fire_modier["simplelaser"] ~= nil) then
			table.insert(effects, wml_codes.get_change_attack_type_code("laser", "fire", 0, -30)[1])
		end
		return effects, wml_codes.get_imp_advancement("fire_modier")
	end,
	--dependant on simplespear, simplelaser, since i use bonus:attack, wich is always executed after, not implented yet
	-- since this uses "bonus_attack" wich is alwasy appied last by stats.lua it is not needed right now.
	order_apply = 2,
	image = "c/attack_modifier_2_nw.png",
	field_images = { [3] = { [3] = "c/attack_modifier_2_nw.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true } } },
	name = "heating_addon",
	tooltip = "gives resitance to cold damage, has to be placed next to the core",
	check_function = function(r_field, robot, objpos)
		for k,v in pairs(robot.components) do
			if v.pos.x == objpos.x and v.pos.y == objpos.y - 1 and v.component.name == "core" then
				return true
			end
		end
		return false
	end,
	aggregate_function = function (robot, comp, aggregator)
		-- nothing here. since it have to ple places next to the core can can onyl be one of this item anyay
	end,
	apply_function = function(robot, aggregator)
		aggregator.resitances_delta.cold = aggregator.resitances_delta.cold - 20
		return {}
	end,
	--no dependencies
	order_apply = 1,
	image = "c/addon_n.png",
	field_images = { [3] = { [3] = "c/addon_n.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true } } },
	name = "cooling_addon",
	tooltip = "gives resitance to fire damage, has to be placed next to the core",
	check_function = function(r_field, robot, objpos)
		for k,v in pairs(robot.components) do
			if v.pos.x == objpos.x  and v.pos.y == objpos.y - 1 and v.component.name == "core" then
				return true
			end
		end
		return false
	end,
	aggregate_function = function (robot, comp, aggregator)
		-- nothing here. since it have to ple places next to the core can can onyl be one of this item anyay
	end,
	apply_function = function(robot, aggregator)
		aggregator.resitances_delta.fire = aggregator.resitances_delta.fire - 20
		return {}
	end,
	--no dependencies
	order_apply = 1,
	image = "c/addon_2_n.png",
	field_images = { [3] = { [3] = "c/addon_2_n.png" } }
})

table.insert(the_list, {
	field = { [3] = { [3] = { w = true, s = true }, [4] = { n = true} } },
	name = "bombdropper",
	tooltip = "this component gives the robot the ability to drop bombs",
	check_function = function(r_field, robot, objpos)
		for i = objpos.y + 2 , robot.size.y do
			if(r_field[objpos.y][i] ~= "empty") then return false end
		end
		return true 
	end,
	aggregate_function = function (robot, comp, aggregator)
		aggregator.bombdropper = aggregator.bombdropper  or { count = 0}
		aggregator.bombdropper.count = aggregator.bombdropper.count  + 1
		-- nothing here. since it have to ple places next to the core can can onyl be one of this item anyay
	end,
	apply_function = function(robot, aggregator)
		local effects = {}
		table.insert(effects, wml_codes.get_trapper_ability_code(1, "spikes", 2 * aggregator.bombdropper.count)[1])
		return effects, wml_codes.get_imp_advancement("trapper")
	end,
	order_apply = 1, -- 1 = no dependecies 
	image = "c/trapper_c.png",
	field_images = { [3] = { [3] = "c/trapper_c.png", [4] = "c/trapper_1.png" } }
})
table.insert(the_list, {
	field = { [3] = { [3] = { n = true, e = true } } },
	name = "trapper_modifier",
	tooltip = "adds poison to traps",
	check_function = function(r_field, robot, objpos)
		-- the chach is in the aggregate_function
		return true
	end,
	aggregate_function = function (robot, comp, aggregator)
		local nigbour_type = nil
		for k,v in pairs(robot.components) do
			if v.pos.x == comp.pos.x + 1 and v.pos.y == comp.pos.y and (v.component.name == "bombdropper") then
				nigbour_type = v.component.name
			end
		end
		aggregator.trapper_modifier = aggregator.trapper_modifier  or {}
		if(nigbour_type == "bombdropper") then	
			aggregator.trapper_modifier.count = (aggregator.trapper_modifier.count or 0) + 1
		end
	end,
	apply_function = function(robot, aggregator)
		local effects = {}
		if(aggregator.trapper_modifier.count ~= nil) then
			table.insert(effects, wml_codes.get_change_trapper_type_code("poison_spikes")[1])
		end
		
		return effects, wml_codes.get_imp_advancement("trapper_modier")
	end,
	--dependant on simplespear, simplelaser, since i use bonus:attack, wich is always executed after, not implented yet
	-- since this uses "bonus_attack" wich is alwasy appied last by stats.lua it is not needed right now.
	order_apply = 2,
	image = "c/trapper_poison.png",
	field_images = { [3] = { [3] = "c/trapper_poison.png" } }
})




for k,v in pairs(component_list.the_list) do
	if(component_list.list_by_name[v.name] ~= nil) then
		error("multiple name in component_list: " .. v.name)
	end
	component_list.list_by_name[v.name] = v
end

return component_list