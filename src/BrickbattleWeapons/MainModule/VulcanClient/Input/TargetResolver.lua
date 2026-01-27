--!strict
local Trove = require(game.ReplicatedStorage.Packages:WaitForChild("trove"))

local TargetResolver = {}

export type TargetingCallback = (BasePart, Vector3) -> boolean

local targetingRules: {[string]: TargetingCallback} = {}

local allowlistedParts: {[BasePart]: true} = {}
local filteredParts: {[BasePart]: true} = {}

local partTrove = Trove.new()

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

function TargetResolver.addTargetingCallback(ruleName: string, targetingCallback: TargetingCallback)
	if targetingRules[ruleName] ~= nil then
		error("Can not add rule, rule name: " .. ruleName .. " already exists.")
	end
	targetingRules[ruleName] = targetingCallback
end

function TargetResolver.overrideTargetingCallback(ruleName: string, targetingCallback: TargetingCallback)
	if targetingRules[ruleName] == nil then
		error("Can not override rule, rule name: " .. ruleName .. " does not exist.")
	end
	targetingRules[ruleName] = targetingCallback
end

function TargetResolver.removeTargetingCallback(ruleName: string)
	if targetingRules[ruleName] == nil then
		error("Can not remove rule, rule name: " .. ruleName .. " does not exist.")
	end
	targetingRules[ruleName] = nil
end

local function getTargetingCallbacksResult(hit: BasePart, endPosition: Vector3): boolean
	for _, targetingCallback in pairs(targetingRules) do
		if targetingCallback(hit, endPosition) == false then
			return false
		end
	end
	return true
end

function TargetResolver.canTargetVulcanPart(_hit: BasePart): boolean
	return true
end

function TargetResolver.canTarget(hit: BasePart, endPosition: Vector3): boolean
	partTrove:AttachToInstance(hit)
	partTrove:Add(function()
		allowlistedParts[hit] = nil
		filteredParts[hit] = nil
	end)
	if hit:GetAttribute("VulcanIdentifier") then
		return TargetResolver.canTargetVulcanPart(hit)
	end

	if allowlistedParts[hit] then
		return true
	end

	local canTarget = getTargetingCallbacksResult(hit, endPosition)

	if canTarget then
		allowlistedParts[hit] = true
	else
		filteredParts[hit] = true
	end

	return canTarget
end

function buildExcludeList(extra: Instance?): {Instance}
	local list = {}

	if extra then
		table.insert(list, extra)
	end

	for part in pairs(filteredParts) do
		table.insert(list, part)
	end

	return list
end

local function castRay(startPosition: Vector3, direction: Vector3, remainingLength: number, depth: number): (Vector3, BasePart?)
	if remainingLength <= 0 or depth > 32 then
		return startPosition
	end

	raycastParams.FilterDescendantsInstances = buildExcludeList()

	local result = workspace:Raycast(startPosition, direction * remainingLength, raycastParams)

	if not result then
		return startPosition + direction * remainingLength
	end

	local hit = result.Instance :: BasePart
	local hitPosition = result.Position

	if not TargetResolver.canTarget(hit, hitPosition) then
		filteredParts[hit] = true
		return castRay(hitPosition, direction, remainingLength - (hitPosition - startPosition).Magnitude, depth + 1)
	end

	return hitPosition, hit
end

function TargetResolver.get3DPosition(targetRay: Ray): (Vector3, BasePart?)
	local Camera = workspace.CurrentCamera

	local direction = (targetRay.Origin + targetRay.Direction - Camera.CFrame.Position).Unit

	return castRay(Camera.CFrame.Position, direction, 9950, 0)
end

return TargetResolver