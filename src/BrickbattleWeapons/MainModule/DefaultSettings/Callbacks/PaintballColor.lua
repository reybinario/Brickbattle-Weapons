--!strict
return function(HitPart: Part, Creator: Player)
	return HitPart:GetMass() < 240 and not HitPart:IsDescendantOf(Creator.Character) -- and not HitPart.Anchored
end