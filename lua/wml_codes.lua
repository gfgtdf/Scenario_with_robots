-- this files gives routines to create cutom wml tables, manly used by component_list.lua and robot_mechanics.lua

local wml_codes = {}
wml_codes.get_attack_spear_code = function(attack_number, attack_damage)
	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "new_attack",
		damage = attack_damage,
		number = attack_number,
		description= _ "spear",
		icon = "attacks/spear.png",
		name = "spear",
		range = "melee",
		type = "pierce"
	})
	-- TODO: add animations.
	-- EDIT the "animation" are in teh units cfg files.
	return effects
end
wml_codes.get_attack_laser_code = function(attack_number, attack_damage)
	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "new_attack",
		damage = attack_damage,
		number = attack_number,
		description= _ "laser",
		icon = "attacks/concussionbeam.png",
		name = "laser",
		range = "ranged",
		type = "arcane"
	})
	--TODO: add animations.
	return effects
end
wml_codes.get_attack_propellerstorm_code = function(attack_number, attack_damage)
	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "new_attack",
		damage = attack_damage,
		number = attack_number,
		description= _ "propellerstorm",
		icon = "attacks/blizzard.png",
		name = "propellerstorm",
		range = "ranged",
		type = "cold"
	})
	--TODO: add animations.
	return effects
end
wml_codes.get_attack_bigbow_code = function(attack_number, attack_damage)
	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "new_attack",
		damage = attack_damage,
		number = attack_number,
		description= _ "Big Bow",
		icon = "attacks/bow.png",
		name = "bigbow",
		range = "ranged",
		type = "pierce",
		T.specials {
			T.chance_to_hit {
				cumulative = true,
				description = _ "This attack always has at least a 80% chance to hit.",
				id = "focused",
				name = _ "focused",
				value = 80
			}
		}
	})
	-- to ad something the makes this useful, for axample a distant attack
	--TODO: add animations.
	return effects
end
wml_codes.get_ad_movement_code = function(movement_increase)
	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "movement",
		increase = movement_increase
	})
	return effects
end
wml_codes.get_ad_movement_costs_code = function(movement_costs)
	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "movement_costs",
		replace = true,
		T.movement_costs(movement_costs)
	})
	return effects
end
wml_codes.get_ad_resistances_code = function(res_arcane, res_cold, res_fire, res_blade , res_pierce, res_impact)
 	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "resistance",
		replace = false,
		T.resistance {
			arcane = res_arcane, 
			cold = res_cold, 
			fire = res_fire, 
			blade = res_blade, 
			pierce = res_pierce, 
			impact = res_impact
		}
	})
	return effects
end
wml_codes.get_healing_ability_code = function(strength)
 	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "new_ability",
		T.abilities { 
			T.heals {
				affect_allies = true,
				affect_self = false,
				description = _ ("heals " .. tostring(strength) .. " hp per turn or removes poison"),
				female_name = _ ("female^heals +" .. tostring(strength)),
				id = "robot_heals_with_4parts",
				name = _ ("heals +" .. tostring(strength)),
				poison = "cured",
				value = strength,
				T.affect_adjacent { adjacent = "n,ne,se,s,sw,nw" }
			}
		}
	})
	return effects
end
wml_codes.get_regenerate_ability_code = function(strength)
 	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "new_ability",
		T.abilities {
			T.regenerate {
				affect_self = true,
				description = _ ("The unit will heal itself " .. tostring(strength) .. " HP per turn. If it is poisoned, these two effects will negate themselves."),
				female_name = _ "female^regenerates slightly",
				id = "robot_regenerate_with_4parts",
				name = _ ("regenerates (" .. tostring(strength) .. ")"),
				poison = "slowed",
				value = strength
			}
		}
	})
	return effects
end
-- originaly i wanted to change the attack type, but since the bonuis_attack effects was already coded i choose this one.
-- later i noiced that i could just have used "aplyto=attack", set_type=...
wml_codes.get_change_attack_type_code = function(attack_name, attack_type, number_change, damage_change)
	local effects = {}
	table.insert(effects, T.effect { 
		apply_to = "bonus_attack",
		attacks = number_change,
		damage = damage_change,
		clone_anim = true,
		type = attack_type,
		--description = _"fury",
		force_original_attack = attack_name,
		name = attack_name .. "_with_type_" .. attack_type
	})
	return effects
end
wml_codes.get_imp_advancement = function(name)
	return { T.advance { id = "robot_imp_" .. name } }
end
wml_codes.get_robot_object = function(effects)
	local obj_wml = { }
	for k,v in pairs(effects) do
		table.insert(obj_wml, v)
	end
	obj_wml.name = "robot_improvements"
	-- this MUST be "advance" instead of "object" because advance is always applied before object, and we want the advancement to overwrite this, 
	-- if this was an object this would overwrite our advaements
	return T.advance(obj_wml)
end
wml_codes.get_trapper_ability_code = function(damage, traptype, maxtraps)
	local effects = {}
	table.insert(effects, T.effect {
		apply_to = "new_ability",
		T.abilities {
			T.ab_trapper{
				id = "ab_trapper",
				name = _ "Trapper",
				description = _ "This units sets a trap at the end of every move, dependent of the type of traps, they can poison, slow, or just deal damage",
				damage = damage,
				traptype = traptype,
				maxtraps = maxtraps,
				
			}
		}
	})
	return effects
end
wml_codes.get_change_trapper_type_code = function(traptype) 
	local effects = {}
	table.insert(effects, T.effect {
		apply_to = "change_ablitity",
		id = "ab_trapper",
		traptype = traptype,
	})
	return effects
end

wml_codes.get_antenna_leadership_code = function(percent)
	local effects = {}
	table.insert(effects, T.effect {
		apply_to = "new_ability",
		T.abilities {
			T.leadership {
				id = "antenna_leadership",
				name = _ "Antanna",
				description = _ "Adjacent robots deal " .. percent .. "% more damage",
				value = percent,
				affect_self = false,
				affect_allies = true,
				cumulative = true,
				T.affect_adjacent {
					adjacent = "n,ne,se,s,sw,nw",
					T.filter {
						race = "zt_robots",
					},
				},
			},
		}
	})
	return effects
end

return wml_codes
