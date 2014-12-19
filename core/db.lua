local _, ns = ...
local E = ns.E

function E:CopyTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	if type(src) ~= "table" then
		return dest
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
				table[k] = panel[k]:GetValue()
			end
		end
	end
end
