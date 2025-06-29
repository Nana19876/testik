-- LocalScript для StarterPlayerScripts или StarterGui

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("SkeetMenu") then
    playerGui.SkeetMenu:Destroy()
end

local skeetGui = Instance.new("ScreenGui")
skeetGui.Name = "SkeetMenu"
skeetGui.Parent = playerGui
skeetGui.ResetOnSpawn = false

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 100)
mainFrame.Position = UDim2.new(0, 100, 0, 140)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = skeetGui

-- Боковая панель с одной иконкой (Настройки)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 60, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
sidebar.Parent = mainFrame

local miscIcon = Instance.new("TextButton")
miscIcon.Size = UDim2.new(1, 0, 0, 48)
miscIcon.Position = UDim2.new(0, 0, 0, 8)
miscIcon.BackgroundTransparency = 1
miscIcon.Text = "⚙️"
miscIcon.Font = Enum.Font.SourceSansBold
miscIcon.TextSize = 32
miscIcon.TextColor3 = Color3.fromRGB(160, 200, 160)
miscIcon.Parent = sidebar

-- Маленький чекбокс с синей рамкой (outline), без текста
local checkBoxContainer = Instance.new("Frame")
checkBoxContainer.Size = UDim2.new(0, 36, 0, 36)
checkBoxContainer.Position = UDim2.new(0, 100, 0, 24)
checkBoxContainer.BackgroundTransparency = 1
checkBoxContainer.Parent = mainFrame

local checkbox = Instance.new("TextButton")
checkbox.Size = UDim2.new(0, 20, 0, 20)
checkbox.Position = UDim2.new(0.5, -10, 0.5, -10)
checkbox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
checkbox.BorderColor3 = Color3.fromRGB(38, 95, 255) -- синяя рамка
checkbox.BorderSizePixel = 2
checkbox.Text = ""
checkbox.AutoButtonColor = true
checkbox.Parent = checkBoxContainer

local isEnabled = false

local boxIndicator = Instance.new("Frame")
boxIndicator.Size = UDim2.new(1, -6, 1, -6)
boxIndicator.Position = UDim2.new(0, 3, 0, 3)
boxIndicator.BackgroundColor3 = Color3.fromRGB(36, 200, 72) -- bright green (как у Skeet)
boxIndicator.Visible = false
boxIndicator.BorderSizePixel = 0
boxIndicator.Parent = checkbox

checkbox.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    boxIndicator.Visible = isEnabled
    -- Здесь твоя логика автофарма, если надо:
    -- if isEnabled then startAutoFarm() else stopAutoFarm() end
end)

-- Открытие/скрытие меню по клавише M
local UIS = game:GetService("UserInputService")
local open = true
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then
        open = not open
        skeetGui.Enabled = open
    end
end)
