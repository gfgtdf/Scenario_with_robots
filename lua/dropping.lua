local on_event = wesnoth.require("on_event")

local dropping = {}

dropping.field_data = {}

dropping.loc_to_index = function(x,y)
	return (y - 1) * 1000 + x
end

dropping.index_to_loc = function(index)
	local y_m1 = math.floor(index / 1000)
	return index - y_m1 * 1000, y_m1 + 1
end

local test_convert = function()
	local x,y = dropping.index_to_loc(dropping.loc_to_index(20,40))
	if x ~= 20 or y ~= 40 then
		error("index_to_loc/loc_to_index bugged")
	end
	local x,y = dropping.index_to_loc(12345)
	if dropping.loc_to_index(x,y) ~= 12345 then
		error("index_to_loc/loc_to_index bugged")
	end
end
test_convert()
dropping.decorate_imagename = function(imagename, id)
	return imagename .. "~BLIT(misc/tpixel.png~O(" .. id .."))"
end

dropping.place_image = function(x, y, cfg)
	wesnoth.add_tile_overlay(x, y, {
		image = dropping.decorate_imagename(cfg.image, cfg.id),
		team_name = cfg.team_name,
		visible_in_fog = cfg.visible_in_fog,
		redraw = cfg.redraw,
	})
end


-- this  can be used to remove item but not to add items.
dropping.get_entries_at_readonly = function(x,y)
	return dropping.field_data[dropping.loc_to_index(x,y)] or {}
end

dropping.get_entries_at_readwrite = function(x,y)
	local index = dropping.loc_to_index(x,y)
	dropping.field_data[index] = dropping.field_data[index] or {}
	return dropping.field_data[index]
end

dropping.remove_empty_lists = function()
	local to_delete = {}
	for k,v in pairs(dropping.field_data) do
		if #v == 0 then
			to_delete[k] = true
		end
	end
	for k,v in pairs(to_delete) do
		dropping.field_data[k] = nil
	end
end

dropping.write = function()
	return {
		field_data = swr_h.serialize_oneline(dropping.field_data),
		next_id = dropping.next_id,
	}
end
-- read might not be called if there is no [dropped_items] tag found
dropping.read = function(cfg)
	dropping.field_data = swr_h.deserialize(cfg.field_data)
	dropping.next_id = cfg.next_id or 0
	dropping.remove_empty_lists()
end

dropping.on_preload = function()
	dropping.next_id = dropping.next_id or 0
	for k,v in pairs(dropping.field_data) do
		local x,y = dropping.index_to_loc(k)
		for i, cfg in ipairs(v) do
			dropping.place_image(x, y, cfg)
		end
	end
end

dropping.add_item = function(x, y, cfg)
	table.insert(dropping.get_entries_at_readwrite(x,y), cfg)
	cfg.id = dropping.next_id
	dropping.next_id = dropping.next_id + 1
	dropping.place_image(x, y, cfg)
end

dropping.remove_item = function(x, y, id)
	local entries = dropping.get_entries_at_readwrite(x,y)
	for i,v in ipairs(entries) do
		if v.id == id then
			wesnoth.remove_tile_overlay(x, y, dropping.decorate_imagename(v.image, id))
			table.remove(entries, i)
			break
		end
	end
end

dropping.on_moveto = function(event_context)
	local x = event_context.x1
	local y = event_context.y1
	local entries = dropping.get_entries_at_readonly(x,y)
	local i = 1
	while i <= #entries do
		local v = entries[i]
		dropping.current_item = v
		dropping.item_taken = nil
		wesnoth.fire_event("drop_pickup", x, y)
		if dropping.item_taken then
			table.remove(entries, i)
			wesnoth.remove_tile_overlay(x, y, dropping.decorate_imagename(v.image, v.id))
			swr_h.disallow_undo()
		else
			i = i + 1
		end
		dropping.current_item = nil
		dropping.item_taken = nil
	end
end


function wesnoth.persistent_tags.swr_dropped_items.read(cfg)
    dropping.read(cfg)
end

function wesnoth.persistent_tags.swr_dropped_items.write(add)
	add(dropping.write())
end

on_event("moveto", dropping.on_moveto)
on_event("preload", dropping.on_preload)

return dropping