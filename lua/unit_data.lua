local search_directories = {
	"~add-ons/Scenario_with_robots/lua/units/",
	"~add-ons/Scenario_with_robots/units/",
}
local load_unit_data = function(unit_id)
	local filename = string.lower(unit_id) .. ".lua"
	for i,dir in ipairs(search_directories) do
		local filename_full = dir .. filename
		if filesystem.have_file(filename_full) then
			return wesnoth.require(filename_full)
		end
	end
	return nil
end

local unit_data = {}
setmetatable(unit_data, {
	__index = function (t, k)
		local ud = load_unit_data(k)
		t[k] = ud
		return ud
	end
})

return unit_data