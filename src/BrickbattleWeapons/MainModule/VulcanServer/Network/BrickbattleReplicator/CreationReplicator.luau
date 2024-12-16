--!strict
local BrickbattleStateReplicator = {}

local NetworkServer = require(script.Parent.NetworkServer)
local BrickbattleStateValidator = require(script.Parent.BrickbattleStateValidator)
local BrickbattleStateCache = require(script.Parent.BrickbattleStateCache)
local BrickbattleObjects = require(script.Parent.BrickbattleObjects)

-- Validates data, updates state, and replicates
local function validateAndReplicate(Context, brickBattleObject: BrickbattleObjects.Types, player: Player, data)
    if not BrickbattleStateValidator.validateCount(Context, player, data, brickBattleObject) then
        return
    end

    BrickbattleStateCache.updateStateForPlayer(player, brickBattleObject, "count", data.count)

    if not BrickbattleStateValidator.validateReloadTime(Context, player, data, brickBattleObject) then
        return
    end

    BrickbattleStateCache.updateStateForPlayer(player, brickBattleObject, "lastUsed", workspace:GetServerTimeNow())

    if not BrickbattleStateValidator.conductSecurityValidations(Context, player, data, brickBattleObject) then
        return
    end

    BrickbattleStateCache.createBrickbattleState(brickBattleObject, player, data)
    BrickbattleStateReplicator.replicateCreatedProjectile(brickBattleObject, player, data)
end

-- Loops over all of the brickbattle things and sets the callback.
local function setProjectileCreationCallbacks(Context)
    for _, brickBattleObject: BrickbattleObjects in pairs(brickBattleObjects) do
        local create: string = string.lower(brickBattleObject) + "Create"

        NetworkServer[create].SetCallback(function(player, data)
            validateAndReplicate(Context, brickBattleObject, player, data)
        end)
    end
end

function BrickbattleStateReplicator.replicateCreatedProjectile(brickBattleObject: BrickbattleObjects.Types, player: Player, data)
    if brickBattleObject == BrickbattleObjects.Bomb then
        NetworkServer.bombCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            position = data.position
        })
    elseif brickBattleObject == BrickbattleObjects.Rocket then
        NetworkServer.rocketCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            cFrame = data.cFrame
        })
    elseif brickBattleObject == BrickbattleObjects.Superball then
        NetworkServer.superballCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            position = data.position,
            velocity = data.velocity
        })
    elseif brickBattleObject == BrickbattleObjects.Paintball then
        NetworkServer.paintballCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            position = data.position,
            velocity = data.velocity
        })
    elseif brickBattleObject == BrickbattleObjects.Slingshot then
        NetworkServer.pelletCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            position = data.position,
            velocity = data.velocity
        })
    elseif brickBattleObject == BrickbattleObjects.Trowel then
        -- TODO: trowel case?
    else
        -- TODO: default case
    end
end

function BrickbattleStateReplicator.beginReplication(Context)
    setProjectileCreationCallbacks(Context)
end

return BrickbattleStateReplicator