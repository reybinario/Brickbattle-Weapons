--!strict
local Sword = {}
local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

function Sword:PositionLunge(tool)
	Aesthetics:ToggleSwordTrail(tool.Handle,true)
	tool.GripForward = Vector3.new(0, 0, 1);
	tool.GripRight = Vector3.new(0, -1, 0);
	tool.GripUp = Vector3.new(-1, 0, 0);
	--tool.GripForward = Vector3.new(0,1,0)
	--tool.GripRight = Vector3.new(0,0,-1)
	--tool.GripUp = Vector3.new(1,0,0)
end

function Sword:PositionIdle(tool)
	Aesthetics:ToggleSwordTrail(tool.Handle)
	tool.GripForward = Vector3.new(-1 ,0 ,0);
	tool.GripRight = Vector3.new(0, 1, 0);
	tool.GripUp = Vector3.new(0, 0, 1);
	--tool.GripForward = Vector3.new(1,0,0)
	--tool.GripRight = Vector3.new(0,0,1)
	--tool.GripUp = Vector3.new(0,1,0)
end

function Sword:CheckJoint(Character,Handle)
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return false
	end
	local ArmOption1 = Character:FindFirstChild("Right Arm")
	local ArmOption2 = Character:FindFirstChild("RightHand")

	local Arm = Humanoid.RigType == Enum.HumanoidRigType.R6 and ArmOption1 or ArmOption2
	if not Arm then
		return false
	end
	local Joint = Arm:FindFirstChild("RightGrip")
	if not Joint then
		return false
	end
	if not (Joint.Part0 == Handle or Joint.Part1 == Handle) then
		return false
	end
	return true
end


return Sword
