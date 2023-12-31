--!strict
local Collections = game:GetService("CollectionService")
local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

-- Create the Rocket
return function(Creator, count)
	local Folder, Theme = Aesthetics:GetThemeObject(Creator, "Bomb")
	
	local Part = Folder:FindFirstChild("Base"):Clone()
	Collections:AddTag(Part,"Bomb")
	Part.Size = Vector3.new(2, 2, 2)
	Part.Shape = Enum.PartType.Ball
	Part.CastShadow = true
	Part.BottomSurface = Enum.SurfaceType.Smooth
	Part.TopSurface = Enum.SurfaceType.Smooth
	Part.Material = Enum.Material.Plastic
	Part.Massless = false
	Part.Anchored = false
	Part.CanCollide = true
	Part.CustomPhysicalProperties = _G.BB.Settings.Bomb.PhysicsProperties
	
	_G.BB.ClientObjects.Sounds.BombSounds.Boom:Clone().Parent = Part
	_G.BB.ClientObjects.Sounds.BombSounds.Tick:Clone().Parent = Part
	
	local Tick = Instance.new("Color3Value")
	Tick.Name = "TickColor"
	Tick.Value = Theme == "Team Color" and Creator.TeamColor.Color or Folder:FindFirstChild("TickColor").Value
	Tick.Parent = Part
	
	local Base = Instance.new("Color3Value")
	Base.Name = "BaseColor"
	Base.Value = Part.Color
	Base.Parent = Part
	
	local ld = Instance.new("Vector3Value")
	ld.Name = "LastSentPosition"
	ld.Parent = Part
	
	local rp = Instance.new("Vector3Value")
	rp.Name = "LatestPosition"
	rp.Parent = Part

	local lastUpdateVel = Instance.new("Vector3Value")
	lastUpdateVel.Name = "LastSentVelocity"
	lastUpdateVel.Parent = Part

	local realOT = Instance.new("NumberValue")
	realOT.Name = "LocalOriginTime"
	realOT.Value = tick()
	realOT.Parent = Part
	
	local lrt = Instance.new("NumberValue")
	lrt.Name = "LastReceivedTime"
	lrt.Value = 0
	lrt.Parent = Part
	
	local ActiveTag = Instance.new("BoolValue")
	ActiveTag.Name = "Active"
	ActiveTag.Value = true
	ActiveTag.Parent = Part
	
	local c = Instance.new("ObjectValue")
	c.Name = "creator"
	c.Value = Creator
	c.Parent = Part

	local AssignedTouch = Instance.new("BoolValue")
	AssignedTouch.Name = "BlownUpClient"
	AssignedTouch.Value = false
	AssignedTouch.Parent = Part
	
	local Type = Instance.new("StringValue")
	Type.Name = "ProjectileType"
	Type.Value = "Bomb"
	Type.Parent = Part
	
	local Ready = Instance.new("BoolValue")
	Ready.Name = "Ready"
	Ready.Value = false
	Ready.Parent = Part
	
	if count then
		local countVal = Instance.new("NumberValue")
		countVal.Name = "Count"
		countVal.Value = count
		countVal.Parent = Part
	end
	
	Part.Color = Tick.Value
	
	Part.Name = Creator.Name.."'s Bomb"
	return Part
end
