--!strict

local StartupManager = require(script.VulcanServer.Management.StartupManager)
local ConfigSchema = require(script.VulcanServer.Management.ConfigSchema)

return function(requestedConfiguration: ConfigSchema.ConfigWithOptionals)
    StartupManager.start(requestedConfiguration)
end
