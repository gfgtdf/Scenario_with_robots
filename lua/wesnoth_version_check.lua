local last_tested_version = "1.13.5"
local min_wesnoth_version = "1.12"
global_events.add_event_handler("prestart", function(event_context)
	if wesnoth.compare_versions(wesnoth.game_config.version, ">", last_tested_version) then
		wesnoth.wml_actions.message {
			speaker = "narrator",
			message = "'Scenario with robots' was only tested up to wesnoth version  " .. last_tested_version .. ". It might not work on your wesnoth version which is " .. wesnoth.game_config.version .. ".",
		}
	end
	if wesnoth.compare_versions(wesnoth.game_config.version, "<", min_wesnoth_version) then
		wesnoth.wml_actions.message {
			speaker = "narrator",
			message = "'Scenario with robots' was only works on wesnoth " .. min_wesnoth_version .. " or later. It might not work on your wesnoth version which is " .. wesnoth.game_config.version .. ".",
		}
	end
end)
