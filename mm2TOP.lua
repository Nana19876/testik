local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "ESP Menu",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "Sirius | Rayfield",
    ConfigurationSaving = { Enabled = false }
})

local EspTab = Window:CreateTab("ESP", 4483362458)

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

-- ================== Секция Box:ESP ==================
EspTab:CreateSection("Box:ESP")
for category, defaultColor in pairs(categories) do
    boxStates[category] = false
    boxColors[category] = defaultColor

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

-- ================== Секция Tracer:ESP ==================
EspTab:CreateSection("Tracer:ESP")
for category, defaultColor in pairs(categories) do
    tracerStates[category] = false
    tracerColors[category] = defaultColor

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

-- ========== ОСНОВНОЙ ESP-КОД ==========

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espCache = {}
local coinDrawings = {}
local gunDropLines = {}

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
    if espCache[player] then
        for _, drawing in next, espCache[player] do
            if drawing.Remove then drawing:Remove() end
        end
    end
    local drawings = {}
    drawings.box = Drawing.new("Square")
    drawings.box.Thickness = 2
    drawings.box.Filled = false
    drawings.box.Visible = false
    drawings.box.ZIndex = 2

    drawings.tracer = Drawing.new("Line")
    drawings.tracer.Thickness = 2
    drawings.tracer.Visible = false
    drawings.tracer.ZIndex = 1

    espCache[player] = drawings
end

local function remove2dEsp(player)
    if espCache[player] then
        for _, drawing in next, espCache[player] do
            if drawing.Remove then drawing:Remove() end
        end
        espCache[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then create2dEsp(player) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then create2dEsp(player) end
end)
Players.PlayerRemoving:Connect(remove2dEsp)

local COIN_PART_NAME = "MainCoin"

local function updateCoinBoxAndTracer(coin)
    local box = coinDrawings[coin]
    if not box then
        box = {}
        for i = 1, 4 do
            local line = Drawing.new("Line")
            line.Color = boxColors.Coin
            line.Thickness = 2
            line.Transparency = 1
            line.Visible = false
            box[i] = line
        end
        local tracer = Drawing.new("Line")
        tracer.Color = tracerColors.Coin
        tracer.Thickness = 2
        tracer.Visible = false
        box.tracer = tracer
        coinDrawings[coin] = box
    end
    return box
end

local function removeCoinBox(coin)
    local box = coinDrawings[coin]
    if box then
        for i = 1, 4 do
            box[i].Visible = false
            box[i]:Remove()
        end
        if box.tracer then box.tracer.Visible = false box.tracer:Remove() end
        coinDrawings[coin] = nil
    end
end

local function updateGunDropESP()
    local Camera = workspace.CurrentCamera
    local targets = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            targets[obj] = true
            local box = gunDropLines[obj]
            if not box then
                box = {}
                for i = 1, 4 do
                    local line = Drawing.new("Line")
                    line.Color = boxColors.Gun
                    line.Thickness = 2
                    line.Transparency = 1
                    line.Visible = false
                    box[i] = line
                end
                local tracer = Drawing.new("Line")
                tracer.Color = tracerColors.Gun
                tracer.Thickness = 2
                tracer.Visible = false
                box.tracer = tracer
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
                    box[i].Visible = boxStates.Gun
                    box[i].Color = boxColors.Gun
                end
                if tracerStates.Gun then
                    box.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    box.tracer.To = Vector2.new(center.X, center.Y)
                    box.tracer.Color = tracerColors.Gun
                    box.tracer.Visible = true
                else
                    box.tracer.Visible = false
                end
            else
                for i = 1, 4 do box[i].Visible = false end
                box.tracer.Visible = false
            end
        end
    end
    for obj, box in pairs(gunDropLines) do
        if not targets[obj] or not obj:IsDescendantOf(workspace) then
            for i = 1, 4 do if box[i] then box[i]:Remove() end end
            if box.tracer then box.tracer:Remove() end
            gunDropLines[obj] = nil
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    -- ESP и TRACER для игроков
    for player, esp in pairs(espCache) do
        local character = player and player.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            if root then
                local pos, visible, z = Camera:WorldToViewportPoint(root.Position)
                if visible and z > 0 then
                    local scale = math.clamp(1 / (z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000, 7, 120)
                    local w, h = 4 * scale, 5 * scale
                    esp.box.Size = Vector2.new(w, h)
                    esp.box.Position = Vector2.new(math.round(pos.X - w / 2), math.round(pos.Y - h / 2))
                    esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(pos.X, pos.Y)

                    if isMurderer(player) then
                        esp.box.Color = boxColors.Murder
                        esp.box.Visible = boxStates.Murder
                        esp.tracer.Color = tracerColors.Murder
                        esp.tracer.Visible = tracerStates.Murder
                    elseif isSheriff(player) then
                        esp.box.Color = boxColors.Sheriff
                        esp.box.Visible = boxStates.Sheriff
                        esp.tracer.Color = tracerColors.Sheriff
                        esp.tracer.Visible = tracerStates.Sheriff
                    elseif isInnocent(player) then
                        esp.box.Color = boxColors.Innocent
                        esp.box.Visible = boxStates.Innocent
                        esp.tracer.Color = tracerColors.Innocent
                        esp.tracer.Visible = tracerStates.Innocent
                    else
                        esp.box.Color = boxColors.Player
                        esp.box.Visible = boxStates.Player
                        esp.tracer.Color = tracerColors.Player
                        esp.tracer.Visible = tracerStates.Player
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

    -- COIN ESP/TRACER
    if boxStates.Coin or tracerStates.Coin then
        local coins = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == COIN_PART_NAME then
                coins[obj] = true
            end
        end
        for coin, _ in pairs(coins) do
            local box = updateCoinBoxAndTracer(coin)
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
                    box[i].Visible = boxStates.Coin
                    box[i].Color = boxColors.Coin
                end
                if tracerStates.Coin then
                    box.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    box.tracer.To = Vector2.new(center.X, center.Y)
                    box.tracer.Color = tracerColors.Coin
                    box.tracer.Visible = true
                else
                    box.tracer.Visible = false
                end
            else
                for i = 1, 4 do box[i].Visible = false end
                if box.tracer then box.tracer.Visible = false end
            end
        end
        for coin, _ in pairs(coinDrawings) do
            if not coins[coin] or not coin:IsDescendantOf(workspace) then
                removeCoinBox(coin)
            end
        end
    else
        for _, box in pairs(coinDrawings) do
            for i = 1, 4 do box[i].Visible = false end
            if box.tracer then box.tracer.Visible = false end
        end
    end

    -- GunDrop ESP и TRACER
    updateGunDropESP()
end)
