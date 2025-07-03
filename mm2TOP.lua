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

-- ========== ESP 2D Box для Player, Murder, Sheriff, Innocent ==========
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
                -- Приоритет: Murder > Sheriff > Innocent > Player
                if isMurderer(player) and murderBoxEnabled then
                    esp.box.Color = murderBoxColor
                    esp.box.Visible = true
                elseif isSheriff(player) and sheriffBoxEnabled then
                    esp.box.Color = sheriffBoxColor
                    esp.box.Visible = true
                elseif isInnocent(player) and innocentBoxEnabled then
                    esp.box.Color = innocentBoxColor
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
local coinDrawings = {} -- [coin] = {Line,Line,Line,Line}
local COIN_PART_NAME = "MainCoin" -- Или CoinVisual если у тебя реально так называется деталь!

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

local function removeCoinBox(coin)
    local box = coinDrawings[coin]
    if box then
        for i = 1, 4 do
            box[i].Visible = false
            box[i]:Remove()
        end
        coinDrawings[coin] = nil
    end
end

-- ========== GunDrop ESP (4 линии) ==========
local gunDropLines = {} -- [GunDrop] = {Line,Line,Line,Line}
local function updateGunDropESP()
    if not gunBoxEnabled then
        for obj, box in pairs(gunDropLines) do
            for i = 1, 4 do if box[i] then box[i].Visible = false end end
        end
        return
    end
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
    end
    for obj, box in pairs(gunDropLines) do
        if not targets[obj] or not obj:IsDescendantOf(workspace) then
            for i = 1, 4 do if box[i] then box[i]:Remove() end end
            gunDropLines[obj] = nil
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    -- ESP для игроков
    for player, esp in pairs(espCache) do
        update2dEsp(player, esp)
    end

    -- COIN ESP
    if coinBoxEnabled then
        local coins = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == COIN_PART_NAME then
                coins[obj] = true
            end
        end
        for coin,_ in pairs(coins) do
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
        for coin, _ in pairs(coinDrawings) do
            if not coins[coin] or not coin:IsDescendantOf(workspace) then
                removeCoinBox(coin)
            end
        end
    else
        for _, box in pairs(coinDrawings) do
            for i = 1, 4 do
                box[i].Visible = false
            end
        end
    end

    -- GunDrop ESP (4 линии)
    updateGunDropESP()
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
        Name = "color" .. category,
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

EspTab:CreateSection("Tracer esp (игроки и предметы)")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Tracers = {} -- [object or player] = Drawing.Line

-- Переменные для игроков
local tracerMurderEnabled = false
local tracerSheriffEnabled = false
local tracerInnocentEnabled = false
local murderColor = Color3.fromRGB(255,30,60)
local sheriffColor = Color3.fromRGB(40,255,60)
local innocentColor = Color3.fromRGB(200,255,255)

-- Переменные для предметов
local tracerTrapEnabled = false
local tracerGunEnabled = false
local tracerCoinEnabled = false
local trapColor = Color3.fromRGB(255,200,0)
local gunColor = Color3.fromRGB(30,144,255)
local coinColor = Color3.fromRGB(255,215,0)

local tracerThickness = 3.5 -- Жирность линий

-- Названия объектов
local TRAP_PART_NAME = "Trap"
local GUN_PART_NAME = "GunDrop"
local COIN_PART_NAME = "MainCoin" -- Или "CoinVisual", если нужно

-- Тогглы и палитры игроков
EspTab:CreateToggle({
    Name = "Tracer: Murder",
    CurrentValue = false,
    Callback = function(Value)
        tracerMurderEnabled = Value
        if not Value then for obj, line in pairs(Tracers) do if line.Role == "Murder" then line.Visible = false end end end
    end
})
EspTab:CreateColorPicker({
    Name = "color Tracer: Murder",
    Color = murderColor,
    Callback = function(Color)
        murderColor = Color
        for obj, line in pairs(Tracers) do if line.Role == "Murder" then line.Color = murderColor end end
    end
})
EspTab:CreateToggle({
    Name = "Tracer: Sheriff",
    CurrentValue = false,
    Callback = function(Value)
        tracerSheriffEnabled = Value
        if not Value then for obj, line in pairs(Tracers) do if line.Role == "Sheriff" then line.Visible = false end end end
    end
})
EspTab:CreateColorPicker({
    Name = "color Tracer: Sheriff",
    Color = sheriffColor,
    Callback = function(Color)
        sheriffColor = Color
        for obj, line in pairs(Tracers) do if line.Role == "Sheriff" then line.Color = sheriffColor end end
    end
})
EspTab:CreateToggle({
    Name = "Tracer: Innocent",
    CurrentValue = false,
    Callback = function(Value)
        tracerInnocentEnabled = Value
        if not Value then for obj, line in pairs(Tracers) do if line.Role == "Innocent" then line.Visible = false end end end
    end
})
EspTab:CreateColorPicker({
    Name = "color Tracer: Innocent",
    Color = innocentColor,
    Callback = function(Color)
        innocentColor = Color
        for obj, line in pairs(Tracers) do if line.Role == "Innocent" then line.Color = innocentColor end end
    end
})

