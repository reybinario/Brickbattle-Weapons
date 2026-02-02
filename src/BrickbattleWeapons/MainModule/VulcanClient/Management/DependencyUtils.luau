--!strict

local DependencyUtils = {}

type VulcanSharedType = Folder & {
    Remotes: Folder & {
        AcquireConfig: RemoteFunction,
        AcquireState: RemoteFunction
    }
}

type ProjectilesFolder = Folder & {
    Active: Folder,
    Buffers: Folder,
    Extrapolated: Folder
}

local VulcanShared = game:GetService("ReplicatedStorage"):WaitForChild("VulcanShared") :: VulcanSharedType

function DependencyUtils.getRemotes()
    return VulcanShared.Remotes
end

function DependencyUtils.getActiveProjectiles()
    local Projectiles = workspace.Projectiles :: ProjectilesFolder
    return Projectiles.Active
end


return DependencyUtils