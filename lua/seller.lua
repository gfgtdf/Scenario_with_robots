
local Seller = {}
Seller.__index = Seller

function Seller:create()
	local res = {}
	setmetatable(res, self)
	res.gui = swr_require("dialogs/seller")
	res.dialog = res.gui.normal
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
		local i = wesnoth.get_dialog_value("trader_list")
			if i > self.page_count or self.page_count == 0 then
			error("invalid trader_list row number")
		end

		self.selected_row = i
		wesnoth.set_dialog_value(i, "details_pages")
	end
	local function preshow()
		wesnoth.set_dialog_callback(select_from_trader_list, "trader_list")
		wesnoth.set_dialog_callback(order_item, "order_button")
		wesnoth.set_dialog_callback(remove_item, "remove_button")
		wesnoth.set_dialog_markup(true, "total_price_label")

		self:update_all_rows()
		self:update_buy_button(true)
		wesnoth.set_dialog_value(1, "trader_list")
		select_from_trader_list()
	end
	self.selected_row = 1
	local r_val = wesnoth.show_dialog(self.dialog, preshow)
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
		wesnoth.set_dialog_value(image, "trader_list", i, "list_image")
			
		local quantity = item.quantity == nil and "" or (item.quantity - (self.items_bought[i] or 0))
		local price_string = string.format("Price: %sg", tostring(item.price))
		local basket_string = string.format("in the basket: %d", self.items_bought[i] or 0)
		if (self.items_bought[i] or 0) < 10 then
			basket_string = basket_string .. "    "
		end
		local quant_string = item.quantity == nil and "         " or string.format("available: %s", item.quantity)
		wesnoth.set_dialog_value(item.name, "trader_list", i, "list_name")
		wesnoth.set_dialog_value(item.quantity or "       ", "trader_list", i, "list_quantity")
		wesnoth.set_dialog_value((self.items_bought[i] or "      "), "trader_list", i, "list_basket")
		wesnoth.set_dialog_value((tostring(item.price) .. "g"), "trader_list", i, "list_price")
			
		wesnoth.set_dialog_value(item.name, "details_pages", i, "details_name")
		wesnoth.set_dialog_value(item.description, "details_pages", i, "details_description")
		wesnoth.set_dialog_value(quant_string, "details_pages", i, "details_quantity")
		wesnoth.set_dialog_value(basket_string, "details_pages", i, "details_basket_count")
		wesnoth.set_dialog_value(price_string, "details_pages", i, "details_price")

		self.page_count = i
	end
	wesnoth.set_dialog_value("\n1\n2\n3\n4\n5", "details_pages", self.page_count + 1, "details_description")
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
		wesnoth.set_dialog_active(false, "use_button")
	else
		wesnoth.set_dialog_active(true, "use_button")
	end
	if initial then
		-- Add some invisible text to give it more space during layout phase.
		text = text .. "       "
	end
	wesnoth.set_dialog_value(text, "total_price_label")
end

return Seller

