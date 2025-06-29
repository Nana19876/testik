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

-- Большое меню
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 900, 0, 550)
mainFrame.Position = UDim2.new(0, 60, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = skeetGui

-- Боковая панель с шестерёнкой
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

-- Чекбокс в стиле, как на скрине (тёмно-серый, без рамки, "стеклянный" эффект)
local checkbox = Instance.new("TextButton")
checkbox.Size = UDim2.new(0, 18, 0, 18)
checkbox.Position = UDim2.new(0, 76, 0, 16)
checkbox.BackgroundColor3 = Color3.fromRGB(34, 34, 36)
checkbox.BorderSizePixel = 0
checkbox.Text = ""
checkbox.AutoButtonColor = true
checkbox.Parent = mainFrame

-- Лёгкая внутренняя тень (визуальный эффект)
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.Position = UDim2.new(0, 0, 0, 0)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://3570695787" -- Круглая тень, подходит для мягких эффектов
shadow.ImageColor3 = Color3.fromRGB(0,0,0)
shadow.ImageTransparency = 0.85
shadow.Parent = checkbox

local isEnabled = false

-- Мягкий зелёный индикатор, появляется внутри при активации
local boxIndicator = Instance.new("Frame")
boxIndicator.Size = UDim2.new(1, -6, 1, -6)
boxIndicator.Position = UDim2.new(0, 3, 0, 3)
boxIndicator.BackgroundColor3 = Color3.fromRGB(85, 210, 120) -- мягкий пастельный зелёный
boxIndicator.BackgroundTransparency = 0.15
boxIndicator.Visible = false
boxIndicator.BorderSizePixel = 0
boxIndicator.Parent = checkbox

checkbox.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    boxIndicator.Visible = isEnabled
    -- Сюда можно добавить код активации фарма
end)

-- Текст справа от чекбокса
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 200, 0, 18)
label.Position = UDim2.new(0, 104, 0, 16)
label.BackgroundTransparency = 1
label.Text = "avto farm"
label.Font = Enum.Font.SourceSans
label.TextSize = 19
label.TextColor3 = Color3.fromRGB(220,220,220)
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = mainFrame

-- Открытие/скрытие меню по клавише M
local UIS = game:GetService("UserInputService")
local open = true
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then
        open = not open
        skeetGui.Enabled = open
    end
end)
