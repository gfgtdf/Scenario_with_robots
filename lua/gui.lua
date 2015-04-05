-- this file need some tidy up

-- local helper = z_require("my_helper")

local gui = {}
-- maybe i should write new.MyGrig instead, so new is a table containing all the constructors.
MyGrig = {}
MyGrig.new = function(sizeX, sizeY)
	local self = {}
	--since this are arguments they are like local objects(i donjt need the local keyword), 
	--this is a closure with is used to hide them from other acess.
	--generally there are wto ways to store instancevariables inlua eigher at the self table or at cloasure in the constructor, 
	--note that the self object is always a cloasure in the constructor
	--TODO: choose wich way.
	sizeX = sizeX or 10 
	sizeY = sizeY or 10 
	local T = helper.set_wml_tag_metatable {}
	local grid = T.grid {} -- = {"grid", {}}
	local cells = {}
	local dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },
		grid}
	
	for iY = 1 , sizeY do
		cells[iY] = cells[iY] or {}
		local row_content = {}
		table.insert(grid[2], T.row( row_content) )
		for iX = 1 , sizeX do
			local cell_content = {}
			cells[iY][iX] = cell_content
			table.insert(row_content, T.column(cell_content) )
		end
	end
	self.get_sizeX = function() return sizeX end
	self.get_sizeY = function() return sizeY end
	self.get_cell = function(x, y) return cells[y][x] end
	self.get_dialog = function() return dialog end
	self.get_grid = function() return grid end
	return self
end
gui.MyGrig = MyGrig
-- the keys of imagelist have to be eigher all strings or all ints
-- Dialog 1 ist not needet anymore dielog 2 replaces it
Dialog1 = {}
Dialog1.new = function(sizeX, sizeY, imagelist, startimagekey)
	local self = {}
	sizeX = sizeX or 10 
	sizeY = sizeY or 10 
	imagelist = imagelist or {}
	startimagekey = startimagekey or 1
	local grid_obj = MyGrig.new(sizeX, sizeY)
	local last_row_content = {}
	local dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },
		T.grid { 
			T.row { T.column { grid_obj.get_grid() } }, 
			T.row { T.column { T.grid { T.row (last_row_content) } } } } }
	table.insert(last_row_content, T.column { T.button { id = "ok" , label = "OK" } })
	for k, v in pairs(imagelist) do 
		table.insert(last_row_content, 
			T.column { T.toggle_panel { id = "down_panel" .. tostring(k), T.grid { T.row { vertical_grow = true, 
				T.column { T.image { id = "down_icon" .. tostring(k) } }
          } } } } )
	end
	
	for iY = 1 , sizeY do
		for iX = 1 , sizeX do
		
			table.insert(grid_obj.get_cell(iX,iY), T.toggle_panel { id = "cell_panel" .. tostring(iX) .. tostring(iY), T.grid { T.row { vertical_grow = true, 
				T.column { T.image { id = "cell_icon"  .. tostring(iX) .. tostring(iY) } }
          } } } )
		end
	end
	self.show_dialog = function()
		local selected_index = startimagekey
		local function preshow()
			for k, v in pairs(imagelist) do 
				local f_sel = function()
					selected_index = k
				end
				wesnoth.set_dialog_value(v, "down_icon" .. tostring(k))
				wesnoth.set_dialog_callback(f_sel, "down_panel" .. tostring(k))
			end
			for iY = 1 , sizeY do
				for iX = 1 , sizeX do
					local f_sel = function()
						wesnoth.set_dialog_value(imagelist[selected_index], "cell_icon" .. tostring(iX) .. tostring(iY))
					end
					wesnoth.set_dialog_value(imagelist[startimagekey], "cell_icon" .. tostring(iX) .. tostring(iY))
					wesnoth.set_dialog_callback(f_sel, "cell_panel" .. tostring(iX) .. tostring(iY))
				end
			end
		end
		local function postshow()
		end
		local r = wesnoth.show_dialog(dialog, preshow, postshow)
	end
	return self
end

