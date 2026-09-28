--!strict
--[[
UpdateValidator checks incoming superball physics updates.

Scope, stated honestly: only LAUNCH-ANCHORED FREE FLIGHT inside the first
free-flight window after creation is validated. Bounce and contact evidence
does not exist anywhere in the package yet, so an update that falls outside
that window - or fails the free-flight arc - is REJECTED, never waved
through. A rejected ball stays inert and its motion is not replicated.
Damage authority and the strike system from the design paper are later slices.
]]
local VulcanServer = script.Parent.Parent
local Common = VulcanServer.Parent.VulcanClient.Common

local StateSchema = require(Common.StateSchema)
local StateRepository = require(VulcanServer.State.StateRepository)
local Core = require(script.Parent.SuperballValidationCore)

local UpdateValidator = {}

-- Clients stamp packets with their estimate of the server clock. The math
-- below trusts server RECEIPT timing only; the client stamp is a sanity
-- check against gross clock skew or replayed packets. Prototype bound:
-- calibrate against honest-player Studio traces.
UpdateValidator.MAX_CLOCK_SKEW_SECONDS = 2

-- The client counts its shots from 0 and wraps at 2^16; StateRepository
-- assigns each accepted creation the next 1-based id.
local function projectileIdFromCount(count: number): number
    return count % 65536 + 1
end

-- Returns whether the update is valid, the projectile state, and its id.
function UpdateValidator.validateSuperballUpdate(player: Player, data: any): (boolean, StateSchema.SuperballState?, number)
    local id = projectileIdFromCount(data.count)
    local state = StateRepository.readProjectileState(player, "Superball", id)
    if state == nil then
        return false, nil, id -- unknown projectile: never validated at creation
    end
    local shot = state :: StateSchema.SuperballState
    if not shot.active then
        return false, nil, id
    end

    local now = workspace:GetServerTimeNow()
    if math.abs(data.timestamp - now) > UpdateValidator.MAX_CLOCK_SKEW_SECONDS then
        return false, nil, id
    end

    local age = now - shot.originTimestamp
    if age > Core.MAX_SEGMENT_SECONDS then
        -- Past the free-flight window a real ball must have bounced. Bounce
        -- handling is pending, so reject instead of pretending to verify.
        return false, nil, id
    end

    -- Every report is measured against the same validated launch anchor.
    -- Re-anchoring on each accepted packet would refill the error budget.
    local valid, reason = Core.validateSegment({
        launchPosition = shot.originPosition,
        launchVelocity = shot.originVelocity,
        startPosition = shot.originPosition,
        startVelocity = shot.originVelocity,
        endPosition = data.position,
        duration = age,
        gravity = workspace.Gravity,
        age = age,
        bounceCount = 0,
    })
    if not valid then
        print(("Rejected superball update from %s (count %d): %s"):format(
            player.Name, data.count, reason or "unknown"))
        return false, nil, id
    end

    return true, shot, id
end

return UpdateValidator
