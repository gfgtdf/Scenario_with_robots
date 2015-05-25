local u = {}
u.image_mods = {}
u.image_mods.spear = function (n, t)
	if n >= 3 then
		table.insert(t, swr_h.ipf.blit("units/robots/spear1.png",3,28))
	end
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/spear1.png",3,33))
	end
	if n >= 2 then
		table.insert(t, swr_h.ipf.blit("units/robots/spear1.png",3,38))
	end
end
u.image_mods.wheel = function (n, t)
	if n >= 3 then
		-- x=40 is we be > 72 pixels.
		table.insert(t, swr_h.ipf.blit("units/robots/wheel1.png",49,50))
	end
	if n >= 2 then
		table.insert(t, swr_h.ipf.blit("units/robots/wheel1.png",44,52))
	end
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/wheel1.png",39,54))
	end
end
u.image_mods.laser = function (n, t)
	if n >= 3 then
		table.insert(t, swr_h.ipf.blit("units/robots/cannon1.png",50,35))
	end
	if n >= 2 then
		table.insert(t, swr_h.ipf.blit("units/robots/cannon1.png",50,30))
	end
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/cannon1.png",50,25))
	end
end
u.image_mods.bow = function (n, t)
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/bow2.png",0,0))
	end
end
u.image_mods.healing = function (n, t)
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/healing_medium.png",0,0))
	end
end
u.image_mods.propeller = function (n, t)
	if n >= 1 then
		table.insert(t, swr_h.ipf.blit("units/robots/propeller1.png",2,15))
	end
	if n >= 2 then
		table.insert(t, swr_h.ipf.blit("units/robots/propeller1.png",34,0))
	end
	if n >= 3 then
		table.insert(t, swr_h.ipf.blit("units/robots/propeller1.png",10,20))
	end
	if n >= 4 then
		table.insert(t, swr_h.ipf.blit("units/robots/propeller1.png",42,5))
	end
end
return u