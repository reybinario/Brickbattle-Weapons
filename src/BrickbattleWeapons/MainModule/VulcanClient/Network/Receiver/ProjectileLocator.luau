--!strict
--[[
ProjectileLocator finds the local extrapolated copy of another player's
projectile. CreationReceiver names every replicated projectile
"<Player>'s <Label><count>" inside workspace.Projectiles.Extrapolated, and
receivers key off that name.

Generic on purpose: locating a projectile is the same lookup for every
weapon type. What differs per type is what a receiver does with the part.
]]
local ProjectileLocator = {}

-- projectileLabel is the label used in the instance name,
-- e.g. "Superball" for "<Player>'s Superball3".
function ProjectileLocator.find(player: Player, projectileLabel: string, count: number): BasePart?
    local projectiles = workspace:FindFirstChild("Projectiles")
    local extrapolated = projectiles and projectiles:FindFirstChild("Extrapolated")
    if not extrapolated then
        return nil
    end
    local projectile = extrapolated:FindFirstChild(player.Name .. "'s " .. projectileLabel .. tostring(count))
    return projectile :: BasePart?
end

return ProjectileLocator
