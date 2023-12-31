--!strict
local Trowel = {}

local tool = script.Parent.Parent;

local UpdateEvent = tool:WaitForChild("Update")
local BuildSound = tool.Handle:WaitForChild("BuildSound");
local Aesthetics = require(_G.BB.Modules:WaitForChild("Aesthetics"))

local Debris = game:GetService("Debris")
local Collections = game:GetService("CollectionService")
local Physics = game:GetService("PhysicsService")

function Trowel:CreateBrick(brickModel)
	
	local Folder,Theme = Aesthetics:GetThemeObject(self.Player,"Trowel");
	
	local brick = Folder:FindFirstChildWhichIsA("Part"):Clone()
	local BrickIndex = #brickModel:GetChildren() + 1
	local Gradient = Folder:FindFirstChildWhichIsA("UIGradient")
	
	local RowNum = math.ceil(BrickIndex / self.BricksPerRow)
	local Alpha = (RowNum - 1) / (self.BricksPerColumn - 1)

	brick.Color = Aesthetics:GetColorAtTime(Gradient.Color, 1 - Alpha)
	brick.Color = Theme == "Team Color" and self.Player.TeamColor.Color or brick.Color

	brick.Massless = false
	brick.CanCollide = true
	brick.CastShadow = true
	brick.Shape = Enum.PartType.Block
	brick.BottomSurface = Enum.SurfaceType.Inlet
	brick.TopSurface = Enum.SurfaceType.Studs
	brick.Size = self.BrickSize
	brick.Position = self.Character.PrimaryPart.Position + Vector3.new(0,8000,0)
	
	if self.Outlines then
		-- Add an aesthetic outline
		local outLine = Instance.new("SelectionBox")
		outLine.LineThickness = 0.01
		outLine.Color3 = Color3.fromRGB(30, 30, 30)
		outLine.Parent = brick
		outLine.Adornee = brick
	end
	
	brick.Parent = brickModel
	
	-- Make sure the first placed brick has the sound
	if BrickIndex == 1 then
		BuildSound:Clone().Parent = brick
	end
	
	-- Add creator tag
	local new_tag = Instance.new("ObjectValue")
	new_tag.Name = ("creator")
	new_tag.Value = self.Player
	new_tag.Parent = brick
	
	-- Name the brick a number, which will determine when it is placed when a wall is built.
	brick.Name = BrickIndex
	
	-- Pretty sure the "Trowel Exploit" happened because of this
	--brick:SetNetworkOwner(self.Player)
	
	-- Temporarily anchor the briccc.
	brick.Anchored = true
	
	Collections:AddTag(brick, "TrowelWallBrick")
end

function Trowel:PrepareBufferWall()
	local name = (self.Player.Name.."'s Wall")
	
	if self.Buffer.Value ~= nil then
		return
	end
	
	-- Create new buffer wall model, now stored inside the buffer folder.
	local Wall = Instance.new("Model")
	Wall.Name = name;

	-- Create buffer bricks. Wall is not formatted for now.
	local BrickCount = self.BricksPerRow * self.BricksPerColumn
	for i = 1,BrickCount do
		self:CreateBrick(Wall)
	end
	
	local PhysicsFolder = Instance.new("Folder")
	PhysicsFolder.Name = "PhysicsFolder"
	
	local CT = Instance.new("Color3Value")
	CT.Name = "RandomColor"
	CT.Value = self.Aesthetics:RandomColor()
	CT.Parent = PhysicsFolder
	
	local CF = Instance.new("CFrameValue")
	CF.Name = "PlaceCFrame"
	CF.Parent = PhysicsFolder
	
	local creator = Instance.new("ObjectValue")
	creator.Name = "creator"
	creator.Value = self.Player
	creator.Parent = PhysicsFolder
	
	local wV = Instance.new("ObjectValue")
	wV.Name = "Wall"
	wV.Value = Wall
	wV.Parent = PhysicsFolder
	
	local ProjectileType = Instance.new("StringValue")
	ProjectileType.Name = "ProjectileType"
	ProjectileType.Value = "Wall"
	ProjectileType.Parent = PhysicsFolder
	
	PhysicsFolder.Parent = Wall
	
	Wall.Parent = self.BufferFolder
	self.Buffer.Value = Wall
end

function Trowel:Init(Settings,Modules,Buffers,Player,Character,Folder)
	self.BrickSize = Settings.Trowel.BrickSize
	self.BricksPerRow = Settings.Trowel.BricksPerRow
	self.BricksPerColumn = Settings.Trowel.BricksPerColumn
	self.Outlines = Settings.Trowel.Outlines
	
	self.BufferFolder = Folder:WaitForChild("Buffers"):WaitForChild(Player.Name)	
	
	self.Buffer = Buffers:WaitForChild("Wall")
	
	self.Aesthetics = require(Modules:WaitForChild("Aesthetics"))
	self.TrowelModule = require(tool:WaitForChild("TrowelModule"))

	self.Player = Player
	self.Character = Character
	
	local ActiveFolder = Folder:WaitForChild("Active"):WaitForChild(Player.Name)

	local Lifetime = Settings.Trowel.Lifetime

	local verifyBuffer = require(tool:WaitForChild("VerifyBuffer"))

	local lastActivation = -5
	
	UpdateEvent.OnServerEvent:connect(function(playerFired,cf)
		local now = time()
		
		-- Ensure firing player is the owner of the tool and is waiting reload time.
		local LenientReloadTime = math.max(Settings.Trowel.ReloadTime - 1, Settings.Trowel.ReloadTime * .6)
		
		if playerFired == Player and (now - lastActivation) > LenientReloadTime then
			if Player.Character and Player.Character.Parent and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
				lastActivation = now;
				
				if verifyBuffer(self.Buffer, ActiveFolder) then
					local wall = self.Buffer.Value
					local PhysicsFolder = wall.PhysicsFolder
			
					wall.Parent = ActiveFolder
					
					PhysicsFolder.PlaceCFrame.Value = cf
					wall.AncestryChanged:Connect(function()
						PhysicsFolder:Destroy()
					end)
					
					Debris:AddItem(wall, Lifetime);
					
					local function BuildWall()
						self.TrowelModule:BuildWall(cf,wall, 0.04, true);
					end
					task.spawn(BuildWall)
				end
			
				self.Buffer.Value = nil
				self:PrepareBufferWall()
			end
		end
	end)
	
	self:PrepareBufferWall()
	
	tool.Enabled = true
end

return Trowel