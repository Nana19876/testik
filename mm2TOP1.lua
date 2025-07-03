local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "ESP Menu",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "Sirius | Rayfield",
    ConfigurationSaving = { Enabled = false }
})

local EspTab = Window:CreateTab("ESP", 4483362458)

EspTab:CreateSection("Box ESP")

local categories = {
    Player   = Color3.fromRGB(255,255,255),
    Murder   = Color3.fromRGB(255,30,60),
    Sheriff  = Color3.fromRGB(40,255,60),
    Innocent = Color3.fromRGB(200,255,255),
    Coin     = Color3.fromRGB(255,215,0),
    Gun      = Color3.fromRGB(30,144,255),
}

-- Состояния
local boxStates, tracerStates = {}, {}
local boxColors, tracerColors = {}, {}

-- Инициализация состояний
for category, color in pairs(categories) do
    boxStates[category] = false
    tracerStates[category] = false
    boxColors[category] = color
    tracerColors[category] = color
end

-- ========== Основные переменные ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local espCache = {}
local coinCache = {}
local gunCache = {}

-- Оптимизация математических функций
local newVector2 = Vector2.new
local tan, rad = math.tan, math.rad
local round = math.round

-- ========== Утилиты ==========
local function wtvp(pos)
    local point, visible, depth = Camera:WorldToViewportPoint(pos)
    return newVector2(point.X, point.Y), visible, depth
end

