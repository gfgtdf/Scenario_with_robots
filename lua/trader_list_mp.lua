local trader_list = {}
table.insert(trader_list, {
	name = "Starter Pack 1", 
	description = "Items to make a small robot with a bow and a wheel.\n",  
	price = 10,
	image = "c/bigbow_c.png",
	apply_func = function(inv)
		inv:add_amount("simplewheel", 1)
		inv:add_amount("bigbow", 1)
		inv:add_amount("pipe_sw",1)
		inv:add_amount("antenna", 1)
	end
})
table.insert(trader_list, {
	name = "Starter Pack 2", 
	description = "Items to make a small robot equipped with lasers and spears.\n",  
	price = 13,
	image = "c/simplespear_1.png",
	apply_func = function(inv)
		inv:add_amount("simplewheel", 2)
		inv:add_amount("pipe_sw",1)
		inv:add_amount("pipe_es",1)
		inv:add_amount("pipe_esw",1)
		inv:add_amount("pipe_sw",1)
		inv:add_amount("pipe_ew",1)
		inv:add_amount("pipe_nw",1)
		inv:add_amount("simplelaser", 1)
		inv:add_amount("simplepike", 1)
	end
})
table.insert(trader_list, {
	name = "wheel", 
	description = "One wheel.\n",  
	price = 3,
	image = "c/wheel.png",
	apply_func = function(inv)
		inv:add_amount("simplewheel", 1)
	end
})
table.insert(trader_list, {
	name = "Spear", 
	description = "One spear\n",  
	price = 4,
	image = "c/simplespear_1.png",
	apply_func = function(inv)
		inv:add_amount("simplepike",1)
	end
})
table.insert(trader_list, {
	name = "Laser", 
	description = "Contains 1 Lasergun\n",  
	price = 4,
	image = "c/simplelaser.png",
	apply_func = function(inv)
		inv:add_amount("simplelaser", 1)
	end
})
table.insert(trader_list, {
	name = "Bigbow", 
	description = "One bow.\n",  
	price = 7, 
	image = "c/bigbow_c.png",
	apply_func = function(inv)
		inv:add_amount("bigbow", 1)
	end
})
table.insert(trader_list, {
	name = "Propellers", 
	description = "2 Propellers.\n",  
	price = 5, 
	image = "c/propeller.png",
	apply_func = function(inv)
		inv:add_amount("propeller", 2)
	end
})
table.insert(trader_list, {
	name = "Pipe pack1", 
	description = "Contains all pipes with 2 ends once\n",  
	price = 8, 
	image = "units/robots/robot_small.png",
	apply_func = function(inv)
		inv:add_amount("pipe_sw",1)
		inv:add_amount("pipe_ew",1)
		inv:add_amount("pipe_es",1)
		inv:add_amount("pipe_nw",1)
		inv:add_amount("pipe_ne",1)
		inv:add_amount("pipe_ns",1)
	end
})
table.insert(trader_list, {
	name = "Pipe pack2", 
	description = "Contains all pipes with 3 ends once\n",  
	price = 15, 
	image = "units/robots/robot_small.png",
	apply_func = function(inv)
		inv:add_amount("pipe_nsw",1)
		inv:add_amount("pipe_esw",1)
		inv:add_amount("pipe_new",1)
		inv:add_amount("pipe_nes",1)
	end
})
table.insert(trader_list, {
	name = "Gimmick pack", 
	description = "Contains healing or +resistance items.\n Note: healing addons take a lot of space and are hard to place.\n",  
	price = 5, 
	image = "units/robots/robot_small.png",
	apply_func = function(inv)
		inv:add_random_items_from_comma_seperated_list("cooling_addon,heating_addon", 1)
		inv:add_random_items_from_comma_seperated_list("four_parted_healing_sw_w,four_parted_healing_nw_w,four_parted_healing_ne_e,four_parted_healing_es_e", 1)
	end
})
table.insert(trader_list, {
	name = "Trapper", 
	description = "Contains eigher a trapper or a trapper modifer\n",  
	price = 4, 
	image = "c/trapper_c.png",
	apply_func = function(inv)
		inv:add_random_items_from_comma_seperated_list("bombdropper,bombdropper,bombdropper,trapper_modifier", 1)
	end
})
table.insert(trader_list, {
	name = "Weapon modifer", 
	description = "Contains weapon modifer that adds fire damage to spears\n",  
	price = 4, 
	image = "c/attack_modifier_2_nw.png",
	apply_func = function(inv)
		inv:add_amount("spear_fire_modier",1)
	end
})
table.insert(trader_list, {
	name = "Antanna", 
	description = "Contains 1 Antenna\n",  
	price = 4,
	image = "c/antenne_oben.png",
	apply_func = function(inv)
		inv:add_amount("antenna", 1)
	end
})
return trader_list
