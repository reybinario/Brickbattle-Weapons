--!strict
local Explosion = {}

local Players = game:GetService("Players")
local Collections = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Limbs = {
	"LeftFoot",
	"LeftLowerLeg",
	"LeftUpperLeg",

	"RightFoot",
	"RightLowerLeg",
	"RightUpperLeg",

	"LeftHand",
	"LeftLowerArm",
	"LeftUpperArm",

	"Left Arm",
	"Right Arm",
	"Left Leg"
}

local DeadlyLimbs = {
	"RightHand",
	"RightLowerArm",
	"RightUpperArm",

	"HumanoidRootPart",
	"UpperTorso",
	"LowerTorso",

	"Right Arm",
	"Torso",

	"Head"
}

local function verifyTableElement(Table,Element)
	if not table.find(Table,Element) then
		table.insert(Table,Element)
		return true
	else
		return false
	end
end

local function isDeadlyLimb(part)
	return table.find(DeadlyLimbs, part.Name) ~= nil
end

local function canFlingPart(Part)
	local Model = Part:FindFirstAncestorWhichIsA("Model") 
	return not (
		Part.Anchored 
			or Part:FindFirstAncestorWhichIsA("Tool") 
			or Part:FindFirstAncestorWhichIsA("Accessory") 
			or Part:FindFirstChild("PhysicsFolder")
			or (Model and Model:FindFirstChildWhichIsA("Humanoid"))
			
	)
end

local function ClientFling(Part, Humanoid, Position, Explosion)
	-- Do not fling self if setting is off.
	local Mass = Part:GetMass()
	local LocalPlayer = Players.LocalPlayer
	local HitPlayer = Humanoid and Players:GetPlayerFromCharacter(Humanoid.Parent)
	local Creator = Explosion.creator.Value
	local ProjectileType = Explosion.ProjectileType.Value
	local Damage = Context.Settings[ProjectileType].Damage
	local SelfDamage = Context.Settings[ProjectileType].SelfDamage
	local Radius = Context.Settings[ProjectileType].Radius
	local ExplosionForce = Context.Settings[ProjectileType].ExplosionForce
	local ForceFactorOnSelf = Context.Settings.Explosions.ForceFactorOnSelf
	local ExplosionsBreakJointsOnClient = Context.Settings.Explosions.BreakJointsOnClient
	
	local IsBomb = Part.Name == LocalPlayer.Name.."'s Bomb"
	if (HitPlayer == Creator and Creator == LocalPlayer and Context.Settings.Explosions.FlingYou) then

		Force:ExertDirectionally(Position, Part, Radius, ExplosionForce * ForceFactorOnSelf, Mass)

	elseif (IsBomb and Context.Settings.Explosions.FlingBombs) then

		Force:ExertDirectionally(Position,Part,Radius,ExplosionForce,Mass)

	elseif not IsBomb and canFlingPart(Part) and Context.Settings.Explosions.FlingParts then

		if ExplosionsBreakJointsOnClient then
			for _, Weld in pairs(WeldTracker:GetWeldsByPart(Part)) do
				if BreakJointsCallback(Weld,Creator) then
					Weld:Destroy()
				end
			end
		end

		--If you fired the rocket/bomb, apply impulse to all debris.
		--You don't always netown it, but it shouldn't do anything in that case.
		Force:ExertLocally(Position, Part, Radius, ExplosionForce, Mass)
	end
end

