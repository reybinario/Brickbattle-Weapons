--!strict
local VulcanShared: Folder = game:GetService("ReplicatedStorage").VulcanShared
local Remotes: Folder = VulcanShared.Remotes
local AcquireConfig: RemoteFunction = Remotes.AcquireConfig
local ConfigSchema = require(script.Parent.ConfigSchema)

local ClientConfig = {}

local config: ConfigSchema.Config = {}

function ClientConfig.acquireConfiguration()
    config = AcquireConfig:InvokeServer()
end

function ClientConfig.get(): ConfigSchema.Config
    return config
end

return ClientConfig