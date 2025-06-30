local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
mainFrame.Size = UDim2.new(0, 350, 0, 220)
mainFrame.Position = UDim2.new(0, 60, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Parent = skeetGui

-- Сайдбар
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 60, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
sidebar.BackgroundTransparency = 0.25
sidebar.Parent = mainFrame

local miscIcon = Instance.new("TextButton")
miscIcon.Size = UDim2.new(1, 0, 0, 48)
miscIcon.Position = UDim2.new(0, 0, 0, 8)
miscIcon.BackgroundTransparency = 1
miscIcon.Text = "⭐"
miscIcon.Font = Enum.Font.SourceSansBold
miscIcon.TextSize = 32
miscIcon.TextColor3 = Color3.fromRGB(240, 200, 90)
miscIcon.Parent = sidebar

-- avto farm чекбокс + текст
local checkbox = Instance.new("TextButton")
checkbox.Size = UDim2.new(0, 18, 0, 18)
checkbox.Position = UDim2.new(0, 76, 0, 16)
checkbox.BackgroundColor3 = Color3.fromRGB(34, 34, 36)
checkbox.BackgroundTransparency = 0.1
checkbox.BorderSizePixel = 2
checkbox.BorderColor3 = Color3.fromRGB(220, 220, 220)
checkbox.Text = ""
checkbox.AutoButtonColor = true
checkbox.Parent = mainFrame

local isEnabled = false

local boxIndicator = Instance.new("Frame")
boxIndicator.Size = UDim2.new(1, -6, 1, -6)
boxIndicator.Position = UDim2.new(0, 3, 0, 3)
boxIndicator.BackgroundColor3 = Color3.fromRGB(85, 210, 120)
boxIndicator.BackgroundTransparency = 0.25
boxIndicator.Visible = false
boxIndicator.BorderSizePixel = 0
boxIndicator.Parent = checkbox

local label = Instance.new("TextButton")
label.Size = UDim2.new(0, 200, 0, 18)
label.Position = UDim2.new(0, 104, 0, 16)
label.BackgroundTransparency = 1
label.Text = "avto farm"
label.Font = Enum.Font.SourceSans
label.TextSize = 19
label.TextColor3 = Color3.fromRGB(220,220,220)
label.TextXAlignment = Enum.TextXAlignment.Left
label.AutoButtonColor = false
label.Parent = mainFrame

-- Dropdown меню ("metod")
local dropdownWidth = 120
local dropdownHeight = 85
local dropdownX = 76
local dropdownY = 40

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight)
dropdownFrame.Position = UDim2.new(0, dropdownX, 0, dropdownY)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
dropdownFrame.BackgroundTransparency = 0.3
dropdownFrame.BorderSizePixel = 2
dropdownFrame.BorderColor3 = Color3.fromRGB(64, 64, 70)
dropdownFrame.Visible = false
dropdownFrame.Parent = mainFrame

local metodLabel = Instance.new("TextLabel")
metodLabel.Size = UDim2.new(1, 0, 0, 22)
metodLabel.Position = UDim2.new(0, 0, 0, 0)
metodLabel.BackgroundTransparency = 1
metodLabel.Text = "Выбери метод фарма"
metodLabel.Font = Enum.Font.SourceSansBold
metodLabel.TextSize = 18
metodLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
metodLabel.TextXAlignment = Enum.TextXAlignment.Left
metodLabel.Parent = dropdownFrame

-- "defolt" (поиск ближайшей), "random"
local dropdownOptions = {"defolt", "random"}
local selectedOption = 1  -- defolt всегда первый

local function updateDropdown()
    for i, child in ipairs(dropdownFrame:GetChildren()) do
        if child:IsA("TextButton") then
            local idx = tonumber(child.Name)
            child.BackgroundColor3 = (idx == selectedOption) and Color3.fromRGB(85, 210, 120) or Color3.fromRGB(36, 36, 38)
            child.BackgroundTransparency = (idx == selectedOption) and 0.18 or 0.3
            child.TextColor3 = (idx == selectedOption) and Color3.fromRGB(28, 28, 32) or Color3.fromRGB(220,220,220)
        end
    end
end

for i, option in ipairs(dropdownOptions) do
    local btn = Instance.new("TextButton")
    btn.Name = tostring(i)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, 22 + (i-1)*27)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = option
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 19
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Parent = dropdownFrame
    btn.MouseButton1Click:Connect(function()
        selectedOption = i
        updateDropdown()
        dropdownFrame.Visible = false
        moveSlider(false)
        -- Запускаем фарм после выбора метода!
        isEnabled = true
        boxIndicator.Visible = true
        startAutoFarm()
    end)
