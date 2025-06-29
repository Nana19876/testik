local TweenService = game:GetService("TweenService")
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
mainFrame.Size = UDim2.new(0, 500, 0, 440)
mainFrame.Position = UDim2.new(0, 60, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Parent = skeetGui

-- Сайдбар
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 60, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
sidebar.BackgroundTransparency = 0.25
sidebar.Parent = mainFrame

local miscIcon = Instance.new("TextButton")
miscIcon.Size = UDim2.new(1, 0, 0, 48)
miscIcon.Position = UDim2.new(0, 0, 0, 8)
miscIcon.BackgroundTransparency = 1
miscIcon.Text = "⭐"
miscIcon.Font = Enum.Font.SourceSansBold
miscIcon.TextSize = 32
miscIcon.TextColor3 = Color3.fromRGB(240, 200, 90)
miscIcon.Parent = sidebar

-- avto farm чекбокс + текст
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

-- Dropdown меню ("метод")
local dropdownWidth = 120
local dropdownHeight = 85
local dropdownX = 76
local dropdownY = 40

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, dropdownX, 0, dropdownY)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
dropdownFrame.BackgroundTransparency = 0.3
dropdownFrame.BorderSizePixel = 2
dropdownFrame.BorderColor3 = Color3.fromRGB(64, 64, 70)
dropdownFrame.Visible = false
dropdownFrame.Parent = mainFrame

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
        moveSliders(false)
        print("Выбран метод фарма: "..option)
    end)
end
updateDropdown()

-- === СЛАЙДЕРЫ ===
-- Y-позиции для трёх слайдеров
local SLIDER1_LABEL_Y_UP = 42
local SLIDER1_BG_Y_UP    = 66
local SLIDER1_LABEL_Y_DOWN = 106
local SLIDER1_BG_Y_DOWN   = 130

local SLIDER2_LABEL_Y_UP = 104
local SLIDER2_BG_Y_UP    = 128
local SLIDER2_LABEL_Y_DOWN = 168
local SLIDER2_BG_Y_DOWN   = 192

local SLIDER3_LABEL_Y_UP = 166
local SLIDER3_BG_Y_UP    = 190
local SLIDER3_LABEL_Y_DOWN = 230
local SLIDER3_BG_Y_DOWN   = 254

-- Первый слайдер "скорость в высоту"
local sliderLabel1 = Instance.new("TextLabel")
sliderLabel1.Size = UDim2.new(0, 180, 0, 22)
sliderLabel1.Position = UDim2.new(0, 76, 0, SLIDER1_LABEL_Y_UP)
sliderLabel1.BackgroundTransparency = 1
sliderLabel1.Text = "скорость в высоту"
sliderLabel1.Font = Enum.Font.SourceSansBold
sliderLabel1.TextSize = 18
sliderLabel1.TextColor3 = Color3.fromRGB(220,220,220)
sliderLabel1.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel1.Parent = mainFrame

local sliderBackground1 = Instance.new("Frame")
sliderBackground1.Size = UDim2.new(0, 210, 0, 32)
sliderBackground1.Position = UDim2.new(0, 72, 0, SLIDER1_BG_Y_UP)
sliderBackground1.BackgroundColor3 = Color3.fromRGB(19, 20, 22)
sliderBackground1.BackgroundTransparency = 0.18
sliderBackground1.BorderSizePixel = 0
sliderBackground1.Parent = mainFrame

local sliderFrame1 = Instance.new("Frame")
sliderFrame1.Size = UDim2.new(1, 0, 1, 0)
sliderFrame1.Position = UDim2.new(0, 0, 0, 0)
sliderFrame1.BackgroundTransparency = 1
sliderFrame1.Parent = sliderBackground1

local sliderBarBg1 = Instance.new("Frame")
sliderBarBg1.Size = UDim2.new(0, 180, 0, 6)
sliderBarBg1.Position = UDim2.new(0, 15, 0.5, -3)
sliderBarBg1.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
sliderBarBg1.BorderSizePixel = 0
sliderBarBg1.Parent = sliderFrame1

