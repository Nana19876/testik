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
mainFrame.Size = UDim2.new(0, 530, 0, 360)
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

-- Dropdown меню ("метод") — появляется ниже строки
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
        moveSlider(false)
        print("Выбран метод фарма: "..option)
    end)
end
updateDropdown()

-- === ВКЛАДКИ ===

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(0, 475, 0, 34)
tabFrame.Position = UDim2.new(0, 76, 0, 6)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabNames = {
    {"скорость в высоту", "up"},
    {"скорость в низ", "down"},
    {"скорость вправо", "right"},
    {"скорость влево", "left"},
}
local tabButtons = {}
local tabStates = {}
local currentTab = "up"

for i, tab in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 32)
    btn.Position = UDim2.new(0, (i-1)*120, 0, 0)
    btn.BackgroundColor3 = (i==1) and Color3.fromRGB(38, 95, 45) or Color3.fromRGB(28, 28, 32)
    btn.BackgroundTransparency = (i==1) and 0.09 or 0.22
    btn.BorderSizePixel = 0
    btn.Text = tab[1]
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.TextColor3 = (i==1) and Color3.fromRGB(210,255,210) or Color3.fromRGB(230,230,230)
    btn.Parent = tabFrame
    tabButtons[tab[2]] = btn
end

local function selectTab(tab)
    for i, t in ipairs(tabNames) do
        if t[2] == tab then
            tabButtons[tab].BackgroundColor3 = Color3.fromRGB(38, 95, 45)
            tabButtons[tab].TextColor3 = Color3.fromRGB(210,255,210)
            tabButtons[tab].BackgroundTransparency = 0.09
        else
            tabButtons[t[2]].BackgroundColor3 = Color3.fromRGB(28, 28, 32)
            tabButtons[t[2]].TextColor3 = Color3.fromRGB(230,230,230)
            tabButtons[t[2]].BackgroundTransparency = 0.22
        end
    end
end
selectTab("up")

-- === ЧЕТЫРЕ БЛОКА-ПОЛЗУНКА ===

local SLIDER_Y_UP = 80
local SLIDER_Y_DOWN = 144
local SLIDER_BG_UP = 104
local SLIDER_BG_DOWN = 168

