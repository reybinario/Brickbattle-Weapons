--!strict

local NetworkClient = require(script.Parent.Parent.NetworkClient)

local Weapons = require(script.Parent.Parent.Parent.Parent.VulcanShared.Weapons)

local CreationReceiver = {}

function CreationReceiver.setCallback()
    for _, brickBattleObject: Weapons.ProjectileType in pairs(Weapons) do
        local create: string = string.lower(brickBattleObject) .. "Create"

        NetworkClient[create].SetCallback(function(player, data)
            print(brickBattleObject, player, data)
        end)
    end
end

return CreationReceiver