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
    Murder   = Color3.fromRGB(255,30,60),
    Sheriff  = Color3.fromRGB(40,255,60),
    Innocent = Color3.fromRGB(200,255,255),
}

local boxStates, boxColors = {}, {}
local tracerStates, tracerColors = {}, {}

-- ========== Меню Box:ESP ==========
EspTab:CreateSection("Box:ESP")
for cat, col in pairs(categories) do
    boxStates[cat] = false
    boxColors[cat] = col
    EspTab:CreateToggle({
        Name = "Box ESP: " .. cat,
        CurrentValue = false,
        Callback = function(v) boxStates[cat] = v end
    })
    EspTab:CreateColorPicker({
        Name = "Цвет для " .. cat,
        Color = col,
        Callback = function(c) boxColors[cat] = c end
    })
end

-- ========== Меню Tracer:ESP ==========
EspTab:CreateSection("Tracer:ESP")
for cat, col in pairs(categories) do
    tracerStates[cat] = false
    tracerColors[cat] = col
    EspTab:CreateToggle({
        Name = "Tracer ESP: " .. cat,
        CurrentValue = false,
        Callback = function(v) tracerStates[cat] = v end
    })
    EspTab:CreateColorPicker({
        Name = "Цвет трейсера " .. cat,
        Color = col,
        Callback = function(c) tracerColors[cat] = c end
    })
end

-- ========== Реализация ESP ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espCache = {}

local function isMurderer(player)
    local bp, ch = player:FindFirstChild("Backpack"), player.Character
    return (bp and bp:FindFirstChild("Knife")) or (ch and ch:FindFirstChild("Knife"))
end
local function isSheriff(player)
    local bp, ch = player:FindFirstChild("Backpack"), player.Character
    return (bp and bp:FindFirstChild("Gun")) or (ch and ch:FindFirstChild("Gun"))
end
local function isInnocent(player)
    return not isMurderer(player) and not isSheriff(player) and player ~= LocalPlayer
end

local function getRole(player)
    if isMurderer(player) then return "Murder"
    elseif isSheriff(player) then return "Sheriff"
    elseif isInnocent(player) then return "Innocent"
    else return "Player" end
end

local function createEsp(player)
    if espCache[player] then for _,obj in pairs(espCache[player]) do if obj.Remove then obj:Remove() end end end
    local box = Drawing.new("Square")
    box.Thickness, box.Filled, box.Visible = 2, false, false
    local tracer = Drawing.new("Line")
    tracer.Thickness, tracer.Visible = 2, false
    espCache[player] = {box=box, tracer=tracer}
end

local function removeEsp(player)
    if espCache[player] then for _,obj in pairs(espCache[player]) do if obj.Remove then obj:Remove() end end espCache[player]=nil end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createEsp(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createEsp(p) end end)
Players.PlayerRemoving:Connect(removeEsp)

game:GetService("RunService").RenderStepped:Connect(function()
    for player, draw in pairs(espCache) do
        local ch = player.Character
        local root = ch and (ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso"))
        if root then
            local pos, vis, z = Camera:WorldToViewportPoint(root.Position)
            if vis and z > 0 then
                local role = getRole(player)
                -- Box
                draw.box.Size = Vector2.new(45, 65)
                draw.box.Position = Vector2.new(pos.X-22, pos.Y-32)
                draw.box.Color = boxColors[role]
                draw.box.Visible = boxStates[role]
                -- Tracer
                draw.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                draw.tracer.To = Vector2.new(pos.X, pos.Y)
                draw.tracer.Color = tracerColors[role]
                draw.tracer.Visible = tracerStates[role]
            else
                draw.box.Visible, draw.tracer.Visible = false, false
            end
        else
            draw.box.Visible, draw.tracer.Visible = false, false
        end
    end
end)
