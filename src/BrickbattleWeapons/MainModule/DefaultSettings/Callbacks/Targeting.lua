--!strict
return function(Hit: BasePart): boolean
	if Hit.Parent == nil then return false end
	return Hit.Parent:FindFirstChildWhichIsA("Humanoid") ~= nil 
		or (
			not Hit.Parent:IsA("Accoutrement") 
			and Hit.CanCollide
			and (Hit.Transparency <= 0.9)
			and not game:GetService("CollectionService"):HasTag(Hit, "Projectile")
		)
end