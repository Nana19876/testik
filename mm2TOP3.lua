local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "ESP Menu",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "Sirius | Rayfield",
    ConfigurationSaving = { Enabled = false }
})

local EspTab = Window:CreateTab("ESP", 4483362458)
local BoxSection = EspTab:CreateSection("Box ESP")

local categories = {
    Player   = Color3.fromRGB(255,255,255),
    Trap     = Color3.fromRGB(255,200,0),
    Gun      = Color3.fromRGB(30,144,255),
    Murder   = Color3.fromRGB(255,30,60),
    Sheriff  = Color3.fromRGB(40,255,60),
    Innocent = Color3.fromRGB(200,255,255),
}

local boxStates = {}
local boxColors = {}
local boxTypes = {}

local boxVariants = {
    "2D Box",
    "3D Box",
    "Corner Box"
}

-- ====== ESP ONLY FOR PLAYERS (2D Box) ======
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local espCache = {}
local espConnection

local function createEsp(player)
    local drawings = {}
    drawings.box = Drawing.new("Square")
    drawings.box.Thickness = 2
    drawings.box.Filled = false
    drawings.box.Color = boxColors["Player"]
    drawings.box.Visible = false
    drawings.box.ZIndex = 2
    espCache[player] = drawings
end

local function removeEsp(player)
    if rawget(espCache, player) then
        for _, drawing in next, espCache[player] do
            drawing:Remove()
        end
        espCache[player] = nil
    end
end

local function updateEsp(player, esp)
    local character = player and player.Character
    if character then
        local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if torso then
            local pos, vis = camera:WorldToViewportPoint(torso.Position)
            if vis and boxStates["Player"] and boxTypes["Player"] == "2D Box" then
                esp.box.Visible = true
                local boxSize = Vector2.new(40, 40)
                esp.box.Size = boxSize
                esp.box.Position = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
                esp.box.Color = boxColors["Player"]
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

local function enablePlayerEsp()
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer then
            if not espCache[player] then
                createEsp(player)
            end
        end
    end

    players.PlayerAdded:Connect(function(player)
        if player ~= localPlayer then
            createEsp(player)
        end
    end)
    players.PlayerRemoving:Connect(function(player)
        removeEsp(player)
    end)

    espConnection = runService.RenderStepped:Connect(function()
        for player, drawings in next, espCache do
            updateEsp(player, drawings)
        end
    end)
end

local function disablePlayerEsp()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    for player, drawings in next, espCache do
        for _, drawing in next, drawings do
            drawing.Visible = false
        end
    end
end

-- ====== MENU INTEGRATION ======

for category, defaultColor in pairs(categories) do
    boxStates[category] = false
    boxColors[category] = defaultColor
    boxTypes[category] = boxVariants[1]

    EspTab:CreateToggle({
        Name = "Box ESP: " .. category,
        CurrentValue = false,
        Callback = function(Value)
            boxStates[category] = Value
            if category == "Player" then
                if Value then
                    enablePlayerEsp()
                else
                    disablePlayerEsp()
                end
            end
        end
    })

    EspTab:CreateColorPicker({
        Name = "Цвет для " .. category,
        Color = defaultColor,
        Callback = function(Color)
            boxColors[category] = Color
            if category == "Player" then
                for _, drawings in pairs(espCache) do
                    drawings.box.Color = Color
                end
            end
        end
    })

    EspTab:CreateDropdown({
        Name = "Вариант бокса для " .. category,
        Options = boxVariants,
        CurrentOption = boxVariants[1],
        MultiSelection = false,
        Callback = function(option)
            boxTypes[category] = option
            print("Box-тип для " .. category .. ": " .. option)
        end
    })
end
