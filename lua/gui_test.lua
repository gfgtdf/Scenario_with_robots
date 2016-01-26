-- i made this because i wanted to make a real campaign at first.
--now in the singe scebario it doesn't really fit, i use it as the "maual book"

-- its gonna be harder than i thought: when i use canvas the text won't wrap, when i use lebal instead i cannot use markup.
--  (note that in cpp boith is possible easily)
-- i think i have to sacrifice the wrapping, it isn't a verybig sacrifice anyway since "pages" are already static, so going to "lines" isnt a that big difference annymore.
-- every page has: page.text, and page.images imagaes ist a list of image inforamtion (pos, path..)
Gui_test = {}
Gui_test.new = function(pages)
	local self = {}
	self.factor = 1
	self.pages = pages
	self.current_page = 1
	local menu_grid_content = { T.row { 
		T.column { T.button {  id = "ok" , label = "OK"  } }, 
		T.column { T.text_box {  id = "textbox_page" , label = "1"  } }, 
		T.column { T.button {  id = "goto_page_btn" , label = "Go To Page"  } } } }
	self.dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },
		T.grid { 
			T.row { T.column { T.grid { T.row { 
				-- mabe i can draw right in the panel? 
				T.column { T.toggle_panel { id = "left_page_panel", T.grid { T.row { T.column { T.drawing {
					height = 600 * self.factor,
					width = 500 * self.factor, 
					id = "left_page_drwaing",
					-- i draw an empty text because otherwise i'd get an error, maybe  T.drawing is just not the right widget.
					T.draw { T.text { font_size = 1 } }
					} } } } } }, 
				T.column { T.toggle_panel { id = "right_page_panel", T.grid { T.row { T.column { T.drawing {
					height = 600 * self.factor,
					width = 500 * self.factor,
					id = "right_page_drwaing",
					T.draw { T.text { font_size = 1 } }
					} } } } } }, 
				 } } } },
			T.row { T.column { T.grid (menu_grid_content) } } } }
	self.show_dialog = function()
		local selected_index = globals.startimagekey
		local function preshow()
			local goto_page_handler = function()
				local p_index = tonumber(wesnoth.get_dialog_value("textbox_page"))
				if p_index ~= nil then
					p_index = p_index - ((p_index + 1)% 2)
					self.set_page(p_index)
				end
			end
			wesnoth.set_dialog_callback(goto_page_handler, "goto_page_btn")
			wesnoth.set_dialog_callback(self.turn_left, "left_page_panel")
			wesnoth.set_dialog_callback(self.turn_right, "right_page_panel")
			self.show_page(self.current_page)
		end
		local function postshow()
		end
		self.is_dialog_showing = true
		local r = wesnoth.show_dialog(self.dialog, preshow, postshow)
		self.is_dialog_showing = false
	end
	--this is alwasy fires twice so we need a workaround
	self.turn_right = function()
		local newstamp = wesnoth.get_time_stamp()
		self.stamp = self.stamp or 0
		if (newstamp - self.stamp) < 100 or self.current_page + 2 >  #pages then
		else
			self.stamp = newstamp
			self.set_page(self.current_page + 2)
		end
	end
	self.turn_left = function()
		local newstamp = wesnoth.get_time_stamp()
		self.stamp = self.stamp or 0
		if (newstamp - self.stamp) < 100 or self.current_page - 2 < 1 then
		else
			self.stamp = newstamp
			self.set_page(self.current_page - 2)
		end
	end
	-- ofc this sets both pages, the right page is set to page_number + 1
	self.set_page = function(page_number)
		if(page_number > #pages) then
			error("page_number > #pages")
		end
		if(page_number < 1) then
			error("page_number > #pages")
		end
		self.current_page = page_number
		if self.is_dialog_showing then
			self.show_page(self.current_page)
		end
	end
	self.show_page = function(page_number)
		local page1 = self.pages[page_number]
		local page2 = self.pages[page_number + 1] or {text = ""}
		local drawing = { 
			T.image { 
				x = 0, 
				y = 0, 
				w = 500 * self.factor, 
				h = 600 * self.factor, 
				resize_mode = "scale",
				name= "misc/page1.png" },
			T.text { 
				x = 30 * self.factor, y = 30 * self.factor, w = 500, h = 500, 
				-- -2 for the line spacing (i dont know hot to change line spacing), it doesnt work very good
				font_size = 22 * self.factor - 2,  
				text = page1.text, 
				color = "135,74,0,255",
				maximum_width = (500 - 50)* self.factor,
				text_markup = true,
				text_wrap_mode = 3 } }
		for k, v in pairs(page1.grapics or {}) do 
			table.insert(drawing, T.image {
				x = v.x * self.factor, 
				y = v.y * self.factor, 
				w = v.w * self.factor, 
				h = v.h * self.factor, 
				name = v.name
			})
		end
		wesnoth.set_dialog_canvas(1, drawing, "left_page_drwaing")
		local drawing = { 
			T.image { 
				x = 0, 
				y = 0, 
				w = 500 * self.factor, 
				h = 600 * self.factor, 
				resize_mode = "scale",
				name= "misc/page2.png" },
			T.text { 
				x = 30 * self.factor, y = 30 * self.factor, w = 500, h = 500, 
				-- -2 for the line spacing (i dont know hot to change line spacing), it doesnt work very good
				font_size = 22 * self.factor - 2,  
				text = page2.text, 
				color = "135,74,0,255",
				maximum_width = (500 - 50)* self.factor,
				text_markup = true,
				text_wrap_mode = 3 } }
		for k, v in pairs(page2.grapics or {}) do 
			table.insert(drawing, T.image {
				x = v.x * self.factor, 
				y = v.y * self.factor, 
				w = v.w * self.factor, 
				h = v.h * self.factor, 
				name = v.name
			})
		end
		wesnoth.set_dialog_canvas(1, drawing,"right_page_drwaing")
		-- a workaround to update the canvas
		wesnoth.set_dialog_value(self.get_changing_string(), "left_page_drwaing")
		wesnoth.set_dialog_value(self.get_changing_string(), "right_page_drwaing")
	end
	-- neddet for the workaround 4 lines above
	self.get_changing_string = function()
		self.changing = (self.changing or 0) + 1
		return tostring(self.changing) 
	end
	return self
end
return Gui_test