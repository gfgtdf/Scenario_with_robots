-- this file adds addidional functionality to the helper object
-- right now im not very convinced that this was the right approach
-- it also defines the Set global function.
local my_helper = {}

--i want this to be like an extension of lua so i want it to be abele to call without the "helper." prefix
function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end


my_helper.serialize = function(o, accept_nil)
	accept_nil = accept_nil or false
	local r = ""
	if type(o) == "nil" and accept_nil then
		return "nil"
	elseif type(o) == "number" or type(o) == "boolean" then
		return tostring(o)
	elseif type(o) == "function" then
		return "loadstring(" .. string.format("%q", string.dump(o)) .. ")"
	elseif type(o) == "userdata" and getmetatable(o) == "translatable string" then
		return serialize(tostring(o))
	elseif type(o) == "string" then
		return string.format("%q", o)
	elseif type(o) == "table" then
		r = "{\n"
		for k,v in pairs(o) do
			r = r .. " [" .. serialize(k) .. "] = " .. serialize(v) .. ",\n"
		end
		return r .. "}\n"
	else
		error("cannot serialize a " .. type(o))
	end
end

-- a function for debugging.
my_helper.cwo = function(obj)
	wesnoth.fire("message",{ message = serialize(obj, true) })
end

--like serialize but faster and without the \n. for storing lua in wml variables
my_helper.serialize_oneline = swr.require("serialize")
my_helper.stable_sort = swr.require("stable_sort")
my_helper.deserialize = function(str)
	return load("return " .. str, nil, "t", {})()
end
my_helper.Set = Set

--not much to say
my_helper.deepcopy = function (orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[my_helper.deepcopy(orig_key)] = my_helper.deepcopy(orig_value)
		end
		setmetatable(copy, my_helper.deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

--unlike get_child this creates a child if it cannot find it.
my_helper.get_or_create_child = function(cfg, name)
	local r = wml.get_child(cfg, name)
	if r ~= nil then
		return r
	else
		r = {}
		table.insert(cfg,{name,r})
		return r
	end
end
--unlike child_range this give also the index of the tag
my_helper.child_range_ex = function (cfg, tag)
	local function f(d, i)
		local c
		repeat
			i = i + 1
			c = cfg[i]
			if not c then return end
		until c[1] == tag
		return i, c[2]
	end
	return f, 0
end

function my_helper.child_range_multiple_tags(cfg, tag_set)
	local function f(s)
		local c
		repeat
			local i = s.i
			c = cfg[i]
			if not c then return end
			s.i = i + 1
		until tag_set[c[1]] ~= nil
		return c[2]
	end
	return f, { i = 1 }
end

-- this method is for iterating over 2 enumerations syncroinous, use it like "for k,v in  merge_iterators({pairs(..)},{pairs(..)}) do" then k,v are arrays of len 2 containing the original k v
my_helper.merge_iterators = function(it1, it2)
	local function f(d, i)
		i1 ,v1 = it1[1](d[1], i[1])
		i2 ,v2 = it2[1](d[2], i[2])
		if(i1 ~= nil or i2 ~= nil) then
			return {i1 ,i2}, {v1 ,v2}
		end
	end
	return f, {it1[2], it2[2]}, {it1[3], it2[3]}
end

--
my_helper.remove_from_array = function(arr, f_filter)
	local index = 1
	while index <= #arr do
		if(f_filter(arr[index])) then
			table.remove(arr, index)
		else
			index = index + 1
		end
	end
end
-- removes ONE subtag with the given tagname of the wml object returns weather somthing was removed,
my_helper.remove_subtag = function(cfg, name)
	for k,v in pairs(cfg) do
		if(type(k) == "number") and (v[1] == name) then
			table.remove(cfg, k)
			return true
		end
	end
	return false
end

my_helper.string_starts = function(String, Start)
   return string.sub(String,1,string.len(Start))==Start
end

-- Doesnt work becaue it requires pango 1.38
my_helper.pango_invisible = function(text)
	-- For some reason pango doesnt support alpha without a color=
	-- For some reason pango doesnt support alpha = 0
	return "<span color='#000000' alpha='1'>" .. text .. "</span>"
end

local function create_image_path_function(funcname)
	local funcname_u = "~" .. string.upper(funcname)
	return function (...)
		local args = table.pack(...)
		local r = {}
		-- table.insert(r, "~")
		table.insert(r, funcname_u)
		table.insert(r, "(")
		if args.n > 0 then
			table.insert(r, args[1])
			for i = 2, args.n do
				table.insert(r, ",")
				table.insert(r, args[i])
			end
		end
		table.insert(r, ")")
		return table.concat(r)
	end
end

my_helper.ipf = {}
setmetatable(my_helper.ipf, {
	__index = function (t, k)
		local f = create_image_path_function(k)
		t[k] = f
		return f
	end
})

local last_time = nil
-- clock debug
cl_b = function()
	local stamp = wesnoth.get_time_stamp()
	local old_time = last_time or stamp
	last_time = stamp
	wesnoth.message(tostring(stamp - old_time) .. "ticks")
end

-- log globals
function l_g()
	local known_names = Set { "pairs", "ipairs", "xpcall", "rawget", "print", "select", "error", "wesnoth", "_G", "tonumber", "collectgarbage", "_VERSION", "loadstring", "string", "load", "rawequal", "rawset", "assert", "debug", "getmetatable", "tostring", "next", "bit32", "os", "unpack", "coroutine", "math", "pcall", "setmetatable", "type", "rawlen", "table"
	                        , "wml", "wesnoth", "globals" }
	for k,v in pairs(_G) do
		if not known_names[k] then
			print(k)
		end
	end
end

function my_helper.lua_to_wml_array(t, tagname)
	local res = {}
	for i, v in ipairs(t) do
		res[#res + 1] = { "tagname", v }
	end
	return res
end

function my_helper.wml_to_lua_array(t, tagname)
	local res = {}
	for tag in wml.child_range(t, tag_set) do
		res[#res + 1] = tag
	end
	return res
end


-- workaround for `local a = obj:member; a(1)` not working.
function my_helper.methonds(obj)
	return setmetatable({}, {
		__index = function(t, k)
			return function(...)
				return obj[k](obj, ...)
			end
		end
	})
end

function my_helper.disallow_undo()
	wesnoth.allow_undo(false)
end

return my_helper