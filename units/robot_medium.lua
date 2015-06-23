local u = {}
u.image_mods = {}
u.image_mods.spear = function (n, t)
	if n >= 3 then
		table.insert(t, { image = "units/robots/spear1.png", x = 3, y = 28 })
	end
	if n >= 1 then
		table.insert(t, { image = "units/robots/spear1.png", x = 3, y = 33 })
	end
	if n >= 2 then
		table.insert(t, { image = "units/robots/spear1.png", x = 3, y = 38 })
	end
end
u.image_mods.wheel = function (n, t)
	if n >= 3 then
		-- x=40 is we be > 72 pixels.
		table.insert(t, { image = "units/robots/wheel1.png", x = 49, y = 50 })
	end
	if n >= 2 then
		table.insert(t, { image = "units/robots/wheel1.png", x = 44, y = 52 })
	end
	if n >= 1 then
		table.insert(t, { image = "units/robots/wheel1.png", x = 39, y = 54 })
	end
end
u.image_mods.laser = function (n, t)
	if n >= 3 then
		table.insert(t, { image = "units/robots/cannon1.png", x = 50, y = 35 })
	end
	if n >= 2 then
		table.insert(t, { image = "units/robots/cannon1.png", x = 50, y = 30 })
	end
	if n >= 1 then
		table.insert(t, { image = "units/robots/cannon1.png", x = 50, y = 25 })
	end
end
u.image_mods.bow = function (n, t)
	if n >= 1 then
		table.insert(t, { image = "units/robots/bow2.png", x = 0, y = 0 })
	end
end
u.image_mods.healing = function (n, t)
	if n >= 1 then
		table.insert(t, { image = "units/robots/healing_medium.png", x = 0, y = 0, order = -100 })
	end
end
u.image_mods.propeller = function (n, t)
	if n >= 1 then
		table.insert(t, { image = "units/robots/propeller1.png", x = 2, y = 15 })
	end
	if n >= 2 then
		table.insert(t, { image = "units/robots/propeller1.png", x = 34, y = 0 })
	end
	if n >= 3 then
		table.insert(t, { image = "units/robots/propeller1.png", x = 10, y = 20 })
	end
	if n >= 4 then
		table.insert(t, { image = "units/robots/propeller1.png", x = 42, y = 5 })
	end
end
return u