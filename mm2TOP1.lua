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
    Coin     = Color3.fromRGB(255,215,0), -- Добавили монеты!
}
local boxStates, boxColors = {}, {}

local box2dEnabled = false
local box2dColor = Color3.fromRGB(255,255,255)
local murderBoxEnabled = false
local murderBoxColor = Color3.fromRGB(255,30,60)
local sheriffBoxEnabled = false
local sheriffBoxColor = Color3.fromRGB(40,255,60)
local coinBoxEnabled = false
local coinBoxColor = Color3.fromRGB(255,215,0)

-- ========== ESP 2D Box для Player, Murder, Sheriff ==========
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

local function create2dEsp(player)
    if espCache[player] then remove2dEsp(player) end
    local drawings = {}
    drawings.box = Drawing.new("Square")
    drawings.box.Thickness = 2
    drawings.box.Filled = false
    drawings.box.Color = box2dColor
    drawings.box.Visible = false
    drawings.box.ZIndex = 2
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
                esp.box.Size = newVector2(width, height)
                esp.box.Position = newVector2(round(x - width / 2, y - height / 2))
                -- Приоритет: Murder > Sheriff > Player
                if isMurderer(player) and murderBoxEnabled then
                    esp.box.Color = murderBoxColor
                    esp.box.Visible = true
                elseif isSheriff(player) and sheriffBoxEnabled then
                    esp.box.Color = sheriffBoxColor
                    esp.box.Visible = true
                elseif box2dEnabled and boxStates["Player"] then
                    esp.box.Color = box2dColor
                    esp.box.Visible = true
                else
                    esp.box.Visible = false
                end
            else
                esp.box.Visible = false
            end
        else
            esp.box.Visible = false
        end
    else
        esp.box.Visible = false
    end
end

-- ========== COIN ESP ==========
local Workspace = game:GetService("Workspace")
local coinBoxes = {}
local COIN_NAME = "Coin" -- Можно указать "Coin" или "Coins" — главное чтобы работало для твоей карты

local function createCoinBox(coin)
    if coinBoxes[coin] then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = coinBoxColor
    box.Visible = false
    coinBoxes[coin] = box
end

local function removeCoinBox(coin)
    if coinBoxes[coin] then
        coinBoxes[coin]:Remove()
        coinBoxes[coin] = nil
    end
end

local function updateCoinBox(coin, box)
    if not coin or not coin.Parent then
        box.Visible = false
        return
    end
    if not coinBoxEnabled then
        box.Visible = false
        return
    end
    local pos, visible, depth = Camera:WorldToViewportPoint(coin.Position)
    if visible and depth > 0 then
        local scale = math.clamp(1 / (depth * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000, 7, 80)
        local width, height = math.round(3 * scale), math.round(3 * scale)
        local x, y = math.round(pos.X), math.round(pos.Y)
        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(x - width/2, y - height/2)
        box.Color = coinBoxColor
        box.Visible = true
    else
        box.Visible = false
    end
end

-- Игроки ESP
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then create2dEsp(player) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then create2dEsp(player) end
end)
Players.PlayerRemoving:Connect(function(player)
    remove2dEsp(player)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    -- ESP для игроков
    for player, esp in pairs(espCache) do
        update2dEsp(player, esp)
    end

    -- ESP для монет
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(COIN_NAME:lower()) then
            createCoinBox(obj)
        end
    end
    for coin, box in pairs(coinBoxes) do
        if not coin:IsDescendantOf(Workspace) then
            removeCoinBox(coin)
        else
            updateCoinBox(coin, box)
        end
    end
end)

-- ========== Rayfield Menu Integration ==========

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
            elseif category == "Coin" then
                coinBoxEnabled = Value
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
            elseif category == "Coin" then
                coinBoxColor = Color
                for coin, box in pairs(coinBoxes) do
                    box.Color = coinBoxColor
                end
            end
        end
    })
end
