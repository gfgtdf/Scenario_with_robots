local trader_list_mp = z_require("trader_list_mp")

global_events.add_event_handler("start", function (event_context)
	z_require("version_check").do_initial_version_check()
	wesnoth.wml_actions.set_menu_item {
		description = "Buy components",
		id = "robot_trader_mp",
	}
end)
global_events.add_event_handler("preload", function (event_context)
	z_require("version_check").do_reload_version_check()
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
global_events.add_event_handler("start", function (event_context)
	for k,v in pairs(wesnoth.get_units { type = "Robot_Medium" } ) do
		if v.variables.robot == nil then
			v.variables.robot = "{  [\"open_ends_count\"] = 0,  [\"rings_count\"] = 0,  [\"components\"] = {  [1] = {  [\"component\"] = \"core\",  [\"distance\"] = 0,  [\"pos\"] = {  [\"y\"] = 4,  [\"x\"] = 3, } , } ,  [2] = {  [\"component\"] = \"simplepike\",  [\"distance\"] = 1,  [\"pos\"] = {  [\"y\"] = 4,  [\"x\"] = 2, } , } ,  [3] = {  [\"component\"] = \"pipe_nw\",  [\"distance\"] = 1,  [\"pos\"] = {  [\"y\"] = 4,  [\"x\"] = 4, } , } ,  [4] = {  [\"component\"] = \"pipe_ns\",  [\"distance\"] = 2,  [\"pos\"] = {  [\"y\"] = 3,  [\"x\"] = 4, } , } ,  [5] = {  [\"component\"] = \"propeller\",  [\"distance\"] = 3,  [\"pos\"] = {  [\"y\"] = 2,  [\"x\"] = 4, } , } ,  [6] = {  [\"component\"] = \"simplewheel\",  [\"distance\"] = 1,  [\"pos\"] = {  [\"y\"] = 5,  [\"x\"] = 3, } , } ,  [7] = {  [\"component\"] = \"pipe_sw\",  [\"distance\"] = 1,  [\"pos\"] = {  [\"y\"] = 3,  [\"x\"] = 3, } , } ,  [8] = {  [\"component\"] = \"simplepike\",  [\"distance\"] = 2,  [\"pos\"] = {  [\"y\"] = 3,  [\"x\"] = 2, } , } , } ,  [\"size\"] = {  [\"y\"] = 5,  [\"x\"] = 5, } , }"
		end
		robot_mechanics.reapply_bonuses_at_xy(v.x, v.y)
		stats.refresh_all_stats_xy(v.x, v.y)
		v.moves = v.max_moves
	end
end)
global_events.add_event_handler("recruit", function (event_context)
	local unit = wesnoth.get_unit(event_context.x1, event_context.y1)
	-- without wheels robots are slow as hell, so we give the player a wheel for each recruited unit
	-- why is the "race" property not accessible though the proxy?
	if unit.__cfg.race == "zt_robots" then
		unit.variables.robot = "{  [\"rings_count\"] = 0,  [\"size\"] = {  [\"x\"] = 3,  [\"y\"] = 4, } ,  [\"open_ends_count\"] = 3,  [\"components\"] = {  [1] = {  [\"distance\"] = 0,  [\"component\"] = \"core\",  [\"pos\"] = {  [\"x\"] = 2,  [\"y\"] = 3, } , } ,  [2] = {  [\"distance\"] = 1,  [\"component\"] = \"simplewheel\",  [\"pos\"] = {  [\"x\"] = 2,  [\"y\"] = 4, } , } , } , } "
		robot_mechanics.reapply_bonuses_at_xy(event_context.x1, event_context.y1)
		stats.refresh_all_stats_xy(event_context.x1, event_context.y1)
	end

end)
