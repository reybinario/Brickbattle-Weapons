--!strict
-- GloriedRage, GFink, tyzone
-- Used in Superball, Paintball Gun, and Slingshot client modules.

local HitModule = {}

local Collections = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


local FPS = 0

local runConnection = RunService.Stepped:Connect(
	function(_, dt)
		FPS = 1 / dt
	end
)

function IsAcceptableHit(hit)
	return hit.Parent:FindFirstChildWhichIsA("Humanoid") or 
		not (
		Collections:HasTag(hit,"Projectile") 
			or (hit.CanCollide == false) 
			or hit.Name == "Handle"
	)
end

--[[
	This function handles the hit detection for both the Superball and Slingshot.
	Incorporates hit detection, damage and indicators all on the client to maximize
	experience.
]]
function HitModule:HandleHitDetection(Context, projectile)
	--print("__________")
	--print("Initializing:", PhysicsFolder.UniqueID.Value)
	local Delete = require(Context.ClientObjects:WaitForChild("Delete"))

	local Kill = require(Context.Modules:WaitForChild("Kill"))
	local Aesthetics = require(Context.Modules:WaitForChild("Aesthetics"))
	local PSPV = require(Context.Modules.Security:WaitForChild("PSPV"))
	local PaintballUtils = require(Context.Modules.PaintballUtils)
	local HitRemote = Context.Remotes:WaitForChild("Hit")
	local Settings = Context.Settings

	if not Context.Settings.Security.Master then
		runConnection:Disconnect()
	end
	
	if projectile:FindFirstChildWhichIsA("TouchTransmitter") then
		return
	end
	
	projectile.Ready.Value = true
	
	local player = Players.LocalPlayer
	local ProjectileType = projectile.ProjectileType.Value
	local setting = Settings[ProjectileType]
	local damage = projectile.Damage.Value
	
	local CanHalfDamage = setting.RicochetDamage
	local hitHumanoid = false
	local SetGlobal = false
	
	--local p0, v0, t0 = PhysicsFolder.LastSentPosition, PhysicsFolder.LastSentVelocity, PhysicsFolder.LastSentTime
	
	local TouchedConnection
	
	TouchedConnection = projectile.Touched:Connect(function(hit)
		
		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
		local Player = Players:GetPlayerFromCharacter(hit.Parent)
		local hat = table.find(PaintballUtils.PBG_Classes, hit.Parent.ClassName)

		local p1 = projectile.Position
		local v1 = projectile.Velocity
		local t1 = time()

		local CharacterData
		local FireToServer = false

		-- Play boing sound
		if projectile:FindFirstChild("Boing") then
			if not projectile.Boing.IsPlaying and (damage > 12) then
				projectile.Boing:Play()
			end
		end
		
		-- Evaluate SB fly status
		if ProjectileType == "Superball" and (Player and Player == Players.LocalPlayer) and not SetGlobal then
			if Settings.SuperballJump and not Settings.SuperballFly then
				if Context.CanSBFly then
					
					SetGlobal = true					
					task.delay(.1, function() 
						Context.CanSBFly = false 
					end)
				end				
			end
		end
		
		-- Evaluate damage
		if humanoid and not hitHumanoid then
			if Kill:CanDamage(player, humanoid, false) then
				hitHumanoid = true
				FireToServer = true

				PaintballUtils.PaintballDamageMultiplier(projectile, hit)
				
				-- Instantaneous damage for firer
				if Settings.InstantDamage then
					local DamageToApply = projectile.Damage.Value

					if humanoid.Health - DamageToApply <= 0 then
						DamageToApply = (humanoid.Health - .1)
					end

					humanoid:TakeDamage(DamageToApply)
					local newHealth = humanoid.Health
					task.spawn(function()
						local t0 = tick()
						while tick() - t0 < 3 do
							task.wait()
							if humanoid.Health <= 0 or math.abs(humanoid.Health - newHealth) > 1e-6 then return end
						end
						humanoid.Health = humanoid.MaxHealth --Other player hasn't healed in 3 seconds (they're lagging, or they're full health and we don't know it.)
					end)
				end
				
				-- Get character positions at multiple frames
				if Player then
					CharacterData = PSPV:CreateCharFrameTables(Player, Context.SlaveTimeTable)
				end
				
				-- Play sound
				if Context.Local.Hit ~= "None" then
					Context.ClientObjects.Sounds.Hit[Context.Local.Hit]:Play()
				end
				
				Aesthetics:CreateVisual(hit, player, false)
				
				TouchedConnection:Disconnect()
				
				if ProjectileType == "Superball" or ProjectileType == "Slingshot" then
					Delete(projectile, 1)
				end
				
			elseif humanoid.Parent ~= player.Character then
								
				if Context.Local.BlockedHit ~="None" then
					local Sound = Context.ClientObjects.Sounds.Blocked[Context.Local.BlockedHit]
					if not Sound.Playing then
						Sound:Play()
					end
				end
				
				if ProjectileType == "PaintballGun" and PaintballUtils.PaintballColorCallback(hit, player) and Settings.InstantDamage then
					FireToServer = true
					
					projectile.Ready.Value = false
					Aesthetics:PaintballColor(hit, projectile.Color)
					Aesthetics:ExplodePaintball(projectile)
					
					TouchedConnection:Disconnect()
				end
			end
		elseif CanHalfDamage and IsAcceptableHit(hit) then
			CanHalfDamage = false
			
			-- Halving value on the client for instant damage purposes
			if ProjectileType == "Superball" or ProjectileType == "Slingshot" then
				local function halfDamage()
					projectile.Damage.Value = projectile.Damage.Value / 2
				end
				
				local halfDmgDelay = Settings.Ricochet.HalfDamageDelay
				local resetDelay = Settings.Ricochet.ResetStateDelay
				
				local function evaluateRicochet()
					if projectile.Damage.Value <= 3 then
						Delete(projectile, .2)
					else
						CanHalfDamage = true -- reset bool
					end
				end
				
				task.delay(halfDmgDelay, halfDamage)
				task.delay(resetDelay, evaluateRicochet)
			end
		end
		
		if IsAcceptableHit(hit) or (hat and ProjectileType == "PaintballGun" ) then
			FireToServer = true

			if ProjectileType == "PaintballGun" then
				if PaintballUtils.PaintballColorCallback(hit, player) and Settings.InstantDamage then
					Aesthetics:PaintballColor(hit, projectile.Color)
				end
				
				if humanoid ~= player.Character.Humanoid and not hat then
					TouchedConnection:Disconnect()
					
					projectile.Ready.Value = false
					Aesthetics:ExplodePaintball(projectile)
				end				
			end	
		end
		
		if FireToServer then
			local ID_array = {
				projectile.ProjectileType.Value, -- string
				projectile.Count.Value -- integer
			}
			
			
			local sendingTable = {
				ID_array, 
				hit,  -- hit part
				projectile.Damage.Value, -- integer,
				Context.ServerTime.Value
			}
			
			if Context.Settings.Security.Master then
				
				local securityInfo = {
					p1, v1, t1, -- post hit position, velocity, and time
					CharacterData, -- table with cframe of char data (nil if security is off)
					FPS
				}
				
				for _ = 1, #securityInfo do
					table.insert(sendingTable, securityInfo)
				end
			end
				
			HitRemote:FireServer(table.unpack(sendingTable))
		end
	end)
end

return HitModule
