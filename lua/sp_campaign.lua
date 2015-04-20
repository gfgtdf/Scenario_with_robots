global_events.add_event_handler("start", function (event_context)
	wesnoth.wml_actions.set_menu_item {
		description = "Buy components",
		id = "menu_open_trader",
	}
	wesnoth.wml_actions.set_menu_item {
		description = "Read a book",
		id = "menu_read_book",
	}
end)

global_events.create_disallow_undo_workaround("menu_item menu_open_trader")
global_events.add_event_handler("menu_item menu_open_trader", function (event_context)
	global_events.disallow_undo_flag = true
	-- i want to save the save the items that are alredy bought so i use an "inventory" object for that
	trader_inv_minus = globals.trader_inv_minus or Inventory.new("trader_inv")
	trader_inv_minus.open()
	
	local side = wesnoth.sides[wesnoth.current.side] 
	local item_list = trader.lists["default"]
	
	for k, v in pairs(trader_inv_minus.get_invenory_set()) do
		item_list[k].quantity = (item_list[k].quantity) and (item_list[k].quantity - v)
	end
	
	local bought_items, price = trader.buy_items(item_list, side.gold)
	
	for k, v in pairs(trader_inv_minus.get_invenory_set()) do
		item_list[k].quantity = (item_list[k].quantity) and (item_list[k].quantity + v)
	end
	local inv = inventories[wesnoth.current.side]
	inv.open()
	for k, v in pairs(bought_items) do
		for i = 1, v do
			item_list[k].apply_func(inv)
		end
		trader_inv_minus.add_amount(k, v)
		
	end
	
	inv.close()
	trader_inv_minus.close()
	side.gold = side.gold - price
end)

global_events.create_disallow_undo_workaround("menu_item menu_read_book")
global_events.add_event_handler("menu_item menu_read_book", function (event_context)
	global_events.disallow_undo_flag = true
	local book_manual = z_require("book_maual")
	local book_dialog = Gui_test.new(book_manual.pages)
	--this doesn't change the game so no synchronize_choice is needed
	book_dialog.show_dialog()
end)

-- use this to give the player a certain amount of components whenever he recruits a robot.
global_events.create_disallow_undo_workaround("recruit")
global_events.add_event_handler("recruit", function (event_context)
	global_events.disallow_undo_flag = true
	-- why is the "race" property not accessible though the proxy?
	local unit_cfg = wesnoth.get_unit(event_context.x1, event_context.y1).__cfg
	-- without wheels robots are slow as hell, so we give the player a wheel for each recruited unit
	if unit_cfg.race == "zt_robots" then
		local inv = inventories[wesnoth.current.side]
		inv.open()
		inv.add_amount("simplewheel", 1)
		inv.add_random_items_from_comma_seperated_list("simplepike,simplelaser,simplepike,simplelaser,bigbow", 1)
		inv.add_random_items_from_comma_seperated_list("pipe_ns,pipe_ne,pipe_nw,pipe_es,pipe_ew,pipe_sw", 3)
		inv.add_random_items_from_comma_seperated_list("pipe_nes,pipe_new,pipe_esw,pipe_nsw", 1)
		inv.add_random_items(2)
		inv.close()
	end
end)
