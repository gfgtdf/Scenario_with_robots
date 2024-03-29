-- if they have the file "version_check.lua" than they also have the file "version.lua"
local local_version = swr.require("version")
return {
	do_initial_version_check = function()
		local all_sides = {}
		for i, v in ipairs(wesnoth.sides) do
			all_sides[i] = i
		end
		local results = wesnoth.sync.evaluate_single("version check", function()
			return { version = local_version }
		end, nil, all_sides)
		for k,v in pairs(results) do
			-- v.version might be nil for a null controlled sides.
			if v.version ~= nil and local_version ~= tostring(v.version) then
				wesnoth.message("Detected different versions of Scenario With robots at scenario start: " .. v.version .. " and "  .. local_version .. " OOS are likeley")
			end
		end
		wml.variables["swr_version"] = local_version
	end,
	do_reload_version_check = function()
		-- Note: we cannot use mp sync here becasue it runs from a preload event.
		local original_version = wml.variables.swr_version
		if original_version ~= nil and tostring(original_version) ~= local_version then
				wesnoth.message("Detected different versions of Scenario With robots: " .. original_version .. " and "  .. local_version .. " OOS are likeley")
		end
	end,
}

