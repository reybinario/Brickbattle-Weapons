--!strict
--!strict

local Collections = game:GetService("CollectionService")
local Physics = game:GetService("PhysicsService")
local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

return function (Creator, CollisionGroup, count)
	
	local Folder, Theme = Aesthetics:GetThemeObject(Creator, "Slingshot")
	local Part = Folder:FindFirstChildWhichIsA("Part"):Clone()
	
	Part.Name = Creator.Name.."'s pellet"
	Part.CastShadow = true
	Part.Massless = false
	Part.Anchored = false
	Part.CanCollide = true
	Part.Size = Vector3.new(1, 1, 1)
	Part.Shape = Enum.PartType.Ball
	Part.BottomSurface = Enum.SurfaceType.Smooth
	Part.TopSurface = Enum.SurfaceType.Smooth
	Part.Color = Theme == "Team Color" and Creator.TeamColor.Color or Part.Color
	
	Aesthetics:HandleProjectileVisuals(Creator, Part)

	Collections:AddTag(Part,"Pellet")
	Collections:AddTag(Part,"Projectile")
	
	_G.BB.ClientObjects.Sounds.SlingshotSounds:Clone().Parent = Part

	local lastUpdateVel = Instance.new("Vector3Value")
	lastUpdateVel.Name = "LastSentVelocity"
	lastUpdateVel.Parent = Part

	local lastUpdateCFrame = Instance.new("Vector3Value")
	lastUpdateCFrame.Name = "LastSentPosition"
	lastUpdateCFrame.Parent = Part

	local lastSentTime = Instance.new("NumberValue")
	lastSentTime.Name = "LastSentTime"
	lastSentTime.Parent = Part

	local Damage = Instance.new("NumberValue")
	Damage.Name = "Damage"
	Damage.Value = _G.BB.Settings.Slingshot.Damage
	Damage.Parent = Part

	local Type = Instance.new("StringValue")
	Type.Name = "ProjectileType"
	Type.Value = "Slingshot"
	Type.Parent = Part

	local c = Instance.new("ObjectValue")
	c.Name = "creator"
	c.Value = Creator
	c.Parent = Part

	local active = Instance.new("BoolValue")
	active.Name = "Active"
	active.Value = true
	active.Parent = Part
	
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
	
	if CollisionGroup then
		Physics:SetPartCollisionGroup(Part,CollisionGroup)
	end

	return Part
end
