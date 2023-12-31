--!strict
-- Created by Tyzone, modified by GloriedRage

local Extrapolation = {}
local Physics = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local TickTimeStamps = { 
	0.4, 
	0.76, 
	1.084, 
	1.3756, 
	1.63804, 
	1.874236, 
	2.0868124, 
	2.27813116,
	2.450318044,
	2.6052862396, 
	2.74475761564, 
	2.870281854076, 
	2.9832536686684, 
	3.0849283018016 -- Looks like a wedge of cheese tbh
}

local InvalidClasses = {
	"Folder",
	"Model"
}

local LastUpdate = -10
local UpdateInterval = 1/6 -- in seconds

local LastRender = -10
local RenderInterval = 1/60 -- in seconds


local function validateTime(Now, Then, Interval, Update)
	local OutsideInterval = Now - Then > Interval
	if OutsideInterval then 
		if Update then
			LastUpdate = Now
		else
			LastRender = Now
		end
	end
	return OutsideInterval
end

local function getProjectileData(Projectile)
	local projectileType = Projectile.ProjectileType.Value
	local ID_array = {Projectile.ProjectileType.Value, Projectile.Count.Value}

	if not _G.BB.Settings.Extrapolation.Updates[projectileType] then
		return
	end

	if projectileType == "Superball" or projectileType == "Slingshot" or projectileType == "PaintballGun" then

		-- Send ID array, CFrame, and Velocity
		local PositionMag = (Projectile.CFrame.Position-Projectile.LastSentPosition.Value).Magnitude
		local VelocityMag = (Projectile.Velocity-Projectile.LastSentVelocity.Value).Magnitude
		
		if PositionMag > 1 or VelocityMag > 1 then

			Projectile.LastSentPosition.Value = Projectile.Position
			Projectile.LastSentVelocity.Value = Projectile.Velocity
			Projectile.LastSentTime.Value = time()

			return {ID_array, Projectile.Position, Projectile.Velocity, Projectile.LastSentTime.Value}
		end

	elseif projectileType == "Rocket" then

		local OriginPosition = Projectile.Origin.Value.Position
		local CurrentPosition = Projectile.Position
		local LastSentPosition = Projectile.LastSentPosition.Value
		local Distance = (CurrentPosition - OriginPosition).Magnitude
		local VelocityMag = (Projectile.Velocity-Projectile.LastSentVelocity.Value).Magnitude

		if (CurrentPosition - LastSentPosition).Magnitude > 1 or VelocityMag > 1 then

			Projectile.LastSentPosition.Value = CurrentPosition
			
			local array = {ID_array, Distance}
			
			-- only send if necessary
			--if _G.BB.Settings.Rocket.Speed ~= _G.BB.Settings.Rocket.InitialSpeed then
			--	table.insert(array, Projectile.Velocity)
			--end
			
			--if _G.BB.Settings.Extrapolation.PingCompensation.Rocket then
				
			--	-- physics replicator determines data based on position
			--	-- in sent array
			--	if #array == 2 then
			--		table.insert(array, Vector3.new(0,0,0))
			--	end
				
			--	table.insert(array, _G.BB.ServerTime.Value)
			--end

			return array
		end

	elseif projectileType == "Bomb" then
				
		local Now = tick()
		local TickDifference = Now - Projectile.LocalOriginTime.Value
		local PositionMag = (Projectile.CFrame.Position - Projectile.LastSentPosition.Value).Magnitude
		local VelocityMag = (Projectile.Velocity - Projectile.LastSentVelocity.Value).Magnitude

		if PositionMag > 1 or VelocityMag > .5 or TickDifference > .1 then
			
			Projectile.LastSentPosition.Value = Projectile.Position
			Projectile.LastSentVelocity.Value = Projectile.Velocity
			
			return {ID_array, Projectile.Position, Projectile.Velocity, TickDifference}
		end
	end
end

