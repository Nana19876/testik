local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старое меню
if playerGui:FindFirstChild("MyCustomGui") then
    playerGui.MyCustomGui:Destroy()
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyCustomGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 700, 0, 320)
mainFrame.Position = UDim2.new(0, 40, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 25, 29)
mainFrame.BorderSizePixel = 0

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Parent = mainFrame
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
sidebar.BorderSizePixel = 0

-- Кнопки и их имена
local buttonNames = {"ESP", "AIMBOT", "AVTOFARM", "MISC", "PROTECTION"}
local buttonRefs = {}

for i, name in ipairs(buttonNames) do
    local btn = Instance.new("TextButton")
    btn.Name = "Button" .. name
    btn.Text = name
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 20 + (i-1)*50)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSans
    btn.Parent = sidebar
    buttonRefs[i] = btn
end

-- Текстовое поле для информации
local textLabel = Instance.new("TextLabel")
textLabel.Name = "InfoLabel"
textLabel.Size = UDim2.new(1, -150, 0, 40)
textLabel.Position = UDim2.new(0, 130, 0, 5)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
textLabel.TextSize = 22
textLabel.Font = Enum.Font.SourceSansSemibold
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Text = "esp player"
textLabel.Parent = mainFrame

-- Палитра цветов (выбери любые)
local colorPalette = {
    Color3.fromRGB(92,135,200), -- синий
    Color3.fromRGB(255,80,80),  -- красный
    Color3.fromRGB(85,200,90),  -- зелёный
    Color3.fromRGB(255,205,70), -- жёлтый
    Color3.fromRGB(140,90,220), -- фиолетовый
    Color3.fromRGB(240,150,70), -- оранжевый
    Color3.fromRGB(80,200,180), -- бирюзовый
    Color3.fromRGB(230,230,230) -- белый/серый
}

-- Функция создания чекбокса "Box"
local function createBoxOption()
    local line = Instance.new("Frame")
    line.Name = "BoxOption"
    line.Parent = mainFrame
    line.Size = UDim2.new(0, 300, 0, 30)
    line.Position = UDim2.new(0, 130, 0, 60)
    line.BackgroundTransparency = 1

    local checkbox = Instance.new("TextButton")
    checkbox.Name = "BoxCheckbox"
    checkbox.Parent = line
    checkbox.Size = UDim2.new(0, 18, 0, 18)
    checkbox.Position = UDim2.new(0, 2, 0, 6)
    checkbox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    checkbox.BorderSizePixel = 1
    checkbox.Text = ""
    checkbox.AutoButtonColor = false

    local check = Instance.new("Frame")
    check.Name = "Check"
    check.Parent = checkbox
    check.Size = UDim2.new(1, -6, 1, -6)
    check.Position = UDim2.new(0, 3, 0, 3)
    check.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
    check.Visible = false

    local label = Instance.new("TextLabel")
    label.Name = "BoxLabel"
    label.Parent = line
    label.Position = UDim2.new(0, 28, 0, 2)
    label.Size = UDim2.new(0, 80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Box"
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left

    local colorBar = Instance.new("TextButton")
    colorBar.Name = "ColorBar"
    colorBar.Parent = line
    colorBar.AnchorPoint = Vector2.new(1, 0)
    colorBar.Position = UDim2.new(1, -6, 0.23, 0)
    colorBar.Size = UDim2.new(0, 28, 0, 12)
    colorBar.BackgroundColor3 = colorPalette[1]
    colorBar.BorderSizePixel = 0
    colorBar.BackgroundTransparency = 0.15
    colorBar.ZIndex = 2
    colorBar.Text = ""

    -- Логика чекбокса
    local toggled = false
    checkbox.MouseButton1Click:Connect(function()
        toggled = not toggled
        check.Visible = toggled
        print("Box toggled:", toggled)
    end)

    -- Color palette pop-up
    local paletteFrame = nil
    colorBar.MouseButton1Click:Connect(function()
        if paletteFrame and paletteFrame.Parent then
            paletteFrame:Destroy()
            paletteFrame = nil
            return
        end

        paletteFrame = Instance.new("Frame")
        paletteFrame.Size = UDim2.new(0, 180, 0, 38)
        paletteFrame.Position = UDim2.new(0, colorBar.AbsolutePosition.X, 0, colorBar.AbsolutePosition.Y + 18)
        paletteFrame.BackgroundColor3 = Color3.fromRGB(36,36,36)
        paletteFrame.BorderSizePixel = 0
        paletteFrame.ZIndex = 20
        paletteFrame.Parent = screenGui

        -- Показываем все цвета в палитре
        for i, col in ipairs(colorPalette) do
            local colorBtn = Instance.new("TextButton")
            colorBtn.Size = UDim2.new(0, 34, 0, 34)
            colorBtn.Position = UDim2.new(0, 8 + (i-1)*40, 0, 2)
            colorBtn.BackgroundColor3 = col
            colorBtn.BorderSizePixel = 0
            colorBtn.ZIndex = 21
            colorBtn.Text = ""
            colorBtn.Parent = paletteFrame

            colorBtn.MouseButton1Click:Connect(function()
                colorBar.BackgroundColor3 = col
                paletteFrame:Destroy()
                paletteFrame = nil
            end)
        end
    end)

    -- Если клик вне палитры — закрываем её
    game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
        if paletteFrame and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            local absPos = paletteFrame.AbsolutePosition
            local absSize = paletteFrame.AbsoluteSize
            if not (mouse.X >= absPos.X and mouse.X <= absPos.X + absSize.X and mouse.Y >= absPos.Y and mouse.Y <= absPos.Y + absSize.Y) then
                paletteFrame:Destroy()
                paletteFrame = nil
            end
        end
    end)

    line.Visible = false -- по умолчанию скрыт
    return line
end

-- Создаём чекбокс один раз
local boxOption = createBoxOption()

-- Кнопки переключения вкладок
local labelTexts = {
    "esp player",
    "aimbot info here",
    "avtofarm info here",
    "misc info here",
    "protection info here"
}
for i, btn in ipairs(buttonRefs) do
    btn.MouseButton1Click:Connect(function()
        textLabel.Text = labelTexts[i]
        if i == 1 then
            boxOption.Visible = true
        else
            boxOption.Visible = false
        end
    end)
end

-- По умолчанию показываем чекбокс и вкладку ESP
textLabel.Text = labelTexts[1]
boxOption.Visible = true
