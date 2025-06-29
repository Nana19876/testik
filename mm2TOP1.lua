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
mainFrame.Size = UDim2.new(0, 400, 0, 260)
mainFrame.Position = UDim2.new(0, 100, 0, 120)
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

-- Окно "Об авторе"
local aboutPage = Instance.new("Frame")
aboutPage.Size = UDim2.new(1, -68, 1, -20)
aboutPage.Position = UDim2.new(0, 68, 0, 10)
aboutPage.BackgroundTransparency = 1
aboutPage.Parent = mainFrame

-- Заголовок "Об авторе"
local sectionTitle = Instance.new("TextLabel")
sectionTitle.Size = UDim2.new(1, 0, 0, 38)
sectionTitle.Position = UDim2.new(0, 0, 0, 0)
sectionTitle.BackgroundTransparency = 1
sectionTitle.Text = "Об авторе"
sectionTitle.Font = Enum.Font.SourceSansBold
sectionTitle.TextSize = 32
sectionTitle.TextColor3 = Color3.fromRGB(170, 255, 170)
sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
sectionTitle.Parent = aboutPage

-- Основной текст
local aboutText = Instance.new("TextLabel")
aboutText.Size = UDim2.new(1, -16, 0, 110)
aboutText.Position = UDim2.new(0, 8, 0, 54)
aboutText.BackgroundTransparency = 1
aboutText.TextWrapped = true
aboutText.TextYAlignment = Enum.TextYAlignment.Top
aboutText.Font = Enum.Font.SourceSans
aboutText.TextSize = 22
aboutText.TextColor3 = Color3.fromRGB(220,220,220)
aboutText.Text = [[
Пример GUI для Roblox Studio.
creator: 1.

aboutText.Text = [[
Пример GUI для Roblox Studio.
creator: 1.
]]

-- (опционально) картинка или иконка
-- local logo = Instance.new("ImageLabel")
-- logo.Size = UDim2.new(0,40,0,40)
-- logo.Position = UDim2.new(1,-50,0,8)
-- logo.BackgroundTransparency = 1
-- logo.Image = "rbxassetid://ВАШ_ИД"
-- logo.Parent = aboutPage

-- Открытие/скрытие меню по клавише M
local UIS = game:GetService("UserInputService")
local open = true
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then
        open = not open
        skeetGui.Enabled = open
    end
end)

