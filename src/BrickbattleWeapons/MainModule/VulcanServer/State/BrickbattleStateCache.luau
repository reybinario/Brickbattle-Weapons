--!strict
--[[
BrickbattleStateCache offers state access at 3 levels:
 - Individual projectile: create, read, update, delete
 - Individual player: create, read, update, delete
 - Global: read
]]
local BrickbattleStateCache = {}

local BrickbattleStateSchema = require(script.Parent.BrickbattleStateSchema)

local cache: BrickbattleStateSchema.GlobalBrickbattleState = {}

-- Creates a new state for a projectile
function BrickbattleStateCache.createBrickbattleState(Context )

end

-- Reads a projectile's state
function BrickbattleStateCache.readBrickbattleState(): BrickbattleState

end

-- Updates a projectile's state. This does not replicate to clients.
-- You will need to manually trigger a replication via BrickbattleStateReplicator.
function BrickbattleStateCache.updateBrickbattleState()

end

-- Deletes a projectile's state
function BrickbattleStateCache.deleteBrickbattleState()

end

function BrickbattleStateCache.createStateForPlayer(player: Player)
    cache[player] = getDefaultPlayerState()
end

function BrickbattleStateCache.readStateForPlayer(): BrickbattleStateSchema.BrickbattlePlayerStateSlice

end

function BrickbattleStateCache.updateStateForPlayer()

end

function BrickbattleStateCache.deleteStateForPlayer()

end

-- Gets the states of every current projectile for all players
function BrickbattleStateCache.readGlobalBrickbattleState(): BrickbattleStateSchema.GlobalBrickbattleState
    return cache
end

function BrickbattleStateCache.serveGlobalBrickbattleState(remoteFunction: RemoteFunction)
    remoteFunction.OnServerInvoke = function(player)
        return BrickbattleStateCache.readGlobalBrickbattleState()
    end
end

function getDefaultPlayerState(): BrickbattleStateSchema.BrickbattlePlayerStateSlice
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

return BrickbattleStateCache
