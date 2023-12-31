--!strict
local Slingshot = {}

local tool = script.Parent.Parent


local spawnDistances = {
	Flying = 4,
	Climbing = 8.5,
}

local ADDED_Y_VEL = 0.3

function Slingshot:ComputeLaunchAngle(dx, dy, grav, speed)
	local Gravity = workspace.Gravity--math.abs(workspace.Gravity)

	local SqSpeed = speed ^ 2

	local inRoot = (SqSpeed ^ 2) - (Gravity * ((Gravity * (dx^2)) + (2 * dy * SqSpeed)))

	if inRoot <= 0 then
		return -1
	end

	local root = math.sqrt(inRoot)

	local GravDist = Gravity * dx

	local inATan1 = (SqSpeed + root) / GravDist
	local inATan2 = (SqSpeed - root) / GravDist

	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)

	if answer1 < answer2 then 
		return answer1 
	end

	return answer2
end

function Slingshot:Fire(Hit, mouse_pos, pellet, count, collisionGroup, now)
	local dir = (mouse_pos - self.Character.PrimaryPart.Position).Unit
	local spawnDistance = _G.BB.Settings.SlingClimb and 6 or _G.BB.Settings.Slingshot.SpawnDistance
	local Speed = _G.BB.Settings.Slingshot.Speed
	local ShootInsideBricks = _G.BB.Settings.Slingshot.ShootInsideBricks
		
	if collisionGroup ~= "Standard" then
		spawnDistance = spawnDistances[collisionGroup]
	end
	
	local launch = self.Character.PrimaryPart.Position + dir * spawnDistance
	local delta = mouse_pos - launch
	local unit_delta = delta.Unit
	
	local dir = unit_delta
	
	if workspace.Gravity > 0 then
		local dy = delta.Y

		delta = Vector3.new(delta.X, 0, delta.Z)

		local dx = delta.Magnitude
		unit_delta = delta.Unit

		local theta = self:ComputeLaunchAngle(dx, dy, workspace.Gravity, Speed)
		
		if theta == -1 then
			dir = (mouse_pos - self.Character.PrimaryPart.Position).Unit
			dir = Vector3.new(dir.X, dir.Y + ADDED_Y_VEL, dir.Z)
		else
			local vy = math.sin(theta)
			local xz = math.cos(theta)
			local vx = unit_delta.X * xz
			local vz = unit_delta.Z * xz
			dir = Vector3.new(vx, vy, vz)
		end
	end
	
	local vel = dir * Speed
	pellet.Position = launch
	pellet.Velocity = vel
	pellet.Parent = self.ActiveFolder
	
	if (ShootInsideBricks == false) and self.isInsideSomething(pellet) then
		local pPartPos = self.Character.PrimaryPart.Position
		local clampedDist = math.clamp((mouse_pos - pPartPos).Magnitude, 0, spawnDistance)
		local pelletDir = (mouse_pos - pPartPos).Unit

		local camDir = workspace.CurrentCamera.CFrame.LookVector
		local finalPos = pPartPos + pelletDir * clampedDist - camDir * 1
		local pelletLook = pellet.CFrame.LookVector
		local cFrame = CFrame.lookAt(finalPos, finalPos + pelletLook)

		pellet.Anchored = true
		pellet.CFrame = cFrame
		pellet.Velocity = pelletLook * Speed
		pellet.Anchored = false

		if self.isInsideSomething(pellet, true) then
			pellet.Anchored = true
			pellet.CFrame = CFrame.lookAt(pPartPos, pPartPos + pelletLook)
			pellet.Velocity = pelletLook * Speed
			pellet.Anchored = false
		end
	end
	
	self.Delete(pellet, 4)
	
	self.Hit:HandleHitDetection(pellet)
	
	return pellet.Position, vel
end

local function touchingMiscPart(character, sourcePart)
	local TC = sourcePart.Touched:Connect(function() end)
	local CollectedParts = sourcePart:GetTouchingParts()
	TC:Disconnect()
	local TouchingMiscPart = false
	for _, Part in pairs(CollectedParts) do
		if not character:IsAncestorOf(Part) then
			TouchingMiscPart = true
			break
		end
	end
	return TouchingMiscPart
end

