-- Добавь в начало после TweenService, Players ... (перед главным окном):

-- Для переключения вкладок
local currentTab = "up" -- up = "скорость в высоту", down = "скорость в низ"

-- === КНОПКИ ВКЛАДОК ===
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(0, 300, 0, 34)
tabFrame.Position = UDim2.new(0, 76, 0, 6)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabUp = Instance.new("TextButton")
tabUp.Size = UDim2.new(0, 146, 0, 32)
tabUp.Position = UDim2.new(0, 0, 0, 0)
tabUp.BackgroundColor3 = Color3.fromRGB(38, 95, 45)
tabUp.BackgroundTransparency = 0.09
tabUp.BorderSizePixel = 0
tabUp.Text = "скорость в высоту"
tabUp.Font = Enum.Font.SourceSansBold
tabUp.TextSize = 17
tabUp.TextColor3 = Color3.fromRGB(210,255,210)
tabUp.Parent = tabFrame

local tabDown = Instance.new("TextButton")
tabDown.Size = UDim2.new(0, 146, 0, 32)
tabDown.Position = UDim2.new(0, 154, 0, 0)
tabDown.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
tabDown.BackgroundTransparency = 0.22
tabDown.BorderSizePixel = 0
tabDown.Text = "скорость в низ"
tabDown.Font = Enum.Font.SourceSansBold
tabDown.TextSize = 17
tabDown.TextColor3 = Color3.fromRGB(230,230,230)
tabDown.Parent = tabFrame

local function selectTab(tab)
    if tab == "up" then
        tabUp.BackgroundColor3 = Color3.fromRGB(38, 95, 45)
        tabUp.TextColor3 = Color3.fromRGB(210,255,210)
        tabDown.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        tabDown.TextColor3 = Color3.fromRGB(230,230,230)
    else
        tabDown.BackgroundColor3 = Color3.fromRGB(38, 95, 45)
        tabDown.TextColor3 = Color3.fromRGB(210,255,210)
        tabUp.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        tabUp.TextColor3 = Color3.fromRGB(230,230,230)
    end
end
selectTab("up")

-- === ДВА БЛОКА: для высоты и для "в низ". Только один видим ===

-- "Вверх" блок (как раньше)
local SLIDER_Y_UP = 42 + 38
local SLIDER_Y_DOWN = 106 + 38
local SLIDER_BG_UP = 66 + 38
local SLIDER_BG_DOWN = 130 + 38

local sliderLabelUp = Instance.new("TextLabel")
sliderLabelUp.Size = UDim2.new(0, 180, 0, 22)
sliderLabelUp.Position = UDim2.new(0, 76, 0, SLIDER_Y_UP)
sliderLabelUp.BackgroundTransparency = 1
sliderLabelUp.Text = "скорость в высоту"
sliderLabelUp.Font = Enum.Font.SourceSansBold
sliderLabelUp.TextSize = 18
sliderLabelUp.TextColor3 = Color3.fromRGB(220,220,220)
sliderLabelUp.TextXAlignment = Enum.TextXAlignment.Left
sliderLabelUp.Parent = mainFrame

local sliderBackgroundUp = Instance.new("Frame")
sliderBackgroundUp.Size = UDim2.new(0, 210, 0, 32)
sliderBackgroundUp.Position = UDim2.new(0, 72, 0, SLIDER_BG_UP)
sliderBackgroundUp.BackgroundColor3 = Color3.fromRGB(19, 20, 22)
sliderBackgroundUp.BackgroundTransparency = 0.18
sliderBackgroundUp.BorderSizePixel = 0
sliderBackgroundUp.Parent = mainFrame

local sliderFrameUp = Instance.new("Frame")
sliderFrameUp.Size = UDim2.new(1, 0, 1, 0)
sliderFrameUp.Position = UDim2.new(0, 0, 0, 0)
sliderFrameUp.BackgroundTransparency = 1
sliderFrameUp.Parent = sliderBackgroundUp

local sliderBarBgUp = Instance.new("Frame")
sliderBarBgUp.Size = UDim2.new(0, 180, 0, 6)
sliderBarBgUp.Position = UDim2.new(0, 15, 0.5, -3)
sliderBarBgUp.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
sliderBarBgUp.BorderSizePixel = 0
sliderBarBgUp.Parent = sliderFrameUp

local sliderBarFillUp = Instance.new("Frame")
sliderBarFillUp.Size = UDim2.new(0, 0, 1, 0)
sliderBarFillUp.Position = UDim2.new(0, 0, 0, 0)
sliderBarFillUp.BackgroundColor3 = Color3.fromRGB(85, 210, 120)
sliderBarFillUp.BorderSizePixel = 0
sliderBarFillUp.Parent = sliderBarBgUp

