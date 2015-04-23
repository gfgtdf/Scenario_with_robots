local dropping = {}

dropping.field_data = {}

dropping.loc_to_index = function(x,y)
	return (y - 1) * 1000 + x
end

dropping.index_to_loc = function(index)
	local y_m1 = math.floor(y / 1000)
	return index - y_m1 * 1000, y_m1 + 1
end
-- tis can be used to remove item but no to add items.
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
	return { value = swr_h.serialize_oneline(dropping.field_data) }
end

dropping.read = function(cfg)
	dropping.field_data = swr_h.deseralize(cfg.value)
	dropping.remove_empty_lists()
end

dropping.on_preload = function()
	for k,v in pairs(dropping.field_data) do
		local x,y = dropping.index_to_loc(k)
		wesnoth.add_tile_overlay(x, y, cfg)
	end
end

dropping.add_item = function(x, y, cfg)
	table.insert(dropping.get_entries_at_readwrite(x,y),cfg)
	wesnoth.add_tile_overlay(x, y, cfg)
end

dropping.remove_item = function(x, y, id)
	local entries = dropping.get_entries_at_readwrite(x,y)
	for i,v in ipairs(entries) do
		if v.id == id then
			wesnoth.remove_tile_overlay(x, y, v.image)
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
	while i < #entries do
		local v = entries[i]
		dropping.current_item = v
		dropping.item_taken = nil
		wesnoth.fire_event("drop_pickup", x, y)
		if dropping.item_taken then
			table.remove(entries, i)
		else
			i = i + 1
		end
		dropping.current_item = nil
		dropping.item_taken = nil
	end
end

global_events.register_on_load_reader("dropped_items", dropping.read)
global_events.register_on_save_writer("dropped_items", dropping.write)
global_events.add_event_handler("moveto", dropping.on_moveto)
global_events.add_event_handler("preload", dropping.on_preload)

