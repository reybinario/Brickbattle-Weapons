--!strict
local BrickbattleStateValidator = {}

function BrickbattleStateValidator.validateReloadTime(Context, player, data, weapon)

    local lenientReloadTime = math.max(Context.Settings[weapon].ReloadTime - 1, Context.Settings[weapon].ReloadTime * .6)

    local valid = time() - Context.WeaponData[player.Name][weapon].LastUsed >= lenientReloadTime
  
    if not valid then
        print("Player " + player.Name + ", " + data.count + " -- did not wait long enough for " + weapon)
    end

    return valid
end

function BrickbattleStateValidator.validateCount(Context, player: Player, data, weapon)

    -- data.count should be exactly 1 greater than current count
    local valid = data.count - Context.WeaponData[player.Name][weapon].Count == 1

    if not valid then
        print("Player " + player.Name + ", " + data.count + " -- delivered out of order for " + weapon)
    end

    return valid
end

function BrickbattleStateValidator.conductSecurityValidations(Context, player: Player, data, weapon)
    -- TODO:
    -- validate position (except trowel)
    -- validate timestamp (workspace:GetServerTimeFromNow())
    -- validate character + tool (char must exist and tool should be a descendant of character)
    -- validate humanoid
    -- validate forcefield
    return true
end

return BrickbattleStateValidator