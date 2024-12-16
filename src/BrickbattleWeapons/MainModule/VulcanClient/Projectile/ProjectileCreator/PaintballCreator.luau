--!strict
--!strict

local Collections = game:GetService("CollectionService")
local Physics = game:GetService("PhysicsService")
local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

return function(Creator, CollisionGroup, count, color)
	
	local Folder, Theme = Aesthetics:GetThemeObject(Creator, "PaintballGun")
	local Part = Folder:FindFirstChildWhichIsA("BasePart"):Clone()
	
	Physics:SetPartCollisionGroup(Part, "Paintballs")
	
	Part.Name = Creator.Name.."s Paintball"
	Part.CastShadow = true
	Part.Massless = false
	Part.Anchored = false
	Part.CanCollide = true
	Part.Size = _G.BB.Settings.PaintballGun.Size
	Part.BottomSurface = Enum.SurfaceType.Smooth
	Part.TopSurface = Enum.SurfaceType.Smooth
	
	if _G.BB.Settings.PaintballGun.Density ~= nil then 
		Part.CustomPhysicalProperties = PhysicalProperties.new(_G.BB.Settings.PaintballGun.Density, 0.3, 0.5)
	end
	
	if Part.ClassName == "Part" then -- rather than WedgePart or others
		Part.Shape = _G.BB.Settings.PaintballGun.Shape
	end
	
	if color then
		Part.Color = color
	else
		if _G.BB.Settings.Themes.RandomPaintballColors and Theme == "Normal" then
			Part.Color = Aesthetics:RandomColor()
		elseif Theme == "Team Color" then
			Part.Color = Creator.TeamColor.Color
		end
	end
	
	local Attachment0 = Instance.new("Attachment")
	Attachment0.Parent = Part
	
	local Force = Instance.new("VectorForce")
	Force.Force = _G.BB.Settings.PaintballGun.VectorForce
	Force.RelativeTo = Enum.ActuatorRelativeTo.World
	Force.Attachment0 = Attachment0
	Force.Parent = Part

	Collections:AddTag(Part, "Paintball")
	Collections:AddTag(Part, "Projectile")
	
	Aesthetics:HandleProjectileVisuals(Creator, Part)

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
	Damage.Value = _G.BB.Settings.PaintballGun.Damage
	Damage.Parent = Part

	local Type = Instance.new("StringValue")
	Type.Name = "ProjectileType"
	Type.Value = "PaintballGun"
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

