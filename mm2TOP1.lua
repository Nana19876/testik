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

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 270)
mainFrame.Position = UDim2.new(0, 60, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Parent = skeetGui

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

local dropdownWidth = 140
local dropdownHeight = 150
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

local dropdownOptions = {"defolt", "random", "teleport", "safe"}
local selectedOption = 1

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
        isEnabled = true
        boxIndicator.Visible = true
        showSliderByMethod()
        startAutoFarm()
    end)
end
updateDropdown()

local SLIDER_LABEL_Y_UP = 42
local SLIDER_LABEL_Y_DOWN = 170
local SLIDER_BG_Y_UP = 66
local SLIDER_BG_Y_DOWN = 200

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

local teleLabel = Instance.new("TextLabel")
teleLabel.Size = UDim2.new(0, 180, 0, 22)
teleLabel.Position = UDim2.new(0, 76, 0, SLIDER_LABEL_Y_UP)
teleLabel.BackgroundTransparency = 1
teleLabel.Text = "скорость телепорта"
teleLabel.Font = Enum.Font.SourceSansBold
teleLabel.TextSize = 18
teleLabel.TextColor3 = Color3.fromRGB(255,255,220)
teleLabel.TextXAlignment = Enum.TextXAlignment.Left
teleLabel.Parent = mainFrame
teleLabel.Visible = false

local teleBackground = Instance.new("Frame")
teleBackground.Size = UDim2.new(0, 210, 0, 32)
teleBackground.Position = UDim2.new(0, 72, 0, SLIDER_BG_Y_UP)
teleBackground.BackgroundColor3 = Color3.fromRGB(19, 20, 22)
teleBackground.BackgroundTransparency = 0.18
teleBackground.BorderSizePixel = 0
teleBackground.Parent = mainFrame
teleBackground.Visible = false

local teleFrame = Instance.new("Frame")
teleFrame.Size = UDim2.new(1, 0, 1, 0)
teleFrame.Position = UDim2.new(0, 0, 0, 0)
teleFrame.BackgroundTransparency = 1
teleFrame.Parent = teleBackground

local teleBarBg = Instance.new("Frame")
teleBarBg.Size = UDim2.new(0, 180, 0, 6)
teleBarBg.Position = UDim2.new(0, 15, 0.5, -3)
teleBarBg.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
teleBarBg.BorderSizePixel = 0
teleBarBg.Parent = teleFrame

local teleBarFill = Instance.new("Frame")
teleBarFill.Size = UDim2.new(0, 0, 1, 0)
teleBarFill.Position = UDim2.new(0, 0, 0, 0)
teleBarFill.BackgroundColor3 = Color3.fromRGB(180, 210, 255)
teleBarFill.BorderSizePixel = 0
teleBarFill.Parent = teleBarBg

local teleKnob = Instance.new("Frame")
teleKnob.Size = UDim2.new(0, 14, 0, 14)
teleKnob.Position = UDim2.new(0, -7, 0.5, -7)
teleKnob.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
teleKnob.BorderSizePixel = 0
teleKnob.BackgroundTransparency = 0.15
teleKnob.Parent = teleBarBg
teleKnob.ZIndex = 2
teleKnob.AnchorPoint = Vector2.new(0.5, 0.5)
teleKnob.ClipsDescendants = false
teleKnob.Name = "TeleKnob"

local teleValue = Instance.new("TextLabel")
teleValue.Size = UDim2.new(0, 60, 1, 0)
teleValue.Position = UDim2.new(0.5, -30, 0, -8)
teleValue.BackgroundTransparency = 1
teleValue.Text = "0.50"
teleValue.Font = Enum.Font.SourceSansBold
teleValue.TextSize = 15
teleValue.TextColor3 = Color3.fromRGB(180,210,255)
teleValue.TextStrokeTransparency = 0.35
teleValue.TextXAlignment = Enum.TextXAlignment.Center
teleValue.TextYAlignment = Enum.TextYAlignment.Center
teleValue.Parent = teleBarBg
teleValue.ZIndex = 3

local minTele, maxTele = 0.05, 1.5
local valueTele = 0.50
local teleDragging = false

local function updateTeleVisual(rel)
    local width = teleBarBg.AbsoluteSize.X
    teleBarFill.Size = UDim2.new(0, rel * width, 1, 0)
    teleKnob.Position = UDim2.new(0, rel * width, 0.5, 0)
    valueTele = math.floor((minTele + (maxTele - minTele) * rel)*100)/100
    teleValue.Text = string.format("%.2f", valueTele)
end

local function setTele(posX)
    local barAbsPos = teleBarBg.AbsolutePosition.X
    local barWidth = teleBarBg.AbsoluteSize.X
    local rel = math.clamp((posX - barAbsPos) / barWidth, 0, 1)
    updateTeleVisual(rel)
end

teleKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then teleDragging = true end
end)
teleKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then teleDragging = false end
end)
teleBarBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        setTele(input.Position.X) teleDragging = true
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if teleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then setTele(input.Position.X) end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then teleDragging = false end
end)

updateTeleVisual((valueTele-minTele)/(maxTele-minTele))

function moveSliders(down)
    local newLabelY = down and SLIDER_LABEL_Y_DOWN or SLIDER_LABEL_Y_UP
    local newBgY    = down and SLIDER_BG_Y_DOWN or SLIDER_BG_Y_UP
    TweenService:Create(sliderLabel, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 76, 0, newLabelY)}):Play()
    TweenService:Create(sliderBackground, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 72, 0, newBgY)}):Play()
    TweenService:Create(teleLabel, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 76, 0, newLabelY)}):Play()
    TweenService:Create(teleBackground, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 72, 0, newBgY)}):Play()
