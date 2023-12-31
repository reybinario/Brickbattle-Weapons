--!strict
-- Thegamboy
-- Handles superball collisions with local character
-- Used to regulate flying via colliding with superball (sb fly)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local REGION_CORNER = Vector3.new(10, 10, 10)

return function(Humanoid)
	local char = Humanoid.Parent
	
	Humanoid.StateChanged:Connect(function(state)
		if state == Enum.HumanoidStateType.Landed then
			local headPos = char.Head.Position

			local superballs = workspace:FindPartsInRegion3WithWhiteList(
				Region3.new(headPos - REGION_CORNER, headPos + REGION_CORNER),
				CollectionService:GetTagged("Superball"),
				math.huge
			)

			local hitSuperball = false
			for _, superball in next, superballs do
				if not superball:FindFirstChild("creator") then continue end
				if superball.creator.Value ~= Player then continue end
				hitSuperball = true
			end

			if hitSuperball then
				return
			end

			if _G.BB then
				_G.BB.CanSBFly = true
			end
		end
	end)
end
