--!strict
local CustomPhysicsReplicator = {}

function CustomPhysicsReplicator.init(Context)
	
	local UpdateSet = Context.Settings.Security.Update
	local Security = require(Context.Modules.Security)

	local UpdateRemote = Context.Remotes:WaitForChild("UpdatePhysics")
	local Delete = Context.Remotes:WaitForChild("Delete")

	UpdateRemote.OnServerEvent:Connect(function(RemoteSender, PlayerProjectilePhysicsData)
		for _,InfoArray in pairs(PlayerProjectilePhysicsData) do
			--[[
				InfoArray = {
					PhysicsFolder,
					Projectile CFrame, (or distance)
					Projectile Velocity,
					Projectile Time
				}
			]]
			
			local ID_array = InfoArray[1]
			local PhysicsFolder = Security:GetPhysicsFolder(ID_array, RemoteSender, true)

			if not PhysicsFolder then
				return
			end
			
			local ProjectileType = PhysicsFolder.ProjectileType.Value
		
			local LastUpdateTick = PhysicsFolder.LastUpdateTick.Value
			
			local Now = tick()
			local DeltaTime = LastUpdateTick and Now - LastUpdateTick or 0
			PhysicsFolder.LastUpdateTick.Value = Now
			
			if not Security:ApproveUpdate(PhysicsFolder, InfoArray, UpdateSet, DeltaTime) then
				return
			end
			
			if ProjectileType == "Rocket" then
				
				--local clientTime = InfoArray[4]
				--local serverTime = Context.ServerTime.Value

				--if Context.Settings.Extrapolation.PingCompensation.Rocket and clientTime then
				--	PhysicsFolder.ServerTime.Value = serverTime
				--	PhysicsFolder.ClientTime.Value = clientTime
				--end

				PhysicsFolder.LatestDistance.Value = InfoArray[2]

				-- No reason to replicate if no change.
				--if Context.Settings.Rocket.Speed ~= Context.Settings.Rocket.InitialSpeed then
				--	LatestVelocity.Value = NewVelocity
				--end
				
			else
				PhysicsFolder.LatestPosition.Value = InfoArray[2]
				PhysicsFolder.LatestVelocity.Value = InfoArray[3]
				PhysicsFolder.LatestTime.Value = InfoArray[4]
			end
			
		end
	end)
	
	Delete.OnServerEvent:Connect(function(RemoteSender, array)
		local PhysicsFolder = Context.ProjectileFolder.Active[RemoteSender.Name]:FindFirstChild(array[1]..array[2])
		if not PhysicsFolder or not PhysicsFolder.Parent then
			--warn("No physics folder sent from "..RemoteSender.Name.."!", array)
			return
		end
		
		if RemoteSender == PhysicsFolder.creator.Value then
			task.wait(.1)
			--print("making inactive", PhysicsFolder)
			PhysicsFolder.Active.Value = false
		end
	end)
end

return CustomPhysicsReplicator