--!strict

local NetworkClient = require(script.Parent.Parent.NetworkClient)
local Applier = require(script.Parent.Applier)

local Common = script.Parent.Parent.Parent.Common
local WeaponTypes = require(Common.WeaponTypes)

local CreationReceiver = {}

local function handleCreate(projectile: WeaponTypes.ProjectileType, data)
    local applier = Applier.get(projectile)

    local instance = applier.create(data)
    applier.applyInitialState(instance, data)
    instance.Parent = applier.getParent(data)
end

function CreationReceiver.setCallback()
    for _, projectile: WeaponTypes.ProjectileType in pairs(WeaponTypes.Projectile) do
        if projectile == "wall" then continue end

        local eventName = projectile .. "CreateReplicate"
        NetworkClient[eventName].SetCallback(function(data)
            handleCreate(projectile, data)
        end)
    end
end

return CreationReceiver
