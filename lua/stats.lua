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

function stats.calculate_weapons_only(unit_cnf)
	local unit_modifications = swr_h.get_or_create_child(unit_cnf, "modifications")
	
	local weapons_extras = {}
	-- used to add animations.
	local objects_to_add = {}
	for k,v in pairs(weapon_sorts) do 
		weapons_extras[k] = {damage = 100} 
	end
	
	--remove temporary attacks
	swr_h.remove_from_array(unit_cnf, function(e) return (e[1] == "attack" and (e[2].temporary == "yes" or e[2].temporary == true)) end)
	
	-- collect information from advancements.
	for advance in helper.child_range(helper.get_child(unit_cnf, "modifications"), "advancement") do
		for effect in helper.child_range(advance, "effect") do 
			if (effect.set_icon ~= nil and string.find(effect.set_icon, "png",1,true)) then
				for attack in helper.child_range(unit_cnf, "attack") do 
					if attack.name == effect.name then
						attack.icon = effect.set_icon
					end
				end
			end
		end
	end
	--begin to collect information form objects
	for object in helper.child_range(helper.get_child(unit_cnf, "modifications"), "object") do
		--amour bonuses apply on all weapons , weaon bounuses only on that weapon type
		if(weapon_sorts[object.sort] ~= nil) then 
			stats.add_damages(object, weapons_extras[object.sort])
		else 
			stats.add_damages_armour(object,weapons_extras)
		end
		-- user defined object "effect" tags
	end
	-- ]]
	--begin to apply things
	--apply weapons_extras
	for attack in helper.child_range(unit_cnf, "attack") do
		local weapon_sort = sort_of_weapons[attack.name]
		if weapon_sort ~= nil then
			stats.calculate_attack(attack, weapons_extras[weapon_sort])
		end
	end
	
	--add unit halos for illuminates/darkens
	--in LotI it is very rare, but there are units with no abilities at all
	local unit_abilities = helper.get_child(unit_cnf, "abilities") or {}
	for illuminates in helper.child_range(unit_abilities, "illuminates") do
		if(illuminates.value < 0) then
			unit_cnf.halo = "halo/illuminates-aura.png"
		elseif(illuminates.value > 0) then
			unit_cnf.halo = "halo/darkens-aura.png"
		end
	end
	--add unit halos for special leadership
	for dummy in helper.child_range(unit_abilities, "dummy") do
		if(dummy.id == "berserk_leadership") then
			unit_cnf.halo = "misc/berserk-1.png:100,misc/berserk-2.png:100,misc/berserk-3.png:100,misc/berserk-2.png:100"
		elseif(dummy.id == "charge_leadership") then
			unit_cnf.halo = "misc/charge-1.png:100,misc/charge-2.png:100,misc/charge-3.png:100,misc/charge-2.png:100"
		elseif(dummy.id == "poison_leadership") then
			unit_cnf.halo = "misc/poison-1.png:100,misc/poison-2.png:100,misc/poison-3.png:100,misc/poison-2.png:100"
		elseif(dummy.id == "firststrike_leadership") then
			unit_cnf.halo = "misc/firststrike-1.png:100,misc/firststrike-2.png:100,misc/firststrike-3.png:100"
		elseif(dummy.id == "backstab_leadership") then
			unit_cnf.halo = "misc/backstab-1.png:100,misc/backstab-2.png:100,misc/backstab-3.png:100,misc/backstab-2.png:100"
		elseif(dummy.id == "marksman_leadership") then
			unit_cnf.halo = "misc/marksman-1.png:100,misc/marksman-2.png:100,misc/marksman-3.png:100,misc/marksman-2.png:100"
		elseif(dummy.id == "drain_leadership") then
			unit_cnf.halo = "misc/drain-1.png:100,misc/drain-2.png:100,misc/drain-3.png:100,misc/drain-2.png:100"
		end
	end
	-- TODO: a "change_ability" would be nice.
	--bonus attacks
	-- i want change_ablitity to takew effect before bonus_attack.
	for modification in swr_h.child_range_multiple_tags(unit_modifications, Set{"advancement", "object", "trait"}) do
		for effect in helper.child_range(modification, "effect") do
			-- a new tag that allows changes of abilies
			-- since we change something we might have to deepcopy somthing here.
			if(effect.apply_to == "change_ablitity" and effect.id ~= nil) then
				for k1,v1 in pairs(unit_abilities) do
					if v1[2].id == effect.id then
						for k, v in pairs(effect) do
							if (k ~= "apply_to") and (k ~= "id") and (k ~= "replace")then
								if effect.replace == false and type(v) == "number" then
									v1[2][k] = v1[2][k] + v
								elseif effect.replace == "multiply" and type(v) == "number" then
									v1[2][k] = v1[2][k] * v
								else
									v1[2][k] =  v
								end
							end
						end
					end
				end
			end
			-- a new tag that allows changes of abilies of weapons
			if(effect.apply_to == "change_special" and effect.attack_name ~= nil and effect.id ~= nil) then
				-- for each special in each atttack
				for attack in helper.child_range(unit_cnf, "attack") do
					if attack.name == effect.attack_name then
						local attack_specials = helper.get_child(attack, "specials") 
						for k1, v1 in pairs(attack_specials) do
							if v1[2].id == effect.id then
								-- aply the changes
								-- wich means we cange each value of that special
								for k, v in pairs(effect) do
									if (k ~= "apply_to") and (k ~= "attack_name") and (k ~= "id") and (k ~= "replace")then
										if effect.replace == false and type(v) == "number" then
											v1[2][k] = v1[2][k] + v
										elseif effect.replace == "multiply" and type(v) == "number" then
											v1[2][k] = v1[2][k] * v
										else
											v1[2][k] =  v
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	-- TODO: 1.13.2 use wesnoth effect for bonus_attack
	for advance in swr_h.child_range_multiple_tags(unit_modifications, Set{"advancement", "object", "trait"}) do
		for effect in helper.child_range(advance, "effect") do
			if(effect.apply_to == "bonus_attack") then
				local stongest_attack -- note that unline in the wml code this is NOT the index of the attack
				local stongest_attack_v = 0
				local has_this_attack = false
				local new_attack
				--we search the strongest attack
				for attack in helper.child_range(unit_cnf, "attack") do
					if(attack.name == effect.force_original_attack) then 
						stongest_attack_v = 100000000
						stongest_attack = attack
					elseif(attack.range == effect.range and attack.damage * attack.number > stongest_attack_v and attack.temporary ~= "yes" and attack.temporary ~= true) then
						stongest_attack_v = attack.damage * attack.number
						stongest_attack = attack
					end
					if(effect.name == attack.name) then 
						--we already have this attack and we don't want it twice
						has_this_attack = true
					end
				end
				if (has_this_attack ~= true) then
					if stongest_attack then
						-- we need to deepcopy it because otherwise the original attack would be changed too.
						new_attack = swr_h.deepcopy(stongest_attack)
					else
						new_attack = {
							range = effect.range,
							damage = 1,
							number = 1,
							type = blade,
							description = _"Blade",
							icon = "attacks/sword-steel.png"
						}
					end
					table.insert(unit_cnf, {"attack",new_attack})
				end
				new_attack.name = effect.name
				if (effect.description ~= nil) then
					new_attack.description = effect.description
				end
				if (effect.icon ~= nil) then
					new_attack.icon = effect.icon
				end
				new_attack.temporary = "yes"
				if (effect.type ~= nil) then 
					new_attack.type = effect.type 
				end
				local damage = 0
				local attacks = 0
				if (effect.damage ~= nil) then 
					damage = effect.damage 
				end
				if (effect.number ~= nil) then 
				
					attacks = effect.number 
				end
				for other_advance in swr_h.child_range_multiple_tags(unit_modifications, Set {"advancement", "object", "trait"}) do
					for other_effect in helper.child_range(other_advance, "effect") do
						if other_effect.apply_to == "improve_bonus_attack" and other_effect.name == effect.name  then 
							damage = damage + (other_effect.increase_damage or 0)
							attacks = attacks + (other_effect.increase_attacks or 0)
						end
					end
				end
				new_attack.damage =  new_attack.damage * (100 + damage) / 100
				new_attack.number =  new_attack.number * (100 + attacks) / 100
				new_attack.attack_weight = effect.attack_weight or new_attack.attack_weight
				new_attack.defense_weight = effect.defense_weight or new_attack.defense_weight
				if effect.merge == true then
					new_attack.damage = new_attack.damage * new_attack.number
					new_attack.number = 1
				end
				local new_attack_specials = swr_h.get_or_create_child(new_attack, "specials")
				local effect_specials = helper.get_child(effect, "specials") or {}
				for special_index,special in pairs(effect_specials)do
					-- deepcopy??
					table.insert(new_attack_specials,special)
				end
			end
		end
	end
	
	for index, object in ipairs(objects_to_add) do
		table.insert(unit_modifications, T.object( object ))
	end
