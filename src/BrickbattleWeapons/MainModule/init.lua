--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Collections = game:GetService("CollectionService")
local StarterPack = game:GetService("StarterPack")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Physics = game:GetService("PhysicsService")

local CallbacksReparented = false
local CallbacksReparented_ = Instance.new("BindableEvent")

local LOAD_PLAYER_SCRIPTS_MODULE_ID = 4710901436
local DISTRIBUTE_TO_DIRECTORIES_MODULE_ID = 4707636413

local function CreateProjectileFolders()
    local Projectiles = Instance.new("Folder")
    Projectiles.Name = "Projectiles"
    Projectiles.Parent = workspace

    local Active = Instance.new("Folder")
    Active.Name = "Active"
    Active.Parent = Projectiles

    local Buffers = Instance.new("Folder")
    Buffers.Name = "Buffers"
    Buffers.Parent = Projectiles

    local Extrapolated = Instance.new("Folder")
    Extrapolated.Name = "Extrapolated"
    Extrapolated.Parent = Projectiles
end

local function ProcessSettings(Settings: {}): {}?
	local SettingsUtilsModule = script.ServerModules.SettingsTableUtils
    local SettingsScript = script.DefaultSettings
	--local ModSettings = require(script.DefaultSettings.ModifiableSettings)
	local Directories = script.Directories
	local NewSettings = require(SettingsScript)

	if not (SettingsUtilsModule ~= nil and SettingsUtilsModule:IsA("ModuleScript")) then
		warn("Failed to override settings: SettingsTableUtils module script not found.")
		return Settings
	end

	local SettingsUtils = require(SettingsUtilsModule)
	
	SettingsUtils.OverwriteTable(NewSettings, Settings)

	--SettingsScript.Name = "BB_Settings"
	--SettingsScript.Parent = ReplicatedStorage
	
	SettingsUtils.OverwriteIncompatibleSettings(NewSettings)

    -- Return settings upon client request
	
	Directories.ReplicatedStorage.BrickbattleWeaponsShared.Remotes.AcquireSettings.OnServerInvoke = function()
		if CallbacksReparented == false then
			CallbacksReparented_.Event:Wait()
		end
		return NewSettings
	end

    return NewSettings
end

local function CreatePhysicsGroups()
    -- Set physics properties (these are all used entirely locally)
	local PhysicsTable = {
		ToolHandles = {
			PlayerParts = false;
			ToolHandles = false;
			Default = false;
		};
		Superballs = {
			PlayerParts = false;
			Superballs = false;
			Pellets = false;
			JumpyPellets = false;
		};
		JumpySuperballs = {
			JumpySuperballs = false;
			PlayerParts = true;
			Superballs = false;
			Pellets = false;
			JumpyPellets = false;
		};
		Pellets = {
			PlayerParts = false;
			JumpyPellets = false;
		};
		JumpyPellets = {
			PlayerParts = true;
		};
		Paintballs = {
			PlayerParts = false;
			Superballs = false;
			JumpySuperballs = false;
			Pellets = false;
			JumpyPellets = false;
		};
		BombJumpBombs = {};
		RideableRockets = {
			Default = false;
			Superballs = false;
			JumpySuperballs = false;
			Pellets = false;
			Paintballs = false;
			JumpyPellets = false;
		};
		PlayerParts = {
			RideableRockets = true;
			BombJumpBombs = false;
		};
	}
	
	for Group, _ in pairs(PhysicsTable) do
		Physics:RegisterCollisionGroup(Group)
	end
	
	for Group, Table in pairs(PhysicsTable) do
		for OtherGroup, Collidable in pairs(Table) do
			Physics:CollisionGroupSetCollidable(Group, OtherGroup, Collidable)
		end
	end
end

