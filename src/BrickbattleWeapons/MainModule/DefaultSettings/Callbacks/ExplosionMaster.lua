--!strict
local MaxFlingMass = 500 -- wil not attempt to fling larger parts

return function(HitPart: Part, Creator: Player?)
	return HitPart.Mass < MaxFlingMass
end