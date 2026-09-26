--!strict
-- Pure validation math. Caller supplies server-owned launch context and elapsed time.
local Core = {}

-- Prototype bounds: calibrate from Studio traces before enabling damage/relay on updates.
Core.POSITION_TOLERANCE = 0.9 -- i16 position rounds each axis by at most 0.5 studs
Core.VELOCITY_TOLERANCE = 1.5 -- i16 velocity rounds each axis by at most 0.5 studs
Core.SPAWN_TOLERANCE = 2 -- position rounding + firing-pose uncertainty
Core.AIM_CONE_COSINE = math.cos(math.rad(20))
Core.MIN_SEGMENT_SECONDS = 0.025
Core.MAX_SEGMENT_SECONDS = 1
Core.MAX_LIFETIME_SECONDS = 10
Core.MAX_BOUNCES = 5
Core.STEP_SECONDS = 1 / 240 -- provisional 2020 measurement; verify in Studio
Core.ENERGY_TOLERANCE = 800 -- squared studs/second, provisional measurement bound

export type Launch = {
    position: Vector3,
    velocity: Vector3,
    firingPosition: Vector3,
    aimDirection: Vector3,
    ammoAvailable: boolean,
    elapsedSinceLastShot: number,
    reloadTime: number,
    spawnDistance: number,
    speed: number,
}

export type Segment = {
    launchPosition: Vector3,
    launchVelocity: Vector3,
    startPosition: Vector3, -- launch or last validated contact, never an arbitrary recent packet
    startVelocity: Vector3, -- velocity at that same anchor
    endPosition: Vector3,
    duration: number,
    gravity: number,
    age: number,
    bounceCount: number,
}

local function finite(n: number): boolean
    return n == n and n > -math.huge and n < math.huge
end

local function finiteVector(v: Vector3): boolean
    return finite(v.X) and finite(v.Y) and finite(v.Z)
end

function Core.validateLaunch(data: Launch): (boolean, string?)
    if not finiteVector(data.position) or not finiteVector(data.velocity)
        or not finiteVector(data.firingPosition) or not finiteVector(data.aimDirection)
        or not finite(data.elapsedSinceLastShot) or not finite(data.reloadTime)
        or not finite(data.spawnDistance) or not finite(data.speed)
        or data.spawnDistance < 0 or data.speed <= 0 or data.aimDirection.Magnitude < 0.99
        or data.aimDirection.Magnitude > 1.01 or data.reloadTime < 0 then
        return false, "invalid launch values"
    end
    if not data.ammoAvailable then return false, "no ammo" end
    if data.elapsedSinceLastShot < data.reloadTime then return false, "fire rate" end
    local offset = data.position - data.firingPosition
    if math.abs(offset.Magnitude - data.spawnDistance) > Core.SPAWN_TOLERANCE
        or offset.Magnitude < 0.001 then
        return false, "spawn position"
    end
    local aim = data.aimDirection.Unit
    if offset.Unit:Dot(aim) < Core.AIM_CONE_COSINE
        or data.velocity.Magnitude < 0.001
        or data.velocity.Unit:Dot(aim) < Core.AIM_CONE_COSINE then
        return false, "aim cone"
    end
    if math.abs(data.velocity.Magnitude - data.speed) > Core.VELOCITY_TOLERANCE then
        return false, "launch speed"
    end
    return true, nil
end

-- Velocity-first Euler correction: p1 = p0 + v0*t + g*(t*t + step*t)/2.
-- A calibrated step estimate is optional; the caller must budget solver uncertainty.
function Core.recoverVelocity(startPosition: Vector3, endPosition: Vector3, duration: number, gravity: number): Vector3?
    if not finiteVector(startPosition) or not finiteVector(endPosition) or not finite(duration)
        or not finite(gravity) or gravity < 0
        or duration < Core.MIN_SEGMENT_SECONDS or duration > Core.MAX_SEGMENT_SECONDS then
        return nil
    end
    local gravityVector = Vector3.new(0, -gravity, 0)
    return (endPosition - startPosition - gravityVector * (duration * duration + Core.STEP_SECONDS * duration) / 2) / duration
end

function Core.validateSegment(data: Segment): (boolean, string?, Vector3?)
    if not finiteVector(data.launchPosition) or not finiteVector(data.launchVelocity)
        or not finiteVector(data.startVelocity) or not finite(data.age)
        or not finite(data.bounceCount) or not finite(data.gravity)
        or data.age < 0 or data.age > Core.MAX_LIFETIME_SECONDS
        or data.bounceCount < 0 or data.bounceCount >= Core.MAX_BOUNCES then
        return false, "invalid segment state", nil
    end
    local recovered = Core.recoverVelocity(data.startPosition, data.endPosition, data.duration, data.gravity)
    if not recovered then return false, "invalid segment interval", nil end
    -- Compare against the same launch/contact anchor across every free-flight report.
    -- Do not replace it with each accepted packet: that would refill the error budget.
    -- Rounded endpoints contribute up to two position errors to velocity recovery.
    local recoveryTolerance = Core.VELOCITY_TOLERANCE
        + 2 * Core.POSITION_TOLERANCE / data.duration
    if (recovered - data.startVelocity).Magnitude > recoveryTolerance then
        return false, "arc velocity", recovered
    end
    local terminal = recovered + Vector3.new(0, -data.gravity * data.duration, 0)
    local allowedSquared = data.launchVelocity:Dot(data.launchVelocity)
        + 2 * data.gravity * (data.launchPosition.Y - data.endPosition.Y)
        + Core.ENERGY_TOLERANCE
    if terminal:Dot(terminal) > allowedSquared then
        return false, "energy envelope", recovered
    end
    return true, nil, recovered
end

return Core