local sliderBarFill1 = Instance.new("Frame")
sliderBarFill1.Size = UDim2.new(0, 0, 1, 0)
sliderBarFill1.Position = UDim2.new(0, 0, 0, 0)
sliderBarFill1.BackgroundColor3 = Color3.fromRGB(85, 210, 120)
sliderBarFill1.BorderSizePixel = 0
sliderBarFill1.Parent = sliderBarBg1

local sliderKnob1 = Instance.new("Frame")
sliderKnob1.Size = UDim2.new(0, 14, 0, 14)
sliderKnob1.Position = UDim2.new(0, -7, 0.5, -7)
sliderKnob1.BackgroundColor3 = Color3.fromRGB(170, 255, 170)
sliderKnob1.BorderSizePixel = 0
sliderKnob1.BackgroundTransparency = 0.15
sliderKnob1.Parent = sliderBarBg1
sliderKnob1.ZIndex = 2
sliderKnob1.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob1.ClipsDescendants = false
sliderKnob1.Name = "SliderKnob1"

local sliderValue1 = Instance.new("TextLabel")
sliderValue1.Size = UDim2.new(0, 60, 1, 0)
sliderValue1.Position = UDim2.new(0.5, -30, 0, -8)
sliderValue1.BackgroundTransparency = 1
sliderValue1.Text = "1 %"
sliderValue1.Font = Enum.Font.SourceSansBold
sliderValue1.TextSize = 15
sliderValue1.TextColor3 = Color3.fromRGB(200,255,200)
sliderValue1.TextStrokeTransparency = 0.35
sliderValue1.TextXAlignment = Enum.TextXAlignment.Center
sliderValue1.TextYAlignment = Enum.TextYAlignment.Center
sliderValue1.Parent = sliderBarBg1
sliderValue1.ZIndex = 3

-- Логика первого слайдера
local minValue1, maxValue1 = 1, 32
local value1 = minValue1
local dragging1 = false

local function updateSliderVisual1(rel)
    local width = sliderBarBg1.AbsoluteSize.X
    sliderBarFill1.Size = UDim2.new(0, rel * width, 1, 0)
    sliderKnob1.Position = UDim2.new(0, rel * width, 0.5, 0)
    value1 = math.floor(minValue1 + (maxValue1 - minValue1) * rel + 0.5)
    sliderValue1.Text = tostring(value1) .. " %"
end

local function setSlider1(posX)
    local barAbsPos = sliderBarBg1.AbsolutePosition.X
    local barWidth = sliderBarBg1.AbsoluteSize.X
    local rel = math.clamp((posX - barAbsPos) / barWidth, 0, 1)
    updateSliderVisual1(rel)
end

sliderKnob1.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging1 = true end
end)
sliderKnob1.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging1 = false end
end)
sliderBarBg1.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        setSlider1(input.Position.X) dragging1 = true
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging1 and input.UserInputType == Enum.UserInputType.MouseMovement then setSlider1(input.Position.X) end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging1 = false end
end)

updateSliderVisual1(0)

-- Второй слайдер "скорость в низ"
local sliderLabel2 = Instance.new("TextLabel")
sliderLabel2.Size = UDim2.new(0, 180, 0, 22)
sliderLabel2.Position = UDim2.new(0, 76, 0, SLIDER2_LABEL_Y_UP)
sliderLabel2.BackgroundTransparency = 1
sliderLabel2.Text = "скорость в низ"
sliderLabel2.Font = Enum.Font.SourceSansBold
sliderLabel2.TextSize = 18
sliderLabel2.TextColor3 = Color3.fromRGB(220,220,220)
sliderLabel2.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel2.Parent = mainFrame

