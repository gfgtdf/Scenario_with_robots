-- this is (was) simply LotI's stats.cfg in lua (i don't like those things in wml)
-- i wrote this while playing LotI hoping to make some parts faster, but i changed it to fit my campaign, still it has a lot of stuff i dont't need.
-- this file "exports":
--   new effects "bonus_attack", "improve_bonus_attack", "change_ablitity", "change_special", for objects, advancements and traits. (in use)
--   add teleport anim (not used)
--   damage, icon, merge, damage_type, name, specials on "object" with a weapon type (not used)
--   damage, damage_type, specials on "object" with another or without type. (not used)
--   and the most important thing: a routine that restes the units stats and applies all modificaations again. (in use)
--   maybe  forgot something.
--   the difference between using change_ablitity and removing the old and adding a new ability is that change_ablitity wnont have any effect if the is no ablity.
--   the other differnece is, that change_ablitity allows you to change int values relavively with replace=no

-- adds te following effecttypes: improve_bonus_attack,bonus_attack, change_special, change_ablitity

local all_sorts = swr_constants.all_sorts
local weapon_sorts = swr_constants.weapon_sorts
local armour_sorts = swr_constants.armour_sorts
local melee_weapon_sorts = swr_constants.melee_weapon_sorts
local ranged_weapon_sorts = swr_constants.ranged_weapon_sorts
local non_weaon_sorts = swr_constants.non_weaon_sorts

local sort_of_weapons = swr_constants.sort_of_weapons
local all_terrains = swr_constants.all_terrains
local all_damage_types = swr_constants.all_damage_types
local weapon_bonuses = swr_constants.weapon_bonuses 
local weapon_speacial_abilites = swr_constants.weapon_speacial_abilites
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