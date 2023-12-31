--!strict
local Hit = {}

function Hit.init(Context)
	--[[
	Velocity parameter (v1) here can be spoofed, as we can't verify its direction component.
	Can't verify with a raycast because a ray is a singular collision point, 
	while the ball is a 3D collision box whose collision effects we cannot replicate

	p1 = PostPosition
	v1 = PostVelocity
	t1 = PostTime
	]]
    local Players = game:GetService("Players")
	local Security = require(Context.Modules.Security)
    local Kill = require(Context.Modules.Kill)
    local Aesthetics = require(Context.Modules.Aesthetics)
    local PaintballUtils = require(Context.Modules.PaintballUtils)
	
    Context.Remotes.Hit.OnServerEvent:Connect(function(playerFired, ID_array, HitPart, sentDmg, reportedServerTime, p1, v1, t1, CharacterData, ClientPhysicsFPS)
		local Now = time()
		
		local PhysicsFolder = Security:GetPhysicsFolder(ID_array, playerFired, true)
		
		if not PhysicsFolder then
			return
		end
		
		local shouldCancel = Context.Settings.CancelHitIfAboveTimeDelay
		
		if reportedServerTime then
			local ping = math.floor((game.ReplicatedStorage.SERVER_TIME.Value - reportedServerTime) * 1000)
			if ping < 0 then
				warn("[HIT]",playerFired,"potentially spoofed the ping value",ping,"ms")
				if shouldCancel then return end
			elseif ping > Context.Settings.MaxReportedTimeDelay then
				warn("[HIT]",playerFired,"ping too high",ping,"ms")
				if shouldCancel then return end
			end
		else
			warn("[HIT] No ping found for player",playerFired)
			if shouldCancel then return end
		end
		
		local ProjectileType = PhysicsFolder.ProjectileType.Value		
		
		local UniqueID = PhysicsFolder.UniqueID.Value
		local Humanoid = HitPart and (HitPart.Parent ~= nil) and HitPart.Parent:FindFirstChildWhichIsA("Humanoid")
		local HitPlayer = Humanoid and Players:GetPlayerFromCharacter(HitPart.Parent)
		
		local hat = HitPart and HitPart.Parent and table.find(PaintballUtils.PBG_Classes, HitPart.Parent.ClassName)
		
		if not Security:ApproveHit(PhysicsFolder, HitPlayer, p1, v1, t1, CharacterData, ClientPhysicsFPS) then
			return
		end
		
		if not HitPart or not HitPart.Parent then
			--if Context.Settings.Security.Update.Warn then
				--print("Projectile hit a local part!")
			--end
			return
		end
		
		-- Verify hit via PSPV and deal damage
		if Humanoid
			and not hat
			and PhysicsFolder.Active.Value
			and Kill:CanDamage(playerFired, Humanoid, Context.Settings[ProjectileType].SelfDamage) then
			
			local damage = PaintballUtils.PaintballDamageMultiplier(PhysicsFolder, HitPart) 
				or (Context.Settings.Security.Ricochet and PhysicsFolder.Damage.Value 
					or sentDmg)
			
			if not (ProjectileType == "PaintballGun") and (damage > Context.Settings[ProjectileType].Damage) then
				warn(playerFired.Name.." exceeded max damage with weapon:", ProjectileType)
				return
			end
			
			-- Tag, deal damage, and deactivate
			Kill:TagHumanoid(playerFired, Humanoid, PhysicsFolder, ProjectileType)
			Humanoid:TakeDamage(damage)
			Context.Remotes.Hit:FireAllClients(playerFired, HitPart, false) -- Hit indicators
			PhysicsFolder.Active.Value = false			
		end
		
		if ProjectileType == "PaintballGun" and PaintballUtils.PaintballColorCallback(HitPart, playerFired) then
			local ProjectileColor = PhysicsFolder.RandomColor.Value
			Aesthetics:PaintballColor(HitPart, ProjectileColor)
		end
		
		if not HitPart.CanCollide and 
			(playerFired.Character:IsAncestorOf(HitPart)) and 
			not Context.Settings[ProjectileType].SelfDamage then
			return
		end
				
		if ProjectileType == "PaintballGun" and HitPart.CanCollide and not Humanoid then
			PhysicsFolder.Active.Value = false
			return
		end
		
		-- Half damage
		if Context.Settings.Security.Ricochet then
			local CanHalfDamage = PhysicsFolder:FindFirstChild("CanHalfDamage")
			if CanHalfDamage and CanHalfDamage.Value then
				CanHalfDamage.Value = false

				local function halfDamage()
					PhysicsFolder.Damage.Value = PhysicsFolder.Damage.Value / 2
				end

				local function evaluateRicochet()
					if PhysicsFolder.Damage.Value <= 3 then
						PhysicsFolder.Active.Value = false
					else
						CanHalfDamage.Value = true
					end
				end

				task.delay(Context.Settings.Ricochet.HalfDamageDelay, halfDamage)
				task.delay(Context.Settings.Ricochet.ResetStateDelay, evaluateRicochet)
			end
		end
		
	end)
end

return Hit