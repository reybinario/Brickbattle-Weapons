--!strict
-- Bomb
local Bomb = {}

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local tool = script.Parent.Parent

local canBombJump = true
local clickTime 
local jumpTime

local regular = "http://www.roblox.com/asset/?id=5320848090"
local reload = "http://www.roblox.com/asset/?id=5321216729"

function Bomb:TryBombJump(Bomb)	
	local handle = tool:WaitForChild("Handle")
	local BombSettings = _G.BB.Settings.Bomb
	
	local BombJumpReloadTime = BombSettings.BombJumpReloadTime
	local BombJumpPosWindow = BombSettings.BombJumpPosWindow
	local BombJumpNegWindow = BombSettings.BombJumpNegWindow
	local BombJumpPowerFormula = BombSettings.BombJumpPowerFormula
	local MaxBombJumpPower =  BombSettings.MaxBombJumpPower
	local WalkingBombJump = BombSettings.WalkingBombJump
	
	if _G.BB.TrueMobile then
		BombJumpNegWindow  = math.min(-.2, BombJumpNegWindow)
		BombJumpPosWindow = math.max(.3, BombJumpPosWindow)
	end
	
	if Bomb and Bomb.Parent and (self.Character.Humanoid.MoveDirection == Vector3.new(0, 0, 0) or WalkingBombJump) then	
		if not jumpTime or not clickTime or not canBombJump then 
			return
		end	
		
		-- Click then jump (jumpTime ought to be larger since it comes after clickTime)
		local Difference = jumpTime-clickTime

		-- Slight leniency with the activation order
		if (Difference <= BombJumpPosWindow and Difference >= BombJumpNegWindow) then
			Bomb.Ready.Value = false
			PhysicsService:SetPartCollisionGroup(Bomb, "BombJumpBombs")
			Bomb.Ready.Value = true
			
			Difference = math.abs(Difference)
			
			local JumpPower

			if BombJumpPowerFormula == "Quadratic" then
				JumpPower = MaxBombJumpPower * (1 - (Difference / (BombJumpPosWindow + .01))^2)
			elseif BombJumpPowerFormula == "Linear" then
				JumpPower = MaxBombJumpPower * (1 - (Difference / (BombJumpPosWindow + .01)))
			elseif BombJumpPowerFormula == "Constant" then
				JumpPower = MaxBombJumpPower
			else
				warn("Incorrect BombJumpPowerFormula value: "..BombJumpPowerFormula)
				JumpPower = MaxBombJumpPower
			end
			
			local rounded = math.round(JumpPower * 10) / 10
			print("Bomb jumped "..rounded.. " studs.")

			local primary = self.Character.PrimaryPart
			primary.Velocity = Vector3.new(primary.Velocity.X, JumpPower, primary.Velocity.Z)
			
			local function HandleReload()
				if BombJumpReloadTime > 0 then
					
					handle.Mesh.TextureId = reload
					handle.BrickColor = BrickColor.new("Medium stone grey")
					
					canBombJump = false
					
					task.wait(BombJumpReloadTime)
					
					if handle then
						handle.Mesh.TextureId = regular
						handle.BrickColor = BrickColor.new("Really black")
					end
					
					canBombJump = true
				end
			end
			
			task.spawn(HandleReload)
			
			task.wait(BombJumpPosWindow + .5)
			
			-- Reset collision group
			Bomb.Ready.Value = false
			PhysicsService:SetPartCollisionGroup(Bomb, "Default")
			Bomb.Ready.Value = true
		end
	end
end

function Bomb:BlowUp(Explosion)
	if Explosion.BlownUpClient.Value == true then
		return
	end
	
	Explosion.Ready.Value = false
	Explosion.BlownUpClient.Value = true

	local Size = _G.BB.Settings.Bomb.Radius * 2
	Explosion.Anchored = true
	Explosion.Size = Vector3.new(Size, Size, Size)
	Explosion.Tick:Destroy()
	
	-- Client explosion sound:
	local Sounds = Explosion:WaitForChild("Boom")
	local Sound = Sounds:FindFirstChild(_G.BB.Local.BombExplosion)
	Sound.Parent = Explosion
	Sound:Play()
	
	local function CreateVisual()
		self.Aesthetics:CreateCustomExplosion(self.Player, Explosion)
	end
	
	task.spawn(CreateVisual)
	self.Explosion:HandleHitDetection(Explosion)
end

