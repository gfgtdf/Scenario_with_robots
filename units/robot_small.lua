local u = {}
u.image_mods = {}
u.image_mods.spear = function (n, t)
	if n >= 1 then
		table.insert(t, { image = "units/robots/spear1.png", x = 12, y = 20 })
	end
	if n >= 2 then
		table.insert(t, { image = "units/robots/spear1.png", x = 12, y = 5 })
	end
	if n >= 3 then
		table.insert(t, { image = "units/robots/spear1.png", x = 12, y = 15 })
	end
end
u.image_mods.wheel = function (n, t)
	if n >= 3 then
		table.insert(t, { image = "units/robots/wheel1.png", x = 46, y = 35 })
	end
	if n >= 2 then
		table.insert(t, { image = "units/robots/wheel1.png", x = 41, y = 37 })
	end
	if n >= 1 then
		table.insert(t, { image = "units/robots/wheel1.png", x = 36, y = 39 })
	end
end
u.image_mods.laser = function (n, t)
	if n >= 3 then
		table.insert(t, { image = "units/robots/cannon1.png", x = 45, y = 35 })
	end
	if n >= 2 then
		table.insert(t, { image = "units/robots/cannon1.png", x = 45, y = 30 })
	end
	if n >= 1 then
		table.insert(t, { image = "units/robots/cannon1.png", x = 45, y = 25 })
	end
end
u.image_mods.bow = function (n, t)
	if n >= 1 then
		table.insert(t, { image = "units/robots/bow1.png", x = 12, y = 8 })
	end
end
u.image_mods.propeller = function (n, t)
	if n >= 1 then
		table.insert(t, { image = "units/robots/propeller1.png", x = 15, y = 5 })
	end
	if n >= 2 then
		table.insert(t, { image = "units/robots/propeller1.png", x = 30, y = 0 })
	end
end
return u