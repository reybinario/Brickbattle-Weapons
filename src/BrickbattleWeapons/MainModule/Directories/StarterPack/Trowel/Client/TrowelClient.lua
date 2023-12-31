--!strict
local Trowel = {}

local tool = script.Parent.Parent

local function snap(Vector)
	return (math.abs(Vector.x)>math.abs(Vector.z))
	and ((Vector.x>0) and Vector3.new(1,0,0) or Vector3.new(-1,0,0))
	or ((Vector.z>0) and Vector3.new(0,0,1) or Vector3.new(0,0,-1))
end

function Trowel:Place(TargetPosition)
	local Head = self.Character.PrimaryPart
	local Lifetime = _G.BB.Settings.Trowel.Lifetime

		
	local vectorConstructor = Vector3.new(
		math.ceil(TargetPosition.X-0.5),
		math.floor(TargetPosition.Y*100)*0.01,
		math.ceil(TargetPosition.Z-0.5)
	)
	
	local lookAt = snap((vectorConstructor - Head.Position).unit)
	
	local cf = CFrame.new(vectorConstructor, vectorConstructor + lookAt)
	local wall = self.Buffer.Value
	
	for _,Brick in pairs(wall:GetChildren()) do
		local SB = Brick:FindFirstChildWhichIsA("SelectionBox")
		if SB then
			SB.Visible = _G.BB.Local.TrowelOutlines
		end
	end
	
	--wall.Parent = workspace
	
	game:GetService("Debris"):AddItem(wall, Lifetime)
	local ct = wall.PhysicsFolder.RandomColor.Value
	
	-- Build client wall
	local function BuildWall()
		self.TrowelModule:BuildWall(cf,wall,.04, ct)
	end
	task.spawn(BuildWall)
	
	return cf
end

function Trowel:Init()
	local Player = game:GetService("Players").LocalPlayer
	
	self.ActiveFolder = workspace:WaitForChild("Projectiles"):WaitForChild("Active"):WaitForChild(Player.Name)
	
	self.Character = game:GetService("Players").LocalPlayer.Character
	
	self.Buffer = _G.BB.Buffers:WaitForChild("Wall")
	
	self.TrowelModule = require(tool:WaitForChild("TrowelModule"))

	local verifyBuffer = require(tool:WaitForChild("VerifyBuffer"))
	local Activation = tool:WaitForChild("Activation")
	local UpdateEvent = tool:WaitForChild("Update")

	local ReloadTime = _G.BB.Settings.Trowel.ReloadTime
	
	local SafeWait = require(_G.BB.Modules.Security:WaitForChild("SafeWait"))

	local HandleCrosshair = require(_G.BB.ClientObjects:WaitForChild("HandleCrosshair"))
	HandleCrosshair(tool)

	Activation.Event:Connect(function(Hit, TargetPosition)
		if tool.Enabled then 
			if not verifyBuffer(self.Buffer, self.ActiveFolder) then
				UpdateEvent:FireServer()
				tool.Enabled = true
				return
			end

			if Hit then
				local cf = self:Place(TargetPosition)
				UpdateEvent:FireServer(cf)

			else
				return
			end
			
			tool.Enabled = false

			SafeWait.wait(ReloadTime)
			tool.Enabled = true
		end
	end)
end

return Trowel