-- LocalScript
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "SkeetMenu"
gui.ResetOnSpawn = false

-- Цвета в стиле skeet
local colors = {
    background = Color3.fromRGB(17, 17, 17),
    secondary = Color3.fromRGB(25, 25, 25),
    accent = Color3.fromRGB(165, 194, 97), -- Зеленый skeet
    text = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(180, 180, 180),
    border = Color3.fromRGB(60, 60, 60),
    hover = Color3.fromRGB(35, 35, 35)
}

-- Настройки
local settings = {
    ESP = {
        title = "ESP",
        options = {
            {name = "Box ESP", enabled = false},
            {name = "Name ESP", enabled = false},
            {name = "Health ESP", enabled = false},
            {name = "Distance ESP", enabled = false},
            {name = "Tracers", enabled = false},
            {name = "Chams", enabled = false},
            {name = "Glow ESP", enabled = false},
            {name = "Skeleton ESP", enabled = false}
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
            {name = "Bunny Hop", enabled = false},
            {name = "Auto Strafe", enabled = false},
            {name = "No Recoil", enabled = false},
            {name = "Infinite Ammo", enabled = false}
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

-- Функция для создания градиента
local function createGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    }
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

-- Функция для создания тени
local function createShadow(parent)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Parent = parent.Parent
    shadow.Size = parent.Size + UDim2.new(0, 10, 0, 10)
    shadow.Position = parent.Position + UDim2.new(0, 5, 0, 5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = parent.ZIndex - 1
    createCorner(shadow, 8)
    return shadow
end

-- Главный фрейм
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 650, 0, 500)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 2
createCorner(mainFrame, 8)
createShadow(mainFrame)

-- Заголовок
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = colors.secondary
titleBar.BorderSizePixel = 0
createCorner(titleBar, 8)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0, 200, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.Text = "skeet.cc"
titleText.TextColor3 = colors.accent
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1

-- Кнопка закрытия
local closeButton = Instance.new("TextButton", titleBar)
closeButton.Size = UDim2.new(0, 30, 0, 25)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "×"
closeButton.TextColor3 = colors.text
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
createCorner(closeButton, 4)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Контейнер для табов
local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1

-- Контейнер для контента
local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.Size = UDim2.new(1, -20, 1, -95)
contentContainer.Position = UDim2.new(0, 10, 0, 85)
contentContainer.BackgroundTransparency = 1

-- Функция создания таба
local function createTab(name, index)
    local tabCount = 0
    for _ in pairs(settings) do tabCount = tabCount + 1 end
    
    local tabButton = Instance.new("TextButton", tabContainer)
    tabButton.Size = UDim2.new(1/tabCount, -5, 1, 0)
    tabButton.Position = UDim2.new((index-1)/tabCount, (index-1)*5, 0, 0)
    tabButton.Text = name
    tabButton.TextColor3 = (name == currentTab) and colors.accent or colors.textSecondary
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 14
    tabButton.BackgroundColor3 = (name == currentTab) and colors.secondary or colors.background
    tabButton.BorderSizePixel = 0
    createCorner(tabButton, 6)
    
    -- Анимация при наведении
    tabButton.MouseEnter:Connect(function()
        if name ~= currentTab then
            tabButton.BackgroundColor3 = colors.hover
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if name ~= currentTab then
            tabButton.BackgroundColor3 = colors.background
        end
    end)
    
    tabButton.MouseButton1Click:Connect(function()
        -- Обновляем все табы
        for _, child in pairs(tabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = colors.textSecondary
                child.BackgroundColor3 = colors.background
            end
        end
        
        -- Активируем текущий таб
        tabButton.TextColor3 = colors.accent
        tabButton.BackgroundColor3 = colors.secondary
        currentTab = name
        
        -- Показываем соответствующий контент
        for _, page in pairs(contentContainer:GetChildren()) do
            if page:IsA("Frame") then
                page.Visible = (page.Name == name .. "Page")
            end
        end
    end)
end

-- Функция создания чекбокса
local function createCheckbox(parent, option, yPos)
    local checkFrame = Instance.new("Frame", parent)
    checkFrame.Size = UDim2.new(1, -20, 0, 30)
    checkFrame.Position = UDim2.new(0, 10, 0, yPos)
    checkFrame.BackgroundTransparency = 1
    
    local checkbox = Instance.new("TextButton", checkFrame)
    checkbox.Size = UDim2.new(0, 18, 0, 18)
    checkbox.Position = UDim2.new(0, 0, 0.5, -9)
    checkbox.Text = ""
    checkbox.BackgroundColor3 = colors.secondary
    checkbox.BorderColor3 = colors.border
    checkbox.BorderSizePixel = 1
    createCorner(checkbox, 3)
    
    local checkmark = Instance.new("TextLabel", checkbox)
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.Text = "✓"
    checkmark.TextColor3 = colors.accent
    checkmark.Font = Enum.Font.GothamBold
    checkmark.TextSize = 12
    checkmark.BackgroundTransparency = 1
    checkmark.Visible = option.enabled
    
    local label = Instance.new("TextLabel", checkFrame)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 25, 0, 0)
    label.Text = option.name
    label.TextColor3 = colors.text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    checkbox.MouseButton1Click:Connect(function()
        option.enabled = not option.enabled
        checkmark.Visible = option.enabled
        checkbox.BackgroundColor3 = option.enabled and colors.accent or colors.secondary
        
        -- Здесь можно добавить логику для включения/выключения функций
        print(option.name .. " is now " .. (option.enabled and "enabled" or "disabled"))
    end)
end

-- Функция создания страницы
local function createPage(name, data)
    local page = Instance.new("ScrollingFrame", contentContainer)
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundColor3 = colors.secondary
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.ScrollBarImageColor3 = colors.accent
    page.CanvasSize = UDim2.new(0, 0, 0, #data.options * 35 + 20)
    page.Visible = (name == currentTab)
    createCorner(page, 6)
    
    for i, option in ipairs(data.options) do
        createCheckbox(page, option, (i-1) * 35 + 10)
    end
end

-- Создаем табы и страницы
local tabIndex = 1
for name, data in pairs(settings) do
    createTab(name, tabIndex)
    createPage(name, data)
    tabIndex = tabIndex + 1
end

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

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Анимация появления
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame:TweenSize(UDim2.new(0, 650, 0, 500), "Out", "Quart", 0.3, true)

print("Skeet menu loaded successfully!")
