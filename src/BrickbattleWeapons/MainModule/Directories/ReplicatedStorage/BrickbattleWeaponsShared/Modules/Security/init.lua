--!strict
local Security = {}

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local INTERP_CONSTANT = .138

local function findFolder(Player,Type)
	return workspace:FindFirstChild("Projectiles"):FindFirstChild(Type):FindFirstChild(Player.Name)
end

local countsKeys = {
	Superball = "Superballs";
	Rocket = "Rockets";
	PaintballGun = "Paintballs";
	Bomb = "Bombs";
	Trowel = "Walls";
	Slingshot = "Pellets";
}

function Security:GetPhysicsFolder(ID_array, PlayerFired, DontWarn)
	local ActiveFolder = findFolder(PlayerFired, "Active")

	local PhysicsFolder = ActiveFolder:FindFirstChild(ID_array[1]..ID_array[2])
		
	local success, err = pcall(function()
		assert(PhysicsFolder, "PhysicsFolder does not exist.")

		assert(#PhysicsFolder:GetChildren() > 0, "PhysicsFolder has no children.")

		assert(PhysicsFolder.creator.Value == PlayerFired, "Creator value does not match firing player, value:" + PhysicsFolder.creator.Value)
		assert(PhysicsFolder.Active.Value == true, "PhysicsFolder is inactive!")
	end)

	if success then
		return PhysicsFolder
	elseif err then
		if not DontWarn then
			warn(
				"\n Error verifying PhysicsFolder...",
				"\n ID:",PlayerFired.Name.." "..ID_array[1]..ID_array[2],
				--"\n Count:", _G.BB.ProjectileCounts[PlayerFired.Name][countsKeys[ID_array[1]]],
				"\n Error:",err
			)
			--for _, obj in pairs(ActiveFolder:GetChildren()) do
			--	print(obj.Name)
			--end
		end
		return false
	end
end

function Security:ApproveActivation(Player, name, server)
	
	local Character = Player.Character
	
	local tool = Character and Character:FindFirstChildWhichIsA("Tool")

	if tool == nil then
		--print(Player, name, "NO TOOL FOUND", Character)
		return false
	end
	
	if tool and name then
		if tool.Name ~= name then
			--print(Player, name, "WRONG TOOL FOUND")
			return false
		end
	end

	if tool.Enabled == false or not tool:FindFirstChild("Activation") then
		--print(Player, name, "TOOL NOT ENABLED")
		return false
	end
	
	local deathCheck = true
	
	if server then
		deathCheck = _G.BB.Settings.Security.Master
	end

	if Character.Humanoid.Health > 0 or not deathCheck then
		if (tool.Name == "Sword" or tool.Name == "Trowel") 
			or Character:FindFirstChildWhichIsA("ForceField") ~= nil then
			return tool
		else
			--print(Player, name, "FORCEFIELDED")
		end
	else
		--print(Player, name, "PLAYER DEAD")
	end
end

-- approves initial positions, velocities, etc
function Security:ApproveInit(PhysicsFolder, handle)
	
	local projectileType = PhysicsFolder.ProjectileType.Value
	local creator = PhysicsFolder.creator.Value
	
	local character = creator.Character
	local head = character.Head
	
	local Settings = _G.BB.Settings	
	
	if not self:ApproveActivation(creator, projectileType, true) then
		--print(PhysicsFolder.Name, "denied activation approval.")
		return false
	end
	
	if Settings.Security.Master then
		if projectileType == "Slingshot" then

			local initPos = PhysicsFolder.LatestPosition.Value
			--local initVel = PhysicsFolder.LatestVelocity.Value
			--local initTime = PhysicsFolder.LatestTime.Value	

			local MovementVector = head.Velocity * INTERP_CONSTANT
			local projPos = head.Position + MovementVector

			local vector2 = Vector2.new(initPos.X, initPos.Z)
			local vector1 = Vector2.new(projPos.X, projPos.Z)

			local Magnitude2D = (vector2 - vector1).Magnitude
			local Magnitude3D = (initPos - projPos).Magnitude

			local Cushion2D = Settings.Slingshot.SpawnDistance + 5
			local Cushion3D = Settings.Slingshot.SpawnDistance * 3

			if Magnitude2D > Cushion2D or Magnitude3D > Cushion3D then

				if Settings.Security.Initial.Warn then
					warn(
						"\n High initial displacement: "..PhysicsFolder.UniqueID.Value,
						"\n 2D Distance: "..Magnitude2D,
						"\n 3D Distance:"..Magnitude3D -- might as well print this too
					)
				end

				if Settings.Security.Initial.Deactivate then
					Debris:AddItem(PhysicsFolder,0)
					PhysicsFolder:Destroy()
					return false
				end
			end
			
		else
			
			local initPos = projectileType == "Rocket"
				and PhysicsFolder.Origin.Value.Position 
				or PhysicsFolder.LatestPosition.Value
			
			--local initVel = PhysicsFolder.LatestVelocity.Value
			--local initTime = PhysicsFolder.LatestTime.Value	

			-- Check velocity
			--[[
			local Vector = initVel.Magnitude--/initCF.LookVector
			local Average = (Vector.X + Vector.Y + Vector.Z)/3
			local Difference =math.abs(Average-Settings.Superball.Speed) 
			if Difference>Settings.Security.Initial.SuperballVelocity then
				if Settings.Security.Initial.Warn then
					warn(
						"\n Bad initial velocity: "..PhysicsFolder.UniqueID.Value,
						"\n Vector speed:",Vector,
						"\n Average: "..Average,
						"\n Difference: "..Difference
					)
				end
				if Settings.Security.Initial.Deactivate then
					PhysicsFolder:Destroy()
					self.BufferObjectValue.Value = nil
					self:CreatePhysicsFolder();
					return
				end
			end
			]]

			local vector2 = Vector2.new(initPos.X, initPos.Z)
			local vector1 = Vector2.new(head.Position.X, head.Position.Z)
			
			local Magnitude2D = (vector2 - vector1).Magnitude
			local Magnitude3D = (initPos - head.Position).Magnitude
			
			local limit2d = Settings.Security.Initial[projectileType.."2D"]
			local limit3d = Settings.Security.Initial[projectileType.."3D"]

			if Magnitude2D > limit2d or Magnitude3D > limit3d then
				if Settings.Security.Initial.Warn then
					warn(
						"\n High initial displacement: "..PhysicsFolder.UniqueID.Value,
						"\n 2D Distance: "..Magnitude2D,
						"\n 3D Distance:"..Magnitude3D -- might as well print this too
					)
				end
				if Settings.Security.Initial.Deactivate then
					PhysicsFolder:Destroy()
					return false
				end
			end
		end
	end
	
	return true
end

function Security:ApproveUpdate(PhysicsFolder, InfoArray, UpdateSet, DeltaTime)
	local Parabola = require(script.Parabola)
	
	local RemoteSender = PhysicsFolder.creator.Value
	local ProjectileType = PhysicsFolder.ProjectileType.Value
	
	if _G.BB.Settings.Security.Master then
		
		if ProjectileType == "Superball" or ProjectileType == "Slingshot" or ProjectileType == "PaintballGun" then
			local LatestPosition = PhysicsFolder.LatestPosition
			local LatestVelocity = PhysicsFolder.LatestVelocity
			local LatestTime = PhysicsFolder.LatestTime

			local p0 = LatestPosition.Value
			local v0 = LatestVelocity.Value
			local p1 = InfoArray[2]
			local PositionMagnitude = (p1 - p0).Magnitude

			local fallout = _G.BB.Settings.Security.Fallout[ProjectileType]
			local g = Vector3.new(0, -workspace.Gravity, 0)

			if not PhysicsFolder.Hacking.Value 
				and not Parabola:Check(p0, v0, g, p1, fallout) then

				if UpdateSet.Warn then
					warn("Projectile Path Verification failed: Position update rejected.")
				end

				if UpdateSet.Deactivate then
					PhysicsFolder.Hacking.Value = true
					PhysicsFolder.Active.Value = false
							--[[local sbpre = game.ReplicatedStorage.SBVis:Clone()
							sbpre.Parent = game.Workspace
							sbpre.BrickColor = BrickColor.new("Bright red")
							sbpre.Position = p1

							local sbpost = game.ReplicatedStorage.SBVis:Clone()
							sbpost.Parent = game.Workspace
							sbpost.BrickColor = BrickColor.new("Bright green")
							sbpost.Position = p0]]

					return false
				end
			end
			
		elseif ProjectileType == "Rocket" then
			local LatestDistance = PhysicsFolder.LatestDistance
			--local LatestVelocity = PhysicsFolder.LatestVelocity

			local OldDistance = LatestDistance.Value
			--local OldVelocity = LatestVelocity.Value
			local NewDistance = InfoArray[2]

			local Difference = NewDistance - OldDistance
			
			if (Difference > UpdateSet.Rocket or Difference < 0) then
				if UpdateSet.Warn then
					warn(
						"\n Bad distance change: "..PhysicsFolder.Name,
						"\n Difference: "..Difference
						--"\n DT: "..DeltaTime
					)
				end
				if UpdateSet.Deactivate then
					PhysicsFolder.Exploded.Value = true
					PhysicsFolder.Active.Value = false
					return false
				end
			elseif Difference == 0 then
				if UpdateSet.Warn then
					warn(
						"\n Zero distance change: "..PhysicsFolder.Name,
						"\n Difference: "..Difference
						--"\n DT: "..DeltaTime
					)
				end
			end
			
		elseif ProjectileType == "Bomb" then
			local Position1 = PhysicsFolder.LatestPosition.Value
			local Position2 = InfoArray[2]
			local PositionMagnitude = (Position2-Position1).Magnitude

			if PositionMagnitude > UpdateSet.Bomb then
				if UpdateSet.Warn then
					warn(
						"\n High displacement:",PhysicsFolder.Name,
						"\n Magnitude:",PositionMagnitude,
						"\n Velocity:",PhysicsFolder.LatestVelocity.Value
						--"\n DT:",DeltaTime
					)
				end
				if UpdateSet.Deactivate then
					PhysicsFolder.Active.Value = false
					return false
				end
			end

			local Velocity1 = PhysicsFolder.LatestVelocity.Value
			local Velocity2 = InfoArray[3]
			local VelocityMagnitude = (Velocity2-Velocity1).Magnitude
				if VelocityMagnitude>UpdateSet.BombVelocity then
					if UpdateSet.Warn then
						warn(
							"\n High acceleration: "..PhysicsFolder.Name,
							"\n Magnitude: "..VelocityMagnitude,
							"\n New velocity:",Velocity2,
							"\n Old velocity:",Velocity1
							--"\n DT:",DeltaTime
						)
					end
					if UpdateSet.Deactivate then
						PhysicsFolder.Active.Value = false
						return false
					end
				end


			local Time =  InfoArray[4]
			local CurrentTime = PhysicsFolder.LatestTime.Value
			-- DeltaTime = Time since last update
			if not(Time > (CurrentTime + .05) and (DeltaTime + CurrentTime - Time < .5)) then
				if UpdateSet.Warn then
					warn(
						"\n Bad incoming time: "..PhysicsFolder.Name,
						"\n Time: "..Time,
						"\n CurrentTime:",CurrentTime,
						"\n DT:",DeltaTime
					)
				end
				if UpdateSet.Deactivate then
					PhysicsFolder.Active.Value = false
					return false
				end
			end
		
		end
		
	end
	
	return true
end

function Security:ApproveExplode(PhysicsFolder, ExplPosData, Parts, HitPart, DirectHitCharacterData, RadiusCharacterData, RocketCFrame)
	local Settings = _G.BB.Settings	
	
	local Kill = require(_G.BB.Modules.Kill)
	local PSPV = self.PSPV
	local ExplosionCallback = require(_G.BB.Modules.Callbacks.ExplodeMaster)

	local ProjectileType = PhysicsFolder.ProjectileType.Value
	local playerFired = PhysicsFolder.creator.Value
	
	local directCharData = DirectHitCharacterData
	local Radius = Settings[ProjectileType].Radius
	local Multiplier = Settings.Security.Hit.RadiusMultiplier -- Current default 5, 5*4=20 for rocket

	local ExplosionPosition = ExplPosData

	local ID = playerFired.Name.."_"..PhysicsFolder.Name
	
	local SecurityPart = self.SecurityPart

	if Settings.Security.Master then
		-- Verify rocket hit a part
		
		if ProjectileType == "Rocket" then
			if HitPart then
				local Humanoid = HitPart.Parent:FindFirstChildWhichIsA("Humanoid")
				if (Humanoid
					and Players:GetPlayerFromCharacter(Humanoid.Parent) 
					and Kill:CanDamage(playerFired,Humanoid,false)
					and Humanoid.RigType == Enum.HumanoidRigType.R6  
					and Humanoid.Health>0)  then
					local HitPlayer = Players:GetPlayerFromCharacter(Humanoid.Parent)

					local TrueHit = PSPV:Verify(directCharData,{RocketCFrame},Vector3.new(1, 1, 4),Enum.PartType.Block,HitPlayer.Name,PhysicsFolder)
					if not TrueHit then
						if Settings.Security.Hit.Warn then
							warn("PSPV failed for direct rocket hit:",ID,"Hit player:",HitPlayer)
						end
						if Settings.Security.Hit.Deactivate then
							PhysicsFolder.Active.Value = false		
							task.delay(2, function() PhysicsFolder:Destroy() end)
							return false
						end
					end
				elseif not Humanoid then
					SecurityPart.Shape = Enum.PartType.Block
					SecurityPart.Size = Vector3.new(1, 1, 4)
					SecurityPart.CFrame = RocketCFrame
					local CollectedParts = SecurityPart:GetTouchingParts()
					SecurityPart.Shape = Enum.PartType.Block
					if not table.find(CollectedParts,HitPart) then
						if Settings.Security.Hit.Warn then
							warn("Rocket's HitPart not touching rocket for",ID,"Hit:", HitPart:GetFullName())
						end
					end
				end
			else
				if Settings.Security.Hit.Warn then
					warn("Rocket's HitPart is nil for",ID)
				end
			end

			-- Ensure rocket did not explode too far away
			local OldDistance = PhysicsFolder.LatestDistance.Value
			local Difference = ExplPosData-OldDistance
			if Difference>Settings.Security.Hit.RocketExplode then
				if Settings.Security.Hit.Warn then
					warn(
						"\n High explosion displacement: "..ID,
						"\n New distance: "..ExplPosData,
						"\n Old distance: "..OldDistance,
						"\n Difference: "..Difference
					)
				end
				if Settings.Security.Hit.Disable then
					PhysicsFolder.Active.Value = false		
					task.delay(2, function() PhysicsFolder:Destroy() end)
					return false
				end
			end
		elseif ProjectileType == "Bomb" then
			if Settings.Security.Master then
				local LastTime = PhysicsFolder.LatestTime.Value
				-- Ensure bomb did not explode too quickly
				if LastTime<Settings.Security.Hit.BombTime then
					if Settings.Security.Hit.Warn then
						warn(
							"\n Quick explosion: "..ID,
							"\n LastTime: "..LastTime
						)
					end
					if Settings.Security.Hit.Disable then
						PhysicsFolder.Active.Value = false	
						task.delay(2, function() PhysicsFolder:Destroy() end)
						return false
					end
				end
			end
		end
	end
	
	-- Grab parts in same vicinity
	local CollectedParts = {}
	if Settings.Security.Master then
		SecurityPart.Size = Vector3.new(Radius*2,Radius*2,Radius*2)
		SecurityPart.Position = ExplosionPosition
		CollectedParts = SecurityPart:GetTouchingParts()
	end

	local Humanoids = {}
	local ApprovedParts = {}

	-- Check distance from explosion, make exception for large parts
	for _, Part in pairs(Parts) do
		-- Verify part
		if not Part or not workspace:IsAncestorOf(Part) or Part.Anchored then
			continue
		end

		if ExplosionCallback(Part, PhysicsFolder.creator.Value) == false then
			continue
		end

		-- Create a dictionary with humanoids
		-- Humanoids[Humanoid] = {CharPart,CharPart2}
		
		local Humanoid = Part.Parent:FindFirstChildWhichIsA("Humanoid") -- old, only includes character limbs
		--local Humanoid = (function() -- new, includes accessories
		--	local Character = Part:FindFirstAncestorOfClass("Model")
		--	if Players:GetPlayerFromCharacter(Character) then
		--		return Character:FindFirstChildOfClass("Humanoid")
		--	end
		--end)()
		
		if Humanoid then
			if not Humanoids[Humanoid] then
				Humanoids[Humanoid] = {Part}
			else
				table.insert(Humanoids[Humanoid],Part)
			end
			continue
		end


		--[[
		Makes an exception for large, moving parts that were not collected
		by the Server explosion.
		
		** This stinks and is probably unnecessary
		]]
		if Settings.Security.Master and not table.find(CollectedParts, Part) then
			local DistanceBetweenCenters = (ExplosionPosition - Part.Position).Magnitude
			local AverageDistanceFromCenter = (Part.Size.X / 2 + Part.Size.Y / 2 + Part.Size.Z / 2) / 3

			-- Constraint is really only necessary for large, moving parts but whatever
			if DistanceBetweenCenters > Radius * Multiplier and AverageDistanceFromCenter + Radius < Radius * Multiplier then
				if Part.Name ~= "Handle" then
					if Settings.Security.Hit.Warn then
						local FullName = Part:GetFullName()

						warn("--------------------",
							"\n Part is far from explosion: "..ID,
							"\n Distance: "..DistanceBetweenCenters,
							"\n Part: "..FullName,
							"\n Part pos: ",Part.Position,
							"\n Expl pos: ",ExplosionPosition,
							"\n Part average from center: "..AverageDistanceFromCenter
						)
					end
					if Settings.Security.Hit.Disable then
						-- Part is not blown up and any possible humanoid is not damaged
						continue	
					end
				end
			end
		end
		table.insert(ApprovedParts,Part)
	end

	--[[
	This is our security check for hit characters. It uses
	a system called Past Server Position Verification (coined
	by GFink). 
	]]
	local ApprovedHumanoids = {}
	for Humanoid,CharPartArray in pairs(Humanoids) do
		local HitPlayer = Players:GetPlayerFromCharacter(Humanoid.Parent)
		if HitPlayer
			and Kill:CanDamage(playerFired, Humanoid, false)
			and Humanoid.RigType == Enum.HumanoidRigType.R6 
			and Settings.Security.Master 
			and Humanoid.Health > 0 then

			local TrueHit = PSPV:Verify(
				{RadiusCharacterData[HitPlayer.Name]},
				{CFrame.new(ExplosionPosition)},
				Vector3.new(Radius*2, Radius*2, Radius*2),
				Enum.PartType.Ball,
				HitPlayer.Name,
				PhysicsFolder
			)

			-- Approve
			if TrueHit then
				ApprovedHumanoids[Humanoid] = CharPartArray
			else
				warn("PSPV failed: Past character position not touching EXPLOSION.","\n Hit position:",ExplosionPosition)
			end
		else
			ApprovedHumanoids[Humanoid] = CharPartArray
		end
	end
	
	return ApprovedHumanoids, ApprovedParts
end

function Security:ApproveHit(PhysicsFolder, HitPlayer, HitPart, p1, v1, t1, CharacterData, ClientPhysicsFPS)
	local PSPV = self.PSPV
	local Parabola = self.Parabola

	local ka, kb, kc, kd, ke, kf, Lm, Mm -- Ewwww
	local HitPosition, HitVelocity, HitTime, SameParabola
	local HitPositionCandidates = {}
	
	local creator = PhysicsFolder.creator.Value
	local ProjectileType = PhysicsFolder.ProjectileType.Value

	local LatestPosition = PhysicsFolder:FindFirstChild("LatestPosition")
	local LatestVelocity = PhysicsFolder:FindFirstChild("LatestVelocity")
	local LatestTime = PhysicsFolder:FindFirstChild("LatestTime")

	local p0 = LatestPosition.Value
	local v0 = LatestVelocity.Value
	local t0 = LatestTime.Value
	
	if _G.BB.Settings.Security.Master then
		local Hacking = PhysicsFolder:FindFirstChild("Hacking")

		local Accel = Vector3.new(0, 0, 0)

		local VectorForce = PhysicsFolder:FindFirstChild("VectorForce")
		local Mass = PhysicsFolder:FindFirstChild("Mass")
		if VectorForce and Mass then
			Accel = VectorForce.Value / Mass.Value 
		end

		Accel += Vector3.new(0, -workspace.Gravity, 0)

		HitPosition, HitVelocity, HitTime, SameParabola, ka, kb, kc, kd, ke, kf, Lm, Mm = Parabola:FindTouchPoint(Accel,   p0, v0, t0,   p1, v1, t1)
		HitPositionCandidates = {CFrame.new(HitPosition)}

		if SameParabola then
			HitPosition, HitVelocity, HitTime = p1,v1,t1
			if not Parabola:Check(p0, v0, Accel, p1, _G.BB.Settings.Security.Fallout[ProjectileType]) then

				if _G.BB.Settings.Security.Hit.Warn then
					warn("Projectile Touch Verification failed: Same-parabola touch position REJECTED.")

					if HitPlayer then
						warn("Failed when hitting a player:", HitPlayer.Name, HitPart.Name)
					end
				end

				if _G.BB.Settings.Security.Hit.Deactivate then
					if Hacking then
						Hacking.Value = true
					end
					PhysicsFolder.Active.Value = false
					return false
				end
			end
			
			-- Post-touch position is confirmed, now we need to find candidates for the touch pos.
			-- Physics get throttled at FPS < 15.
			ClientPhysicsFPS = math.max(ClientPhysicsFPS, 15)
			HitPositionCandidates = {}
			for i = 0, 4 do
				local HitTimeCandidate = t1 - (i/4) * (1 / ClientPhysicsFPS)
				local HitPosCandidate,_ = Parabola:Eval(p1, v1, Vector3.new(0, -workspace.Gravity, 0), t1, HitTimeCandidate)
				table.insert(HitPositionCandidates, CFrame.new(HitPosCandidate))
			end
		end

		local DELTA_T = t1-HitTime

		if (t1-t0 > 0) then 
			if (not Hacking or Hacking.Value == false)
				and not SameParabola 
				and (Parabola:Check(p0, v0, Accel, HitPosition, _G.BB.Settings.Security.Fallout[ProjectileType]) == false) then

				if _G.BB.Settings.Security.Hit.Warn then
					warn("Projectile Touch Verification for".." failed: Normal touch position REJECTED.")

					if HitPlayer then
						warn("Failed when hitting a player:",HitPlayer.Name, HitPart.Name)
					end
				end
				if _G.BB.Settings.Security.Hit.Deactivate then
					if Hacking then
						Hacking.Value = true
					end
					PhysicsFolder.Active.Value = false
					return false
				end
			elseif not SameParabola then
				PhysicsFolder.LatestPosition.Value = p1
				PhysicsFolder.LatestVelocity.Value = v1
				PhysicsFolder.LatestTime.Value = t1
			end
		end
		
		-- No current PSPV security offered for NPCs.
		if HitPlayer then 
			local Size = ProjectileType == "Superball" and Vector3.new(2,2,2) or Vector3.new(1,1,1)
			local TrueHit = PSPV:Verify(
				CharacterData, 
				HitPositionCandidates, 
				Size, 
				Enum.PartType.Ball, 
				HitPlayer.Name, 
				PhysicsFolder, 
				SameParabola)

			if not TrueHit then
				if _G.BB.Settings.Security.Hit.Warn then
					warn("PSPV failed: Past character position not touching projectile hit position.","SameParabola:",SameParabola)
				end
				if _G.BB.Settings.Security.Hit.Deactivate then
					PhysicsFolder.Active.Value = false
					return false
				end
			end
		end
	end
	
	return true
end

function Security:ApproveFuturePositions(Player,LocalCFrames)
	if not _G.BB.Settings.Security.Master then
		return true
	end 
	if not _G.BB.Settings.Security.FuturePositionApproval then
		return true
	end
	local AlottedTime = _G.BB.Settings.Security.AllowedTime
	local Distance = _G.BB.Settings.Security.AcceptableDistance
	-- approve character position (occurs post-hit)
	local Character  = Player.Character
	if not Character then
		return false
	end
	local start = tick()
	local c
	local approved = {}
	local bestMags = {0,0,0}
	-- player has 1 second to get to that position
	c = game:GetService("RunService").Heartbeat:Connect(function()
		if tick()-start>.2 and #approved~=3 then
			warn(Player.Name," never reached future positions.",#approved)
			-- Do something here
			c:Disconnect()
		end
		for i,v in pairs(LocalCFrames) do
			if approved[i] then
				continue
			end
			local Mag = (v[2].Head.Position-Character.PrimaryPart.Position).Magnitude
			if Mag<bestMags[i] then
				bestMags[i]  = Mag
			end
			if Mag<Distance then
				approved[i] = true
			end
		end
		if #approved == 3 then
			--print("Approved future positions for",Player.Name)
			c:Disconnect()
		end
	end)
end

function Security:ApproveHandlePositions(Player,LocalCFrames)
	if not _G.BB.Settings.Security.Master then
		return true
	end 
	for _,frametable in pairs(LocalCFrames) do
		local char = frametable[2]
		local cf = char.Sword
		if cf then
			local mag = (cf.Position - char.Head.Position).Magnitude
			if mag > 3.8 then
				warn("High handle-root distance for:",Player)
				return false
			end
		end
	end
	return true
end

function Security.init(SecurityPart, SecurityDummy, TimeValue)
	self.SecurityPart = SecurityPart
	
	self.Parabola = require(script:WaitForChild("Parabola"))
	self.PSPV = require(script:WaitForChild("PSPV"))
	
	self.PSPV:Init(SecurityPart, SecurityDummy, TimeValue)
end

return Security
