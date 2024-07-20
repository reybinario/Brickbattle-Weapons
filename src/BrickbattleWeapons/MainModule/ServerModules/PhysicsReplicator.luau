--!strict
local PhysicsReplicator = {}

local NetworkServer = require(script.Parent.NetworkServer)
local ValidationUtils = require(script.Parent.ValidationUtils)

local createdProjectiles = {"Bomb", "Paintball", "Rocket", "Slingshot", "Superball", "Trowel"}

local function replicateCreations(Context)

    for projectile in createdProjectiles do
        local create = string.lower(projectile) + "Create"
        local replicate = create + "Replicate"

        NetworkServer[create].SetCallback(function(player, data)
            -- validate reload time
            -- validate position
            -- validate count
    
            if not ValidationUtils.validateCount(Context, player, data, projectile) then
                return
            end
    
            Context.WeaponData[player.Name][projectile].Count = data.count
    
            if not ValidationUtils.validateReloadTime(Context, player, data, projectile) then
                return
            end

            Context.WeaponData[player.Name][projectile].LastUsed = time()
    
            -- validate position
    
            NetworkServer[replicate].FireExcept(player, {data.count, player.UserId, data.position})
        end)
    end
end

local function replicatePhysicsUpdates(Context)

end

function PhysicsReplicator.beginReplication(Context)
    replicateCreations(Context)
    replicatePhysicsUpdates(Context)
    -- replicate physics updates
    -- replicate hits
    -- replicate explosions
    -- replicate deletes
    return ''
end

return PhysicsReplicator