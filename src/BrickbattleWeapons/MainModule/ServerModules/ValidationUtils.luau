--!strict
local ValidationUtils = {}

function ValidationUtils.validateReloadTime(Context, player, data, weapon)

    local lenientReloadTime = math.max(Context.Settings[weapon].ReloadTime - 1, Context.Settings[weapon].ReloadTime * .6)

    local valid = time() - Context.WeaponData[player.Name][weapon].LastUsed >= lenientReloadTime
    
    if not valid then
        print("Player " + player.Name + ", " + data.count + " -- did not wait long enough for " + weapon)
    end

    return valid
end

function ValidationUtils.validateCount(Context, player, data, weapon)
    
    -- data.count should be exactly 1 greater than current count
    local valid = data.count - Context.WeaponData[player.Name][weapon].Count == 1
   
    if not valid then
        print("Player " + player.Name + ", " + data.count + " -- delivered out of order for " + weapon)
    end

    return valid
end


return ValidationUtils