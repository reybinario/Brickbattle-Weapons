--!strict

local DependencyUtils = require(script.Parent.Parent.Parent.Management.DependencyUtils)
local NetworkClient = require(script.Parent.Parent.NetworkClient)

local VulcanShared = DependencyUtils.getVulcanShared()
local WeaponTypes = require(VulcanShared.WeaponTypes)

local CreationReceiver = {}

local SuperballCreator = require(script.Parent.Parent.Parent.Projectile.ProjectileCreator.SuperballCreator)

function fire(brickBattleObject, data)
    print("firing creation receiver for:", brickBattleObject)
    if brickBattleObject == "superball" then
        local part: Part = SuperballCreator.create(data.player)
        part.Position = data.position
        part.AssemblyLinearVelocity = data.velocity
        part.Parent = workspace.Projectiles.Buffers[data.player.Name]
    end
end

function CreationReceiver.setCallback()
    for _, brickBattleObject: WeaponTypes.ProjectileType in pairs(WeaponTypes.Projectile) do
        if brickBattleObject == "wall" then
            continue
        end
        local create: string = string.lower(brickBattleObject) .. "CreateReplicate"
        print("setting receiver callback for:", create)
        NetworkClient[create].SetCallback(function(data)
            fire(brickBattleObject, data)
        end)

    end
end

return CreationReceiver