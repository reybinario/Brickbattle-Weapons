--!strict
local ComboUtils = {}

local COLLISION_GROUP_NAME = "PlayerParts"

function ComboUtils.setupLocalCharacterCollisionGroups(player: Player)
    local character = player.Character
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CollisionGroup = COLLISION_GROUP_NAME
        end
    end
end

return ComboUtils