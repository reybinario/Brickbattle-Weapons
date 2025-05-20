--!strict

local Weapons = require(script.Parent.Weapons)
type Weapons = Weapons.Types

--[[
StateCache offers state access at 3 levels:
 - Individual projectile: create, read, update, delete
 - Individual player: create, read, update, delete
 - Global: read
]]
local StateCache = {}

local StateSchema = require(script.Parent.StateSchema)
type keyofPlayerState = StateSchema.keyofPlayerState
type ProjectileState = StateSchema.ProjectileState
local cache: StateSchema.GlobalState = {}

-- Creates a new state for a projectile
function StateCache.createProjectileState(player: Player, Weapon: Weapons, State: ProjectileState)
	local PlayerState = cache[player]
	cache[player].counts[Weapon] += 1
	PlayerState[string.lower(Weapon).."s"][cache[player].counts[Weapon]] = State
end

-- Reads a projectile's state
function StateCache.readProjectileState(player: Player, Weapon: Weapons, count: number): StateSchema.ProjectileState
	local PlayerState = cache[player]
	return PlayerState[string.lower(Weapon).."s"][count]
end

-- Updates a projectile's state. This does not replicate to clients.
-- You will need to manually trigger a replication via StateReplicator.
function StateCache.updateProjectileState(player: Player, Weapon: Weapons, count: number, property: string, newValue)
	local PlayerState = cache[player]
	PlayerState[string.lower(Weapon).."s"][count][property] = newValue
end

-- Deletes a projectile's state
function StateCache.deleteProjectileState(player: Player, Weapon: Weapons, count: number)
	local PlayerState = cache[player]
	table.remove(PlayerState[string.lower(Weapon).."s"], count)
	cache[player].counts[Weapon] -= 1
end

function StateCache.createPlayerState(player: Player)
    cache[player] = getDefaultPlayerState()
end

function StateCache.readPlayerState(player: Player): StateSchema.PlayerState
	return cache[player]
end

function StateCache.updatePlayerState(player: Player, keyofPlayerState: keyofPlayerState, newState)
	local PlayerState = cache[player]
	PlayerState[keyofPlayerState] = newState
	return cache[player]
end

function StateCache.deletePlayerState(player: Player)
	cache[player] = nil
end

-- Gets the states of every current projectile for all players
function StateCache.readGlobalState(): StateSchema.GlobalState
    return cache
end

function StateCache.serveGlobalState(remoteFunction: RemoteFunction)
    remoteFunction.OnServerInvoke = function(player)
        return StateCache.readGlobalState()
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
		trowels = {},
	}
end

return StateCache
