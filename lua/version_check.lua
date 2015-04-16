-- if they have the file "version_check.lua" than they also have the file "version.lua"
local local_version = z_require("version")
return {
	do_initial_version_check = function()
		local sync_choice = z_require("synconize_choice_workaround")
		local all_sides = {}
		for i, v in ipairs(wesnoth.sides) do
			all_sides[i] = i
		end
		local results = sync_choice.version1_11_13(function()
			return { version = local_version }
		end, nil, all_sides)
		
		for k,v in pairs(results) do
			if local_version ~= v.version then
				wesnoth.message("Detected different versions of Scenario With robots: " .. v.version .. " and "  .. local_version .. " OOS are likeley")
			end
		end
		wesnoth.set_variable("swr_version", local_version)
	end,
	do_reload_version_check = function()
		-- Note: we cannot use mp sync here becasue it runs from a preload event.
		local original_version = wesnoth.get_variable("swr_version")
		if original_version ~= nil and original_version ~= local_version then
				wesnoth.message("Detected different versions of Scenario With robots: " .. original_version .. " and "  .. local_version .. " OOS are likeley")
		end
	end,
}

