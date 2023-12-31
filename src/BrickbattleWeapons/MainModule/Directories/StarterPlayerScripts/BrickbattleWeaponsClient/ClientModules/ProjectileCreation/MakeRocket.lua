--!strict
local Collections = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Physics = game:GetService("PhysicsService")

local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

-- Create the Rocket
return function(Creator, count, PhysicsFolder)

	local Folder,Theme = Aesthetics:GetThemeObject(Creator, "Rocket")
	
	local Part = Folder:FindFirstChildWhichIsA("Part"):Clone()
	Part.Name = Creator.Name.."s Rocket"
	Part.Size = Vector3.new(1, 1, 4)
	Part.BottomSurface = 3
	Part.TopSurface = 3
	Part.LeftSurface = 3
	Part.RightSurface = 3
	Part.FrontSurface = 3
	Part.BackSurface = 3
	Part.CanCollide = false
	Part.CastShadow = true
	Part.Massless = true
	
	Collections:AddTag(Part,"Rocket")
	Collections:AddTag(Part,"Projectile")
	
	if Theme == "Team Color" then
		Part.Color = Creator.TeamColor.Color
	end
	
	-- Make it float
	local force = Instance.new("BodyForce")
	force.Name = "Floater"
	force.Force = Vector3.new(0, Part:GetMass() * workspace.Gravity, 0)
	force.Parent = Part
	
	-- Used for ramp-up
	local vel = Instance.new("BodyVelocity")
	vel.Name = "RocketVelocity"
	vel.Velocity = Vector3.new(0, 0, 0)
	vel.MaxForce = Vector3.new(0, 0, 0)
	vel.Parent = Part
	
	Aesthetics:HandleProjectileVisuals(Creator, Part)

	_G.BB.ClientObjects.Sounds.RocketSounds.Boom:Clone().Parent = Part
	_G.BB.ClientObjects.Sounds.RocketSounds.Swoosh:Clone().Parent = Part

	local v = Instance.new("NumberValue")
	v.Name = "LastReceivedDistance"
	v.Value = 0
	v.Parent = Part

	local ld = Instance.new("Vector3Value")
	ld.Name = "LastSentPosition"
	ld.Parent = Part
	
	local lastUpdateVel = Instance.new("Vector3Value")
	lastUpdateVel.Name = "LastSentVelocity"
	lastUpdateVel.Parent = Part

	local Damage = Instance.new("NumberValue")
	Damage.Name = "Damage"
	Damage.Value = _G.BB.Settings.Rocket.Damage
	Damage.Parent = Part

	local Type = Instance.new("StringValue")
	Type.Name = "ProjectileType"
	Type.Value = "Rocket"
	Type.Parent = Part

	local c = Instance.new("ObjectValue")
	c.Name = "creator"
	c.Value = Creator
	c.Parent = Part
	
	local LastUpdateTick = Instance.new("NumberValue")
	LastUpdateTick.Name = "LastUpdateTick"
	LastUpdateTick.Parent = Part

	local cf = Instance.new("CFrameValue")
	cf.Name = "Origin"
	cf.Parent = Part

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
		
	if _G.BB.Settings.Doomspire.RocketCollisions then
		Physics:SetPartCollisionGroup(Part, "RideableRockets")
		Part.CanCollide = true
	end
		
	
	return Part
end
