--!strict
--[[
StateCache offers state access at 3 levels:
 - Individual projectile: create, read, update, delete
 - Individual player: create, read, update, delete
 - Global: read
]]
local StateCache = {}

local StateSchema = require(script.Parent.StateSchema)

local cache: StateSchema.GlobalState = {}

-- Creates a new state for a projectile
function StateCache.createProjectileState()

end

-- Reads a projectile's state
function StateCache.readProjectileState(): StateSchema.ProjectileState

end

-- Updates a projectile's state. This does not replicate to clients.
-- You will need to manually trigger a replication via StateReplicator.
function StateCache.updateProjectileState()

end

-- Deletes a projectile's state
function StateCache.deleteProjectileState()

end

function StateCache.createPlayerState(player: Player)
    cache[player] = getDefaultPlayerState()
end

function StateCache.readPlayerState(): StateSchema.PlayerState

end

function StateCache.updatePlayerState()

end

function StateCache.deletePlayerState()

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
		walls = {},
	}
end

return StateCache