-- Used in rocket and bomb client scripts
function Explosion:HandleHitDetection(Explosion: Part, HitPart, RocketPosition, DirectHitCFrames)
	local player = Players.LocalPlayer
	local localHum = player.Character.Humanoid
	
	local ProjectileType = Explosion.ProjectileType.Value
	local Damage = Context.Settings[ProjectileType].Damage
	local SelfDamage = Context.Settings[ProjectileType].SelfDamage
	local SelfDamageMultiplier = Context.Settings[ProjectileType].SelfDamageMultiplier
	
	-- Grab parts
	local TempConnection = Explosion.Touched:Connect(function() end)
	local TouchingParts = Explosion:GetTouchingParts()
	TempConnection:Disconnect()
	
	if HitPart and not table.find(TouchingParts,HitPart) then
		table.insert(TouchingParts,HitPart)	
	end
	
	Explosion.Active.Value = false -- Stop sending updates
	
	-- Rocket sends new distance, bomb sends cframe
	local ExplData = Explosion.Position
	if ProjectileType == "Rocket" then
        local OriginObject: Instance? = Explosion:FindFirstChild("Origin")

        if not OriginObject or not OriginObject:IsA("ObjectValue") then
            warn("Type error")
            return
        end

        if OriginObject.Value == nil then
            warn("Origin ObjectValue's value not found")
            retur
        end

        local Origin = OriginObject.Value

        if Origin == nil or not Origin:IsA("Part") then
            warn("Origin ObjectValue's value not found")
            return
        end

        local OriginPosition = Origin.Position
		ExplData = (Explosion.Position - OriginPosition).Magnitude
	end
	
	-- Determine what sounds to play, grab character positional data, + client dmg
	local HitCharacterCFrames = {}
	local Humanoids = {}
	local Killed = false
	local Blocked = false
	for i,Part in pairs(TouchingParts) do
		
		if ExplosionCallback(Part, Explosion.creator.Value) == false then
			continue
		end
		
		local Humanoid = Part.Parent:FindFirstChildWhichIsA("Humanoid")
		local position = RocketPosition and RocketPosition or Explosion.Position
		
		if Humanoid then
			if Kill:CanDamage(player,Humanoid,SelfDamage) then
				
				if not HitCharacterCFrames[Humanoid.Parent.Name] then
					HitCharacterCFrames[Humanoid.Parent.Name] = PSPV:CreateCharacterCFrameTable(Humanoid)
				end
				
				if not Context.Settings.Explosions.LimbRemoval or isDeadlyLimb(Part) then
					if verifyTableElement(Humanoids, Humanoid) then
						
						-- Instantaneous damage for firer
						if Context.Settings.InstantDamage then
							local DamageToApply = Damage * (player.Character:IsAncestorOf(Humanoid) and SelfDamageMultiplier or 1)
							
							if Humanoid.Health - DamageToApply <= 0 then
								DamageToApply = (Humanoid.Health - .1)
							end
							
							Humanoid:TakeDamage(DamageToApply)
							local newHealth = Humanoid.Health
							task.spawn(function()
								local t0 = tick()
								while tick() - t0 < 3 do
									task.wait()
									if Humanoid.Health <= 0 or math.abs(Humanoid.Health - newHealth) > 1e-6 then return end
								end
								Humanoid.Health = Humanoid.MaxHealth --Other player hasn't healed in 3 seconds (they're lagging, or they're full health and we don't know it.)
							end)
						end
						
						Killed = ((Humanoid.Health-Damage)<=0) and not player.Character:IsAncestorOf(Humanoid)
						
						Aesthetics:CreateVisual(Humanoid.Parent.PrimaryPart,player,true)
					end
				end
			else
				Blocked = not player.Character:IsAncestorOf(Humanoid)
			end
		end
		
		ClientFling(Part, Humanoid, position, Explosion)
	end
	
	if not Context.Settings.Security.PSPV then
		HitCharacterCFrames = {}
	end
	
	-- Play sound
	if Killed then
		if Context.Local.Hit~="None" then
			Context.ClientObjects.Sounds.Hit[Context.Local.Hit]:Play()
		end
	elseif Blocked then
		if Context.Local.BlockedHit ~="None" then
			Context.ClientObjects.Sounds.Blocked[Context.Local.BlockedHit]:Play()
		end
	end
	
	local ID_array = {Explosion.ProjectileType.Value, Explosion.Count.Value}

	local SERVER_TIME
	if game.ReplicatedStorage:FindFirstChild("SERVER_TIME") then
		SERVER_TIME = game.ReplicatedStorage.SERVER_TIME.Value
	end
	
	explodeRemote:FireServer(
		ID_array,
		ExplData,
		HitPart,
		TouchingParts,
		DirectHitCFrames,
		HitCharacterCFrames,
		SERVER_TIME
	)
	
