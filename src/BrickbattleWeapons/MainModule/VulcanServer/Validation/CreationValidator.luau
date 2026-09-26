--!strict

local VulcanClient = script.Parent.Parent.Parent.VulcanClient.Common
local StateSchema = require(VulcanClient.StateSchema)
local Config = require(script.Parent.Parent.Management.Config)
local StateRepository = require(script.Parent.Parent.State.StateRepository)
local SuperballCore = require(script.Parent.SuperballValidationCore)

local CreationValidator = {}

function CreationValidator.validateReloadTime(player: Player, data: StateSchema.ProjectileState, weapon: string)

    local valid = true
    if weapon == "Superball" then
        local lastUsed = StateRepository.readPlayerWeaponField(player, "Superball", "lastUsed")
        valid = lastUsed ~= nil and (lastUsed < 0 or workspace:GetServerTimeNow() - lastUsed >= Config.get().Superball.ReloadTime)
    end

    if not valid then
        print("Player " .. player.Name .. ", " .. data.count .. " -- did not wait long enough for " .. weapon)
    end

    return valid
end

function CreationValidator.validateCount(player: Player, data: StateSchema.ProjectileState, weapon: string)

    -- The current client sends count 0 for its first shot, then increments modulo u16.
    local valid = true
    if weapon == "Superball" then
        local count = StateRepository.readPlayerWeaponField(player, "Superball", "counts")
        valid = count ~= nil and data.count == count % 65536
    end

    if not valid then
        print("Player " .. player.Name .. ", " .. data.count .. " -- delivered out of order for " .. weapon)
    end

    return valid
end

function CreationValidator.conductSecurityValidations(player: Player, data: StateSchema.ProjectileState, weapon: string)
    if weapon == "Superball" then
        local character = player.Character
        local root = character and character.PrimaryPart
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return false end
        local shot = data :: StateSchema.SuperballState
        local offset = shot.position - root.Position
        local speed = Config.get().Superball.ProjectileConfig.Speed
        local spawnDistance = Config.get().Superball.ProjectileConfig.SpawnDistance
        if offset.Magnitude < 0.001 then return false end
        -- No server-recorded aim snapshot exists yet. This only checks that
        -- launch velocity points along the spawn offset, not the player camera.
        local valid = SuperballCore.validateLaunch({
            position = shot.position, velocity = shot.velocity,
            firingPosition = root.Position, aimDirection = offset.Unit,
            ammoAvailable = true, -- no server ammo ledger exists yet
            elapsedSinceLastShot = 0, -- cooldown checked in validateReloadTime
            reloadTime = 0, spawnDistance = spawnDistance, speed = speed,
        })
        return valid
    end
    -- TODO:
    -- validate position (except trowel)
    -- validate timestamp (workspace:GetServerTimeFromNow())
    -- validate character + tool (char must exist and tool should be a descendant of character)
    -- validate humanoid
    -- validate forcefield
    return true
end

return CreationValidator
