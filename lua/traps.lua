local Traps = {}
local traptypes = {}
Traps.new = function(storage_variable)
	local self = {}
	-- each entry contains the following keys: x, y, sender_side, sender_unit_id, type, power
	self.traplist = {}
	self.storage_variable = storage_variable
	self.init = function ()
		global_events.add_event_handler("enter_hex", self.on_hex_enter)
		global_events.add_event_handler("prestart", self.on_prestart)
		global_events.add_event_handler("moveto", self.on_move_to)
		global_events.create_disallow_undo_workaround("enter_hex")
		global_events.create_disallow_undo_workaround("moveto")
		global_events.register_on_save_writer("traps", self.save_traps)
		global_events.register_on_load_reader("traps", self.load_traps)
	end
	self.load_traps = function (cfg)
		self.traplist = swr_h.deseralize(cfg.value)
	end
	self.save_traps = function (cfg)
		return {value = swr_h.serialize_oneline( self.traplist ) }
	end
	self.on_prestart = function ()
	end
	-- lua traps.set_trap({ x = 25, y = 18, power = 1, type = "poison_spikes" }, 1)
	self.set_trap = function(trap, max_times)
		local firstfound = false
		local firstfound_loc = nil
		local firstfound_count = 0
		local count = 0
		
		for k, v in pairs(self.traplist) do
			if v.sender_unit_id == trap.sender_unit_id then
				count = count + 1
				firstfound = firstfound or k
				firstfound_loc = firstfound_loc or {x = v.x, y = v.y}
			end
		end
		if count >= max_times then
			table.remove(self.traplist,firstfound)
			for k, v in pairs(self.traplist) do
				if v.x == (firstfound_loc or {}).x and   v.y == (firstfound_loc or {}).y then
					firstfound_count = firstfound_count + 1
				end
			end
			if firstfound_count == 0 then
				wesnoth.wml_actions["remove_item"]({x = firstfound_loc.x, y = firstfound_loc.y, image = "misc/red_border.png"})
			end
		end
		table.insert(self.traplist, trap)
		wesnoth.wml_actions["item"]({x = trap.x, y = trap.y, image = "misc/red_border.png", visible_in_fog = false})
	end
	self.on_hex_enter = function(event_context)

		last_on_exit_hex = global_events.last_on_exit_hex
		local unit_wml = wesnoth.get_variable("unit")
		local remove_traps = {}
		-- i dont want to event to fire if there is another unit on that hex.
		if last_on_exit_hex.x2 == event_context.x1 and last_on_exit_hex.y2 == event_context.y1 then
			for k, trap in pairs(self.traplist) do
				-- i caould also check weather the units are allied here
				if trap.x == last_on_exit_hex.x2 and trap.y == last_on_exit_hex.y2 then
					local unit_ref = wesnoth.get_unit(trap.x,trap.y)
					self.execute_trap(trap, trap.x, trap.y, unit_ref)
					if traptypes[trap.type].permanent ~= true then
						table.insert(remove_traps, k)
					end
					global_events.disallow_undo_flag = true
					-- allowing units to move on if i want would be cool, but forcing htem to move on would be unfair i think
					-- TODO: "undo" is still allowed after this, fix this
				end
			end
			while #remove_traps > 0 do
				table.remove(self.traplist, remove_traps[#remove_traps])
				table.remove(remove_traps, #remove_traps)
			end
		end		
	end
	self.on_prestart = function()
	
	end
	self.execute_trap = function(trap, x, y, taget_ref)
		local traptype = traptypes[trap.type]
		local anim = {}
		if traptype.animation == "spikes" then
			anim = {
				T.item { x = x, y = y, halo="animation/spikes.png" },
				T.delay { time = 50 },
				T.item { x = x, y = y, halo="animation/spikes2.png" },
				T.delay { time = 100 },
				T.item { x = x, y = y, halo="animation/spikes3.png" },
				T.delay { time = 50 },
				T.remove_item { x= x, y = y, image = "animation/spikes3.png" },
				T.item { x = x, y = y, halo="animation/spikes2.png" },
				T.delay { time = 50 },
				T.remove_item { x= x, y = y, image = "animation/spikes2.png" },
				T.item { x = x, y = y, halo="animation/spikes.png" },
				T.delay { time = 50 },
				T.remove_item { x= x, y = y, image = "animation/spikes.png" } }
		elseif traptype.animation == "explosion" then
			-- TODO place the animation for the explosion trap here.
			anim = {
				T.item { x = x, y = y, halo="animation/spikes.png" },
				T.delay { time = 50 },
				T.item { x = x, y = y, halo="animation/spikes2.png" },
				T.delay { time = 100 },
				T.item { x = x, y = y, halo="animation/spikes3.png" },
				T.delay { time = 50 },
				T.item { x = x, y = y, halo="animation/spikes2.png" },
				T.delay { time = 50 },
				T.item { x = x, y = y, halo="animation/spikes.png" },
				T.delay { time = 50 },
				T.remove_item { x= x, y = y} }
		end
		for k,v in pairs(anim) do 
			wesnoth.wml_actions[v[1]](v[2])
		end
		local resist = wesnoth.unit_resistance(taget_ref, traptype.damagetype or "pierce")
		wesnoth.wml_actions.harm_unit( wesnoth.tovconfig {
			T.filter { x = x, y = y},
			amount = traptype.amount * trap.power,
			resistance_multiplier = resist / 100,
			animate = false,
			kill = false,
			poisoned = traptype.poisoned,
			slowed = traptype.slowed,
			})
		local trapcount = 0
		for k, other_trap in pairs(self.traplist) do
			if trap.x == other_trap.x and trap.y == other_trap.y then 
				trapcount = trapcount + 1 
			end
		end 
		if trapcount == 1 then
			wesnoth.wml_actions["remove_item"]({x = trap.x, y = trap.y, image = "misc/red_border.png"})
		end
	end
	self.on_move_to = function(event_context)
		unit = wesnoth.get_unit(event_context.x1,event_context.y1)
		if wesnoth.unit_ability(unit, "ab_trapper") then
			unit_cfg = unit.__cfg
			local unit_abilities = swr_h.get_or_create_child(unit_cfg, "abilities")
			for ab_trapper in helper.child_range(unit_abilities, "ab_trapper") do
				self.set_trap({
					x = event_context.x1, 
					y = event_context.y1, 
					power = ab_trapper.damage, 
					type = ab_trapper.traptype,
					sender_side = unit.side, 
					sender_unit_id = unit.id
					}, ab_trapper.maxtraps) 
				global_events.disallow_undo_flag = true
				break
			end
		end
	end
	return self
	
	
end
traptypes["spikes"] = 
{
	animation = "spikes",
	amount = 10,
	damagetype = "pierce",
}
traptypes["poison_spikes"] = 
{
	animation = "spikes",
	amount = 10,
	damagetype = "pierce",
	poisoned = true
}

return Traps