end

function stats.calculate_attack(attack, weapons_extras_t)
	local specials = swr_h.get_or_create_child(attack, "specials")
	weapons_extras_t.specials = weapons_extras_t.specials or {}
	
	attack.damage = (attack.damage * weapons_extras_t.damage / 100)
	if(weapons_extras_t.icon ~= nil and string.find(weapons_extras_t.icon,"png",1,true)) then
		attack.icon = weapons_extras_t.icon
	end
	if(weapons_extras_t.merge == "yes" or weapons_extras_t.merge == true) then
		attack.damage = attack.damage * attack.number
		attack.number = 1
	end
	if (weapons_extras_t.name ~= nil) then
		attack.description = weapons_extras_t.name
	end
	for k,v in pairs(weapons_extras_t.specials) do
		table.insert(specials, swr_h.deepcopy(v))
	end
	local specials_2 = swr_h.get_or_create_child(attack, "specials")
end

function stats.add_damages(object, wep_extra_aggregator)
	wep_extra_aggregator.damage = wep_extra_aggregator.damage + (object.damage or 0) 
	wep_extra_aggregator.icon = (wep_extra_aggregator.icon or object.icon)
	wep_extra_aggregator.merge = (wep_extra_aggregator.merge or object.merge) 
	wep_extra_aggregator.name = object.name or wep_extra_aggregator.name 
	wep_extra_aggregator.specials = (wep_extra_aggregator.specials or {})
	
	object_specials = helper.get_child(object, "specials") or {}
	for k,v in pairs(object_specials) do
		if(type(k) ~= type(1)) then
			error("", 0)
		else
			--since we dont change it we dont need to deepcopy it specials
			table.insert(wep_extra_aggregator.specials, v)
		end
	end
