--!strict
local module = {}

return function(ObjectValue, ActiveFolder)
	local Success,Error = pcall(function()
		assert(ObjectValue,"ObjectValue does not exist.")
		assert(ObjectValue.Value,"ObjectValue's value does not exist.")
		assert(ObjectValue.Value.Parent ~= nil,"ObjectValue's value is parented to nil.")
		assert(ObjectValue.Value.Parent ~= ActiveFolder, "ObjectValue's value has already been parented to ActiveFolder.")	
		assert(ObjectValue.Value:IsA("Model"), "Improper class, msut be model.")	
	end)
	
	if Success then
		--print("Verification succeeded for: ",ObjectValue.Value.Name)
		return true
	elseif Error then
		local ValueName = ObjectValue and ObjectValue.Name or "NIL_OBJVAL_NAME"
		local ObjectName = (ObjectValue and ObjectValue.Value) and ObjectValue.Value.Name or "NIL_OBJ_NAME"
		
		warn(
			"\n Error verifying ObjectValue...",
			"\n Value:",ValueName,
			"\n Object:",ObjectName,
			"\n Error:",Error
		)
		
		return false
	end
end