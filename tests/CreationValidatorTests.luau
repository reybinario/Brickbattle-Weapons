--!strict
--[[
CreationValidator, exercised the way the server uses it.

No clients can connect to a headless test server, so we stand in for one:
the repository keys state by the player value and the validator only reads
player.Name and player.Character, so a plain table plus a minimal character
model is enough to walk every check.

This suite skips politely until the validation core exists on the branch -
the pre-validator CreationValidator stub accepted everything by design.
]]
local Workspace = game:GetService("Workspace")

local TestRunner = require(script.Parent.TestRunner)
local Helpers = require(script.Parent.Helpers)

local coreModule = Helpers.findModule("VulcanServer/Validation/SuperballValidationCore")
local validatorModule = Helpers.findModule("VulcanServer/Validation/CreationValidator")
local repositoryModule = Helpers.findModule("VulcanServer/State/StateRepository")
local configModule = Helpers.findModule("VulcanServer/Management/Config")

local CreationValidator = if validatorModule then require(validatorModule) else nil
local StateRepository = if repositoryModule then require(repositoryModule) else nil
local Config = if configModule then require(configModule) else nil

local function needValidator()
	if not coreModule or not CreationValidator then
		TestRunner.skip("the superball creation validator is not on this branch yet")
	end
end

-- A superball creation packet launching along +X from the character.
local function honestShot(characterPosition: Vector3, speed: number, spawnDistance: number)
	return {
		position = characterPosition + Vector3.new(spawnDistance, 0, 0),
		velocity = Vector3.new(speed, 0, 0),
	}
end

local function reloadGateAdmitsFirstShot()
	needValidator()
	local player = Helpers.fakePlayer("ReloadHonest")
	StateRepository.createPlayerState(player)

	-- A fresh player has never fired, so the reload gate must open.
	local valid = CreationValidator.validateReloadTime(player, { count = 0 }, "Superball")
	TestRunner.expectTrue(valid, "first-ever shot was blocked by the reload gate")

	StateRepository.deletePlayerState(player)
end

local function reloadGateBlocksRapidFire()
	needValidator()
	local player = Helpers.fakePlayer("ReloadDoctored")
	StateRepository.createPlayerState(player)

	-- Pretend the player fired THIS instant: the next shot must wait.
	StateRepository.updatePlayerProjectileField(player, "Superball", "lastUsed", Workspace:GetServerTimeNow())
	local valid = CreationValidator.validateReloadTime(player, { count = 1 }, "Superball")
	TestRunner.expectFalse(valid, "a shot inside the reload window was allowed")

	StateRepository.deletePlayerState(player)
end

local function countGateChecksSequence()
	needValidator()
	local player = Helpers.fakePlayer("CountCheck")
	StateRepository.createPlayerState(player)

	-- The client counts shots from 0, so a fresh player's first packet is 0.
	TestRunner.expectTrue(
		CreationValidator.validateCount(player, { count = 0 }, "Superball"),
		"a fresh player's first shot (count 0) was rejected"
	)
	-- Claiming to be on shot 7 already is a cheater's packet.
	TestRunner.expectFalse(
		CreationValidator.validateCount(player, { count = 7 }, "Superball"),
		"an out-of-sequence shot count was accepted"
	)

	StateRepository.deletePlayerState(player)
end

local function securityChecksAdmitHonestShot()
	needValidator()
	local superball = Config.get().Superball
	local character = Helpers.spawnFakeCharacter(Vector3.new(0, 10, 0))
	local player = Helpers.fakePlayer("SecurityHonest")
	player.Character = character

	local valid = CreationValidator.conductSecurityValidations(
		player,
		honestShot(character.PrimaryPart.Position, superball.ProjectileConfig.Speed, superball.ProjectileConfig.SpawnDistance),
		"Superball"
	)
	TestRunner.expectTrue(valid, "an honest superball creation failed security checks")

	character:Destroy()
end

local function securityChecksRejectFastShot()
	needValidator()
	local superball = Config.get().Superball
	local character = Helpers.spawnFakeCharacter(Vector3.new(0, 10, 0))
	local player = Helpers.fakePlayer("SecurityDoctored")
	player.Character = character

	local valid = CreationValidator.conductSecurityValidations(
		player,
		honestShot(character.PrimaryPart.Position, superball.ProjectileConfig.Speed * 3, superball.ProjectileConfig.SpawnDistance),
		"Superball"
	)
	TestRunner.expectFalse(valid, "a triple-speed superball creation passed security checks")

	character:Destroy()
end

local function securityChecksRequireLivingCharacter()
	needValidator()
	local superball = Config.get().Superball
	local character = Helpers.spawnFakeCharacter(Vector3.new(0, 10, 0))
	local player = Helpers.fakePlayer("SecurityDead")
	player.Character = character

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	humanoid.Health = 0
	local valid = CreationValidator.conductSecurityValidations(
		player,
		honestShot(character.PrimaryPart.Position, superball.ProjectileConfig.Speed, superball.ProjectileConfig.SpawnDistance),
		"Superball"
	)
	TestRunner.expectFalse(valid, "a dead character was allowed to fire")

	character:Destroy()
end

return {
	name = "CreationValidator",
	tests = {
		{ name = "the reload gate admits a first shot", run = reloadGateAdmitsFirstShot },
		{ name = "the reload gate blocks rapid fire", run = reloadGateBlocksRapidFire },
		{ name = "the count gate checks the shot sequence", run = countGateChecksSequence },
		{ name = "security checks admit an honest shot", run = securityChecksAdmitHonestShot },
		{ name = "security checks reject a triple-speed shot", run = securityChecksRejectFastShot },
		{ name = "security checks require a living character", run = securityChecksRequireLivingCharacter },
	},
}
