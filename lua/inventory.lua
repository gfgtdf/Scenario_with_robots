-- there musn't be more than one inventory object for each inventory variable otherwise the'd cofuse each other.
-- if inv_set is map string -> number it is a it is a valid wml table, but im used to serialisation and itgives me more flexibility.
local Inventory = {}

function Inventory:create(variable_name, side_num)
	local res = {}
	res.side_num = side_num
	res.variable_name = variable_name
	res.is_open = false
	setmetatable(res, self)
	self.__index = self
	return res
end

-- opens the inventory so it can be written and read
function Inventory:open()
	if self.is_open then
		error("Inventory cannot be opened because it is already open")
	else
		local inv_string = nil
		if self.side_number then
			inv_string = wesnoth.get_side_variable(self.side_number, self.variable_name)
		else
			inv_string = wesnoth.get_variable(self.variable_name)
		end
		self.inv_set = swr_h.deserialize(inv_string or "{}")
		self.is_open = true
	end
end

-- closed the inventory to end the transaction.
function Inventory:close()
	if not self.is_open then
		error("Inventory cannot be closed because it is not open")
	else
		local inv_string = swr_h.serialize_oneline(self.inv_set)
		if self.side_number then
			wesnoth.set_side_variable(self.side_number, self.variable_name, inv_string)
		else
			wml.variables[self.variable_name] = inv_string
		end
		self.inv_set = nil
		self.is_open = false
	end
end

-- checks weather the inventory is open and returns self.inv_set
-- it is not realy a set more a map type -> number in thew inventory
-- note that operations on the given object write right throug the inventory as long as it is open
-- it is recomendet touse this as read only and write with "add_amount"
function Inventory:get_invenory_set()
	if not self.is_open then
		error("invenory_set is not accessible because te inventory it is not open")
	else
		return self.inv_set
	end
end


-- adds "delta" objects of type "key" to the inventory
function Inventory:add_amount(key, delta)
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

function Inventory:add_random_items(number)
	if not self.is_open then
		error("add_amount is not accessible because te inventory it is not open")
	else
		local inv_deltaa = wesnoth.sync.evaluate_single(function ()
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
			self:add_amount(k,v)
		end
	end
end

-- adds number elments to the inventory wich are randomly chosen form th comma_seperated_list "list" (that means s list is a string)
function Inventory:add_random_items_from_comma_seperated_list(list, number)
	if not self.is_open then
		error("add_amount is not accessible because te inventory it is not open")
	else
		for i = 1, number do
			self:add_amount(mathx.random_choice(list),1)
		end
	end
end

-- closes the inventory and fogetts the changres made.
function Inventory:forfeit_changes ()
	if not self.is_open then
		error("not self.is_open in forfeit_changes")
	else
		self.inv_set = nil
		self.is_open = false
	end
end

return Inventory
