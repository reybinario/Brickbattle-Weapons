--!strict
local CreationReplicator = {}

local Network: Folder = script.Parent.Parent
local VulcanServer: Folder = Network.Parent

local NetworkServer = require(Network.NetworkServer)
local CreationValidator = require(VulcanServer.Validation.CreationValidator)
local StateCache = require(VulcanServer.State.StateCache)
local Weapons = require(VulcanServer.State.Weapons)

function CreationReplicator.setCallback()
    for _, brickBattleObject: Weapons.Types in pairs(brickBattleObjects) do
        local create: string = string.lower(brickBattleObject) + "Create"

        NetworkServer[create].SetCallback(function(player, data)
            validateAndReplicate(Context, brickBattleObject, player, data)
        end)
    end
end

function CreationReplicator.replicateCreatedProjectile(weapon: Weapons.Types, player: Player, data)
    if weapon == Weapons.Bomb then
        NetworkServer.bombCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            position = data.position
        })
    elseif weapon == Weapons.Rocket then
        NetworkServer.rocketCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            cFrame = data.cFrame
        })
    elseif weapon == Weapons.Superball then
        NetworkServer.superballCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            position = data.position,
            velocity = data.velocity
        })
    elseif weapon == Weapons.Paintball then
        NetworkServer.paintballCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            position = data.position,
            velocity = data.velocity
        })
    elseif weapon == Weapons.Slingshot then
        NetworkServer.pelletCreateReplicate.FireExcept(player, {
            count = data.count,
            userId = player.UserId,
            position = data.position,
            velocity = data.velocity
        })
    elseif weapon == Weapons.Trowel then
        -- TODO: trowel case?
    else
        -- TODO: default case
    end
end

function validateAndReplicate(weapon: Weapons.Types, player: Player, data)
    if not CreationValidator.validateCount(player, data, weapon) then
        return
    end

    StateCache.updateStateForPlayer(player, weapon, "count", data.count)

    if not CreationValidator.validateReloadTime(player, data, weapon) then
        return
    end

    StateCache.updateStateForPlayer(player, weapon, "lastUsed", workspace:GetServerTimeNow())

    if not CreationValidator.conductSecurityValidations(player, data, weapon) then
        return
    end

    StateCache.createBrickbattleState(weapon, player, data)
    CreationReplicator.replicateCreatedProjectile(weapon, player, data)
end

return CreationReplicator