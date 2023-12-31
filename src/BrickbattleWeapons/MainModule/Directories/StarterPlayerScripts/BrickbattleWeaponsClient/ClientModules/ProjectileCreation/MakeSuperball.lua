--!strict
local Collections = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Physics = game:GetService("PhysicsService")
local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

-- Create the superball
return function(Creator, CollisionGroup, count, _color)
	local Folder,Theme = Aesthetics:GetThemeObject(Creator, "Superball");
	local Part = Folder:FindFirstChildWhichIsA("Part"):Clone()
	
	Collections:AddTag(Part,"Superball")
	Collections:AddTag(Part,"Projectile")
	
	Part.Name = Creator.Name.."'s Superball"
	Part.CastShadow = true
	Part.Massless = false
	Part.Anchored = false
	Part.CanCollide = true
	Part.Size = Vector3.new(2, 2, 2)
	Part.Shape = Enum.PartType.Ball
	Part.BottomSurface = Enum.SurfaceType.Smooth
	Part.TopSurface = Enum.SurfaceType.Smooth
	
	if _G.BB.Settings.Themes.RandomSuperballColors and Theme == "Normal" then
		Part.Color =  _color
	elseif Theme == "Team Color" then
		Part.Color = Creator.TeamColor.Color
	end
	
	_G.BB.ClientObjects.Sounds.SuperballSounds.Boing:Clone().Parent = Part
	
	Aesthetics:HandleProjectileVisuals(Creator, Part, Theme)
	
	--local PhysicsFolderVal = Instance.new("ObjectValue")
	--PhysicsFolderVal.Name = "PhysicsFolder"
	--PhysicsFolderVal.Value = PhysicsFolder
	--PhysicsFolderVal.Parent = Part
	
	Part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0, 1, 1, 1)
	Physics:SetPartCollisionGroup(Part, CollisionGroup)
	
	-- In order to remove the PhysicsFolder buffer, had to make the projectile
	-- the location of data storage.
	
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
	Damage.Value = _G.BB.Settings.Superball.Damage
	Damage.Parent = Part
	
	local Type = Instance.new("StringValue")
	Type.Name = "ProjectileType"
	Type.Value = "Superball"
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
	
	return Part
end
