--!strict
-- Run as a ModuleScript in Studio by requiring it from the command bar.
local ArcValidator = require(script.Parent.ArcValidator)
type Launch = ArcValidator.Launch
type Segment = ArcValidator.Segment

local function launch(overrides: {[string]: any}?): Launch
    local data: any = {
        position = Vector3.new(4, 10, 0), velocity = Vector3.new(200, 0, 0),
        firingPosition = Vector3.new(0, 10, 0), aimDirection = Vector3.new(1, 0, 0),
        elapsedSinceLastShot = 3, reloadTime = 2,
        spawnDistance = 4, speed = 200,
    }
    for key, value in overrides or {} do data[key] = value end
    return data :: Launch
end

local function segment(overrides: {[string]: any}?): Segment
    local gravity = 196.2
    local t = 0.2
    local g = Vector3.new(0, -gravity, 0)
    local start = Vector3.new(4, 10, 0)
    local velocity = Vector3.new(200, 0, 0)
    local data: any = {
        launchPosition = start, launchVelocity = velocity,
        startPosition = start, startVelocity = velocity,
        endPosition = start + velocity * t + g * (t * t + ArcValidator.STEP_SECONDS * t) / 2,
        duration = t, gravity = gravity, age = t, bounceCount = 0,
    }
    for key, value in overrides or {} do data[key] = value end
    return data :: Segment
end

assert(ArcValidator.validateLaunch(launch()))
assert(not ArcValidator.validateLaunch(launch({elapsedSinceLastShot = 1.9})))
assert(not ArcValidator.validateLaunch(launch({position = Vector3.new(30, 10, 0)})))
assert(not ArcValidator.validateLaunch(launch({velocity = Vector3.new(0, 0, 200)})))
assert(not ArcValidator.validateLaunch(launch({velocity = Vector3.new(300, 0, 0)})))
assert(not ArcValidator.validateLaunch(launch({position = Vector3.new(math.huge, 10, 0)})))

local valid, _, recovered = ArcValidator.validateSegment(segment())
assert(valid and recovered ~= nil and (recovered - Vector3.new(200, 0, 0)).Magnitude < 0.001)
assert(not ArcValidator.validateSegment(segment({endPosition = Vector3.new(200, 10, 0)}))) -- teleport
assert(not ArcValidator.validateSegment(segment({endPosition = Vector3.new(8, 6, 0)}))) -- slow/hover
assert(not ArcValidator.validateSegment(segment({duration = 0.001}))) -- ill-conditioned
assert(not ArcValidator.validateSegment(segment({age = 10.01})))
assert(not ArcValidator.validateSegment(segment({bounceCount = 5})))
-- Raise launch energy within the arc tolerance; the independent energy ceiling still rejects it.
local highEnergy = segment({startVelocity = Vector3.new(210, 0, 0), launchVelocity = Vector3.new(100, 0, 0)})
assert(not ArcValidator.validateSegment(highEnergy))
return true
