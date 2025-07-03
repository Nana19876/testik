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
    Gun      = Color3.fromRGB(30,144,255), -- GunDrop ESP
    Murder   = Color3.fromRGB(255,30,60),
    Sheriff  = Color3.fromRGB(40,255,60),
    Innocent = Color3.fromRGB(200,255,255),
    Coin     = Color3.fromRGB(255,215,0),
}
local boxStates, boxColors = {}, {}
local tracerStates, tracerColors = {}, {}

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

local tracer2dEnabled = false
local tracer2dColor = Color3.fromRGB(255,255,255)
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

-- ========== ESP 2D Box и Tracer для Player, Murder, Sheriff, Innocent ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espCache = {}
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

    drawings.tracer = Drawing.new("Line")
    drawings.tracer.Thickness = 2
    drawings.tracer.Color = tracer2dColor
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

local function update2dEsp(player, esp)
    if not esp or not esp.box or not esp.tracer then return end
    local character = player and player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if root then
            local position, visible, depth = wtvp(root.Position)
            if visible and depth > 0 then
                local scaleFactor = math.clamp(1 / (depth * tan(rad(Camera.FieldOfView / 2)) * 2) * 1000, 7, 120)
                local width, height = round(4 * scaleFactor, 5 * scaleFactor)
                local x, y = round(position.X, position.Y)
                esp.box.Size = newVector2(width, height)
                esp.box.Position = newVector2(round(x - width / 2, y - height / 2))
                esp.tracer.From = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.tracer.To = newVector2(x, y)
                -- Приоритет: Murder > Sheriff > Innocent > Player
                if isMurderer(player) then
                    esp.box.Color = murderBoxColor
                    esp.box.Visible = murderBoxEnabled
                    esp.tracer.Color = murderTracerColor
                    esp.tracer.Visible = murderTracerEnabled
                elseif isSheriff(player) then
                    esp.box.Color = sheriffBoxColor
                    esp.box.Visible = sheriffBoxEnabled
                    esp.tracer.Color = sheriffTracerColor
                    esp.tracer.Visible = sheriffTracerEnabled
                elseif isInnocent(player) then
                    esp.box.Color = innocentBoxColor
                    esp.box.Visible = innocentBoxEnabled
                    esp.tracer.Color = innocentTracerColor
                    esp.tracer.Visible = innocentTracerEnabled
                else
                    esp.box.Color = box2dColor
                    esp.box.Visible = box2dEnabled and boxStates["Player"]
                    esp.tracer.Color = tracer2dColor
                    esp.tracer.Visible = tracer2dEnabled and tracerStates["Player"]
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

-- ========== COIN 2D BOX и TRACER (4-LINE) ==========
local coinDrawings = {} -- [coin] = {Line,Line,Line,Line, tracer=Line}
local COIN_PART_NAME = "MainCoin"

local function updateCoinBoxAndTracer(coin)
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
        local tracer = Drawing.new("Line")
        tracer.Color = coinTracerColor
        tracer.Thickness = 2
        tracer.Visible = false
        box.tracer = tracer
        coinDrawings[coin] = box
    else
        for i = 1, 4 do
            box[i].Color = coinBoxColor
        end
        box.tracer.Color = coinTracerColor
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

-- ========== GunDrop ESP и TRACER (4 линии) ==========
local gunDropLines = {} -- [GunDrop] = {Line,Line,Line,Line, tracer=Line}
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
                    line.Color = gunBoxColor
                    line.Thickness = 2
                    line.Transparency = 1
                    line.Visible = false
                    box[i] = line
                end
                local tracer = Drawing.new("Line")
                tracer.Color = gunTracerColor
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
                    box[i].Visible = gunBoxEnabled
                    box[i].Color = gunBoxColor
                end
                if gunTracerEnabled then
                    box.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    box.tracer.To = Vector2.new(center.X, center.Y)
                    box.tracer.Color = gunTracerColor
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
        update2dEsp(player, esp)
    end

    -- COIN ESP/TRACER
    if coinBoxEnabled or coinTracerEnabled then
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
                    box[i].Visible = coinBoxEnabled
                    box[i].Color = coinBoxColor
                end
                if coinTracerEnabled then
                    box.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    box.tracer.To = Vector2.new(center.X, center.Y)
                    box.tracer.Color = coinTracerColor
                    box.tracer.Visible = true
                else
                    box.tracer.Visible = false
                end
            else
                for i = 1, 4 do box[i].Visible = false end
                box.tracer.Visible = false
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

-- ========== Rayfield Menu Integration ==========
for category, defaultColor in pairs(categories) do
    boxStates[category] = false
    boxColors[category] = defaultColor
    tracerStates[category] = false
    tracerColors[category] = defaultColor

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
            elseif category == "Murder" then
                murderBoxColor = Color
            elseif category == "Sheriff" then
                sheriffBoxColor = Color
            elseif category == "Innocent" then
                innocentBoxColor = Color
            elseif category == "Coin" then
                coinBoxColor = Color
            elseif category == "Gun" then
                gunBoxColor = Color
            end
        end
    })

    -- ========== Tracer ==========
    EspTab:CreateToggle({
        Name = "Tracer ESP: " .. category,
        CurrentValue = false,
        Callback = function(Value)
            tracerStates[category] = Value
            if category == "Player" then
                tracer2dEnabled = Value
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
                tracer2dColor = Color
            elseif category == "Murder" then
                murderTracerColor = Color
            elseif category == "Sheriff" then
                sheriffTracerColor = Color
            elseif category == "Innocent" then
                innocentTracerColor = Color
            elseif category == "Coin" then
                coinTracerColor = Color
            elseif category == "Gun" then
                gunTracerColor = Color
            end
        end
    })
end
