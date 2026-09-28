--!strict
--[[
Validation core math, checked against closed-form ballistic arcs.

PhysicsGroundTruthTests covers arcs recorded from the live engine; these
cover the pure math with exact numbers, including the failure modes a
cheater would actually send. The launch constants mirror the Superball
defaults in Config (SpawnDistance 4, Speed 200, ReloadTime 2).
]]
local TestRunner = require(script.Parent.TestRunner)
local Helpers = require(script.Parent.Helpers)

local coreModule = Helpers.findModule("VulcanServer/Validation/SuperballValidationCore")
local Core = if coreModule then require(coreModule) else nil

local GRAVITY = 196.2 -- Roblox's default workspace.Gravity

local function needCore()
	if not Core then
		TestRunner.skip("SuperballValidationCore is not on this branch yet")
	end
end

local function honestLaunchIsAccepted()
	needCore()
	local valid, reason = Core.validateLaunch({
		position = Vector3.new(4, 10, 0),
		velocity = Vector3.new(200, 0, 0),
		firingPosition = Vector3.new(0, 10, 0),
		aimDirection = Vector3.new(1, 0, 0),
		ammoAvailable = true,
		elapsedSinceLastShot = 3,
		reloadTime = 2,
		spawnDistance = 4,
		speed = 200,
	})
	TestRunner.expectTrue(valid, "honest launch rejected: " .. tostring(reason))
end

local function launchWithWrongSpeedIsRejected()
	needCore()
	-- Claims nearly triple the allowed launch speed.
	local valid = Core.validateLaunch({
		position = Vector3.new(4, 10, 0),
		velocity = Vector3.new(590, 0, 0),
		firingPosition = Vector3.new(0, 10, 0),
		aimDirection = Vector3.new(1, 0, 0),
		ammoAvailable = true,
		elapsedSinceLastShot = 3,
		reloadTime = 2,
		spawnDistance = 4,
		speed = 200,
	})
	TestRunner.expectFalse(valid, "launch at 3x speed was accepted")
end

local function launchFromWrongPositionIsRejected()
	needCore()
	-- Claims to spawn 40 studs from the firer instead of 4.
	local valid = Core.validateLaunch({
		position = Vector3.new(40, 10, 0),
		velocity = Vector3.new(200, 0, 0),
		firingPosition = Vector3.new(0, 10, 0),
		aimDirection = Vector3.new(1, 0, 0),
		ammoAvailable = true,
		elapsedSinceLastShot = 3,
		reloadTime = 2,
		spawnDistance = 4,
		speed = 200,
	})
	TestRunner.expectFalse(valid, "launch from a faraway spawn was accepted")
end

local function honestArcIsAccepted()
	needCore()
	local origin = Vector3.new(0, 100, 0)
	local velocity = Vector3.new(40, 30, 0)
	local duration = 0.5
	local valid, reason = Core.validateSegment({
		launchPosition = origin,
		launchVelocity = velocity,
		startPosition = origin,
		startVelocity = velocity,
		endPosition = Helpers.freeFallPosition(origin, velocity, duration, GRAVITY),
		duration = duration,
		gravity = GRAVITY,
		age = duration,
		bounceCount = 0,
	})
	TestRunner.expectTrue(valid, "honest arc rejected: " .. tostring(reason))
end

local function teleportIsRejected()
	needCore()
	local origin = Vector3.new(0, 100, 0)
	local velocity = Vector3.new(40, 30, 0)
	local duration = 0.5
	-- 200 studs further along than physics allows in half a second.
	local doctored = Helpers.freeFallPosition(origin, velocity, duration, GRAVITY) + Vector3.new(200, 0, 0)
	local valid = Core.validateSegment({
		launchPosition = origin,
		launchVelocity = velocity,
		startPosition = origin,
		startVelocity = velocity,
		endPosition = doctored,
		duration = duration,
		gravity = GRAVITY,
		age = duration,
		bounceCount = 0,
	})
	TestRunner.expectFalse(valid, "teleporting arc was accepted")
end

local function energyGainIsRejected()
	needCore()
	-- The arc is internally consistent, but its claimed anchor sits 55 studs
	-- above the launch: the ball would have to gain energy to be there.
	-- The velocity check passes; the energy envelope must not.
	local launchPosition = Vector3.new(0, 0, 0)
	local launchVelocity = Vector3.new(10, 0, 0)
	local anchorPosition = Vector3.new(0, 55, 0)
	local anchorVelocity = Vector3.new(10, 0, 0)
	local duration = 0.5
	local valid = Core.validateSegment({
		launchPosition = launchPosition,
		launchVelocity = launchVelocity,
		startPosition = anchorPosition,
		startVelocity = anchorVelocity,
		endPosition = Helpers.freeFallPosition(anchorPosition, anchorVelocity, duration, GRAVITY),
		duration = duration,
		gravity = GRAVITY,
		age = duration,
		bounceCount = 1,
	})
	TestRunner.expectFalse(valid, "energy-gaining arc was accepted")
end

return {
	name = "Validation core math",
	tests = {
		{ name = "an honest launch is accepted", run = honestLaunchIsAccepted },
		{ name = "a launch at triple speed is rejected", run = launchWithWrongSpeedIsRejected },
		{ name = "a launch from the wrong position is rejected", run = launchFromWrongPositionIsRejected },
		{ name = "an honest arc is accepted", run = honestArcIsAccepted },
		{ name = "a teleport is rejected", run = teleportIsRejected },
		{ name = "an energy-gaining arc is rejected", run = energyGainIsRejected },
	},
}
