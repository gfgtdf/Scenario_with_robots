local on_event = wesnoth.require("on_event")

local last_tested_version = "1.17.23"
local min_wesnoth_version = "1.14"

on_event("prestart", function(event_context)
	local cur_ver = tostring(wesnoth.current_version())
	if wesnoth.current_version() > wesnoth.version(last_tested_version) then
		wesnoth.wml_actions.message {
			speaker = "narrator",
			message = "'Scenario with robots' was only tested up to wesnoth version  " .. last_tested_version .. ". It might not work on your wesnoth version which is " .. cur_ver .. ".",
		}
	end
	if wesnoth.current_version() < wesnoth.version(min_wesnoth_version) then
		wesnoth.wml_actions.message {
			speaker = "narrator",
			message = "'Scenario with robots' was only works on wesnoth " .. min_wesnoth_version .. " or later. It might not work on your wesnoth version which is " .. cur_ver .. ".",
		}
	end
end)
