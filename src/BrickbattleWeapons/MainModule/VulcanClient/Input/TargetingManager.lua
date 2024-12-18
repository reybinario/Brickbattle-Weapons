--!strict
local Targeting = {}

local Players = game:GetService("Players")

local targetingRules: {[string]: (BasePart, Vector3) -> boolean} = {}
local allowlistedParts: {[BasePart]: true} = {}
local filteredParts: {[number]: Instance} = {}
local tempFilteredParts: {[number]: Instance} = {} -- also filters all descendants

function Targeting.addTargetingCallback(ruleName: string, targetingCallback: ((BasePart, Vector3) -> boolean))
	if targetingRules[ruleName] ~= nil then
		error("Can not add rule, rule name: " .. ruleName .. " already exists.")
	end
	targetingRules[ruleName] = targetingCallback
end

function Targeting.overrideTargetingCallback(ruleName: string, targetingCallback: ((BasePart, Vector3) -> boolean))
	if targetingRules[ruleName] == nil then
		error("Can not override rule, rule name: " .. ruleName .. " does not exist.")
	end
	targetingRules[ruleName] = targetingCallback
end

function Targeting.removeTargetingCallback(ruleName)
	if targetingRules[ruleName] == nil then
		error("Can not remove rule, rule name: " .. ruleName .. " does not exist.")
	end
	targetingRules[ruleName] = nil
end

function Targeting.getTargetingCallbacksResult(hit: BasePart, endPosition: Vector3): boolean
	for ruleName: string, targetingCallback: (BasePart, Vector3) -> boolean in next, targetingRules do
		print("Processing", ruleName)
		local result: boolean = targetingCallback(hit, endPosition)
		print("result", result)

		if result == false then
			return false
		end
	end
	return true
end

function Targeting.canTargetVulcanPart(hit: BasePart): boolean
	-- For now while I figure out a better solution for this.
	-- Since we reuse parts, can't guarantee processing of rules
	-- will be the same each time.
	return true
end

function Targeting.canTarget(hit: BasePart, endPosition: Vector3): boolean
	if hit:GetAttribute("VulcanIdentifier") then -- note that the Vulcan projectiles are not cached.
		return Targeting.canTargetVulcanPart(hit)
	end
	if allowlistedParts[hit] ~= nil then
		return true
	end
	local canTarget: boolean = Targeting.getTargetingCallbacksResult(hit, endPosition)
	if canTarget then
		allowlistedParts[hit] = true
	else
		table.insert(filteredParts, hit)
		table.insert(tempFilteredParts, hit)
	end
	return canTarget
end

-- Custom raycasting function to prevent specific objects from messing up targeting
function Targeting.castRay(startPosition: Vector3, direction: Vector3, length: number): (Vector3, BasePart?)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = tempFilteredParts
	raycastParams.IgnoreWater = true

	local raycastResult: RaycastResult? = workspace:Raycast(startPosition, direction * length, raycastParams)

	local didRayHitSomething: boolean = raycastResult ~= nil and raycastResult.Instance ~= nil

	if not didRayHitSomething then
		return startPosition + (direction * length)
	end

	local hit = raycastResult.Instance
	local endPosition = raycastResult.Position

	local canTarget: boolean = Targeting.canTarget(hit, endPosition)
	if canTarget == false then
		table.insert(tempFilteredParts, hit)
		return Targeting.castRay(endPosition, direction, length - ((startPosition - endPosition).Magnitude))
	end

	-- reset
	tempFilteredParts = table.clone(filteredParts)

	return endPosition, hit
end

-- Acquires world position of the mouse
function Targeting.get3DPosition(targetRay: Ray): (Vector3, BasePart?)
	local LocalPlayer: Player = game:GetService("Players").LocalPlayer
	local Camera: Camera = workspace.CurrentCamera

	local endPosition: Vector3 = targetRay.Origin + targetRay.Direction
	local direction: Vector3 = (endPosition - Camera.CFrame.Position).Unit

	table.insert(tempFilteredParts, LocalPlayer.Character)
	return Targeting.castRay(Camera.CFrame.Position, direction, 9950)
end

return Targeting