local function isMurderer(player)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    return (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife"))
end

local function isSheriff(player)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    return (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun"))
end

local function isInnocent(player)
    return not isMurderer(player) and not isSheriff(player) and player ~= LocalPlayer
end

-- ========== ESP для игроков ==========
local function createPlayerESP(player)
    if espCache[player] then
        -- Удаляем старые объекты
        for _, obj in pairs(espCache[player]) do
            if obj.Remove then obj:Remove() end
        end
    end

    local drawings = {}
    
    -- Box
    drawings.box = Drawing.new("Square")
    drawings.box.Thickness = 2
    drawings.box.Filled = false
    drawings.box.Visible = false
    drawings.box.ZIndex = 2

    -- Tracer
    drawings.tracer = Drawing.new("Line")
    drawings.tracer.Thickness = 2
    drawings.tracer.Visible = false
    drawings.tracer.ZIndex = 1

    espCache[player] = drawings
end

local function removePlayerESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj.Remove then obj:Remove() end
        end
        espCache[player] = nil
    end
end

local function updatePlayerESP(player, esp)
    local character = player.Character
    if not character then
        esp.box.Visible = false
        esp.tracer.Visible = false
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        esp.box.Visible = false
        esp.tracer.Visible = false
        return
    end

    local position, visible, depth = wtvp(root.Position)
    if not visible or depth <= 0 then
        esp.box.Visible = false
        esp.tracer.Visible = false
        return
    end

    -- Определяем тип игрока и цвета
    local playerType = "Player"
    local boxColor = boxColors.Player
    local tracerColor = tracerColors.Player
    local showBox = boxStates.Player
    local showTracer = tracerStates.Player

    if isMurderer(player) then
        playerType = "Murder"
        boxColor = boxColors.Murder
        tracerColor = tracerColors.Murder
        showBox = boxStates.Murder
        showTracer = tracerStates.Murder
    elseif isSheriff(player) then
        playerType = "Sheriff"
        boxColor = boxColors.Sheriff
        tracerColor = tracerColors.Sheriff
        showBox = boxStates.Sheriff
        showTracer = tracerStates.Sheriff
    elseif isInnocent(player) then
        playerType = "Innocent"
        boxColor = boxColors.Innocent
        tracerColor = tracerColors.Innocent
        showBox = boxStates.Innocent
        showTracer = tracerStates.Innocent
    end

    -- Box ESP
    if showBox then
        local scaleFactor = math.clamp(1000 / (depth * tan(rad(Camera.FieldOfView / 2)) * 2), 7, 120)
        local width, height = round(4 * scaleFactor), round(5 * scaleFactor)
        
        esp.box.Size = newVector2(width, height)
        esp.box.Position = newVector2(round(position.X - width / 2), round(position.Y - height / 2))
        esp.box.Color = boxColor
        esp.box.Visible = true
    else
        esp.box.Visible = false
    end

    -- Tracer ESP
    if showTracer then
        local screenCenter = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        esp.tracer.From = screenCenter
        esp.tracer.To = position
        esp.tracer.Color = tracerColor
        esp.tracer.Visible = true
    else
        esp.tracer.Visible = false
    end
end

-- ========== ESP для монет ==========
local function updateCoinESP()
    if not boxStates.Coin and not tracerStates.Coin then
        -- Скрываем все монеты если ESP выключен
        for _, cache in pairs(coinCache) do
            if cache.box then
                for i = 1, 4 do
                    cache.box[i].Visible = false
                end
            end
            if cache.tracer then
                cache.tracer.Visible = false
            end
        end
        return
    end

    local foundCoins = {}
    
    -- Ищем монеты (оптимизировано)
    for _, obj in ipairs(workspace:GetChildren()) do
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("BasePart") and child.Name == "MainCoin" then
                foundCoins[child] = true
                
                local cache = coinCache[child]
                if not cache then
                    cache = {}
                    
                    -- Создаем box (4 линии)
                    if boxStates.Coin then
                        cache.box = {}
                        for i = 1, 4 do
                            local line = Drawing.new("Line")
                            line.Thickness = 2
                            line.Visible = false
                            cache.box[i] = line
                        end
                    end
                    
                    -- Создаем tracer
                    if tracerStates.Coin then
                        cache.tracer = Drawing.new("Line")
                        cache.tracer.Thickness = 2
                        cache.tracer.Visible = false
                    end
                    
                    coinCache[child] = cache
                end

                local position, visible = wtvp(child.Position)
                if visible then
                    -- Box ESP
                    if boxStates.Coin and cache.box then
                        local size = 28
                        local half = size / 2
                        local corners = {
                            newVector2(position.X - half, position.Y - half),
                            newVector2(position.X - half, position.Y + half),
                            newVector2(position.X + half, position.Y + half),
                            newVector2(position.X + half, position.Y - half)
                        }

                        for i = 1, 4 do
                            cache.box[i].From = corners[i]
                            cache.box[i].To = corners[i % 4 + 1]
                            cache.box[i].Color = boxColors.Coin
                            cache.box[i].Visible = true
                        end
                    end

                    -- Tracer ESP
                    if tracerStates.Coin and cache.tracer then
                        local screenCenter = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        cache.tracer.From = screenCenter
                        cache.tracer.To = position
                        cache.tracer.Color = tracerColors.Coin
                        cache.tracer.Visible = true
                    end
                else
                    -- Скрываем если не видно
                    if cache.box then
                        for i = 1, 4 do
                            cache.box[i].Visible = false
                        end
                    end
                    if cache.tracer then
                        cache.tracer.Visible = false
                    end
                end
            end
        end
    end

    -- Удаляем старые монеты
    for coin, cache in pairs(coinCache) do
        if not foundCoins[coin] or not coin:IsDescendantOf(workspace) then
            if cache.box then
                for i = 1, 4 do
                    cache.box[i]:Remove()
                end
            end
            if cache.tracer then
                cache.tracer:Remove()
            end
            coinCache[coin] = nil
        end
    end
end

-- ========== ESP для оружия ==========
local function updateGunESP()
    if not boxStates.Gun and not tracerStates.Gun then
        for _, cache in pairs(gunCache) do
            if cache.box then
                for i = 1, 4 do
                    cache.box[i].Visible = false
                end
            end
            if cache.tracer then
                cache.tracer.Visible = false
            end
        end
        return
    end

    local foundGuns = {}
    
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            foundGuns[obj] = true
            
            local cache = gunCache[obj]
            if not cache then
                cache = {}
                
                if boxStates.Gun then
                    cache.box = {}
                    for i = 1, 4 do
                        local line = Drawing.new("Line")
                        line.Thickness = 2
                        line.Visible = false
                        cache.box[i] = line
                    end
                end
                
                if tracerStates.Gun then
                    cache.tracer = Drawing.new("Line")
                    cache.tracer.Thickness = 2
                    cache.tracer.Visible = false
                end
                
                gunCache[obj] = cache
            end

            local position, visible = wtvp(obj.Position)
            if visible then
                if boxStates.Gun and cache.box then
                    local size = 36
                    local half = size / 2
                    local corners = {
                        newVector2(position.X - half, position.Y - half),
                        newVector2(position.X - half, position.Y + half),
                        newVector2(position.X + half, position.Y + half),
                        newVector2(position.X + half, position.Y - half)
                    }

                    for i = 1, 4 do
                        cache.box[i].From = corners[i]
                        cache.box[i].To = corners[i % 4 + 1]
                        cache.box[i].Color = boxColors.Gun
                        cache.box[i].Visible = true
                    end
                end

                if tracerStates.Gun and cache.tracer then
                    local screenCenter = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    cache.tracer.From = screenCenter
                    cache.tracer.To = position
                    cache.tracer.Color = tracerColors.Gun
                    cache.tracer.Visible = true
                end
            else
                if cache.box then
                    for i = 1, 4 do
                        cache.box[i].Visible = false
                    end
                end
                if cache.tracer then
                    cache.tracer.Visible = false
                end
            end
        end
    end

    for gun, cache in pairs(gunCache) do
        if not foundGuns[gun] or not gun:IsDescendantOf(workspace) then
            if cache.box then
                for i = 1, 4 do
                    cache.box[i]:Remove()
                end
            end
            if cache.tracer then
                cache.tracer:Remove()
            end
            gunCache[gun] = nil
        end
    end
end

-- ========== События игроков ==========
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createPlayerESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createPlayerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerESP(player)
end)

-- ========== Основной цикл обновления ==========
local lastUpdate = 0
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    
    -- Ограничиваем частоту обновления до 60 FPS
    if currentTime - lastUpdate < 1/60 then
        return
    end
    lastUpdate = currentTime

    -- Обновляем ESP игроков
    for player, esp in pairs(espCache) do
        if player and player.Parent then
            updatePlayerESP(player, esp)
        end
    end

    -- Обновляем ESP монет и оружия (реже)
    if currentTime % 0.1 < 0.016 then -- Каждые 100мс
        updateCoinESP()
        updateGunESP()
    end
end)

-- ========== Интерфейс ==========

-- Box ESP
for category, defaultColor in pairs(categories) do
    EspTab:CreateToggle({
        Name = "Box ESP: " .. category,
        CurrentValue = false,
        Callback = function(Value)
            boxStates[category] = Value
        end
    })

    EspTab:CreateColorPicker({
        Name = "Цвет для " .. category,
        Color = defaultColor,
        Callback = function(Color)
            boxColors[category] = Color
        end
    })
end

-- Tracer ESP
EspTab:CreateSection("Tracer ESP")

for category, defaultColor in pairs(categories) do
    EspTab:CreateToggle({
        Name = "Tracer ESP: " .. category,
        CurrentValue = false,
        Callback = function(Value)
            tracerStates[category] = Value
        end
    })

    EspTab:CreateColorPicker({
        Name = "Цвет трейсера " .. category,
        Color = defaultColor,
        Callback = function(Color)
            tracerColors[category] = Color
        end
    })
end