local function CreateSecurityObjects()
	local SecurityPart = Instance.new("Part")
	SecurityPart.Shape = Enum.PartType.Ball
	SecurityPart.Transparency = 1
	SecurityPart.CanCollide = false
	SecurityPart.Anchored = true
	SecurityPart.Parent = workspace
	SecurityPart.Touched:Connect(function() end)


	local SecurityDummy = Instance.new("Model")
	SecurityDummy.Name = "SecurityDummy"
    SecurityDummy.Parent = script

	local Head = Instance.new("Part")
	Head.Name = "Head"
	Head.Transparency = 1
	Head.Size = Vector3.new(2, 1, 1)
	Head.Position = Vector3.new(-374, 4.5, 89.5)
	Head.CanCollide = false
    Head.Anchored = true
	Head.Parent = SecurityDummy

	local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
	BodyAngularVelocity.AngularVelocity = Vector3.new(0, 2, 0)
	BodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
	BodyAngularVelocity.P = 1250
	BodyAngularVelocity.Parent = Head

	local HumanoidRootPart = Instance.new("Part")
	HumanoidRootPart.Name = "HumanoidRootPart"
	HumanoidRootPart.Transparency = 1
	HumanoidRootPart.Size = Vector3.new(2, 2, 1)
	HumanoidRootPart.Position = Vector3.new(-374, 3, 89.5)
	HumanoidRootPart.CanCollide = false
    HumanoidRootPart.Anchored = true
	HumanoidRootPart.Parent = SecurityDummy

	local Torso = Instance.new("Part")
	Torso.Name = "Torso"
	Torso.Transparency = 1
	Torso.Size = Vector3.new(2, 2, 1)
	Torso.Position = Vector3.new(-374, 3, 89.5)
	Torso.CanCollide = false
    Torso.Anchored = true
	Torso.Parent = SecurityDummy

	local RightLeg = Instance.new("Part")
	RightLeg.Name = "Right Leg"
	RightLeg.Transparency = 1
	RightLeg.Size = Vector3.new(1, 2, 1)
	RightLeg.Position = Vector3.new(-373.5, 1, 89.5)
	RightLeg.CanCollide = false
    RightLeg.Anchored = true
	RightLeg.Parent = SecurityDummy

	local LeftLeg = Instance.new("Part")
	LeftLeg.Name = "Left Leg"
	LeftLeg.Transparency = 1
	LeftLeg.Size = Vector3.new(1, 2, 1)
	LeftLeg.Position = Vector3.new(-374.5, 1, 89.5)
	LeftLeg.CanCollide = false
    LeftLeg.Anchored = true
	LeftLeg.Parent = SecurityDummy

	local RightArm = Instance.new("Part")
	RightArm.Name = "Right Arm"
	RightArm.Transparency = 1
	RightArm.Size = Vector3.new(1, 2, 1)
	RightArm.Position = Vector3.new(-372.5, 3, 89.5)
	RightArm.CanCollide = false
    RightArm.Anchored = true
	RightArm.Parent = SecurityDummy

	local LeftArm = Instance.new("Part")
	LeftArm.Name = "Right Arm"
	LeftArm.Transparency = 1
	LeftArm.Size = Vector3.new(1, 2, 1)
	LeftArm.Position = Vector3.new(-375.5, 3, 89.5)
	LeftArm.CanCollide = false
    LeftArm.Anchored = true
	LeftArm.Parent = SecurityDummy

	return SecurityPart, SecurityDummy
end

local function CreateRemotes()
	local RemoteMap: {[string]: string} = {
		AcquireSettings = "RemoteFunction",
		Debug = "RemoteEvent",
		Delete = "RemoteEvent",
		Explosion = "RemoteEvent",
		Hit = "RemoteEvent",
		Ping = "RemoteEvent",
		ReplicateThemes = "RemoteEvent",
		ThemeActivation = "BindableEvent",
		UpdatePhysics = "UnreliableRemoteEvent"
	}

	local RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = script.Directories.ReplicatedStorage.BrickbattleWeaponsShared

	for RemoteName, RemoteType in pairs(RemoteMap) do
		local Remote = Instance.new(RemoteType)
		Remote.Name = RemoteName
        Remote.Parent = RemotesFolder
	end
end

local function CreateServerTimeValue(Shared: Folder)
	local ServerTime = Instance.new("NumberValue")
	ServerTime.Name = "SERVER_TIME"
	ServerTime.Parent = Shared
	return ServerTime
end

local function ConstructGlobalContext(NewSettings: {})

	local Shared = game.ReplicatedStorage.BrickbattleWeaponsShared

	local CreatedSecurityPart, CreatedSecurityDummy = CreateSecurityObjects()
	
	local GlobalTable = {}

	local Modules: Folder = Shared.Modules
	local ServerModules: Folder = script.ServerModules
	local Remotes: Folder = Shared.Remotes
	local ProjectileFolder: Folder = workspace.Projectiles
	local ServerTime: NumberValue = CreateServerTimeValue(Shared)
	local LoadModule: (Tool: Tool, Buffers: Folder, Player: Player, Character: Model) -> () = nil
	local SetUpCharacter: (Player: Player, Character: Model) -> () = nil
	local SecurityPart: Part = CreatedSecurityPart
	local SecurityDummy: Model = CreatedSecurityDummy

	-- Construct global table
	GlobalTable.Settings = NewSettings
	GlobalTable.Modules = Modules
	GlobalTable.ServerModules = ServerModules
	GlobalTable.Remotes = Remotes
	GlobalTable.ProjectileFolder = ProjectileFolder
	GlobalTable.MasterTimeTable = {}
	GlobalTable.ProjectileCounts = {}
	GlobalTable.ServerTime = ServerTime
	GlobalTable.LoadModule = LoadModule
	GlobalTable.SetUpCharacter = SetUpCharacter
	GlobalTable.SecurityPart = SecurityPart
	GlobalTable.SecurityDummy = SecurityDummy

	return GlobalTable
