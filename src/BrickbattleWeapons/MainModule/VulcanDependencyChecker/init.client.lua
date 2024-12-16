--!strict

local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local LocalPlayer = game.Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts

if not PlayerScripts:FindFirstChild("VulcanClient") then
	warn("Player spawned without brick battle toolset core objects.")
	StarterPlayerScripts:FindFirstChild("VulcanClient"):Clone().Parent = PlayerScripts
end
task.wait()
script:Destroy()