--!strict
-- Past Server Position Verification
local PSPV = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MaxDistances = {
	["Head"] = 1.6,
	["Right Arm"] = 2,
	["Left Arm"]= 2,
	["Left Leg"]= 2.3,
	["Right Leg"]= 2.3,
	["Torso"] = .1,
	["HumanoidRootPart"] = .1
}

local DefaultHRP = Vector3.new(2,2,1)

local function findTimeFromRoot(ClientRootPosition,HitPlayerName,ClientSeenTime)
	local ReturningTable
	local BestMagnitude = 100
	local BestTimeDifference = 1
	
	--print("Evaluating with client time stamp:",ClientSeenTime)
	
	for  _,RecordedCharData in pairs(_G.BB.MasterTimeTable[HitPlayerName]) do
		
		local RecordedRootPosition = RecordedCharData[2]["HumanoidRootPart"].Position
		local RecordedTime = RecordedCharData[1]
		
		local TimeDifference = math.abs(ClientSeenTime - RecordedCharData[1])
		local Magnitude = (ClientRootPosition - RecordedRootPosition).Magnitude
		
		if ((Magnitude > 0.1 and Magnitude < BestMagnitude) or Magnitude <= 0.1) and TimeDifference < BestTimeDifference then
			--print("Mag:",BestMagnitude,"TD:",BestTimeDifference)
			BestMagnitude = Magnitude
			BestTimeDifference = TimeDifference
			ReturningTable = RecordedCharData
		end
		
	end
	--[[ Debug
	local ReportMag = math.round(BestMagnitude*100)/100
	local ReportTD = math.round(BestTimeDifference*100000000)/100000000
	local Frames = math.floor((BestTimeDifference/(1/60)) + 0.5)
	local Steps = Frames*4
	print("Selected time stamp: ",ReturningTable[1],"Mag:",ReportMag,"TD:",ReportTD,"Frames:",Frames,"Steps:",Steps)
	]]
	return ReturningTable[1], ReturningTable[2] -- Time + Character data table
end

