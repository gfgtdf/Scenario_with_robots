local on_event = wesnoth.require("on_event")

on_event("start", function (event_context)
	wesnoth.wml_actions.set_menu_item {
		description = "Buy components",
		id = "menu_open_trader",
	}
	wesnoth.wml_actions.set_menu_item {
		description = "Read a book",
		id = "menu_read_book",
		synced = false,
	}
end)

on_event("menu_item menu_open_trader", function (event_context)
	swr_h.disallow_undo()
	-- i want to save the save the items that are alredy bought so i use an "inventory" object for that
	trader_inv_minus = swr.globals.trader_inv_minus or swr.Inventory:create("trader_inv")
	trader_inv_minus:open()
	local side = wesnoth.sides[wesnoth.current.side] 
	local item_list = swr_trader.lists["default"]
	for k, v in pairs(trader_inv_minus:get_invenory_set()) do
		item_list[k].quantity = (item_list[k].quantity) and (item_list[k].quantity - v)
	end
	local bought_items, price = swr_trader.buy_items(item_list, side.gold)
	for k, v in pairs(trader_inv_minus:get_invenory_set()) do
		item_list[k].quantity = (item_list[k].quantity) and (item_list[k].quantity + v)
	end
	local inv = swr.Inventory:get_open(wesnoth.current.side, "component_inventory")

	for k, v in pairs(bought_items) do
		for i = 1, v do
			item_list[k].apply_func(inv)
		end
		trader_inv_minus:add_amount(k, v)
	end
	inv:close()
	trader_inv_minus:close()
	side.gold = side.gold - price
end)

on_event("menu_item menu_read_book", function (event_context)
	swr_h.disallow_undo()
	local book_manual = swr.require("book_maual")
	local book_dialog = swr.BookDialog:new(book_manual.pages)
	--this doesn't change the game so no wesnoth.sync is needed
	book_dialog:show_dialog()
end)

-- use this to give the player a certain amount of components whenever he recruits a robot.
on_event("recruit", function (event_context)
	swr_h.disallow_undo()
	-- why is the "race" property not accessible though the proxy?
	local unit_cfg = wesnoth.units.get(event_context.x1, event_context.y1).__cfg
	-- without wheels robots are slow as hell, so we give the player a wheel for each recruited unit
	if unit_cfg.race == "zt_robots" then
		local inv = swr.Inventory:get_open(wesnoth.current.side, "component_inventory")
		inv:add_amount("simplewheel", 1)
		inv:add_random_items_from_comma_seperated_list("simplepike,simplelaser,simplepike,simplelaser,bigbow", 1)
		inv:add_random_items_from_comma_seperated_list("pipe_ns,pipe_ne,pipe_nw,pipe_es,pipe_ew,pipe_sw", 3)
		inv:add_random_items_from_comma_seperated_list("pipe_nes,pipe_new,pipe_esw,pipe_nsw", 1)
		inv:add_random_items(2)
		inv:close()
	end
end)