gui.Dialog1 = Dialog1
-- the keys of imagelist have to be eigher all strings or all ints
-- TODO: make the "componentbar" multilined in case there are to much components
-- i'll do that later, gui2 code is really hard.
Dialog2 = {}
Dialog2.new = function(sizeX, sizeY, imagelist, startimagekey, tooltiplist)
	local self = {}
	sizeX = sizeX or 10 
	sizeY = sizeY or 10 
	tooltiplist = tooltiplist or {}
	imagelist = imagelist or {}
	startimagekey = startimagekey or 1
	local images = {}
	local is_dialog_showing = false
	for  ix = 1, sizeX do
		images[ix] = {}
	end
	local grid_obj = MyGrig.new(sizeX, sizeY)
	local last_row_content = {}
	local dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },
		T.grid { 
			T.row { T.column { grid_obj.get_grid() } }, 
			T.row { T.column { T.grid { T.row (last_row_content) } } } } }
	table.insert(last_row_content, T.column { T.button { id = "ok" , label = "OK" } })
	for k, v in pairs(imagelist) do 
		table.insert(last_row_content, 
			T.column { T.toggle_panel { id = "down_panel" .. tostring(k), T.grid { T.row { vertical_grow = true, 
				T.column { T.image { id = "down_icon" .. tostring(k), tooltip = tooltiplist[k] } }
          } } } } )
	end
	
	for iY = 1 , sizeY do
		for iX = 1 , sizeX do
			table.insert(grid_obj.get_cell(iX,iY), T.toggle_panel { id = "cell_panel" .. tostring(iX) .. tostring(iY), T.grid { T.row { vertical_grow = true, 
				T.column { T.image { id = "cell_icon"  .. tostring(iX) .. tostring(iY) } }
          } } } )
		end
	end
	self.show_dialog = function()
		local selected_index = startimagekey
		local function preshow()
			for k, v in pairs(imagelist) do 
				local f_sel = function()
					self.on_image_chosen(k)
					selected_index = k
				end
				wesnoth.set_dialog_value(v, "down_icon" .. tostring(k))
				wesnoth.set_dialog_callback(f_sel, "down_panel" .. tostring(k))
			end
			for iY = 1 , sizeY do
				for iX = 1 , sizeX do
					local f_sel = function()
						self.on_field_clicked({ x = iX, y = iY }, selected_index)
					end
					if images[iX][iY] == nil then
						wesnoth.set_dialog_value(imagelist[startimagekey], "cell_icon" .. tostring(iX) .. tostring(iY))
					else
						wesnoth.set_dialog_value(images[iX][iY], "cell_icon" .. tostring(iX) .. tostring(iY))
					end
					wesnoth.set_dialog_callback(f_sel, "cell_panel" .. tostring(iX) .. tostring(iY))
				end
			end
		end
		local function postshow()
		end
		is_dialog_showing = true
		local r = wesnoth.show_dialog(dialog, preshow, postshow)
		is_dialog_showing = false
	end
	self.set_image = function(x, y, image)
		--i want make set_image work before and afer show_dialog is called.
		images[x][y] = image
		if is_dialog_showing then
			wesnoth.set_dialog_value(image, "cell_icon" .. tostring(x) .. tostring(y))
		end
	end
	return self
end

