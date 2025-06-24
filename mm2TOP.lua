-- LocalScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Удаляем старое меню если есть
if playerGui:FindFirstChild("SkeetMenu") then
    playerGui.SkeetMenu:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "SkeetMenu"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- ESP переменные и состояния
local ESPStates = {
    box = false,
    color = false,
    gradient = false,
    ["3d box"] = false,
    nickname = false,
    ping = false,
    tracer = false,
    distance = false,
    ["radius of visibility"] = false,
    chams = false
}

-- Хранилища для ESP объектов
local ESPs = {}
local ESPConnections = {}

-- Настройки для Box ESP
local BoxESPSettings = {
    showAll = true,
    showMurderer = false,
    showSheriff = false,
    customColor = Color3.fromRGB(255, 255, 255),
    useCustomColor = false
}

-- Безопасное удаление объектов
local function SafeRemove(obj)
    if obj then
        pcall(function() obj:Remove() end)
        pcall(function() obj:Destroy() end)
        if obj.Visible ~= nil then
            obj.Visible = false
        end
    end
end

-- Проверка персонажа
local function HasCharacter(targetPlayer)
    return targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- Проверка на наличие ножа (murderer)
local function isMurderer(targetPlayer)
    local backpack = targetPlayer:FindFirstChild("Backpack")
    local character = targetPlayer.Character
    
    return (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife"))
end

-- Проверка на наличие пистолета (sheriff)
local function isSheriff(targetPlayer)
    local backpack = targetPlayer:FindFirstChild("Backpack")
    local character = targetPlayer.Character
    
    return (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun"))
end

-- ========== BOX ESP ==========
function CreateBoxESP(targetPlayer)
    if targetPlayer == player then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Filled = false
    box.Visible = false

    ESPs[targetPlayer] = box
end

function UpdateBoxESP()
    if not ESPStates.box then return end
    
    for targetPlayer, box in pairs(ESPs) do
        if targetPlayer and targetPlayer.Parent then
            local shouldShow = false
            local boxColor = BoxESPSettings.customColor

            if BoxESPSettings.showAll then
                shouldShow = true
                if not BoxESPSettings.useCustomColor then
                    boxColor = Color3.fromRGB(255, 255, 255)
                end
            else
                local isMurd = isMurderer(targetPlayer)
                local isSher = isSheriff(targetPlayer)
                
                if BoxESPSettings.showMurderer and isMurd then
                    shouldShow = true
                    if not BoxESPSettings.useCustomColor then
                        boxColor = Color3.fromRGB(255, 0, 0)
                    end
                elseif BoxESPSettings.showSheriff and isSher then
                    shouldShow = true
                    if not BoxESPSettings.useCustomColor then
                        boxColor = Color3.fromRGB(0, 150, 255)
                    end
                end
            end
            
            if shouldShow then
                local character = targetPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    local pos, onscreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onscreen then
                        local size = Vector2.new(80, 120)
                        box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                        box.Size = size
                        box.Color = boxColor
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
    end
end

-- ========== ГЛАВНЫЕ ФУНКЦИИ УПРАВЛЕНИЯ ==========
local function EnableESP(espType)
    ESPStates[espType] = true
    
    if espType == "box" then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            CreateBoxESP(targetPlayer)
        end
        if not ESPConnections.box then
            ESPConnections.box = RunService.RenderStepped:Connect(UpdateBoxESP)
        end
    end
    
    print(espType .. " ESP включен")
end

local function DisableESP(espType)
    ESPStates[espType] = false
    
    if espType == "box" then
        for _, box in pairs(ESPs) do 
            if box then
                box.Visible = false
                SafeRemove(box) 
            end
        end
        ESPs = {}
        if ESPConnections.box then
            ESPConnections.box:Disconnect()
            ESPConnections.box = nil
        end
    end
    
    print(espType .. " ESP выключен")
end

-- Цвета skeet
local colors = {
    background = Color3.fromRGB(17, 17, 17),
    secondary = Color3.fromRGB(25, 25, 25),
    accent = Color3.fromRGB(165, 194, 97),
    text = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(180, 180, 180),
    border = Color3.fromRGB(60, 60, 60),
    hover = Color3.fromRGB(35, 35, 35)
}

-- Настройки с callback функциями
local settings = {
    ESP = {
        title = "ESP",
        options = {
            {name = "box", enabled = false, hasDropdown = true, hasColorPicker = true, callback = function(enabled)
                if enabled then EnableESP("box") else DisableESP("box") end
            end},
            {name = "color", enabled = false},
            {name = "gradient", enabled = false},
            {name = "3d box", enabled = false},
            {name = "nickname", enabled = false},
            {name = "ping", enabled = false},
            {name = "tracer", enabled = false},
            {name = "distance", enabled = false},
            {name = "radius of visibility", enabled = false},
            {name = "chams", enabled = false}
        }
    },
    Aimbot = {
        title = "Aimbot", 
        options = {
            {name = "Enable Aimbot", enabled = false},
            {name = "FOV Circle", enabled = false},
            {name = "Silent Aim", enabled = false},
            {name = "Triggerbot", enabled = false}
        }
    },
    Misc = {
        title = "Misc",
        options = {
            {name = "Speed Hack", enabled = false},
            {name = "Jump Power", enabled = false},
            {name = "Noclip", enabled = false},
            {name = "Fly", enabled = false}
        }
    }
}

local currentTab = "ESP"

-- Функция для создания закругленных углов
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
createCorner(mainFrame, 8)

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = colors.secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
createCorner(titleBar, 8)

-- Фикс для закругленных углов только сверху
local titleBarBottom = Instance.new("Frame")
titleBarBottom.Size = UDim2.new(1, 0, 0, 8)
titleBarBottom.Position = UDim2.new(0, 0, 1, -8)
titleBarBottom.BackgroundColor3 = colors.secondary
titleBarBottom.BorderSizePixel = 0
titleBarBottom.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 200, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Text = "skeet.cc"
titleText.TextColor3 = colors.accent
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 20)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text = "X"
closeButton.TextColor3 = colors.text
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 12
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar
createCorner(closeButton, 4)

closeButton.MouseButton1Click:Connect(function()
    for espType, _ in pairs(ESPStates) do
        DisableESP(espType)
    end
    gui:Destroy()
end)

-- Контейнер для табов
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 35)
tabContainer.Position = UDim2.new(0, 5, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

-- Контейнер для контента
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -10, 1, -75)
contentContainer.Position = UDim2.new(0, 5, 0, 70)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Функция создания таба
local function createTab(name, index)
    local tabCount = 3
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1/tabCount, -2, 1, 0)
    tabButton.Position = UDim2.new((index-1)/tabCount, (index-1)*2, 0, 0)
    tabButton.Text = name
    tabButton.TextColor3 = (name == currentTab) and colors.accent or colors.textSecondary
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 12
    tabButton.BackgroundColor3 = (name == currentTab) and colors.secondary or colors.background
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabContainer
    createCorner(tabButton, 6)
    
    tabButton.MouseButton1Click:Connect(function()
        for _, child in pairs(tabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = colors.textSecondary
                child.BackgroundColor3 = colors.background
            end
        end
        
        tabButton.TextColor3 = colors.accent
        tabButton.BackgroundColor3 = colors.secondary
        currentTab = name
        
        for _, page in pairs(contentContainer:GetChildren()) do
            if page:IsA("ScrollingFrame") then
                page.Visible = (page.Name == name .. "Page")
            end
        end
    end)
end

-- ПРАВИЛЬНАЯ ЦВЕТОВАЯ ПАЛИТРА
local function createColorPicker(parent, yPos)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0, 20, 0, 15)
    colorFrame.Position = UDim2.new(1, -25, 0.5, -7.5)
    colorFrame.BackgroundColor3 = BoxESPSettings.customColor
    colorFrame.BorderSizePixel = 1
    colorFrame.BorderColor3 = colors.border
    colorFrame.ZIndex = 15
    colorFrame.Parent = parent
    createCorner(colorFrame, 3)
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(1, 0, 1, 0)
    colorButton.Text = ""
    colorButton.BackgroundTransparency = 1
    colorButton.ZIndex = 16
    colorButton.Parent = colorFrame
    
    local colorPalette = Instance.new("Frame")
    colorPalette.Size = UDim2.new(0, 300, 0, 220)
    colorPalette.Position = UDim2.new(0, -280, 1, 2)
    colorPalette.BackgroundColor3 = colors.secondary
    colorPalette.BorderSizePixel = 1
    colorPalette.BorderColor3 = colors.border
    colorPalette.Visible = false
    colorPalette.ZIndex = 25
    colorPalette.Parent = colorFrame
    createCorner(colorPalette, 3)
    
    -- Заголовок
    local paletteTitle = Instance.new("TextLabel")
    paletteTitle.Size = UDim2.new(1, 0, 0, 25)
    paletteTitle.Position = UDim2.new(0, 0, 0, 0)
    paletteTitle.Text = "Color Picker"
    paletteTitle.TextColor3 = colors.text
    paletteTitle.Font = Enum.Font.SourceSansBold
    paletteTitle.TextSize = 12
    paletteTitle.BackgroundTransparency = 1
    paletteTitle.ZIndex = 26
    paletteTitle.Parent = colorPalette
    
    -- Вертикальная полоса оттенков (слева)
    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0, 20, 0, 140)
    hueBar.Position = UDim2.new(0, 10, 0, 30)
    hueBar.BorderSizePixel = 1
    hueBar.BorderColor3 = colors.border
    hueBar.ZIndex = 26
    hueBar.Parent = colorPalette
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    hueGradient.Rotation = 90
    hueGradient.Parent = hueBar
    
    -- Основная цветовая область (справа)
    local colorArea = Instance.new("Frame")
    colorArea.Size = UDim2.new(0, 200, 0, 140)
    colorArea.Position = UDim2.new(0, 40, 0, 30)
    colorArea.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    colorArea.BorderSizePixel = 1
    colorArea.BorderColor3 = colors.border
    colorArea.ZIndex = 26
    colorArea.Parent = colorPalette
    
    -- Градиент насыщенности (горизонтальный: белый слева -> прозрачный справа)
    local saturationOverlay = Instance.new("Frame")
    saturationOverlay.Size = UDim2.new(1, 0, 1, 0)
    saturationOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    saturationOverlay.ZIndex = 27
    saturationOverlay.Parent = colorArea
    
    local satGradient = Instance.new("UIGradient")
    satGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),    -- Белый слева (полная непрозрачность)
        NumberSequenceKeypoint.new(1, 1)     -- Прозрачный справа
    }
    satGradient.Rotation = 0
    satGradient.Parent = saturationOverlay
    
    -- Градиент яркости (вертикальный: прозрачный сверху -> черный снизу)
    local brightnessOverlay = Instance.new("Frame")
    brightnessOverlay.Size = UDim2.new(1, 0, 1, 0)
    brightnessOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    brightnessOverlay.ZIndex = 28
    brightnessOverlay.Parent = colorArea
    
    local brightGradient = Instance.new("UIGradient")
    brightGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),    -- Прозрачный сверху
        NumberSequenceKeypoint.new(1, 0)     -- Черный снизу (полная непрозрачность)
    }
    brightGradient.Rotation = 90
    brightGradient.Parent = brightnessOverlay
    
    -- Индикатор на цветовой области (белый кружок с черной обводкой)
    local colorIndicator = Instance.new("Frame")
    colorIndicator.Size = UDim2.new(0, 12, 0, 12)
    colorIndicator.Position = UDim2.new(1, -6, 0, -6) -- Начальная позиция: правый верхний угол
    colorIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    colorIndicator.BorderSizePixel = 2
    colorIndicator.BorderColor3 = Color3.fromRGB(0, 0, 0)
    colorIndicator.ZIndex = 30
    colorIndicator.Parent = colorArea
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = colorIndicator
    
    -- Индикатор на полосе оттенков (белый прямоугольник)
    local hueIndicator = Instance.new("Frame")
    hueIndicator.Size = UDim2.new(1, 4, 0, 4)
    hueIndicator.Position = UDim2.new(0, -2, 0, -2)
    hueIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueIndicator.BorderSizePixel = 1
    hueIndicator.BorderColor3 = Color3.fromRGB(0, 0, 0)
    hueIndicator.ZIndex = 30
    hueIndicator.Parent = hueBar
    
    -- Предпросмотр цвета
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 50, 0, 25)
    colorPreview.Position = UDim2.new(0, 10, 1, -35)
    colorPreview.BackgroundColor3 = BoxESPSettings.customColor
    colorPreview.BorderSizePixel = 1
    colorPreview.BorderColor3 = colors.border
    colorPreview.ZIndex = 26
    colorPreview.Parent = colorPalette
    createCorner(colorPreview, 3)
    
    -- RGB значения
    local rgbLabel = Instance.new("TextLabel")
    rgbLabel.Size = UDim2.new(0, 120, 0, 25)
    rgbLabel.Position = UDim2.new(0, 70, 1, -35)
    rgbLabel.Text = "RGB: 255, 255, 255"
    rgbLabel.TextColor3 = colors.text
    rgbLabel.Font = Enum.Font.SourceSans
    rgbLabel.TextSize = 10
    rgbLabel.TextXAlignment = Enum.TextXAlignment.Left
    rgbLabel.BackgroundTransparency = 1
    rgbLabel.ZIndex = 26
    rgbLabel.Parent = colorPalette
    
    -- Кнопка "Auto Color"
    local autoColorButton = Instance.new("TextButton")
    autoColorButton.Size = UDim2.new(0, 70, 0, 25)
    autoColorButton.Position = UDim2.new(1, -80, 1, -35)
    autoColorButton.Text = "Auto Color"
    autoColorButton.TextColor3 = colors.text
    autoColorButton.Font = Enum.Font.SourceSans
    autoColorButton.TextSize = 9
    autoColorButton.BackgroundColor3 = colors.hover
    autoColorButton.BorderSizePixel = 1
    autoColorButton.BorderColor3 = colors.border
    autoColorButton.ZIndex = 26
    autoColorButton.Parent = colorPalette
    createCorner(autoColorButton, 3)
    
    -- Переменные для HSV
    local currentHue = 0
    local currentSaturation = 1
    local currentValue = 1
    
    -- Функция конвертации HSV в RGB
    local function HSVtoRGB(h, s, v)
        local r, g, b
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        
        local imod = i % 6
        if imod == 0 then
            r, g, b = v, t, p
        elseif imod == 1 then
            r, g, b = q, v, p
        elseif imod == 2 then
            r, g, b = p, v, t
        elseif imod == 3 then
            r, g, b = p, q, v
        elseif imod == 4 then
            r, g, b = t, p, v
        elseif imod == 5 then
            r, g, b = v, p, q
        end
        
        return Color3.fromRGB(math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
    end
    
    -- Функция обновления цвета
    local function updateColor(h, s, v)
        currentHue = h
        currentSaturation = s
        currentValue = v
        
        local newColor = HSVtoRGB(h, s, v)
        BoxESPSettings.customColor = newColor
        BoxESPSettings.useCustomColor = true
        
        colorFrame.BackgroundColor3 = newColor
        colorPreview.BackgroundColor3 = newColor
        rgbLabel.Text = string.format("RGB: %d, %d, %d", 
            math.floor(newColor.R * 255), 
            math.floor(newColor.G * 255), 
            math.floor(newColor.B * 255))
        
        -- Обновляем позицию индикатора на цветовой области
        -- s = 0 (слева) до s = 1 (справа)
        -- v = 1 (сверху) до v = 0 (снизу)
        colorIndicator.Position = UDim2.new(s, -6, 1-v, -6)
        
        -- Обновляем позицию индикатора на полосе оттенков
        hueIndicator.Position = UDim2.new(0, -2, h, -2)
        
        -- Обновляем цвет основной области
        local hueColor = HSVtoRGB(h, 1, 1)
        colorArea.BackgroundColor3 = hueColor
        
        print("Цвет обновлен:", newColor, "HSV:", h, s, v)
    end
    
    -- Обработка полосы оттенков
    local hueButton = Instance.new("TextButton")
    hueButton.Size = UDim2.new(1, 0, 1, 0)
    hueButton.Text = ""
    hueButton.BackgroundTransparency = 1
    hueButton.ZIndex = 29
    hueButton.Parent = hueBar
    
    local hueDragging = false
    
    local function updateHueFromMouse()
        local mouse = UserInputService:GetMouseLocation()
        local relativeY = math.clamp((mouse.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
        updateColor(relativeY, currentSaturation, currentValue)
    end
    
    hueButton.MouseButton1Down:Connect(function()
        hueDragging = true
        updateHueFromMouse()
    end)
    
    hueButton.MouseButton1Click:Connect(function()
        updateHueFromMouse()
    end)
    
    -- Обработка цветовой области
    local colorAreaButton = Instance.new("TextButton")
    colorAreaButton.Size = UDim2.new(1, 0, 1, 0)
    colorAreaButton.Text = ""
    colorAreaButton.BackgroundTransparency = 1
    colorAreaButton.ZIndex = 29
    colorAreaButton.Parent = colorArea
    
    local colorAreaDragging = false
    
    local function updateColorFromMouse()
        local mouse = UserInputService:GetMouseLocation()
        local relativeX = math.clamp((mouse.X - colorArea.AbsolutePosition.X) / colorArea.AbsoluteSize.X, 0, 1)
        local relativeY = math.clamp((mouse.Y - colorArea.AbsolutePosition.Y) / colorArea.AbsoluteSize.Y, 0, 1)
        
        local saturation = relativeX  -- 0 = слева (белый), 1 = справа (насыщенный)
        local value = 1 - relativeY   -- 0 = снизу (черный), 1 = сверху (яркий)
        
        updateColor(currentHue, saturation, value)
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
            if hueDragging then
                updateHueFromMouse()
            elseif colorAreaDragging then
                updateColorFromMouse()
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
            colorAreaDragging = false
        end
    end)
    
    -- Кнопка Auto Color
    autoColorButton.MouseButton1Click:Connect(function()
        BoxESPSettings.useCustomColor = false
        colorFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        colorPalette.Visible = false
        print("Включен авто цвет ESP")
    end)
    
    -- Инициализация с красным цветом
    updateColor(0, 1, 1)
    
    local paletteOpen = false
    
    colorButton.MouseButton1Click:Connect(function()
        paletteOpen = not paletteOpen
        colorPalette.Visible = paletteOpen
        print("Color picker открыт:", paletteOpen)
    end)
    
    -- Закрытие при клике вне палитры
    spawn(function()
        while colorFrame.Parent do
            wait(0.1)
            if paletteOpen then
                local mouse = UserInputService:GetMouseLocation()
                local palettePos = colorPalette.AbsolutePosition
                local paletteSize = colorPalette.AbsoluteSize
                local framePos = colorFrame.AbsolutePosition
                
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local insidePalette = (mouse.X >= palettePos.X and mouse.X <= palettePos.X + paletteSize.X and
                                         mouse.Y >= palettePos.Y and mouse.Y <= palettePos.Y + paletteSize.Y)
                    local insideButton = (mouse.X >= framePos.X and mouse.X <= framePos.X + 20 and
                                         mouse.Y >= framePos.Y and mouse.Y <= framePos.Y + 15)
                    
                    if not insidePalette and not insideButton and not hueDragging and not colorAreaDragging then
                        wait(0.1)
                        paletteOpen = false
                        colorPalette.Visible = false
                    end
                end
            end
        end
    end)
    
    return colorFrame
end

-- Функция создания dropdown
local function createMultiDropdown(parent, yPos)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 120, 0, 15)
    dropdownFrame.Position = UDim2.new(1, -150, 0.5, -7.5)
    dropdownFrame.BackgroundColor3 = colors.secondary
    dropdownFrame.BorderSizePixel = 1
    dropdownFrame.BorderColor3 = colors.border
    dropdownFrame.ZIndex = 15
    dropdownFrame.Parent = parent
    createCorner(dropdownFrame, 3)
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Text = "All Players ▼"
    dropdownButton.TextColor3 = colors.text
    dropdownButton.Font = Enum.Font.SourceSans
    dropdownButton.TextSize = 9
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.ZIndex = 16
    dropdownButton.Parent = dropdownFrame
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, 75)
    dropdownList.Position = UDim2.new(0, 0, 1, 2)
    dropdownList.BackgroundColor3 = colors.secondary
    dropdownList.BorderSizePixel = 1
    dropdownList.BorderColor3 = colors.border
    dropdownList.Visible = false
    dropdownList.ZIndex = 20
    dropdownList.Parent = dropdownFrame
    createCorner(dropdownList, 3)
    
    local options = {
        {text = "All Players", setting = "showAll"},
        {text = "Murderer", setting = "showMurderer"},
        {text = "Sheriff", setting = "showSheriff"}
    }
    
    for i, option in ipairs(options) do
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, -4, 1/3, -2)
        optionFrame.Position = UDim2.new(0, 2, (i-1)/3, (i-1))
        optionFrame.BackgroundTransparency = 1
        optionFrame.ZIndex = 21
        optionFrame.Parent = dropdownList
        
        local optionCheckbox = Instance.new("TextButton")
        optionCheckbox.Size = UDim2.new(0, 12, 0, 12)
        optionCheckbox.Position = UDim2.new(0, 5, 0.5, -6)
        optionCheckbox.Text = ""
        optionCheckbox.BackgroundColor3 = BoxESPSettings[option.setting] and colors.accent or colors.background
        optionCheckbox.BorderSizePixel = 1
        optionCheckbox.BorderColor3 = colors.border
        optionCheckbox.ZIndex = 22
        optionCheckbox.Parent = optionFrame
        createCorner(optionCheckbox, 2)
        
        local optionCheckmark = Instance.new("TextLabel")
        optionCheckmark.Size = UDim2.new(1, 0, 1, 0)
        optionCheckmark.Text = "✓"
        optionCheckmark.TextColor3 = colors.background
        optionCheckmark.Font = Enum.Font.SourceSansBold
        optionCheckmark.TextSize = 8
        optionCheckmark.BackgroundTransparency = 1
        optionCheckmark.Visible = BoxESPSettings[option.setting]
        optionCheckmark.ZIndex = 23
        optionCheckmark.Parent = optionCheckbox
        
        local optionLabel = Instance.new("TextLabel")
        optionLabel.Size = UDim2.new(1, -25, 1, 0)
        optionLabel.Position = UDim2.new(0, 20, 0, 0)
        optionLabel.Text = option.text
        optionLabel.TextColor3 = colors.text
        optionLabel.Font = Enum.Font.SourceSans
        optionLabel.TextSize = 9
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.BackgroundTransparency = 1
        optionLabel.ZIndex = 22
        optionLabel.Parent = optionFrame
        
        optionCheckbox.MouseButton1Click:Connect(function()
            if option.setting == "showAll" then
                BoxESPSettings.showAll = not BoxESPSettings.showAll
                if BoxESPSettings.showAll then
                    BoxESPSettings.showMurderer = false
                    BoxESPSettings.showSheriff = false
                end
            else
                BoxESPSettings[option.setting] = not BoxESPSettings[option.setting]
                if BoxESPSettings[option.setting] then
                    BoxESPSettings.showAll = false
                end
            end
            
            -- Обновляем все чекбоксы
            for j, opt in ipairs(options) do
                local frame = dropdownList:GetChildren()[j]
                if frame and frame:IsA("Frame") then
                    local checkbox = frame:FindFirstChild("TextButton")
                    local checkmark = checkbox and checkbox:FindFirstChild("TextLabel")
                    if checkbox and checkmark then
                        local isActive = BoxESPSettings[opt.setting]
                        checkbox.BackgroundColor3 = isActive and colors.accent or colors.background
                        checkmark.Visible = isActive
                    end
                end
            end
            
            -- Обновляем текст кнопки
            local activeOptions = {}
            if BoxESPSettings.showAll then
                table.insert(activeOptions, "All Players")
            end
            if BoxESPSettings.showMurderer then
                table.insert(activeOptions, "Murderer")
            end
            if BoxESPSettings.showSheriff then
                table.insert(activeOptions, "Sheriff")
            end
            
            if #activeOptions == 0 then
                dropdownButton.Text = "None ▼"
            elseif #activeOptions == 1 then
                dropdownButton.Text = activeOptions[1] .. " ▼"
            else
                dropdownButton.Text = table.concat(activeOptions, "+") .. " ▼"
            end
        end)
    end
    
    local dropdownOpen = false
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        dropdownList.Visible = dropdownOpen
    end)
    
    return dropdownFrame
