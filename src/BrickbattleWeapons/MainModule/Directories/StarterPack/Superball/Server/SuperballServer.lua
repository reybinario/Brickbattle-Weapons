--!strict
local Superball = {}

local tool = script.Parent.Parent

function Superball:CreatePhysicsFolder(color, count)
	--_G.BB.ProjectileCounts[self.Player.Name].Superballs += 1

	local PhysicsFolder = Instance.new("Folder")
	--PhysicsFolder.Name = "Superball".._G.BB.ProjectileCounts[self.Player.Name].Superballs
	PhysicsFolder.Name = "Superball"..count

	-- Aesthetics:
	local Folder, Theme = self.Aesthetics:GetThemeObject(self.Player, "Superball")
	local Part = Folder:FindFirstChildWhichIsA("Part")
	
	self.handle.Material = Part.Material
	self.handle.Reflectance = Part.Reflectance
	self.handle.Color = Theme == "Team Color" and self.Player.TeamColor.Color or Part.Color
	self.handle.Transparency = Part.Transparency
	
	local CT = Instance.new("Color3Value")
	CT.Name = "RandomColor"
	CT.Value = self.handle.Color 
	CT.Parent = PhysicsFolder
	
	local ThemeTag = Instance.new("StringValue")
	ThemeTag.Name = "Theme"
	ThemeTag.Value = self.Aesthetics:DetermineTheme(self.Player)
	ThemeTag.Parent = PhysicsFolder
	
	if _G.BB.Settings.Themes.RandomSuperballColors and ThemeTag.Value == "Normal" then
		CT.Value = color
		self.handle.Color = color
	end

	-- Add the creator tag
	local new_tag = Instance.new("ObjectValue")
	new_tag.Name = ("creator")
	new_tag.Value = self.Player;
	new_tag.Parent = PhysicsFolder
	
	local lastUpdateCFrame = Instance.new("Vector3Value")
	lastUpdateCFrame.Name = "LastSentPosition"
	lastUpdateCFrame.Parent = PhysicsFolder
	
	local lastSentTime = Instance.new("NumberValue")
	lastSentTime.Name = "LastSentTime"
	lastSentTime.Parent = PhysicsFolder
	
	local LastUpdateTick = Instance.new("NumberValue")
	LastUpdateTick.Name = "LastUpdateTick"
	LastUpdateTick.Parent = PhysicsFolder

	local lp = Instance.new("Vector3Value")
	lp.Name = "LatestPosition"
	lp.Parent = PhysicsFolder
	
	local lv = Instance.new("Vector3Value")
	lv.Name = "LatestVelocity"
	lv.Parent = PhysicsFolder
	
	local lt = Instance.new("NumberValue")
	lt.Name = "LatestTime"
	lt.Parent = PhysicsFolder

	local projType = Instance.new("StringValue")
	projType.Name = "ProjectileType"
	projType.Value = "Superball"
	projType.Parent = PhysicsFolder
	
	local ID = Instance.new("StringValue")
	ID.Name = "UniqueID"
	ID.Value = PhysicsFolder.Name.._G.BB.ProjectileCounts[self.Player.Name].Superballs
	ID.Parent = PhysicsFolder
	
	local ActiveVal = Instance.new("BoolValue")
	ActiveVal.Name = "Active"
	ActiveVal.Value = true
	ActiveVal.Parent = PhysicsFolder
	
	local CanHalfDamageValue = Instance.new("BoolValue")
	CanHalfDamageValue.Name = "CanHalfDamage"
	CanHalfDamageValue.Value = true
	CanHalfDamageValue.Parent = PhysicsFolder
	
	local Hacking = Instance.new("BoolValue")
	Hacking.Name = "Hacking"
	Hacking.Value = false
	Hacking.Parent = PhysicsFolder
	
	local Damage = Instance.new("NumberValue")
	Damage.Name = "Damage"
	Damage.Value = _G.BB.Settings.Superball.Damage;
	Damage.Parent = PhysicsFolder;
	
	local sound = self.Boing:Clone()
	sound.Playing = false
	sound.TimePosition = 0
	sound.Parent = PhysicsFolder
		
	return PhysicsFolder
end

function Superball:Init(Settings, Modules, Buffers, Player, Character, Folder)
	self.Aesthetics = require(Modules:WaitForChild("Aesthetics"))

	self.ActiveFolder = Folder:WaitForChild("Active"):WaitForChild(Player.Name)
	self.Player = Player
	
	self.handle = tool:WaitForChild("Handle")
	self.Boing = self.handle:WaitForChild("Boing")
	
	local Security = require(Modules:WaitForChild("Security"))
	local UpdateEvent = tool:WaitForChild("Update")
	local ColorEvent = tool:WaitForChild("Color")

	local themeRemote = _G.BB.Remotes:WaitForChild("ReplicateTheme")

	--self.Aesthetics:HandleSBHandle(Player, self.handle)
		
	-- First activation must always work even if time() returns 0. 
	local lastActivation = -10
	
	UpdateEvent.OnServerEvent:Connect(function(playerFired, initPos, initVel, initTime, color, count)
		
		local now = time()
		local LenientReloadTime = math.max(Settings.Superball.ReloadTime - 1, Settings.Superball.ReloadTime * .6)
		
		if playerFired == Player and (now - lastActivation) > LenientReloadTime then
			if Player.Character and Player.Character.Parent and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
				lastActivation = now
				
				local PhysicsFolder = self:CreatePhysicsFolder(color, count)
				
				-- Begin replication
				PhysicsFolder.LatestPosition.Value = initPos
				PhysicsFolder.LatestVelocity.Value = initVel
				PhysicsFolder.LatestTime.Value = initTime
				PhysicsFolder.LastUpdateTick.Value = now
				PhysicsFolder.Active.Value = true
				
				if Security:ApproveInit(PhysicsFolder) then
					PhysicsFolder.Parent = self.ActiveFolder
				end
				
				game:GetService("Debris"):AddItem(PhysicsFolder, Settings.Superball.DespawnTime)
			end
		end
	end)
	
	ColorEvent.OnServerEvent:Connect(function(player, color, transparency, reflectance, material, themeFolder, initial)
		self.handle.Color = color
		self.handle.Material = material
		self.handle.Reflectance = reflectance
		self.handle.Transparency = transparency
		
		if not initial then return end --This next part is only needed for animated textures
		local sb = themeFolder:FindFirstChild("Superball")
		if not sb then return end
			
		for _,v in pairs(game.Players:GetPlayers()) do
			if v ~= player then
				themeRemote:FireClient(v, player, self.handle, themeFolder)
			end
		end
	end)
	
	tool.Enabled = true
end

return Superball