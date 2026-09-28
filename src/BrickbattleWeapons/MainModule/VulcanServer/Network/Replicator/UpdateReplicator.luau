--!strict
--[[
UpdateReplicator wires superball physics updates to validation.

An accepted update refreshes server state and fans out to the other clients.
A rejected update is dropped: the ball stays born-inert and nobody else sees
the motion. The first accepted free-flight report flips the ball live -
creation replication always marks new balls inert, and only server validation
moves them out of that state.
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

        if not shot.validated then
            shot.validated = true
            NetworkServer.superballValidation.FireAll({
                count = data.count,
                player = player,
                validated = true,
            })
        end
    end)
end

return UpdateReplicator
