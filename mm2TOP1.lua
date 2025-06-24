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
    colorBar.BackgroundColor3 = Color3.fromRGB(92, 135, 200)
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

    -- Цвет
    local lastColor = Color3.fromRGB(92, 135, 200)
    local userInput = game:GetService("UserInputService")

    local picker = nil
    local function openColorPicker()
        if picker and picker.Parent then
            picker:Destroy()
        end
        picker = Instance.new("Frame")
        picker.Size = UDim2.new(0, 200, 0, 200)
        picker.Position = UDim2.new(0, colorBar.AbsolutePosition.X, 0, colorBar.AbsolutePosition.Y + 20)
        picker.BackgroundColor3 = Color3.fromRGB(40,40,40)
        picker.BorderSizePixel = 0
        picker.Parent = screenGui

        -- Простая RGB палитра (3 ползунка)
        local values = {"R","G","B"}
        local current = {lastColor.R*255,lastColor.G*255,lastColor.B*255}
        local sliders = {}
        for i,v in ipairs(values) do
            local s = Instance.new("TextLabel")
            s.Size = UDim2.new(0,30,0,24)
            s.Position = UDim2.new(0,10,0,(i-1)*60+12)
            s.Text = v
            s.TextColor3 = Color3.fromRGB(220,220,220)
            s.BackgroundTransparency = 1
            s.Parent = picker

            local slider = Instance.new("TextButton")
            slider.Size = UDim2.new(0,130,0,22)
            slider.Position = UDim2.new(0,50,0,(i-1)*60+14)
            slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
            slider.Text = tostring(math.floor(current[i]))
            slider.TextColor3 = Color3.fromRGB(220,220,255)
            slider.Font = Enum.Font.SourceSans
            slider.TextSize = 16
            slider.BorderSizePixel = 0
            slider.Parent = picker

            slider.MouseButton1Click:Connect(function()
                local val = tonumber(game:GetService("StarterGui"):PromptInput("Input "..v.." (0-255)",tostring(math.floor(current[i]))))
                if val and val >= 0 and val <= 255 then
                    current[i] = val
                    slider.Text = tostring(val)
                    local col = Color3.fromRGB(current[1],current[2],current[3])
                    colorBar.BackgroundColor3 = col
                    lastColor = col
                end
            end)
            sliders[i] = slider
        end

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0,70,0,30)
        closeBtn.Position = UDim2.new(0,115,0,160)
        closeBtn.Text = "Close"
        closeBtn.Parent = picker
        closeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        closeBtn.TextColor3 = Color3.fromRGB(220,220,255)
        closeBtn.Font = Enum.Font.SourceSans
        closeBtn.TextSize = 18
        closeBtn.MouseButton1Click:Connect(function()
            picker:Destroy()
        end)
    end

    colorBar.MouseButton1Click:Connect(openColorPicker)

    line.Visible = false -- по умолчанию скрыт
    return line
end

-- Создаём один раз
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
        -- Только на вкладке ESP показываем чекбокс
        if i == 1 then
            boxOption.Visible = true
        else
            boxOption.Visible = false
        end
    end)
end

-- При запуске сразу показываем ESP и чекбокс
textLabel.Text = labelTexts[1]
boxOption.Visible = true
