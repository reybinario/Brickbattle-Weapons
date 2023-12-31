--!strict
local Kill = {}
local Debris = game:GetService("Debris")

local function findFiltered(name)
	return table.find(_G.BB.Settings.TeamsFiltered, name)
end

local callbacks = {}

local Tags = {
	Rocket = "rbxasset://Textures/Rocket.png";
	Bomb = "rbxasset://Textures/Bomb.png";
	Sword = "rbxasset://Textures/Sword128.png";
	PaintballGun = "rbxasset://Textures/PaintballIcon.png";
	Slingshot = "rbxasset://Textures/Slingshot.png";
	Superball = "rbxasset://Textures/Superball.png";
}

function Kill:CanDamage(player, hitHumanoid, SelfKill, DeadException)
	--print(2.7, hitHumanoid:GetFullName())
	if player:FindFirstChild("CanDamage") and player.CanDamage.Value == false then 
		return false
	end

	-- Must have an active character
	local character = player.Character
	if not character then
		return false;
	end

	-- Must have a humanoid
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return false
	end

	-- Hit player must have a character/char can't be nil
	local hitCharacter = hitHumanoid.Parent
	if not hitCharacter then
		return false
	end

	local otherPlr = game.Players:GetPlayerFromCharacter(hitCharacter)

	-- Already dead or godded
	if (hitHumanoid.Health <= 0) and not DeadException then
		return false
	end

	-- Player has a forcefield.
	if hitCharacter:FindFirstChildWhichIsA("ForceField",true) then
		return false
	end

	---- Manipulated humanoid, could be godded
	if not _G.BB.Settings.AllowHumanoidChanges then
		if (((humanoid.MaxHealth ~= 100) or (humanoid.WalkSpeed~=16) or humanoid.JumpPower~=50)) 
			or character:FindFirstChildWhichIsA("ForceField",true) then
			return false
		end
	end 

	-- Died, projectile is roaming around though
	if (humanoid.Health <= 0) and not _G.BB.Settings.WeaponsDamageAfterDeath then
		--print("Can't damage after death")
		return false
	end

	-- NPC
	-- The only reason this causes no weird behaviour is because all
	-- conditions after that are reserved for players (teams, etc).
	-- i.e. an afterlife check after this condition would yield unintended results.
	if not otherPlr then
		return true
	end

	-- Callback functions available to add after module loads
	for _, func in ipairs(callbacks) do
		if not func(player, otherPlr) then
			return false
		end
	end

	local t1 = player.TeamColor
	local t2 = otherPlr.TeamColor
	local t1Name
	local t2Name

	-- Firing player could be a spectator and shouldn't deal damage
	if not player.Neutral and player.Team ~= nil  then
		t1Name = player.Team.Name
		if _G.BB.Settings.SpectatorTeamActive 
			and t1Name == _G.BB.Settings.SpectatorTeamName then
			return false
		end
	end

	-- Hit player could be a spectator and shouldn't take damage
	if not otherPlr.Neutral and otherPlr.Team ~= nil then
		t2Name = otherPlr.Team.Name
		if _G.BB.Settings.SpectatorTeamActive 
			and t2Name == _G.BB.Settings.SpectatorTeamName then
			return false
		end
	end

	-- Self kill
	if player == otherPlr then
		return SelfKill
	end

	-- For FFA scenarios
	if player.Neutral or otherPlr.Neutral then
		return true 
	end

	-- Team kill
	if t1 == t2 then
		-- Ensure they are not on a "neutral team"
		if _G.BB.Settings.IgnoreCertainTeams then
			return findFiltered(t1Name) or findFiltered(t2Name)
		end

		return _G.BB.Settings.TeamKill
	end

	return true
end

function Kill:TagHumanoid(player, humanoid, obj, projectileType)
	local currentTag = humanoid:FindFirstChild("creator");
	local tag = obj and obj:FindFirstChild("creator")
	local Lifetime = _G.BB.Settings.TagLifetime
	
	if currentTag and currentTag:IsA("ObjectValue") then
		pcall(game.Destroy, currentTag)
	end
	
	local NewTag = tag and tag:Clone() or Instance.new("ObjectValue")
	NewTag.Name = "creator"
	NewTag.Value = player
	NewTag:SetAttribute("WeaponImageId", Tags[projectileType])
	--NewTag:SetAttribute("WeaponType", projectileType)
	
	local weapon = player:WaitForChild("Backpack"):FindFirstChild(projectileType) or player.Character:FindFirstChild(projectileType)
			
	local newWeaponTag = NewTag:FindFirstChild("Weapon") or Instance.new("ObjectValue")
	newWeaponTag.Name = "Weapon"
	newWeaponTag.Value = weapon
	newWeaponTag.Parent = NewTag
	
	local newWeaponStringTag = NewTag:FindFirstChild("WeaponType") or Instance.new("StringValue")
	newWeaponStringTag.Name = "WeaponType"
	newWeaponStringTag.Value = projectileType
	newWeaponStringTag.Parent = NewTag
	
	--[[
	creator.Value = Player object
	creator.Weapon.Value = Tool object
	creator.WeaponType.Value = String of weapon type
	]]
	
	NewTag.Parent = humanoid
	
	--print(
	--	"\n PATH:", NewTag:GetFullName(), 
	--	"\n VALUE:", NewTag.Value, 
	--	"\n WEAPON OBJECT:", NewTag.Weapon.Value, 
	--	"\n WEAPON STRING:", NewTag.WeaponType.Value
	--)
	
	Debris:AddItem(NewTag, Lifetime)
end

function Kill:AddDamageRule(func)
	local index = table.find(callbacks, func)
	if index then 
		warn("Function rule already exists.")
		return 
	end
	table.insert(callbacks, func)
end

function Kill:RemoveDamageRule(func)
	local index = table.find(callbacks, func)
	if index == nil then 
		warn("No damage rule found for input function.")
		return 
	end
	table.remove(callbacks, index)
end


return Kill