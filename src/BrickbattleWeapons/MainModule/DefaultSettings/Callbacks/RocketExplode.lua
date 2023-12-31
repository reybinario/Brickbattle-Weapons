--!strict
return function(Hit: BasePart): boolean
	if game:GetService("CollectionService"):HasTag(Hit, "Projectile") then
		return false
		--return string.find(Hit.Name, "Pellet") ~= nil
	else
		local CharacterModel = Hit:FindFirstAncestorOfClass("Model")
		if CharacterModel and CharacterModel:FindFirstChildOfClass("Humanoid") then
			return Hit.Parent == CharacterModel
		else
			return Hit.CanCollide
		end
	end
end