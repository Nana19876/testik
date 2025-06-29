-- LocalScript для StarterPlayerScripts или StarterGui

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("SkeetMenu") then
    playerGui.SkeetMenu:Destroy()
end

local skeetGui = Instance.new("ScreenGui")
skeetGui.Name = "SkeetMenu"
skeetGui.Parent = playerGui
skeetGui.ResetOnSpawn = false

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0, 100, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = skeetGui

-- Боковая панель с одной иконкой (Настройки)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 60, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
sidebar.Parent = mainFrame

local miscIcon = Instance.new("TextButton")
miscIcon.Size = UDim2.new(1, 0, 0, 48)
miscIcon.Position = UDim2.new(0, 0, 0, 8)
miscIcon.BackgroundTransparency = 1
miscIcon.Text = "⚙️"
miscIcon.Font = Enum.Font.SourceSansBold
miscIcon.TextSize = 32
miscIcon.TextColor3 = Color3.fromRGB(160, 200, 160)
miscIcon.Parent = sidebar

-- Окно настроек
local settingsPage = Instance.new("Frame")
settingsPage.Size = UDim2.new(1, -68, 1, -20)
settingsPage.Position = UDim2.new(0, 68, 0, 10)
settingsPage.BackgroundTransparency = 1
settingsPage.Parent = mainFrame

-- Заголовок
local sectionTitle = Instance.new("TextLabel")
sectionTitle.Size = UDim2.new(1, 0, 0, 30)
sectionTitle.Position = UDim2.new(0, 10, 0, 0)
sectionTitle.BackgroundTransparency = 1
sectionTitle.Text = "Settings"
sectionTitle.Font = Enum.Font.SourceSansBold
sectionTitle.TextSize = 28
sectionTitle.TextColor3 = Color3.fromRGB(170, 255, 170)
sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
sectionTitle.Parent = settingsPage

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

makeCheckbox(settingsPage, "Accuracy boost", 50, true)
makeCheckbox(settingsPage, "Automatic fire", 80, false)
makeCheckbox(settingsPage, "Silent aim", 110, false)
makeCheckbox(settingsPage, "Remove recoil", 140, false)
makeCheckbox(settingsPage, "Quick peek assist", 170, false)

-- Дропдаун (для выбора режима)
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

makeDropdown(settingsPage, "Accuracy boost:", 220, {"Minimum", "Medium", "Maximum"}, 1)
makeDropdown(settingsPage, "FOV:", 260, {"Low", "Medium", "High"}, 2)

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

makeSlider(settingsPage, "Maximum FOV:", 300, 0, 180, 90)

-- Открытие/скрытие меню по клавише M
local UIS = game:GetService("UserInputService")
local open = true
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then
        open = not open
        skeetGui.Enabled = open
    end
end)

-- Готово! Остальное (color picker и т.д.) можно добавить аналогично!
