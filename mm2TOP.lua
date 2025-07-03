local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "ESP Menu",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "Sirius | Rayfield",
    ConfigurationSaving = { Enabled = false }
})

local EspTab = Window:CreateTab("ESP", 4483362458)

EspTab:CreateSection("Box ESP")

-- ========== Переменные ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Состояния ESP
local playerBoxEnabled = false
local playerTracerEnabled = false
local murderBoxEnabled = false
local murderTracerEnabled = false
local sheriffBoxEnabled = false
local sheriffTracerEnabled = false
local innocentBoxEnabled = false
local innocentTracerEnabled = false
local coinBoxEnabled = false
local coinTracerEnabled = false
local gunBoxEnabled = false
local gunTracerEnabled = false

-- Цвета
local playerBoxColor = Color3.fromRGB(255,255,255)
local playerTracerColor = Color3.fromRGB(255,255,255)
local murderBoxColor = Color3.fromRGB(255,30,60)
local murderTracerColor = Color3.fromRGB(255,30,60)
local sheriffBoxColor = Color3.fromRGB(40,255,60)
local sheriffTracerColor = Color3.fromRGB(40,255,60)
local innocentBoxColor = Color3.fromRGB(200,255,255)
local innocentTracerColor = Color3.fromRGB(200,255,255)
local coinBoxColor = Color3.fromRGB(255,215,0)
local coinTracerColor = Color3.fromRGB(255,215,0)
local gunBoxColor = Color3.fromRGB(30,144,255)
local gunTracerColor = Color3.fromRGB(30,144,255)

-- Кэши
local espCache = {}
local coinCache = {}
local gunCache = {}

-- ========== Утилиты ==========
local function wtvp(pos)
    local point, visible, depth = Camera:WorldToViewportPoint(pos)
    return Vector2.new(point.X, point.Y), visible, depth
end

