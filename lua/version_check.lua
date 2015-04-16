local do_version_check = function()
	local sync_choice = z_require("synconize_choice_workaround")
	local all_sides = {}
	for i, v in ipairs(wesnoth.sides) do
		all_sides[i] = i
	end
	local results = sync_choice.version1_11_13(function()
		return { version = z_require("version") }
	end, nil, all_sides)
	local last_version = nil
	for k,v in pairs(results) do
		last_version = last_version or v.version
		if last_version ~= v.version then
			wesnoth.message("Detected different versions of Scenario With robots: " .. last_version .. " and "  .. v.version .. " OOS are likeley")
		end
	end
end
return do_version_check