function Bomb:HandleTick(Bomb)
	local updateInterval = 0.4
	local currentColor = 1
	local TickColor = Bomb.TickColor.Value
	local BaseColor = Bomb.BaseColor.Value

	--Bomb color was BaseColor on first two ticks.
	--Bomb.Color = TickColor
	
	local looping = true
	
	Bomb.BlownUpClient.Changed:Connect(function()
		if Bomb.BlownUpClient.Value == false then
			looping = false
		end
	end)
	
	Bomb.Ready.Value = true
	
	local expectedTime = 0
	local totalTime = 0
	
	while (updateInterval > 0.1) and looping do
		
		Bomb.Tick:Stop()
		
		-- For some reason, when changing TimePosition mobile players
		-- could not hear the sound.
		if not _G.BB.TrueMobile then
			Bomb.Tick.TimePosition = 0.12
		end
		
		Bomb.Tick:Play()
		
		expectedTime += updateInterval
		totalTime += SafeWait.wait(updateInterval)
		
		if looping then
			currentColor = currentColor == 1 and 2 or 1
			
			Bomb.Ready.Value = false
			Bomb.Color = currentColor == 1 and TickColor or BaseColor
			Bomb.Ready.Value = true
			updateInterval = updateInterval * 0.9
		end
	end
	
	return (totalTime - expectedTime < 1)
end

function Bomb:AssignTouchEvent(Bomb)
	local TouchedConnection
	local hasExploded = false
	local CharacterData

	TouchedConnection = Bomb.Touched:Connect(function(hit)
		if Bomb.BlownUpClient.Value == true then
			return
		end

		local hitCharacter = hit.Parent:IsA("Model") and hit.Parent
		local hitHumanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")

		if not hitCharacter or not hitHumanoid then
			return
		end

		local hitPlr = Players:GetPlayerFromCharacter(hitCharacter)
		local canHitSelf = self.Kill:CanDamage(self.Player, hitHumanoid, _G.BB.Settings.Bomb.TouchExplodeSelf)
		
		if hitPlr == self.Player and not canHitSelf then
			return
		end

		if not self.Kill:CanDamage(self.Player, hitHumanoid) then
			return
		end

		self:BlowUp(Bomb)
	end)
end

function Bomb:Init()
	local Player = game:GetService("Players").LocalPlayer
	local Character = Player.Character
	
	local UpdateEvent = tool:WaitForChild("Update")
	local Activation = tool:WaitForChild("Activation")
	
	self.Player = Player
	self.Character = Character

	self.Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))
	self.Explosion = require(_G.BB.Modules:WaitForChild("Explosion"))
	self.Kill = require(_G.BB.Modules:WaitForChild("Kill"))

	SafeWait = require(_G.BB.Modules.Security:WaitForChild("SafeWait"))

	local ActiveFolder = workspace:WaitForChild("Projectiles"):WaitForChild("Active"):WaitForChild(Player.Name)
	local MakeBomb = require(_G.BB.ClientObjects:WaitForChild("MakeBomb"))

	local CurrentBomb = nil

	local HandleCrosshair = require(_G.BB.ClientObjects:WaitForChild("HandleCrosshair"))
	HandleCrosshair(tool)

	Activation.Event:Connect(function()
		if tool.Enabled then 
			
			tool.Enabled = false
			
			clickTime = tick()
			
			_G.BB.ProjectileCounts.Bombs += 1

			local NewBomb = MakeBomb(Player, _G.BB.ProjectileCounts.Bombs)
			
			CurrentBomb = NewBomb
			
			local Head = Character.PrimaryPart

			if _G.BB.Settings.Doomspire.BombSpawnToCam then
				local Cam = workspace.CurrentCamera
				NewBomb.CFrame = ((Cam.CFrame - Cam.CFrame.Position) + Head.Position):toWorldSpace(CFrame.new(0, 4, -2))
			else
				NewBomb.CFrame = Head.CFrame + (Head.CFrame.UpVector * 4)
			end

			NewBomb.LatestPosition.Value = NewBomb.Position
			NewBomb.LastSentPosition.Value = NewBomb.Position
			NewBomb.LastSentVelocity.Value = Vector3.new(0,0,0)
			NewBomb.LocalOriginTime.Value = clickTime
			NewBomb.Parent = ActiveFolder
			
			UpdateEvent:FireServer(NewBomb.CFrame, NewBomb.Velocity, clickTime, _G.BB.ProjectileCounts.Bombs)

			local function RunBomb()
				if _G.BB.Settings.Bomb.TouchExplode then
					self:AssignTouchEvent(NewBomb)
				end
				
				local shouldBlowUp = self:HandleTick(NewBomb)
				if shouldBlowUp then
					self:BlowUp(NewBomb)
				else
					NewBomb:Destroy()
				end
			end
			
			task.spawn(RunBomb)

			SafeWait.wait(_G.BB.Settings.Bomb.ReloadTime)
			tool.Enabled = true
		end
	end)
	
	-- Only fires once per jump.
	if _G.BB.Settings.BombJump then
		Character.Humanoid.StateChanged:Connect(function(State)
			if State == Enum.HumanoidStateType.Jumping then
				-- Record jump time
				jumpTime = tick()
				self:TryBombJump(CurrentBomb)
			end
		end)
	end
end

return Bomb