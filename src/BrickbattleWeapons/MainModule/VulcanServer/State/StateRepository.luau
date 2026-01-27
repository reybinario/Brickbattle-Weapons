--!strict
--[[
StateRepository offers state access at 3 levels:
 - Individual projectile: create, read, update, delete
 - Individual player: create, read, update, delete
 - Global: read
]]
local StateRepository = {}

local Common = script.Parent.Parent.Parent.VulcanClient.Common
local StateSchema = require(Common.StateSchema)
local WeaponTypes = require(Common.WeaponTypes)

local cache: StateSchema.GlobalState = {}

local weaponProjectileMapping = {
	Superball = "superballs",
	Slingshot = "pellets",
	PaintballGun = "paintballs",
	Rocket = "rockets",
	Bomb = "bombs",
	Trowel = "walls"
}

local function getArrayName(weaponType: string): string?
    return weaponProjectileMapping[weaponType]
end

-- Creates a new state for a projectile
function StateRepository.createProjectileState(player: Player, weaponType: string, initialState: StateSchema.ProjectileState)
    local playerState = cache[player]
    if not playerState then return end
    local arrayName = getArrayName(weaponType)
    if not arrayName then return end
    playerState.counts[weaponType] += 1
    local id = playerState.counts[weaponType]
    playerState[arrayName][id] = initialState
end

-- Reads a projectile's state
function StateRepository.readProjectileState(player: Player, weaponType: string, projectileId: number): StateSchema.ProjectileState?
    local playerState = cache[player]
    if not playerState then return nil end
    local arrayName = getArrayName(weaponType)
    if not arrayName then return nil end
    return playerState[arrayName][projectileId]
end

-- Updates a projectile's state. This does not replicate to clients.
-- You will need to manually trigger a replication via StateReplicator.
function StateRepository.updateProjectileState(player: Player, weaponType: string, projectileId: number, newState: StateSchema.ProjectileState)
    local playerState = cache[player]
    if not playerState then return end
    local arrayName = getArrayName(weaponType)
    if not arrayName then return end
    playerState[arrayName][projectileId] = newState
end

-- Deletes a projectile's state
function StateRepository.deleteProjectileState(player: Player, weaponType: string, projectileId: number)
    local playerState = cache[player]
    if not playerState then return end
    local arrayName = getArrayName(weaponType)
    if not arrayName then return end
    playerState[arrayName][projectileId] = nil
end

function StateRepository.createPlayerState(player: Player)
    cache[player] = getDefaultPlayerState()
end

function StateRepository.readPlayerState(player: Player): StateSchema.PlayerState?
    return cache[player]
end

function StateRepository.updatePlayerState(player: Player, newState: StateSchema.PlayerState)
    cache[player] = newState
end

function StateRepository.deletePlayerState(player: Player)
    cache[player] = nil
end

-- Update a specific field in a player's weapon state (like lastUsed or counts)
function StateRepository.updatePlayerProjectileField(player: Player, weaponType: WeaponTypes.WeaponType, fieldName: StateSchema.PlayerStateNumericFields, value: number)
    local playerState = cache[player]
    if not playerState then
        warn("Player state not found for", player.Name)
        return
    end
    playerState[fieldName][weaponType] = value
end

-- Read a specific field in a player's weapon state
function StateRepository.readPlayerWeaponField(player: Player, weaponType: WeaponTypes.WeaponType, fieldName: StateSchema.PlayerStateNumericFields): number?
    local playerState = cache[player]
    if not playerState then
        warn("Player state not found for", player.Name)
        return
    end
    return playerState[fieldName][weaponType]
end

-- Gets the states of every current projectile for all players
function StateRepository.readGlobalState(): StateSchema.GlobalState
    return cache
end

function StateRepository.serveGlobalState(remoteFunction: RemoteFunction)
    remoteFunction.OnServerInvoke = function(player)
        return StateRepository.readGlobalState()
    end
end

function getDefaultPlayerState(): StateSchema.PlayerState
	return {
		lastUsed = {
			Superball = -1,
			Slingshot = -1,
			PaintballGun = -1,
			Rocket = -1,
			Bomb = -1,
			Trowel = -1,
			Sword = -1,
		},
		counts = {
			Superball = 0,
			Slingshot = 0,
			PaintballGun = 0,
			Rocket = 0,
			Bomb = 0,
			Trowel = 0,
		},
		superballs = {},
		pellets = {},
		paintballs = {},
		rockets = {},
		bombs = {},
		walls = {},
	}
end

return StateRepository