-- Тогглы и палитры предметов
EspTab:CreateToggle({
    Name = "Tracer: Trap",
    CurrentValue = false,
    Callback = function(Value)
        tracerTrapEnabled = Value
        if not Value then for obj, line in pairs(Tracers) do if line.ObjType == "Trap" then line.Visible = false end end end
    end
})
EspTab:CreateColorPicker({
    Name = "color Tracer: Trap",
    Color = trapColor,
    Callback = function(Color)
        trapColor = Color
        for obj, line in pairs(Tracers) do if line.ObjType == "Trap" then line.Color = trapColor end end
    end
})
EspTab:CreateToggle({
    Name = "Tracer: Gun",
    CurrentValue = false,
    Callback = function(Value)
        tracerGunEnabled = Value
        if not Value then for obj, line in pairs(Tracers) do if line.ObjType == "Gun" then line.Visible = false end end end
    end
})
EspTab:CreateColorPicker({
    Name = "color Tracer: Gun",
    Color = gunColor,
    Callback = function(Color)
        gunColor = Color
        for obj, line in pairs(Tracers) do if line.ObjType == "Gun" then line.Color = gunColor end end
    end
})
EspTab:CreateToggle({
    Name = "Tracer: Coin",
    CurrentValue = false,
    Callback = function(Value)
        tracerCoinEnabled = Value
        if not Value then for obj, line in pairs(Tracers) do if line.ObjType == "Coin" then line.Visible = false end end end
    end
})
EspTab:CreateColorPicker({
    Name = "color Tracer: Coin",
    Color = coinColor,
    Callback = function(Color)
        coinColor = Color
        for obj, line in pairs(Tracers) do if line.ObjType == "Coin" then line.Color = coinColor end end
    end
})

-- Функция для прижатия к экрану
local function clampToScreen(x, y)
    x = math.clamp(x, 0, Camera.ViewportSize.X)
    y = math.clamp(y, 0, Camera.ViewportSize.Y)
    return Vector2.new(x, y)
end

-- Определение ролей
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

-- Чистим, если игрок/объект исчез
Players.PlayerRemoving:Connect(function(player)
    if Tracers[player] then Tracers[player]:Remove() Tracers[player] = nil end
end)
local function cleanupTracers(valid)
    for obj, line in pairs(Tracers) do
        if not valid[obj] then line:Remove() Tracers[obj] = nil end
    end
end

