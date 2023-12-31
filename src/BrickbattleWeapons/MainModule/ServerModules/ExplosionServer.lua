--!strict
local Explosion = {}

function Explosion.init(Context)
	--[[
		When the explosion is from a rocket, "ExplPosData" is 
		the distance from the origin.
		
		Otherwise if explosion is from a bomb, "ExplPosData" is 
		the client's last seen cframe.
	]]
	
	local Security = require(Context.Modules.Security)
	
	Context.Remotes.Explosion.OnServerEvent:Connect(function(
		playerFired, 
		ID_array, 
		ExplPosData, 
		HitPart,
		Parts, 
		DirectHitCharacterData, 
		RadiusCharacterData,
		reportedServerTime
	)
		
		local shouldCancel = Context.Context.Settings.CancelHitIfAboveTimeDelay
		
		if reportedServerTime then
			local ping = math.floor((game.ReplicatedStorage.SERVER_TIME.Value - reportedServerTime) * 1000)
			if ping < 0 then
				warn("[EXPL]",playerFired,"potentially spoofed the ping value",ping,"ms")
				if shouldCancel then return end
			elseif ping > Context.Context.Settings.MaxReportedTimeDelay then
				warn("[EXPL]",playerFired,"ping too high",ping,"ms")
				if shouldCancel then return end
			end
		else
			warn("[EXPL] No ping found for player",playerFired)
			if shouldCancel then return end
		end

		local PhysicsFolder = Security:GetPhysicsFolder(ID_array, playerFired, true)
		if not PhysicsFolder then
			return
		end
		
		local ProjectileType = PhysicsFolder:FindFirstChild("ProjectileType")
		local Creator = PhysicsFolder:FindFirstChild("creator")	
		
		local ExplosionPosition = ExplPosData
		local RocketCFrame
		
		if ProjectileType.Value == "Rocket" then
			local Origin = PhysicsFolder.Origin.Value
			local ExplosionCFrame = (Origin) and (Origin + Origin.lookVector * ExplPosData)
			
			RocketCFrame = CFrame.new(ExplosionCFrame.Position - 2*ExplosionCFrame.LookVector, ExplosionCFrame.Position)
			ExplosionPosition = ExplosionCFrame.Position
		end
		
		local approvedHumanoids, approvedParts = Security:ApproveExplode(
			PhysicsFolder, 
			ExplPosData, 
			Parts, 
			HitPart, 
			DirectHitCharacterData, 
			RadiusCharacterData, 
			RocketCFrame
		)
		
		if not approvedHumanoids or not approvedParts then
			return
		end
		
		-- Rocket sends distance as its final update. Bomb send position.
		local value = ProjectileType.Value == "Bomb" and "LatestPosition" or "LatestDistance"
		PhysicsFolder[value].Value = ExplPosData
		
		-- Tell clients that this projectile has exploded		
		PhysicsFolder.Active.Value = false 	
		
		-- Blow up only the approved parts
		for _, Part in pairs(approvedParts) do
			local function BlowUpPart()
				self:BlowUpPart(PhysicsFolder, Part, ExplosionPosition)
			end
			task.spawn(BlowUpPart)
		end
		
		for Humanoid, CharPartArray in pairs(approvedHumanoids) do
			local function BlowUpPlayer()
				self:HandleHumanoid(PhysicsFolder, Humanoid, CharPartArray, ExplosionPosition)
			end
			task.spawn(BlowUpPlayer)
		end
				
		-- Remove explosion
		task.delay(2, function()
            PhysicsFolder:Destroy()
        end)
		
		if Context.Settings.Bomb.TeleportOnExplode 
			and not Context.Settings.Bomb.SelfDamage 
			and ProjectileType.Value == "Bomb" then
			Creator.Value.Character:MoveTo(ExplosionPosition)
		end
	end)
end

return Explosion