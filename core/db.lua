local _, ns = ...
local E = ns.E

-- Lua
local _G = _G
local type = _G.type
local pairs = _G.pairs
local next = _G.next

-- Mine
function E:CopyTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dest[k] = self:CopyTable(v, dest[k])
		elseif type(v) ~= type(dest[k]) then
			dest[k] = v
		end
	end

	return dest
end

function E:DiffTable(src , dest)
	if type(dest) ~= "table" then
		return {}
	end

	if type(src) ~= "table" then
		return dest
	end

	for k, v in pairs(dest) do
		if type(v) == "table" then
			if not next(self:DiffTable(src[k], v)) then
				dest[k] = nil
			end
		elseif v == src[k] then
			dest[k] = nil
		end
	end

	return dest
end

function E:ReplaceTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dest[k] = self:ReplaceTable(v, dest[k])
		else
			dest[k] = v
		end
	end

	return dest
end

local function IsEqualTable(a, b)
	for k, v in pairs(a) do
		if type(v) == "table" and type(b[k]) == "table" then
			if not IsEqualTable(v, b[k]) then
				return false
			end
		else
			if v ~= b[k] then
				return false
			end
		end
	end

	for k, v in pairs(b) do
		if type(v) == "table" and type(a[k]) == "table" then
			if not IsEqualTable(v, a[k]) then
				return false
			end
		else
			if v ~= a[k] then
				return false
			end
		end
	end

	return true
end

function E:IsEqual(a, b)
	if type(a) ~= type(b) then
		return false
	end

	if type(a) == "table" then
		return IsEqualTable(a, b)
	else
		return a == b
	end
end

function E:FetchSettings(panel, table)
	if not table then return end

	for k, v in pairs(table) do
		if type(panel[k]) == "table" and type(v) == "table" then
			-- print(k, v)
			self:FetchSettings(panel[k], v)
		else
			if panel[k] then
				-- print(k, v)
				panel[k]:SetValue(v)
			end
		end
	end
end

function E:ApplySettings(panel, table)
	if not table then return end

	for k, v in pairs(table) do
		if type(panel[k]) == "table" and type(v) == "table" then
			-- print(k, v)
			self:ApplySettings(panel[k], v)
		else
			if panel[k] then
				-- print(k, v, panel[k]:GetValue())
				table[k] = panel[k]:GetValue(v)
			end
		end
	end
end
