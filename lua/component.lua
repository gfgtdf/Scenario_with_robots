local Component = {}
Component.__index = Component

function Component:new(o)
	setmetatable(o, self)
	return o
end

function Component:get_center()
	return {x = 3, y = 3}
end

function Component:relative_pos(pos)
	local center = self:get_center()
	return { x = pos.x - center.x, y = pos.y - center.y }
end
function Component:get_cell(x, y)
	if y == nil then
		y = x.y
		x = x.x
	end
	--if (self.field[x] or {})[y] == nil then
	--	print("returning nil cell" , x, y)
	--end
	return (self.field[x] or {})[y]
end

function Component:get_image(x, y)
	if y == nil then
		y = x.y
		x = x.x
	end
	return (self.field_images[x] or {})[y]
end

function Component:get_used_rect()
	local x_min = 3
	local x_max = 3
	local y_min = 3
	local y_max = 3

	for x, col in pairs(self.field_images) do
		for y, cell in pairs(col) do
			x_min = math.min(x_min, x)
			x_max = math.max(x_max, x)
			y_min = math.min(y_min, y)
			y_max = math.max(y_max, y)
		end
	end
	return { x_min = x_min, x_max = x_max, y_min = y_min, y_max = y_max }
end

function Component:cells()
	local res = {}
	local i = 0
	local rect = self:get_used_rect()
	for x = rect.x_min, rect.x_max do
		for y = rect.y_min, rect.y_max do
			table.insert(res, { x = x, y = y})
		end
	end
	return function()
		i = i + 1
		return res[i]
	end
end

function Component:get_full_image()
	local rect = self:get_used_rect()
	local x_min = math.min(rect.x_min, 2)
	local x_max = math.max(rect.x_max, 4)
	local y_min = math.min(rect.y_min, 2)
	local y_max = math.max(rect.y_max, 4)

	local center = self:get_center()
	local center_x = center.x - x_min
	local center_y = center.y - y_min

	local res = { "misc/tpixel.png~SCALE(" , 40 * (x_max - x_min + 1) , "," , 40 * (y_max - y_min + 1), ")" }
	for x = x_min, x_max do
		for y = y_min, y_max do

			local image = self:get_image(x, y)

			local pos_x = (x  - x_min) * 40
			local pos_y = (y  - y_min) * 40

			if image then
				--table.insert(res, "~BLIT(misc/twhitesqare40.png,")
				--table.insert(res, tostring(pos_x))
				--table.insert(res, ",")
				--table.insert(res, tostring(pos_y))
				--table.insert(res, ")")
				table.insert(res, "~BLIT(")
				table.insert(res, image)
				table.insert(res, ",")
				table.insert(res, tostring(pos_x))
				table.insert(res, ",")
				table.insert(res, tostring(pos_y))
				table.insert(res, ")")
			end
		end
	end
	table.insert(res, "~BLIT(cursors/normal.png,")
	table.insert(res, tostring(16 + 40 * center_x))
	table.insert(res, ",")
	table.insert(res, tostring(16 + 40 * center_y))
	table.insert(res, ")")
	if x_min ~= 2 or  x_max ~= 4 or  x_min ~= 2 or  x_max ~= 4 then
		table.insert(res, "~SCALE(120,120)")
	end
	return table.concat(res)

end

return Component
