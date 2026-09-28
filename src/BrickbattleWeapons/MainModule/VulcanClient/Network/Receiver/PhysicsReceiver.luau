--!strict
--[[
PhysicsReceiver applies server-approved superball motion from other clients.
Only updates that passed validation are replicated, so spectators can move
the extrapolated ball without second-guessing the server.
]]
local NetworkClient = require(script.Parent.Parent.NetworkClient)
local SuperballLocator = require(script.Parent.SuperballLocator)

local PhysicsReceiver = {}

function PhysicsReceiver.setCallback()
    NetworkClient.superballReplicate.On(function(data)
        local ball = SuperballLocator.find(data.player, data.count)
        if not ball then
            return
        end
        ball.Position = data.position
        ball.AssemblyLinearVelocity = data.velocity
    end)
end

return PhysicsReceiver
