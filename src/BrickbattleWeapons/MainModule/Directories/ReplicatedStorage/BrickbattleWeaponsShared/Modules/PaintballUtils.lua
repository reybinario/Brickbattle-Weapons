--!strict


local PaintballUtils = {}

function PaintballUtils.PaintballDamageMultiplier(Context, Projectile, HitPart): boolean | number
	
	local properPart = Context.Settings.PaintballGun.MultiplierPartNames[HitPart.Name]
		
	if Projectile.ProjectileType.Value == "PaintballGun" and properPart then

        if not Projectile.Damage or Projectile.Damage.Value == nil or type(Projectile.Damage.Value) ~= "number" then
            return 0
        end
		
		Projectile.Damage.Value *= 1 + 2 / 3
		
		return Projectile.Damage.Value
	end

	return false
end

function PaintballUtils.PaintballColorCallback(Context, Projectile, HitPart)
    local callback = require(Context.Modules.Callbacks.PaintballColorCallback)

    return callback(Projectile, HitPart)

end

PaintballUtils.PBG_Classes = {"Accoutrement", "Tool", "Accessory"}


return PaintballUtils
