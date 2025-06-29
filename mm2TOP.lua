-- LocalScript, вставь в StarterPlayerScripts или StarterGui

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем прошлое меню если что
if playerGui:FindFirstChild("SkeetMenu") then
    playerGui.SkeetMenu:Destroy()
end

local skeetGui = Instance.new("ScreenGui")
skeetGui.Name = "SkeetMenu"
skeetGui.Parent = playerGui
skeetGui.ResetOnSpawn = false

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 720, 0, 480)
mainFrame.Position = UDim2.new(0, 100, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = skeetGui

-- Левое меню с иконками
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 60, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
sidebar.Parent = mainFrame

local iconLabels = {}
local iconList = {
    {Name="Aimbot", Icon="🎯"},
    {Name="Visuals", Icon="👁️"},
    {Name="Misc", Icon="⚙️"},
    {Name="Configs", Icon="🗂️"},
}

for i, iconData in ipairs(iconList) do
    local icon = Instance.new("TextButton")
    icon.Size = UDim2.new(1, 0, 0, 48)
    icon.Position = UDim2.new(0, 0, 0, 8 + (i-1)*56)
    icon.BackgroundTransparency = 1
    icon.Text = iconData.Icon
    icon.Font = Enum.Font.SourceSansBold
    icon.TextSize = 32
    icon.TextColor3 = Color3.fromRGB(160, 200, 160)
    icon.Parent = sidebar
    iconLabels[#iconLabels+1] = icon
end

-- Панели (разделы) меню
local pages = {}

for i, nameData in ipairs(iconList) do
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -68, 1, -20)
    page.Position = UDim2.new(0, 68, 0, 10)
    page.BackgroundTransparency = 1
    page.Visible = i == 1
    page.Parent = mainFrame
    pages[#pages+1] = page
end

-- Переключение страниц
for i, icon in ipairs(iconLabels) do
    icon.MouseButton1Click:Connect(function()
        for j, page in ipairs(pages) do
            page.Visible = (j == i)
        end
    end)
end

---------------------------------------------------------
-- Пример наполнения для страницы "Aimbot"
local aimbotPage = pages[1]

local sectionTitle = Instance.new("TextLabel")
sectionTitle.Size = UDim2.new(1, 0, 0, 30)
sectionTitle.Position = UDim2.new(0, 10, 0, 0)
sectionTitle.BackgroundTransparency = 1
sectionTitle.Text = "Aimbot"
sectionTitle.Font = Enum.Font.SourceSansBold
sectionTitle.TextSize = 28
sectionTitle.TextColor3 = Color3.fromRGB(170, 255, 170)
sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
sectionTitle.Parent = aimbotPage

-- Чекбокс
local function makeCheckbox(parent, label, y, default)
    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 22, 0, 22)
    box.Position = UDim2.new(0, 10, 0, y)
    box.BackgroundColor3 = default and Color3.fromRGB(60,200,60) or Color3.fromRGB(40,40,40)
    box.Text = ""
    box.Parent = parent
    local state = default
    box.MouseButton1Click:Connect(function()
        state = not state
        box.BackgroundColor3 = state and Color3.fromRGB(60,200,60) or Color3.fromRGB(40,40,40)
    end)
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(0, 200, 0, 22)
    lab.Position = UDim2.new(0, 40, 0, 0)
    lab.BackgroundTransparency = 1
    lab.Text = label
    lab.Font = Enum.Font.SourceSans
    lab.TextSize = 21
    lab.TextColor3 = Color3.fromRGB(220,220,220)
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Parent = box
    return function() return state end
end

makeCheckbox(aimbotPage, "Enabled", 50, true)
makeCheckbox(aimbotPage, "Silent Aim", 80, false)
makeCheckbox(aimbotPage, "Aim Through Walls", 110, false)

-- Дропдаун (Head/Body/Legs)
local function makeDropdown(parent, label, y, options, default)
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(0, 120, 0, 22)
    lab.Position = UDim2.new(0, 10, 0, y)
    lab.BackgroundTransparency = 1
    lab.Text = label
    lab.Font = Enum.Font.SourceSans
    lab.TextSize = 21
    lab.TextColor3 = Color3.fromRGB(220,220,220)
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Parent = parent

    local drop = Instance.new("TextButton")
    drop.Size = UDim2.new(0, 90, 0, 22)
    drop.Position = UDim2.new(0, 140, 0, y)
    drop.BackgroundColor3 = Color3.fromRGB(50,50,50)
    drop.Text = options[default]
    drop.Font = Enum.Font.SourceSans
    drop.TextSize = 19
    drop.TextColor3 = Color3.fromRGB(180,255,180)
    drop.Parent = parent

    local cur = default
    drop.MouseButton1Click:Connect(function()
        cur = cur % #options + 1
        drop.Text = options[cur]
    end)
    return function() return options[cur] end
end

makeDropdown(aimbotPage, "Hit Point:", 150, {"Head","Body","Legs"}, 1)

-- Ползунок
local function makeSlider(parent, label, y, min, max, default)
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(0, 180, 0, 22)
    lab.Position = UDim2.new(0, 10, 0, y)
    lab.BackgroundTransparency = 1
    lab.Text = label
    lab.Font = Enum.Font.SourceSans
    lab.TextSize = 21
    lab.TextColor3 = Color3.fromRGB(220,220,220)
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Parent = parent

    local slideBg = Instance.new("Frame")
    slideBg.Size = UDim2.new(0, 150, 0, 6)
    slideBg.Position = UDim2.new(0, 190, 0, y + 8)
    slideBg.BackgroundColor3 = Color3.fromRGB(40,60,40)
    slideBg.Parent = parent

    local slideKnob = Instance.new("Frame")
    slideKnob.Size = UDim2.new(0, 10, 0, 18)
    slideKnob.Position = UDim2.new(0, (default-min)/(max-min)*140, 0, -6)
    slideKnob.BackgroundColor3 = Color3.fromRGB(130,255,130)
    slideKnob.Parent = slideBg
    slideKnob.BorderSizePixel = 0

    local val = default

    slideBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local moveConn
            moveConn = game:GetService("UserInputService").InputChanged:Connect(function(changed)
                if changed.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((changed.Position.X - slideBg.AbsolutePosition.X) / (slideBg.AbsoluteSize.X-10), 0, 1)
                    slideKnob.Position = UDim2.new(0, rel*140, 0, -6)
                    val = math.floor((min + (max-min)*rel)*10)/10
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(ended)
                if ended.UserInputType == Enum.UserInputType.MouseButton1 then
                    if moveConn then moveConn:Disconnect() end
                end
            end)
        end
    end)
    return function() return val end
end

makeSlider(aimbotPage, "Minimum hit chance:", 200, 0, 100, 85)

---------------------------------------------------------

-- Страницу Visuals/ESP/Color Picker, Misc и Configs делай аналогично — могу расписать детали под любые функции!

-- Открытие/скрытие меню по клавише (например, M)
local UIS = game:GetService("UserInputService")
local open = true
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then
        open = not open
        skeetGui.Enabled = open
    end
end)

---------------------------------------------------------

-- Всё готово! Меню поддерживает:
-- - Иконки слева (разделы)
-- - Несколько страниц
-- - Группы настроек: чекбокс, дропдаун, слайдер
-- - Современный стиль

-- Остальное (цветовую палитру, ESP, визуал и т.д.) добавим по аналогии.
