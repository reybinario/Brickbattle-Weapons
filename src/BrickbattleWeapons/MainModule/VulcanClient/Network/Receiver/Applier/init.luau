--!strict

local ApplierTypes = require(script.ApplierTypes)
local Common = script.Parent.Parent.Parent.Common
local WeaponTypes = require(Common.WeaponTypes)

local WorldAppliers: {
    [WeaponTypes.ProjectileType]: ApplierTypes.WorldApplier
} = {
    superball = require(script.SuperballWorldApplier),
}

local Applier = {}

function Applier.get(projectile: WeaponTypes.ProjectileType)
    local strategy = WorldAppliers[projectile]
    if not strategy then
        error(("No client creation strategy for projectile '%s'"):format(projectile))
    end
    return strategy
end

return Applier