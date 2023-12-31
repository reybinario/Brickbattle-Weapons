--!strict
-- GloriedRage, Thegameboy and NexusAvenger
local Targeting = {}

local Collections = game:GetService("CollectionService")
local Filtered = {}

-- Assumes nothing like nested models in the hierarchy.
local function FindCharacterAncestor(part)
	local Model = part:FindFirstAncestorOfClass("Model")
	local Humanoid = Model and Model:FindFirstChildOfClass("Humanoid")
	return Model,Humanoid
end

local player = game:GetService("Players").LocalPlayer -- player would be nil for seemingly no reason..?

-- Custom raycasting function to prevent specific objects from messing up targeting
function Targeting:CastRay(StartPos, Direction, Length)
	local _set = _G.BB.Settings
	local Settings = _set.Targeting
	
	local ref =  _G.BB.Modules.Callbacks.Targeting
	local Callback = ref and require(ref)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = Filtered
	raycastParams.IgnoreWater = true
	
	local RaycastResults = workspace:Raycast(StartPos,Direction * Length, raycastParams) 
		or {Position = StartPos + (Direction* Length)}
	
	local Hit = RaycastResults and RaycastResults.Instance
	local EndPos = RaycastResults and RaycastResults.Position
	
	if Hit then		
		local CallbackResult = Callback(Hit)
		
		if CallbackResult == false then
			
			-- Cast another ray
			table.insert(Filtered,Hit)
			return self:CastRay(EndPos, Direction, Length - ((StartPos - EndPos).magnitude))
		end
	end
	
	-- Return the hit and target position
	Filtered = {}
	
	--print("Hit:", Hit, "Position:", EndPos)
	return Hit,EndPos
end

-- Acquires world position of the mouse
function Targeting:Get3DPosition(X, Y, TouchTap)
	local Camera = workspace.CurrentCamera
	local MouseRay = Camera[(TouchTap and "Viewport" or "Screen") .. "PointToRay"](Camera, X, Y)
	local EndPos = MouseRay.Origin + MouseRay.Direction
	table.insert(Filtered, player.Character)
	local Direction = (EndPos - Camera.CFrame.Position).Unit
	return self:CastRay(Camera.CFrame.Position, Direction, 9950)
end

return Targeting