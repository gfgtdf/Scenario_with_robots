local trader_list_mp = z_require("trader_list_mp")

global_events.add_event_handler("prestart", function (event_context)
	wesnoth.wml_actions.set_menu_item {
		description = "Buy components",
		id = "robot_trader_mp",
	}
end)
global_events.add_event_handler("menu_item robot_trader_mp", function (event_context)
	local side = wesnoth.sides[wesnoth.current.side] 
	local bought_items, price = trader.buy_items(trader_list_mp, side.gold)
	local inv = inventories[wesnoth.current.side]
	inv.open()
	for k, v in pairs(bought_items) do
		for i = 1, v do
			trader_list_mp[k].apply_func(inv)
		end
	end
	inv.close()
	side.gold = side.gold - price
end)