local sliderKnobUp = Instance.new("Frame")
sliderKnobUp.Size = UDim2.new(0, 14, 0, 14)
sliderKnobUp.Position = UDim2.new(0, -7, 0.5, -7)
sliderKnobUp.BackgroundColor3 = Color3.fromRGB(170, 255, 170)
sliderKnobUp.BorderSizePixel = 0
sliderKnobUp.BackgroundTransparency = 0.15
sliderKnobUp.Parent = sliderBarBgUp
sliderKnobUp.ZIndex = 2
sliderKnobUp.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnobUp.ClipsDescendants = false
sliderKnobUp.Name = "SliderKnobUp"

local sliderValueUp = Instance.new("TextLabel")
sliderValueUp.Size = UDim2.new(0, 60, 1, 0)
sliderValueUp.Position = UDim2.new(0.5, -30, 0, -8)
sliderValueUp.BackgroundTransparency = 1
sliderValueUp.Text = "1 %"
sliderValueUp.Font = Enum.Font.SourceSansBold
sliderValueUp.TextSize = 15
sliderValueUp.TextColor3 = Color3.fromRGB(200,255,200)
sliderValueUp.TextStrokeTransparency = 0.35
sliderValueUp.TextXAlignment = Enum.TextXAlignment.Center
sliderValueUp.TextYAlignment = Enum.TextYAlignment.Center
sliderValueUp.Parent = sliderBarBgUp
sliderValueUp.ZIndex = 3

-- "Вниз" блок (новый!)
local sliderLabelDown = sliderLabelUp:Clone()
sliderLabelDown.Text = "скорость в низ"
sliderLabelDown.Parent = mainFrame

local sliderBackgroundDown = sliderBackgroundUp:Clone()
sliderBackgroundDown.Parent = mainFrame

local sliderFrameDown = sliderFrameUp:Clone()
sliderFrameDown.Parent = sliderBackgroundDown

local sliderBarBgDown = sliderBarBgUp:Clone()
sliderBarBgDown.Parent = sliderFrameDown

local sliderBarFillDown = sliderBarFillUp:Clone()
sliderBarFillDown.Parent = sliderBarBgDown

local sliderKnobDown = sliderKnobUp:Clone()
sliderKnobDown.Parent = sliderBarBgDown
sliderKnobDown.Name = "SliderKnobDown"

local sliderValueDown = sliderValueUp:Clone()
sliderValueDown.Parent = sliderBarBgDown

-- Позиции одинаковые, чтобы анимировать так же как с высотой.
sliderLabelDown.Position = sliderLabelUp.Position
sliderBackgroundDown.Position = sliderBackgroundUp.Position

-- По умолчанию показываем только "up"
sliderLabelUp.Visible = true
sliderBackgroundUp.Visible = true
sliderLabelDown.Visible = false
sliderBackgroundDown.Visible = false

-- Логика обоих ползунков (up и down)
local function makeSliderLogic(barBg, barFill, knob, valueLabel)
    local minValue, maxValue = 1, 32
    local value = minValue
    local dragging = false

    local function updateSliderVisual(rel)
        local width = barBg.AbsoluteSize.X
        barFill.Size = UDim2.new(0, rel * width, 1, 0)
        knob.Position = UDim2.new(0, rel * width, 0.5, 0)
        value = math.floor(minValue + (maxValue - minValue) * rel + 0.5)
        valueLabel.Text = tostring(value) .. " %"
    end

    local function setSlider(posX)
        local barAbsPos = barBg.AbsolutePosition.X
        local barWidth = barBg.AbsoluteSize.X
        local rel = math.clamp((posX - barAbsPos) / barWidth, 0, 1)
        updateSliderVisual(rel)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    barBg.InputBegan:Connect(function(input)
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
end

makeSliderLogic(sliderBarBgUp, sliderBarFillUp, sliderKnobUp, sliderValueUp)
makeSliderLogic(sliderBarBgDown, sliderBarFillDown, sliderKnobDown, sliderValueDown)

-- === ВКЛАДКИ ПЕРЕКЛЮЧАТЕЛЬ ===

tabUp.MouseButton1Click:Connect(function()
    currentTab = "up"
    selectTab("up")
    sliderLabelUp.Visible = true
    sliderBackgroundUp.Visible = true
    sliderLabelDown.Visible = false
    sliderBackgroundDown.Visible = false
end)

tabDown.MouseButton1Click:Connect(function()
    currentTab = "down"
    selectTab("down")
    sliderLabelUp.Visible = false
    sliderBackgroundUp.Visible = false
    sliderLabelDown.Visible = true
    sliderBackgroundDown.Visible = true
end)

-- === Плавное смещение (анимируй оба блока при выпадашке) ===
local function moveSlider(down)
    local newLabelY = down and SLIDER_Y_DOWN or SLIDER_Y_UP
    local newBgY    = down and SLIDER_BG_DOWN or SLIDER_BG_UP
    if currentTab == "up" then
        TweenService:Create(sliderLabelUp, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 76, 0, newLabelY)}):Play()
        TweenService:Create(sliderBackgroundUp, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 72, 0, newBgY)}):Play()
    else
        TweenService:Create(sliderLabelDown, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 76, 0, newLabelY)}):Play()
        TweenService:Create(sliderBackgroundDown, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 72, 0, newBgY)}):Play()
    end
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
