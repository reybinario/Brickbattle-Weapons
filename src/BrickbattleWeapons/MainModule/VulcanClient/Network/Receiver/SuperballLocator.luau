--!strict
--[[
SuperballLocator finds the extrapolated copy of another player's superball.
CreationReceiver names every replicated ball "<Player>'s Superball<count>"
inside workspace.Projectiles.Extrapolated; both update receivers key off that.
]]
local SuperballLocator = {}

function SuperballLocator.find(player: Player, count: number): BasePart?
    local projectiles = workspace:FindFirstChild("Projectiles")
    local extrapolated = projectiles and projectiles:FindFirstChild("Extrapolated")
    if not extrapolated then
        return nil
    end
    local ball = extrapolated:FindFirstChild(player.Name .. "'s Superball" .. tostring(count))
    return ball :: BasePart?
end

return SuperballLocator