end

function showSliderByMethod()
    if selectedOption == 3 then
        sliderLabel.Visible = false
        sliderBackground.Visible = false
        teleLabel.Visible = true
        teleBackground.Visible = true
    else
        sliderLabel.Visible = true
        sliderBackground.Visible = true
        teleLabel.Visible = false
        teleBackground.Visible = false
    end
end

-- ========== MAP/LOBBY LOGIC ==========
local MAP_NAMES = {
    "Bank 2", "Bio Lab", "Factory", "Hospital 3", "House 2", "Mansion 2",
    "Mil Base", "Office 3", "Police Station", "Research Facility", "Workplace"
}
local function isInLobby(hrp)
    return hrp.Parent and hrp.Parent == workspace.Lobby
end
local function getActiveMap()
    for _, mapName in ipairs(MAP_NAMES) do
        local map = workspace:FindFirstChild(mapName)
        if map and map:IsA("Model") then
            local pos = map:FindFirstChild("Spawn") and map.Spawn.Position
            if not pos then
                if map.PrimaryPart then
                    pos = map.PrimaryPart.Position
                else
                    pos = map:GetModelCFrame().p
                end
            end
            return pos
        end
    end
    return nil
end
local function teleportToActiveMap(hrp)
    local pos = getActiveMap()
    if pos then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
    end
end

-- ==== АВТОФАРМ логика ====
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

local function smoothFlyTo(hrp, coin)
    while true do
        if not coin or not coin.Parent then break end
        local pos = coin.Position or (coin:FindFirstChild("CoinVisual") and coin.CoinVisual.Position)
        if not pos then break end
        if isInLobby(hrp) then
            teleportToActiveMap(hrp)
            wait(0.7)
        end
        local targetPos = pos + Vector3.new(0, 2, 0)
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

local function setSafePose(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("Animator") then
            for _, tr in ipairs(desc:GetPlayingAnimationTracks()) do
                tr:Stop()
            end
        end
    end
end

local function safeFlyToStaticY(hrp, coin)
    if not coin or not coin.Parent then return end
    local pos = coin.Position or (coin:FindFirstChild("CoinVisual") and coin.CoinVisual.Position)
    if not pos then return end
    local character = player.Character or player.CharacterAdded:Wait()
    setSafePose(character)
    if isInLobby(hrp) then
        teleportToActiveMap(hrp)
        wait(0.7)
    end
    local safeY = pos.Y - 2.1
    while true do
        if not coin or not coin.Parent then break end
        local currentPos = hrp.Position
        local targetPos = Vector3.new(pos.X, safeY, pos.Z)
        local direction = (targetPos - currentPos)
        local dist = direction.Magnitude
        if dist < 2 then
            hrp.CFrame = CFrame.new(targetPos)
            setSafePose(character)
            break
        end
        direction = direction.Unit
        local dt = RunService.RenderStepped:Wait()
        local moveDist = math.min(valueSpeed * dt, dist)
        local newPos = currentPos + direction * moveDist
        hrp.CFrame = CFrame.new(newPos.X, safeY, newPos.Z)
        setSafePose(character)
        if isInLobby(hrp) then
            teleportToActiveMap(hrp)
            wait(0.7)
        end
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
                if selectedOption == 1 then
                    while autoFarmActive and #coins > 0 do
                        hrp = getHRP()
                        local closestCoin = getClosestCoin(hrp, coins)
                        if closestCoin and closestCoin.Parent then
                            smoothFlyTo(hrp, closestCoin)
                            wait(0.12)
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
                elseif selectedOption == 2 then
                    local remaining = {}
                    for _, coin in ipairs(coins) do
                        table.insert(remaining, coin)
                    end
                    while autoFarmActive and #remaining > 0 do
                        local i = math.random(1, #remaining)
                        local coin = remaining[i]
                        if coin and coin.Parent then
                            local hrp = getHRP()
                            smoothFlyTo(hrp, coin)
                            wait(0.12)
                        end
                        table.remove(remaining, i)
                    end
                elseif selectedOption == 3 then
                    local remaining = {}
                    for _, coin in ipairs(coins) do
                        table.insert(remaining, coin)
                    end
                    while autoFarmActive and #remaining > 0 do
                        local i = math.random(1, #remaining)
                        local coin = remaining[i]
                        if coin and coin.Parent then
                            local pos = coin.Position or (coin:FindFirstChild("CoinVisual") and coin.CoinVisual.Position)
                            if pos then
                                local hrp = getHRP()
                                if isInLobby(hrp) then
                                    teleportToActiveMap(hrp)
                                    wait(0.7)
                                end
                                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                                wait(valueTele)
                            end
                        end
                        table.remove(remaining, i)
                    end
                elseif selectedOption == 4 then
                    while autoFarmActive and #coins > 0 do
                        hrp = getHRP()
                        local closestCoin = getClosestCoin(hrp, coins)
                        if closestCoin and closestCoin.Parent then
                            safeFlyToStaticY(hrp, closestCoin)
                            wait(0.13)
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
                end
            end
            wait(0.5)
        end
    end)
    coroutine.resume(autoFarmThread)
end

local function stopAutoFarm()
    autoFarmActive = false
    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

label.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
    moveSliders(dropdownFrame.Visible)
end)

checkbox.MouseButton1Click:Connect(function()
    if not isEnabled then
        dropdownFrame.Visible = true
        moveSliders(true)
    else
        isEnabled = false
        boxIndicator.Visible = false
        moveSliders(false)
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

showSliderByMethod()

local function onNewCharacter(char)
    if isEnabled and autoFarmActive then
        wait(1.2)
        startAutoFarm()
    end
end
player.CharacterAdded:Connect(onNewCharacter)
