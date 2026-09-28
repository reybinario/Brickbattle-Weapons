--!strict
local NetworkStateMapper = {}

local Common = script.Parent.Parent.Parent.VulcanClient.Common
local StateSchema = require(Common.StateSchema)
-- Blink generates event methods, not standalone payload types.
type MovingCreateData = { count: number, position: Vector3, velocity: Vector3 }
type PaintballCreateData = MovingCreateData & { color: Color3 }
type RocketCreateData = { count: number, cFrame: CFrame }
type BombCreateData = { count: number, position: Vector3 }
type WallCreateData = { count: number, cFrame: CFrame }
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
	superball = function(data: MovingCreateData): StateSchema.SuperballState
		local base = getBase(data.count)
		return {
			count = base.count,
			timestamp = base.timestamp,
			originTimestamp = base.originTimestamp,
			active = base.active,
			position = data.position,
			velocity = data.velocity,
			originPosition = data.position,
			originVelocity = data.velocity,
			hitCount = 0,
		}
	end,

	pellet = function(data: MovingCreateData): StateSchema.SlingshotState
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

    paintball = function(data: PaintballCreateData): StateSchema.PaintballState
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

	rocket = function(data: RocketCreateData): StateSchema.RocketState
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

	bomb = function(data: BombCreateData): StateSchema.BombState
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

	wall = function(data: WallCreateData): StateSchema.WallState
        -- TODO: better reconcile wall network data with internal state
		return {
			count = data.count,
			model = Instance.new("Model"),
		}
	end,
}

type creationType = BombCreateData | RocketCreateData | MovingCreateData | WallCreateData | PaintballCreateData
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
