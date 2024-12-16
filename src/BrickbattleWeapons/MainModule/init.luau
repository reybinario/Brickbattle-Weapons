--!strict

local BrickbattleStartupManager = require(script.VulcanServer.Management.BrickbattleStartupManager)
local BrickbattleConfig = require(script.VulcanServer.Config.BrickbattleConfig)

return function(requestedConfiguration: BrickbattleConfig.BrickbattleConfigWithOptionals)
    BrickbattleStartupManager.start(requestedConfiguration, script)
end
