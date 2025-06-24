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

-- ESP переменные
local ESPs = {}
local ESPConnection = nil
local ESPEnabled = false

-- ESP функции
function CreateESP(targetPlayer)
    if targetPlayer == player then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Visible = false

    ESPs[targetPlayer] = box

    targetPlayer.CharacterAdded:Connect(function()
        if ESPs[targetPlayer] then
            ESPs[targetPlayer] = box
        end
    end)
end

function UpdateESP()
    if not ESPEnabled then return end
    
    for targetPlayer, box in pairs(ESPs) do
        if targetPlayer and targetPlayer.Parent then
            local character = targetPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local pos, onscreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onscreen then
                    local size = Vector2.new(80, 120)
                    box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    box.Size = size
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
    end
end

function EnableESP()
    ESPEnabled = true
    -- Создаем ESP для всех игроков
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        CreateESP(targetPlayer)
    end
    -- Подключаем обновление
    if not ESPConnection then
        ESPConnection = RunService.RenderStepped:Connect(UpdateESP)
    end
    print("ESP включен")
end

function DisableESP()
    ESPEnabled = false
    -- Скрываем все ESP
    for _, box in pairs(ESPs) do
        if box then
            box.Visible = false
            box:Remove()
        end
    end
    ESPs = {}
    -- Отключаем обновление
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    print("ESP выключен")
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

-- Настройки
local settings = {
    ESP = {
        title = "ESP",
        options = {
            {name = "box", enabled = false, callback = function(enabled)
                if enabled then
                    EnableESP()
                else
                    DisableESP()
                end
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
    DisableESP() -- Выключаем ESP при закрытии меню
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
    local tabCount = 3 -- ESP, Aimbot, Misc
    
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
            if page:IsA("ScrollingFrame") then
                page.Visible = (page.Name == name .. "Page")
            end
        end
    end)
end

-- Функция создания чекбокса
local function createCheckbox(parent, option, yPos)
    local checkFrame = Instance.new("Frame")
    checkFrame.Size = UDim2.new(1, -10, 0, 25)
    checkFrame.Position = UDim2.new(0, 5, 0, yPos)
    checkFrame.BackgroundTransparency = 1
    checkFrame.Parent = parent
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 15, 0, 15)
    checkbox.Position = UDim2.new(0, 0, 0.5, -7.5)
    checkbox.Text = ""
    checkbox.BackgroundColor3 = option.enabled and colors.accent or colors.secondary
    checkbox.BorderColor3 = colors.border
    checkbox.BorderSizePixel = 1
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
    checkmark.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -25, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.Text = option.name
    label.TextColor3 = colors.text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = checkFrame
    
    checkbox.MouseButton1Click:Connect(function()
        option.enabled = not option.enabled
        checkmark.Visible = option.enabled
        checkbox.BackgroundColor3 = option.enabled and colors.accent or colors.secondary
        
        -- Вызываем callback если есть
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
    if ESPEnabled then
        CreateESP(newPlayer)
    end
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

print("Skeet menu with ESP loaded successfully!")