local function isMurderer(player)
    if not player or not player.Character then return false end
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    return (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife"))
end

local function isSheriff(player)
    if not player or not player.Character then return false end
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
        for _, obj in pairs(espCache[player]) do
            if obj and obj.Remove then obj:Remove() end
        end
    end

    local drawings = {}
    
    -- Box
    drawings.box = Drawing.new("Square")
    drawings.box.Thickness = 2
    drawings.box.Filled = false
    drawings.box.Visible = false
    drawings.box.ZIndex = 2
    drawings.box.Color = Color3.fromRGB(255,255,255)

    -- Tracer
    drawings.tracer = Drawing.new("Line")
    drawings.tracer.Thickness = 2
    drawings.tracer.Visible = false
    drawings.tracer.ZIndex = 1
    drawings.tracer.Color = Color3.fromRGB(255,255,255)

    espCache[player] = drawings
end

local function removePlayerESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj and obj.Remove then 
                obj:Remove() 
            end
        end
        espCache[player] = nil
    end
end

local function updatePlayerESP()
    for player, esp in pairs(espCache) do
        if not player or not player.Parent or not esp then
            continue
        end

        local character = player.Character
        if not character then
            esp.box.Visible = false
            esp.tracer.Visible = false
            continue
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then
            esp.box.Visible = false
            esp.tracer.Visible = false
            continue
        end

        local position, visible, depth = wtvp(root.Position)
        if not visible or depth <= 0 then
            esp.box.Visible = false
            esp.tracer.Visible = false
            continue
        end

        -- Определяем тип игрока
        local showBox = false
        local showTracer = false
        local boxColor = playerBoxColor
        local tracerColor = playerTracerColor

        if isMurderer(player) then
            showBox = murderBoxEnabled
            showTracer = murderTracerEnabled
            boxColor = murderBoxColor
            tracerColor = murderTracerColor
        elseif isSheriff(player) then
            showBox = sheriffBoxEnabled
            showTracer = sheriffTracerEnabled
            boxColor = sheriffBoxColor
            tracerColor = sheriffTracerColor
        elseif isInnocent(player) then
            showBox = innocentBoxEnabled
            showTracer = innocentTracerEnabled
            boxColor = innocentBoxColor
            tracerColor = innocentTracerColor
        else
            showBox = playerBoxEnabled
            showTracer = playerTracerEnabled
            boxColor = playerBoxColor
            tracerColor = playerTracerColor
        end

        -- Box ESP
        if showBox then
            local scaleFactor = math.clamp(1000 / (depth * math.tan(math.rad(Camera.FieldOfView / 2)) * 2), 7, 120)
            local width = math.round(4 * scaleFactor)
            local height = math.round(5 * scaleFactor)
            
            esp.box.Size = Vector2.new(width, height)
            esp.box.Position = Vector2.new(math.round(position.X - width / 2), math.round(position.Y - height / 2))
            esp.box.Color = boxColor
            esp.box.Visible = true
        else
            esp.box.Visible = false
        end

        -- Tracer ESP
        if showTracer then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.tracer.From = screenCenter
            esp.tracer.To = position
            esp.tracer.Color = tracerColor
            esp.tracer.Visible = true
        else
            esp.tracer.Visible = false
        end
    end
end

-- ========== ESP для монет ==========
local function updateCoinESP()
    local foundCoins = {}
    
    -- Поиск монет
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "MainCoin" then
            foundCoins[obj] = true
            
            if not coinCache[obj] then
                coinCache[obj] = {
                    box = {},
                    tracer = nil
                }
                
                -- Создаем box (4 линии)
                for i = 1, 4 do
                    local line = Drawing.new("Line")
                    line.Thickness = 2
                    line.Visible = false
                    line.Color = coinBoxColor
                    coinCache[obj].box[i] = line
                end
                
                -- Создаем tracer
                local tracer = Drawing.new("Line")
                tracer.Thickness = 2
                tracer.Visible = false
                tracer.Color = coinTracerColor
                coinCache[obj].tracer = tracer
            end

            local position, visible = wtvp(obj.Position)
            if visible then
                -- Box ESP
                if coinBoxEnabled then
                    local size = 28
                    local half = size / 2
                    local corners = {
                        Vector2.new(position.X - half, position.Y - half),
                        Vector2.new(position.X - half, position.Y + half),
                        Vector2.new(position.X + half, position.Y + half),
                        Vector2.new(position.X + half, position.Y - half)
                    }

                    for i = 1, 4 do
                        coinCache[obj].box[i].From = corners[i]
                        coinCache[obj].box[i].To = corners[i % 4 + 1]
                        coinCache[obj].box[i].Color = coinBoxColor
                        coinCache[obj].box[i].Visible = true
                    end
                else
                    for i = 1, 4 do
                        coinCache[obj].box[i].Visible = false
                    end
                end

                -- Tracer ESP
                if coinTracerEnabled then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    coinCache[obj].tracer.From = screenCenter
                    coinCache[obj].tracer.To = position
                    coinCache[obj].tracer.Color = coinTracerColor
                    coinCache[obj].tracer.Visible = true
                else
                    coinCache[obj].tracer.Visible = false
                end
            else
                -- Скрываем если не видно
                for i = 1, 4 do
                    coinCache[obj].box[i].Visible = false
                end
                coinCache[obj].tracer.Visible = false
            end
        end
    end

    -- Удаляем старые монеты
    for coin, cache in pairs(coinCache) do
        if not foundCoins[coin] or not coin:IsDescendantOf(workspace) then
            for i = 1, 4 do
                if cache.box[i] then cache.box[i]:Remove() end
            end
            if cache.tracer then cache.tracer:Remove() end
            coinCache[coin] = nil
        end
    end
end

-- ========== ESP для оружия ==========
local function updateGunESP()
    local foundGuns = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            foundGuns[obj] = true
            
            if not gunCache[obj] then
                gunCache[obj] = {
                    box = {},
                    tracer = nil
                }
                
                -- Создаем box (4 линии)
                for i = 1, 4 do
                    local line = Drawing.new("Line")
                    line.Thickness = 2
                    line.Visible = false
                    line.Color = gunBoxColor
                    gunCache[obj].box[i] = line
                end
                
                -- Создаем tracer
                local tracer = Drawing.new("Line")
                tracer.Thickness = 2
                tracer.Visible = false
                tracer.Color = gunTracerColor
                gunCache[obj].tracer = tracer
            end

            local position, visible = wtvp(obj.Position)
            if visible then
                -- Box ESP
                if gunBoxEnabled then
                    local size = 36
                    local half = size / 2
                    local corners = {
                        Vector2.new(position.X - half, position.Y - half),
                        Vector2.new(position.X - half, position.Y + half),
                        Vector2.new(position.X + half, position.Y + half),
                        Vector2.new(position.X + half, position.Y - half)
                    }

                    for i = 1, 4 do
                        gunCache[obj].box[i].From = corners[i]
                        gunCache[obj].box[i].To = corners[i % 4 + 1]
                        gunCache[obj].box[i].Color = gunBoxColor
                        gunCache[obj].box[i].Visible = true
                    end
                else
                    for i = 1, 4 do
                        gunCache[obj].box[i].Visible = false
                    end
                end

                -- Tracer ESP
                if gunTracerEnabled then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    gunCache[obj].tracer.From = screenCenter
                    gunCache[obj].tracer.To = position
                    gunCache[obj].tracer.Color = gunTracerColor
                    gunCache[obj].tracer.Visible = true
                else
                    gunCache[obj].tracer.Visible = false
                end
            else
                for i = 1, 4 do
                    gunCache[obj].box[i].Visible = false
                end
                gunCache[obj].tracer.Visible = false
            end
        end
    end

    -- Удаляем старые пушки
    for gun, cache in pairs(gunCache) do
        if not foundGuns[gun] or not gun:IsDescendantOf(workspace) then
            for i = 1, 4 do
                if cache.box[i] then cache.box[i]:Remove() end
            end
            if cache.tracer then cache.tracer:Remove() end
            gunCache[gun] = nil
        end
    end
end

-- ========== События игроков ==========
for _, player in pairs(Players:GetPlayers()) do
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

-- ========== Основной цикл ==========
RunService.RenderStepped:Connect(function()
    updatePlayerESP()
    updateCoinESP()
    updateGunESP()
end)

-- ========== Интерфейс ==========

-- Box ESP для игроков
EspTab:CreateToggle({
    Name = "Box ESP: Player",
    CurrentValue = false,
    Callback = function(Value)
        playerBoxEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет для Player",
    Color = Color3.fromRGB(255,255,255),
    Callback = function(Color)
        playerBoxColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Box ESP: Murder",
    CurrentValue = false,
    Callback = function(Value)
        murderBoxEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет для Murder",
    Color = Color3.fromRGB(255,30,60),
    Callback = function(Color)
        murderBoxColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Box ESP: Sheriff",
    CurrentValue = false,
    Callback = function(Value)
        sheriffBoxEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет для Sheriff",
    Color = Color3.fromRGB(40,255,60),
    Callback = function(Color)
        sheriffBoxColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Box ESP: Innocent",
    CurrentValue = false,
    Callback = function(Value)
        innocentBoxEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет для Innocent",
    Color = Color3.fromRGB(200,255,255),
    Callback = function(Color)
        innocentBoxColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Box ESP: Coin",
    CurrentValue = false,
    Callback = function(Value)
        coinBoxEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет для Coin",
    Color = Color3.fromRGB(255,215,0),
    Callback = function(Color)
        coinBoxColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Box ESP: Gun",
    CurrentValue = false,
    Callback = function(Value)
        gunBoxEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет для Gun",
    Color = Color3.fromRGB(30,144,255),
    Callback = function(Color)
        gunBoxColor = Color
    end
})

-- Tracer ESP
EspTab:CreateSection("Tracer ESP")

EspTab:CreateToggle({
    Name = "Tracer ESP: Player",
    CurrentValue = false,
    Callback = function(Value)
        playerTracerEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет трейсера Player",
    Color = Color3.fromRGB(255,255,255),
    Callback = function(Color)
        playerTracerColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Tracer ESP: Murder",
    CurrentValue = false,
    Callback = function(Value)
        murderTracerEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет трейсера Murder",
    Color = Color3.fromRGB(255,30,60),
    Callback = function(Color)
        murderTracerColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Tracer ESP: Sheriff",
    CurrentValue = false,
    Callback = function(Value)
        sheriffTracerEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет трейсера Sheriff",
    Color = Color3.fromRGB(40,255,60),
    Callback = function(Color)
        sheriffTracerColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Tracer ESP: Innocent",
    CurrentValue = false,
    Callback = function(Value)
        innocentTracerEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет трейсера Innocent",
    Color = Color3.fromRGB(200,255,255),
    Callback = function(Color)
        innocentTracerColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Tracer ESP: Coin",
    CurrentValue = false,
    Callback = function(Value)
        coinTracerEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет трейсера Coin",
    Color = Color3.fromRGB(255,215,0),
    Callback = function(Color)
        coinTracerColor = Color
    end
})

EspTab:CreateToggle({
    Name = "Tracer ESP: Gun",
    CurrentValue = false,
    Callback = function(Value)
        gunTracerEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Цвет трейсера Gun",
    Color = Color3.fromRGB(30,144,255),
    Callback = function(Color)
        gunTracerColor = Color
    end
})
