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

-- Кэши и списки
local espCache = {}
local coinCache = {}
local gunCache = {}
local coinsList = {}
local gunsList = {}

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

-- ========== Быстрое обновление списков монет и GunDrop ==========
local function updateCoinsList()
    coinsList = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "MainCoin" then
            table.insert(coinsList, obj)
        end
    end
end

local function updateGunsList()
    gunsList = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            table.insert(gunsList, obj)
        end
    end
end

-- Автообновление списков раз в 0.5 сек
task.spawn(function()
    while true do
        pcall(updateCoinsList)
        pcall(updateGunsList)
        task.wait(0.5)
    end
end)

-- ========== ESP для игроков ==========
local function createPlayerESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj and obj.Remove then pcall(function() obj:Remove() end) end
        end
    end
    local box = Drawing.new("Square")
    box.Thickness = 2; box.Filled = false; box.Visible = false; box.ZIndex = 2
    local tracer = Drawing.new("Line")
    tracer.Thickness = 2; tracer.Visible = false; tracer.ZIndex = 1
    espCache[player] = {box=box, tracer=tracer}
end

local function removePlayerESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            if obj and obj.Remove then pcall(function() obj:Remove() end) end
        end
        espCache[player] = nil
    end
end

local function updatePlayerESP()
    for player, esp in pairs(espCache) do
        if not player or not player.Parent or not esp or not esp.box or not esp.tracer then continue end
        local character = player.Character
        if not character then esp.box.Visible = false; esp.tracer.Visible = false; continue end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then esp.box.Visible = false; esp.tracer.Visible = false; continue end
        local position, visible, depth = wtvp(root.Position)
        if not visible or not depth or depth <= 0 then
            esp.box.Visible = false; esp.tracer.Visible = false; continue
        end
        local showBox, showTracer = false, false
        local boxColor, tracerColor = playerBoxColor, playerTracerColor
        if isMurderer(player) then
            showBox = murderBoxEnabled; showTracer = murderTracerEnabled
            boxColor = murderBoxColor; tracerColor = murderTracerColor
        elseif isSheriff(player) then
            showBox = sheriffBoxEnabled; showTracer = sheriffTracerEnabled
            boxColor = sheriffBoxColor; tracerColor = sheriffTracerColor
        elseif isInnocent(player) then
            showBox = innocentBoxEnabled; showTracer = innocentTracerEnabled
            boxColor = innocentBoxColor; tracerColor = innocentTracerColor
        else
            showBox = playerBoxEnabled; showTracer = playerTracerEnabled
            boxColor = playerBoxColor; tracerColor = playerTracerColor
        end
        -- Box
        if showBox then
            local fov = Camera.FieldOfView or 70
            local scaleFactor = 1000 / (depth * math.tan(math.rad(fov / 2)) * 2)
            scaleFactor = math.clamp(scaleFactor or 50, 7, 120)
            local width = math.round(4 * scaleFactor)
            local height = math.round(5 * scaleFactor)
            esp.box.Size = Vector2.new(width, height)
            esp.box.Position = Vector2.new(math.round(position.X - width / 2), math.round(position.Y - height / 2))
            esp.box.Color = boxColor
            esp.box.Visible = true
        else
            esp.box.Visible = false
        end
        -- Tracer
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
    for _, obj in ipairs(coinsList) do
        foundCoins[obj] = true
        if not coinCache[obj] then
            coinCache[obj] = {box={}, tracer=nil}
            for i = 1, 4 do
                local line = Drawing.new("Line")
                line.Thickness = 2
                line.Visible = false
                line.Color = coinBoxColor
                coinCache[obj].box[i] = line
            end
            local tracer = Drawing.new("Line")
            tracer.Thickness = 2; tracer.Visible = false; tracer.Color = coinTracerColor
            coinCache[obj].tracer = tracer
        end
        local position, visible = wtvp(obj.Position)
        if visible then
            -- Box
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
                for i = 1, 4 do coinCache[obj].box[i].Visible = false end
            end
            -- Tracer
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
            for i = 1, 4 do coinCache[obj].box[i].Visible = false end
            coinCache[obj].tracer.Visible = false
        end
    end
    for coin, cache in pairs(coinCache) do
        if not foundCoins[coin] or not coin:IsDescendantOf(workspace) then
            for i = 1, 4 do if cache.box[i] then cache.box[i]:Remove() end end
            if cache.tracer then cache.tracer:Remove() end
            coinCache[coin] = nil
        end
    end
end

