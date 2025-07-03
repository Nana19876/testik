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
    local success, point, visible, depth = pcall(function()
        return Camera:WorldToViewportPoint(pos)
    end)
    
    if success and point and visible ~= nil and depth then
        return Vector2.new(point.X, point.Y), visible, depth
    else
        return Vector2.new(0, 0), false, 0
    end
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
            if obj and obj.Remove then 
                pcall(function() obj:Remove() end)
            end
        end
    end

    local drawings = {}
    
    -- Box
    local success1, box = pcall(function()
        local b = Drawing.new("Square")
        b.Thickness = 2
        b.Filled = false
        b.Visible = false
        b.ZIndex = 2
        b.Color = Color3.fromRGB(255,255,255)
        return b
    end)

    -- Tracer
    local success2, tracer = pcall(function()
        local t = Drawing.new("Line")
        t.Thickness = 2
        t.Visible = false
        t.ZIndex = 1
        t.Color = Color3.fromRGB(255,255,255)
        return t
    end)

    if success1 and success2 then
        drawings.box = box
        drawings.tracer = tracer
        espCache[player] = drawings
    end
end

local function removePlayerESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj and obj.Remove then 
                pcall(function() obj:Remove() end)
            end
        end
        espCache[player] = nil
    end
end

local function updatePlayerESP()
    for player, esp in pairs(espCache) do
        if not player or not player.Parent or not esp or not esp.box or not esp.tracer then
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
        
        -- Исправленная проверка depth
        if not visible or not depth or depth <= 0 then
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

        -- Box ESP с безопасными вычислениями
        if showBox then
            local fov = Camera.FieldOfView or 70
            local scaleFactor = 1000 / (depth * math.tan(math.rad(fov / 2)) * 2)
            scaleFactor = math.clamp(scaleFactor or 50, 7, 120)
            
            local width = math.round(4 * scaleFactor)
            local height = math.round(5 * scaleFactor)
            
            pcall(function()
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(math.round(position.X - width / 2), math.round(position.Y - height / 2))
                esp.box.Color = boxColor
                esp.box.Visible = true
            end)
        else
            pcall(function() esp.box.Visible = false end)
        end

        -- Tracer ESP
        if showTracer then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            pcall(function()
                esp.tracer.From = screenCenter
                esp.tracer.To = position
                esp.tracer.Color = tracerColor
                esp.tracer.Visible = true
            end)
        else
            pcall(function() esp.tracer.Visible = false end)
        end
    end
end

-- ========== ESP для монет ==========
local function updateCoinESP()
    local foundCoins = {}
    
    -- Поиск монет с защитой от ошибок
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj and obj:IsA("BasePart") and obj.Name == "MainCoin" then
                foundCoins[obj] = true
                
                if not coinCache[obj] then
                    coinCache[obj] = {
                        box = {},
                        tracer = nil
                    }
                    
                    -- Создаем box (4 линии)
                    for i = 1, 4 do
                        local success, line = pcall(function()
                            local l = Drawing.new("Line")
                            l.Thickness = 2
                            l.Visible = false
                            l.Color = coinBoxColor
                            return l
                        end)
                        if success then
                            coinCache[obj].box[i] = line
                        end
                    end
                    
                    -- Создаем tracer
                    local success, tracer = pcall(function()
                        local t = Drawing.new("Line")
                        t.Thickness = 2
                        t.Visible = false
                        t.Color = coinTracerColor
                        return t
                    end)
                    if success then
                        coinCache[obj].tracer = tracer
                    end
                end

                local position, visible = wtvp(obj.Position)
                if visible then
                    -- Box ESP
                    if coinBoxEnabled and coinCache[obj].box then
                        local size = 28
                        local half = size / 2
                        local corners = {
                            Vector2.new(position.X - half, position.Y - half),
                            Vector2.new(position.X - half, position.Y + half),
                            Vector2.new(position.X + half, position.Y + half),
                            Vector2.new(position.X + half, position.Y - half)
                        }

                        for i = 1, 4 do
                            if coinCache[obj].box[i] then
                                pcall(function()
                                    coinCache[obj].box[i].From = corners[i]
                                    coinCache[obj].box[i].To = corners[i % 4 + 1]
                                    coinCache[obj].box[i].Color = coinBoxColor
                                    coinCache[obj].box[i].Visible = true
                                end)
                            end
                        end
                    else
                        for i = 1, 4 do
                            if coinCache[obj].box[i] then
                                pcall(function() coinCache[obj].box[i].Visible = false end)
                            end
                        end
                    end

                    -- Tracer ESP
                    if coinTracerEnabled and coinCache[obj].tracer then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        pcall(function()
                            coinCache[obj].tracer.From = screenCenter
                            coinCache[obj].tracer.To = position
                            coinCache[obj].tracer.Color = coinTracerColor
                            coinCache[obj].tracer.Visible = true
                        end)
                    else
                        if coinCache[obj].tracer then
                            pcall(function() coinCache[obj].tracer.Visible = false end)
                        end
                    end
                else
                    -- Скрываем если не видно
                    for i = 1, 4 do
                        if coinCache[obj].box[i] then
                            pcall(function() coinCache[obj].box[i].Visible = false end)
                        end
                    end
                    if coinCache[obj].tracer then
                        pcall(function() coinCache[obj].tracer.Visible = false end)
                    end
                end
            end
        end
    end)

    -- Удаляем старые монеты
    for coin, cache in pairs(coinCache) do
        if not foundCoins[coin] or not coin:IsDescendantOf(workspace) then
            for i = 1, 4 do
                if cache.box[i] then 
                    pcall(function() cache.box[i]:Remove() end)
                end
            end
            if cache.tracer then 
                pcall(function() cache.tracer:Remove() end)
            end
            coinCache[coin] = nil
        end
    end
