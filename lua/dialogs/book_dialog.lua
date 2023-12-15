-- i made this because i wanted to make a real campaign at first.
--now in the singe scebario it doesn't really fit, i use it as the "maual book"

-- its gonna be harder than i thought: when i use canvas the text won't wrap, when i use lebal instead i cannot use markup.
--  (note that in cpp boith is possible easily)
-- i think i have to sacrifice the wrapping, it isn't a verybig sacrifice anyway since "pages" are already static, so going to "lines" isnt a that big difference annymore.
-- every page has: page.text, and page.images imagaes ist a list of image inforamtion (pos, path..)

BookDialog = {}
BookDialog.__index = BookDialog

function BookDialog:new(pages)
	local res = {}
	setmetatable(res, self)
	self.factor = 1
	self.pages = pages
	self.current_page = 1
	self.dialog = nil
	self.dialog_wml = {
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
					T.draw { T.text { font_size = 1 } },
				} } } } } },
				T.column { T.toggle_panel { id = "right_page_panel", T.grid { T.row { T.column { T.drawing {
					height = 600 * self.factor,
					width = 500 * self.factor,
					id = "right_page_drwaing",
					T.draw { T.text { font_size = 1 } },
				} } } } } },
			} } } },
			T.row { T.column { T.grid { T.row {
				T.column { T.button {  id = "ok" , label = "OK"  } },
				T.column { T.text_box {  id = "textbox_page" , label = "1"  } },
				T.column { T.button {  id = "goto_page_btn" , label = "Go To Page"  } },
			} } } },
		}
	}
	return res
end

function BookDialog:show_dialog()

	local function preshow(dialog)
		self.dialog = dialog
		local goto_page_handler = function()
			local p_index = tonumber(dialog.textbox_page.label)
			if p_index ~= nil then
				p_index = p_index - ((p_index + 1)% 2)
				self:set_page(p_index)
			end
		end
		dialog.goto_page_btn.callback = goto_page_handler
		dialog.left_page_panel.callback = function() self:set_page(self.current_page - 2) end
		dialog.right_page_panel.callback = function() self:set_page(self.current_page + 2) end
		
		self:show_page(self.current_page)
	end
	local r = gui.show_dialog(self.dialog_wml, preshow)
	self.dialog = nil
end

function BookDialog:set_page(page_number)
	if(page_number > #self.pages) then
		return
	end
	if(page_number < 1) then
		return
	end
	self.current_page = page_number
	if self.dialog then
		self:show_page(self.current_page)
	end
end

function BookDialog:show_page(page_number)
	local page1 = self.pages[page_number]
	local page2 = self.pages[page_number + 1] or {text = ""}
	local drawing = {
		T.image {
			x = 0,
			y = 0,
			w = 500 * self.factor,
			h = 600 * self.factor,
			resize_mode = "scale",
			name= "misc/page1.png"
		},
		T.text {
			x = 30 * self.factor, y = 30 * self.factor, w = 500, h = 500,
			-- -2 for the line spacing (i dont know how to change line spacing), it doesnt work very good
			font_size = 22 * self.factor - 2,
			text = page1.text,
			color = "135,74,0,255",
			maximum_width = (500 - 50)* self.factor,
			text_markup = true,
			text_wrap_mode = 0,
		},
	}
	for k, v in pairs(page1.grapics or {}) do
		table.insert(drawing, T.image {
			x = v.x * self.factor,
			y = v.y * self.factor,
			w = v.w * self.factor,
			h = v.h * self.factor,
			name = v.name
		})
	end
	self.dialog:find("left_page_drwaing"):set_canvas(1, drawing)

	local drawing = {
		T.image {
			x = 0,
			y = 0,
			w = 500 * self.factor,
			h = 600 * self.factor,
			resize_mode = "scale",
			name= "misc/page2.png",
		},
		T.text {
			x = 30 * self.factor, y = 30 * self.factor, w = 500, h = 500,
			-- -2 for the line spacing (i dont know hot to change line spacing), it doesnt work very good
			font_size = 22 * self.factor - 2,
			text = page2.text,
			color = "135,74,0,255",
			maximum_width = (500 - 50)* self.factor,
			text_markup = true,
			text_wrap_mode = 3,
		},
	}
	for k, v in pairs(page2.grapics or {}) do
		table.insert(drawing, T.image {
			x = v.x * self.factor,
			y = v.y * self.factor,
			w = v.w * self.factor,
			h = v.h * self.factor,
			name = v.name
		})
	end
	self.dialog:find("right_page_drwaing"):set_canvas(1, drawing)
end

return BookDialog
