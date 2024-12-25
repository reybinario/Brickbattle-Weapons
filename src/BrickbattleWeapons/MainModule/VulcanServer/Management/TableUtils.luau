--!strict
local TableUtils = {}

type PathArray = {any}

type GenericTable = {[any]: any}

-- Clears all elements from an array
function TableUtils.clearArray(array: {any})
	while #array > 0 do
		table.remove(array)
	end
end

-- Overwrites keys in the target table with values from the source table
function TableUtils.overwriteTable(target: GenericTable, source: GenericTable, pathArray: PathArray | nil)
	pathArray = pathArray or {}

	if typeof(target) == "table" and typeof(source) == "table" then
		for key, value in pairs(source) do
			if typeof(value) == "table" then
				target[key] = target[key] or {}
				TableUtils.overwriteTable(target[key], value, nil)
			else
				if target[key] == nil and typeof(key) ~= "number" then
					warn("Key not found in default settings (attempting to override):", key, value)
				end
				target[key] = value
			end
		end
	end
end

-- Retrieves a value from a nested table using a path array
function TableUtils.getValueFromPathArray(table: GenericTable, pathArray: PathArray, possibleDepth: number?): any
	local depth = possibleDepth or 1
	for key, value in pairs(table) do
		if key == pathArray[depth] then
			if typeof(value) == "table" then
				return TableUtils.getValueFromPathArray(value, pathArray, depth + 1)
			else
				return value
			end
		end
	end

	return nil
end

-- Performs a deep copy of `source` into `target`, using `defaults` for missing keys
function TableUtils.deepCopyWithDefaults(target: GenericTable, source: GenericTable, defaults: GenericTable)
    -- Ensure the target is initialized
    target = target or {}

    for key, value in pairs(defaults) do
        if typeof(value) == "table" then
            -- Recursively copy nested tables
            target[key] = TableUtils.deepCopyWithDefaults(
                target[key] or {},
                typeof(source[key]) == "table" and source[key] or {},
                value
            )
        else
            -- Use the source value if it exists, otherwise fallback to default
            target[key] = source[key] ~= nil and source[key] or value
        end
    end

    -- Copy any additional keys from the source that aren't in the defaults
    for key, value in pairs(source) do
        if defaults[key] == nil then
            target[key] = value
        end
    end

    return target
end

function TableUtils.printTable(table: GenericTable)

	if game:GetService("RunService"):IsStudio() then
		print(table)
		return
	end

	-- studio output has great printing, but the dev console does not.
	local function serialize(value: any, depth: number): string
		local indent = string.rep(" ", depth * 2)
		if typeof(value) == "table" then
			local result = "{\n"
			for k, v in pairs(value) do
				local keyStr = typeof(k) == "string" and ("[\"" .. k .. "\"]") or ("[" .. tostring(k) .. "]")
				result ..= indent .. "  " .. keyStr .. " = " .. serialize(v, depth + 1) .. ",\n"
			end
			result ..= indent .. "}"
			return result
		elseif typeof(value) == "string" then
			return "\"" .. value .. "\""
		else
			return tostring(value)
		end
	end

	print("Table state:\n" .. serialize(table, 0))
end


return TableUtils
