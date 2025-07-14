loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local AimbotEnabled = false
local Highlights = {}
local holding = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TabButtons = Instance.new("Frame", MainFrame)
TabButtons.Size = UDim2.new(1, 0, 0, 30)
TabButtons.BackgroundTransparency = 1

local VisualBtn = Instance.new("TextButton", TabButtons)
VisualBtn.Size = UDim2.new(0.5, 0, 1, 0)
VisualBtn.Text = "Visual"
VisualBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
VisualBtn.BorderSizePixel = 0

local AimbotBtn = Instance.new("TextButton", TabButtons)
AimbotBtn.Size = UDim2.new(0.5, 0, 1, 0)
AimbotBtn.Position = UDim2.new(0.5, 0, 0, 0)
AimbotBtn.Text = "Aimbot"
AimbotBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimbotBtn.BorderSizePixel = 0

local VisualFrame = Instance.new("Frame", MainFrame)
VisualFrame.Size = UDim2.new(1, 0, 1, -30)
VisualFrame.Position = UDim2.new(0, 0, 0, 30)
VisualFrame.BackgroundTransparency = 1
VisualFrame.Visible = true

local AimbotFrame = Instance.new("Frame", MainFrame)
AimbotFrame.Size = UDim2.new(1, 0, 1, -30)
AimbotFrame.Position = UDim2.new(0, 0, 0, 30)
AimbotFrame.BackgroundTransparency = 1
AimbotFrame.Visible = false

local ESPToggle = Instance.new("TextButton", VisualFrame)
ESPToggle.Size = UDim2.new(1, -20, 0, 40)
ESPToggle.Position = UDim2.new(0, 10, 0, 20)
ESPToggle.Text = "ESP: OFF"
ESPToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ESPToggle.BorderSizePixel = 0

local AimbotToggle = Instance.new("TextButton", AimbotFrame)
AimbotToggle.Size = UDim2.new(1, -20, 0, 40)
AimbotToggle.Position = UDim2.new(0, 10, 0, 20)
AimbotToggle.Text = "Aimbot: OFF"
AimbotToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
AimbotToggle.BorderSizePixel = 0

-- Tab switching
VisualBtn.MouseButton1Click:Connect(function()
    VisualFrame.Visible = true
    AimbotFrame.Visible = false
end)
AimbotBtn.MouseButton1Click:Connect(function()
    VisualFrame.Visible = false
    AimbotFrame.Visible = true
end)

-- ESP functions (enemy-only)
local function addHighlight(player)
    if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and not Highlights[player] then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.FillTransparency = 0.2
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Adornee = player.Character
        highlight.Parent = player.Character
        Highlights[player] = highlight
    end
end

local function removeHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function enableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            addHighlight(player)
        end
    end
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            if ESPEnabled and player.Team ~= LocalPlayer.Team then
                addHighlight(player)
            end
        end)
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        player.CharacterAdded:Connect(function()
            if ESPEnabled and player.Team ~= LocalPlayer.Team then
                addHighlight(player)
            end
        end)
    end
end

local function disableESP()
    for player, _ in pairs(Highlights) do
        removeHighlight(player)
    end
end

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    if ESPEnabled then
        enableESP()
    else
        disableESP()
    end
end)

-- Aimbot functions (enemy-only)
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and holding then
        local targetPlayer = getClosestEnemy()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPlayer.Character.Head.Position)
        end
    end
end)

AimbotToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotToggle.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)
]])()
