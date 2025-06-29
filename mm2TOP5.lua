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

-- Чекбокс и текст "avto farm"
local checkbox = Instance.new("TextButton")
checkbox.Size = UDim2.new(0, 18, 0, 18)
checkbox.Position = UDim2.new(0, 76, 0, 16)
checkbox.BackgroundColor3 = Color3.fromRGB(34, 34, 36)
checkbox.BorderSizePixel = 2
checkbox.BorderColor3 = Color3.fromRGB(220, 220, 220)
checkbox.Text = ""
checkbox.AutoButtonColor = true
checkbox.Parent = mainFrame

local isEnabled = false

local boxIndicator = Instance.new("Frame")
boxIndicator.Size = UDim2.new(1, -6, 1, -6)
boxIndicator.Position = UDim2.new(0, 3, 0, 3)
boxIndicator.BackgroundColor3 = Color3.fromRGB(85, 210, 120)
boxIndicator.BackgroundTransparency = 0.15
boxIndicator.Visible = false
boxIndicator.BorderSizePixel = 0
boxIndicator.Parent = checkbox

local label = Instance.new("TextButton")
label.Size = UDim2.new(0, 200, 0, 18)
label.Position = UDim2.new(0, 104, 0, 16)
label.BackgroundTransparency = 1
label.Text = "avto farm"
label.Font = Enum.Font.SourceSans
label.TextSize = 19
label.TextColor3 = Color3.fromRGB(220,220,220)
label.TextXAlignment = Enum.TextXAlignment.Left
label.AutoButtonColor = false
label.Parent = mainFrame

-- Dropdown меню появляется слева от чекбокса и текста
local dropdownWidth = 120
local dropdownHeight = 85

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, 76 - dropdownWidth - 10, 0, 16) -- слева от чекбокса
dropdownFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
dropdownFrame.BorderSizePixel = 2
dropdownFrame.BorderColor3 = Color3.fromRGB(64, 64, 70)
dropdownFrame.Visible = false
dropdownFrame.Parent = mainFrame

-- Надпись "metod" сверху
local metodLabel = Instance.new("TextLabel")
metodLabel.Size = UDim2.new(1, 0, 0, 22)
metodLabel.Position = UDim2.new(0, 0, 0, 0)
metodLabel.BackgroundTransparency = 1
metodLabel.Text = "metod"
metodLabel.Font = Enum.Font.SourceSansBold
metodLabel.TextSize = 18
metodLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
metodLabel.TextXAlignment = Enum.TextXAlignment.Left
metodLabel.Parent = dropdownFrame

-- Варианты дропдауна
local dropdownOptions = {"deloft", "random"}
local selectedOption = 1

local function updateDropdown()
    for i, child in ipairs(dropdownFrame:GetChildren()) do
        if child:IsA("TextButton") then
            local idx = tonumber(child.Name)
            child.BackgroundColor3 = (idx == selectedOption) and Color3.fromRGB(85, 210, 120) or Color3.fromRGB(36, 36, 38)
            child.TextColor3 = (idx == selectedOption) and Color3.fromRGB(28, 28, 32) or Color3.fromRGB(220,220,220)
        end
    end
end

for i, option in ipairs(dropdownOptions) do
    local btn = Instance.new("TextButton")
    btn.Name = tostring(i)
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, 22 + (i-1)*31)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
    btn.BorderSizePixel = 0
    btn.Text = option
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 19
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Parent = dropdownFrame
    btn.MouseButton1Click:Connect(function()
        selectedOption = i
        updateDropdown()
        dropdownFrame.Visible = false
        print("Выбран метод фарма: "..option)
    end)
end
updateDropdown()

-- Открытие/закрытие дропдауна по клику на чекбокс или текст
local function toggleDropdown()
    dropdownFrame.Visible = not dropdownFrame.Visible
end

checkbox.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    boxIndicator.Visible = isEnabled
    if isEnabled then
        dropdownFrame.Visible = true
    else
        dropdownFrame.Visible = false
    end
end)

label.MouseButton1Click:Connect(toggleDropdown)

-- Открытие/скрытие меню по клавише M
local UIS = game:GetService("UserInputService")
local open = true
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then
        open = not open
        skeetGui.Enabled = open
    end
end)