end

-- Used in client Extrapolation module
function Explosion:ExtrapolateExplosion(ExtrapolatedProjectile, PhysicsFolder)
	
	PhysicsFolder.Exploded.Value = true
	
	local Radius = Context.Context.Settings[PhysicsFolder.ProjectileType.Value].Radius
	ExtrapolatedProjectile.Size = Vector3.new(Radius*2,Radius*2,Radius*2)
	
	local ProjectileType = PhysicsFolder.ProjectileType.Value
	local Damage = Context.Settings[ProjectileType].Damage
	local SelfDamage = Context.Settings[ProjectileType].SelfDamage
	
	local SoundName
	
	if ProjectileType == "Bomb" then
		SoundName = Context.Local.BombExplosion

		ExtrapolatedProjectile.Position = PhysicsFolder.LatestPosition.Value
		ExtrapolatedProjectile.Tick:Destroy()
	elseif ProjectileType == "Rocket" then
		SoundName = Context.Local.RocketExplosion
		
		ExtrapolatedProjectile.CFrame = (
			PhysicsFolder.Origin.Value 
				+ (PhysicsFolder.Origin.Value.lookVector 
					* PhysicsFolder.LatestDistance.Value
				)
		)
		ExtrapolatedProjectile.Swoosh:Destroy()
	end

	-- Client explosion sound
	local Sounds = ExtrapolatedProjectile:WaitForChild("Boom")
	local Sound = Sounds:FindFirstChild(SoundName)
	Sound.Parent = ExtrapolatedProjectile
	Sound:Play()
	
	Aesthetics:CreateCustomExplosion(PhysicsFolder.creator.Value, ExtrapolatedProjectile)
	
	local connection = ExtrapolatedProjectile.Touched:Connect(function() end)
	local CollectedParts = ExtrapolatedProjectile:GetTouchingParts()
	connection:Disconnect()
	
	for _,Part in pairs (CollectedParts) do
		
		if ExplosionCallback(Part, PhysicsFolder.creator.Value) == false then
			continue
		end
		
		local CharacterModel = Part:FindFirstAncestorOfClass("Model")
		local Humanoid = CharacterModel and CharacterModel:FindFirstChildOfClass("Humanoid")

		ClientFling(Part,Humanoid,ExtrapolatedProjectile.Position,PhysicsFolder)
	end
	
	Debris:AddItem(ExtrapolatedProjectile,5)	
end

function Explosion:HandleHumanoid(PhysicsFolder, Humanoid, CharPartArray, ExplosionPosition)
	-- When LimbRemoval is on, only hits to the torso/hrp, head, and right
	-- arm deal certain damage.
	
	local ProjectileType = PhysicsFolder.ProjectileType.Value
	local Damage = Context.Settings[ProjectileType].Damage
	local SelfDamage = Context.Settings[ProjectileType].SelfDamage
	local SelfDamageMultiplier = Context.Settings[ProjectileType].SelfDamageMultiplier
	local Radius = Context.Settings[ProjectileType].Radius
	local ExplosionForce = Context.Settings[ProjectileType].ExplosionForce
	
	local Player = PhysicsFolder.creator.Value
	local FirerHumanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	local HitPlayer = Players:GetPlayerFromCharacter(Humanoid.Parent)
	local Damaged = false

	for _, Part in pairs(CharPartArray) do
		if Kill:CanDamage(Player, Humanoid, SelfDamage) then
			
			if not Context.Settings.Explosions.LimbRemoval or isDeadlyLimb(Part)then
				if not Damaged then
					Damaged = true
					Kill:TagHumanoid(Player, Humanoid, PhysicsFolder, ProjectileType)
					Humanoid:TakeDamage(Damage * (Player.Character:IsAncestorOf(Humanoid) and SelfDamageMultiplier or 1))
					hitRemote:FireAllClients(Player,Humanoid.Parent.PrimaryPart, true)
				end
				
			elseif Context.Settings.Explosions.LimbRemoval then
				-- Break limb off (Try to prevent wild fling issue)
				Part:BreakJoints()
				Part.Massless = true
				Part.Parent = workspace
			end
		end
		
		if  Context.Context.Settings.Explosions.FlingEnemies then
			if Kill:CanDamage(Player, Humanoid, false, true) then
				
				--print("Flinging hum:",Part,Humanoid.Parent)
				Force:ExertDirectionally(ExplosionPosition, Part, Radius, ExplosionForce, Part:GetMass())
			end
		end
	end
