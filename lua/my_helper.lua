-- this file adds addidional functionality to the helper object
-- right now im not very convinced that this was the right approach
-- it also defines some global functions wich are very important (set, cwo, serialize_oneline)
local helper = wesnoth.require("lua/helper.lua")
local my_helper = {}

--i want this to be like an extension of lua so i want it to be abele to call without the "helper." prefix
function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

-- a function for debugging. cwo = Console Write Object
function cwo(obj)
	wesnoth.fire("message",{ message = serialize(obj, true) })
end
function l_g()
	for k,v in pairs(_G) do
		cwo(k)
	end
end
-- TODO add support for userdata and boolean valuews
function serialize(o, accept_nil)
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
--like seralite but without the \n., used if i want to store wml in lua variables
-- or lua in wml variables
function serialize_oneline(o, accept_nil)
	accept_nil = accept_nil or false
	local r = ""
	if type(o) == "nil" and accept_nil then
		return "nil"
	elseif type(o) == "number" or type(o) == "boolean" then
		return tostring(o)
	elseif type(o) == "userdata" and getmetatable(o) == "translatable string" then
		return serialize_oneline(tostring(o))
	elseif type(o) == "function" then
		return "loadstring(" .. string.format("%q", string.dump(o)) .. ")"
	elseif type(o) == "string" then
		return string.format("%q", o)
	elseif type(o) == "table" then
		r = "{ "
		for k,v in pairs(o) do
			r = r .. " [" .. serialize_oneline(k) .. "] = " .. serialize_oneline(v) .. ", "
		end
		return r .. "} "
	else
		error("cannot serialize a " .. type(o))
	end
end

function deseralize(str)
	return loadstring("return " .. str)()
end

my_helper.cwo = cwo
my_helper.serialize = serialize
my_helper.serialize_oneline = serialize_oneline
my_helper.deseralize = function(str)
	return loadstring("return " .. str)()
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
	local r = helper.get_child(cfg, name)
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

-- i think this was the hardest part, this method is for iterating over 2 enumerations syncroinous, 
-- it is like Enumerabe.Zip in C#, use it like "for k,v in  merge_iterators({pairs(..)},{pairs(..)}) do" then k,v are arrays of len 2 containing the original k v
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
-- min, max are keyword according to notepad++ syntax highlighting-
my_helper.random_number = function(mi, ma)
	if not ma then mi, ma = 1, mi end
	wesnoth.fire("set_variable", { name = "LUA_random", rand = string.format("%d..%d", mi, ma) })
	local res = wesnoth.get_variable "LUA_random"
	wesnoth.set_variable "LUA_random"
	return res
end

my_helper.string_starts = function(String, Start)
   return string.sub(String,1,string.len(Start))==Start
end

local function create_image_path_function(funcname)
	local funcname_u = "~" .. string.upper(funcname)
	return function (...)
		local args = table.pack(...)
		local r = {}
		table.insert(r, "~")
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

return my_helper