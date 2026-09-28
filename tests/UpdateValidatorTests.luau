--!strict
--[[
UpdateValidator, exercised with honest and doctored superball updates.

The validator reads server receipt timing (workspace:GetServerTimeNow) and
the state recorded at creation, so each test registers a creation with the
repository first and then reports an update against it.
]]
local Workspace = game:GetService("Workspace")

local TestRunner = require(script.Parent.TestRunner)
local Helpers = require(script.Parent.Helpers)

local validatorModule = Helpers.findModule("VulcanServer/Validation/UpdateValidator")
local repositoryModule = Helpers.findModule("VulcanServer/State/StateRepository")

local UpdateValidator = if validatorModule then require(validatorModule) else nil
local StateRepository = if repositoryModule then require(repositoryModule) else nil

local ORIGIN = Vector3.new(0, 100, 0)
local VELOCITY = Vector3.new(40, 30, 0)

local function needValidator()
	if not UpdateValidator then
		TestRunner.skip("UpdateValidator is not on this branch yet")
	end
end

-- Registers a superball creation that was launched launchAge seconds ago.
-- Returns the fake player and the count the client would report for it.
local function registerShot(name: string, launchAge: number)
	local player = Helpers.fakePlayer(name)
	StateRepository.createPlayerState(player)

	local playerState = StateRepository.readPlayerState(player)
	local count = playerState.counts.Superball -- next creation gets count + 1

	local now = Workspace:GetServerTimeNow()
	StateRepository.createProjectileState(player, "Superball", {
		position = ORIGIN,
		velocity = VELOCITY,
		hitCount = 0,
		timestamp = now,
		originPosition = ORIGIN,
		originVelocity = VELOCITY,
		originTimestamp = now - launchAge,
		active = true,
		validated = false,
		count = count,
	})
	return player, count
end

local function honestUpdateIsAccepted()
	needValidator()
	local launchAge = 0.1
	local player, count = registerShot("UpdateHonest", launchAge)

	local valid = UpdateValidator.validateSuperballUpdate(player, {
		count = count,
		timestamp = Workspace:GetServerTimeNow(),
		position = Helpers.freeFallPosition(ORIGIN, VELOCITY, launchAge, Workspace.Gravity),
	})
	TestRunner.expectTrue(valid, "an honest free-flight update was rejected")

	StateRepository.deletePlayerState(player)
end

local function teleportedUpdateIsRejected()
	needValidator()
	local launchAge = 0.1
	local player, count = registerShot("UpdateDoctored", launchAge)

	local valid = UpdateValidator.validateSuperballUpdate(player, {
		count = count,
		timestamp = Workspace:GetServerTimeNow(),
		position = Helpers.freeFallPosition(ORIGIN, VELOCITY, launchAge, Workspace.Gravity) + Vector3.new(50, 0, 0),
	})
	TestRunner.expectFalse(valid, "a teleported update was accepted")

	StateRepository.deletePlayerState(player)
end

local function staleTimestampIsRejected()
	needValidator()
	local launchAge = 0.1
	local player, count = registerShot("UpdateStale", launchAge)

	-- A replayed (or grossly skewed) packet: 10 seconds old.
	local valid = UpdateValidator.validateSuperballUpdate(player, {
		count = count,
		timestamp = Workspace:GetServerTimeNow() - 10,
		position = Helpers.freeFallPosition(ORIGIN, VELOCITY, launchAge, Workspace.Gravity),
	})
	TestRunner.expectFalse(valid, "an update with a stale timestamp was accepted")

	StateRepository.deletePlayerState(player)
end

local function updateBeyondFreeFlightWindowIsRejected()
	needValidator()
	-- The ball claims to still be in its first free flight 5 seconds after
	-- launch; a real ball must have bounced by then, and bounce evidence is
	-- not implemented - so the honest answer is rejection, not a wave-through.
	local player, count = registerShot("UpdateOld", 5)

	local valid = UpdateValidator.validateSuperballUpdate(player, {
		count = count,
		timestamp = Workspace:GetServerTimeNow(),
		position = Helpers.freeFallPosition(ORIGIN, VELOCITY, 5, Workspace.Gravity),
	})
	TestRunner.expectFalse(valid, "an update past the free-flight window was accepted")

	StateRepository.deletePlayerState(player)
end

local function unknownProjectileIsRejected()
	needValidator()
	local player = Helpers.fakePlayer("UpdateUnknown")
	StateRepository.createPlayerState(player)

	-- Count 9 was never created on the server.
	local valid = UpdateValidator.validateSuperballUpdate(player, {
		count = 9,
		timestamp = Workspace:GetServerTimeNow(),
		position = ORIGIN,
	})
	TestRunner.expectFalse(valid, "an update for a never-created projectile was accepted")

	StateRepository.deletePlayerState(player)
end

return {
	name = "UpdateValidator",
	tests = {
		{ name = "an honest free-flight update is accepted", run = honestUpdateIsAccepted },
		{ name = "a teleported update is rejected", run = teleportedUpdateIsRejected },
		{ name = "a stale timestamp is rejected", run = staleTimestampIsRejected },
		{ name = "an update past the free-flight window is rejected", run = updateBeyondFreeFlightWindowIsRejected },
		{ name = "an unknown projectile is rejected", run = unknownProjectileIsRejected },
	},
}