end

local function DistributeThemePacks(NewSettings: any)
    local themes = script.Directories.ReplicatedStorage.BrickbattleWeaponsShared.Themes
	for _, Module in pairs(NewSettings.Themes.ThemePacks) do
		if not Module:IsA("ModuleScript") then
			warn("Theme pack set as something other than ModuleScript")
			continue
		end
		local ThemePack = require(Module)
		if type(ThemePack) == "userdata" then
			if ThemePack:IsA("Folder") then
				for _, Theme in pairs(ThemePack:GetChildren()) do
					if Theme:IsA("Folder") then
						local current = themes:FindFirstChild(Theme.Name)
						if current then
							warn("Theme with same name found, overriding:", current)
							pcall(game.Destroy, current)
						end

						Theme.Parent = themes
					else
						warn("Theme inside themepack must be a folder, not adding:", Theme)
					end
				end
			else
				warn("Improper class for themepack: class must be a folder")
			end
		else
			warn("Improper type for themepack: type() must return userdata (folder)")
		end
	end
end

local function ApplyWeaponDirectoryConfigurations(NewSettings: any)
	-- Remove filtered weapons
	for _, Tool in pairs(script.Directories.StarterPack:GetChildren()) do
		local Tool_Filtered = table.find(NewSettings.WeaponsFiltered, Tool.Name) ~= nil
		if Tool_Filtered ~= NewSettings.WeaponsFilterType then
			Tool.Parent = ServerStorage
		end
	end

	-- If existent, parent weapons to custom directory
	if NewSettings.CustomWeaponsDirectory then
		for _,Tool in pairs(script.Directories.StarterPack:GetChildren()) do
			Tool.Parent = NewSettings.CustomWeaponsDirectory
		end
		script.Directories.StarterPack:Destroy()
	end
end

local function DistributeToGameDirectories(NewSettings: any)

	-- Distribute objects
	require(DISTRIBUTE_TO_DIRECTORIES_MODULE_ID)(script.Directories)

	-- Handle callbacks
	local Callbacks = script.DefaultSettings:WaitForChild("Callbacks")
	Callbacks.Parent = ReplicatedStorage.BrickbattleWeaponsShared.Modules

	local approved = {}
	for name, module in pairs(NewSettings.Callbacks) do
		if typeof(module) == "Instance" 
			and module:IsA("ModuleScript") 
			and type(require(module)) == "function" then
			table.insert(approved, module)
			module.Name = name
			module.Parent = Callbacks
		end
	end

	for _, child in pairs (Callbacks:GetChildren()) do
		if not table.find(approved, child) then
			child:Destroy() -- delete unnecessary extrenuous modules
		end
	end

	CallbacksReparented = true
	CallbacksReparented_:Fire()
	game:GetService("Debris"):AddItem(CallbacksReparented_, 0)

	-- Distribute checker script to ensure players have mandatory client scripts
	for _, Player in pairs (Players:GetPlayers()) do
		if not Player:WaitForChild("PlayerGui"):FindFirstChild("Checker") then
			StarterGui.Checker:Clone().Parent = Player.PlayerGui
		end
	end
end

