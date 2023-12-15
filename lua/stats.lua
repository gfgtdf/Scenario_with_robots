local stats = {}

function stats.replace_modifications(unit, mods)
	-- remove all modifications.
	local hitpoints = unit.hitpoints
	local moves = unit.moves
	unit:remove_modifications({},"advancement")
	for i,v in ipairs(mods) do
		-- reapply modifications
		unit:add_modification(v[1], v[2])
	end
	unit.hitpoints = hitpoints
	unit.moves = moves
end

function stats.refresh_all_stats_xy(x, y)
	local u = wesnoth.units.get(x, y)
	local hitpoints = u.hitpoints
	local moves = u.moves
	-- the following code dopes not work becasue of a bug in the wesnoth engine for image_mods.
	u:transform(u.type)
	u.hitpoints = hitpoints
	u.moves = moves
end

return stats