RunService.RenderStepped:Connect(function()
    local valid = {}

    -- Игроки (murder, sheriff, innocent)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local role, color, enabled = nil, nil, false
            if isMurderer(player) and tracerMurderEnabled then
                role = "Murder"; color = murderColor; enabled = true
            elseif isSheriff(player) and tracerSheriffEnabled then
                role = "Sheriff"; color = sheriffColor; enabled = true
            elseif isInnocent(player) and tracerInnocentEnabled then
                role = "Innocent"; color = innocentColor; enabled = true
            end

            if enabled then
                valid[player] = true
                if not Tracers[player] then
                    local tracer = Drawing.new("Line")
                    tracer.Thickness = tracerThickness
                    tracer.Color = color
                    tracer.Transparency = 1
                    tracer.Visible = false
                    tracer.Role = role
                    Tracers[player] = tracer
                end
                local tracer = Tracers[player]
                tracer.Color = color
                tracer.Role = role
                tracer.Thickness = tracerThickness

                local rootPart = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local toPos
                if onScreen and screenPos.Z > 0 then
                    toPos = Vector2.new(screenPos.X, screenPos.Y)
                else
                    toPos = clampToScreen(screenPos.X, screenPos.Y)
                end
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = toPos
                tracer.Visible = true
            elseif Tracers[player] then
                Tracers[player].Visible = false
                Tracers[player].Role = nil
            end
        elseif Tracers[player] then
            Tracers[player].Visible = false
            Tracers[player].Role = nil
        end
    end

    -- Trap
    if tracerTrapEnabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == TRAP_PART_NAME then
                valid[obj] = true
                if not Tracers[obj] then
                    local line = Drawing.new("Line")
                    line.Thickness = tracerThickness
                    line.Color = trapColor
                    line.Transparency = 1
                    line.Visible = false
                    line.ObjType = "Trap"
                    Tracers[obj] = line
                end
                local line = Tracers[obj]
                line.Color = trapColor
                line.Thickness = tracerThickness

                local screenPos, onScreen = Camera:WorldToViewportPoint(obj.Position)
                local toPos
                if onScreen and screenPos.Z > 0 then
                    toPos = Vector2.new(screenPos.X, screenPos.Y)
                else
                    toPos = clampToScreen(screenPos.X, screenPos.Y)
                end
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = toPos
                line.Visible = true
            elseif Tracers[obj] and Tracers[obj].ObjType == "Trap" then
                Tracers[obj].Visible = false
            end
        end
    else
        for obj, line in pairs(Tracers) do if line.ObjType == "Trap" then line.Visible = false end end
    end

    -- Gun
    if tracerGunEnabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == GUN_PART_NAME then
                valid[obj] = true
                if not Tracers[obj] then
                    local line = Drawing.new("Line")
                    line.Thickness = tracerThickness
                    line.Color = gunColor
                    line.Transparency = 1
                    line.Visible = false
                    line.ObjType = "Gun"
                    Tracers[obj] = line
                end
                local line = Tracers[obj]
                line.Color = gunColor
                line.Thickness = tracerThickness

                local screenPos, onScreen = Camera:WorldToViewportPoint(obj.Position)
                local toPos
                if onScreen and screenPos.Z > 0 then
                    toPos = Vector2.new(screenPos.X, screenPos.Y)
                else
                    toPos = clampToScreen(screenPos.X, screenPos.Y)
                end
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = toPos
                line.Visible = true
            elseif Tracers[obj] and Tracers[obj].ObjType == "Gun" then
                Tracers[obj].Visible = false
            end
        end
    else
        for obj, line in pairs(Tracers) do if line.ObjType == "Gun" then line.Visible = false end end
    end

    -- Coin
    if tracerCoinEnabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == COIN_PART_NAME then
                valid[obj] = true
                if not Tracers[obj] then
                    local line = Drawing.new("Line")
                    line.Thickness = tracerThickness
                    line.Color = coinColor
                    line.Transparency = 1
                    line.Visible = false
                    line.ObjType = "Coin"
                    Tracers[obj] = line
                end
                local line = Tracers[obj]
                line.Color = coinColor
                line.Thickness = tracerThickness

                local screenPos, onScreen = Camera:WorldToViewportPoint(obj.Position)
                local toPos
                if onScreen and screenPos.Z > 0 then
                    toPos = Vector2.new(screenPos.X, screenPos.Y)
                else
                    toPos = clampToScreen(screenPos.X, screenPos.Y)
                end
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = toPos
                line.Visible = true
            elseif Tracers[obj] and Tracers[obj].ObjType == "Coin" then
                Tracers[obj].Visible = false
            end
        end
    else
        for obj, line in pairs(Tracers) do if line.ObjType == "Coin" then line.Visible = false end end
    end

    cleanupTracers(valid)
end)

EspTab:CreateSection("Outlining ESP (Players and Roles)")

-- Highlight state toggles
local colorPlayerEnabled = false
local murderHighlightEnabled = false
local sheriffHighlightEnabled = false
local innocentHighlightEnabled = false

-- Highlight colors
local colorPlayerColor = Color3.fromRGB(255, 255, 255)
local murderHighlightColor = Color3.fromRGB(255, 30, 60)
local sheriffHighlightColor = Color3.fromRGB(40, 255, 60)
local innocentHighlightColor = Color3.fromRGB(200, 255, 255)

-- Role checks
local function isMurder(player)
	local bp, ch = player:FindFirstChild("Backpack"), player.Character
	return (bp and bp:FindFirstChild("Knife")) or (ch and ch:FindFirstChild("Knife"))
