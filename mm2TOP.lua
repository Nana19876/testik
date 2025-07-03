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

-- ====== ESP ONLY FOR PLAYERS ======
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local espCache = {}
local espConnection -- чтобы останавливать рендер

local function createEsp(player)
    local drawings = {}

    drawings.box = Drawing.new("Square")
    drawings.box.Thickness = 1
    drawings.box.Filled = false
    drawings.box.Color = boxColors["Player"]
    drawings.box.Visible = false
    drawings.box.ZIndex = 2

    drawings.boxoutline = Drawing.new("Square")
    drawings.boxoutline.Thickness = 3
    drawings.boxoutline.Filled = false
    drawings.boxoutline.Color = Color3.new(0,0,0)
    drawings.boxoutline.Visible = false
    drawings.boxoutline.ZIndex = 1

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
        local head = character:FindFirstChild("Head")
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if head and humanoidRootPart then
            local pos, vis = camera:WorldToViewportPoint(humanoidRootPart.Position)
            if vis and boxStates["Player"] then
                esp.box.Visible = true
                esp.boxoutline.Visible = true
                local size = Vector2.new(40, 60) -- Можно кастомизировать
                esp.box.Size = size
                esp.box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                esp.box.Color = boxColors["Player"]
                esp.boxoutline.Size = size
                esp.boxoutline.Position = esp.box.Position
            else
                esp.box.Visible = false
                esp.boxoutline.Visible = false
            end
        else
            esp.box.Visible = false
            esp.boxoutline.Visible = false
        end
    else
        esp.box.Visible = false
        esp.boxoutline.Visible = false
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

    EspTab:CreateToggle({
        Name = "Box ESP: " .. category,
        CurrentValue = false,
        Callback = function(Value)
            boxStates[category] = Value
            if category == "Player" then
                if Value then
                    enablePlayerEsp()
                    print("Box ESP для Player включён")
                else
                    disablePlayerEsp()
                    print("Box ESP для Player выключён")
                end
            else
                print("Box ESP для " .. category .. (Value and " включён" or " выключен"))
                -- Для других категорий сюда вставишь свой esp-код, если появится
            end
        end
    })

    EspTab:CreateColorPicker({
        Name = "Цвет для " .. category,
        Color = defaultColor,
        Callback = function(Color)
            boxColors[category] = Color
            if category == "Player" then
                -- Меняем цвет уже существующих боксов
                for _, drawings in pairs(espCache) do
                    drawings.box.Color = Color
                end
            end
            print("Цвет Box ESP для " .. category .. " изменён", Color)
        end
    })
end
