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
    Trap     = Color3.fromRGB(255,200,0),
    Gun      = Color3.fromRGB(30,144,255),
    Murder   = Color3.fromRGB(255,30,60),
    Sheriff  = Color3.fromRGB(40,255,60),
    Innocent = Color3.fromRGB(200,255,255),
    Coin     = Color3.fromRGB(255,215,0),
}

local boxStates, boxColors = {}, {}
local tracerStates, tracerColors = {}, {}

-- Box ESP variables
local box2dEnabled = false
local box2dColor = Color3.fromRGB(255,255,255)
local murderBoxEnabled = false
local murderBoxColor = Color3.fromRGB(255,30,60)
local sheriffBoxEnabled = false
local sheriffBoxColor = Color3.fromRGB(40,255,60)
local innocentBoxEnabled = false
local innocentBoxColor = Color3.fromRGB(200,255,255)
local coinBoxEnabled = false
local coinBoxColor = Color3.fromRGB(255,215,0)
local gunBoxEnabled = false
local gunBoxColor = Color3.fromRGB(30,144,255)

-- Tracer ESP variables
local tracerEnabled = false
local tracerColor = Color3.fromRGB(255,255,255)
local murderTracerEnabled = false
local murderTracerColor = Color3.fromRGB(255,30,60)
local sheriffTracerEnabled = false
local sheriffTracerColor = Color3.fromRGB(40,255,60)
local innocentTracerEnabled = false
local innocentTracerColor = Color3.fromRGB(200,255,255)
local coinTracerEnabled = false
local coinTracerColor = Color3.fromRGB(255,215,0)
local gunTracerEnabled = false
local gunTracerColor = Color3.fromRGB(30,144,255)

-- ========== ESP 2D Box для Player, Murder, Sheriff, Innocent ==========

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espCache = {}
local tracerCache = {}

local newVector2 = Vector2.new
local tan, rad = math.tan, math.rad
local round = function(...) local a = {}; for i,v in next, table.pack(...) do a[i] = math.round(v); end return unpack(a); end
local wtvp = function(...) local a, b = Camera.WorldToViewportPoint(Camera, ...) return newVector2(a.X, a.Y), b, a.Z end

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

local function create2dEsp(player)
    if espCache[player] then remove2dEsp(player) end

    local drawings = {}
    drawings.box = Drawing.new("Square")
    drawings.box.Thickness = 2
    drawings.box.Filled = false
    drawings.box.Color = box2dColor
    drawings.box.Visible = false
    drawings.box.ZIndex = 2

    -- Create tracer
    drawings.tracer = Drawing.new("Line")
    drawings.tracer.Thickness = 2
    drawings.tracer.Color = tracerColor
    drawings.tracer.Visible = false
    drawings.tracer.ZIndex = 1

    espCache[player] = drawings
    tracerCache[player] = drawings.tracer
end

local function remove2dEsp(player)
    if espCache[player] then
        for _, drawing in next, espCache[player] do
            if drawing.Remove then drawing:Remove() end
        end
        espCache[player] = nil
        tracerCache[player] = nil
    end
end

local function update2dEsp(player, esp)
    if not esp or not esp.box then return end

    local character = player and player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if root then
            local position, visible, depth = wtvp(root.Position)
            if visible and depth > 0 then
                local scaleFactor = math.clamp(1 / (depth * tan(rad(Camera.FieldOfView / 2)) * 2) * 1000, 7, 120)
                local width, height = round(4 * scaleFactor, 5 * scaleFactor)
                local x, y = round(position.X, position.Y)

                -- Box ESP
                esp.box.Size = newVector2(width, height)
                esp.box.Position = newVector2(round(x - width / 2, y - height / 2))

                -- Tracer ESP
                local screenCenter = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.tracer.From = screenCenter
                esp.tracer.To = newVector2(x, y)

                -- Приоритет: Murder > Sheriff > Innocent > Player
                if isMurderer(player) then
                    if murderBoxEnabled then
                        esp.box.Color = murderBoxColor
                        esp.box.Visible = true
                    else
                        esp.box.Visible = false
                    end
                    
                    if murderTracerEnabled then
                        esp.tracer.Color = murderTracerColor
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end
                elseif isSheriff(player) then
                    if sheriffBoxEnabled then
                        esp.box.Color = sheriffBoxColor
                        esp.box.Visible = true
                    else
                        esp.box.Visible = false
                    end
                    
                    if sheriffTracerEnabled then
                        esp.tracer.Color = sheriffTracerColor
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end
                elseif isInnocent(player) then
                    if innocentBoxEnabled then
                        esp.box.Color = innocentBoxColor
                        esp.box.Visible = true
                    else
                        esp.box.Visible = false
                    end
                    
                    if innocentTracerEnabled then
                        esp.tracer.Color = innocentTracerColor
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end
                else
                    if box2dEnabled and boxStates["Player"] then
                        esp.box.Color = box2dColor
                        esp.box.Visible = true
                    else
                        esp.box.Visible = false
                    end
                    
                    if tracerEnabled and tracerStates["Player"] then
                        esp.tracer.Color = tracerColor
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end
                end
            else
                esp.box.Visible = false
                esp.tracer.Visible = false
            end
        else
            esp.box.Visible = false
            esp.tracer.Visible = false
        end
    else
        esp.box.Visible = false
        esp.tracer.Visible = false
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then create2dEsp(player) end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then create2dEsp(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    remove2dEsp(player)
end)

