--!strict
local Sword = {}

local players = game:GetService("Players")
local tool = script.Parent.Parent

local state = "Up"
local canDamage = true

function Sword:Damage(hitHumanoid)
	-- Find Character and Player
	local hitCharacter = hitHumanoid.Parent;
	local hitPlayer = players:GetPlayerFromCharacter(hitCharacter);
	
	if hitCharacter ~= nil then
		-- Find torsos
		local hitTorso = hitCharacter:FindFirstChild("HumanoidRootPart");
		local localTorso = self.Character:FindFirstChild("HumanoidRootPart");

		if hitTorso and localTorso then
			-- Make sure user is within reasonable distance.
			local mag = (hitTorso.Position - localTorso.Position).Magnitude;
			
			if mag < self.MaxKillDistance then
				-- if they're a player, do tk check
				if self.Kill:CanDamage(self.Player,hitHumanoid) 
					and (self.SwordModule:CheckJoint(self.Character, self.handle)) then
					
					-- Tag player
					self.Kill:TagHumanoid(self.Player,hitHumanoid, self.handle, "Sword");

					-- Decide damage
					local Damage = self.Damages[state]
					
					--print(self.Player,"is damaging",hitCharacter)
					
					-- Deal damage
					hitHumanoid:TakeDamage(Damage)
				end				
			end
		end
	end
end

function Sword:Init(Settings,Modules,Buffers,Player,Character)
	self.Player = Player
	self.Character = Character
	self.Humanoid = Character:WaitForChild("Humanoid")
	
	self.MaxKillDistance = Settings.Security.Hit.MaxSwordKillDistance
	self.Ties = Settings.WeaponDamageAfterDeath
	self.Damages = {
		Out = Settings.Sword.LungeDamage,
		Down = Settings.Sword.SlashDamage,
		Up  = Settings.Sword.IdleDamage
	} 
	
	self.Kill = require(Modules:WaitForChild("Kill"))
	
	self.handle = tool:WaitForChild("Handle")
	self.SwordModule = require(tool:WaitForChild("SwordModule"))

	local Damage = tool:WaitForChild("Damage")

	local equipSound = self.handle:WaitForChild("Equip")
	local slashSound = self.handle:WaitForChild("Slash")
	local lungeSound = self.handle:WaitForChild("Lunge")

	local gripEvent = tool:WaitForChild("Grip")
	
	local PSPV = require(Modules.Security:WaitForChild("PSPV"))
	local Security = require(Modules:WaitForChild("Security"))
	local Aesthetics = require(Modules.Aesthetics)
	
	Aesthetics:HandleSword(Player, self.handle, true)
	
	local Primary
	Primary = Damage.OnServerEvent:Connect(function(playerFired,hit,CharacterData,LocalCFrames, reportedServerTime)
		
		if playerFired~=Player then
			return
		end

		local shouldCancel = _G.BB.Settings.CancelHitIfAboveTimeDelay

		if reportedServerTime then
			local ping = math.floor((game.ReplicatedStorage.SERVER_TIME.Value - reportedServerTime) * 1000)
			if ping < 0 then
				warn("[SWORD]",playerFired,"potentially spoofed the ping value",ping,"ms")
				if shouldCancel then return end
			elseif ping > _G.BB.Settings.MaxReportedTimeDelay then
				warn("[SWORD]",playerFired,"ping too high",ping,"ms")
				if shouldCancel then return end
			end
		else
			warn("[SWORD] No ping found for player",playerFired)
			if shouldCancel then return end
		end
		
		if hit and hit.Parent and hit.Parent:IsDescendantOf(workspace)  then
			
			if hit.Name == "HumanoidRootPart" 
				or Character:FindFirstChildWhichIsA("ForceField") then 
				return 
			end
			
			local hitHumanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid");
			local HitPlayer = players:GetPlayerFromCharacter(hit.Parent)
			
			if hitHumanoid then
				
				local Alive = self.Character.Humanoid.Health>0
				local TrueHit = not HitPlayer or not Settings.Security.PSPV or not Settings.Security.Master
				
				if Settings.Security.Master then
					local SwordCFrames = {LocalCFrames[1][2].Sword,LocalCFrames[2][2].Sword,LocalCFrames[3][2].Sword}
					local size = self.handle.Size -- Vector3.new(.2,.2,.2)
					if HitPlayer then
						
						TrueHit = PSPV:Verify(
							CharacterData, 
							SwordCFrames, -- hmmm...
							size, 
							Enum.PartType.Block, 
							HitPlayer.Name,
							nil,
							true
						)
						
						if not TrueHit then
							warn("PSPV failed for sword hit, hit plr:",
								HitPlayer,"Sword owner:",
								Player,
								"Hit:",hit.Name)
							
							canDamage = false
							
							Primary:Disconnect()
							
							return
						end

						for _, sCF in pairs(SwordCFrames) do
							
							local CurrentPosition = Vector2.new(self.handle.Position.X, self.handle.Position.Z)
							
							local SentPosition = Vector2.new(sCF.Position.X, sCF.Position.Z)
							local Mag = (SentPosition-CurrentPosition).Magnitude
							
							if Mag > 9 then
								TrueHit = false
								warn(
									"High 2D distance for sword hit, hit plr:", HitPlayer,
									"Sword owner:", Player,
									"Hit:", hit.Name,
									"Mag:", Mag
								)
							end
						end
					end
					
					Security:ApproveHandlePositions(Player, LocalCFrames)
					Security:ApproveFuturePositions(Player, LocalCFrames)
				end
				
				if TrueHit and canDamage then
					self:Damage(hitHumanoid);
				end
			end
		end
	end)
	
	gripEvent.OnServerEvent:Connect(function(plr, gripType)
		if Player == plr then
			
			-- replicate state
			state = gripType
			
			if gripType == "Out" then
				lungeSound:Play()
				self.SwordModule:PositionLunge(tool)
				
			elseif gripType == "Down" then
				slashSound:Play()
				
			elseif gripType == "Up" then
				self.SwordModule:PositionIdle(tool)
			end
		end
	end)
	
	-- sword equip sound server:
	tool.Equipped:Connect(function()
		equipSound:Play()	
	end)
	
	tool.Enabled = true
end

return Sword