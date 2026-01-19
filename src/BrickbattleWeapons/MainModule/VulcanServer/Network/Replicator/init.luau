--!strict

local CreationReplicator = require(script.CreationReplicator)

local Replicator = {}


function Replicator.setCallbacks()
    CreationReplicator.setCallback()
end

return Replicator