local function createSliderBlock(text, parent)
    local block = {}
    block.label = Instance.new("TextLabel")
    block.label.Size = UDim2.new(0, 180, 0, 22)
    block.label.Position = UDim2.new(0, 76, 0, SLIDER_Y_UP)
    block.label.BackgroundTransparency = 1
    block.label.Text = text
    block.label.Font = Enum.Font.SourceSansBold
    block.label.TextSize = 18
    block.label.TextColor3 = Color3.fromRGB(220,220,220)
    block.label.TextXAlignment = Enum.TextXAlignment.Left
    block.label.Parent = parent

    block.bg = Instance.new("Frame")
    block.bg.Size = UDim2.new(0, 210, 0, 32)
    block.bg.Position = UDim2.new(0, 72, 0, SLIDER_BG_UP)
    block.bg.BackgroundColor3 = Color3.fromRGB(19, 20, 22)
    block.bg.BackgroundTransparency = 0.18
    block.bg.BorderSizePixel = 0
    block.bg.Parent = parent

    block.frame = Instance.new("Frame")
    block.frame.Size = UDim2.new(1, 0, 1, 0)
    block.frame.Position = UDim2.new(0, 0, 0, 0)
    block.frame.BackgroundTransparency = 1
    block.frame.Parent = block.bg

    block.barBg = Instance.new("Frame")
    block.barBg.Size = UDim2.new(0, 180, 0, 6)
    block.barBg.Position = UDim2.new(0, 15, 0.5, -3)
    block.barBg.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
    block.barBg.BorderSizePixel = 0
    block.barBg.Parent = block.frame

    block.barFill = Instance.new("Frame")
    block.barFill.Size = UDim2.new(0, 0, 1, 0)
    block.barFill.Position = UDim2.new(0, 0, 0, 0)
    block.barFill.BackgroundColor3 = Color3.fromRGB(85, 210, 120)
    block.barFill.BorderSizePixel = 0
    block.barFill.Parent = block.barBg

    block.knob = Instance.new("Frame")
    block.knob.Size = UDim2.new(0, 14, 0, 14)
    block.knob.Position = UDim2.new(0, -7, 0.5, -7)
    block.knob.BackgroundColor3 = Color3.fromRGB(170, 255, 170)
    block.knob.BorderSizePixel = 0
    block.knob.BackgroundTransparency = 0.15
    block.knob.Parent = block.barBg
    block.knob.ZIndex = 2
    block.knob.AnchorPoint = Vector2.new(0.5, 0.5)
    block.knob.ClipsDescendants = false

    block.valueLabel = Instance.new("TextLabel")
    block.valueLabel.Size = UDim2.new(0, 60, 1, 0)
    block.valueLabel.Position = UDim2.new(0.5, -30, 0, -8)
    block.valueLabel.BackgroundTransparency = 1
    block.valueLabel.Text = "1 %"
    block.valueLabel.Font = Enum.Font.SourceSansBold
    block.valueLabel.TextSize = 15
    block.valueLabel.TextColor3 = Color3.fromRGB(200,255,200)
    block.valueLabel.TextStrokeTransparency = 0.35
    block.valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    block.valueLabel.TextYAlignment = Enum.TextYAlignment.Center
    block.valueLabel.Parent = block.barBg
    block.valueLabel.ZIndex = 3

    -- Скрыть по умолчанию
    block.label.Visible = false
    block.bg.Visible = false

    -- Ползунок логика
    local minValue, maxValue = 1, 32
    local value = minValue
    local dragging = false

    local function updateSliderVisual(rel)
        local width = block.barBg.AbsoluteSize.X
        block.barFill.Size = UDim2.new(0, rel * width, 1, 0)
        block.knob.Position = UDim2.new(0, rel * width, 0.5, 0)
        value = math.floor(minValue + (maxValue - minValue) * rel + 0.5)
        block.valueLabel.Text = tostring(value) .. " %"
    end

    local function setSlider(posX)
        local barAbsPos = block.barBg.AbsolutePosition.X
        local barWidth = block.barBg.AbsoluteSize.X
        local rel = math.clamp((posX - barAbsPos) / barWidth, 0, 1)
        updateSliderVisual(rel)
    end

    block.knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    block.knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    block.barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setSlider(input.Position.X) dragging = true
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setSlider(input.Position.X) end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    updateSliderVisual(0)
    return block
end

-- Все четыре ползунка
local sliders = {
    up = createSliderBlock("скорость в высоту", mainFrame),
    down = createSliderBlock("скорость в низ", mainFrame),
    right = createSliderBlock("скорость вправо", mainFrame),
    left = createSliderBlock("скорость в влево", mainFrame),
}

-- Показывать только активный ползунок
local function showSlider(tab)
    for k,v in pairs(sliders) do
        v.label.Visible = (k == tab)
        v.bg.Visible = (k == tab)
    end
end
showSlider("up")

-- Переключение вкладок
for k, tab in pairs(tabButtons) do
    tab.MouseButton1Click:Connect(function()
        currentTab = k
        selectTab(k)
        showSlider(k)
    end)
end

-- Анимация смещения вниз
local function moveSlider(down)
    local newLabelY = down and SLIDER_Y_DOWN or SLIDER_Y_UP
    local newBgY    = down and SLIDER_BG_DOWN or SLIDER_BG_UP
    local tab = currentTab
    TweenService:Create(sliders[tab].label, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 76, 0, newLabelY)}):Play()
    TweenService:Create(sliders[tab].bg, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 72, 0, newBgY)}):Play()
end

-- dropdownFrame и всё остальное оставь как раньше!
local function toggleDropdown()
    local willOpen = not dropdownFrame.Visible
    dropdownFrame.Visible = willOpen
    moveSlider(willOpen)
end

label.MouseButton1Click:Connect(toggleDropdown)

checkbox.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    boxIndicator.Visible = isEnabled
    if isEnabled then
        dropdownFrame.Visible = true
        moveSlider(true)
    else
        dropdownFrame.Visible = false
        moveSlider(false)
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