end

function Explosion:BlowUpPart(PhysicsFolder, Part, ExplosionPosition)
	local Humanoid = Part.Parent:FindFirstChildWhichIsA("Humanoid") or Part.Parent.Parent:FindFirstChildWhichIsA("Humanoid")
	local Character = Humanoid and Humanoid.Parent
	local Player = Players:GetPlayerFromCharacter(Part.Parent)
	local ProjectileType = PhysicsFolder.ProjectileType.Value
	local Creator = PhysicsFolder.creator.Value

	if Collections:HasTag(Part, Context.Settings.Explosions.ExclusionTag) then
		return
	end
	
	if Part.Parent:IsA("Tool") then
		return
	elseif Part.Parent:IsA("Accessory") and Humanoid then
		if not Kill:CanDamage(Creator, Humanoid, false) or not Context.Settings.Explosions.LimbRemoval then
			return
		end
	end
	
	if Part.Anchored then return end
	
	-- Teammates trowel's are protected, unless setting is off
	if Collections:HasTag(Part,"TrowelWallBrick") and Context.Settings.Explosions.ProtectTeammateWalls then 
		local OwnerValue = Part.creator.Value
		if OwnerValue.Character then
			local ownerHumanoid = OwnerValue.Character:FindFirstChild("Humanoid")
			if ownerHumanoid and not Kill:CanDamage(PhysicsFolder.creator.Value,ownerHumanoid,true) then
				return
			end
		end
	end
	
	local firingPlayer = PhysicsFolder.creator.Value
	local PartJointsBroken = false

	-- Break joints assuming Context.Settings is on, and humanoid is either dead, 
	-- nil, or LR is on
	local destroyed = 0
	local welds = WeldTracker:GetWeldsByPart(Part)
	for _, Weld in pairs(welds) do
		if BreakJointsCallback(Weld, Creator) then
			Weld:Destroy()
			destroyed += 1
		end
	end
	
	-- Ensure mass is below threshold & fling
	local Mass = Part:GetMass()
	
	if Context.Settings.Explosions.FlingParts and destroyed == #welds then
		--print("Flinging part:",Part,Part.Parent)
		Force:Exert(ExplosionPosition,Part,Context.Settings[ProjectileType].Radius,Context.Settings[ProjectileType].ExplosionForce ,Mass)
	end
		
	-- Destroy
	if Mass < Context.Settings[ProjectileType].MaxMassToDestroy 
		and not Part:IsA("SpawnLocation")
		and not Humanoid
		and (Context.Settings.Explosions.DestroyParts
			or (
				Collections:HasTag(Part,"TrowelWallBrick")
				and Context.Settings.Explosions.DestroyTrowelWallsOverride
			)
		) then
		Part:Destroy()
	end
	
	if Context.Settings.Explosions.DebrisTime > 0 then
		Debris:AddItem(Part, Context.Settings.Explosions.DebrisTime)
	end
end

return Explosion