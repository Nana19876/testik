-- skeet-menu-with-proper-color-picker.lua

-- Services
local UserInputService = game:GetService("UserInputService")

-- Settings
local BoxESPSettings = {
    useBoxESP = true,
    boxColor = Color3.new(1, 1, 1),
    useCustomColor = false,
    customColor = Color3.new(1, 0, 0)
}

-- Helper Functions
local function HSVtoRGB(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end

    return Color3.new(r, g, b)
end

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkeetMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.Text = "Skeet Menu"
titleLabel.Parent = mainFrame

local boxESPButton = Instance.new("TextButton")
boxESPButton.Size = UDim2.new(1, 0, 0, 30)
boxESPButton.Position = UDim2.new(0, 0, 0, 40)
boxESPButton.Text = "Toggle Box ESP"
boxESPButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
boxESPButton.TextColor3 = Color3.new(1, 1, 1)
boxESPButton.Parent = mainFrame

boxESPButton.MouseButton1Click:Connect(function()
    BoxESPSettings.useBoxESP = not BoxESPSettings.useBoxESP
    print("Box ESP:", BoxESPSettings.useBoxESP)
end)

local colorPickerButton = Instance.new("TextButton")
colorPickerButton.Size = UDim2.new(1, 0, 0, 30)
colorPickerButton.Position = UDim2.new(0, 0, 0, 80)
colorPickerButton.Text = "Open Color Picker"
colorPickerButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
colorPickerButton.TextColor3 = Color3.new(1, 1, 1)
colorPickerButton.Parent = mainFrame

local colorPickerFrame

local function createColorPicker()
    if colorPickerFrame then return end

    colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Name = "ColorPickerFrame"
    colorPickerFrame.Size = UDim2.new(0, 250, 0, 250)
    colorPickerFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
    colorPickerFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    colorPickerFrame.BorderSizePixel = 0
    colorPickerFrame.ZIndex = 30
    colorPickerFrame.Parent = screenGui

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -20, 0, 0)
    closeButton.Text = "X"
    closeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Parent = colorPickerFrame

    closeButton.MouseButton1Click:Connect(function()
        colorPickerFrame:Destroy()
        colorPickerFrame = nil
    end)

    local colorPreview = Instance.new("Frame")
    colorPreview.Name = "ColorPreview"
    colorPreview.Size = UDim2.new(0, 50, 0, 50)
    colorPreview.Position = UDim2.new(0, 10, 0, 10)
    colorPreview.BackgroundColor3 = BoxESPSettings.customColor
    colorPreview.BorderSizePixel = 0
    colorPreview.Parent = colorPickerFrame

    local rgbValue = Instance.new("TextLabel")
    rgbValue.Name = "RGBValue"
    rgbValue.Size = UDim2.new(1, 0, 0, 20)
    rgbValue.Position = UDim2.new(0, 0, 0, 70)
    rgbValue.BackgroundTransparency = 1
    rgbValue.TextColor3 = Color3.new(1, 1, 1)
    rgbValue.Font = Enum.Font.SourceSans
    rgbValue.TextSize = 14
    rgbValue.Text = string.format("%d, %d, %d", 
        BoxESPSettings.customColor.R * 255, 
        BoxESPSettings.customColor.G * 255, 
        BoxESPSettings.customColor.B * 255)
    rgbValue.Parent = colorPickerFrame

    local hueBar = Instance.new("Frame")
    hueBar.Name = "HueBar"
    hueBar.Size = UDim2.new(0, 20, 0, 150)
    hueBar.Position = UDim2.new(0, 70, 0, 10)
    hueBar.BackgroundColor3 = Color3.new(1, 0, 0)
    hueBar.BorderSizePixel = 0
    hueBar.Parent = colorPickerFrame

    -- Create gradient for hue bar
    for i = 0, 30 do
        local stripe = Instance.new("Frame")
        stripe.Size = UDim2.new(1, 0, 0, 5)
        stripe.Position = UDim2.new(0, 0, 0, i * 5)
        stripe.BackgroundColor3 = HSVtoRGB(i / 30, 1, 1)
        stripe.BorderSizePixel = 0
        stripe.Parent = hueBar
    end

    local colorArea = Instance.new("Frame")
    colorArea.Name = "ColorArea"
    colorArea.Size = UDim2.new(0, 150, 0, 150)
    colorArea.Position = UDim2.new(0, 100, 0, 10)
    colorArea.BackgroundColor3 = Color3.new(1, 1, 1)
    colorArea.BorderSizePixel = 0
    colorArea.Parent = colorPickerFrame

    local colorIndicator = Instance.new("Frame")
    colorIndicator.Name = "ColorIndicator"
    colorIndicator.Size = UDim2.new(0, 8, 0, 8)
    colorIndicator.Position = UDim2.new(0, 0, 0, 0)
    colorIndicator.BackgroundColor3 = Color3.new(0, 0, 0)
    colorIndicator.BorderSizePixel = 1
    colorIndicator.BorderColor3 = Color3.new(1, 1, 1)
    colorIndicator.ZIndex = 30
    colorIndicator.Parent = colorArea

    local hueIndicator = Instance.new("Frame")
    hueIndicator.Name = "HueIndicator"
    hueIndicator.Size = UDim2.new(0, 4, 0, 4)
    hueIndicator.Position = UDim2.new(0, -2, 0, 0)
    hueIndicator.BackgroundColor3 = Color3.new(0, 0, 0)
    hueIndicator.BorderSizePixel = 1
    hueIndicator.BorderColor3 = Color3.new(1, 1, 1)
    hueIndicator.ZIndex = 30
    hueIndicator.Parent = hueBar

    local currentHue = 0
    local currentSaturation = 0
    local currentValue = 1

    -- Функция обновления цвета (исправленная версия)
    local function updateColor(h, s, v)
        currentHue = h
        currentSaturation = s
        currentValue = v
        
        local newColor = HSVtoRGB(h, s, v)
        BoxESPSettings.customColor = newColor
        BoxESPSettings.useCustomColor = true
        
        colorPickerFrame.BackgroundColor3 = newColor
        colorPreview.BackgroundColor3 = newColor
        rgbValue.Text = string.format("%d, %d, %d", 
            math.floor(newColor.R * 255), 
            math.floor(newColor.G * 255), 
            math.floor(newColor.B * 255))
        
        -- Правильное позиционирование индикатора в пикселях
        local areaSize = colorArea.AbsoluteSize
        local indicatorX = s * areaSize.X - 4  -- s от 0 до 1, центрируем индикатор
        local indicatorY = (1-v) * areaSize.Y - 4  -- v от 1 до 0 (инвертируем), центрируем индикатор
        
        colorIndicator.Position = UDim2.new(0, indicatorX, 0, indicatorY)
        
        -- Обновляем позицию индикатора на полосе оттенков
        hueIndicator.Position = UDim2.new(0, -2, h, -2)
        
        -- Обновляем цвет основной области
        local hueColor = HSVtoRGB(h, 1, 1)
        colorArea.BackgroundColor3 = hueColor
        
        print("Цвет обновлен:", newColor, "HSV:", h, s, v)
    end

    -- Обработка кликов по полосе оттенков
    local hueBarButton = Instance.new("TextButton")
    hueBarButton.Size = UDim2.new(1, 0, 1, 0)
    hueBarButton.Text = ""
    hueBarButton.BackgroundTransparency = 1
    hueBarButton.ZIndex = 29
    hueBarButton.Parent = hueBar

    hueBarButton.MouseButton1Click:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        local barPos = hueBar.AbsolutePosition
        local barSize = hueBar.AbsoluteSize

        local relativeY = math.clamp((mouse.Y - barPos.Y) / barSize.Y, 0, 1)
        local hue = relativeY

        -- Точное позиционирование индикатора
        local indicatorY = relativeY * barSize.Y - 1.5
        hueIndicator.Position = UDim2.new(0, -2, 0, indicatorY)

        updateColor(hue, currentSaturation, currentValue)
    end)

    -- Обработка цветовой области с точным выравниванием курсора (ИСПРАВЛЕННАЯ ВЕРСИЯ)
    local colorAreaButton = Instance.new("TextButton")
    colorAreaButton.Size = UDim2.new(1, 0, 1, 0)
    colorAreaButton.Text = ""
    colorAreaButton.BackgroundTransparency = 1
    colorAreaButton.ZIndex = 29
    colorAreaButton.Parent = colorArea

    local colorAreaDragging = false

    local function updateColorFromMouse()
        local mouse = UserInputService:GetMouseLocation()
        
        -- Получаем точные границы цветовой области
        local areaPos = colorArea.AbsolutePosition
        local areaSize = colorArea.AbsoluteSize
        
        -- Вычисляем относительные координаты ТОЧНО в пределах области
        local relativeX = math.clamp((mouse.X - areaPos.X) / areaSize.X, 0, 1)
        local relativeY = math.clamp((mouse.Y - areaPos.Y) / areaSize.Y, 0, 1)
        
        -- Вычисляем точную позицию индикатора (центрируем его на курсоре)
        local indicatorX = relativeX * areaSize.X - 4  -- -4 это половина размера индикатора (8/2)
        local indicatorY = relativeY * areaSize.Y - 4  -- -4 это половина размера индикатора (8/2)
        
        -- Устанавливаем позицию индикатора в пикселях
        colorIndicator.Position = UDim2.new(0, indicatorX, 0, indicatorY)
        
        local saturation = relativeX  -- 0 = слева (белый), 1 = справа (насыщенный)
        local value = 1 - relativeY   -- 0 = снизу (черный), 1 = сверху (яркий)
        
        -- Обновляем цвет
        currentSaturation = saturation
        currentValue = value
        
        local newColor = HSVtoRGB(currentHue, saturation, value)
        BoxESPSettings.customColor = newColor
        BoxESPSettings.useCustomColor = true
        
        colorPickerFrame.BackgroundColor3 = newColor
        colorPreview.BackgroundColor3 = newColor
        rgbValue.Text = string.format("%d, %d, %d", 
            math.floor(newColor.R * 255), 
            math.floor(newColor.G * 255), 
            math.floor(newColor.B * 255))
        
        -- Обновляем цвет основной области
        local hueColor = HSVtoRGB(currentHue, 1, 1)
        colorArea.BackgroundColor3 = hueColor
        
        print("Цвет обновлен:", newColor, "Позиция индикатора:", indicatorX, indicatorY)
    end

    colorAreaButton.MouseButton1Down:Connect(function()
        colorAreaDragging = true
        updateColorFromMouse()
    end)

    colorAreaButton.MouseButton1Click:Connect(function()
        updateColorFromMouse()
    end)

    -- Глобальная обработка перетаскивания
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if colorAreaDragging then
                updateColorFromMouse()
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            colorAreaDragging = false
        end
    end)
