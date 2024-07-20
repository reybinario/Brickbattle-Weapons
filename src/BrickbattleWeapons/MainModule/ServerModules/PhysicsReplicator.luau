--!strict
local PhysicsReplicator = {}

local NetworkServer = require(script.Parent.NetworkServer)
local ValidationUtils = require(script.Parent.ValidationUtils)

local brickBattleObjects = {"Bomb", "Paintball", "Rocket", "Slingshot", "Superball", "Trowel"}

local function replicateCreations(Context)

    for brickBattleObject in brickBattleObjects do
        local create = string.lower(brickBattleObject) + "Create"
        local replicate = create + "Replicate"

        NetworkServer[create].SetCallback(function(player, data)
            -- validate reload time
            -- validate position
            -- validate count
    
            if not ValidationUtils.validateCount(Context, player, data, brickBattleObject) then
                return
            end
    
            Context.WeaponData[player.Name][brickBattleObject].Count = data.count
    
            if not ValidationUtils.validateReloadTime(Context, player, data, brickBattleObject) then
                return
            end

            Context.WeaponData[player.Name][brickBattleObject].LastUsed = time()
        
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