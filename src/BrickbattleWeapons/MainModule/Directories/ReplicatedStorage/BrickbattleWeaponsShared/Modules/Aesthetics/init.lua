--!strict
-- GloriedRage
-- Module used for determining aesthetics of explosions and hit indicators.
local Aesthetics = {}

local repStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Physics = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- Yield for themes folder
local ThemesFolder = repStorage:WaitForChild("Themes")

local BrightnessRange = {
	Min = .15,
	Max = .85
}

local swordTrailLoop = nil

Aesthetics.TrailTypes  = {
	"Trail",
	"Fire",
	"ParticleEmitter",
	"Smoke",
	"Beam"
}


local function themesOn()
	return _G.BB.Local and _G.BB.Local.Themes 
end

local function themesHighGraphics()
	return _G.BB.Local and _G.BB.Local.ThemesHighGraphics
end

local function returnRandomBrickColor(ctable)
	return BrickColor.new(ctable[math.random(1, #ctable)])		
end

function Aesthetics:HasNeutralColors(Player)

	local teamName = Player.Team and Player.Team.Name

	if not _G.BB.Settings.AutoTeamColors then
		return true
	end

	if _G.BB.Settings.ThemeOverrides then
		local theme = Player:FindFirstChild("Theme")

		-- do not override if theme is normal/default theme
		if theme and theme.Value ~= _G.BB.Settings.Themes.DefaultTheme then
			return true
		end
	end

	return Player.Neutral or table.find(_G.BB.Settings.TeamsFiltered, teamName)
end

function Aesthetics:DetermineTheme(Player)
	local themeVal = Player:WaitForChild("Theme")
	local theme = themeVal and themeVal.Value

	local base = (themesOn() and themeVal) and theme or _G.BB.Settings.Themes.DefaultTheme
	local teamColor = not self:HasNeutralColors(Player) and "Team Color"

	return teamColor or base or _G.BB.Settings.Themes.DefaultTheme
end

function Aesthetics:GetThemeObject(Player, ObjectName)
	local Theme = self:DetermineTheme(Player)

	local ThemeFolder = (Theme and Theme ~= "Team Color") 
		and ThemesFolder:FindFirstChild(Theme) 
		or ThemesFolder:FindFirstChild("Normal")

	local Object = ThemeFolder and ThemeFolder:FindFirstChild(ObjectName)

	return Object,Theme
end

function Aesthetics:RandomColor()
	return Color3.new(
		math.random(BrightnessRange.Min*1000,BrightnessRange.Max*1000)/1000,
		math.random(BrightnessRange.Min*1000,BrightnessRange.Max*1000)/1000,
		math.random(BrightnessRange.Min*1000,BrightnessRange.Max*1000)/1000
	)
end

function Aesthetics:GetColorAtTime(Sequence, Time)

	local LowerBound, UpperBound = Sequence.Keypoints[1], Sequence.Keypoints[#Sequence.Keypoints]

	for i = 1, #Sequence.Keypoints do
		local Keypoint = Sequence.Keypoints[i]
		if Time - Keypoint.Time >= 0 and Time - Keypoint.Time < Time - LowerBound.Time then
			LowerBound = Keypoint
		end
		if Keypoint.Time - Time >= 0 and Keypoint.Time - Time < UpperBound.Time - Time then
			UpperBound = Keypoint
		end
	end

	Time = Time - LowerBound.Time

	return LowerBound.Value:Lerp(UpperBound.Value, Time)
end

--Handle animated textures
local function animateTexture(t)
	local uSpeed = t:FindFirstChild("UOffsetSpeed") and t.UOffsetSpeed.Value or 0
	local vSpeed = t:FindFirstChild("VOffsetSpeed") and t.VOffsetSpeed.Value or 0

	if uSpeed == 0 and vSpeed == 0 then return end

	if uSpeed ~= 0 then
		local tweenInfo = TweenInfo.new(uSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
		local uTween = TweenService:Create(t, tweenInfo, {OffsetStudsU = 30})
		uTween:Play()
		t.Destroying:Connect(function() uTween:Destroy() end)
	end

	if vSpeed ~= 0 then
		local tweenInfo = TweenInfo.new(vSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
		local vTween = TweenService:Create(t, tweenInfo, {OffsetStudsV = 30})
		vTween:Play()
		t.Destroying:Connect(function() vTween:Destroy() end)
	end

end

function Aesthetics:UpdateSuperballHandle(Player, handle, colorEvent, initial)

	-- Update handle
	local Folder, Theme = self:GetThemeObject(Player, "Superball")
	local Part = Folder:FindFirstChildWhichIsA("Part")
	handle.Material = Part.Material
	handle.Reflectance = Part.Reflectance
	handle.Transparency = Part.Transparency
	
	local replicated = (Player ~= game.Players.LocalPlayer)

	if initial then
		for _,v in pairs(handle:GetChildren()) do
			if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Texture") then
				v:Destroy()
			end
		end

		for _,v in pairs(Part:GetChildren()) do
			if v:IsA("Texture") then
				local vv = v:Clone()
				vv.Parent = handle
				if vv:FindFirstChild("UOffsetSpeed") or vv:FindFirstChild("VOffsetSpeed") then
					animateTexture(vv)
				end
			end
		end
	end
	
	if replicated then return end
	
	local NonCustomThemes = {
		_G.BB.Settings.Themes.DefaultTheme,
		"Team Color",
	}

	handle.Color = (themesOn() and not table.find(NonCustomThemes, Theme)) 
		and (Part.Color)
		or Theme == "Team Color"
		and Player.TeamColor.Color 
		or (_G.BB.Settings.Themes.RandomSuperballColors 
			and self:RandomColor() 
			or Part.Color)

	colorEvent:FireServer(handle.Color, handle.Transparency, handle.Reflectance, handle.Material, Folder, initial)
end

function Aesthetics:HandleSBHandle(Player, handle, colorEvent, initial)

	local ThemeValue = Player:WaitForChild("Theme")

	self:UpdateSuperballHandle(Player, handle, colorEvent, initial)

	if initial then
		ThemeValue.Changed:Connect(function()
			self:UpdateSuperballHandle(Player, handle, colorEvent, initial)
		end)
		
		_G.BB.Remotes:WaitForChild("ThemeActivation").Event:Connect(function()
			self:UpdateSuperballHandle(Player, handle, colorEvent, initial)
		end)
	end	
end

function Aesthetics:HandleSword(Player, handle, Server)
	local ThemeValue = Player:WaitForChild("Theme")
	local Connection

	local function ColorSword()
		local Folder = self:GetThemeObject(Player, "Sword")

		local HandleRef = Folder:FindFirstChildWhichIsA("Part")
		handle.Color = HandleRef.Color
		handle.Reflectance = HandleRef.Reflectance
		handle.Transparency = HandleRef.Transparency
		handle.Material = HandleRef.Material

		local Mesh = HandleRef:FindFirstChildWhichIsA("SpecialMesh")
		local myMesh = handle:WaitForChild("Mesh", 3)
		if myMesh then
			myMesh.TextureId = Mesh.TextureId
			myMesh.VertexColor = Mesh.VertexColor
		end
	end

	local function AssignColors()
		ColorSword()
		local HasTrail = self:CreateSwordTrail(handle,Player)
		if not Server and (HasTrail or not _G.BB.Local.Themes) then
			if not Connection then
				Connection = handle.DescendantAdded:Connect(function(Child)
					if Child.Name == "ServerTrail" then
						game:GetService('Debris'):AddItem(Child,0)
					end
				end)
			end

			for _,Child in pairs(handle:GetDescendants()) do
				if Child.Name == "ServerTrail" then
					Child:Destroy()
				end
			end
		end
	end

	local function themeChanged()
		for _,Child in pairs(handle:GetDescendants()) do
			if table.find(Aesthetics.TrailTypes,Child.ClassName) then
				Child:Destroy()
			end
		end
		AssignColors()
	end

	if not Server then
		_G.BB.Remotes:WaitForChild("ThemeActivation").Event:Connect(themeChanged)
	end

	AssignColors()

	ThemeValue.Changed:Connect(themeChanged)
end

function Aesthetics:ToggleThemes(value)
	if _G.BB == nil then
		warn("Global table not found, yielding.")
		while _G.BB == nil do
			task.wait()
		end
	end

	local Themes


	if value == nil or type(value) ~= "boolean" then
		Themes = not _G.BB.Local.Themes
	else
		Themes = value
	end

	_G.BB.Local.Themes = Themes


	_G.BB.Remotes:WaitForChild("ThemeActivation"):Fire()

	if swordTrailLoop then
		swordTrailLoop:Disconnect()
	end

	if Themes then
		return
	end

	-- Run through every single player and toggle their trail off every render step
	swordTrailLoop = RunService.RenderStepped:Connect(function()
		for _, Plr in pairs (Players:GetPlayers()) do
			if Plr.Character and Plr ~= Players.LocalPlayer then
				local Sword = Plr.Character:FindFirstChild("Sword") or Plr.Backpack:FindFirstChild("Sword")
				if Sword then
					local Handle = Sword:FindFirstChild("Handle")
					if Handle then
						for _, Desc in pairs (Handle:GetDescendants()) do
							if table.find(Aesthetics.TrailTypes,Desc.ClassName) then
								game:GetService("Debris"):AddItem(Desc,0)
							end
						end
					end
				end
			end
		end
	end)

	return Themes
end


function Aesthetics:CreateSwordTrail(Handle, Creator, Server)

	local Reference,Theme = Aesthetics:GetThemeObject(Creator,"Sword")
	local Children = Reference:FindFirstChildWhichIsA("Part"):GetChildren()

	local AddedTrail = false
	for _,Trail in pairs(Children) do
		if not (Trail and Trail.ClassName and table.find(Aesthetics.TrailTypes,Trail.ClassName)) then 
			--warn("No trail for",Creator,"with theme",Theme) 
			continue 
		end
		AddedTrail = true

		if Trail:IsA("Trail") then -- could also be a fire
			Trail = Trail:Clone()

			if Theme == "Team Color" then
				Handle.Color = Creator.TeamColor
			end

			if Theme == "Team Color" or Theme == "Normal" then
				Trail.Color = Aesthetics:CustomColorSequence(Handle.Color)
			end

			Trail.Attachment0 = Handle:WaitForChild("A0")
			Trail.Attachment1 = Handle:WaitForChild("A1")
			Trail.FaceCamera = false
			Trail.Enabled = false
			Trail.Name = Server and "ServerTrail" or "ClientTrail"
			Trail.Parent = Handle

		elseif table.find(Aesthetics.TrailTypes,Trail.ClassName) then

			for _,Child in pairs(Handle:GetChildren()) do

				if Child:IsA("Attachment")then

					Trail = Trail:Clone()
					Trail.Enabled = false
					Trail.Name = Server and "ServerTrail" or "ClientTrail"
					Trail.Parent = Child
				end
			end
		end
	end
	return AddedTrail
end


function Aesthetics:ToggleSwordTrail(handle,Activation)
	for _,Child in pairs(handle:GetDescendants()) do

		if table.find(Aesthetics.TrailTypes,Child.ClassName)then

			coroutine.wrap(function() 

				if not Activation then
					task.wait(.1)	
				end

				if not (Activation and not themesHighGraphics()) then --If HighGraphics == false, trail can be disabled but not enabled
					Child.Enabled = Activation
				end
			end)()
		end
	end
end

local function lowerVal(value)

	local a = math.max(value - 70, 0)
	local b = value * .5

	return math.min(a, b)
end

function Aesthetics:CustomColorSequence(baseColor3)

	local darkColor3 = Color3.new(
		lowerVal(baseColor3.r), 
		lowerVal(baseColor3.g), 
		lowerVal(baseColor3.b)
	)

	return ColorSequence.new(baseColor3, darkColor3)
end

function Aesthetics:ApplyWallColors(Brick, randomColor)
	if not Brick:IsA("Part") then
		return
	end

	local Creator = Brick.creator.Value
	local BrickIndex = tonumber(Brick.Name)
	local Folder, Theme = Aesthetics:GetThemeObject(Creator, "Trowel")
	local Part = Folder:FindFirstChildWhichIsA("Part")

	local Gradient = Folder:FindFirstChildWhichIsA("UIGradient")
	local RowNum = math.ceil(BrickIndex / _G.BB.Settings.Trowel.BricksPerRow)
	local Alpha = (RowNum - 1) / (_G.BB.Settings.Trowel.BricksPerColumn - 1)

	Brick.Transparency = Part.Transparency
	Brick.Reflectance = Part.Reflectance
	Brick.Material = Part.Material

	local RandomColor = Theme == "Normal" and _G.BB.Settings.Themes.RandomWallColors
	local Color = RandomColor and randomColor or self:GetColorAtTime(Gradient.Color, 1 - Alpha)

	Brick.Color = Theme == "Team Color" and Creator.TeamColor.Color or Color
end

function Aesthetics:HandleProjectileVisuals(Creator, Part, Theme)
	Aesthetics:AddTrail(Creator, Part)

	if not themesHighGraphics() then
		for _,v in pairs(Part:GetChildren()) do
			if v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") or v:IsA("Smoke") then
				v:Destroy()
			end
		end
	end
	
	for _,v in pairs(Part:GetChildren()) do
		if v:IsA("Texture") and (v:FindFirstChild("UOffsetSpeed") or v:FindFirstChild("VOffsetSpeed")) then
			animateTexture(v)
		end
	end
end

function Aesthetics:AddTrail(Creator, Part)
	if not themesHighGraphics() then --themesOn
		return
	end

	local Theme = self:DetermineTheme(Creator)

	if table.find(_G.BB.Settings.Themes.TrailsOmitted,Theme) then
		return
	end

	local Children = Part:GetChildren()
	for _,Trail in pairs(Children) do

		if not (Trail and Trail.ClassName and table.find(self.TrailTypes, Trail.ClassName)) then 
			--warn("No trail for", Creator, "with theme", Theme) 
			continue 
		end

		Trail = Trail:Clone()

		if Theme == "Team Color" or Theme == "Normal" then
			Trail.Color = self:CustomColorSequence(Part.Color)
		end

		local Size = Part.Size.X/2

		if Trail:IsA("Trail") then -- could also be a fire
			local a0 = Instance.new("Attachment")
			a0.Name = "0"
			a0.Position = Vector3.new(-Size,0,0)
			a0.Parent = Part

			local a1 = Instance.new("Attachment")
			a1.Name = "1"
			a1.Position = -Vector3.new(-Size,0,0)
			a1.Parent = Part
			Trail.Attachment0 = a0
			Trail.Attachment1 = a1
		end

		Trail.Parent = Part
	end
end

function Aesthetics:PaintballColor(Hit, Color)
	local oldColor = Hit.Color

	local originalColor = Hit:FindFirstChild("OriginalColor")

	if originalColor then
		oldColor = originalColor.Value
	else
		local val = Instance.new("Color3Value")
		val.Name = "OriginalColor"
		val.Value = oldColor
		val.Parent = Hit
	end

	Hit.Color = Color


	local Mesh = Hit:FindFirstChildWhichIsA("FileMesh")
	local part = Hit:IsA("Part")
	local functionUponReset = nil

	local reset = _G.BB.Settings.PaintballGun.ColorResetTime > 0
	local timeUntilRemove = _G.BB.Settings.PaintballGun.ColorResetTime
	local timeUntilTween = timeUntilRemove - 3
	local tweenDuration = timeUntilRemove - timeUntilTween

	local plr = Players:GetPlayerFromCharacter(Hit.Parent)
	local hum = Hit.Parent:FindFirstChildWhichIsA("Humanoid")
	local hrp = Hit.Name == "HumanoidRootPart"

	-- Only a tween if _G.BB.Local.Themes is true.
	local tweenInfo = TweenInfo.new(
		tweenDuration, -- Time
		Enum.EasingStyle.Linear, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- RepeatCount (when less than zero the tween will loop indefinitely)
		false, -- Reverses (tween will reverse once reaching it's goal)
		0 -- DelayTime
	)

	if Hit:IsA("MeshPart") and not hum then
		local oldId = Hit.TextureID
		Hit.TextureID = ""

		functionUponReset = function()
			Hit.TextureID = oldId
		end

	elseif Mesh then
		local oldId = Mesh.TextureId
		Mesh.TextureId = ""

		functionUponReset = function()
			Mesh.TextureId = oldId
		end

	elseif hum and Hit.Name ~= "Head" then
		local guiArray = {}

		for _, gui in pairs (script.PaintballGUIs:GetChildren()) do

			local new = gui:Clone()
			new.Frame.BackgroundColor3 = Color

			local current = Hit:FindFirstChild(gui.Name)
			if current then
				current:Destroy()
			end

			new.Parent = Hit

			if reset then
				Debris:AddItem(new, timeUntilRemove)
			end

			table.insert(guiArray, new)
		end

		functionUponReset = function()
			if themesHighGraphics() then --themesOn
				for _, gui in pairs(guiArray) do

					local tween = TweenService:Create(gui.Frame, tweenInfo, {BackgroundTransparency = 1})
					tween:Play()
				end
			end
		end

	elseif Hit:IsA("UnionOperation") then
		Hit.UsePartColor = true
	end

	if reset then

		local stillReset = true
		local conn 

		conn = Hit.Changed:Connect(function(property)
			if property == "Color" then
				if Hit.OriginalColor.Value ~= Hit.Color then
					stillReset = false
					if functionUponReset then
						functionUponReset()
					end
					conn:Disconnect()
				end
			end
		end)

		task.delay(timeUntilTween, function()
			if conn then
				conn:Disconnect()
			end

			if stillReset then
				if themesHighGraphics() then --themesOn
					local tween = TweenService:Create(Hit, tweenInfo, {Color = oldColor})
					tween:Play()
				else
					Hit.Color = oldColor
				end

				if functionUponReset then
					functionUponReset()
				end
			end
		end)
	end
end

function Aesthetics:ExplodePaintball(Paintball)

	Paintball.Anchored = true
	Paintball.Transparency = 1
	Paintball.CanCollide = false

	for _,v in pairs(Paintball:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end

	for i = 1, math.random(2, 3) do
		local DebrisPart = Instance.new("Part")

		Physics:SetPartCollisionGroup(DebrisPart, "Paintballs")

		DebrisPart.Name = "PaintballDebris"
		DebrisPart.Size = Vector3.new(1,0.4,1)
		DebrisPart.BrickColor = Paintball.BrickColor

		-- yuck
		local RandomDistance = Vector3.new(
			math.random(-10, 10) / 10, 
			math.random(0, 10) / 10, 
			math.random(-10, 10) / 10
		).Unit * (math.random(10, 20) / 10)

		DebrisPart.CFrame = CFrame.lookAt(Paintball.Position + RandomDistance, Paintball.Position)

		DebrisPart.Velocity = 15 * RandomDistance 
		DebrisPart.Parent = workspace
		Debris:AddItem(DebrisPart, math.random(3, 5))
	end

	Debris:AddItem(Paintball,1.5)
end

function Aesthetics:CreateCustomExplosion(Player, ExplosionPart)

	local HighGraphics = themesHighGraphics() --themesOn()

	local ParticleFolder, Theme = self:GetThemeObject(Player, "ExplosionParticles")
	local ExplosionFolder = ParticleFolder.Parent.Explosion

	local performantBase = ExplosionFolder:FindFirstChild("Base") or {
		Color = ExplosionPart.Color,
		Material = Enum.Material.SmoothPlastic,
		Transparency = .5,
	}

	local aestheticBase = ExplosionFolder:FindFirstChild("Theme") or {
		Color = ExplosionPart.Color,
		Material = Enum.Material.Neon,
		Transparency = .7,
	}

	local ExplosionBase = HighGraphics and aestheticBase or performantBase
	local baseTime = ExplosionFolder:FindFirstChild("BaseTime")
	local themeTime = ExplosionFolder:FindFirstChild("ThemeTime")

	local TIME = HighGraphics and (themeTime and themeTime.Value or .6) 
		or (baseTime and baseTime.Value or .3)

	--[[local Fire = ExplosionPart:FindFirstChildWhichIsA("Fire")
	if Fire then
		Debris:AddItem(Fire, 0)
	end]]
	for _,v in pairs(ExplosionPart:GetChildren()) do
		if v:IsA("Fire") then
			v.Enabled = false
			Debris:AddItem(v, 1) --?
		elseif v:IsA("ParticleEmitter") then
			v.Enabled = false
			Debris:AddItem(v, v.Lifetime.Max) --?
		end
	end

	local radius = ExplosionPart.Size.X / 2
	ExplosionPart.Name = Player.Name.."'s Client Explosion"
	ExplosionPart.Shape = Enum.PartType.Ball
	ExplosionPart.Anchored = true
	ExplosionPart.CanCollide = false
	ExplosionPart.CastShadow = false
	ExplosionPart.Color = Theme == "Team Color" and Player.TeamColor.Color or ExplosionBase.Color
	ExplosionPart.Material = ExplosionBase.Material
	ExplosionPart.Transparency = ExplosionBase.Transparency
	ExplosionPart.BottomSurface = Enum.SurfaceType.Smooth
	ExplosionPart.TopSurface = Enum.SurfaceType.Smooth
	ExplosionPart.LeftSurface = Enum.SurfaceType.Smooth
	ExplosionPart.RightSurface = Enum.SurfaceType.Smooth
	ExplosionPart.FrontSurface = Enum.SurfaceType.Smooth
	ExplosionPart.BackSurface = Enum.SurfaceType.Smooth

	if HighGraphics then

		-- Either use default Roblox explosion or
		-- use custom explosions.

		if _G.BB.Settings.Themes.UseRobloxExplosions then

			ExplosionPart.Transparency = 1

			local Explosion = Instance.new("Explosion")
			Explosion.Name = Player.Name.."'s Aesthetic Explosion"
			Explosion.BlastPressure = 0
			Explosion.BlastRadius = radius
			Explosion.DestroyJointRadiusPercent = 0
			Explosion.ExplosionType = Enum.ExplosionType.NoCraters
			Explosion.Position = ExplosionPart.Position
			Explosion.Parent = workspace

			Debris:AddItem(Explosion, 5)
		else

			-- Prepare aesthetic objects
			for _,Object in pairs(ParticleFolder:GetChildren()) do

				local Object = Object:Clone()

				if Object:IsA("ParticleEmitter") then

					Object.Speed = NumberRange.new((Object.Speed.Min/2) * radius, (Object.Speed.Max / 2) * radius)
					Object.Rate = (Object.Rate / 2) * radius

					if Theme == "Team Color" then
						Object.Color = self:CustomColorSequence(ExplosionPart.Color)
					end

				elseif Object:IsA("Smoke") then

					Object.Size = radius * 2.2

				elseif Object:IsA("Folder") then

					local partDecals = Object:GetChildren()

					for _, Decal in pairs (partDecals) do
						Decal.Parent = ExplosionPart
					end
				end

				Object.Parent = ExplosionPart
			end

			-- Begin tweening
			local function PlayTweens()
				for _,Object in pairs (ExplosionPart:GetChildren()) do

					if Object:IsA("Decal") then
						TweenService:Create(Object, TweenInfo.new(TIME, Enum.EasingStyle.Linear), {Transparency = 1}):Play()

					elseif Object:IsA("Smoke") then
						TweenService:Create(Object,TweenInfo.new(TIME, Enum.EasingStyle.Linear), {Opacity = 0}):Play()

					elseif Object:IsA("ParticleEmitter") then
						Object:Emit(Object.Rate)
					end
				end
			end

			task.spawn(PlayTweens)

			TweenService:Create(ExplosionPart, TweenInfo.new(TIME, Enum.EasingStyle.Linear), {Transparency = 1}):Play()

		end
	end

	local function CleanUp()
		ExplosionPart.Size = Vector3.new(.01,.01,.01)
		ExplosionPart.Transparency = 1

		for _,Child in pairs(ExplosionPart:GetChildren()) do

			if Child:IsA("ParticleEmitter") or Child:IsA("Smoke") or Child:IsA("Decal") then
				Child:Destroy()
			end
		end
	end

	task.delay(TIME, CleanUp)
	Debris:AddItem(ExplosionPart, 5)
end

local function doOutline(Part, color)

	local Outline = Instance.new("SelectionBox")
	Outline.SurfaceColor3 = color
	Outline.Transparency = 1
	Outline.SurfaceTransparency=0
	Outline.Parent = Part
	Outline.Adornee = Outline.Parent

	local Tween = TweenService:Create(Outline, TweenInfo.new(1), {SurfaceTransparency=1})
	Tween:Play()

	local function RemoveOutline()
		Tween.Completed:Wait()
		Outline:Destroy()
	end

	coroutine.wrap(RemoveOutline)()
end

function Aesthetics:CreateVisual(hitPart, player, highlightEntireCharacter)
	if not _G.BB.Local.VisualHitIndicators then
		return
	end

	if not _G.BB.Local.Themes then
		return
	end 

	if hitPart == nil or hitPart.Parent == nil then 
		return
	end

	local color = self:GetThemeObject(player,"HitColor").Value

	if highlightEntireCharacter then
		for _,Part in pairs(hitPart.Parent:GetChildren()) do
			if Part:IsA("Part") and Part.Name~="HumanoidRootPart" then
				doOutline(Part,color)
			end
		end
	else
		doOutline(hitPart,color)
	end
end

function Aesthetics:RegisterClientEvents()
	local localPlayer = game:GetService("Players").LocalPlayer
	local hitRemote = _G.BB.Remotes.Hit

	hitRemote.OnClientEvent:connect(function(plr, hit, expl)
		if plr ~= localPlayer then
			self:CreateVisual(hit,plr,expl)
		end
	end)
end

return Aesthetics