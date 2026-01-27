--!strict
local DependencyUtils = require(script.Parent.DependencyUtils)
local ConfigSchema = require(script.Parent.ConfigSchema)

local AcquireConfig = DependencyUtils.getRemotes().AcquireConfig

local ClientConfig = {}
local config: ConfigSchema.Config
local initialized = false

function ClientConfig.acquireConfiguration()
    config = AcquireConfig:InvokeServer()
    initialized = true
end

function ClientConfig.get(): ConfigSchema.Config
    if not initialized then
        ClientConfig.acquireConfiguration()
    end
    return config
end

return ClientConfig