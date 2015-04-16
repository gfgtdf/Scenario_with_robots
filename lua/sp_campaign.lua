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

global_events.add_event_handler("menu_item menu_open_trader", function (event_context)
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

global_events.add_event_handler("menu_item menu_read_book", function (event_context)
	local book_manual = z_require("book_maual")
	local book_dialog = Gui_test.new(book_manual.pages)
	--this doesn't change the game so no synchronize_choice is needed
	book_dialog.show_dialog()
end)