end

--this function is  part of calculate_weapons_only on the original
function stats.add_damages_armour(object, weapons_extras)
	--put this outside the loop because we done want to call it more often than nececary
	specials = helper.get_child(object, "specials") or {}
	specials_melee = helper.get_child(object, "specials_melee") or {}
	specials_ranged = helper.get_child(object, "specials_ranged") or {}
	--apply effects for all weapons
	for k,v in pairs(weapon_sorts) do
		weapons_extras[k].damage = weapons_extras[k].damage  + (object.damage or 0)
		weapons_extras[k].specials = (weapons_extras[k].specials or {})
		for k_1,v in pairs(specials) do
			if(type(k_1) ~= type(1)) then
				error("", 0)
			else
				--since we dont change it we dont need to deepcopy it, you alway have to ask yourself that question if you use table.insert
				table.insert(weapons_extras[k].specials, v)
			end
		end
	end
	--apply effect for melee weapons
	for k,v in pairs(melee_weapon_sorts) do
		weapons_extras[k].damage = weapons_extras[k].damage
		for k_1,v in pairs(specials_melee) do
			if(type(k_1) ~= type(1)) then
				error("", 0)
			else
				--since we dont change it we dont need to deepcopy it
				table.insert(weapons_extras[k].specials, v)
			end
		end
	end
	--apply effects for ranges weapons
	for k,v in pairs(ranged_weapon_sorts) do
		weapons_extras[k].damage = weapons_extras[k].damage
		for k_1,v in pairs(specials_ranged) do
			if(type(k_1) ~= type(1)) then
				error("", 0)
			else
				--since we dont change it we dont need to deepcopy it
				table.insert(weapons_extras[k].specials, v)
			end
		end
	end