local function HookUpPlayerEvents(Context)

	-- Functions to load weapons and data for players	
	local function CreatePlayerProjectileFolders(Player: Player)
		local PlayerBufferFolder = Instance.new("Folder")
		PlayerBufferFolder.Name = Player.Name
		PlayerBufferFolder.Parent = workspace.Projectiles.Buffers
		local PlayerActiveFolder = Instance.new("Folder")
		PlayerActiveFolder.Name = Player.Name
		PlayerActiveFolder.Parent = workspace.Projectiles.Active
	end

	local function AddBufferValues(Player: Player)
		local Buffers = Player:FindFirstChild("Buffers")
		if not Buffers then
			local BuffersFolder = Instance.new("Folder")
			BuffersFolder.Name = "Buffers"
            BuffersFolder.Parent = Player
		end
	end

	local function LoadModule(Tool: Tool , Buffers: Folder, Player: Player, Character: Model)
		local ServerFolder = Tool:WaitForChild("Server",1)
		local ServerModule = ServerFolder and ServerFolder:FindFirstChildWhichIsA("ModuleScript")
		if ServerModule then
			--print("Initializing:",Tool.Name,"| For:",Player.Name)
			require(ServerModule):Init(Context.Settings, ReplicatedStorage, Buffers, Player, Character, workspace.Projectiles)
		end
	end
	
	local function AddCharacter(Player: Player, Character: Model)	
		local Buffers = Player:WaitForChild("Buffers")

		if not Buffers:IsA("Folder") then
			return
		end
		--[[if not Character then
			return
		end]]
		
		if not Collections:HasTag(Character, "ToolsLoaded") then
			local Backpack = Player:WaitForChild("Backpack")
			Collections:AddTag(Character, "ToolsLoaded")
			
			-- Ensure player has weapons
			local spawnedWithout = 0
			if not Context.Settings.CustomWeaponsDirectory then
				for _, tool in pairs (StarterPack:GetChildren()) do
					if not Backpack:FindFirstChild(tool.Name) then
						spawnedWithout += 1
						tool:Clone().Parent = Backpack
					end
				end
			end
			
			--if spawnedWithout > 0 then
				--print(Player.Name.." spawned without", spawnedWithout, "tools.")
			--end
			
			-- Load weapon
			for _,Tool in pairs(Backpack:GetChildren()) do
				if Tool:IsA("Tool") then
                    task.spawn(LoadModule, Tool, Buffers, Player, Character)
                end
			end
		end
	end

	local function AddPlayer(Player: Player)
		local weaponData = {
			Superball = {
				Count = 0,
				LastUsed = 0,
				ActiveObjects = {}
			},
			Sword = {
				LastUsed = 0
			},
			Slingshot = {
				Count = 0,
				LastUsed = 0,
				ActiveObjects = {}
			},
			Bomb = {
				Count = 0,
				LastUsed = 0,
				ActiveObjects = {}
			},
			Trowel = {
				Count = 0,
				LastUsed = 0,
				ActiveObjects = {}
			},
			Rocket = {
				Count = 0,
				LastUsed = 0,
				ActiveObjects = {}
			},
			Paintball = {
				Count = 0,
				LastUsed = 0,
				ActiveObjects = {}
			},
		}

		Context.MasterTimeTable[Player.Name] = {}
		Context.WeaponData[Player.Name] = weaponData

		local Theme = Instance.new("StringValue")
		Theme.Name = "Theme"
		Theme.Value = "Normal"
		Theme.Parent = Player
		task.spawn(CreatePlayerProjectileFolders, Player)
		task.spawn(AddBufferValues, Player)
	end
	
	local function RemovePlayer(Player: Player)
		local PlayerBufferFolder = workspace.Projectiles.Buffers:WaitForChild(Player.Name, 1)
		local PlayerActiveFolder = workspace.Projectiles.Active:WaitForChild(Player.Name, 1)
		if PlayerBufferFolder then
			PlayerBufferFolder:Destroy()
		end
		if PlayerActiveFolder then
			PlayerActiveFolder:Destroy()
		end
		Context.ProjectileCounts[Player.Name] = nil
	end

	-- Load player modules
	local addConn, removeConn, charConns = require(LOAD_PLAYER_SCRIPTS_MODULE_ID)(AddPlayer, RemovePlayer, AddCharacter)

	Context.LoadModule = LoadModule
	Context.SetUpCharacter = AddCharacter
end

function Load(Settings: any)
	
	CreateRemotes()
	local NewSettings = ProcessSettings(Settings)
	DistributeThemePacks(NewSettings)
	CreatePhysicsGroups()
	CreateProjectileFolders()
	DistributeToGameDirectories(NewSettings)
	local Context = ConstructGlobalContext(NewSettings)
	ApplyWeaponDirectoryConfigurations(NewSettings)
	HookUpPlayerEvents(Context)

	print(Context)

	-- Initialize & hook up remotes
	require(Context.ServerModules.ExplosionServer).init(Context)
	require(Context.ServerModules.HitServer).init(Context)
	require(Context.Modules.Security).init(Context)
	require(Context.ServerModules.CustomPhysicsReplicator).init(Context)
	
	--script.Parent = game:GetService("ServerScriptService")
end

return Load

--[[
	Under _G.BB (Server):
	- Settings: The default settings that were overriden by the requirer's changes
	- Modules: Directory of the modules used by the toolset
	- Remotes: Directory of the remotes used by the toolset
	- ProjectileFolder: Directory of the projectiles (would be physics folders from server's POV)
	- ServerTime: Number value that holds the last tick of the last heartbeat
	- MasterTimeTable: Dictionary that CFrames of chracters every heartbeat when PSPV is on
	- ProjectileCounts: Dictionary with tool names as keys and the fire count as values
	- InitializeServer: A function that ensures the player has the necessary weapons and loads their server modules
	- LoadModule: A function that loads the server modules of a specific weapon
]]