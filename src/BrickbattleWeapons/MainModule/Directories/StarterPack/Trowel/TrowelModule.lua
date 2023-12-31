--!strict
-- GloriedRage
-- Created module to minimize code repetition.
local Trowel = {}
local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

function Trowel:PositionBrick(CF,wallModel,BrickIndex,ct)
	local WallBricks = wallModel:GetChildren()
	
	-- Bricks are named with numbers. Allows for the same brick to be placed in the same
	-- place on both the client and server.
	local Brick = wallModel:FindFirstChild(BrickIndex)
	
	-- Place the brick.
	if Brick then
		--Brick:FindFirstChildWhichIsA("BodyForce"):Destroy()
		local Sound = Brick:FindFirstChildWhichIsA("Sound")
		Brick.CFrame = CF
		Brick.Anchored = false;
		
		if not (game.Players.LocalPlayer) then -- wtf?
			-- localplayer will never NOT exist in client code
			Brick:MakeJoints()
			if Sound then
				Sound:Play()
			end
		else
			if Sound then -- Client sound
				local NewSound = Sound:Clone()
				Sound:Destroy()
				NewSound.Name = "ClientTrowelSound"
				NewSound.Parent = Brick
				--print("Playing sound")
				NewSound:Play()
			end
			Aesthetics:ApplyWallColors(Brick,ct)
			if game.Players.LocalPlayer~= Brick.creator.Value then
				Brick:MakeJoints()
			end
		end

		for k,j in pairs(Brick:GetJoints()) do
			local m = j.Part1:FindFirstAncestorWhichIsA("Model")
			if m and m:FindFirstChildWhichIsA("Humanoid") then
				j:Destroy()
			end
		end
	end
	
	return Brick;
end
--[[
function Trowel:CreateServerWeld(wallModel,BrickIndex,CF)
	local WallBricks = wallModel:GetChildren();
	local Brick = wallModel:FindFirstChild(BrickIndex);
	
	if Brick then
		if (Brick.Position - CF.Position).Magnitude > 0.1 then
			print("Waiting")
			task.wait(.1)
		end
		print("Making joints for",Brick.Name)
		Brick:FindFirstChildWhichIsA("BodyForce"):Destroy()
		Brick:MakeJoints()
	end
end
]]
function Trowel:BuildWall(cf,wall,Speed,ct)
	local yPos = 0;
	local BrickIndex = 0
	local Settings = _G.BB.Settings
	
	-- Build y rows
	for i = 1,Settings.Trowel.BricksPerColumn do
		local RunningVector
		local xPos = -6
		
		-- Build x bricks per row
		for i2 = 1,Settings.Trowel.BricksPerRow do
			-- Increase BrickIndex before each brick is placed for proper reference
			BrickIndex = BrickIndex + 1
			local Position = Vector3.new(xPos, yPos, 0)
			local CF = cf * CFrame.new(Position + Settings.Trowel.BrickSize / 2)

			self:PositionBrick(CF,wall,BrickIndex,ct)
			
			RunningVector = (Vector3.new(xPos, yPos, 0) + Settings.Trowel.BrickSize)
			xPos = RunningVector.x
			
			task.wait(Speed)
		end
		
		yPos = RunningVector.y
	end
end

return Trowel