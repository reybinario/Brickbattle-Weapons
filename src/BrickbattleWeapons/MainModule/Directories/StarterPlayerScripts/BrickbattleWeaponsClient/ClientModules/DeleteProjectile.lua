--!strict
return function (Projectile, DelayTime)
	local DeleteRemote = _G.BB.Remotes:WaitForChild("Delete")

	if not Projectile.Parent then
		--warn("Projectile already deleted:", Projectile)
		return
	end
	
	local ID_array = {Projectile.ProjectileType.Value, Projectile.Count.Value}
	
	local function delete()
		if Projectile.Parent ~= nil and Projectile.Active.Value then
			--print("Sending deletion info for",Projectile,PhysicsFolder.ProjectileType.Value)
			if Projectile:FindFirstChild("Active") then
				Projectile.Active.Value = false
			end
			DeleteRemote:FireServer(ID_array)
			game:GetService("Debris"):AddItem(Projectile, 0)
		end
	end
	
	if DelayTime > 0 then
		task.delay(DelayTime, delete)
	else
		delete()
	end
end

