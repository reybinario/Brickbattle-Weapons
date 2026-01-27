--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local StateRepository = require(script.Parent.Parent.State.StateRepository)
local Config = require(script.Parent.Config)
local ConfigSchema = require(script.Parent.ConfigSchema)

local StateReplicator = require(script.Parent.Parent.Network.Replicator)

local StartupManager = {}


function StartupManager.start(requestedConfiguration: ConfigSchema.ConfigWithOptionals)
	print("Thank you for using Vulcan  Weapons. Setting up...")
	local mainModule = script.Parent.Parent.Parent
	local VulcanShared = createSharedFolder()
	local remoteFunctionsFolder = createRemoteFunctions()
	remoteFunctionsFolder.Parent = VulcanShared

	-- We now deliberately initialize all server modules before distributing objects.
	Config.processRequestedConfiguration(requestedConfiguration)
	Config.serveClientConfig(ReplicatedStorage:WaitForChild("VulcanShared").Remotes.AcquireConfig)
	connectPlayerEvents()
	StateRepository.serveGlobalState(ReplicatedStorage:WaitForChild("VulcanShared").Remotes.AcquireState)
	StateReplicator.setCallbacks()
	distributeObjects(mainModule)
	createPhysicsGroups()

	print("Vulcan Weapons setup completed.")
end

function connectPlayerEvents()

	-- Functions to load weapons and data for players
	local function createPlayerProjectileFolders(player: Player)
		local playerBufferFolder = Instance.new("Folder")
		playerBufferFolder.Name = player.Name
		playerBufferFolder.Parent = workspace.Projectiles.Buffers
		local playerActiveFolder = Instance.new("Folder")
		playerActiveFolder.Name = player.Name
		playerActiveFolder.Parent = workspace.Projectiles.Active
	end

	local function playerJoined(player: Player)
		createPlayerProjectileFolders(player)
		StateRepository.createPlayerState(player)
	end

	local function playerLeft(player: Player)
		StateRepository.deletePlayerState(player)
		local bufferFolder = workspace.Projectiles.Buffers[player.Name]
		if bufferFolder then
			bufferFolder:Destroy()
		end
		local activeFolder = workspace.Projectiles.Active[player.Name]
		if activeFolder then
			activeFolder:Destroy()
		end
	end

	for _, player: Player in next, Players:GetPlayers() do
		playerJoined(player)
	end
	Players.PlayerAdded:Connect(playerJoined)
	Players.PlayerRemoving:Connect(playerLeft)
end

function createSharedFolder(): Folder
	local VulcanShared = Instance.new("Folder")
	VulcanShared.Name = "VulcanShared"
	VulcanShared.Parent = ReplicatedStorage
	return VulcanShared
end

function createRemoteFunctions(): Folder
	local remoteFunctions: {string} = {
		"AcquireConfig",
		"AcquireState"
	}

	local remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"

	for _, remoteFunctionName in pairs(remoteFunctions) do
		local Remote = Instance.new("RemoteFunction")
		Remote.Name = remoteFunctionName
        Remote.Parent = remotesFolder
	end

	return remotesFolder
end

local function createProjectileFolders(): Folder
    local projectiles = Instance.new("Folder")
    projectiles.Name = "Projectiles"

    local active = Instance.new("Folder")
    active.Name = "Active"
    active.Parent = projectiles

    local buffers = Instance.new("Folder")
    buffers.Name = "Buffers"
    buffers.Parent = projectiles

    local extrapolated = Instance.new("Folder")
    extrapolated.Name = "Extrapolated"
    extrapolated.Parent = projectiles

	return projectiles
end

local function checkAndParent(obj: string, oldDirectory: Instance, newDirectory: Instance)
	local foundObj = oldDirectory:FindFirstChild(obj)
	if foundObj then
		foundObj.Parent = newDirectory
	else
		error("Could not find object" .. obj, 1)
	end
end

function distributeObjects(mainModule: ModuleScript)
	local projectilesFolder: Folder = createProjectileFolders()
	checkAndParent("VulcanDependencyChecker", mainModule, StarterGui)
	checkAndParent("VulcanClient", mainModule, game:GetService("StarterPlayer").StarterPlayerScripts)
	checkAndParent("VulcanServer", mainModule, ServerScriptService)
	mainModule.Parent = ServerScriptService.VulcanServer
	projectilesFolder.Parent = workspace

	-- Distribute checker script to ensure players have mandatory client scripts,
	-- I hate doing this more than you do.
	for _, player: Player in pairs (Players:GetPlayers()) do
		if not player:WaitForChild("PlayerGui"):FindFirstChild("VulcanDependencyChecker") then
			StarterGui.VulcanDependencyChecker:Clone().Parent = player.PlayerGui
		end
	end
end

-- Create collision groups and set their interactions
function createPhysicsGroups()
	local PhysicsTable = {
		ToolHandles = {
			PlayerParts = false,
			ToolHandles = false,
			Default = false,
		},
		Superballs = {
			PlayerParts = false,
			Superballs = false,
			Pellets = false,
			JumpyPellets = false,
		},
		JumpySuperballs = {
			JumpySuperballs = false,
			PlayerParts = true,
			Superballs = false,
			Pellets = false,
			JumpyPellets = false,
		},
		Pellets = {
			PlayerParts = false,
			JumpyPellets = false,
		},
		JumpyPellets = {
			PlayerParts = true,
		},
		Paintballs = {
			PlayerParts = false,
			Superballs = false,
			JumpySuperballs = false,
			Pellets = false,
			JumpyPellets = false,
		},
		BombJumpBombs = {},
		RideableRockets = {
			Default = false,
			Superballs = false,
			JumpySuperballs = false,
			Pellets = false,
			Paintballs = false,
			JumpyPellets = false,
		},
		PlayerParts = {
			RideableRockets = true,
			BombJumpBombs = false,
		},
	}

    -- Iterate over all groups and register them
    for group, _ in pairs(PhysicsTable) do
        -- Register each collision group
        if not PhysicsService:IsCollisionGroupRegistered(group) then
            PhysicsService:RegisterCollisionGroup(group)
        end
    end

    -- Set the interactions between the groups
    for group, interactions in pairs(PhysicsTable) do
        for otherGroup, isCollidable in pairs(interactions) do
            -- Check if both groups exist before setting collidability
            if PhysicsService:IsCollisionGroupRegistered(group) and PhysicsService:IsCollisionGroupRegistered(otherGroup) then
                PhysicsService:CollisionGroupSetCollidable(group, otherGroup, isCollidable)
            else
                warn("One or both collision groups do not exist: " .. group .. ", " .. otherGroup)
            end
        end
    end
end


return StartupManager
