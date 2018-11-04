local function find_best_attack(u_cfg, a_range, a_type, a_forced_name, a_new_name)
	local best_attack = nil
	local best_attack_damage = 0
	local name_exists = false
	for attack in helper.child_range(u_cfg, "attack") do
		if(a_new_name == attack.name) then 
			--we already have this attack and we don't want it twice
			name_exists = true
		end
		if a_forced_name then
			if attack.name == a_forced_name then 
				-- can't return because we want to calculate name_exists too.
				best_attack_damage = 100000000
				best_attack = attack
			end
		elseif a_type and a_type ~= attack.type then
			-- do nothing
		elseif a_range and a_range ~= attack.range then
			-- do nothing
		elseif attack.damage * attack.number <= best_attack_damage then
			-- do nothing
		else
			best_attack_damage = attack.damage * attack.number
			best_attack = attack
		end
	end
	return best_attack, name_exists
end



function wesnoth.effects.bonus_attack(u, cfg)
	u_cfg = u.__cfg
	local best_attack, name_exists = find_best_attack(u_cfg, cfg.base_range, cfg.base_type, cfg.base_name, cfg.name)
	if name_exists or best_attack == nil then
		return
	end
	local old_name = best_attack.name
	best_attack.apply_to = "new_attack"
	best_attack.name = cfg.name
	best_attack.description = cfg.description or best_attack.description
	best_attack.icon = cfg.icon or best_attack.icon
	best_attack.type = cfg.type or best_attack.type
	best_attack.range = cfg.range or best_attack.range
	-- mark this attack as a bonus attack.
	best_attack.bonus_attack = true
	-- removed 'improve_bonus_attack' simply use apply_to=attack to change the damage of the attack.
	best_attack.damage = best_attack.damage * (100 + (cfg.damage or 0)) / 100
	best_attack.number = best_attack.number * (100 + (cfg.strikes or 0)) / 100
	best_attack.description = cfg.description or best_attack.description
	best_attack.attack_weight = cfg.attack_weight or best_attack.attack_weight
	best_attack.defense_weight = cfg.defense_weight or best_attack.defense_weight
	if cfg.merge == true  then --seems like "yes" is translated to true but tostring shows "yes" ???
		best_attack.damage = best_attack.damage * best_attack.number
		best_attack.number = 1
	end
	local specials = swr_h.get_or_create_child(best_attack, "specials")
	local additional_specials = helper.get_child(cfg, "specials") or {}
	for special_index, additional_special in pairs(additional_specials) do
		table.insert(specials, additional_special)
	end
	-- Mark this attack as a bonus attack.
	table.insert(specials, T.is_bonus_attack {
		T.filter_self {
			T["not"] {
			}
		},
		id = "derived_from_" .. old_name
	})
	--important: use wesnoth.add_modification(..., false) so that the function will only execute the effects of that object and not store the object in the unit.
	wesnoth.add_modification(u, "object", { T.effect (best_attack) }, false)
end

function wesnoth.effects.alignment(u, cfg)
	u.alignment = cfg.alignment
end

function wesnoth.effects.swr_antenna_bonus(u, cfg)
	local add = tonumber(cfg.add) or 0
	local percent = tonumber(cfg.add_percent) or 0
	u.variables["mods.antenna_add"] = add + (u.variables["mods.antenna_add"] or 0)
	u.variables["mods.antenna_per"] = percent + (u.variables["mods.antenna_per"] or 0)
end

function wesnoth.effects.swr_4p_healing_bonus(u, cfg)
	local add = tonumber(cfg.add) or 0
	u.variables["mods.p4_healing_add"] = add + (u.variables["mods.p4_healing_add"] or 0)
end

function wesnoth.effects.swr_4p_regen_bonus(u, cfg)
	local add = tonumber(cfg.add) or 0
	u.variables["mods.p4_regen_add"] = add + (u.variables["mods.p4_regen_add"] or 0)
end

function wesnoth.effects.swr_charge_bonus(u, cfg)
	local add = tonumber(cfg.add) or 0
	u.variables["mods.swr_charge_add"] = add + (u.variables["mods.swr_charge_add"] or 0)
end

function wesnoth.effects.swr_precision_bonus(u, cfg)
	local add = tonumber(cfg.add) or 0
	u.variables["mods.swr_precison_add"] = add + (u.variables["mods.swr_precison_add"] or 0)
end

function wesnoth.effects.swr_set_variable(u, cfg)
	u.variables[cfg.name] = cfg.value
end


-- TODO: Add change_specialy, change_ability effects.