--!strict
return function(Shape, Size, Density) -- Does not account for unions
	if Shape == "Block" or Shape == "Wedge" then
		local Mass = Size.X * Size.Y * Size.Z * Density
		-- Wedges and cornerwedges do not currently have 
		-- variant mass from regular blocks
		--if Shape == "Wedge" then 
		--	Mass /= 2
		--end
		return Mass
	elseif Shape == "Ball" then
		local Radius = Size.Y / 2
		return (4 / 3) * math.pi * (Radius ^ 3) * Density 
		-- Roblox does not support irregular spheres unless using meshes, 
		-- but because you can't actually resize spheres outside of 
		-- equilaterial sides, we dont need to find the smallest axis
	elseif Shape == "Cylinder" then
		local SmallestAxis = Size.Y > Size.Z and Size.Z or Size.Y
		-- Roblox does not support irregular cylinders, 
		-- and so because we can freely resize the cylinder regardless, 
		-- we have to see which axis is smaller so we can use that as 
		-- the radius.
		local Radius = SmallestAxis / 2
		return math.pi * (Radius ^ 2) * Size.X * Density
	end
end