-- ========== COIN 2D BOX (4-LINE) ==========

local coinDrawings = {}
local coinTracers = {}
local COIN_PART_NAME = "MainCoin"

local function updateCoinBox(coin)
    local box = coinDrawings[coin]
    if not box then
        box = {}
        for i = 1, 4 do
            local line = Drawing.new("Line")
            line.Color = coinBoxColor
            line.Thickness = 2
            line.Transparency = 1
            line.Visible = false
            box[i] = line
        end
        coinDrawings[coin] = box
    else
        for i = 1, 4 do
            box[i].Color = coinBoxColor
        end
    end
    return box
end

local function updateCoinTracer(coin)
    local tracer = coinTracers[coin]
    if not tracer then
        tracer = Drawing.new("Line")
        tracer.Color = coinTracerColor
        tracer.Thickness = 2
        tracer.Visible = false
        coinTracers[coin] = tracer
    else
        tracer.Color = coinTracerColor
    end
    return tracer
end

local function removeCoinBox(coin)
    local box = coinDrawings[coin]
    if box then
        for i = 1, 4 do
            box[i].Visible = false
            box[i]:Remove()
        end
        coinDrawings[coin] = nil
    end
    
    local tracer = coinTracers[coin]
    if tracer then
        tracer.Visible = false
        tracer:Remove()
        coinTracers[coin] = nil
    end
end

-- ========== GunDrop ESP (4 линии) ==========

local gunDropLines = {}
local gunDropTracers = {}

local function updateGunDropESP()
    local Camera = workspace.CurrentCamera
    local targets = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            targets[obj] = true
            
            -- Box ESP
            if gunBoxEnabled then
                local box = gunDropLines[obj]
                if not box then
                    box = {}
                    for i = 1, 4 do
                        local line = Drawing.new("Line")
                        line.Color = gunBoxColor
                        line.Thickness = 2
                        line.Transparency = 1
                        line.Visible = false
                        box[i] = line
                    end
                    gunDropLines[obj] = box
                end

                local center, visible = Camera:WorldToViewportPoint(obj.Position)
                if visible then
                    local size2D = 36
                    local half = size2D / 2
                    local corners = {
                        Vector2.new(center.X - half, center.Y - half),
                        Vector2.new(center.X - half, center.Y + half),
                        Vector2.new(center.X + half, center.Y + half),
                        Vector2.new(center.X + half, center.Y - half)
                    }

                    for i = 1, 4 do
                        box[i].From = corners[i]
                        box[i].To = corners[i % 4 + 1]
                        box[i].Visible = true
                        box[i].Color = gunBoxColor
                    end
                else
                    for i = 1, 4 do
                        box[i].Visible = false
                    end
                end
            end
            
            -- Tracer ESP
            if gunTracerEnabled then
                local tracer = gunDropTracers[obj]
                if not tracer then
                    tracer = Drawing.new("Line")
                    tracer.Color = gunTracerColor
                    tracer.Thickness = 2
                    tracer.Visible = false
                    gunDropTracers[obj] = tracer
                end

                local center, visible = Camera:WorldToViewportPoint(obj.Position)
                if visible then
                    local screenCenter = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.From = screenCenter
                    tracer.To = newVector2(center.X, center.Y)
                    tracer.Color = gunTracerColor
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            end
        end
    end

    for obj, box in pairs(gunDropLines) do
        if not targets[obj] or not obj:IsDescendantOf(workspace) then
            for i = 1, 4 do if box[i] then box[i]:Remove() end end
            gunDropLines[obj] = nil
        end
    end
    
    for obj, tracer in pairs(gunDropTracers) do
        if not targets[obj] or not obj:IsDescendantOf(workspace) then
            tracer:Remove()
            gunDropTracers[obj] = nil
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    -- ESP для игроков
    for player, esp in pairs(espCache) do
        update2dEsp(player, esp)
    end

    -- COIN ESP
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == COIN_PART_NAME then
            coins[obj] = true
        end
    end

    for coin,_ in pairs(coins) do
        -- Coin Box
        if coinBoxEnabled then
            local box = updateCoinBox(coin)
            local center, visible = Camera:WorldToViewportPoint(coin.Position)
            if visible then
                local size2D = 28
                local half = size2D / 2
                local corners = {
                    Vector2.new(center.X - half, center.Y - half),
                    Vector2.new(center.X - half, center.Y + half),
                    Vector2.new(center.X + half, center.Y + half),
                    Vector2.new(center.X + half, center.Y - half)
                }

                for i = 1, 4 do
                    box[i].From = corners[i]
                    box[i].To = corners[i % 4 + 1]
                    box[i].Visible = true
                    box[i].Color = coinBoxColor
                end
            else
                for i = 1, 4 do
                    box[i].Visible = false
                end
            end
        end
        
        -- Coin Tracer
        if coinTracerEnabled then
            local tracer = updateCoinTracer(coin)
            local center, visible = Camera:WorldToViewportPoint(coin.Position)
            if visible then
                local screenCenter = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.From = screenCenter
                tracer.To = newVector2(center.X, center.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        end
    end

    for coin, _ in pairs(coinDrawings) do
        if not coins[coin] or not coin:IsDescendantOf(workspace) then
            removeCoinBox(coin)
        end
    end

    -- Hide coin elements when disabled
    if not coinBoxEnabled then
        for _, box in pairs(coinDrawings) do
            for i = 1, 4 do
                box[i].Visible = false
            end
        end
    end
    
    if not coinTracerEnabled then
        for _, tracer in pairs(coinTracers) do
            tracer.Visible = false
        end
    end

    -- GunDrop ESP (4 линии + tracers)
    updateGunDropESP()
end)

