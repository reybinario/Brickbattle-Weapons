--!strict
local PhysicsReplicator = {}

local NetworkServer = require(script.Parent.NetworkServer)

local function replicatePhysicsUpdates(Context)

    NetworkServer.bombCreate.SetCallback(function(player, data) 
        NetworkServer.bombCreateReplicate.FireExcept(player, data)
    end)

end

function PhysicsReplicator.beginReplication(Context)
    replicatePhysicsUpdates(Context)
    -- replicate physics updates
    -- replicate hits
    -- replicate explosions
    -- replicate deletes
    return ''
end

return PhysicsReplicator