function PSPV:Verify(CharacterDataFrames, ProjectileCFrames, ProjectileSize, ProjectileShape, HitPlayerName, PhysicsFolder, SameParabola)
	if not _G.BB.Settings.Security.PSPV then
		return true
	end
	local info = PhysicsFolder and PhysicsFolder.UniqueID.Value or "Sword"

	--print(" >> PSPV","\n 1, Beginning PSPV for",info)
	
	--[[ Details
		CharacterDataFrames = {
			{Time, CFrameTable}, -- Post touch
			{Time, CFrameTable}, -- pre frame (if nec.)
			{Time, CFrameTable}, -- pre touch (if nec.)
		}
		Time = game.ReplicatedStorage.SERVER_TIME.Value
		Updated by server every heartbeat with time()
		CFrameTable = {
			Torso = CFrame
			Right Arm = CFrame
			etc
		}
	]]
	
	local ServerCFrames = {}
	
	-- Verify time
	for i,CharacterData in pairs(CharacterDataFrames) do
		
		-- Prevent long lag shadow hits
		local Now = time()
		local Lag = Now-CharacterData[1]
		if Lag>1 then -- Sorry BLOODTUSSK
			warn("\n\t Sent client time too old:","Client time:",CharacterData[1],"Now:",Now,"Lag:", math.round(Lag*100)/100)
			if PhysicsFolder then
				warn(
					"\tID:",PhysicsFolder.UniqueID.Value
				)
				PhysicsFolder.Active.Value = false
			end
			--return false
		end
		
		local SentRootPosition = CharacterData[2]["HumanoidRootPart"].Position
		local MatchingServerTime, ServerCFramesAtFrame = findTimeFromRoot(
			SentRootPosition,
			HitPlayerName,
			CharacterData[1] -- Time
		)
		
		-- For reference when verifying limb positions
		ServerCFrames[i] = ServerCFramesAtFrame

		-- Comparing server time when character was 
		-- at client seen position to client's seen time. 
		local TimeDifference = CharacterData[1] - MatchingServerTime

		if (TimeDifference>.33) then
			warn("\n\tPSPV failed time verification with dT:",TimeDifference,"\nServer time:",MatchingServerTime)
			if PhysicsFolder then
				warn(
					"\tID:",PhysicsFolder.UniqueID.Value
				)
				PhysicsFolder.Active.Value = false
			end
			return false
		end
	end
	
	--[[ Debug
	print("3, time difference of "..TimeDifference.." passed")
	
	local F = Instance.new("Folder")
	local Now = math.round(time()*100)/100
	F.Name = PhysicsFolder and PhysicsFolder.UniqueID.Value or "SwordHit"..Now
	F.Parent = workspace
	SecurityPart.Color = SameParabola and Color3.new(1, 0.941176, 0.278431) or Color3.new(0.615686, 0, 1)
	print("4, SameParabola = ",SameParabola)
	SecurityPart.Touched:Connect(function() end)
	SecurityPart.Parent = F
	
	
	 Position dummy projectile + character
	SecurityPart.Transparency = 0
	
	table.insert(CharacterCFrames,ServerCFrames)
	local Colors = {Color3.fromRGB(0, 170, 0),Color3.fromRGB(147, 147, 147),Color3.fromRGB(255, 255, 255)}
	local First
	]]
	
	local TrueHit = false
	local SecurityPart = self.SecurityPart
	local SecurityDummy = self.SecurityDummy
	SecurityPart.Size = ProjectileSize + Vector3.new(.35,.35,.35)
	SecurityPart.Shape = ProjectileShape
	
	-- Loop through character candidates (may contain candidates for
	-- multiple players, i.e., from a bomb explosion).
	for i,CharacterData in pairs(CharacterDataFrames) do
		local CharacterCFrames = CharacterData[2]
		
		--[[ Debug
		SecurityDummy.Parent = F

		if i == 1 then
			First = SecurityDummy
		end
		]]
		
		local Player = game.Players:FindFirstChild(HitPlayerName)
		
		-- Position limbs
		for PartName,PartCF in pairs(CharacterCFrames) do
			local Part = SecurityDummy:FindFirstChild(PartName)
			
			--[[ Inactive check
			-- Supposed to verify limb positions/distances
			if ServerFrames[i][PartName] then
				local ServerPart = ServerFrames[i][PartName]
				print(PartName,(PartCF.Position-ServerPart.Position).Magnitude)
			end
			
			local HRP = CharacterCFrames.HumanoidRootPart
			local Magnitude = (HRP.Position-PartCF.Position).Magnitude
			if MaxDistances[PartName] and (Magnitude>MaxDistances[PartName]) and Part then
				warn(PartName,"far from Root Part, will not be used in PSPV check,")
				continue
				--return false
			end
			if string.find(PartName,"Leg") then
				if (PartCF.Position.Y>(HRP.Position.Y-1.5)) then
					warn("Not counting",PartName)
					continue
					--return false
				end
			end
			]]
			if Part then
				Part.Size = Player.Character[PartName].Size -- Use server size
				Part.CFrame = PartCF -- Use firing client's seen position
				--Part.Transparency = 0
				--Part.Color = Colors[i]
			end
		end
		--local name = 1
		
		-- Position projectile candidates
		for _,CF in pairs(ProjectileCFrames) do
			-- Position
			SecurityPart.CFrame = CF

			--[[ Debug
			local visualPart
			if SameParabola then
				visualPart = SecurityPart:Clone()
				visualPart.Name = "Candidate projectile "..name
				visualPart.Parent = F
				visualPart.CFrame = CF
				visualPart.Color = Color3.new(0.172549, 0.0823529, 0.0196078) 
				name = name + 1
			end
			]]
			
			-- See if projectile is touching a limb
			local CollectedParts = SecurityPart:GetTouchingParts()
			for _,CharacterPart in pairs(SecurityDummy:GetChildren()) do
				if table.find(CollectedParts,CharacterPart) then
					--if visualPart and not TrueHit then
					--	visualPart.Color = Color3.new(0.615686, 1, 0) -- Touches sent frame
					--end
					TrueHit = true
				end
			end
		end
	end
	
	--[[ Debug
	if First then
		for _,DebugPart in pairs(First:GetChildren()) do
			DebugPart.Color = TrueHit and Color3.new(0.00784314, 0.490196, 0) or Color3.new(1, 0, 0.0156863)
			DebugPart.Transparency = 0
		end
	end
	
	if TrueHit then
		F:Destroy()
	end
	]]
	return TrueHit
