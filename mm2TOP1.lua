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
mainFrame.Size = UDim2.new(0, 400, 0, 180)
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

-- Только кнопка автофарма, без текста об авторе
local autoFarmActive = false
local autoFarmButton = Instance.new("TextButton")
autoFarmButton.Size = UDim2.new(1, -84, 0, 52)
autoFarmButton.Position = UDim2.new(0, 76, 0.5, -26)
autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
autoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFarmButton.Font = Enum.Font.SourceSansBold
autoFarmButton.TextSize = 22
autoFarmButton.Text = "Запустить автофарм"
autoFarmButton.AutoButtonColor = false
autoFarmButton.Parent = mainFrame

-- Пример логики автофарма
local autoFarmThread = nil
local autoFarmStop = false

local function startAutoFarm()
    print("Автофарм ЗАПУЩЕН")
    autoFarmStop = false
    autoFarmThread = task.spawn(function()
        while not autoFarmStop do
            -- Здесь твой автофарм-код (пример):
            print("Фармим монетки/ресурсы/что нужно...")
            task.wait(1)
        end
        print("Автофарм остановлен!")
    end)
end

local function stopAutoFarm()
    autoFarmStop = true
end

autoFarmButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        autoFarmButton.Text = "Остановить автофарм"
        autoFarmButton.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
        startAutoFarm()
    else
        autoFarmButton.Text = "Запустить автофарм"
        autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
        stopAutoFarm()
    end
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
