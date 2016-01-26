local trader = {}
trader.lists = {}

trader.buy_items = function(item_list, max_gold)
	local buy_result_str = wesnoth.synchronize_choice(function ()
		local seller = Seller.new()
		local price = 0
		seller.set_item_list(item_list)
		local reet = seller.show_dialog()
		for k,v in pairs(reet) do
			price = price + v * item_list[k].price
		end
		if price > max_gold then
			reet = {}
			price = 0
		end
		return { s = swr_h.serialize_oneline(reet), p = price}
	end,
	function()
		error("buy_items called by ai.")
	end)
	return loadstring("return ".. buy_result_str.s)(), buy_result_str.p
end

local default_list = {}
trader.lists["default"] = default_list 
table.insert(default_list, {
	name = "Little robot pack", 
	description = "this pack contains the same items you get if you buy a little robot.\n",  
	price = 20, 
	image = "units/robots/robot_small.png",
	apply_func = function(inv)
		inv.add_amount("simplewheel", 1)
		inv.add_random_items_from_comma_seperated_list("simplepike,simplelaser,simplepike,simplelaser,bigbow", 1)
		inv.add_random_items_from_comma_seperated_list("pipe_ns,pipe_ne,pipe_nw,pipe_es,pipe_ew,pipe_sw", 3)
		inv.add_random_items_from_comma_seperated_list("pipe_nes,pipe_new,pipe_esw,pipe_nsw", 1)
		inv.add_random_items(2)
	end
})
table.insert(default_list, {
	name = "Random item pack", 
	description = "this pack contains one random item.\n",  
	price = 4, 
	image = "misc/unknown1.png",
	apply_func = function(inv)
		inv.add_random_items(1)
	end
})
table.insert(default_list, {
	name = "Bigbow", 
	description = "contains a bogbow.\n",  
	price = 10, 
	quantity = 2,
	image = "c/bigbow_c.png",
	apply_func = function(inv)
		inv.add_amount("bigbow", 1)
	end
})
table.insert(default_list, {
	name = "Propellers", 
	description = "contains 2 propellers.\n",  
	price = 20, 
	quantity = 2,
	image = "c/propeller.png",
	apply_func = function(inv)
		inv.add_amount("propeller", 2)
	end
})
table.insert(default_list, {
	name = "Pipe pack1", 
	description = "contains all pipes with 2 ends once\n",  
	price = 20, 
	image = "units/robots/robot_small.png",
	apply_func = function(inv)
		inv.add_amount("pipe_sw",1)
		inv.add_amount("pipe_ew",1)
		inv.add_amount("pipe_es",1)
		inv.add_amount("pipe_nw",1)
		inv.add_amount("pipe_ne",1)
		inv.add_amount("pipe_ns",1)
	end
})
table.insert(default_list, {
	name = "Pipe pack2", 
	description = "contains all pipes with 3 ends once\n",  
	price = 30, 
	image = "units/robots/robot_small.png",
	apply_func = function(inv)
		inv.add_amount("pipe_nsw",1)
		inv.add_amount("pipe_esw",1)
		inv.add_amount("pipe_new",1)
		inv.add_amount("pipe_nes",1)
	end
})
table.insert(default_list, {
	name = "Spear", 
	description = "contains a spear\n",  
	price = 10, 
	quantity = 2,
	image = "c/simplespear_1.png",
	apply_func = function(inv)
		inv.add_amount("simplepike",1)
	end
})
return trader