end

function stats.backup_unit_stats(unit_cnf, heal, status_heal)
	
	heal = status_heal or heal
	unit_cnf.hitpoints = heal and unit_cnf.max_hitpoints or unit_cnf.hitpoints
	unit_cnf.moves = status_heal and unit_cnf.max_moves or unit_cnf.moves
	unit_cnf.attacks_left = status_heal and unit_cnf.max_attacks or unit_cnf.attacks_left
	local unit_status = helper.get_child(unit_cnf, "status")
	local unit_modifications  = helper.get_child(unit_cnf, "modifications")
	local unit_abilities = helper.get_child(unit_cnf, "abilities")
	local unit_variables = helper.get_child(unit_cnf, "variables")
	if(status_heal) then
		for k,v in pairs(unit_status) do unit_status[k] = nil end
	end
	local unit_wml = {
		side=unit_cnf.side,
		x=unit_cnf.x,
		y=unit_cnf.y,
		experience=unit_cnf.experience,
		canrecruit=unit_cnf.canrecruit,
		variation=unit_cnf.variation,
		type=unit_cnf.type,
		id=unit_cnf.id,
		moves=unit_cnf.moves,
		hitpoints=unit_cnf.hitpoints,
		gender=unit_cnf.gender,
		name=unit_cnf.name,
		facing=unit_cnf.facing,
		extra_recruit=unit_cnf.extra_recruit,
		underlying_id=unit_cnf.underlying_id,
		unrenamable=unit_cnf.unrenamable,
		overlays=unit_cnf.overlays,
		T.status (unit_status),
		T.modifications (unit_modifications),
		T.variables (unit_variables),
	}
	
	local unit_cnf_new = wesnoth.create_unit(unit_wml).__cfg
	unit_cnf_new.moves = unit_cnf.moves
	unit_cnf_new.attacks_left = unit_cnf.attacks_left
	
	return unit_cnf_new
end

function stats.calculations_end(unit_cnf)
	wesnoth.put_unit(unit_cnf)
end

function stats.refresh_all_stats_xy(x, y)
	if true then
		local u = wesnoth.get_unit(x, y)
		u:transform(u.type)
		return
	end
	-- This function was originally coded to substitude LotI's stats.cfg becasue LotI's code seemed to be slow.
	-- I tested the performance of this code on an efraim unit with 80 advamcents:
	--   the wesnoth.create_unit and the wesnoth.put_unit in backup_unit_stats and calculations_end take by far
	--   the most time > 60 milliseconds each. while calculate_weapons_only which contains teh most lua code only
	--   takes 13 milliseconds. A possible attempt to fix this would be to change calculate_weapons_only and 
	--   calculations_end to use direct unit manipulation or effectwml instead of recreating the unit.
	
	-- TODO 1.13.2: Try to implement custom [effect]s using wesnoth.effects
	local unit_cnf = wesnoth.get_unit(x, y).__cfg
	wesnoth.put_unit(x, y)
	local unit_cnf2 = stats.backup_unit_stats(unit_cnf, false, false)
	stats.calculate_weapons_only(unit_cnf2)
	stats.calculations_end(unit_cnf2)
end
return stats