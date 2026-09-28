--!strict
--[[
Physics ground truth.

Every other validator test feeds positions into math. This suite asks the
more basic question first: does the engine itself behave the way the math
assumes? We launch a REAL ball here in the engine, record its arc heartbeat
by heartbeat, and then

  1. check the fall matches workspace.Gravity (sanity), and
  2. hand the honest recorded arc to the validation core, which must accept
     it - while the same arc with a doctored endpoint must be rejected.

If the honest arc is ever rejected, the validator's tolerances are wrong for
real Roblox physics, and no amount of analytic fixture testing would have
told us.
]]
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local TestRunner = require(script.Parent.TestRunner)
local Helpers = require(script.Parent.Helpers)

local LAUNCH_POSITION = Vector3.new(0, 100, 0)
local LAUNCH_VELOCITY = Vector3.new(40, 30, 0) -- mostly horizontal, some loft

-- Launches a real ball and samples its position every Heartbeat for the
-- given number of seconds. Returns { { time = t, position = Vector3 }, ... }.
local function recordFreeFlight(launchPosition: Vector3, launchVelocity: Vector3, seconds: number)
	local ball = Instance.new("Part")
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(2, 2, 2)
	ball.Position = launchPosition
	ball.Parent = Workspace
	ball.AssemblyLinearVelocity = launchVelocity

	local samples = {}
	local elapsed = 0
	-- The iteration cap is only a safety net: if Heartbeat ever stopped
	-- firing, the Open Cloud task itself would time out after 5 minutes.
	local iterations = 0
	while elapsed < seconds and iterations < 600 do
		elapsed += RunService.Heartbeat:Wait()
		iterations += 1
		table.insert(samples, { time = elapsed, position = ball.Position })
	end

	ball:Destroy()
	return samples
end

local function engineFallsAtWorkspaceGravity()
	local samples = recordFreeFlight(Vector3.new(0, 200, 0), Vector3.zero, 0.5)
	TestRunner.expectTrue(#samples > 10, "recorded too few physics samples")

	-- From rest, drop distance is g*t^2/2. Roblox's stepped integration
	-- overshoots slightly, so allow 10% plus one stud.
	local last = samples[#samples]
	local drop = 200 - last.position.Y
	local expectedDrop = Workspace.Gravity * last.time * last.time / 2
	TestRunner.expectApprox(drop, expectedDrop, expectedDrop * 0.1 + 1, "free fall matches workspace.Gravity")
end

local function coreAcceptsHonestEngineArc()
	local coreModule = Helpers.findModule("VulcanServer/Validation/SuperballValidationCore")
	if not coreModule then
		TestRunner.skip("SuperballValidationCore is not on this branch yet")
	end
	local Core = require(coreModule)

	local samples = recordFreeFlight(LAUNCH_POSITION, LAUNCH_VELOCITY, 0.5)
	local last = samples[#samples]

	local valid, reason = Core.validateSegment({
		launchPosition = LAUNCH_POSITION,
		launchVelocity = LAUNCH_VELOCITY,
		startPosition = LAUNCH_POSITION,
		startVelocity = LAUNCH_VELOCITY,
		endPosition = last.position,
		duration = last.time,
		gravity = Workspace.Gravity,
		age = last.time,
		bounceCount = 0,
	})
	TestRunner.expectTrue(valid, "honest engine arc was rejected: " .. tostring(reason))
end

local function coreRejectsDoctoredEngineArc()
	local coreModule = Helpers.findModule("VulcanServer/Validation/SuperballValidationCore")
	if not coreModule then
		TestRunner.skip("SuperballValidationCore is not on this branch yet")
	end
	local Core = require(coreModule)

	local samples = recordFreeFlight(LAUNCH_POSITION, LAUNCH_VELOCITY, 0.5)
	local last = samples[#samples]

	-- A cheater's report: the same honest arc, but the endpoint claims a
	-- 30-stud sideways teleport. Recovering velocity from it must fail.
	local doctored = last.position + Vector3.new(30, 0, 0)
	local valid = Core.validateSegment({
		launchPosition = LAUNCH_POSITION,
		launchVelocity = LAUNCH_VELOCITY,
		startPosition = LAUNCH_POSITION,
		startVelocity = LAUNCH_VELOCITY,
		endPosition = doctored,
		duration = last.time,
		gravity = Workspace.Gravity,
		age = last.time,
		bounceCount = 0,
	})
	TestRunner.expectFalse(valid, "doctored engine arc was accepted")
end

return {
	name = "Physics ground truth",
	tests = {
		{ name = "the engine falls at workspace.Gravity", run = engineFallsAtWorkspaceGravity },
		{ name = "core accepts an honest engine arc", run = coreAcceptsHonestEngineArc },
		{ name = "core rejects a doctored engine arc", run = coreRejectsDoctoredEngineArc },
	},
}
