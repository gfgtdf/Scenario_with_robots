
-- storing important functions as upvalues to access it faster
local tostring = tostring
local type = type
local pairs = pairs
local insert = table.insert
local format = string.format
-- s_o_i == serialize_oneline_impl
-- 'local s_o_i = nil' is needed to store s_o_i as an upvalue in itself
-- this function cannot serialize functions becasue usually storing functions implies an error
local s_o_i = nil
s_o_i = function (o, builder)
	local o_t = type(o)
	if o_t == "number" or o_t == "boolean" then
		insert(builder, tostring(o))
	elseif o_t == "string" then
		insert(builder, format("%q", o))
	elseif o_t == "userdata" and getmetatable(o) == "translatable string" then
		s_o_i(tostring(o), builder)
	elseif o_t == "table" then
		insert(builder, "{")
		for k,v in pairs(o) do
			insert(builder, "[")
			s_o_i(k, builder)
			insert(builder, "]=")
			s_o_i(v, builder)
			insert(builder, ",")
		end
		insert(builder, "}")
	else
		error("cannot serialize a " .. o_t)
	end
end

local serialize_oneline = function(o, accept_nil)
	if accept_nil and o == nil then
		return "nil"
	end
	local builder = {}
	s_o_i(o, builder)
	return table.concat(builder)
end

return serialize_oneline