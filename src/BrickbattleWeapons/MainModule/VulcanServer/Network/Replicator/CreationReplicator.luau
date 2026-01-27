--!strict
local CreationReplicator = {}

local Network = script.Parent.Parent
local VulcanServer = Network.Parent
local Common = VulcanServer.Parent.VulcanClient.Common

local NetworkStateMapper = require(VulcanServer.State.NetworkStateMapper)
local NetworkServer = require(Network.NetworkServer)
local CreationValidator = require(VulcanServer.Validation.CreationValidator)
local StateRepository = require(VulcanServer.State.StateRepository)
local WeaponTypes = require(Common.WeaponTypes)


local weaponSpecificNetworkFields = {
    superball = {"position", "velocity"},
    rocket = {"cFrame"},
    bomb = {"position"},
    paintball = {"position", "velocity", "color"},
    pellet = {"position", "velocity"},
    wall = {"cFrame"},
}

function CreationReplicator.setCallback()
    print("setting creation callbacks")
    for _, brickBattleObject: WeaponTypes.ProjectileType in pairs(WeaponTypes.Projectile) do
        local create = string.lower(brickBattleObject) .. "Create"
        print("setting callback for:", create)
        print(NetworkServer)
        NetworkServer[create].SetCallback(function(player, data)
            validateAndReplicate(brickBattleObject, player, data)
        end)
    end
end

function CreationReplicator.replicateCreatedProjectile(projectile: WeaponTypes.ProjectileType, player: Player, data)
    print("replicating created projectile:", projectile, "for player:", player.Name)
    local replicateEvent = NetworkServer[projectile .. "CreateReplicate"]
    if not replicateEvent then error("No event for "..projectile) end
    local payload = {player = player, count = data.count}
    for _, key in ipairs(weaponSpecificNetworkFields[projectile]) do
        payload[key] = data[key]
    end

    replicateEvent.FireExcept(player, payload)
end

function validateAndReplicate(projectile: WeaponTypes.ProjectileType, player: Player, data)
    local weapon: WeaponTypes.WeaponType = WeaponTypes.fromProjectileToWeapon(projectile)
    local requestedInitialState = NetworkStateMapper.toProjectileState(projectile, data)
    if not CreationValidator.validateCount(player, requestedInitialState, weapon) then
        return
    end

    StateRepository.updatePlayerProjectileField(player, weapon, "counts", data.count)

    if not CreationValidator.validateReloadTime(player, requestedInitialState, weapon) then
        return
    end

    StateRepository.updatePlayerProjectileField(player, weapon, "lastUsed", workspace:GetServerTimeNow())

    if not CreationValidator.conductSecurityValidations(player, requestedInitialState, weapon) then
        return
    end

    StateRepository.createProjectileState(player, weapon, requestedInitialState)

    CreationReplicator.replicateCreatedProjectile(projectile, player, data)
end

return CreationReplicator