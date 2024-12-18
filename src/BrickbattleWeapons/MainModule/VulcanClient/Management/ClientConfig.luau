--!strict
local VulcanShared: Folder = game:GetService("ReplicatedStorage").VulcanShared
local Remotes: Folder = VulcanShared.Remotes
local AcquireConfig: RemoteFunction = Remotes.AcquireConfig
local ConfigSchema = require(script.Parent.ConfigSchema)

local ClientConfig = {}
ClientConfig.__index = ClientConfig

function ClientConfig.new()
	return setmetatable({
		config = nil;
		initialized = false;
	}, ClientConfig)
end

function ClientConfig:AcquireConfiguration()
    print("acquiring")
    self.config = AcquireConfig:InvokeServer()
    self.initialized = true
end

function ClientConfig:Get(): ConfigSchema.Config
    if self.initialized == false then
        self:AcquireConfiguration()
    end
    return self.config
end

local singleton = ClientConfig.new()
return singleton