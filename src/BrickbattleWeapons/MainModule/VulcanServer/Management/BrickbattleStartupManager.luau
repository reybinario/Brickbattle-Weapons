--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local BrickbattleStateCache = require(script.Parent.Parent.State.BrickbattleStateCache)
local BrickbattleConfig = require(script.Parent.Parent.Config.BrickbattleConfig)
local BrickbattleStateReplicator = require(script.Parent.Parent.Network.BrickbattleReplicator)

local BrickbattleStartupManager = {}

function BrickbattleStartupManager.start(requestedConfiguration: BrickbattleConfig.BrickbattleConfigWithOptionals, mainModule: ModuleScript)
	print("Thank you for using Vulcan Brickbattle Weapons. Setting up...")

	BrickbattleConfig.processRequestedConfiguration(requestedConfiguration)
	distributeObjects(mainModule)
	BrickbattleConfig.serveClientConfig(ReplicatedStorage.VulcanShared.Remotes.AcquireConfig)
	connectPlayerEvents()
	BrickbattleStateCache.serveGlobalBrickbattleState(ReplicatedStorage.VulcanShared.Remotes.AcquireBrickbattleState)
	BrickbattleStateReplicator.setCallacks()
	createPhysicsGroups()

	print("Vulcan Brickbattle Weapons setup completed.")
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
		BrickbattleStateCache.createStateForPlayer(player)
	end

	local function playerLeft(player: Player)
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

local function createRemoteFunctions(): Folder
	local remoteFunctions: {string} = {
		"AcquireConfig",
		"AcquireBrickbattleState"
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

function distributeObjects(mainModule: ModuleScript)

	local remoteFunctionsFolder: Folder = createRemoteFunctions()
	local projectilesFolder: Folder = createProjectileFolders()

	mainModule.VulcanDependencyChecker.Parent = StarterGui
	mainModule.VulcanClient.Parent = game:GetService("StarterPlayer").StarterPlayerScripts
	mainModule.VulcanShared.Parent = ReplicatedStorage
	mainModule.VulcanServer.Parent = ServerScriptService
	mainModule.Parent = ServerScriptService.VulcanServer
	remoteFunctionsFolder.Parent = ReplicatedStorage.VulcanShared
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


return BrickbattleStartupManager
