--!strict
local Superball = {}

local tool = script.Parent.Parent

local function canSBJump(Character)
	return (_G.BB.Settings.SuperballJump 
		and Character.Humanoid.FloorMaterial == Enum.Material.Air 
		and _G.BB.CanSBFly)
end

function Superball:Fire(Superball, TargetPosition, SpawnDistance, count)
	
	local Speed = _G.BB.Settings.Superball.Speed
	local ShootInsideBricks = _G.BB.Settings.Superball.ShootInsideBricks
	
	local now = time()
	local SpawnPosition = self.Head.Position + (TargetPosition - self.Head.Position).unit * SpawnDistance
	local LaunchCF = CFrame.new(SpawnPosition, TargetPosition)
	local Velocity = LaunchCF.LookVector * Speed
	
	Superball.LastSentPosition.Value = LaunchCF.Position
	Superball.LastSentVelocity.Value = Velocity
	Superball.LastSentTime.Value = now
	
	Superball.CFrame = LaunchCF
	Superball.Velocity = Velocity
	Superball.Parent = self.ClientActiveFolder
	
	if not ShootInsideBricks and self.isInsideSomething(Superball) then
		Superball.Anchored = true
		local Position = self.handle.Position
		local cFrame = CFrame.lookAt(Position, TargetPosition)
		Superball.CFrame = cFrame
		Superball.Velocity = Superball.CFrame.LookVector * Speed
		Superball.Anchored = false
	end
	
	self.handle.Boing:Play() -- or handle.Boing:Play()
	
	self.Delete(Superball, 8) -- exists for 8 seconds		
	self.Hit:HandleHitDetection(Superball, count)
	return LaunchCF.Position, Velocity, now
end

function Superball:Init()
	local Player = game:GetService("Players").LocalPlayer
	local Character = Player.Character
	
	self.Hit = require(_G.BB.Modules:WaitForChild("Hit"))
	self.Delete = require(_G.BB.ClientObjects:WaitForChild("Delete"))
	self.isInsideSomething = require(_G.BB.ClientObjects:WaitForChild("isInsideSomething"))

	local MakeSuperball = require(_G.BB.ClientObjects:WaitForChild("MakeSuperball"))

	self.ClientActiveFolder = workspace:WaitForChild("Projectiles"):WaitForChild("Active"):WaitForChild(Player.Name)
	
	self.handle = tool:WaitForChild("Handle")

	self.Head = Character:WaitForChild("Head")
	
	local ReloadTime = _G.BB.Settings.Superball.ReloadTime

	local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))
	local HandleCrosshair = require(_G.BB.ClientObjects:WaitForChild("HandleCrosshair"))
	
	local UpdateEvent = tool:WaitForChild("Update")
	local Activation = tool:WaitForChild("Activation")
	local colorEvent = tool:WaitForChild("Color")
	
	local SafeWait = require(_G.BB.Modules.Security:WaitForChild("SafeWait"))

	local themeRemote = _G.BB.Remotes:WaitForChild("ReplicateTheme")

	Aesthetics:HandleSBHandle(Player, self.handle, colorEvent, true)
	HandleCrosshair(tool)
	
	Activation.Event:Connect(function(Hit, targetPos)
		if tool.Enabled then 
			tool.Enabled = false
			
			_G.BB.ProjectileCounts.Superballs += 1
			
			local count = _G.BB.ProjectileCounts.Superballs
			local CollisionGroup = "Superballs" 
			local SpawnDistance = _G.BB.Settings.Superball.SpawnDistance
			
			if canSBJump(Character) then
				CollisionGroup = "JumpySuperballs"
				SpawnDistance = 5 -- optimal spawn distance for superball jumping
			end
						
			local Superball = MakeSuperball(Player, CollisionGroup, count, self.handle.Color)
						
			local position, velocity, now = self:Fire(Superball, targetPos, SpawnDistance, count)
			UpdateEvent:FireServer(position, velocity, now, Superball.Color, count)

			Aesthetics:HandleSBHandle(Player, self.handle, colorEvent)

			SafeWait.wait(ReloadTime)
			
			tool.Enabled = true
		end
	end)
	
	themeRemote.OnClientEvent:Connect(function(otherPlayer, otherHandle, themeFolder)
		local sb = themeFolder:FindFirstChild("Superball")
		Aesthetics:UpdateSuperballHandle(otherPlayer, otherHandle, nil, true)
	end)
end

return Superball