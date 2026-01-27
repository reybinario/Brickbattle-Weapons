--!strict

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local VulcanClient = script.Parent.Parent
local SuperballCreator = require(VulcanClient.Projectile.ProjectileCreator.SuperballCreator)
local Config = require(VulcanClient.Management.ClientConfig)
local NetworkClient = require(script.Parent.Parent.Network.NetworkClient)

local config = Config.get()

local ToolActivator = {}

local sbs = 0 

function ToolActivator.fireSuperball(hit: BasePart?, endPosition: Vector3)
    local superball = SuperballCreator.create(Players.LocalPlayer)
    local head: Part = Players.LocalPlayer.Character.PrimaryPart
	
	local spawnPosition = head.Position + (endPosition - head.Position).Unit * config.Superball.ProjectileConfig.SpawnDistance
	local launchCframe = CFrame.new(spawnPosition, endPosition)
	local velocity = launchCframe.LookVector * config.Superball.ProjectileConfig.Speed
	
	superball.CFrame = launchCframe
	superball.AssemblyLinearVelocity = velocity
	superball.Parent = workspace

    NetworkClient.superballCreate.Fire({
        color = Vector3.new(superball.Color.R, superball.Color.G, superball.Color.B),
        count = sbs,
        position = superball.Position,
        velocity = superball.AssemblyLinearVelocity,
    })
    sbs = sbs + 1

    -- TODO:
    -- tell client projectile registry that we created and fired a superball
    -- shoot inside bricks logic
    -- after a while, return superball to part cache
    -- play sound
    -- handle hit detection
    -- parent to active folder
end

function ToolActivator.activateTool(tool: Tool, hit: BasePart?, endPosition: Vector3)
    if RunService:IsStudio() then
        doDebugStuff(tool, hit, endPosition)
    end
    ToolActivator.fireSuperball(hit, endPosition)
end

function doDebugStuff(tool: Tool, hit: BasePart?, endPosition: Vector3)
    print("Activating", tool, hit, endPosition)
    local x = Instance.new("Part")
    x.Size = Vector3.new(1, 1, 1)
    x.Anchored = true
    x.Color = Color3.fromRGB(255, 0, 0)
    x.Position = endPosition
    x.Parent = workspace
end

return ToolActivator