function Slingshot:Init()
	local Player = game:GetService("Players").LocalPlayer
	local Character = Player.Character
	local Mouse = Player:GetMouse()
	
	self.Hit = require(_G.BB.Modules:WaitForChild("Hit"))
	self.Delete = require(_G.BB.ClientObjects:WaitForChild("Delete"))
	self.ActiveFolder = workspace:WaitForChild("Projectiles"):WaitForChild("Active"):WaitForChild(Player.Name)

	local MakePellet = require(_G.BB.ClientObjects:WaitForChild("MakePellet"))
	local Targeting = require(_G.BB.ClientObjects:WaitForChild("Core"):WaitForChild("Targeting"))

	local SafeWait = require(_G.BB.Modules.Security:WaitForChild("SafeWait"))
	
	self.isInsideSomething = require(_G.BB.ClientObjects:WaitForChild("isInsideSomething"))
	local Security = require(_G.BB.Modules:WaitForChild("Security"))
	
	local handle = tool:WaitForChild("Handle")
	local Activation = tool:WaitForChild("Activation")
	local UpdateEvent = tool:WaitForChild("Update")
	local slingshotSounds = tool.Handle:WaitForChild("SlingshotSounds")
	local NewSounds  = slingshotSounds:Clone()
	NewSounds.Name = "ClientSounds"
	NewSounds.Parent = handle
	slingshotSounds:Destroy()
	
	local HandleCrosshair = require(_G.BB.ClientObjects:WaitForChild("HandleCrosshair"))
	HandleCrosshair(tool)
	
	self.Character = Character

	local down = false
	local jumpyDeltaTime = _G.BB.Settings.Slingshot.SlingFlyCooldown
	local jumpyT0 = time()

	local function Activate(Hit,targetPos)
		if not Security:ApproveActivation(Player, "Slingshot") then
			return
		end
		tool.Enabled = false
		
		local now = time()

		local CollisionGroup = _G.BB.Settings.Doomspire.SlingFly and "JumpyPellets" or "Pellets"

		local isHoldingSpace = game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space)
		local isJumping = (Character.Humanoid.FloorMaterial == Enum.Material.Air or isHoldingSpace)
		
		local mode = "Standard"
		
		-- Set mode (Standard, Climbing, or Flying)
		if handle then
			
			if _G.BB.Settings.SlingClimb or _G.BB.Settings.Doomspire.SlingFly then
				
				local TouchingMiscPart = touchingMiscPart(Character, handle)
				CollisionGroup = (TouchingMiscPart and isJumping) and "JumpyPellets" or "Pellets"
				
				if TouchingMiscPart then
					
					mode = "Climbing"
					jumpyT0 = now
					
				elseif _G.BB.Settings.Doomspire.SlingFly  then
					
					if ((now - jumpyT0) > jumpyDeltaTime) and isJumping then
						mode = "Flying"
						CollisionGroup = "JumpyPellets"
						jumpyT0 = now
					end
				end
			end
		end

		_G.BB.ProjectileCounts.Pellets += 1
		local count = _G.BB.ProjectileCounts.Pellets
		
		local Pellet = MakePellet(Player, CollisionGroup, count)
		
		local position, velocity = self:Fire(Hit, targetPos, Pellet, count, mode, now)
		UpdateEvent:FireServer(position, velocity, now, count, _G.BB.ServerTime.Value)	

		local Sound = NewSounds:FindFirstChild(_G.BB.Local.SlingshotSound)
		Sound.Parent = handle
		Sound:Play()
		Sound.Parent = NewSounds
		
		SafeWait.wait(_G.BB.Settings.Slingshot.ReloadTime)
		
		tool.Enabled = true
		
		return true
	end
	
	--This exception attempts to turn off automatic sling for mobile users, as it's nonfunctional and causes issues on the side.
	if not (game:GetService("UserInputService").MouseEnabled) and
		not (game:GetService("UserInputService").KeyboardEnabled) and
		game:GetService("UserInputService").TouchEnabled then
		--_G.BB.Settings.Slingshot.Automatic = false
		warn("Your device was recognized as mobile and Slingshot Automatic fire was deactivated.")
		warn("If your device is not mobile, contact a developer to report the issue.")
	end
	
	local Thread = 0
	local currentInputObject = nil
	Activation.Event:Connect(function(Hit,targetPos, inputObject)
		if tool.Enabled then
			if _G.BB.Settings.Slingshot.Automatic and not down then
				Thread = Thread + 1
				local CurrentThread = Thread
				currentInputObject = inputObject
				down = true
				while down and CurrentThread == Thread do
					local Hit, TargetPosition
					if currentInputObject.UserInputType == Enum.UserInputType.Touch then
						Hit, TargetPosition = Targeting:Get3DPosition(currentInputObject.Position.X, currentInputObject.Position.Y, false)
					else
						Hit, TargetPosition = Targeting:Get3DPosition(Mouse.X, Mouse.Y, false)
					end
					if not Activate(Hit,TargetPosition) then
						SafeWait.wait(_G.BB.Settings.Slingshot.ReloadTime)
					end
				end
				down = false
			elseif not _G.BB.Settings.Slingshot.Automatic then
				Activate(Hit,targetPos)
			end
		end
	end)

	if _G.BB.Settings.Slingshot.Automatic then
		game:GetService("UserInputService").InputEnded:Connect(function(input)
			--[[
			if input.UserInputType == Enum.UserInputType.MouseButton1 
				or input.UserInputType == Enum.UserInputType.Gamepad1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				if input.UserInputType == Enum.UserInputType.Touch  then
					task.wait(1/15)
				end
				down = false
			end]]
			--TODO why is there a task.wait(1/15) specifically for InputType "Touch"? Ask glor
			if input == currentInputObject then
				currentInputObject = nil
				down = false
			end
		end)
		
		tool.AncestryChanged:Connect(function()
			if tool.Parent ~= Character then
				down = false
			end
		end)
	end
end

return Slingshot