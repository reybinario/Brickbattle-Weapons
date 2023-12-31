--!strict
local Slingshot = {}

local tool = script.Parent.Parent

local Debris = game:GetService("Debris")
local Collections = game:GetService("CollectionService")
local Physics = game:GetService("PhysicsService")

function Slingshot:CreatePhysicsFolder(count)
	local PhysicsFolder = Instance.new("Folder")
	
	--_G.BB.ProjectileCounts[self.Player.Name].Pellets += 1

	--PhysicsFolder.Name = "Slingshot".._G.BB.ProjectileCounts[self.Player.Name].Pellets
	PhysicsFolder.Name = "Slingshot"..count

	-- Add creator tag
	local new_tag = Instance.new("ObjectValue")
	new_tag.Name = "creator"
	new_tag.Value = self.Player
	new_tag.Parent = PhysicsFolder
	
	local Active = Instance.new("BoolValue")
	Active.Name = "Active"
	Active.Value = true
	Active.Parent = PhysicsFolder
	
	local ProjectileType = Instance.new("StringValue")
	ProjectileType.Name = "ProjectileType"
	ProjectileType.Value = "Slingshot"
	ProjectileType.Parent = PhysicsFolder
	
	local CanHalfDamageValue = Instance.new("BoolValue")
	CanHalfDamageValue.Name = "CanHalfDamage"
	CanHalfDamageValue.Value = true
	CanHalfDamageValue.Parent = PhysicsFolder
	
	local Damage = Instance.new("IntValue")
	Damage.Name = "Damage"
	Damage.Value = self.Settings.Slingshot.Damage
	Damage.Parent = PhysicsFolder;
	
	local ID = Instance.new("StringValue")
	ID.Name = "UniqueID"
	ID.Value = PhysicsFolder.Name.._G.BB.ProjectileCounts[self.Player.Name].Pellets
	ID.Parent = PhysicsFolder
	
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

	local ThemeTag = Instance.new("StringValue")
	ThemeTag.Name = "Theme"
	ThemeTag.Value = self.Aesthetics:DetermineTheme(self.Player)
	ThemeTag.Parent = PhysicsFolder
	
	self.slingshotSounds:Clone().Parent = PhysicsFolder
		
	--print(PhysicsFolder:GetFullName())
	return PhysicsFolder
end

function Slingshot:Init(Settings, Modules, Buffers, Player, Character, Folder)	
	local handle = tool:WaitForChild("Handle")
	local UpdateEvent = tool:WaitForChild("Update")
	
	self.slingshotSounds = handle:WaitForChild("SlingshotSounds")
	self.ActiveFolder = Folder:WaitForChild("Active"):WaitForChild(Player.Name)
	self.Aesthetics = require(Modules:WaitForChild("Aesthetics"))
	self.Settings = Settings
	self.Player = Player
	
	local ActiveFolder = Folder:WaitForChild("Active"):WaitForChild(Player.Name)
	
	local Security = require(Modules:WaitForChild("Security"))

	-- First activation must always work event if time() returns 0. 
	local lastActivation = -0.2;
	
	UpdateEvent.OnServerEvent:Connect(function(firingPlayer, initPos, initVel, initTime, count, seenServerTime)
		local now = time()
		local Head = firingPlayer.Character and firingPlayer.Character:FindFirstChild("Head")
		local LenientReloadTime = math.max(Settings.Slingshot.ReloadTime - 1, Settings.Slingshot.ReloadTime * .5)
		
		if Head and firingPlayer == Player and (now - lastActivation) > LenientReloadTime then
			if Player.Character and Player.Character.Parent and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
				lastActivation = now
							
				local PhysicsFolder = self:CreatePhysicsFolder(count)
		
				
				-- Replicate projectile
				PhysicsFolder.LatestPosition.Value = initPos
				PhysicsFolder.LatestVelocity.Value = initVel
				PhysicsFolder.LatestTime.Value = initTime
				PhysicsFolder.LastUpdateTick.Value = now
				PhysicsFolder.Active.Value = true
				
				if Security:ApproveInit(PhysicsFolder) then
					PhysicsFolder.Parent = self.ActiveFolder
				end
				
				Debris:AddItem(PhysicsFolder ,Settings.Slingshot.DespawnTime)
			end
		end
	end)
	
	tool.Enabled = true
end

return Slingshot