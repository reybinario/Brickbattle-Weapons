--!strict

local CreationReplicator = require(script.CreationReplicator)
local UpdateReplicator = require(script.UpdateReplicator)

local Replicator = {}


function Replicator.setCallbacks()
    CreationReplicator.setCallback()
    UpdateReplicator.setCallback()
end

return Replicator
