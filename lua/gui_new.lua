local dialogs = {}
MyGrid.new = function ()
	local self = {}
	--generally there are wto ways to store instancevariables inlua eigher at the self table or at cloasure in the constructor, 
	--note that the self object is always a cloasure in the constructor
	--TODO: choose wich way.
	self.sizeX = sizeX or 10 
	self.sizeY = sizeY or 10 
	self.grid = T.grid {} 
	self.cells = {}
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
	self.get_sizeX = function() return self.sizeX end
	self.get_sizeY = function() return self.sizeY end
	self.get_cell = function(x, y) return self.cells[y][x] end
	self.get_grid = function() return self.grid end
	return self
end

Dialog3 = {}
Dialog3.new = function(sizeX, sizeY, imagelist, startimagekey, tooltiplist, last_row_width)
	local self = {}
	self.sizeX = sizeX or 10 
	self.sizeY = sizeY or 10 
	self.tooltiplist = tooltiplist or {}
	self.imagelist = imagelist or {}
	self.startimagekey = startimagekey or 1
	self.images = {}
	self.is_dialog_showing = false
	for  ix = 1, sizeX do
		images[ix] = {}
	end
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
	-- creating the downer area  "toolbox"
	for k, v in pairs(imagelist) do
		if down_count % last_row_width == 0 then
			last_row_content = {}
			table.insert(last_grid_content, T.row (last_row_content) )
		end
		down_count = down_count + 1
		table.insert(last_row_content, 
			T.column { T.toggle_panel { id = "down_panel" .. tostring(k), T.grid { T.row { vertical_grow = true, 
				T.column { T.image { id = "down_icon" .. tostring(k), tooltip = tooltiplist[k] } }
          } } } } )
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
	-- creating the upper (robot grid) area
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
