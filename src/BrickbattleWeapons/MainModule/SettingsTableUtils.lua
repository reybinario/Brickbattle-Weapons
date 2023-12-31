--!strict
local SettingsUtils = {}

function SettingsUtils.ClearArray(Array)
	while #Array > 0 do
		table.remove(Array)
	end
end

function SettingsUtils.OverwriteTable(To, From, PathArray: {} | nil)
	if PathArray == nil then
		PathArray = {}
	end
	if typeof(From) == "table" and typeof(To) == "table" then
		for Key, Value in pairs(From) do

			if typeof(Value) == "table" then
				SettingsUtils.OverwriteTable(To[Key], Value, nil)
			else
				if To[Key] == nil and type(Key) ~= "number" then
					warn("Key not found in default settings (attempting to override):", Key, Value)
				end
				To[Key] = Value
			end
		end
	end
end

function SettingsUtils.OverwriteIncompatibleSettings(T)
	if T.InstantDamage then
		if (
			T.Security.Initial.Deactivate
				or T.Security.Update.Deactivate
				or T.Security.Hit.Deactivate
			) and T.Security.Master then

			warn("InstantDamage disabled (not compatible with Deactivate settings in Security).")
			T.InstantDamage = false
		end
	end
	if T.SlingClimb and T.Doomspire.SlingFly then
		T.SlingClimb = false
	end
end

function SettingsUtils.GetValueFromPathArray(Table, PathArray, Depth)
	if not Depth then
		Depth = 1
	end
	for Key,Value in pairs(Table) do
		if Key == PathArray[Depth] then
			if typeof(Value) == "table" then
				return SettingsUtils.GetValueFromPathArray(Value, PathArray, Depth + 1)
			else
				return Value
			end
		end
	end

	return {}
end


return SettingsUtils