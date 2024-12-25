--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera: Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local VulcanClient = script.Parent.Parent
local ClientConfig = require(VulcanClient.Management.ClientConfig)
local ConfigSchema = require(VulcanClient.Management.ConfigSchema)
local ToolActivator = require(script.Parent.ToolActivator)
local TargetingManager = require(script.Parent.TargetingManager)

local InputGateway = {}

local clientConfig: ConfigSchema.Config = ClientConfig.get()
local lastUsed: {[string]: number} = {}

local toolCache: {[Tool]: string} = {}

local VULCAN_ATTRIBUTE_NAME = "VulcanName"

local function hasTool(): boolean
    if LocalPlayer.Character then
        local tool: Tool? = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if tool then
            if toolCache[tool] then return true end
            local vulcanName = tool:GetAttribute(VULCAN_ATTRIBUTE_NAME)
            if vulcanName and type(vulcanName) == "string" then
                toolCache[tool] = vulcanName
            end
            return tool:GetAttribute(VULCAN_ATTRIBUTE_NAME) ~= nil
        end
    end
    return false
end

local function isReady(tool: Tool): boolean
    local vulcanName: string = toolCache[tool]
    local now = time()
    if lastUsed[vulcanName] == nil then
        lastUsed[vulcanName] = now
        return true
    else
        if (now - lastUsed[vulcanName]) >= clientConfig[vulcanName].ReloadTime then
            lastUsed[vulcanName] = now
            return true
        else
            print(tool, "reloading")
        end
        return false
    end
end

local function passesActivationRules(tool: Tool, targetRay: Ray)
    return true
end

function InputGateway.processInput(targetRay: Ray)
    local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    if isReady(tool) and passesActivationRules(tool, targetRay) then
        local endPosition: Vector3, hit: BasePart?  = TargetingManager.get3DPosition(targetRay)
        ToolActivator.activateTool(tool, hit, endPosition)
    end
end

function InputGateway.processTouch(position: Vector2, processedByUI: boolean)
    if processedByUI then return end
    if not hasTool() then return end
    local targetRay: Ray = Camera:ViewportPointToRay(position.X, position.Y)
    InputGateway.processInput(targetRay)
end

function InputGateway.processClick(input: InputObject, gameProcessedEvent: boolean)
    if gameProcessedEvent then return end
    if not (input.UserInputType == Enum.UserInputType.MouseButton1) then return end
    if not hasTool() then return end

    local targetRay: Ray = Camera:ScreenPointToRay(input.Position.X, input.Position.Y)
    InputGateway.processInput(targetRay)
end

function InputGateway.listenForInput()
    if UserInputService.TouchEnabled then
        UserInputService.TouchTapInWorld:Connect(InputGateway.processTouch)
    else
        UserInputService.InputBegan:Connect(InputGateway.processClick)
    end
end

return InputGateway