end
updateDropdown()

-- ==== СЛАЙДЕР "скорость перемещения" с анимацией ====
local SLIDER_LABEL_Y_UP = 42
local SLIDER_LABEL_Y_DOWN = 108
local SLIDER_BG_Y_UP = 66
local SLIDER_BG_Y_DOWN = 132

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0, 180, 0, 22)
sliderLabel.Position = UDim2.new(0, 76, 0, SLIDER_LABEL_Y_UP)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "скорость перемещения"
sliderLabel.Font = Enum.Font.SourceSansBold
sliderLabel.TextSize = 18
sliderLabel.TextColor3 = Color3.fromRGB(255,255,190)
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = mainFrame

local sliderBackground = Instance.new("Frame")
sliderBackground.Size = UDim2.new(0, 210, 0, 32)
sliderBackground.Position = UDim2.new(0, 72, 0, SLIDER_BG_Y_UP)
sliderBackground.BackgroundColor3 = Color3.fromRGB(19, 20, 22)
sliderBackground.BackgroundTransparency = 0.18
sliderBackground.BorderSizePixel = 0
sliderBackground.Parent = mainFrame

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(1, 0, 1, 0)
sliderFrame.Position = UDim2.new(0, 0, 0, 0)
sliderFrame.BackgroundTransparency = 1
sliderFrame.Parent = sliderBackground

local sliderBarBg = Instance.new("Frame")
sliderBarBg.Size = UDim2.new(0, 180, 0, 6)
sliderBarBg.Position = UDim2.new(0, 15, 0.5, -3)
sliderBarBg.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
sliderBarBg.BorderSizePixel = 0
sliderBarBg.Parent = sliderFrame

local sliderBarFill = Instance.new("Frame")
sliderBarFill.Size = UDim2.new(0, 0, 1, 0)
sliderBarFill.Position = UDim2.new(0, 0, 0, 0)
sliderBarFill.BackgroundColor3 = Color3.fromRGB(255, 230, 90)
sliderBarFill.BorderSizePixel = 0
sliderBarFill.Parent = sliderBarBg

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 14, 0, 14)
sliderKnob.Position = UDim2.new(0, -7, 0.5, -7)
sliderKnob.BackgroundColor3 = Color3.fromRGB(250, 240, 110)
sliderKnob.BorderSizePixel = 0
sliderKnob.BackgroundTransparency = 0.15
sliderKnob.Parent = sliderBarBg
sliderKnob.ZIndex = 2
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.ClipsDescendants = false
sliderKnob.Name = "SliderKnob"

local sliderValue = Instance.new("TextLabel")
sliderValue.Size = UDim2.new(0, 60, 1, 0)
sliderValue.Position = UDim2.new(0.5, -30, 0, -8)
sliderValue.BackgroundTransparency = 1
sliderValue.Text = "50"
sliderValue.Font = Enum.Font.SourceSansBold
sliderValue.TextSize = 15
sliderValue.TextColor3 = Color3.fromRGB(255,235,160)
sliderValue.TextStrokeTransparency = 0.35
sliderValue.TextXAlignment = Enum.TextXAlignment.Center
sliderValue.TextYAlignment = Enum.TextYAlignment.Center
sliderValue.Parent = sliderBarBg
sliderValue.ZIndex = 3

local minSpeed, maxSpeed = 10, 120
local valueSpeed = 50
local dragging = false

local function updateSliderVisual(rel)
    local width = sliderBarBg.AbsoluteSize.X
    sliderBarFill.Size = UDim2.new(0, rel * width, 1, 0)
    sliderKnob.Position = UDim2.new(0, rel * width, 0.5, 0)
    valueSpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * rel + 0.5)
    sliderValue.Text = tostring(valueSpeed)
end

local function setSlider(posX)
    local barAbsPos = sliderBarBg.AbsolutePosition.X
    local barWidth = sliderBarBg.AbsoluteSize.X
    local rel = math.clamp((posX - barAbsPos) / barWidth, 0, 1)
    updateSliderVisual(rel)
end

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
sliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
sliderBarBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        setSlider(input.Position.X) dragging = true
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setSlider(input.Position.X) end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

