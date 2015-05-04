local u = {}
u.image_mods = {}
u.image_mods.spear = function (n, t)
	if n >= 3 then
		table.insert(t, swr_h.ipf.blit("units/robots/spear1.png",12,15))
	end
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/spear1.png",12,20))
	end
	if n >= 2 then
		table.insert(t, swr_h.ipf.blit("units/robots/spear1.png",12,25))
	end
end
u.image_mods.wheel = function (n, t)
	if n >= 3 then
		table.insert(t, swr_h.ipf.blit("units/robots/wheel1.png",46,35))
	end
	if n >= 2 then
		table.insert(t, swr_h.ipf.blit("units/robots/wheel1.png",41,37))
	end
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/wheel1.png",36,39))
	end
end
u.image_mods.laser = function (n, t)
	if n >= 3 then
		table.insert(t, swr_h.ipf.blit("units/robots/cannon1.png",45,35))
	end
	if n >= 2 then
		table.insert(t, swr_h.ipf.blit("units/robots/cannon1.png",45,30))
	end
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/cannon1.png",45,25))
	end
end
u.image_mods.bow = function (n, t)
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/bow1.png",12,8))
	end
end
u.image_mods.propeller = function (n, t)
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/propeller1.png",15,5))
	end
	if n >= 2 then
		table.insert(t, swr_h.ipf.blit("units/robots/propeller1.png",30,0))
	end
end
return u