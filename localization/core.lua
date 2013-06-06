local _, ns = ...
local L = {}
local function defaultFunc(L, key)
	return key
end
setmetatable(L, {__index=defaultFunc})
ns.L = L