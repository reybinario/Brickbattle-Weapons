--!strict
local CreationReplicator = {}

local Network = script.Parent.Parent
local VulcanServer = Network.Parent

local NetworkServer = require(Network.NetworkServer)
local CreationValidator = require(VulcanServer.Validation.CreationValidator)
local StateRepository = require(VulcanServer.State.StateRepository)
local StateSchema = require(VulcanServer.State.StateSchema)
local Weapons = require(VulcanServer.Parent.VulcanShared.Weapons)

function CreationReplicator.setCallback()
    print("setting creation callbacks")
    for _, brickBattleObject: Weapons.ProjectileType in pairs(Weapons.Projectiles) do
        local create: string = string.lower(brickBattleObject) .. "Create"
        print("setting callback for:", create)
        print(NetworkServer)
        NetworkServer[create].SetCallback(function(player, data)
            validateAndReplicate(brickBattleObject, player, data)
        end)
    end
end

function CreationReplicator.replicateCreatedProjectile(weapon: Weapons.ProjectileType, player: Player, data)
    print("replicating created projectile:", weapon, "for player:", player.Name)
    if weapon == Weapons.Projectiles.bomb then
        NetworkServer.bombCreateReplicate.FireExcept(player, {
            count = data.count,
            player = player,
            position = data.position
        })
    elseif weapon == Weapons.Projectiles.rocket then
        NetworkServer.rocketCreateReplicate.FireExcept(player, {
            count = data.count,
            player = player,
            cFrame = data.cFrame
        })
    elseif weapon == Weapons.Projectiles.superball then
        NetworkServer.superballCreateReplicate.FireExcept(player, {
            count = data.count,
            player = player,
            position = data.position,
            velocity = data.velocity
        })
    elseif weapon == Weapons.Projectiles.paintball then
        NetworkServer.paintballCreateReplicate.FireExcept(player, {
            count = data.count,
            player = player,
            position = data.position,
            velocity = data.velocity,
            color = data.color
        })
    elseif weapon == Weapons.Projectiles.pellet then
        NetworkServer.pelletCreateReplicate.FireExcept(player, {
            count = data.count,
            player = player,
            position = data.position,
            velocity = data.velocity
        })
    elseif weapon == Weapons.Projectiles.wall then
        -- TODO: Place trowel
    else
        error("Cannot replicate unknown type:", 1)
    end
end

function validateAndReplicate(weapon: Weapons.ProjectileType, player: Player, data)
    local requestedInitialState = transformCreationData(weapon, data)
    if not CreationValidator.validateCount(player, requestedInitialState, weapon) then
        return
    end

    -- StateRepository.updateProjectileState(player, weapon, data.count, "count")

    if not CreationValidator.validateReloadTime(player, requestedInitialState, weapon) then
        return
    end

    -- StateRepository.updateProjectileState(player, weapon, "lastUsed", workspace:GetServerTimeNow())

    if not CreationValidator.conductSecurityValidations(player, requestedInitialState, weapon) then
        return
    end

    StateRepository.createProjectileState(player, weapon, requestedInitialState)

    CreationReplicator.replicateCreatedProjectile(weapon, player, data)
end

function transformCreationData(weapon: Weapons.ProjectileType, data): StateSchema.ProjectileState
    -- TODO: transform data based on weapon type, from sent client data to server state schema
    return data
end

return CreationReplicator