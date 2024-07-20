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
            -- validate position (except trowel)
            -- validate count
            -- validate timestamp (workspace:GetServerTimeFromNow())
            -- validate character + tool (char must exist and tool should be a descendant of character)
            -- validate humanoid
            -- validate forcefield
    
            if not ValidationUtils.validateCount(Context, player, data, brickBattleObject) then
                return
            end
    
            Context.WeaponData[player.Name][brickBattleObject].Count = data.count
    
            if not ValidationUtils.validateReloadTime(Context, player, data, brickBattleObject) then
                return
            end

            Context.WeaponData[player.Name][brickBattleObject].LastUsed = workspace:GetServerTimeNow()

            -- Only rocket sends cframe
            local positionalDataKey = brickBattleObject == "Rocket" and "cFrame" or "position"
        
            -- Trowel walls are not technically extrapolated
            if brickBattleObject ~= "Trowel" then
                NetworkServer[replicate].FireExcept(player, {data.count, player.UserId, data[positionalDataKey]})
            else
                
            end
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