end
local function isSheriff(player)
	local bp, ch = player:FindFirstChild("Backpack"), player.Character
	return (bp and bp:FindFirstChild("Gun")) or (ch and ch:FindFirstChild("Gun"))
end
local function isInnocent(player)
	return not isMurder(player) and not isSheriff(player) and player ~= LocalPlayer
end

-- Apply or update highlight on player
local function ApplyHighlight(player)
	if player == LocalPlayer then return end
	if not player.Character then return end
	local char = player.Character

	-- Ensure Highlight exists
	local highlight = char:FindFirstChild("Highlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "Highlight"
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0
		highlight.Adornee = char
		highlight.Parent = char
	end

	-- Always reset visibility
	highlight.Enabled = false

	-- Apply role-based color
	if isMurder(player) and murderHighlightEnabled then
		highlight.OutlineColor = murderHighlightColor
		highlight.Enabled = true
	elseif isSheriff(player) and sheriffHighlightEnabled then
		highlight.OutlineColor = sheriffHighlightColor
		highlight.Enabled = true
	elseif isInnocent(player) and innocentHighlightEnabled then
		highlight.OutlineColor = innocentHighlightColor
		highlight.Enabled = true
	elseif colorPlayerEnabled then
		highlight.OutlineColor = colorPlayerColor
		highlight.Enabled = true
	end
end

-- Update highlights for all players
local function UpdateHighlights()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			ApplyHighlight(player)
		end
	end
end

-- Hook into new players and respawns
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		ApplyHighlight(player)
	end)
end)
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		ApplyHighlight(player)
	end
	player.CharacterAdded:Connect(function()
		task.wait(1)
		ApplyHighlight(player)
	end)
end

-- Run every frame to recheck role-based changes
RunService.RenderStepped:Connect(UpdateHighlights)

-- === UI bindings ===
EspTab:CreateToggle({
	Name = "Outline: All Players",
	CurrentValue = false,
	Callback = function(Value)
		colorPlayerEnabled = Value
	end
})
EspTab:CreateColorPicker({
	Name = "Outline Color: All Players",
	Color = colorPlayerColor,
	Callback = function(Color)
		colorPlayerColor = Color
	end
})

EspTab:CreateToggle({
	Name = "Outline: Murder",
	CurrentValue = false,
	Callback = function(Value)
		murderHighlightEnabled = Value
	end
})
EspTab:CreateColorPicker({
	Name = "Outline Color: Murder",
	Color = murderHighlightColor,
	Callback = function(Color)
		murderHighlightColor = Color
	end
})

EspTab:CreateToggle({
	Name = "Outline: Sheriff",
	CurrentValue = false,
	Callback = function(Value)
		sheriffHighlightEnabled = Value
	end
})
EspTab:CreateColorPicker({
	Name = "Outline Color: Sheriff",
	Color = sheriffHighlightColor,
	Callback = function(Color)
		sheriffHighlightColor = Color
	end
})

EspTab:CreateToggle({
	Name = "Outline: Innocent",
	CurrentValue = false,
	Callback = function(Value)
		innocentHighlightEnabled = Value
	end
})
EspTab:CreateColorPicker({
	Name = "Outline Color: Innocent",
	Color = innocentHighlightColor,
	Callback = function(Color)
		innocentHighlightColor = Color
	end
})

-- Добавлено: 3D Box Toggle
EspTab:CreateSection("3D Box")

local box3dEnabled = false
local box3dColor = Color3.fromRGB(255, 0, 0)

EspTab:CreateToggle({
    Name = "3D Box: Players",
    CurrentValue = false,
    Callback = function(Value)
        box3dEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "3D Box Color",
    Color = box3dColor,
    Callback = function(Color)
        box3dColor = Color
    end
})

-- Обновление 3D Box каждый кадр
RunService.RenderStepped:Connect(function()
    if not box3dEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local part = player.Character.HumanoidRootPart
            local adorn = part:FindFirstChild("BoxAdornment")
            if not adorn then
                adorn = Instance.new("BoxHandleAdornment")
                adorn.Name = "BoxAdornment"
                adorn.Adornee = part
                adorn.AlwaysOnTop = true
                adorn.ZIndex = 0
                adorn.Size = Vector3.new(3, 5, 1.5)
                adorn.Color3 = box3dColor
                adorn.Transparency = 0.5
                adorn.Parent = part
            end
            adorn.Visible = true
            adorn.Color3 = box3dColor
        end
    end
end)
