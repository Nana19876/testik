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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local boxStates, boxColors = {}, {}
local tracerStates, tracerColors = {}, {}

-- --- Переменные ESP (аналогично твоим, но короче) ---
local states = {
    Player = {Box=false, Color=categories.Player, Tracer=false, TracerColor=categories.Player},
    Murder = {Box=false, Color=categories.Murder, Tracer=false, TracerColor=categories.Murder},
    Sheriff = {Box=false, Color=categories.Sheriff, Tracer=false, TracerColor=categories.Sheriff},
    Innocent = {Box=false, Color=categories.Innocent, Tracer=false, TracerColor=categories.Innocent},
    Coin = {Box=false, Color=categories.Coin, Tracer=false, TracerColor=categories.Coin},
    Gun = {Box=false, Color=categories.Gun, Tracer=false, TracerColor=categories.Gun}
}

-- Кэшируем игроков, монеты и GunDrop через события!
local espCache = {}
local coinCache = {}   -- [part] = true
local gunCache = {}    -- [part] = true

-- --- Быстрые утилиты ---
local function isMurderer(player)
    local c, b = player.Character, player:FindFirstChild("Backpack")
    return (b and b:FindFirstChild("Knife")) or (c and c:FindFirstChild("Knife"))
end
local function isSheriff(player)
    local c, b = player.Character, player:FindFirstChild("Backpack")
    return (b and b:FindFirstChild("Gun")) or (c and c:FindFirstChild("Gun"))
end
local function isInnocent(player)
    return not isMurderer(player) and not isSheriff(player) and player ~= LocalPlayer
end

-- --- ESP создание/удаление ---
local function createESP(player)
    if espCache[player] then return end
    local box = Drawing.new("Square")
    box.Thickness, box.Filled, box.Visible = 2, false, false
    local tracer = Drawing.new("Line")
    tracer.Thickness, tracer.Visible = 2, false
    espCache[player] = {box=box, tracer=tracer}
end
local function removeESP(player)
    local d = espCache[player]
    if d then d.box:Remove() d.tracer:Remove() espCache[player]=nil end
end

-- --- COIN ESP ---
local function createCoinESP(coin)
    if coinCache[coin] then return end
    local lines = {}
    for i=1,4 do
        local l = Drawing.new("Line")
        l.Thickness, l.Transparency, l.Visible = 2, 1, false
        lines[i] = l
    end
    coinCache[coin] = lines
end
local function removeCoinESP(coin)
    local lines = coinCache[coin]
    if lines then for i=1,4 do lines[i]:Remove() end coinCache[coin]=nil end
end

-- --- GUN ESP ---
local function createGunESP(gun)
    if gunCache[gun] then return end
    local lines = {}
    for i=1,4 do
        local l = Drawing.new("Line")
        l.Thickness, l.Transparency, l.Visible = 2, 1, false
        lines[i] = l
    end
    gunCache[gun] = lines
end
local function removeGunESP(gun)
    local lines = gunCache[gun]
    if lines then for i=1,4 do lines[i]:Remove() end gunCache[gun]=nil end
end

-- --- Автоматическое отслеживание монет/гандропа (по событиям) ---
local function scanCoinsAndGuns()
    -- Монеты
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "MainCoin" then
            if not coinCache[v] then createCoinESP(v) end
        end
    end
    for coin in pairs(coinCache) do
        if not coin or not coin:IsDescendantOf(workspace) then removeCoinESP(coin) end
    end
    -- GunDrop
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "GunDrop" then
            if not gunCache[v] then createGunESP(v) end
        end
    end
    for gun in pairs(gunCache) do
        if not gun or not gun:IsDescendantOf(workspace) then removeGunESP(gun) end
    end
end

-- Редкий вызов поиска (раз в 0.25 сек)
task.spawn(function()
    while true do
        scanCoinsAndGuns()
        task.wait(0.25)
    end
end)

-- --- Игроки: кэш и слушатели ---
for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

-- --- Главный легкий RenderStepped ---
RunService.RenderStepped:Connect(function()
    -- Игроки
    for player,draw in pairs(espCache) do
        local char = player and player.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
        if root then
            local pos, onscreen, z = Camera:WorldToViewportPoint(root.Position)
            if onscreen and z > 0 then
                local scale = math.clamp(1/(z*math.tan(math.rad(Camera.FieldOfView/2))*2)*1000, 7, 120)
                local w, h = 4*scale, 5*scale
                draw.box.Size = Vector2.new(w, h)
                draw.box.Position = Vector2.new(math.round(pos.X-w/2), math.round(pos.Y-h/2))

                -- Определяем роль
                local role, state
                if isMurderer(player) then role,state = "Murder",states.Murder
                elseif isSheriff(player) then role,state = "Sheriff",states.Sheriff
                elseif isInnocent(player) then role,state = "Innocent",states.Innocent
                else role,state = "Player",states.Player end

                draw.box.Color = state.Color
                draw.box.Visible = state.Box
                -- Tracer
                draw.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                draw.tracer.To = Vector2.new(pos.X, pos.Y)
                draw.tracer.Color = state.TracerColor
                draw.tracer.Visible = state.Tracer
            else
                draw.box.Visible, draw.tracer.Visible = false, false
            end
        else
            draw.box.Visible, draw.tracer.Visible = false, false
        end
    end
    -- Монеты
    for coin,lines in pairs(coinCache) do
        local pos, on, z = Camera:WorldToViewportPoint(coin.Position)
        if on and states.Coin.Box then
            local s = 14 -- половина размера
            local c = Vector2.new(pos.X, pos.Y)
            local pts = {
                c+Vector2.new(-s,-s), c+Vector2.new(-s,s),
                c+Vector2.new(s,s),   c+Vector2.new(s,-s)
            }
            for i=1,4 do
                lines[i].From = pts[i]
                lines[i].To = pts[i%4+1]
                lines[i].Color = states.Coin.Color
                lines[i].Visible = true
            end
        else
            for i=1,4 do lines[i].Visible = false end
        end
    end
    -- GunDrop
    for gun,lines in pairs(gunCache) do
        local pos, on, z = Camera:WorldToViewportPoint(gun.Position)
        if on and states.Gun.Box then
            local s = 18
            local c = Vector2.new(pos.X, pos.Y)
            local pts = {
                c+Vector2.new(-s,-s), c+Vector2.new(-s,s),
                c+Vector2.new(s,s),   c+Vector2.new(s,-s)
            }
            for i=1,4 do
                lines[i].From = pts[i]
                lines[i].To = pts[i%4+1]
                lines[i].Color = states.Gun.Color
                lines[i].Visible = true
            end
        else
            for i=1,4 do lines[i].Visible = false end
        end
    end
end)

-- --- Rayfield Меню ---
for cat,def in pairs(categories) do
    EspTab:CreateToggle({
        Name = "Box ESP: " .. cat,
        CurrentValue = false,
        Callback = function(v) states[cat].Box = v end
    })
    EspTab:CreateColorPicker({
        Name = "Цвет для " .. cat,
        Color = def,
        Callback = function(color) states[cat].Color = color end
    })
    EspTab:CreateToggle({
        Name = "Tracer ESP: " .. cat,
        CurrentValue = false,
        Callback = function(v) states[cat].Tracer = v end
    })
    EspTab:CreateColorPicker({
        Name = "Цвет трейсера " .. cat,
        Color = def,
        Callback = function(color) states[cat].TracerColor = color end
    })
end
