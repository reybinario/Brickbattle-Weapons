--!strict
--[[
UpdateReplicator wires superball physics updates to validation.

Validation is silent. An accepted update refreshes server state and fans out
to the other clients; a rejected update is dropped and its motion is never
replicated. No verdict is sent to any client: the firing client keeps its own
smooth view either way, and the only consequence of failing validation is
that effects never happen (damage and explosion authority are later slices).
]]
local Network = script.Parent.Parent
local VulcanServer = Network.Parent

local NetworkServer = require(Network.NetworkServer)
local StateRepository = require(VulcanServer.State.StateRepository)
local UpdateValidator = require(VulcanServer.Validation.UpdateValidator)

local UpdateReplicator = {}

function UpdateReplicator.setCallback()
    NetworkServer.superballUpdate.On(function(player, data)
        local valid, shot, id = UpdateValidator.validateSuperballUpdate(player, data)
        if not valid or shot == nil then
            return
        end

        shot.position = data.position
        shot.velocity = data.velocity
        shot.timestamp = workspace:GetServerTimeNow()
        StateRepository.updateProjectileState(player, "Superball", id, shot)

        NetworkServer.superballReplicate.FireExcept(player, {
            count = data.count,
            packetCount = data.packetCount,
            player = player,
            position = data.position,
            velocity = data.velocity,
        })
    end)
end

return UpdateReplicator
