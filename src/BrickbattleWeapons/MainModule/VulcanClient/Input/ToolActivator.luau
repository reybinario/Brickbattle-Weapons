--!strict
local ToolActivator = {}

function ToolActivator.activateTool(tool: Tool, hit: BasePart, endPosition: Vector3)
    print("Activating", tool, hit, endPosition)
    local x = Instance.new("Part")
    x.Size = Vector3.new(1, 1, 1)
    x.Anchored = true
    x.Color = Color3.fromRGB(255, 0, 0)
    x.Position = endPosition
    x.Parent = workspace
end

return ToolActivator