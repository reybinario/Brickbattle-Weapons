--!strict
local NetworkStateMapper = {}

local Common = script.Parent.Parent.Parent.VulcanClient.Common
local StateSchema = require(Common.StateSchema)
local NetworkTypes = require(Common.NetworkTypes)
local WeaponTypes = require(Common.WeaponTypes)

-- Private logic helper
local function getBase(count: number)
	local now = workspace:GetServerTimeNow()
	return {
		count = count,
		timestamp = now,
		originTimestamp = now,
		active = true,
	}
end

local Mappers = {
	superball = function(data: NetworkTypes.movingProjectileCreateData): StateSchema.SuperballState
		local base = getBase(data.count)
		return {
			count = base.count,
			timestamp = base.timestamp,
			originTimestamp = base.originTimestamp,
			active = base.active,
			position = data.position,
			velocity = data.velocity,
			originPosition = data.position,
			hitCount = 0,
		}
	end,

	pellet = function(data: NetworkTypes.movingProjectileCreateData): StateSchema.SlingshotState
		local base = getBase(data.count)
		return {
			count = base.count,
			timestamp = base.timestamp,
			originTimestamp = base.originTimestamp,
			active = base.active,
			position = data.position,
			velocity = data.velocity,
			originPosition = data.position,
			hitCount = 0,
		}
	end,

    paintball = function(data: NetworkTypes.paintballCreateData): StateSchema.PaintballState
        local base = getBase(data.count)
        return {
            count = base.count,
            timestamp = base.timestamp,
            originTimestamp = base.originTimestamp,
            active = base.active,
            position = data.position,
            velocity = data.velocity,
            originPosition = data.position,
            hasHit = false,
        }
    end,

	rocket = function(data: NetworkTypes.rocketCreateData): StateSchema.RocketState
		local base = getBase(data.count)
		return {
			count = base.count,
			timestamp = base.timestamp,
			originTimestamp = base.originTimestamp,
			active = base.active,
			distance = 0,
			velocity = data.cFrame.LookVector * 100,
			originCframe = data.cFrame,
			hasExploded = false,
		}
	end,

	bomb = function(data: NetworkTypes.bombCreateData): StateSchema.BombState
		local base = getBase(data.count)
		return {
			count = base.count,
			timestamp = base.timestamp,
			originTimestamp = base.originTimestamp,
			active = base.active,
			position = data.position,
			velocity = Vector3.zero,
			originPosition = data.position,
			tickTime = 0,
			hasExploded = false,
		}
	end,

	wall = function(data: NetworkTypes.wallCreateData): StateSchema.WallState
        -- TODO: better reconcile wall network data with internal state
		return {
			count = data.count,
			model = Instance.new("Model"),
		}
	end,
}

type creationType = NetworkTypes.bombCreateData | NetworkTypes.rocketCreateData | NetworkTypes.movingProjectileCreateData | NetworkTypes.wallCreateData | NetworkTypes.paintballCreateData
function NetworkStateMapper.toProjectileState(
    projectile: WeaponTypes.ProjectileType,
    networkData: creationType
): StateSchema.ProjectileState

    local mapper = Mappers[projectile]

    if not mapper then
        error(string.format("NetworkStateMapper: No mapping strategy found for projectile type '%s'", tostring(projectile)))
    end

    return mapper(networkData)
end

return NetworkStateMapper