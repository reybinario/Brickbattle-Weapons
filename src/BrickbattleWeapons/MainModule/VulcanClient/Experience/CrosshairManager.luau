--!strict
local Players = game:GetService("Players")
local Settings = _G.BB.Settings
local Player = Players.LocalPlayer
local Bindable = _G.BB.IconStateChanged
--[[
	Bindable params (fires with):
	1st param: "NoTools" = no tools equipped, 
			   "Equipped" = tool equipped, 
			   "Reloaded" = tool reloaded
	2nd: lastTime: the time() at which tool was last fired
	3rd: the reload time of the tool
	
	Notice how there is no firing when a tool is unequipped.
	This is because all cases are covered when any other tool
	is equipped or when a player unequips and no longer has a tool.
]]
local Mouse = Player:GetMouse()

return function(Tool)
	local Equipped = true
	local lastTime = 0
	
	local RELOAD_TIME = Settings[Tool.Name].ReloadTime
		
	local function ToggleCrosshair()
		if Equipped and Settings.NativeCrosshair then
			local NewIcon = (Tool.Enabled and "Regular" or "Reload") .. "Icon"
			Mouse.Icon = Settings.Targeting[NewIcon]
		end
	end
	
	local function isDead()
		local Character = Player.Character
		if (Character.Humanoid.Health<=0) or not Tool.Parent then
			Bindable:Fire("NoTools", lastTime, RELOAD_TIME)

			if Settings.NativeCrosshair then
				Mouse.Icon = Settings.Targeting.DefaultIcon
			end
			return true
		end;
		return false
	end
	
	Tool.Equipped:Connect(function()
		if not isDead() then
			Equipped = true
			Bindable:Fire("Equipped", lastTime, RELOAD_TIME)
			ToggleCrosshair()
		end
	end)
	
	Tool:GetPropertyChangedSignal("Enabled"):Connect(function()
		--local Character = Player.Character
		if not isDead() then
			local String = Tool.Enabled and "Reloaded" or "Fired"
			if String == "Fired" then
				lastTime = time()
			end
			Bindable:Fire("Reloaded", lastTime, RELOAD_TIME)

			ToggleCrosshair()
		end
	end)
	
	Tool.Unequipped:Connect(function()
		if not isDead() then
			Equipped = false
			if Settings.NativeCrosshair then
				Mouse.Icon = Settings.Targeting.DefaultIcon
			end
			task.wait()
			if (Player.Character ~= nil) 
				and (Player.Character:FindFirstChildWhichIsA("Tool")) then
				Bindable:Fire("NoTools", lastTime, RELOAD_TIME)
			end
		end
	end)
	
	Tool.AncestryChanged:Connect(function()
		local Character = Player.Character
		if (Character == nil) or (Character.Parent == nil)
			or (not (
				(Tool.Parent == Character) or 
					((Tool.Parent ~= nil) and (Tool.Parent:IsA("Backpack"))
					)
				)
			) then
			
			Equipped = false
			Bindable:Fire("NoTools", lastTime, RELOAD_TIME)

			if Settings.NativeCrosshair then
				Mouse.Icon = Settings.Targeting.DefaultIcon
			end
		end
	end)
end

