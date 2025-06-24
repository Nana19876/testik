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

-- Основной интерфейс и чекбокс — как в прошлых примерах
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 700, 0, 320)
mainFrame.Position = UDim2.new(0, 40, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 25, 29)
mainFrame.BorderSizePixel = 0

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Parent = mainFrame
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
sidebar.BorderSizePixel = 0

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
    colorBar.BackgroundColor3 = Color3.fromRGB(92,135,200)
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
        pickerFrame.Size = UDim2.new(0, 230, 0, 190)
        pickerFrame.Position = UDim2.new(0, colorBar.AbsolutePosition.X, 0, colorBar.AbsolutePosition.Y + 16)
        pickerFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
        pickerFrame.BorderSizePixel = 0
        pickerFrame.ZIndex = 30
        pickerFrame.Parent = screenGui

        -- Градиент HSV квадрат
        local grad = Instance.new("ImageLabel")
        grad.Size = UDim2.new(0, 150, 0, 150)
        grad.Position = UDim2.new(0, 15, 0, 10)
        grad.BackgroundTransparency = 1
        grad.Image = "rbxassetid://14685689696" -- твой ассет или https://i.imgur.com/6ITmFRX.png, можно залить свой!
        grad.ZIndex = 31
        grad.Parent = pickerFrame

        -- Курсор на градиенте
        local selDot = Instance.new("Frame")
        selDot.Size = UDim2.new(0,10,0,10)
        selDot.AnchorPoint = Vector2.new(0.5,0.5)
        selDot.BackgroundColor3 = Color3.new(1,1,1)
        selDot.BorderColor3 = Color3.new(0,0,0)
        selDot.BorderSizePixel = 1
        selDot.Position = UDim2.new(0,150,0,10)
        selDot.ZIndex = 32
        selDot.Parent = pickerFrame

        -- Hue-bar (радуга)
        local hueBar = Instance.new("Frame")
        hueBar.Size = UDim2.new(0, 150, 0, 14)
        hueBar.Position = UDim2.new(0, 15, 0, 170)
        hueBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
        hueBar.BorderSizePixel = 0
        hueBar.ZIndex = 31
        hueBar.Parent = pickerFrame

        local hueImg = Instance.new("ImageLabel")
        hueImg.Size = UDim2.new(1,0,1,0)
        hueImg.Position = UDim2.new(0,0,0,0)
        hueImg.Image = "rbxassetid://14685692143" -- горизонтальный радужный градиент, или залей свой!
        hueImg.BackgroundTransparency = 1
        hueImg.ZIndex = 32
        hueImg.Parent = hueBar

        -- Слушатели клика по градиенту и hueBar
        local selectedColor = Color3.fromRGB(92,135,200)

        local function setBarColor(h,s,v)
            local c = Color3.fromHSV(h,s,v)
            colorBar.BackgroundColor3 = c
            selectedColor = c
        end

        grad.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position - grad.AbsolutePosition
                local gx, gy = pos.X, pos.Y
                gx = math.clamp(gx, 0, 149)
                gy = math.clamp(gy, 0, 149)
                -- h берём от hueBar, s — gx/149, v — 1-gy/149
                local h = 0
                if hueBar:FindFirstChild("currentHue") then
                    h = hueBar.currentHue.Value
                end
                local s = gx / 149
                local v = 1 - (gy / 149)
                setBarColor(h,s,v)
                selDot.Position = UDim2.new(0, gx, 0, gy)
            end
        end)

        -- Hue-Value (слайдер)
        local hueValue = Instance.new("NumberValue")
        hueValue.Name = "currentHue"
        hueValue.Value = 0.55 -- синий по умолчанию
        hueValue.Parent = hueBar

        hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position - hueBar.AbsolutePosition
                local hx = math.clamp(pos.X, 0, 149) / 149
                hueValue.Value = hx
                setBarColor(hx,0.8,0.8)
            end
        end)

        -- Кнопка закрытия
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 55, 0, 25)
        closeBtn.Position = UDim2.new(0, 175, 0, 8)
        closeBtn.Text = "X"
        closeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        closeBtn.TextColor3 = Color3.fromRGB(220,220,255)
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
