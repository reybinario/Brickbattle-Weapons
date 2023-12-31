--!strict
local Sword = {}

local tool = script.Parent.Parent
local UserInput = game:GetService("UserInputService")
local Collections = game:GetService("CollectionService")

local currentState = "Up"

local function createToolAnim(animName)
	local toolAnim = Instance.new("StringValue")
	toolAnim.Name = ("toolanim")
	toolAnim.Value = animName
	Collections:AddTag(toolAnim,"SwordObject")
	toolAnim.Parent = tool
end

local function createClientSound(Name, handle)
	local Sound = handle:WaitForChild(Name)

	local NewSound = Sound:Clone()
	NewSound.Name = "Client"..NewSound.Name 
	NewSound.Parent = handle
	Sound:Destroy()

	return NewSound
end

function Sword:Lunge()
	local FloatAmount = _G.BB.Settings.Sword.FloatAmount
	local JumpHeight = _G.BB.Settings.Sword.JumpHeight
	local LungeDelayTime = _G.BB.Settings.Sword.LungeDelayTime
	local LungeExtensionTime = _G.BB.Settings.Sword.LungeExtensionTime
	
	createToolAnim("Lunge")
	
	local root = self.Character:FindFirstChild("HumanoidRootPart")
	local isHoldingSpace = game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space)
	local isInAirMaterial = self.Humanoid.FloorMaterial == Enum.Material.Air
	local isInAirState = (
		self.Humanoid:GetState() == Enum.HumanoidStateType.Jumping or
		self.Humanoid:GetState() == Enum.HumanoidStateType.Freefall
	)
	
	if root and (isInAirMaterial or isInAirState or isHoldingSpace or self.Humanoid.Jump) and (FloatAmount > 0) then
		
		--Once upon a time the sword Handle had a mass, making the character mass 14.84.
		--Everyone defined their FloatAmount based on this mass value for the player.
		--We fixed the sword having a mass, but this means characters now weigh 12.6 units.
		--This correctionFactor makes it so people who override the floatAmount won't see a change in sword force when this is pushed.
		local correctionFactor = 12.6 / 14.84
		
		local lungeForce = Instance.new("BodyVelocity")
		lungeForce.Velocity = Vector3.new(0, JumpHeight, 0)
		lungeForce.MaxForce = Vector3.new(0, FloatAmount * correctionFactor, 0)
		lungeForce.Name = "LungeForce"
		
		Collections:AddTag(lungeForce, "SwordObject")
		
		lungeForce.Parent = root
		
		game:GetService("Debris"):AddItem(lungeForce, .5)
	end
	
	if LungeDelayTime > 0 then
		--task.wait(LungeDelayTime)
		SafeWait.wait(LungeDelayTime)
	end
	
	self.lungeSound:Play()	
	
	-- since input is delayed by .1 seconds to replicate classic feel, fire to the server ahead of time 
	self.GripEvent:FireServer("Out")

	-- client only animations
	currentState = ("Out")
	self.SwordModule:PositionLunge(tool)
	
	--task.wait(LungeExtensionTime)
	SafeWait.wait(LungeExtensionTime)
	
	currentState = ("Up")
	self.SwordModule:PositionIdle(tool)
	self.GripEvent:FireServer("Up")
end

function Sword:Slash()
	self.slashSound:Play()	
	currentState = ("Attack")
	createToolAnim("Slash")
	self.GripEvent:FireServer("Down")
end

function Sword:Init()
	local Player = game:GetService("Players").LocalPlayer
	local Character = Player.Character
	
	self.Character = Character
	self.Humanoid = Character:WaitForChild("Humanoid")

	self.GripEvent = tool:WaitForChild("Grip")
	self.SwordModule = require(tool:WaitForChild("SwordModule"))

	local HandleCrosshair = require(_G.BB.ClientObjects:WaitForChild("HandleCrosshair"))
	local Kill = require(_G.BB.Modules:WaitForChild("Kill"))
	local PSPV = require(_G.BB.Modules.Security:WaitForChild("PSPV"))
	SafeWait = require(_G.BB.Modules.Security:WaitForChild("SafeWait"))
	local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

	local handle = tool:WaitForChild("Handle")
	local Activation = tool:WaitForChild("Activation")
	local Damage = tool:WaitForChild("Damage")
	
	local IsTrueMobile = UserInput.TouchEnabled and not UserInput.MouseEnabled
	local lastInput = -1
	local equipped = false

	HandleCrosshair(tool)
	Aesthetics:HandleSword(Player, handle)

	self.equipSound = createClientSound("Equip", handle)
	self.slashSound = createClientSound("Slash", handle)
	self.lungeSound = createClientSound("Lunge", handle)
	
	local function Activate()
		if not tool.Enabled or not equipped then 
			return
		end
		
		tool.Enabled = false
		
		local now = tick()
		if now - lastInput < _G.BB.Settings.Sword.DoubleClickTime then
			self:Lunge()
		else
			self:Slash()
		end
		
		lastInput = now
		
		task.wait(_G.BB.Settings.Sword.ReloadTime)
		
		tool.Enabled = true
	end
	
	Activation.Event:Connect(Activate)
	
	local mobileDoubleTapTime = 0.2
	local last = -10
	
	local function ActivateJump()
		local now = tick()

		if _G.BB.TrueMobile and _G.BB.Local.MobileJump then
						
			if now - last < mobileDoubleTapTime then
				Activate()
			end
			
			last = now
		end
	end
	
	
	if _G.BB.TrueMobile and _G.BB.Settings.Mobile.DoubleJumpToSwordLunge  
		and _G.BB.Local.MobileJump then
		UserInput.JumpRequest:Connect(ActivateJump)
	end
	
	tool:GetPropertyChangedSignal("GripPos"):Connect(function()
		if currentState == ("Out") then
			self.SwordModule:PositionLunge(tool)
		else
			self.SwordModule:PositionIdle(tool)
		end
	end)
	
	-- sword equip sound client:
	tool.Equipped:Connect(function()
		equipped = true
		--if not _G.BB.TrueMobile then
		--	equipSound.TimePosition = 0.1
		--end
		self.equipSound:Play()		
	end)
	
	tool.Unequipped:Connect(function()
		equipped = false
	end)
	
	handle.Touched:Connect(function(hit)
		if hit.Parent then
			
			-- Don't damage if hit is HRP, commonly manipulated by
			-- exploiters.
			if hit.Name == "HumanoidRootPart" then 
				return 
			end
			
			local hitHumanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
			local hitPlayer = hitHumanoid and game.Players:GetPlayerFromCharacter(hitHumanoid.Parent)

			if hitHumanoid 
				and Kill:CanDamage(Player, hitHumanoid, false) 
				and self.SwordModule:CheckJoint(Character, handle) then
					
				-- Gather security data, will return nil if Security is off
				local Source = hitPlayer and hitPlayer or hitHumanoid
				local HitCharacterData = PSPV:CreateCharFrameTables(Source)
				local LocalCharacterData = PSPV:CreateCharFrameTables(Player)

				local SERVER_TIME
				if game.ReplicatedStorage:FindFirstChild("SERVER_TIME") then
					SERVER_TIME = game.ReplicatedStorage.SERVER_TIME.Value
				end
				
				-- Send data to server (no debounce, stay true to old RBLX)
				Damage:FireServer(
					hit,
					HitCharacterData,
					LocalCharacterData,
					SERVER_TIME
				)
			end
		end
	end)
end

return Sword