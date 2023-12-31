--!strict
local Rocket = {}

local tool = script.Parent.Parent
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Collections = game:GetService("CollectionService")

function Rocket:ProcessTouched(rocket)
	local TouchedConnection;
	local hasExploded = false
	local CharacterData
	
	local Diamater = _G.BB.Settings.Rocket.Radius * 2
	
	rocket.Ready.Value = true
	
	TouchedConnection = rocket.Touched:Connect(function(hit)
		local RocketPosition = rocket.Position

		local hitCharacter = hit.Parent:IsA("Model") and hit.Parent
		local hitHumanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
		
		local hitPlr = hitCharacter and Players:GetPlayerFromCharacter(hitCharacter)
		if hitPlr == self.Player and (not self.Kill:CanDamage(self.Player, hitHumanoid, _G.BB.Settings.Doomspire.RocketCollisions)) then
			return
		end
		
		local CallbackModule = _G.BB.Modules.Callbacks.RocketExplode
		local Callback = CallbackModule and require(CallbackModule)
		if Callback and Callback(hit) == false then
			-- IF FALSE, ROCKET PASSES THROUGH
			return
		end
		
		if hasExploded then
			return
		end
		
		hasExploded = true
		rocket.Ready.Value = false
		rocket.Anchored = true
		
		TouchedConnection:Disconnect()
		
		-- Move rocket forward 2 studs
		rocket.CFrame = rocket.CFrame + (rocket.CFrame * Vector3.new(0, 0, -2)) - rocket.Position
		
		-- Get character positions at two frames
		if hitPlr then
			CharacterData = self.PSPV:CreateCharFrameTables(hitPlr)
		end
		
		--Debris:AddItem(rocket, 3)
		
		rocket.Size = Vector3.new(Diamater, Diamater, Diamater)
		
		local function CreateExpl()
			
			rocket.Swoosh:Destroy()
			
			-- client rocket explosion sound
			local Sounds = rocket:WaitForChild("Boom")
			local Sound = Sounds:FindFirstChild(_G.BB.Local.RocketExplosion)
			Sound.Parent = rocket
			Sound:Play()
			
			self.Aesthetics:CreateCustomExplosion(self.Player, rocket)
		end
		
		task.spawn(CreateExpl)
		self.Explosion:HandleHitDetection(rocket, hit, RocketPosition, CharacterData)
	end)
end

function Rocket:Fire(rocket, TargetPosition, SpawnDistance)
	local InitialSpeed = _G.BB.Settings.Rocket.InitialSpeed
	local Speed = _G.BB.Settings.Rocket.Speed
	local RampUpDuration = _G.BB.Settings.Rocket.RampUpDuration
	local ShootInsideBricks = _G.BB.Settings.Rocket.ShootInsideBricks
	
	local InitPosition = tool.Handle.Position + (TargetPosition - tool.Handle.Position).unit * SpawnDistance
	local InitialCFrame = CFrame.lookAt(InitPosition, TargetPosition)
	
	rocket.Origin.Value = InitialCFrame -- have to buffer this on the client
	rocket.LastSentPosition.Value = InitialCFrame.Position
	
	rocket.CFrame = InitialCFrame
	
	local initialVelocity = rocket.CFrame.LookVector *InitialSpeed
	local velocity = rocket.CFrame.LookVector * Speed

	rocket.Velocity = initialVelocity
	rocket.RocketVelocity.Velocity = velocity
	
	local force = (velocity - initialVelocity) * rocket:GetMass() / RampUpDuration
	force = Vector3.new(math.abs(force.X), math.abs(force.Y), math.abs(force.Z))
	rocket.RocketVelocity.MaxForce = force
	
	rocket.Parent = self.ActiveFolder

	if not ShootInsideBricks and self.isInsideSomething(rocket) then
		rocket.Anchored = true
		local Position = tool.Handle.Position
		local cFrame = CFrame.lookAt(Position, TargetPosition)
		rocket.CFrame = cFrame
		local initialVelocity = rocket.CFrame.LookVector * InitialSpeed
		local velocity = rocket.CFrame.LookVector * Speed

		rocket.Velocity = initialVelocity
		rocket.RocketVelocity.Velocity = velocity
		rocket.Anchored = false
	end
	
	game:GetService("Debris"):AddItem(rocket,9.5)
	rocket.Swoosh:Play()
	
	self:ProcessTouched(rocket)
	return rocket.CFrame
end

function Rocket:Init()
	
	local Player = Players.LocalPlayer
	self.Player = Player
	self.Character = self.Player.Character
	
	self.Kill = require(_G.BB.Modules:WaitForChild("Kill"))
	self.Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))
	self.Explosion = require(_G.BB.Modules:WaitForChild("Explosion"))
	self.PSPV = require(_G.BB.Modules.Security:WaitForChild("PSPV"))	
	self.isInsideSomething = require(_G.BB.ClientObjects:WaitForChild("isInsideSomething"))

	local SafeWait = require(_G.BB.Modules.Security:WaitForChild("SafeWait"))

	self.ActiveFolder = workspace:WaitForChild("Projectiles"):WaitForChild("Active"):WaitForChild(Player.Name)
	
	local MakeRocket = require(_G.BB.ClientObjects:WaitForChild("MakeRocket"))

	self.handle = tool:WaitForChild("Handle")


	local Activation = tool:WaitForChild("Activation")
	local UpdateEvent = tool:WaitForChild("Update")
	local HandleCrosshair = require(_G.BB.ClientObjects:WaitForChild("HandleCrosshair"))

	HandleCrosshair(tool)
	
	Activation.Event:Connect(function(Hit, TargetPosition)
		if tool.Enabled then 
			tool.Enabled = false

			local SpawnDistance = _G.BB.Settings.Rocket.SpawnDistance

			_G.BB.ProjectileCounts.Rockets += 1

			local rocket = MakeRocket(self.Player, _G.BB.ProjectileCounts.Rockets)
			local cframe = self:Fire(rocket, TargetPosition, SpawnDistance, _G.BB.ProjectileCounts.Rockets)
			UpdateEvent:FireServer(cframe, _G.BB.ServerTime.Value, _G.BB.ProjectileCounts.Rockets)
			
			SafeWait.wait(_G.BB.Settings.Rocket.ReloadTime)

			tool.Enabled = true
		end
	end)

end

return Rocket