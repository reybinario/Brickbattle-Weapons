--!strict

local NetworkEncoding = {}

local I16_MIN = -32768
local I16_MAX = 32767
local U16_MODULUS = 65536

local function toI16Component(value: number): number
    return math.clamp(math.round(value), I16_MIN, I16_MAX)
end

function NetworkEncoding.toI16Vector(value: Vector3): Vector3
    return Vector3.new(toI16Component(value.X), toI16Component(value.Y), toI16Component(value.Z))
end

function NetworkEncoding.nextU16Count(count: number): number
    return (count + 1) % U16_MODULUS
end

return NetworkEncoding
