--!strict
local Rocket = {}

local tool = script.Parent.Parent;
local handle = tool:WaitForChild("Handle")
local UpdateEvent = tool:WaitForChild("Update");
local boom = handle:WaitForChild("Boom");
local swoosh = handle:WaitForChild("Swoosh");

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Collections = game:GetService("CollectionService")

function Rocket:CreatePhysicsFolder(count)
	--_G.BB.ProjectileCounts[self.Player.Name].Rockets += 1

	local PhysicsFolder = Instance.new("Folder")
	--PhysicsFolder.Name = "Rocket".._G.BB.ProjectileCounts[self.Player.Name].Rockets
	PhysicsFolder.Name = "Rocket"..count
	
	local ThemeTag = Instance.new("StringValue")
	ThemeTag.Name = "Theme"
	ThemeTag.Value = self.Aesthetics:DetermineTheme(self.Player)
	ThemeTag.Parent = PhysicsFolder
	
	local newTag = Instance.new("ObjectValue")
	newTag.Name = "creator"
	newTag.Value = self.Player
	newTag.Parent = PhysicsFolder
	
	local Active = Instance.new("BoolValue");
	Active.Name = "Active"
	Active.Value = true
	Active.Parent = PhysicsFolder
	
	local Exploded = Instance.new("BoolValue")
	Exploded.Name = "Exploded"
	Exploded.Value = false
	Exploded.Parent = PhysicsFolder
	
	local projType = Instance.new("StringValue")
	projType.Name = "ProjectileType"
	projType.Value = "Rocket"
	projType.Parent = PhysicsFolder
	
	local LastUpdateTick = Instance.new("NumberValue")
	LastUpdateTick.Name = "LastUpdateTick"
	LastUpdateTick.Parent = PhysicsFolder
	
	local cf = Instance.new("CFrameValue")
	cf.Name = "Origin"
	cf.Parent = PhysicsFolder
	
	local rdist = Instance.new("NumberValue")
	rdist.Name = "LatestDistance"
	rdist.Parent = PhysicsFolder

	--local rvel = Instance.new("Vector3Value")
	--rvel.Name = "LatestVelocity"
	--rvel.Parent = PhysicsFolder
	
	local st = Instance.new("NumberValue")
	st.Name = "ClientTime"
	st.Parent = PhysicsFolder
	
	local mt = Instance.new("NumberValue")
	mt.Name = "ServerTime"
	mt.Parent = PhysicsFolder

	local ID = Instance.new("StringValue")
	ID.Name = "UniqueID"
	ID.Value = PhysicsFolder.Name.._G.BB.ProjectileCounts[self.Player.Name].Rockets
	ID.Parent = PhysicsFolder
	
	-- Add the "shoosh" and "boom"
	boom:Clone().Parent = PhysicsFolder
	swoosh:Clone().Parent = PhysicsFolder
	
	return PhysicsFolder
end

function Rocket:Init(Settings,Modules,Buffers,Player,Character,Folder)
	self.Aesthetics = require(Modules:WaitForChild("Aesthetics"))
	self.Player = Player
	self.Character = Character
	
	local Security = require(Modules:WaitForChild("Security"))
	
	local ActiveFolder = Folder:WaitForChild("Active"):WaitForChild(Player.Name)
	
	local lastActivation = -10;
	UpdateEvent.OnServerEvent:connect(function(playerFired, initCF, clientTime, count)
		local now = tick()
		local LenientReloadTime = math.max(Settings.Rocket.ReloadTime - 1, Settings.Rocket.ReloadTime * .6)
		if playerFired == Player and (now - lastActivation) > LenientReloadTime then
			if Player.Character and Player.Character.Parent and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
				lastActivation = now;

				local PhysicsFolder = self:CreatePhysicsFolder(count)
				
				-- Begin replication
				PhysicsFolder.ServerTime.Value = _G.BB.ServerTime.Value
				PhysicsFolder.ClientTime.Value = clientTime
				PhysicsFolder.Origin.Value = initCF
				PhysicsFolder.LatestDistance.Value = 0
				PhysicsFolder.LastUpdateTick.Value = now
				
				if Security:ApproveInit(PhysicsFolder, handle) then
					PhysicsFolder.Parent = ActiveFolder
				end
		
				-- Clean up and prepare for next rocket
				Debris:AddItem(PhysicsFolder, Settings.Rocket.DespawnTime)
			end
		end
	end)
	tool.Enabled = true
end

return Rocket