gui.Dialog2 = Dialog2
-- it is not very pretty, with MyGrig and Dialog1,2,3 
-- especialy becaus erthe line between MyGrig and Dialog is not as clear as i wanted
-- and because im still not sure wich method to use for classes.
-- since gui code isnot  easy especialy because it crashes the game instead of giving an error in most times, i always create another function when i change something here.
Dialog3 = {}
Dialog3.new = function(sizeX, sizeY, imagelist, startimagekey, tooltiplist, last_row_width, down_labels)
	local self = {}
	sizeX = sizeX or 10 
	sizeY = sizeY or 10 
	tooltiplist = tooltiplist or {}
	imagelist = imagelist or {}
	startimagekey = startimagekey or 1
	local images = {}
	local is_dialog_showing = false
	for  ix = 1, sizeX do
		images[ix] = {}
	end
	--self.down_count = {}
	local down_strings= down_labels or {}
	local grid_obj = MyGrig.new(sizeX, sizeY)
	local last_row_content = {}
	local last_grid_content = {}
	local menu_grid_content = {}
	local menu_row_content = {}
	-- sonce i dont forece the keys of imagelist to be ints i need this
	local down_count = 0 
	local dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },
		T.grid { 
			T.row { T.column { grid_obj.get_grid() } },
			T.row { T.column { T.grid (menu_grid_content) } }, 
			T.row { T.column { T.grid (last_grid_content) } } } }
	-- creating the  downer area  "toolbox"
	for k, v in pairs(imagelist) do
		if down_count % last_row_width == 0 then
			last_row_content = {}
			table.insert(last_grid_content, T.row (last_row_content) )
		end
		down_count = down_count + 1
		table.insert(last_row_content, 
			T.column { T.toggle_panel { id = "down_panel" .. tostring(k), T.grid { 
			T.row { vertical_grow = true, T.column { T.image { id = "down_icon" .. tostring(k), tooltip = tooltiplist[k] } } },
			T.row { vertical_grow = true, T.column { T.label { id = "down_label" .. tostring(k) } } },
			
		  } } } )
	end
	for i = ((down_count - 1)% last_row_width) + 2, last_row_width do
		table.insert(last_row_content, 
			T.column { T.toggle_panel { T.grid { T.row { vertical_grow = true, 
				T.column { T.image { name = imagelist[startimagekey] , tooltip = "fill to match the comuns of above"  } }
          } } } } )
	end
	-- creating the middle (menu) area.
	table.insert(menu_grid_content, T.row (menu_row_content) )
	table.insert(menu_row_content, T.column { T.button { id = "ok" , label = "OK" } })
	
	for iY = 1 , sizeY do
		for iX = 1 , sizeX do
			table.insert(grid_obj.get_cell(iX,iY), T.toggle_panel { id = "cell_panel" .. tostring(iX) .. tostring(iY), T.grid { T.row { vertical_grow = true, 
				T.column { T.image { id = "cell_icon"  .. tostring(iX) .. tostring(iY) } }
          } } } )
		end
	end
	self.show_dialog = function()
		local selected_index = startimagekey
		local function preshow()
			for k, v in pairs(imagelist) do 
				local f_sel = function()
					self.on_image_chosen(k)
					selected_index = k
				end
				wesnoth.set_dialog_value(v, "down_icon" .. tostring(k))
				wesnoth.set_dialog_callback(f_sel, "down_panel" .. tostring(k))
				if down_strings[k] == nil then
					wesnoth.set_dialog_value("0", "down_label" .. tostring(k))
				else
					wesnoth.set_dialog_value(down_strings[k], "down_label" .. tostring(k))
				end
			end
			for iY = 1 , sizeY do
				for iX = 1 , sizeX do
					local f_sel = function()
						self.on_field_clicked({ x = iX, y = iY }, selected_index)
					end
					if images[iX][iY] == nil then
						wesnoth.set_dialog_value(imagelist[startimagekey], "cell_icon" .. tostring(iX) .. tostring(iY))
					else
						wesnoth.set_dialog_value(images[iX][iY], "cell_icon" .. tostring(iX) .. tostring(iY))
					end
					wesnoth.set_dialog_callback(f_sel, "cell_panel" .. tostring(iX) .. tostring(iY))
				end
			end
		end
		local function postshow()
		end
		is_dialog_showing = true
		local r = wesnoth.show_dialog(dialog, preshow, postshow)
		is_dialog_showing = false
	end
	self.set_image = function(x, y, image)
		--i want make set_image work before and afer show_dialog is called.
		images[x][y] = image
		if is_dialog_showing then
			wesnoth.set_dialog_value(image, "cell_icon" .. tostring(x) .. tostring(y))
		end
	end
	self.set_down_label = function(index, text)
		--i want make set_image work before and afer show_dialog is called.
		down_strings[index] = text
		if is_dialog_showing then
			wesnoth.set_dialog_value(text, "down_label"  .. tostring(index))
		end
	end
	return self
end

gui.Dialog3 = Dialog3
return gui