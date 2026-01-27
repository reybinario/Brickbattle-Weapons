--!strict
local SuperballCreator = require(script.Parent.Parent.Parent.Parent.Projectile.ProjectileCreator.SuperballCreator)
local ApplierTypes = require(script.Parent.ApplierTypes)

local SuperballWorldApplier = {}

function SuperballWorldApplier.create(receivedData: ApplierTypes.ReceivedProjectileData)
    return SuperballCreator.create(receivedData.player)
end

function SuperballWorldApplier.applyInitialState(part: Part, receivedData: ApplierTypes.ReceivedProjectileData)
    local position = receivedData.position
    local velocity = receivedData.velocity
    if not position then
        print(part, receivedData)
        error("SuperballWorldApplier requires position!")
    end
    if not velocity then
        print(part, receivedData)
        error("SuperballWorldApplier requires velocity!")
    end
    part.Position = position
    part.AssemblyLinearVelocity = velocity
    part.Name = receivedData.player.Name.."'s Superball"..tostring(receivedData.count)
end

function SuperballWorldApplier.getParent(receivedData: ApplierTypes.ReceivedProjectileData)
    return workspace.Projectiles.Extrapolated
end

return SuperballWorldApplier