-- there musn't be more than one inventory object for each inventory variable otherwise the'd cofuse each other.
-- if inv_set is map string -> number it is a it is a valid wml table, but im used to serialisation and itgives me more flexibility.
local Inventory = {}
Inventory.new = function(inventory_variable)
	-- there self is the only thing cloasured, all the membervariables are part of the self table.
	-- i think thats the better way.
	local self = {}
	self.variable_name = inventory_variable
	self.is_open = false
	-- opens the inventory so it can be written and read
	self.open = function()
		if self.is_open then
			error("Inventory cannot be opened because it is already open")
		else
			local inv_string = wesnoth.get_variable(self.variable_name) or "{}"
			local inv_set = loadstring("return " .. inv_string)()
			self.inv_set = inv_set
			self.is_open = true
		end
	end
	-- closed the inventory to end the transaction.
	self.close = function()
		if not self.is_open then
			error("Inventory cannot be closed because it is not open")
		else
			local inv_string = swr_h.serialize_oneline(self.inv_set)
			wesnoth.set_variable(self.variable_name, inv_string)
			self.inv_set = nil
			self.is_open = false
		end
	end
	-- checks weather the inventory is open and returns self.inv_set
	-- it is not realy a set more a map type -> number in thew inventory
	-- note that operations on the given object write right throug the inventory as long as it is open
	-- it is recomendet touse this as read only and write with "add_amount"
	self.get_invenory_set = function()
		if not self.is_open then
			error("invenory_set is not accessible because te inventory it is not open")
		else
			return self.inv_set
		end
	end
	-- adds "delta" objects of type "key" to the inventory
	self.add_amount = function(key, delta)
		if not self.is_open then
			error("add_amount is not accessible because te inventory it is not open")
		else
			self.inv_set[key] = self.inv_set[key] or 0
			if self.inv_set[key] + delta < 0 then
				error("you cannot add " .. tostring(delta) .. " items if there are only " .. tostring(self.inv_set[key]) .. " items in the inventory")
			elseif key == "core" then
				error("trying o add core")
			else
				self.inv_set[key] = self.inv_set[key] + delta
			end
		end
	end
	-- now in a multiplayer safe version
	self.add_random_items = function(number)
		if not self.is_open then
			error("add_amount is not accessible because te inventory it is not open")
		else
			local inv_deltaa = wesnoth.synchronize_choice(function ()
				local inv_delta = {}
				local c_name = ""
				for i = 1, number do
					c_name = component_list.the_list[math.random(#component_list.the_list - 1) + 1].name
					inv_delta[c_name] = (inv_delta[c_name] or 0) + 1
				end
				return inv_delta
			end,
			function ()
				-- for the ai we do the same.
				-- note that we currently have only one inventory (for one player).
				local inv_delta = {}
				local c_name = ""
				for i = 1, number do
					c_name = component_list.the_list[math.random(#component_list.the_list - 1) + 1].name
					inv_delta[c_name] = (inv_delta[c_name] or 0) + 1
				end
				return inv_delta
			end)
			for k,v in pairs(inv_deltaa) do
				self.add_amount(k,v)
			end
		end
	end
	-- adds number elments to the inventory wich are randomly chosen form th comma_seperated_list "list" (that means s list is a string)
	self.add_random_items_from_comma_seperated_list = function(list, number)
		if not self.is_open then
			error("add_amount is not accessible because te inventory it is not open")
		else
			for i = 1, number do
				self.add_amount(helper.rand(list),1)
			end
		end
	end
	-- closes the inventory and fogetts the changres made.
	self.forfeit_changes = function()
		if not self.is_open then
			error("not self.is_open in forfeit_changes")
		else
			self.inv_set = nil
			self.is_open = false
		end
	end
	return self
end
return Inventory
