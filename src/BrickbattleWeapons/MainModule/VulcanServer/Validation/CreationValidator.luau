--!strict
local CreationValidator = {}

function CreationValidator.validateReloadTime(player, data, weapon)

    local valid = true
  
    if not valid then
        print("Player " + player.Name + ", " + data.count + " -- did not wait long enough for " + weapon)
    end

    return valid
end

function CreationValidator.validateCount(player: Player, data, weapon)

    -- data.count should be exactly 1 greater than current count
    local valid = true

    if not valid then
        print("Player " + player.Name + ", " + data.count + " -- delivered out of order for " + weapon)
    end

    return valid
end

function CreationValidator.conductSecurityValidations(player: Player, data, weapon)
    -- TODO:
    -- validate position (except trowel)
    -- validate timestamp (workspace:GetServerTimeFromNow())
    -- validate character + tool (char must exist and tool should be a descendant of character)
    -- validate humanoid
    -- validate forcefield
    return true
end

return CreationValidator