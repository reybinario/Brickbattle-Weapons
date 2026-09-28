--!strict
--[[
SuperballPhysicsSender reports locally fired superballs to the server.
One physics sender per projectile type, mirroring the receivers.

Only the first free-flight window is reported. Until bounce evidence exists
there is nothing honest to say after that window, so reporting simply stops -
the server rejects late updates for the same reason. The firing client keeps
its own view either way; these reports exist so the SERVER can validate the
arc and share it with everyone else.
]]
local RunService = game:GetService("RunService")

local NetworkClient = require(script.Parent.Parent.NetworkClient)
local Common = script.Parent.Parent.Parent.Common
local NetworkEncoding = require(Common.NetworkEncoding)

local SuperballPhysicsSender = {}

local UPDATE_INTERVAL_SECONDS = 1 / 15
-- Keep in step with SuperballValidationCore.MAX_SEGMENT_SECONDS on the server.
local FREE_FLIGHT_WINDOW_SECONDS = 1
local TICKS_PER_SECOND = 100
local TICK_MODULUS = 65536

type TrackedBall = {
    part: BasePart,
    count: number,
    packetCount: number,
    originTime: number,
    lastSent: number,
}

local tracked: {TrackedBall} = {}
local heartbeat: RBXScriptConnection? = nil

local function sendUpdate(ball: TrackedBall, now: number)
    ball.packetCount += 1
    ball.lastSent = now
    NetworkClient.superballUpdate.Fire({
        count = ball.count,
        packetCount = ball.packetCount,
        position = NetworkEncoding.toI16Vector(ball.part.Position),
        velocity = NetworkEncoding.toI16Vector(ball.part.AssemblyLinearVelocity),
        -- Centisecond ticks fit in two bytes; wrap is safe against the server clock.
        timestamp = math.round(now * TICKS_PER_SECOND) % TICK_MODULUS,
    })
end

local function onHeartbeat()
    local now = workspace:GetServerTimeNow()
    for index = #tracked, 1, -1 do
        local ball = tracked[index]
        local age = now - ball.originTime
        if ball.part.Parent == nil or age > FREE_FLIGHT_WINDOW_SECONDS then
            table.remove(tracked, index)
        elseif now - ball.lastSent >= UPDATE_INTERVAL_SECONDS then
            sendUpdate(ball, now)
        end
    end
    if #tracked == 0 and heartbeat then
        heartbeat:Disconnect()
        heartbeat = nil
    end
end

-- Registers a just-fired superball and sends its first report immediately,
-- so the server sees motion well inside the free-flight window.
function SuperballPhysicsSender.trackSuperball(part: BasePart, count: number)
    local ball: TrackedBall = {
        part = part,
        count = count,
        packetCount = 0,
        originTime = workspace:GetServerTimeNow(),
        lastSent = 0,
    }
    table.insert(tracked, ball)
    sendUpdate(ball, ball.originTime)
    if not heartbeat then
        heartbeat = RunService.Heartbeat:Connect(onHeartbeat)
    end
end

return SuperballPhysicsSender
