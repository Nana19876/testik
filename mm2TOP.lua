local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старое меню
if playerGui:FindFirstChild("MyCustomGui") then
    playerGui.MyCustomGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyCustomGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Основной интерфейс
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 700, 0, 320)
mainFrame.Position = UDim2.new(0, 40, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
mainFrame.BorderSizePixel = 0

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Parent = mainFrame
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 37)
sidebar.BorderSizePixel = 0

local buttonNames = {"ESP", "AIMBOT", "AVTOFARM", "MISC", "PROTECTION"}
local buttonRefs = {}

for i, name in ipairs(buttonNames) do
    local btn = Instance.new("TextButton")
    btn.Name = "Button" .. name
    btn.Text = name
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 20 + (i-1)*50)
    btn.BackgroundColor3 = Color3.fromRGB(37, 37, 55)
    btn.TextColor3 = Color3.fromRGB(229, 231, 235)
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSans
    btn.Parent = sidebar
    buttonRefs[i] = btn
end

local textLabel = Instance.new("TextLabel")
textLabel.Name = "InfoLabel"
textLabel.Size = UDim2.new(1, -150, 0, 40)
textLabel.Position = UDim2.new(0, 130, 0, 5)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(165, 180, 252)
textLabel.TextSize = 22
textLabel.Font = Enum.Font.SourceSansSemibold
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Text = "esp player"
textLabel.Parent = mainFrame

-- Box checkbox и colorBar
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
    checkbox.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
    checkbox.BorderSizePixel = 1
    checkbox.Text = ""
    checkbox.AutoButtonColor = false

    local check = Instance.new("Frame")
    check.Name = "Check"
    check.Parent = checkbox
    check.Size = UDim2.new(1, -6, 1, -6)
    check.Position = UDim2.new(0, 3, 0, 3)
    check.BackgroundColor3 = Color3.fromRGB(75, 158, 251)
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
    colorBar.BackgroundColor3 = Color3.fromRGB(96, 165, 250)
    colorBar.BorderSizePixel = 0
    colorBar.BackgroundTransparency = 0.15
    colorBar.ZIndex = 2
    colorBar.Text = ""

    -- Чекбокс логика
    local toggled = false
    checkbox.MouseButton1Click:Connect(function()
        toggled = not toggled
        check.Visible = toggled
        print("Box toggled:", toggled)
    end)

    -- === Color Picker ===
    local pickerFrame = nil
    local function openColorPicker()
        if pickerFrame and pickerFrame.Parent then
            pickerFrame:Destroy()
            pickerFrame = nil
            return
        end

        pickerFrame = Instance.new("Frame")
        pickerFrame.Size = UDim2.new(0, 250, 0, 200)
        pickerFrame.Position = UDim2.new(0, colorBar.AbsolutePosition.X, 0, colorBar.AbsolutePosition.Y + 16)
        pickerFrame.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
        pickerFrame.BorderSizePixel = 0
        pickerFrame.ZIndex = 30
        pickerFrame.Parent = screenGui

        -- HSV Color Wheel
        local colorWheel = Instance.new("ImageLabel")
        colorWheel.Size = UDim2.new(0, 150, 0, 150)
        colorWheel.Position = UDim2.new(0, 10, 0, 10)
        colorWheel.BackgroundTransparency = 1
        colorWheel.Image = "rbxassetid://14685689696" -- Замени на свой цветовой круг, если нужно
        colorWheel.ZIndex = 31
        colorWheel.Parent = pickerFrame

        -- Cursor for color wheel
        local wheelCursor = Instance.new("Frame")
        wheelCursor.Size = UDim2.new(0, 10, 0, 10)
        wheelCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        wheelCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        wheelCursor.BorderColor3 = Color3.new(0, 0, 0)
        wheelCursor.BorderSizePixel = 1
        wheelCursor.Position = UDim2.new(0, 75, 0, 75) -- Центр по умолчанию
        wheelCursor.ZIndex = 32
        wheelCursor.Parent = pickerFrame

        -- Hue Slider
        local hueSlider = Instance.new("Frame")
        hueSlider.Size = UDim2.new(0, 150, 0, 14)
        hueSlider.Position = UDim2.new(0, 10, 0, 170)
        hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueSlider.BorderSizePixel = 0
        hueSlider.ZIndex = 31
        hueSlider.Parent = pickerFrame

        local hueImg = Instance.new("ImageLabel")
        hueImg.Size = UDim2.new(1, 0, 1, 0)
        hueImg.Position = UDim2.new(0, 0, 0, 0)
        hueImg.Image = "rbxassetid://14685692143" -- Горизонтальный радужный градиент
        hueImg.BackgroundTransparency = 1
        hueImg.ZIndex = 32
        hueImg.Parent = hueSlider

        -- Hue Slider Cursor
        local hueCursor = Instance.new("Frame")
        hueCursor.Size = UDim2.new(0, 5, 0, 14)
        hueCursor.Position = UDim2.new(0, 0, 0, 0)
        hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        hueCursor.BorderSizePixel = 1
        hueCursor.ZIndex = 33
        hueCursor.Parent = hueSlider

        -- Value/Saturation Gradient
        local svGradient = Instance.new("ImageLabel")
        svGradient.Size = UDim2.new(0, 150, 0, 150)
        svGradient.Position = UDim2.new(0, 10, 0, 10)
        svGradient.BackgroundTransparency = 1
        svGradient.Image = "rbxassetid://14685689696" -- Замени на градиент S/V
        svGradient.Visible = false -- Используем цветовой круг для начальной настройки
        svGradient.ZIndex = 31
        svGradient.Parent = pickerFrame

        local selectedColor = Color3.fromRGB(96, 165, 250)

        local function updateColor(h, s, v)
            local color = Color3.fromHSV(h, s, v)
            colorBar.BackgroundColor3 = color
            selectedColor = color
            wheelCursor.BackgroundColor3 = color
        end

        -- Обработка кликов по цветовому кругу
        colorWheel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position - colorWheel.AbsolutePosition
                local x, y = pos.X, pos.Y
                x = math.clamp(x, 0, 149)
                y = math.clamp(y, 0, 149)
                local h = (x / 150) * 360 / 360
                local s = 1 - (y / 150)
                local v = 1
                updateColor(h, s, v)
                wheelCursor.Position = UDim2.new(0, x, 0, y)
            end
        end)

        -- Обработка кликов по hueSlider
        hueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position - hueSlider.AbsolutePosition
                local hx = math.clamp(pos.X, 0, 149) / 149
                hueCursor.Position = UDim2.new(0, hx * 150, 0, 0)
                updateColor(hx, 1, 1)
            end
        end)

        -- Кнопка закрытия
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 55, 0, 25)
        closeBtn.Position = UDim2.new(0, 185, 0, 8)
        closeBtn.Text = "X"
        closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
        closeBtn.Font = Enum.Font.SourceSans
        closeBtn.TextSize = 20
        closeBtn.ZIndex = 40
        closeBtn.Parent = pickerFrame
        closeBtn.MouseButton1Click:Connect(function()
            pickerFrame:Destroy()
        end)
    end

    colorBar.MouseButton1Click:Connect(openColorPicker)

    line.Visible = false -- по умолчанию скрыт
    return line
end

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

textLabel.Text = labelTexts[1]
boxOption.Visible = true