end

-- Функция создания чекбокса
local function createCheckbox(parent, option, yPos)
    local checkFrame = Instance.new("Frame")
    checkFrame.Size = UDim2.new(1, -10, 0, 25)
    checkFrame.Position = UDim2.new(0, 5, 0, yPos)
    checkFrame.BackgroundTransparency = 1
    checkFrame.ZIndex = 2
    checkFrame.Parent = parent
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 15, 0, 15)
    checkbox.Position = UDim2.new(0, 0, 0.5, -7.5)
    checkbox.Text = ""
    checkbox.BackgroundColor3 = option.enabled and colors.accent or colors.secondary
    checkbox.BorderColor3 = colors.border
    checkbox.BorderSizePixel = 1
    checkbox.ZIndex = 3
    checkbox.Parent = checkFrame
    createCorner(checkbox, 3)
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.Text = "✓"
    checkmark.TextColor3 = colors.background
    checkmark.Font = Enum.Font.SourceSansBold
    checkmark.TextSize = 10
    checkmark.BackgroundTransparency = 1
    checkmark.Visible = option.enabled
    checkmark.ZIndex = 4
    checkmark.Parent = checkbox
    
    local labelWidth = 1
    if option.hasDropdown and option.hasColorPicker then
        labelWidth = -175
    elseif option.hasDropdown then
        labelWidth = -150
    elseif option.hasColorPicker then
        labelWidth = -50
    else
        labelWidth = -25
    end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, labelWidth, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.Text = option.name
    label.TextColor3 = colors.text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 3
    label.Parent = checkFrame
    
    if option.hasDropdown then
        createMultiDropdown(checkFrame, yPos)
    end
    
    if option.hasColorPicker then
        createColorPicker(checkFrame, yPos)
    end
    
    checkbox.MouseButton1Click:Connect(function()
        option.enabled = not option.enabled
        checkmark.Visible = option.enabled
        checkbox.BackgroundColor3 = option.enabled and colors.accent or colors.secondary
        
        if option.callback then
            option.callback(option.enabled)
        end
        
        print(option.name .. " is now " .. (option.enabled and "enabled" or "disabled"))
    end)
end

-- Функция создания страницы
local function createPage(name, data)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundColor3 = colors.secondary
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = colors.accent
    page.CanvasSize = UDim2.new(0, 0, 0, #data.options * 30 + 20)
    page.Visible = (name == currentTab)
    page.ZIndex = 1
    page.Parent = contentContainer
    createCorner(page, 6)
    
    for i, option in ipairs(data.options) do
        createCheckbox(page, option, (i-1) * 30 + 5)
    end
end

-- Создаем табы и страницы
local tabNames = {"ESP", "Aimbot", "Misc"}
for i, name in ipairs(tabNames) do
    createTab(name, i)
    createPage(name, settings[name])
end

-- Подключаем создание ESP для новых игроков
Players.PlayerAdded:Connect(function(newPlayer)
    if ESPStates.box then CreateBoxESP(newPlayer) end
end)

-- Делаем окно перетаскиваемым
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Анимация появления
mainFrame.Size = UDim2.new(0, 0, 0, 0)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 600, 0, 400)})
tween:Play()

print("Skeet menu с правильной цветовой палитрой загружен!")
