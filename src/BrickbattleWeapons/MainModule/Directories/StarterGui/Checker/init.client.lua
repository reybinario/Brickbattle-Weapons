--!strict
local Player = game.Players.LocalPlayer
local playerScripts = Player.PlayerScripts

local SPS = game:GetService("StarterPlayer") .StarterPlayerScripts
if not playerScripts:FindFirstChild("ToolObjects") then
	--warn("Player spawned without brick battle toolset core objects.")
	SPS:FindFirstChild("ToolObjects"):Clone().Parent = playerScripts
end
--if not Player:FindFirstChild("Buffers") then
--	StarterPlayer:WaitForChild("Buffers"):Clone().Parent = Player
--end
task.wait(1)
script:Destroy()