function Extrapolation:SendUpdateData()
	local PhysicsPacket = {}
		
	for _, Projectile in pairs(self.ClientActiveFolder:GetChildren()) do
		if not table.find(InvalidClasses, Projectile.ClassName) then
			
			if Projectile and Projectile.Active.Value then
				
				local ProjectileDataArray = getProjectileData(Projectile)

				if ProjectileDataArray then
					table.insert(PhysicsPacket, ProjectileDataArray)
				end
			end
		end
	end

	if #PhysicsPacket > 0 then
		self.UpdateRemote:FireServer(PhysicsPacket)
	end
end

-- Uses data from an added folder that contains physics values to replicate a projectile
function Extrapolation:Begin(PhysicsFolder)
	
	if PhysicsFolder:IsA("Model") then
		local CandidatePF = PhysicsFolder:FindFirstChild("PhysicsFolder")
		if CandidatePF then
			PhysicsFolder = CandidatePF
		else
			return
		end
	elseif not PhysicsFolder:IsA("Folder") then
		return
	end

	if not PhysicsFolder:WaitForChild("creator", 1/30) then
		warn("No creator value!")
		return
	end

	if not PhysicsFolder:FindFirstChild("ProjectileType") then
		warn("No projectile type!")
		return
	end

	local extrapProjectile
	local creator = PhysicsFolder.creator.Value
	
	local tickRender = nil
	
	if PhysicsFolder.ProjectileType.Value == "Superball" then

		-- Make new superball
		extrapProjectile = self.MakeSuperball(creator, "Superballs", nil, PhysicsFolder.RandomColor.Value)

		-- Update position upon value changed
		local latestPos = PhysicsFolder.LatestPosition
		latestPos.Changed:Connect(function()
			extrapProjectile.Position = latestPos.Value
		end)

		-- Update velocity upon value changed
		local latestVel = PhysicsFolder.LatestVelocity
		latestVel.Changed:Connect(function()
			extrapProjectile.Velocity = latestVel.Value
		end)
		
		-- Remove projectile upon inactivity
		local function checkActive()
			if PhysicsFolder.Active.Value == false then
				Debris:AddItem(extrapProjectile, 1)
			end
		end

		PhysicsFolder.Active.Changed:Connect(checkActive)

		-- Fire the superball!
		extrapProjectile.Position = latestPos.Value
		extrapProjectile.Velocity = latestVel.Value
		extrapProjectile.Parent = self.ExtrapolatedFolder

		extrapProjectile.Boing:Play()
		
		checkActive()

	elseif PhysicsFolder.ProjectileType.Value == "Slingshot" then
		extrapProjectile = self.MakePellet(creator, "Pellets")

		-- Update position upon value changed
		local latestPos = PhysicsFolder.LatestPosition
		latestPos.Changed:Connect(function()
			extrapProjectile.Position = latestPos.Value
		end)

		-- Update velocity upon value changed
		local latestVel = PhysicsFolder.LatestVelocity
		latestVel.Changed:Connect(function()
			extrapProjectile.Velocity = latestVel.Value
		end)
		
		-- Remove projectile upon inactivity
		local function checkActive()
			if PhysicsFolder.Active.Value == false then
				Debris:AddItem(extrapProjectile, 1)
			end
		end
		
		PhysicsFolder.Active.Changed:Connect(checkActive)
		
		-- Fire the pellet!
		extrapProjectile.Position = latestPos.Value
		extrapProjectile.Velocity = latestVel.Value
		extrapProjectile.Parent = self.ExtrapolatedFolder

		local Sound = extrapProjectile.SlingshotSounds:FindFirstChild(_G.BB.Local.SlingshotSound)
		if Sound then
			Sound.Parent = extrapProjectile
			Sound:Play()
		end
		
		checkActive()

	elseif PhysicsFolder.ProjectileType.Value == "PaintballGun" then
		extrapProjectile = self.MakePaintball(creator, "Paintballs", nil, PhysicsFolder.RandomColor.Value)
		
		-- Update position upon value changed
		local latestPos = PhysicsFolder.LatestPosition
		latestPos.Changed:Connect(function()
			extrapProjectile.Position = latestPos.Value
		end)

		-- Update velocity upon value changed
		local latestVel = PhysicsFolder.LatestVelocity
		latestVel.Changed:Connect(function()
			extrapProjectile.Velocity = latestVel.Value
		end)
		
		-- Explode paintball upon inactivity
		local function checkActive()
			if PhysicsFolder.Active.Value == false then
				self.Aesthetics:ExplodePaintball(extrapProjectile)
			end
		end
		
		PhysicsFolder.Active.Changed:Connect(checkActive)
		
		-- Fire the paintball!
		extrapProjectile.Position = latestPos.Value
		extrapProjectile.Velocity = latestVel.Value
		extrapProjectile.Parent = self.ExtrapolatedFolder

		checkActive()

	elseif PhysicsFolder.ProjectileType.Value == "Rocket" then
		
		extrapProjectile = self.MakeRocket(creator, nil, PhysicsFolder)
		
		local function determineOffset()
			local ClientTime = _G.BB.ServerTime.Value
			local ServerTime = PhysicsFolder.ServerTime.Value
			local SenderTime = PhysicsFolder.ClientTime.Value
			local TotalDelay = (ServerTime - SenderTime) + (ServerTime - ClientTime)
			local offset = TotalDelay * _G.BB.Settings.Rocket.Speed
			return offset
		end
		
		local origin = PhysicsFolder.Origin.Value
		local pingCompensation = _G.BB.Settings.Extrapolation.PingCompensation.Rocket and determineOffset()
		
		
		local progress = pingCompensation and (origin.lookVector * pingCompensation) or origin.lookVector
		local newCF = origin + progress

		extrapProjectile.CFrame = newCF

		local InitialVelocity = origin.lookVector * _G.BB.Settings.Rocket.InitialSpeed
		local Velocity = origin.lookVector * _G.BB.Settings.Rocket.Speed
		
		extrapProjectile.Velocity = InitialVelocity
		extrapProjectile.RocketVelocity.Velocity = InitialVelocity
		extrapProjectile.RocketVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		
		local tweenInfo = TweenInfo.new(_G.BB.Settings.Rocket.RampUpDuration, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(extrapProjectile.RocketVelocity, tweenInfo, {Velocity = Velocity})
		
		tween:Play()
		
		
		if _G.BB.Settings.RocketRiding and PhysicsFolder and not self.Kill:CanDamage(creator, self.Player.Character.Humanoid) then
			-- Can Collide true
			extrapProjectile.CanCollide = true

			Physics:SetPartCollisionGroup(extrapProjectile, "RideableRockets")

			-- Make dense
			local densityMultiplier = 140
			local OriginalProperties = PhysicalProperties.new(extrapProjectile.Material)
			extrapProjectile.CustomPhysicalProperties = PhysicalProperties.new(
				OriginalProperties.Density * densityMultiplier, OriginalProperties.Friction, OriginalProperties.Elasticity
			) -- SUPER dense so that you can actually ride the rocket

			--Adapt bodymovers to the new density
			extrapProjectile.Floater.Force *= densityMultiplier
			extrapProjectile.RocketVelocity.MaxForce *= densityMultiplier

			-- Make rigid
			local Part = Instance.new("Part")
			Part.Size = Vector3.new(.05,.05,.05)
			Part.Anchored = true
			Part.CanCollide = false
			Part.Position = PhysicsFolder.Origin.Value.Position - PhysicsFolder.Origin.Value.lookVector * 1000
			Part.CFrame = CFrame.new(Part.Position,Part.Position + extrapProjectile.CFrame.LookVector)
			Part.Parent = workspace

			local Attachment1 = Instance.new("Attachment")
			Attachment1.Name = "Goal"
			Attachment1.Parent = Part
			Attachment1.Axis = Vector3.new(0, 0, 1)

			local Attachment0 = Instance.new("Attachment")
			Attachment0.Name = "Rocket"
			Attachment0.Parent = extrapProjectile 
			Attachment0.Axis = Vector3.new(0, 0, 1)

			local Constraint = Instance.new("AlignOrientation")
			Constraint.RigidityEnabled = true
			Constraint.Attachment1 = Attachment1
			Constraint.Attachment0 = Attachment0
			Constraint.Parent = Part

			local Constraint = Instance.new("PrismaticConstraint")
			Constraint.Attachment1 = Attachment1
			Constraint.Attachment0 = Attachment0
			Constraint.Parent = Part

			Debris:AddItem(Part,10)
		end
		
		-- Update distance upon value changed
		-- Compensate for ping if settings dictate so
		local latestDistance = PhysicsFolder.LatestDistance
		latestDistance.Changed:Connect(function()
			local distance = latestDistance.Value

			if _G.BB.Settings.Extrapolation.PingCompensation.Rocket then
				distance += pingCompensation
			end

			local progress = origin.lookVector * distance
			local newCF = origin + progress

			extrapProjectile.CFrame = newCF
		end)
	
		-- Update velocity upon value changed
		--local latestVel = PhysicsFolder.LatestVelocity
		--latestVel.Changed:Connect(function()
		--	extrapProjectile.Velocity = latestVel.Value
		--end)
		
		-- Explode rocket upon inactivity
		local function checkActive()
			if PhysicsFolder.Active.Value == false then
				self.Explosion:ExtrapolateExplosion(extrapProjectile, PhysicsFolder)
			end
		end

		PhysicsFolder.Active.Changed:Connect(checkActive)
		
		extrapProjectile.Parent = self.ExtrapolatedFolder
		extrapProjectile.Swoosh:Play()
		
		checkActive()

	elseif PhysicsFolder.ProjectileType.Value == "Bomb" then
		
		extrapProjectile = self.MakeBomb(creator)
		
		local exploded = false

		-- Update position upon value changed
		local latestPos = PhysicsFolder.LatestPosition
		latestPos.Changed:Connect(function()
			extrapProjectile.Position = latestPos.Value
		end)
		
		-- Update velocity upon value changed
		local latestVel = PhysicsFolder.LatestVelocity
		latestVel.Changed:Connect(function()
			extrapProjectile.Velocity = latestVel.Value
		end)

		-- Explode bomb upon inactivity
		local function checkActive()
			if PhysicsFolder.Active.Value == false then
				exploded = true
				extrapProjectile.Position = latestPos.Value
				extrapProjectile.Velocity = latestVel.Value

				self.Explosion:ExtrapolateExplosion(extrapProjectile, PhysicsFolder)
			end
		end
		
		extrapProjectile.Position = latestPos.Value
		extrapProjectile.Velocity = latestVel.Value
		extrapProjectile.Parent = self.ExtrapolatedFolder

		--Play the first tick
		extrapProjectile.Tick:Stop()
		if not _G.BB.TrueMobile then
			extrapProjectile.Tick.TimePosition = 0.12
		end
		extrapProjectile.Tick:Play()
		
		-- Update last tick time value
		local latestTime = PhysicsFolder.LatestTime
		--local _tick = 1
		
		local function updateTick(dt)
			if exploded or (not PhysicsFolder.Parent) or (not PhysicsFolder:FindFirstChild("LatestTime")) then
				if tickRender then
					tickRender:Disconnect()
				end
				return
			end
			
			-- Update last tick time value
			local receivedTime = PhysicsFolder.LatestTime.Value
			local lastTime = extrapProjectile.LastReceivedTime.Value
			if lastTime < receivedTime then
				extrapProjectile.LastReceivedTime.Value = receivedTime
			else
				extrapProjectile.LastReceivedTime.Value = lastTime + dt -- Default render speed
			end
			local updatedTime = extrapProjectile.LastReceivedTime.Value

			-- Update tick time
			local iTick = -1
			for i=1,14 do
				if lastTime<TickTimeStamps[i] and updatedTime>=TickTimeStamps[i] then
					iTick = i
					break
				elseif updatedTime<TickTimeStamps[i] then
					break
				end
			end

			-- Play tick sound and update color
			if iTick ~= -1 then
				extrapProjectile.Tick:Stop()

				if not _G.BB.TrueMobile then
					extrapProjectile.Tick.TimePosition = 0.12
				end

				extrapProjectile.Tick:Play()

				local Val = iTick%2

				if Val == 1 then
					extrapProjectile.Color = extrapProjectile.TickColor.Value
				else
					extrapProjectile.Color = extrapProjectile.BaseColor.Value
				end

				if iTick == 14 then
					extrapProjectile.Anchored = true
				end
			end
		end
		
		--latestTime.Changed:Connect(function(new)
		--	updateTick(new - extrapProjectile.LastReceivedTime.Value)
		--end)

		tickRender = game:GetService("RunService").RenderStepped:Connect(function(dt)
			updateTick(dt)
		end)
		
		PhysicsFolder.Active.Changed:Connect(checkActive)

		checkActive()
		
	elseif PhysicsFolder.ProjectileType.Value == "Wall" then
		
		-- Toggle trowel outlines
		local CF = PhysicsFolder.PlaceCFrame.Value
		local CT = PhysicsFolder.RandomColor.Value
		local wall = PhysicsFolder.Wall.Value
		
		for _,Brick in pairs(wall:GetChildren()) do
			
			local SB = Brick:FindFirstChildWhichIsA("SelectionBox")
			
			if SB then
				SB.Visible = _G.BB.Local.TrowelOutlines
			end
			
			self.Aesthetics:ApplyWallColors(Brick,CT)
		end
	end

	if not extrapProjectile then 
		--warn("Added physics folder has improper projectile type")
		return 
	end

	PhysicsFolder.AncestryChanged:Connect(function(_, newParent)
		if newParent == nil then
			Debris:AddItem(extrapProjectile, 0)
			if tickRender then
				tickRender:Disconnect()
			end
		end
	end)

	extrapProjectile.Parent = self.ExtrapolatedFolder
end


function Extrapolation:Init(Settings, Modules, Remotes, Player, ProjectileFolder)
	
	local objects = Player.PlayerScripts.ToolObjects
	
	self.Player = Player
	
	self.Aesthetics = require(Modules:WaitForChild("Aesthetics"))
	self.Explosion = require(Modules:WaitForChild("Explosion"))
	self.Kill = require(Modules:WaitForChild("Kill"))
	
	self.UpdateRemote = Remotes:WaitForChild("UpdatePhysics")

	self.MakeSuperball = require(objects:WaitForChild("MakeSuperball"))
	self.MakeRocket = require(objects:WaitForChild("MakeRocket"))
	self.MakeBomb = require(objects:WaitForChild("MakeBomb"))
	self.MakePellet = require(objects:WaitForChild("MakePellet"))
	self.MakePaintball = require(objects:WaitForChild("MakePaintball"))
	

	-- Folder that contains each player's various physics folders and projectiles
	self.ActiveFolder = ProjectileFolder:WaitForChild("Active")

	-- Folder that contains extrapolated projectiles (only visible to client)
	self.ExtrapolatedFolder = ProjectileFolder:WaitForChild("Extrapolated")

	-- Folder that contains client's active physics folders and projectiles
	self.ClientActiveFolder = self.ActiveFolder:WaitForChild(Player.Name)

	local function EvaluateFolder(Folder)
		-- Do not extrapolate own projectiles
		if not Folder:IsA("Folder") or Folder.Name == Player.Name then 
			return 
		end

		for _,Folder2 in pairs(Folder:GetChildren()) do
			self:Begin(Folder2)
		end

		Folder.ChildAdded:Connect(function(Folder3)
			self:Begin(Folder3)
		end)
	end	

	for _,Folder in pairs(self.ActiveFolder:GetChildren()) do
		EvaluateFolder(Folder)
	end

	self.ActiveFolder.ChildAdded:connect(EvaluateFolder)

	game:GetService("RunService").RenderStepped:connect(function(ElaspedTime)
		--Displace all extrapolated projectiles
		local Start = tick()

		if validateTime(Start, LastUpdate, UpdateInterval, true) then
			self:SendUpdateData()
		end
	end)
end

return Extrapolation