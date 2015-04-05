-- i wanted to make an item seller, not done yet.
local Seller = {}
Seller.new = function()
	local self = {}
	self.gui = z_require("dialogs/seller")
	self.dialog = self.gui.normal
	self.items = {}
	self.total_price = 0
	self.items_bought = {}
	
	self.show_dialog = function()
		local select_from_trader_list = function()
		end
		local order_item = function()
			if ((self.items[self.selected_row].quantity or 9999) > (self.items_bought[self.selected_row] or 0)) then
				self.items_bought[self.selected_row] = (self.items_bought[self.selected_row] or 0) + 1
				--self.update_all_basket_rows()
				--cwo("order_i")
				self.update_buy_button()
				self.update_all_rows()
			end
		end
		local remove_item = function()
			if ( (self.items_bought[self.selected_row] or 0) > 0) then
				self.items_bought[self.selected_row] = self.items_bought[self.selected_row]  - 1
				--self.update_all_basket_rows()
				--cwo("order_i")
				self.update_buy_button()
				self.update_all_rows()
			end
		end
		local function select_from_trader_list()
			local i = wesnoth.get_dialog_value("trader_list")

			if i > self.page_count or self.page_count == 0 then
				error("invalid trader_list row number")
			end

			self.selected_row = i
			--refresh_use_button_text(i)
			wesnoth.set_dialog_value(i, "details_pages")
		end
		local function preshow()

			wesnoth.set_dialog_callback(select_from_trader_list, "trader_list")
			wesnoth.set_dialog_callback(order_item, "order_button")
			wesnoth.set_dialog_callback(remove_item, "remove_button")

			self.update_all_rows()
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
	--each item contains: price, quantity, name, description, image
	self.set_item_list = function(item_list)
		self.items = item_list
	end
	self.set_on_item_buyed = function(on_buy_func)
		self.on_buy_func = on_buy_func
	end
	self.update_all_rows = function()
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
			local price_string = "Price: " .. tostring(item.price) .. "g"
			local basket_string = "in the basket: " .. (self.items_bought[i] or 0)
			if (self.items_bought[i] or 0) < 10 then
				basket_string = basket_string .. "    "
			end
			local quant_string = item.quantity == nil and "         " or "available: " .. item.quantity
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
	
	self.update_all_basket_rows = function()
		local old_page_count = self.basket_page_count
		local i = 1
		for k, item_b_number in pairs(self.items_bought) do
			wesnoth.set_dialog_value(self.items[k].image, "basket_list", i, "list_b_image")
			wesnoth.set_dialog_value(item_b_number, "basket_list", i, "list_b_number")

			self.basket_page_count = i
			i = i + 1
		end
	end
	
	self.update_buy_button = function()
		local t_price = 0
		for k, item_b_number in pairs(self.items_bought) do
			t_price = t_price + self.items[k].price * item_b_number
		end
		wesnoth.set_dialog_value(t_price .. "g", "total_price_label")
		
	end
	return self
end
return Seller

