local on_event = wesnoth.require("on_event")

local trader_list_mp = swr_require("trader_list_mp")

on_event("start", function (event_context)
	swr_require("version_check").do_initial_version_check()
	wesnoth.wml_actions.set_menu_item {
		description = "Buy components",
		id = "robot_trader_mp",
	}
end)

on_event("preload", function (event_context)
	swr_require("version_check").do_reload_version_check()
end)

on_event("menu_item robot_trader_mp", function (event_context)
	global_events.disallow_undo()
	local side = wesnoth.sides[wesnoth.current.side] 
	local bought_items, price = swr_trader.buy_items(trader_list_mp, side.gold)
	local inv = inventories[wesnoth.current.side]
	inv:open()
	for k, v in pairs(bought_items) do
		for i = 1, v do
			trader_list_mp[k].apply_func(inv)
		end
	end
	inv:close()
	side.gold = side.gold - price
end)

on_event("start", function (event_context)
	for k,v in pairs(wesnoth.get_units { type = "Robot_Medium" } ) do
		if v.variables.robot == nil then
			v.variables.robot = "{  [\"open_ends_count\"] = 0,  [\"rings_count\"] = 0,  [\"components\"] = {  [1] = {  [\"component\"] = \"core\",  [\"distance\"] = 0,  [\"pos\"] = {  [\"y\"] = 4,  [\"x\"] = 3, } , } ,  [2] = {  [\"component\"] = \"simplepike\",  [\"distance\"] = 1,  [\"pos\"] = {  [\"y\"] = 4,  [\"x\"] = 2, } , } ,  [3] = {  [\"component\"] = \"pipe_nw\",  [\"distance\"] = 1,  [\"pos\"] = {  [\"y\"] = 4,  [\"x\"] = 4, } , } ,  [4] = {  [\"component\"] = \"pipe_ns\",  [\"distance\"] = 2,  [\"pos\"] = {  [\"y\"] = 3,  [\"x\"] = 4, } , } ,  [5] = {  [\"component\"] = \"propeller\",  [\"distance\"] = 3,  [\"pos\"] = {  [\"y\"] = 2,  [\"x\"] = 4, } , } ,  [6] = {  [\"component\"] = \"simplewheel\",  [\"distance\"] = 1,  [\"pos\"] = {  [\"y\"] = 5,  [\"x\"] = 3, } , } ,  [7] = {  [\"component\"] = \"pipe_sw\",  [\"distance\"] = 1,  [\"pos\"] = {  [\"y\"] = 3,  [\"x\"] = 3, } , } ,  [8] = {  [\"component\"] = \"simplepike\",  [\"distance\"] = 2,  [\"pos\"] = {  [\"y\"] = 3,  [\"x\"] = 2, } , } , } ,  [\"size\"] = {  [\"y\"] = 5,  [\"x\"] = 5, } , }"
		end
		wesnoth.wml_actions.swr_update_unit { x = v.x, y = v.y }
		v.moves = v.max_moves
	end
end)

on_event("recruit", function (event_context)
	global_events.disallow_undo()
	local unit = wesnoth.units.get(event_context.x1, event_context.y1)
	if unit.race == "zt_robots" then
		unit.variables.robot = "{  [\"rings_count\"] = 0,  [\"size\"] = {  [\"x\"] = 3,  [\"y\"] = 4, } ,  [\"open_ends_count\"] = 3,  [\"components\"] = {  [1] = {  [\"distance\"] = 0,  [\"component\"] = \"core\",  [\"pos\"] = {  [\"x\"] = 2,  [\"y\"] = 3, } , } ,  [2] = {  [\"distance\"] = 1,  [\"component\"] = \"simplewheel\",  [\"pos\"] = {  [\"x\"] = 2,  [\"y\"] = 4, } , } , } , } "
		wesnoth.wml_actions.swr_update_unit { x = event_context.x1, y = event_context.y1 }
	end

end)
