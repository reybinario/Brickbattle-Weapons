--!strict
local Paintball = {}

local tool = script.Parent.Parent

function Paintball:Fire(Paintball, TargetPosition, SpawnDistance, count)
	local Speed = _G.BB.Settings.PaintballGun.Speed
	local ShootInsideBricks = _G.BB.Settings.PaintballGun.ShootInsideBricks

	local Head = self.Character.PrimaryPart
	local SpawnPosition = Head.Position + (TargetPosition - self.handle.Position).unit * SpawnDistance
	local LaunchCF = CFrame.lookAt(SpawnPosition, TargetPosition)
	local Velocity = LaunchCF.LookVector * Speed

	Paintball.CFrame = LaunchCF
	Paintball.Velocity = Velocity
	Paintball.Parent = self.ClientActiveFolder
	
	if ShootInsideBricks == false and self.isInsideSomething(Paintball) then
		Paintball.Anchored = true
		local Position = tool.Handle.Position
		Paintball.CFrame = CFrame.lookAt(Position, TargetPosition)
		Paintball.Velocity = Paintball.CFrame.LookVector * Speed
		Paintball.Anchored = false
	end
	
	game:GetService("Debris"):AddItem(Paintball, 10)
	
	self.Hit:HandleHitDetection(Paintball)
	return LaunchCF.Position, Velocity
end

function Paintball:Init()
	local Player = game:GetService("Players").LocalPlayer
	
	self.Hit = require(_G.BB.Modules:WaitForChild("Hit"))
	
	self.ClientActiveFolder = workspace:WaitForChild("Projectiles"):WaitForChild("Active"):WaitForChild(Player.Name)
	self.handle = tool:WaitForChild("Handle")
	local UpdateEvent = tool:WaitForChild("Update")

	local SafeWait = require(_G.BB.Modules.Security:WaitForChild("SafeWait"))
	
	self.Character = Player.Character

	local Activation = tool:WaitForChild("Activation")
	local MakePaintball = require(_G.BB.ClientObjects:WaitForChild("MakePaintball"))
	
	local HandleCrosshair = require(_G.BB.ClientObjects:WaitForChild("HandleCrosshair"))
	HandleCrosshair(tool)
	
	self.isInsideSomething = require(_G.BB.ClientObjects:WaitForChild("isInsideSomething"))

	Activation.Event:Connect(function(Hit,targetPos)
		if tool.Enabled then 
			tool.Enabled = false

			_G.BB.ProjectileCounts.Paintballs += 1
			local count = _G.BB.ProjectileCounts.Paintballs	
			
			local Paintball = MakePaintball(Player, "Paintballs", count)

			local position, velocity = self:Fire(Paintball, targetPos, _G.BB.Settings.PaintballGun.SpawnDistance, count)
			UpdateEvent:FireServer(position, velocity, time(), count, Paintball.Color)

			SafeWait.wait(_G.BB.Settings.PaintballGun.ReloadTime)
			tool.Enabled = true
		end
	end)
end

return Paintball