end

function PSPV:CreateCharacterCFrameTable(Source)
	if not _G.BB.Settings.Security.PSPV then
		return
	end
	local Character = Source:IsA("Player") and Source.Character or Source:IsA("Humanoid") and Source.Parent
	if not Character then
		warn("Not generating character cframes (could not find char), any hit on this player will not count. ")
		return	
	end
	-- Grab character positional data at current seen server time
	local CharacterCFrame = {}
	for _,CharPart in pairs(Character:GetChildren()) do
		if CharPart:IsA("Part") then
			CharacterCFrame[CharPart.Name] = CharPart.CFrame
		elseif CharPart:IsA("Tool") and CharPart.Name == "Sword" then
			if CharPart:FindFirstChild("Handle") then
				CharacterCFrame[CharPart.Name] = CharPart.Handle.CFrame
			end
		end
	end
	local Time = _G.BB.ServerTime.Value
	return {Time,CharacterCFrame}
end

function PSPV:CreateCharFrameTables(Player)
	if not _G.BB.Settings.Security.PSPV then
		return
	end
	--assert(Player:IsA("Player"),"Arg1 must be a player obj.")
	--assert(TimeTable,"No time scope!")
	local PostFrameData = self:CreateCharacterCFrameTable(Player)
	local PreFrameData1 = _G.BB.SlaveTimeTable[Player.Name] and _G.BB.SlaveTimeTable[Player.Name][1]
	local PreFrameData2 = _G.BB.SlaveTimeTable[Player.Name] and _G.BB.SlaveTimeTable[Player.Name][2]
	--[[
		_G.BB.SlaveTimeTable[PlayerName] = {
			FrameData = {Time,CFrameTable} -- older
			FrameData = {Time,CFrameTable}
		}
	]]
		
	return {PostFrameData,PreFrameData1,PreFrameData2}
end

function PSPV:Init(SecurityPart, SecurityDummy, ServerTimeValue)
	
	if not _G.BB.Settings.Security.PSPV then
		RunService.Heartbeat:Connect(function()
			_G.BB.ServerTime.Value = time()
		end)
		return
	end
	
	self.SecurityDummy = SecurityDummy
	self.SecurityPart = SecurityPart
	
	SecurityPart.Parent = workspace
	SecurityDummy.Parent = workspace
	
	local function RecordPlayerPositions()
		local Time = time()
		_G.BB.ServerTime.Value = Time
		
		for _,Player in pairs (Players:GetPlayers()) do
			if Player.Character then
				
				local CharacterData = self:CreateCharacterCFrameTable(Player)
				
				table.insert(_G.BB.MasterTimeTable[Player.Name],CharacterData)
				
				if #_G.BB.MasterTimeTable[Player.Name] > 360 then
					table.remove(_G.BB.MasterTimeTable[Player.Name],1)
				end
			end
		end
	end
	
	RunService.Heartbeat:Connect(RecordPlayerPositions)
end

function PSPV:InitClient()
	
	if not _G.BB.Settings.Security.PSPV then
		return
	end
	
	local function addPlayer(Player)
		_G.BB.SlaveTimeTable[Player.Name] = {}
	end
	
	for _, Player in pairs(Players:GetPlayers()) do
		addPlayer(Player)
	end
	
	Players.PlayerAdded:Connect(addPlayer)
	
	local function RecordPlayerPositions()
		for _,Player in pairs (Players:GetPlayers()) do
			if Player.Character then
				local CharacterData = self:CreateCharacterCFrameTable(Player)
				
				table.insert(_G.BB.SlaveTimeTable[Player.Name], CharacterData)
				
				if #_G.BB.SlaveTimeTable[Player.Name] > 2 then
					table.remove(_G.BB.SlaveTimeTable[Player.Name],1)
				end
			end
		end
	end
	
	RunService.Heartbeat:Connect(RecordPlayerPositions)
	
end

return PSPV
