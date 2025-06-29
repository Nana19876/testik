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

-- Компактное и полупрозрачное главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 320)
mainFrame.Position = UDim2.new(0, 60, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Parent = skeetGui

-- Боковая панель с шестерёнкой
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 60, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
sidebar.BackgroundTransparency = 0.25
sidebar.Parent = mainFrame

local miscIcon = Instance.new("TextButton")
miscIcon.Size = UDim2.new(1, 0, 0, 48)
miscIcon.Position = UDim2.new(0, 0, 0, 8)
miscIcon.BackgroundTransparency = 1
miscIcon.Text = "💫"
miscIcon.Font = Enum.Font.SourceSansBold
miscIcon.TextSize = 32
miscIcon.TextColor3 = Color3.fromRGB(160, 200, 160)
miscIcon.Parent = sidebar

-- Чекбокс и текст "avto farm"
local checkbox = Instance.new("TextButton")
checkbox.Size = UDim2.new(0, 18, 0, 18)
checkbox.Position = UDim2.new(0, 76, 0, 16)
checkbox.BackgroundColor3 = Color3.fromRGB(34, 34, 36)
checkbox.BackgroundTransparency = 0.1
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
boxIndicator.BackgroundTransparency = 0.25
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

-- Текст "скорость в высоту" над полосой
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0, 180, 0, 22)
sliderLabel.Position = UDim2.new(0, 76, 0, 42)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "скорость в высоту"
sliderLabel.Font = Enum.Font.SourceSansBold
sliderLabel.TextSize = 18
sliderLabel.TextColor3 = Color3.fromRGB(220,220,220)
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = mainFrame

-- Контейнер для полосы и значения
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 200, 0, 22)
sliderFrame.Position = UDim2.new(0, 76, 0, 68)
sliderFrame.BackgroundTransparency = 1
sliderFrame.Parent = mainFrame

-- Фоновая полоса (тёмно-серая)
local sliderBarBg = Instance.new("Frame")
sliderBarBg.Size = UDim2.new(1, 0, 0, 6)
sliderBarBg.Position = UDim2.new(0, 0, 0.5, -3)
sliderBarBg.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
sliderBarBg.BorderSizePixel = 0
sliderBarBg.Parent = sliderFrame

-- Заполненная (зелёная) часть
local sliderBarFill = Instance.new("Frame")
sliderBarFill.Size = UDim2.new(0, 0, 1, 0)
sliderBarFill.Position = UDim2.new(0, 0, 0, 0)
sliderBarFill.BackgroundColor3 = Color3.fromRGB(85, 210, 120)
sliderBarFill.BorderSizePixel = 0
sliderBarFill.Parent = sliderBarBg

-- Круглый "knob"
local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 14, 0, 14)
sliderKnob.Position = UDim2.new(0, -7, 0.5, -7)
sliderKnob.BackgroundColor3 = Color3.fromRGB(170, 255, 170)
sliderKnob.BorderSizePixel = 0
sliderKnob.BackgroundTransparency = 0.15
sliderKnob.Parent = sliderBarBg
sliderKnob.ZIndex = 2
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.ClipsDescendants = false
sliderKnob.Name = "SliderKnob"

-- Текст в центре полосы
local sliderValue = Instance.new("TextLabel")
sliderValue.Size = UDim2.new(0, 60, 1, 0)
sliderValue.Position = UDim2.new(0.5, -30, 0, -8)
sliderValue.BackgroundTransparency = 1
sliderValue.Text = "1 %"
sliderValue.Font = Enum.Font.SourceSansBold
sliderValue.TextSize = 15
sliderValue.TextColor3 = Color3.fromRGB(200,255,200)
sliderValue.TextStrokeTransparency = 0.35
sliderValue.TextXAlignment = Enum.TextXAlignment.Center
sliderValue.TextYAlignment = Enum.TextYAlignment.Center
sliderValue.Parent = sliderBarBg
sliderValue.ZIndex = 3

-- Логика ползунка (от 1 до 32)
local minValue, maxValue = 1, 32
local value = minValue
local dragging = false

local function updateSliderVisual(rel)
    local width = sliderBarBg.AbsoluteSize.X
    sliderBarFill.Size = UDim2.new(0, rel * width, 1, 0)
    sliderKnob.Position = UDim2.new(0, rel * width, 0.5, 0)
    value = math.floor(minValue + (maxValue - minValue) * rel + 0.5)
    sliderValue.Text = tostring(value) .. " %"
end

local function setSlider(posX)
    local barAbsPos = sliderBarBg.AbsolutePosition.X
    local barWidth = sliderBarBg.AbsoluteSize.X
    local rel = math.clamp((posX - barAbsPos) / barWidth, 0, 1)
    updateSliderVisual(rel)
    -- Теперь переменная "value" содержит актуальное значение (1-32)
end

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

sliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

sliderBarBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        setSlider(input.Position.X)
        dragging = true
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        setSlider(input.Position.X)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- начальное положение (1%)
updateSliderVisual(0)

-- Dropdown-меню, чуть ниже чекбокса
local dropdownWidth = 110
local dropdownHeight = 80
local dropdownX = 76
local dropdownY = 16 + 24

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, dropdownX, 0, dropdownY)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
dropdownFrame.BackgroundTransparency = 0.3
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
            child.BackgroundTransparency = (idx == selectedOption) and 0.18 or 0.3
            child.TextColor3 = (idx == selectedOption) and Color3.fromRGB(28, 28, 32) or Color3.fromRGB(220,220,220)
        end
    end
end

for i, option in ipairs(dropdownOptions) do
    local btn = Instance.new("TextButton")
    btn.Name = tostring(i)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, 22 + (i-1)*27)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
    btn.BackgroundTransparency = 0.3
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