end

-- ========== ESP для оружия ==========
local function updateGunESP()
    local foundGuns = {}
    
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj and obj:IsA("BasePart") and obj.Name == "GunDrop" then
                foundGuns[obj] = true
                
                if not gunCache[obj] then
                    gunCache[obj] = {
                        box = {},
                        tracer = nil
                    }
                    
                    -- Создаем box (4 линии)
                    for i = 1, 4 do
                        local success, line = pcall(function()
                            local l = Drawing.new("Line")
                            l.Thickness = 2
                            l.Visible = false
                            l.Color = gunBoxColor
                            return l
                        end)
                        if success then
                            gunCache[obj].box[i] = line
                        end
                    end
                    
                    -- Создаем tracer
                    local success, tracer = pcall(function()
                        local t = Drawing.new("Line")
                        t.Thickness = 2
                        t.Visible = false
                        t.Color = gunTracerColor
                        return t
                    end)
                    if success then
                        gunCache[obj].tracer = tracer
                    end
                end

                local position, visible = wtvp(obj.Position)
                if visible then
                    -- Box ESP
                    if gunBoxEnabled and gunCache[obj].box then
                        local size = 36
                        local half = size / 2
                        local corners = {
                            Vector2.new(position.X - half, position.Y - half),
                            Vector2.new(position.X - half, position.Y + half),
                            Vector2.new(position.X + half, position.Y + half),
                            Vector2.new(position.X + half, position.Y - half)
                        }

                        for i = 1, 4 do
                            if gunCache[obj].box[i] then
                                pcall(function()
                                    gunCache[obj].box[i].From = corners[i]
                                    gunCache[obj].box[i].To = corners[i % 4 + 1]
                                    gunCache[obj].box[i].Color = gunBoxColor
                                    gunCache[obj].box[i].Visible = true
                                end)
                            end
                        end
                    else
                        for i = 1, 4 do
                            if gunCache[obj].box[i] then
                                pcall(function() gunCache[obj].box[i].Visible = false end)
                            end
                        end
                    end

                    -- Tracer ESP
                    if gunTracerEnabled and gunCache[obj].tracer then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        pcall(function()
                            gunCache[obj].tracer.From = screenCenter
                            gunCache[obj].tracer.To = position
                            gunCache[obj].tracer.Color = gunTracerColor
                            gunCache[obj].tracer.Visible = true
                        end)
                    else
                        if gunCache[obj].tracer then
                            pcall(function() gunCache[obj].tracer.Visible = false end)
                        end
                    end
                else
                    for i = 1, 4 do
                        if gunCache[obj].box[i] then
                            pcall(function() gunCache[obj].box[i].Visible = false end)
                        end
                    end
                    if gunCache[obj].tracer then
                        pcall(function() gunCache[obj].tracer.Visible = false end)
                    end
                end
            end
        end
    end)

    -- Удаляем старые пушки
    for gun, cache in pairs(gunCache) do
        if not foundGuns[gun] or not gun:IsDescendantOf(workspace) then
            for i = 1, 4 do
                if cache.box[i] then 
                    pcall(function() cache.box[i]:Remove() end)
                end
            end
            if cache.tracer then 
                pcall(function() cache.tracer:Remove() end)
            end
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
    pcall(updatePlayerESP)
    pcall(updateCoinESP)
    pcall(updateGunESP)
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