updateSliderVisual((valueSpeed-minSpeed)/(maxSpeed-minSpeed))

-- ==== АНИМАЦИЯ СДВИГА СЛАЙДЕРА ====
function moveSlider(down)
    local newLabelY = down and SLIDER_LABEL_Y_DOWN or SLIDER_LABEL_Y_UP
    local newBgY    = down and SLIDER_BG_Y_DOWN or SLIDER_BG_Y_UP
    TweenService:Create(sliderLabel, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 76, 0, newLabelY)}):Play()
    TweenService:Create(sliderBackground, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 72, 0, newBgY)}):Play()
end

-- ==== АВТО ФАРМ МОНЕТ (defolt/random) ====
local autoFarmActive = false
local autoFarmThread

local function getHRP()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:FindFirstChild("HumanoidRootPart")
end

local function findCoinContainer()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Folder") or obj:IsA("Model")) and obj.Name:lower():find("coincontainer") then
            return obj
        end
    end
    return nil
end

local function getCoins(coinContainer)
    local coins = {}
    for _, coin in ipairs(coinContainer:GetChildren()) do
        if coin:IsA("BasePart") or coin:FindFirstChild("CoinVisual") then
            table.insert(coins, coin)
        end
    end
    return coins
end

local function getClosestCoin(hrp, coins)
    local closestCoin, minDist = nil, math.huge
    for _, coin in ipairs(coins) do
        local pos = coin.Position or (coin:FindFirstChild("CoinVisual") and coin.CoinVisual.Position)
        if pos then
            local dist = (hrp.Position - pos).Magnitude
            if dist < minDist then
                closestCoin = coin
                minDist = dist
            end
        end
    end
    return closestCoin
end

local function smoothFlyTo(hrp, targetPos)
    while true do
        local currentPos = hrp.Position
        local direction = (targetPos - currentPos)
        local dist = direction.Magnitude
        if dist < 2 then
            hrp.CFrame = CFrame.new(targetPos)
            break
        end
        direction = direction.Unit
        local dt = RunService.RenderStepped:Wait()
        local moveDist = math.min(valueSpeed * dt, dist)
        hrp.CFrame = CFrame.new(currentPos + direction * moveDist)
        if not autoFarmActive then break end
    end
end

function startAutoFarm()
    autoFarmActive = true
    autoFarmThread = coroutine.create(function()
        while autoFarmActive do
            local coinContainer = findCoinContainer()
            if coinContainer then
                local hrp = getHRP()
                local coins = getCoins(coinContainer)
                if selectedOption == 1 then -- "defolt"
                    while autoFarmActive and #coins > 0 do
                        hrp = getHRP()
                        local closestCoin = getClosestCoin(hrp, coins)
                        if closestCoin and closestCoin.Parent then
                            local pos = closestCoin.Position or (closestCoin:FindFirstChild("CoinVisual") and closestCoin.CoinVisual.Position)
                            if hrp and pos then
                                smoothFlyTo(hrp, pos + Vector3.new(0, 2, 0))
                                wait(0.12)
                            end
                            -- убираем монету из списка (вдруг ещё осталась)
                            for i, c in ipairs(coins) do
                                if c == closestCoin then
                                    table.remove(coins, i)
                                    break
                                end
                            end
                        else
                            break
                        end
                    end
                else -- random
                    for _, coin in ipairs(coins) do
                        if not autoFarmActive then break end
                        local hrp = getHRP()
                        local pos = coin.Position or (coin:FindFirstChild("CoinVisual") and coin.CoinVisual.Position)
                        if hrp and pos and coin and coin.Parent then
                            smoothFlyTo(hrp, pos + Vector3.new(0, 2, 0))
                            wait(0.12)
                        end
                    end
                end
            end
            wait(0.5)
        end
    end)
    coroutine.resume(autoFarmThread)
end

local function stopAutoFarm()
    autoFarmActive = false
end

label.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
    moveSlider(dropdownFrame.Visible)
end)

checkbox.MouseButton1Click:Connect(function()
    if not isEnabled then
        dropdownFrame.Visible = true
        moveSlider(true)
        -- После выбора метода фарм стартует внутри dropdown (см. код выше)
    else
        isEnabled = false
        boxIndicator.Visible = false
        moveSlider(false)
        stopAutoFarm()
    end
end)

local UIS = game:GetService("UserInputService")
local open = true
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then
        open = not open
        skeetGui.Enabled = open
    end
end)
