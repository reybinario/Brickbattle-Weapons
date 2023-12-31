--!strict
local Bomb = {}

local tool = script.Parent.Parent;

local handle = tool:WaitForChild("Handle")
local TickSound = handle:WaitForChild("Tick")
local BoomSound = handle:WaitForChild("Boom")

local UpdateEvent = tool:WaitForChild("Update")

local Players = game:GetService("Players");
local Collections = game:GetService("CollectionService");
local Physics = game:GetService("PhysicsService")

function Bomb:CreatePhysicsFolder(count)
	--_G.BB.ProjectileCounts[self.Player.Name].Bombs += 1
	
	local PhysicsFolder = Instance.new("Folder")
		
	PhysicsFolder.Name = "Bomb".._G.BB.ProjectileCounts[self.Player.Name].Bombs
	PhysicsFolder.Name = "Bomb"..count
	local new_tag = Instance.new("ObjectValue")
	new_tag.Name = ("creator")
	new_tag.Value = self.Player
	new_tag.Parent = PhysicsFolder
	
	
	local projType = Instance.new("StringValue")
	projType.Name = "ProjectileType"
	projType.Value = "Bomb"
	projType.Parent = PhysicsFolder
	
	local Exploded = Instance.new("BoolValue")
	Exploded.Name = ("Exploded")
	Exploded.Value = false;
	Exploded.Parent = PhysicsFolder;
	
	local LastUpdateTick = Instance.new("NumberValue")
	LastUpdateTick.Name = "LastUpdateTick"
	LastUpdateTick.Parent = PhysicsFolder
	
	local ID = Instance.new("StringValue")
	ID.Name = "UniqueID"
	ID.Value = PhysicsFolder.Name.._G.BB.ProjectileCounts[self.Player.Name].Bombs
	ID.Parent = PhysicsFolder
	
	local ThemeTag = Instance.new("StringValue")
	ThemeTag.Name = "Theme"
	ThemeTag.Value = self.Aesthetics:DetermineTheme(self.Player)
	ThemeTag.Parent = PhysicsFolder
	
	local realCF = Instance.new("Vector3Value")
	realCF.Name = "LatestPosition"
	realCF.Parent = PhysicsFolder
	
	local LastCF = Instance.new("Vector3Value")
	LastCF.Name = "LastSentPosition"
	LastCF.Parent = PhysicsFolder
	
	local realVel = Instance.new("Vector3Value")
	realVel.Name = "LatestVelocity"
	realVel.Parent = PhysicsFolder
	
	--You need this because clocks aren't synchronized. Can't use a global timestamp.
	--Bwuh bwuh bwuh why don't you synchronize the clocks? Well why don't YOU do it lole
	local realFT = Instance.new("NumberValue")
	realFT.Name = "LatestTime"
	realFT.Value = 0
	realFT.Parent = PhysicsFolder
	
	local realOT = Instance.new("NumberValue")
	realOT.Name = "LocalOriginTime"
	realOT.Value = 0
	realOT.Parent = PhysicsFolder
	
	local ActiveTag = Instance.new("BoolValue")
	ActiveTag.Name = ("Active")
	ActiveTag.Value = false
	ActiveTag.Parent = PhysicsFolder;
	
	local AssignedTouch = Instance.new("BoolValue")
	AssignedTouch.Name = ("BlownUpClient")
	AssignedTouch.Value = false
	AssignedTouch.Parent = PhysicsFolder;
	
	-- Add sounds
	TickSound:Clone().Parent = PhysicsFolder
	BoomSound:Clone().Parent = PhysicsFolder
	
	return PhysicsFolder
end

function Bomb:Init(Settings,Modules,Buffers,Player,Character,Folder)
	self.Settings = Settings
	
	local Security = require(Modules:WaitForChild("Security"))

	self.Aesthetics = require(Modules:WaitForChild("Aesthetics"))
	
	local ActiveFolder = Folder:WaitForChild("Active"):WaitForChild(Player.Name)
	
	self.Player = Player
	
	-- First activation must always work even if time() returns 0.
	local lastActivation = -5;	
	UpdateEvent.OnServerEvent:Connect(function(playerFired, initCF, initVel, initClientTime, count)
		local now = tick()
		local LenientReloadTime = math.max(Settings.Bomb.ReloadTime - 1, Settings.Bomb.ReloadTime * .6)
		
		if playerFired == Player and (now - lastActivation) > LenientReloadTime then
			if Player.Character and Player.Character.Parent and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
				lastActivation = now
				
				local PhysicsFolder = self:CreatePhysicsFolder(count)
				
				PhysicsFolder.LatestPosition.Value = initCF.Position
				PhysicsFolder.LatestVelocity.Value = initVel
				PhysicsFolder.LatestTime.Value = 0
				
				PhysicsFolder.LocalOriginTime.Value = initClientTime
				PhysicsFolder.LastUpdateTick.Value = now
				
				PhysicsFolder.Active.Value = true

				
				if Security:ApproveInit(PhysicsFolder) then
					PhysicsFolder.Parent = ActiveFolder
				end

				local function ForceExplode()
					if PhysicsFolder.Parent
						and PhysicsFolder.Active.Value then
						
						--print("Forced explosion for:",PhysicsFolder.UniqueID.Value)
						
						PhysicsFolder.Active.Value = false
						game:GetService("Debris"):AddItem(PhysicsFolder, 0)
					end
				end
				task.delay(Settings.Bomb.DespawnTime, ForceExplode)
			end
		end	
	end)
	tool.Enabled = true
	
end

return Bomb