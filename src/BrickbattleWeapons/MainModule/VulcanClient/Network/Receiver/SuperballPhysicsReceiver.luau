--!strict
--[[
SuperballPhysicsReceiver applies server-approved superball motion from other
clients. Only updates that passed validation are replicated, so spectators can
move the extrapolated ball without second-guessing the server.

One physics receiver per projectile type: motion rules differ per weapon
(a superball ricochets, a rocket does not), so each type gets its own
receiver. Shared lookups live in ProjectileLocator.
]]
local NetworkClient = require(script.Parent.Parent.NetworkClient)
local ProjectileLocator = require(script.Parent.ProjectileLocator)

local SuperballPhysicsReceiver = {}

function SuperballPhysicsReceiver.setCallback()
    NetworkClient.superballReplicate.On(function(data)
        local ball = ProjectileLocator.find(data.player, "Superball", data.count)
        if not ball then
            return
        end
        ball.Position = data.position
        ball.AssemblyLinearVelocity = data.velocity
    end)
end

return SuperballPhysicsReceiver
