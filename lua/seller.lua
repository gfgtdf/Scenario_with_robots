
local Seller = {}
Seller.__index = Seller

function Seller:create()
	local res = {}
	setmetatable(res, self)
	res.gui = swr_require("dialogs/seller")
	res.dialog_wml = res.gui.normal
	res.dialog = nil
	res.items = {}
	res.total_price = 0
	res.items_bought = {}
	res.max_gold = nil
	return res
end

function Seller:show_dialog()
	local order_item = function()
		if ((self.items[self.selected_row].quantity or 9999) > (self.items_bought[self.selected_row] or 0)) then
			self.items_bought[self.selected_row] = (self.items_bought[self.selected_row] or 0) + 1
			--self.update_all_basket_rows()
			self:update_buy_button()
			self:update_all_rows()
		end
	end
	local remove_item = function()
		if ( (self.items_bought[self.selected_row] or 0) > 0) then
			self.items_bought[self.selected_row] = self.items_bought[self.selected_row]  - 1
			--self.update_all_basket_rows()
			self:update_buy_button()
			self:update_all_rows()
		end
	end
	local function select_from_trader_list()
		local i = self.dialog:find("trader_list").selected_index
		if i > self.page_count or self.page_count == 0 then
			error("invalid trader_list row number")
		end

		self.selected_row = i
		self.dialog:find("details_pages").selected_index = i
	end
	local function preshow(dialog)
		self.dialog = dialog
		self.selected_row = 1

		self.dialog:find("trader_list").callback = select_from_trader_list
		self.dialog:find("order_button").callback = order_item
		self.dialog:find("remove_button").callback = remove_item
		self.dialog:find("total_price_label").use_markup = true
		

		self:update_all_rows()
		self:update_buy_button(true)
		self.dialog:find("trader_list").selected_index = 1

		select_from_trader_list()
	end
	local r_val = gui.show_dialog(self.dialog_wml, preshow)

	self.dialog = nil
	if r_val == self.gui.buttons.abort then
		return {}
	else
		return self.items_bought
	end
end

function Seller:set_item_list(item_list)
	self.items = item_list
end

function Seller:set_max_gold(max_gold)
	self.max_gold = max_gold
end

function Seller:update_all_rows()
	for i, item in ipairs(self.items) do
		local image = item.image
		if true then
			image = image .. "~SCALE(72,72)"
		end
		if item.quantity ~= nil and ((self.items_bought[i] or 0) >= item.quantity) then
			image = image .. "~BLIT(misc/cross1.png,0,0)"
		end

		local list_item = self.dialog:find("trader_list", i)
		local details_page = self.dialog:find("details_pages", i)

		list_item.list_image.label = image
			
		local quantity = item.quantity == nil and "" or (item.quantity - (self.items_bought[i] or 0))
		local price_string = string.format("Price: %sg", tostring(item.price))
		local basket_string = string.format("in the basket: %d", self.items_bought[i] or 0)
		if (self.items_bought[i] or 0) < 10 then
			basket_string = basket_string .. "    "
		end
		local quant_string = item.quantity == nil and "         " or string.format("available: %s", item.quantity)

		list_item.list_name.label = item.name
		list_item.list_quantity.label = item.quantity or "       "
		list_item.list_basket.label = self.items_bought[i] or "      "
		list_item.list_price.label = tostring(item.price) .. "g"


		details_page.details_name.label = item.name
		details_page.details_description.label = item.description
		details_page.details_quantity.label = quant_string
		details_page.details_basket_count.label = basket_string
		details_page.details_price.label = price_string

		self.page_count = i
	end
	self.dialog:find("details_pages", self.page_count + 1, "details_description").label = "\n1\n2\n3\n4\n5"
end


function Seller:update_all_basket_rows()
	local old_page_count = self.basket_page_count
	local i = 1
	for k, item_b_number in pairs(self.items_bought) do

		wesnoth.set_dialog_value(self.items[k].image, "basket_list", i, "list_b_image")
		wesnoth.set_dialog_value(item_b_number, "basket_list", i, "list_b_number")
		self.basket_page_count = i
		i = i + 1
	end
end

function Seller:update_buy_button(initial)
	local t_price = 0
	for k, item_b_number in pairs(self.items_bought) do
		t_price = t_price + self.items[k].price * item_b_number
	end
	local text = string.format("Total: %dg", t_price)
	if self.max_gold and self.max_gold < t_price then
		text = "<span foreground='red'>" .. text .. "</span>"
		self.dialog:find("use_button").enabled = false
	else
		self.dialog:find("use_button").enabled = true
	end
	if initial then
		-- Add some invisible text to give it more space during layout phase.
		text = text .. "       "
	end
	self.dialog:find("total_price_label").label = text
end

return Seller