end

colorPickerButton.MouseButton1Click:Connect(createColorPicker)

-- Game Loop (Example)
game:GetService("RunService").RenderStepped:Connect(function()
    for i, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent:IsA("Model") and v.Parent ~= game.Players.LocalPlayer.Character then
            local character = v.Parent
            local head = character:FindFirstChild("Head")
            if head then
                local boxESP = character:FindFirstChild("BoxESP")
                if BoxESPSettings.useBoxESP then
                    if not boxESP then
                        boxESP = Instance.new("BillboardGui")
                        boxESP.Name = "BoxESP"
                        boxESP.ExtentsOffset = Vector3.new(0, 1.5, 0)
                        boxESP.Size = UDim2.new(0, 50, 0, 50)
                        boxESP.AlwaysOnTop = true
                        boxESP.Parent = character

                        local frame = Instance.new("Frame")
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundTransparency = 0
                        frame.BackgroundColor3 = BoxESPSettings.useCustomColor and BoxESPSettings.customColor or BoxESPSettings.boxColor
                        frame.Parent = boxESP
                    else
                        boxESP.Frame.BackgroundColor3 = BoxESPSettings.useCustomColor and BoxESPSettings.customColor or BoxESPSettings.boxColor
                    end
                else
                    if boxESP then
                        boxESP:Destroy()
                    end
                end
            end
        end
    end
end)
