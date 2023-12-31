--!strict
local Paintball = {}

local tool = script.Parent.Parent

function Paintball:CreatePhysicsFolder(color, count)
	
	local PhysicsFolder = Instance.new("Folder")
	
	--_G.BB.ProjectileCounts[self.Player.Name].Paintballs += 1
	
	--PhysicsFolder.Name = "PaintballGun".._G.BB.ProjectileCounts[self.Player.Name].Paintballs
	PhysicsFolder.Name = "PaintballGun"..count
	
	local ThemeTag = Instance.new("StringValue")
	ThemeTag.Name = "Theme"
	ThemeTag.Value = self.Aesthetics:DetermineTheme(self.Player)
	ThemeTag.Parent = PhysicsFolder
	
	local Folder,Theme = self.Aesthetics:GetThemeObject(self.Player,"PaintballGun");
	local Pb = Folder:FindFirstChildWhichIsA("Part")
	
	local CT = Instance.new("Color3Value")
	CT.Name = "RandomColor"
	CT.Value = color
	CT.Parent = PhysicsFolder	
	
	-- Add the creator tag
	local new_tag = Instance.new("ObjectValue")
	new_tag.Name = "creator"
	new_tag.Value = self.Player
	new_tag.Parent = PhysicsFolder

	local projType = Instance.new("StringValue")
	projType.Name = "ProjectileType"
	projType.Value = "PaintballGun"
	projType.Parent = PhysicsFolder
	
	local ID = Instance.new("StringValue")
	ID.Name = "UniqueID"
	ID.Value = PhysicsFolder.Name.._G.BB.ProjectileCounts[self.Player.Name].Paintballs
	ID.Parent = PhysicsFolder

	local pbSettings = _G.BB.Settings.PaintballGun

	local vf = Instance.new("Vector3Value")
	vf.Name = "VectorForce"
	vf.Value = pbSettings.VectorForce
	vf.Parent = PhysicsFolder

	local m = Instance.new("NumberValue")
	m.Name = "Mass"
	m.Value = self.GetMass(pbSettings.Shape, pbSettings.Size, pbSettings.Density)
	m.Parent = PhysicsFolder
	
	local lp = Instance.new("Vector3Value")
	lp.Name = "LatestPosition"
	lp.Parent = PhysicsFolder

	local lv = Instance.new("Vector3Value")
	lv.Name = "LatestVelocity"
	lv.Parent = PhysicsFolder

	local lt = Instance.new("NumberValue")
	lt.Name = "LatestTime"
	lt.Parent = PhysicsFolder
	
	local LastUpdateTick = Instance.new("NumberValue")
	LastUpdateTick.Name = "LastUpdateTick"
	LastUpdateTick.Parent = PhysicsFolder
	
	local ActiveVal = Instance.new("BoolValue")
	ActiveVal.Name = "Active"
	ActiveVal.Value = true
	ActiveVal.Parent = PhysicsFolder
	
	local ActiveVal = Instance.new("BoolValue")
	ActiveVal.Name = "Exploded"
	ActiveVal.Value = false
	ActiveVal.Parent = PhysicsFolder
	
	local Damage = Instance.new("NumberValue")
	Damage.Name = "Damage"
	Damage.Value = self.Settings.PaintballGun.Damage
	Damage.Parent = PhysicsFolder
	
	
	return PhysicsFolder
end

function Paintball:Init(Settings, Modules, Buffers ,Player, Character, Folder)	
	self.Aesthetics = require(Modules:WaitForChild("Aesthetics"))
	self.GetMass = require(tool:WaitForChild("GetMass"))
	
	self.ActiveFolder = Folder:WaitForChild("Active"):WaitForChild(Player.Name)
	
	self.Player = Player
	
	self.Settings = Settings
	
	local handle = tool:WaitForChild("Handle")
	local UpdateEvent = tool:WaitForChild("Update")

	local Security = require(Modules:WaitForChild("Security"))
	
	-- First activation must always work event if time() returns 0. 
	local lastActivation = -10;
	
	UpdateEvent.OnServerEvent:Connect(function(playerFired,initPos,initVel, initTime, count, color)
		
		-- Verifying firer == player and reload time was waited upon.
		local now = time()
		local LenientReloadTime = math.max(Settings.PaintballGun.ReloadTime - 1, Settings.PaintballGun.ReloadTime * .6)
		
		if playerFired == Player and (now - lastActivation) > LenientReloadTime then
			if Player.Character and Player.Character.Parent and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
			
				lastActivation = now
				
				local PhysicsFolder = self:CreatePhysicsFolder(color, count)
				
				-- Replicate projectile
				PhysicsFolder.LatestPosition.Value = initPos or Vector3.new()
				PhysicsFolder.LatestVelocity.Value = initVel or Vector3.new()
				PhysicsFolder.LatestTime.Value = initTime			
				
				handle:FindFirstChild("Fire"):Play()
				
				if Security:ApproveInit(PhysicsFolder) then
					PhysicsFolder.Parent = self.ActiveFolder
				end

				-- Clean up and prepare for next paintball
				game:GetService("Debris"):AddItem(PhysicsFolder, Settings.PaintballGun.DespawnTime)
			end
		end
	end)
	tool.Enabled = true
end

return Paintball