local sliderBackground2 = Instance.new("Frame")
sliderBackground2.Size = UDim2.new(0, 210, 0, 32)
sliderBackground2.Position = UDim2.new(0, 72, 0, SLIDER2_BG_Y_UP)
sliderBackground2.BackgroundColor3 = Color3.fromRGB(19, 20, 22)
sliderBackground2.BackgroundTransparency = 0.18
sliderBackground2.BorderSizePixel = 0
sliderBackground2.Parent = mainFrame

local sliderFrame2 = Instance.new("Frame")
sliderFrame2.Size = UDim2.new(1, 0, 1, 0)
sliderFrame2.Position = UDim2.new(0, 0, 0, 0)
sliderFrame2.BackgroundTransparency = 1
sliderFrame2.Parent = sliderBackground2

local sliderBarBg2 = Instance.new("Frame")
sliderBarBg2.Size = UDim2.new(0, 180, 0, 6)
sliderBarBg2.Position = UDim2.new(0, 15, 0.5, -3)
sliderBarBg2.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
sliderBarBg2.BorderSizePixel = 0
sliderBarBg2.Parent = sliderFrame2

local sliderBarFill2 = Instance.new("Frame")
sliderBarFill2.Size = UDim2.new(0, 0, 1, 0)
sliderBarFill2.Position = UDim2.new(0, 0, 0, 0)
sliderBarFill2.BackgroundColor3 = Color3.fromRGB(120, 210, 255)
sliderBarFill2.BorderSizePixel = 0
sliderBarFill2.Parent = sliderBarBg2

local sliderKnob2 = Instance.new("Frame")
sliderKnob2.Size = UDim2.new(0, 14, 0, 14)
sliderKnob2.Position = UDim2.new(0, -7, 0.5, -7)
sliderKnob2.BackgroundColor3 = Color3.fromRGB(180, 230, 255)
sliderKnob2.BorderSizePixel = 0
sliderKnob2.BackgroundTransparency = 0.15
sliderKnob2.Parent = sliderBarBg2
sliderKnob2.ZIndex = 2
sliderKnob2.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob2.ClipsDescendants = false
sliderKnob2.Name = "SliderKnob2"

local sliderValue2 = Instance.new("TextLabel")
sliderValue2.Size = UDim2.new(0, 60, 1, 0)
sliderValue2.Position = UDim2.new(0.5, -30, 0, -8)
sliderValue2.BackgroundTransparency = 1
sliderValue2.Text = "1 %"
sliderValue2.Font = Enum.Font.SourceSansBold
sliderValue2.TextSize = 15
sliderValue2.TextColor3 = Color3.fromRGB(200,255,255)
sliderValue2.TextStrokeTransparency = 0.35
sliderValue2.TextXAlignment = Enum.TextXAlignment.Center
sliderValue2.TextYAlignment = Enum.TextYAlignment.Center
sliderValue2.Parent = sliderBarBg2
sliderValue2.ZIndex = 3

-- Логика второго слайдера
local minValue2, maxValue2 = 1, 32
local value2 = minValue2
local dragging2 = false

local function updateSliderVisual2(rel)
    local width = sliderBarBg2.AbsoluteSize.X
    sliderBarFill2.Size = UDim2.new(0, rel * width, 1, 0)
    sliderKnob2.Position = UDim2.new(0, rel * width, 0.5, 0)
    value2 = math.floor(minValue2 + (maxValue2 - minValue2) * rel + 0.5)
    sliderValue2.Text = tostring(value2) .. " %"
end

local function setSlider2(posX)
    local barAbsPos = sliderBarBg2.AbsolutePosition.X
    local barWidth = sliderBarBg2.AbsoluteSize.X
    local rel = math.clamp((posX - barAbsPos) / barWidth, 0, 1)
    updateSliderVisual2(rel)
end

sliderKnob2.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging2 = true end
end)
sliderKnob2.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging2 = false end
end)
sliderBarBg2.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton
