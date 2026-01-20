--!strict

local DependencyUtils = {}

type VulcanSharedType = Folder & {
    Remotes: Folder & {
        AcquireConfig: RemoteFunction,
        AcquireState: RemoteFunction
    },
    PartCache: ModuleScript,
    WeaponTypes: ModuleScript
}

type ProjectilesFolder = Folder & {
    Active: Folder,
    Buffers: Folder,
    Extrapolated: Folder
}

local VulcanShared = game:GetService("ReplicatedStorage"):WaitForChild("VulcanShared") :: VulcanSharedType

local PartCache = require(VulcanShared.PartCache)
local part = Instance.new("Part")
part.Anchored = true
local partCache = PartCache.new(part, 200, workspace.Projectiles.Buffers)

function DependencyUtils.getRemotes()
    return VulcanShared.Remotes
end

function DependencyUtils.getPartCache()
    return partCache
end

function DependencyUtils.getActiveProjectiles()
    local Projectiles = workspace.Projectiles :: ProjectilesFolder
    return Projectiles.Active
end

function DependencyUtils.getVulcanShared(): VulcanSharedType
    return VulcanShared
end

return DependencyUtils