-- ========== ESP для GunDrop ==========
local function updateGunESP()
    local foundGuns = {}
    for _, obj in ipairs(gunsList) do
        foundGuns[obj] = true
        if not gunCache[obj] then
            gunCache[obj] = {box={}, tracer=nil}
            for i = 1, 4 do
                local line = Drawing.new("Line")
                line.Thickness = 2
                line.Visible = false
                line.Color = gunBoxColor
                gunCache[obj].box[i] = line
            end
            local tracer = Drawing.new("Line")
            tracer.Thickness = 2; tracer.Visible = false; tracer.Color = gunTracerColor
            gunCache[obj].tracer = tracer
        end
        local position, visible = wtvp(obj.Position)
        if visible then
            -- Box
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
                for i = 1, 4 do gunCache[obj].box[i].Visible = false end
            end
            -- Tracer
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
            for i = 1, 4 do gunCache[obj].box[i].Visible = false end
            gunCache[obj].tracer.Visible = false
        end
    end
    for gun, cache in pairs(gunCache) do
        if not foundGuns[gun] or not gun:IsDescendantOf(workspace) then
            for i = 1, 4 do if cache.box[i] then cache.box[i]:Remove() end end
            if cache.tracer then cache.tracer:Remove() end
            gunCache[gun] = nil
        end
    end
end

-- ========== События игроков ==========
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createPlayerESP(player) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then createPlayerESP(player) end
end)
Players.PlayerRemoving:Connect(removePlayerESP)

-- ========== Основной цикл ==========

RunService.RenderStepped:Connect(function()
    updatePlayerESP()
    updateCoinESP()
    updateGunESP()
end)

-- ========== Интерфейс ==========

EspTab:CreateToggle({ Name = "Box ESP: Player", CurrentValue = false, Callback = function(v) playerBoxEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет для Player", Color = Color3.fromRGB(255,255,255), Callback = function(c) playerBoxColor = c end })

EspTab:CreateToggle({ Name = "Box ESP: Murder", CurrentValue = false, Callback = function(v) murderBoxEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет для Murder", Color = Color3.fromRGB(255,30,60), Callback = function(c) murderBoxColor = c end })

EspTab:CreateToggle({ Name = "Box ESP: Sheriff", CurrentValue = false, Callback = function(v) sheriffBoxEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет для Sheriff", Color = Color3.fromRGB(40,255,60), Callback = function(c) sheriffBoxColor = c end })

EspTab:CreateToggle({ Name = "Box ESP: Innocent", CurrentValue = false, Callback = function(v) innocentBoxEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет для Innocent", Color = Color3.fromRGB(200,255,255), Callback = function(c) innocentBoxColor = c end })

EspTab:CreateToggle({ Name = "Box ESP: Coin", CurrentValue = false, Callback = function(v) coinBoxEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет для Coin", Color = Color3.fromRGB(255,215,0), Callback = function(c) coinBoxColor = c end })

EspTab:CreateToggle({ Name = "Box ESP: Gun", CurrentValue = false, Callback = function(v) gunBoxEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет для Gun", Color = Color3.fromRGB(30,144,255), Callback = function(c) gunBoxColor = c end })

EspTab:CreateSection("Tracer ESP")

EspTab:CreateToggle({ Name = "Tracer ESP: Player", CurrentValue = false, Callback = function(v) playerTracerEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет трейсера Player", Color = Color3.fromRGB(255,255,255), Callback = function(c) playerTracerColor = c end })

EspTab:CreateToggle({ Name = "Tracer ESP: Murder", CurrentValue = false, Callback = function(v) murderTracerEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет трейсера Murder", Color = Color3.fromRGB(255,30,60), Callback = function(c) murderTracerColor = c end })

EspTab:CreateToggle({ Name = "Tracer ESP: Sheriff", CurrentValue = false, Callback = function(v) sheriffTracerEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет трейсера Sheriff", Color = Color3.fromRGB(40,255,60), Callback = function(c) sheriffTracerColor = c end })

EspTab:CreateToggle({ Name = "Tracer ESP: Innocent", CurrentValue = false, Callback = function(v) innocentTracerEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет трейсера Innocent", Color = Color3.fromRGB(200,255,255), Callback = function(c) innocentTracerColor = c end })

EspTab:CreateToggle({ Name = "Tracer ESP: Coin", CurrentValue = false, Callback = function(v) coinTracerEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет трейсера Coin", Color = Color3.fromRGB(255,215,0), Callback = function(c) coinTracerColor = c end })

EspTab:CreateToggle({ Name = "Tracer ESP: Gun", CurrentValue = false, Callback = function(v) gunTracerEnabled = v end })
EspTab:CreateColorPicker({ Name = "Цвет трейсера Gun", Color = Color3.fromRGB(30,144,255), Callback = function(c) gunTracerColor = c end })