-- ========== Rayfield Menu Integration ==========

-- Box ESP Section
for category, defaultColor in pairs(categories) do
    boxStates[category] = false
    boxColors[category] = defaultColor

    EspTab:CreateToggle({
        Name = "Box ESP: " .. category,
        CurrentValue = false,
        Callback = function(Value)
            boxStates[category] = Value
            if category == "Player" then
                box2dEnabled = Value
            elseif category == "Murder" then
                murderBoxEnabled = Value
            elseif category == "Sheriff" then
                sheriffBoxEnabled = Value
            elseif category == "Innocent" then
                innocentBoxEnabled = Value
            elseif category == "Coin" then
                coinBoxEnabled = Value
            elseif category == "Gun" then
                gunBoxEnabled = Value
            end
        end
    })

    EspTab:CreateColorPicker({
        Name = "Цвет для " .. category,
        Color = defaultColor,
        Callback = function(Color)
            boxColors[category] = Color
            if category == "Player" then
                box2dColor = Color
                for _, esp in pairs(espCache) do
                    esp.box.Color = Color
                end
            elseif category == "Murder" then
                murderBoxColor = Color
                for player, esp in pairs(espCache) do
                    if isMurderer(player) then
                        esp.box.Color = murderBoxColor
                    end
                end
            elseif category == "Sheriff" then
                sheriffBoxColor = Color
                for player, esp in pairs(espCache) do
                    if isSheriff(player) then
                        esp.box.Color = sheriffBoxColor
                    end
                end
            elseif category == "Innocent" then
                innocentBoxColor = Color
                for player, esp in pairs(espCache) do
                    if isInnocent(player) then
                        esp.box.Color = innocentBoxColor
                    end
                end
            elseif category == "Coin" then
                coinBoxColor = Color
                for _, box in pairs(coinDrawings) do
                    for i = 1, 4 do
                        box[i].Color = coinBoxColor
                    end
                end
            elseif category == "Gun" then
                gunBoxColor = Color
                for _, box in pairs(gunDropLines) do
                    for i = 1, 4 do
                        box[i].Color = gunBoxColor
                    end
                end
            end
        end
    })
end

-- Tracer ESP Section
EspTab:CreateSection("Tracer ESP")

for category, defaultColor in pairs(categories) do
    tracerStates[category] = false
    tracerColors[category] = defaultColor

    EspTab:CreateToggle({
        Name = "Tracer ESP: " .. category,
        CurrentValue = false,
        Callback = function(Value)
            tracerStates[category] = Value
            if category == "Player" then
                tracerEnabled = Value
            elseif category == "Murder" then
                murderTracerEnabled = Value
            elseif category == "Sheriff" then
                sheriffTracerEnabled = Value
            elseif category == "Innocent" then
                innocentTracerEnabled = Value
            elseif category == "Coin" then
                coinTracerEnabled = Value
            elseif category == "Gun" then
                gunTracerEnabled = Value
            end
        end
    })

    EspTab:CreateColorPicker({
        Name = "Цвет трейсера " .. category,
        Color = defaultColor,
        Callback = function(Color)
            tracerColors[category] = Color
            if category == "Player" then
                tracerColor = Color
                for _, esp in pairs(espCache) do
                    esp.tracer.Color = Color
                end
            elseif category == "Murder" then
                murderTracerColor = Color
                for player, esp in pairs(espCache) do
                    if isMurderer(player) then
                        esp.tracer.Color = murderTracerColor
                    end
                end
            elseif category == "Sheriff" then
                sheriffTracerColor = Color
                for player, esp in pairs(espCache) do
                    if isSheriff(player) then
                        esp.tracer.Color = sheriffTracerColor
                    end
                end
            elseif category == "Innocent" then
                innocentTracerColor = Color
                for player, esp in pairs(espCache) do
                    if isInnocent(player) then
                        esp.tracer.Color = innocentTracerColor
                    end
                end
            elseif category == "Coin" then
                coinTracerColor = Color
                for _, tracer in pairs(coinTracers) do
                    tracer.Color = coinTracerColor
                end
            elseif category == "Gun" then
                gunTracerColor = Color
                for _, tracer in pairs(gunDropTracers) do
                    tracer.Color = gunTracerColor
                end
            end
        end
    })
end
