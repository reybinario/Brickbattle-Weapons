--!strict
-- Thegameboy
-- Used in all projectile client scripts
-- Designed to stop shooting through bricks

local CORNER_MULTIPLIERS = {
	Vector3.new(-1, -1, 1),
	Vector3.new(1, -1, 1),
	Vector3.new(-1, -1, -1),
	Vector3.new(1, -1, -1),

	Vector3.new(-1, 1, 1),
	Vector3.new(1, 1, 1),
	Vector3.new(-1, 1, -1),
	Vector3.new(1, 1, -1),
}

local function getPoints(instance)
	local points = {}
	local CF = instance.CFrame
	local size = instance.Size

	for _, corner in next, CORNER_MULTIPLIERS do
		local point = CF:PointToWorldSpace(corner * (size / 2))
		table.insert(points, point)
	end

	return points
end

local function getFaces(instance)
	local faces = {}
	local CF = instance.CFrame
	local size = instance.Size

	for _, dir in next, Enum.NormalId:GetEnumItems() do
		local v = Vector3.fromNormalId(dir)
		local point = CF:PointToWorldSpace(v * (size / 2))
		table.insert(faces, {point = point, normal = CF:VectorToWorldSpace(v)})
	end

	return faces
end

function isAbove(point, planePoint, normal)
	local relative = point - planePoint
	return relative:Dot(normal) > 0 -- if point is above plane
end

local chars = {}
do
	local function onPlayerAdded(player)
		local function onCharacterAdded(char)
			table.insert(chars, char)
		end
		local function onCharacterRemoving(char)
			local index = table.find(chars, char)
			if index then
				table.remove(chars, index)
			end
		end

		local con1 = player.CharacterAdded:Connect(onCharacterAdded)
		local con2 = player.CharacterRemoving:Connect(onCharacterRemoving)
		if player.Character then
			onCharacterAdded(player.Character)
		end

		local con3
		con3 = player.AncestryChanged:Connect(function()
			con1:Disconnect()
			con2:Disconnect()
			con3:Disconnect()

			if player.Character then
				onCharacterRemoving(player.Character)
			end
		end)
	end

	game:GetService("Players").PlayerAdded:Connect(onPlayerAdded)
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		onPlayerAdded(player)
	end
end

local SIZE = Vector3.new(0.1, 0.1, 0.1)
return function(instance, completelyInside)

	local ignore = {instance, unpack(chars)}
	local pos = instance.Position
	local parts = workspace:FindPartsInRegion3WithIgnoreList(Region3.new(pos - SIZE, pos + SIZE), ignore, 1)
	local points = getPoints(instance)

	if completelyInside then
		for _, part in next, parts do
			for _, face in next, getFaces(part) do
				for _, point in next, points do
					if isAbove(point, face.point, face.normal) then
						return false
					end
				end
			end
		end
		
		return #parts > 0
	end
	
	for _, part in next, parts do
		for _, face in next, getFaces(part) do
			for _, point in next, points do
				if not isAbove(point, face.point, face.normal) then
					return true
				end
			end
		end
	end
	
	return false
end