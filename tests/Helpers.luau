--!strict
--[[
Helpers shared by the engine test suites.

The interesting one is fakePlayer: the server validators key their state by
the player value and only ever read player.Name or player.Character, so a
plain table stands in for a real connected player. That is what lets us
exercise the validators in a headless server with no clients at all.
]]
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Helpers = {}

-- Finds a module under the weapon kit's MainModule, or returns nil when this
-- branch does not have it yet (tests for unmerged work skip politely).
-- Path segments are separated by "/", e.g. "VulcanServer/Validation/UpdateValidator".
function Helpers.findModule(path: string): ModuleScript?
	local current: Instance? = ServerScriptService:FindFirstChild("MainModule")
	for name in string.gmatch(path, "[^/]+") do
		current = if current then current:FindFirstChild(name) else nil
	end
	if current and current:IsA("ModuleScript") then
		return current
	end
	return nil
end

-- Position of a projectile in free fall after t seconds (no bounce):
-- p(t) = p0 + v0*t - (g*t^2/2) straight down.
function Helpers.freeFallPosition(origin: Vector3, velocity: Vector3, t: number, gravity: number): Vector3
	return origin + velocity * t + Vector3.new(0, -gravity * t * t / 2, 0)
end

-- A stand-in player. Validators key state tables by this value and read
-- .Name; security checks also read .Character.
function Helpers.fakePlayer(name: string): any
	return { Name = name }
end

-- Builds the smallest "character" that satisfies the creation security
-- checks: a Model in Workspace with a PrimaryPart and a living Humanoid.
function Helpers.spawnFakeCharacter(position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "EngineTestCharacter"

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Anchored = true
	root.CanCollide = false
	root.Position = position
	root.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model

	model.PrimaryPart = root
	model.Parent = Workspace
	return model
end

return Helpers
