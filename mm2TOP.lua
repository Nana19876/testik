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

-- Player/Role Highlight state toggles
local colorPlayerEnabled = false
local murderHighlightEnabled = false
local sheriffHighlightEnabled = false
local innocentHighlightEnabled = false

-- Object Highlight toggles
local trapHighlightEnabled = false
local gunHighlightEnabled = false
local coinHighlightEnabled = false

-- Highlight colors
local colorPlayerColor = Color3.fromRGB(255, 255, 255)
local murderHighlightColor = Color3.fromRGB(255, 30, 60)
local sheriffHighlightColor = Color3.fromRGB(40, 255, 60)
local innocentHighlightColor = Color3.fromRGB(200, 255, 255)
local trapHighlightColor = Color3.fromRGB(255, 200, 0)
local gunHighlightColor = Color3.fromRGB(30, 144, 255)
local coinHighlightColor = Color3.fromRGB(255, 215, 0)

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

-- ==================== OBJECTS ====================

local Workspace = game:GetService("Workspace")
local objectHighlightRefs = {} -- store for cleanup

local function UpdateObjectHighlights(objectName, color, enabled)
	-- Удалить старые highlights если выключено
	if not enabled then
		if objectHighlightRefs[objectName] then
			for _, hl in pairs(objectHighlightRefs[objectName]) do
				if hl and hl.Parent then
					hl:Destroy()
				end
			end
			objectHighlightRefs[objectName] = nil
		end
		return
	end
	objectHighlightRefs[objectName] = objectHighlightRefs[objectName] or {}

	-- Получить объекты по имени
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find(objectName:lower()) then
			local parent = obj.Parent
			local highlight = parent and parent:FindFirstChild("Highlight_" .. objectName)
			if not highlight then
				highlight = Instance.new("Highlight")
				highlight.Name = "Highlight_" .. objectName
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 0
				highlight.Adornee = parent
				highlight.Parent = parent
				table.insert(objectHighlightRefs[objectName], highlight)
			end
			highlight.OutlineColor = color
			highlight.Enabled = true
		end
	end
end

-- Обновление всех highlights
local function UpdateHighlights()
	-- Игроки
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			ApplyHighlight(player)
		end
	end
	-- Объекты
	UpdateObjectHighlights("trap", trapHighlightColor, trapHighlightEnabled)
	UpdateObjectHighlights("gun", gunHighlightColor, gunHighlightEnabled)
	UpdateObjectHighlights("coin", coinHighlightColor, coinHighlightEnabled)
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

RunService.RenderStepped:Connect(UpdateHighlights)

-- === UI bindings ===
EspTab:CreateToggle({
	Name = "Outline: All Players",
	CurrentValue = false,
	Callback = function(Value) colorPlayerEnabled = Value end
})
EspTab:CreateColorPicker({
	Name = "Outline Color: All Players",
	Color = colorPlayerColor,
	Callback = function(Color) colorPlayerColor = Color end
})

EspTab:CreateToggle({
	Name = "Outline: Murder",
	CurrentValue = false,
	Callback = function(Value) murderHighlightEnabled = Value end
})
EspTab:CreateColorPicker({
	Name = "Outline Color: Murder",
	Color = murderHighlightColor,
	Callback = function(Color) murderHighlightColor = Color end
})

EspTab:CreateToggle({
	Name = "Outline: Sheriff",
	CurrentValue = false,
	Callback = function(Value) sheriffHighlightEnabled = Value end
})
EspTab:CreateColorPicker({
	Name = "Outline Color: Sheriff",
	Color = sheriffHighlightColor,
	Callback = function(Color) sheriffHighlightColor = Color end
})

EspTab:CreateToggle({
	Name = "Outline: Innocent",
	CurrentValue = false,
	Callback = function(Value) innocentHighlightEnabled = Value end
})
EspTab:CreateColorPicker({
	Name = "Outline Color: Innocent",
	Color = innocentHighlightColor,
	Callback = function(Color) innocentHighlightColor = Color end
})

-- =========== Новые опции для Trap, Gun, Coin ===========

EspTab:CreateToggle({
	Name = "Outline: Coin",
	CurrentValue = false,
	Callback = function(Value) coinHighlightEnabled = Value end
})

EspTab:CreateColorPicker({
	Name = "Outline Color: Coin",
	Color = coinHighlightColor,
	Callback = function(Color)
		coinHighlightColor = Color
	end
})

-- === GUI Section ===
EspTab:CreateSection("3D Box")

-- Toggles
local box3dEnabled = false
local box3dMurderEnabled = false
local box3dSheriffEnabled = false
local box3dInnocentEnabled = false

-- Colors
local box3dColor = Color3.fromRGB(255, 255, 255)
local box3dMurderColor = Color3.fromRGB(255, 30, 60)
local box3dSheriffColor = Color3.fromRGB(40, 255, 60)
local box3dInnocentColor = Color3.fromRGB(200, 255, 255)

-- GUI Binds
EspTab:CreateToggle({ Name = "3D Box: Players", CurrentValue = false, Callback = function(v) box3dEnabled = v end })
EspTab:CreateColorPicker({ Name = "3D Box Color: Players", Color = box3dColor, Callback = function(c) box3dColor = c end })
EspTab:CreateToggle({ Name = "3D Box: Murder", CurrentValue = false, Callback = function(v) box3dMurderEnabled = v end })
EspTab:CreateColorPicker({ Name = "3D Box Color: Murder", Color = box3dMurderColor, Callback = function(c) box3dMurderColor = c end })
EspTab:CreateToggle({ Name = "3D Box: Sheriff", CurrentValue = false, Callback = function(v) box3dSheriffEnabled = v end })
EspTab:CreateColorPicker({ Name = "3D Box Color: Sheriff", Color = box3dSheriffColor, Callback = function(c) box3dSheriffColor = c end })
EspTab:CreateToggle({ Name = "3D Box: Innocent", CurrentValue = false, Callback = function(v) box3dInnocentEnabled = v end })
EspTab:CreateColorPicker({ Name = "3D Box Color: Innocent", Color = box3dInnocentColor, Callback = function(c) box3dInnocentColor = c end })

-- === Drawing Logic ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local BoxData = {}

local function IsValidVector2(v)
	return v.X == v.X and v.Y == v.Y and math.abs(v.X) < 99999 and math.abs(v.Y) < 99999
end

local function GetCorners(cf, size)
	local half = size / 2
	local corners = {}
	for x = -1, 1, 2 do
		for y = -1, 1, 2 do
			for z = -1, 1, 2 do
				table.insert(corners, (cf * CFrame.new(half * Vector3.new(x, y, z))).Position)
			end
		end
	end
	return corners
end

local function GetOrCreateLines(id)
	BoxData[id] = BoxData[id] or {}
	for i = 1, 12 do
		if not BoxData[id][i] then
			local line = Drawing.new("Line")
			line.Thickness = 1.5
			line.Transparency = 1
			line.Visible = true
			BoxData[id][i] = line
		end
	end
	return BoxData[id]
end

local function RemoveLines(id)
	if BoxData[id] then
		for _, line in pairs(BoxData[id]) do
			if line then line:Remove() end
		end
		BoxData[id] = nil
	end
end

local function isMurder(p)
	local bp, ch = p:FindFirstChild("Backpack"), p.Character
	return (bp and bp:FindFirstChild("Knife")) or (ch and ch:FindFirstChild("Knife"))
end

local function isSheriff(p)
	local bp, ch = p:FindFirstChild("Backpack"), p.Character
	return (bp and bp:FindFirstChild("Gun")) or (ch and ch:FindFirstChild("Gun"))
end

local function isInnocent(p)
	return not isMurder(p) and not isSheriff(p) and p ~= LocalPlayer
end

RunService.RenderStepped:Connect(function()
	local faces = {
		{1, 2}, {2, 4}, {4, 3}, {3, 1},
		{5, 6}, {6, 8}, {8, 7}, {7, 5},
		{1, 5}, {2, 6}, {3, 7}, {4, 8}
	}

	-- Игроки
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local id = "Player_" .. player.UserId
			local show, color = false, box3dColor
			if isMurder(player) and box3dMurderEnabled then show = true; color = box3dMurderColor
			elseif isSheriff(player) and box3dSheriffEnabled then show = true; color = box3dSheriffColor
			elseif isInnocent(player) and box3dInnocentEnabled then show = true; color = box3dInnocentColor
			elseif box3dEnabled then show = true; color = box3dColor end

			if show then
				local verts = GetCorners(hrp.CFrame, Vector3.new(3, 5, 1.5))
				local lines = GetOrCreateLines(id)
				for i, edge in ipairs(faces) do
					local a, b = verts[edge[1]], verts[edge[2]]
					local sa, va = Camera:WorldToViewportPoint(a)
					local sb, vb = Camera:WorldToViewportPoint(b)
					local line = lines[i]
					if va and vb and IsValidVector2(Vector2.new(sa.X, sa.Y)) and IsValidVector2(Vector2.new(sb.X, sb.Y)) then
						line.From = Vector2.new(sa.X, sa.Y)
						line.To = Vector2.new(sb.X, sb.Y)
						line.Color = color
						line.Visible = true
					else
						line.Visible = false
					end
				end
			else
				RemoveLines(id)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	RemoveLines("Player_" .. player.UserId)
end)

EspTab:CreateSection("Role Tags")

-- Global Settings
_G.ShowSheriffTag = false
_G.ShowMurderTag = false
_G.ShowInnocentTag = false

_G.SheriffTagColor = Color3.fromRGB(40, 255, 60)
_G.MurderTagColor = Color3.fromRGB(255, 30, 60)
_G.InnocentTagColor = Color3.fromRGB(200, 255, 255)

-- UI Controls
EspTab:CreateToggle({
	Name = "Show Tag: Sheriff",
	CurrentValue = false,
	Callback = function(Value) _G.ShowSheriffTag = Value end
})
EspTab:CreateColorPicker({
	Name = "Tag Color: Sheriff",
	Color = _G.SheriffTagColor,
	Callback = function(Color) _G.SheriffTagColor = Color end
})

EspTab:CreateToggle({
	Name = "Show Tag: Murder",
	CurrentValue = false,
	Callback = function(Value) _G.ShowMurderTag = Value end
})
EspTab:CreateColorPicker({
	Name = "Tag Color: Murder",
	Color = _G.MurderTagColor,
	Callback = function(Color) _G.MurderTagColor = Color end
})

EspTab:CreateToggle({
	Name = "Show Tag: Innocent",
	CurrentValue = false,
	Callback = function(Value) _G.ShowInnocentTag = Value end
})
EspTab:CreateColorPicker({
	Name = "Tag Color: Innocent",
	Color = _G.InnocentTagColor,
	Callback = function(Color) _G.InnocentTagColor = Color end
})

-- Main Logic
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local roleTags = {} -- [player] = BillboardGui

-- Удаление лишних надписей, включая "Невиновен" и т.д.
local function clearOtherBillboards(player)
	local char = player.Character
	if not char then return end
	for _, gui in pairs(char:GetChildren()) do
		if gui:IsA("BillboardGui") and gui.Name ~= "RoleTag" then
			gui:Destroy()
		end
	end
end

-- Проверка ролей
local function isSheriff(player)
	local bp = player:FindFirstChild("Backpack")
	local ch = player.Character
	return (bp and bp:FindFirstChild("Gun")) or (ch and ch:FindFirstChild("Gun"))
end

local function isMurder(player)
	local bp = player:FindFirstChild("Backpack")
	local ch = player.Character
	return (bp and bp:FindFirstChild("Knife")) or (ch and ch:FindFirstChild("Knife"))
end

local function isInnocent(player)
	return not isSheriff(player) and not isMurder(player) and player ~= LocalPlayer
end

-- Создание текстового тега
local function createRoleTag(player, text, color)
	if roleTags[player] then
		roleTags[player]:Destroy()
		roleTags[player] = nil
	end

	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

	clearOtherBillboards(player)

	local tag = Instance.new("BillboardGui")
	tag.Name = "RoleTag"
	tag.Size = UDim2.new(0, 100, 0, 40)
	tag.Adornee = head
	tag.AlwaysOnTop = true
	tag.StudsOffset = Vector3.new(0, 2.5, 0)

	local label = Instance.new("TextLabel")
	label.Name = "RoleLabel"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = tag

	tag.Parent = head
	roleTags[player] = tag
end

-- Обновление цвета
local function updateRoleColor(player, color)
	local gui = roleTags[player]
	if gui and gui:FindFirstChild("RoleLabel") then
		gui.RoleLabel.TextColor3 = color
	end
end

-- Удаление тега
local function removeRoleTag(player)
	if roleTags[player] then
		roleTags[player]:Destroy()
		roleTags[player] = nil
	end
end

-- Обновление каждый кадр
RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if _G.ShowSheriffTag and isSheriff(player) then
				createRoleTag(player, "Sheriff", _G.SheriffTagColor)
				updateRoleColor(player, _G.SheriffTagColor)
			elseif _G.ShowMurderTag and isMurder(player) then
				createRoleTag(player, "Murder", _G.MurderTagColor)
				updateRoleColor(player, _G.MurderTagColor)
			elseif _G.ShowInnocentTag and isInnocent(player) then
				createRoleTag(player, "Innocent", _G.InnocentTagColor)
				updateRoleColor(player, _G.InnocentTagColor)
			else
				removeRoleTag(player)
			end
		end
	end
end)

-- Очистка при выходе игрока
Players.PlayerRemoving:Connect(removeRoleTag)

EspTab:CreateSection("other")

-- ========== Новый раздел: ESP Nickname ==========
local espNicknameEnabled = false

-- ========== ESP Nickname ==========
local espNicknameEnabled = false
local espNicknameColor = Color3.fromRGB(255, 255, 255)

EspTab:CreateToggle({
    Name = "ESP-Nickname",
    CurrentValue = false,
    Callback = function(Value)
        espNicknameEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Nickname Color",
    Color = espNicknameColor,
    Callback = function(Color)
        espNicknameColor = Color
    end
})

local nicknameLabels = {}

local function removeNicknameLabel(player)
    if nicknameLabels[player] then
        nicknameLabels[player]:Destroy()
        nicknameLabels[player] = nil
    end
end

game:GetService("Players").PlayerRemoving:Connect(removeNicknameLabel)

game:GetService("RunService").RenderStepped:Connect(function()
    if not espNicknameEnabled then
        for _, label in pairs(nicknameLabels) do
            if label then label.Enabled = false end
        end
        return
    end
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not nicknameLabels[player] then
                local head = player.Character.Head
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP_Nickname"
                billboard.Size = UDim2.new(0, 120, 0, 22)
                billboard.Adornee = head
                billboard.AlwaysOnTop = true
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                local text = Instance.new("TextLabel")
                text.Name = "NickText"
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = player.DisplayName .. " [" .. player.Name .. "]"
                text.TextColor3 = espNicknameColor
                text.TextStrokeTransparency = 0.4
                text.Font = Enum.Font.GothamBold
                text.TextScaled = true
                text.Parent = billboard
                billboard.Parent = head
                nicknameLabels[player] = billboard
            else
                nicknameLabels[player].Enabled = true
                if nicknameLabels[player]:FindFirstChild("NickText") then
                    nicknameLabels[player].NickText.Text = player.DisplayName .. " [" .. player.Name .. "]"
                    nicknameLabels[player].NickText.TextColor3 = espNicknameColor
                end
            end
        else
            removeNicknameLabel(player)
        end
    end
end)


-- ========== Gun Text ESP ==========
local gunTextEnabled = false
local gunTextColor = Color3.fromRGB(30, 144, 255)

EspTab:CreateToggle({
    Name = "Text: Gun",
    CurrentValue = false,
    Callback = function(Value)
        gunTextEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Text Color: Gun",
    Color = gunTextColor,
    Callback = function(Color)
        gunTextColor = Color
    end
})

local gunTextLabels = {}

local function removeGunTextLabel(part)
    if gunTextLabels[part] then
        gunTextLabels[part]:Destroy()
        gunTextLabels[part] = nil
    end
end

game:GetService("Players").PlayerRemoving:Connect(function()
    for part, label in pairs(gunTextLabels) do
        if label then label:Destroy() end
    end
    gunTextLabels = {}
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if not gunTextEnabled then
        for _, label in pairs(gunTextLabels) do
            if label then label.Enabled = false end
        end
        return
    end

    local gunParts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            gunParts[obj] = true
            if not gunTextLabels[obj] then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "GunTextESP"
                billboard.Size = UDim2.new(0, 70, 0, 20)
                billboard.Adornee = obj
                billboard.AlwaysOnTop = true
                billboard.StudsOffset = Vector3.new(0, 1.2, 0)

                local text = Instance.new("TextLabel")
                text.Name = "Text"
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = "Gun"
                text.TextColor3 = gunTextColor
                text.TextStrokeTransparency = 0.2
                text.Font = Enum.Font.GothamBold
                text.TextScaled = true
                text.Parent = billboard

                billboard.Parent = obj
                gunTextLabels[obj] = billboard
            else
                gunTextLabels[obj].Enabled = true
                if gunTextLabels[obj]:FindFirstChild("Text") then
                    gunTextLabels[obj].Text.TextColor3 = gunTextColor
                end
            end
        end
    end

    -- Remove labels from missing guns
    for obj, _ in pairs(gunTextLabels) do
        if not gunParts[obj] or not obj:IsDescendantOf(workspace) then
            removeGunTextLabel(obj)
        end
    end
end)

-- ========== Coin Text ESP ==========
local coinTextEnabled = false
local coinTextColor = Color3.fromRGB(255, 215, 0)

EspTab:CreateToggle({
    Name = "Text: Coin",
    CurrentValue = false,
    Callback = function(Value)
        coinTextEnabled = Value
    end
})

EspTab:CreateColorPicker({
    Name = "Text Color: Coin",
    Color = coinTextColor,
    Callback = function(Color)
        coinTextColor = Color
    end
})

local coinTextLabels = {}

local function removeCoinTextLabel(part)
    if coinTextLabels[part] then
        coinTextLabels[part]:Destroy()
        coinTextLabels[part] = nil
    end
end

game:GetService("Players").PlayerRemoving:Connect(function()
    for part, label in pairs(coinTextLabels) do
        if label then label:Destroy() end
    end
    coinTextLabels = {}
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if not coinTextEnabled then
        for _, label in pairs(coinTextLabels) do
            if label then label.Enabled = false end
        end
        return
    end

    local coinParts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "MainCoin" then
            coinParts[obj] = true
            if not coinTextLabels[obj] then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "CoinTextESP"
                billboard.Size = UDim2.new(0, 70, 0, 20)
                billboard.Adornee = obj
                billboard.AlwaysOnTop = true
                billboard.StudsOffset = Vector3.new(0, 1.2, 0)

                local text = Instance.new("TextLabel")
                text.Name = "Text"
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = "Coin"
                text.TextColor3 = coinTextColor
                text.TextStrokeTransparency = 0.2
                text.Font = Enum.Font.GothamBold
                text.TextScaled = true
                text.Parent = billboard

                billboard.Parent = obj
                coinTextLabels[obj] = billboard
            else
                coinTextLabels[obj].Enabled = true
                if coinTextLabels[obj]:FindFirstChild("Text") then
                    coinTextLabels[obj].Text.TextColor3 = coinTextColor
                end
            end
        end
    end

    -- Remove labels from missing coins
    for obj, _ in pairs(coinTextLabels) do
        if not coinParts[obj] or not obj:IsDescendantOf(workspace) then
            removeCoinTextLabel(obj)
        end
    end
end)

-- Distance ESP
local distanceEnabled = false

EspTab:CreateToggle({
    Name = "Distance",
    CurrentValue = false,
    Callback = function(Value)
        distanceEnabled = Value
    end
})

local DistanceLabels = {}

local function ClearLabels()
    for _, label in ipairs(DistanceLabels) do
        if label.Remove then
            label:Remove()
        end
    end
    table.clear(DistanceLabels)
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not distanceEnabled then
        ClearLabels()
        return
    end

    ClearLabels()

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local distance = math.floor((rootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude)
            local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            if visible then
                local text = Drawing.new("Text")
                text.Text = tostring(distance) .. "m"
                text.Size = 16
                text.Center = true
                text.Outline = true
                text.Color = Color3.fromRGB(255, 255, 0)
                text.Position = Vector2.new(screenPos.X, screenPos.Y)
                text.Visible = true
                table.insert(DistanceLabels, text)
            end
        end
    end
end)

local pingAllEnabled = false

EspTab:CreateToggle({
    Name = "Ping (All Players)",
    CurrentValue = false,
    Callback = function(Value)
        pingAllEnabled = Value
    end
})

local PingLabels = {}

local function ClearPingLabels()
    for _, label in ipairs(PingLabels) do
        if label.Remove then
            label:Remove()
        end
    end
    table.clear(PingLabels)
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not pingAllEnabled then
        ClearPingLabels()
        return
    end

    ClearPingLabels()

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Ping") then
            local hrp = player.Character.HumanoidRootPart
            local pingValue = player.Character.Ping.Value
            local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 4, 0))
            if visible then
                local text = Drawing.new("Text")
                text.Text = "Ping: " .. tostring(pingValue) .. " ms"
                text.Size = 16
                text.Center = true
                text.Outline = true
                text.Color = Color3.fromRGB(0, 255, 255)
                text.Position = Vector2.new(screenPos.X, screenPos.Y)
                text.Visible = true
                table.insert(PingLabels, text)
            end
        end
    end
end)

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Настройки
local RADIUS = 5
local SEGMENTS = 30
local THICKNESS = 1.5
local circleColor = Color3.fromRGB(0, 255, 0)
local visibilityCircleEnabled = false
local PlayerCircles = {} -- [player.UserId] = {line1, line2, ...}
local renderConnection = nil
local playerRemovingConnection = nil

-- СНАЧАЛА Тоггл в меню
if EspTab then
    EspTab:CreateToggle({
        Name = "Enable Visibility Circle",
        CurrentValue = false,
        Callback = function(Value)
            visibilityCircleEnabled = Value
            if Value then
                Connect()
            else
                Disconnect()
            end
        end
    })

    -- ПОТОМ ColorPicker в меню
    EspTab:CreateColorPicker({
        Name = "Circle Color",
        Color = circleColor,
        Callback = function(Color)
            circleColor = Color
        end
    })
end

-- Очистка кругов для игрока
local function ClearPlayerCircles(playerId)
    local lines = PlayerCircles[playerId]
    if lines then
        for _, line in ipairs(lines) do
            if line and line.Remove then 
                pcall(function() line:Remove() end)
            end
        end
        PlayerCircles[playerId] = nil
    end
end

-- Очистка всех кругов
local function ClearAllCircles()
    for playerId, _ in pairs(PlayerCircles) do
        ClearPlayerCircles(playerId)
    end
end

-- При выходе игрока
local function OnPlayerRemoving(player)
    ClearPlayerCircles(player.UserId)
end

-- Рисование круга вокруг позиции
local function DrawCircle(center, color)
    local step = math.pi * 2 / SEGMENTS
    local points = {}
    local lines = {}
    
    -- Сначала вычисляем все точки круга
    for i = 0, SEGMENTS do
        local angle = i * step
        local worldPos = center + Vector3.new(math.cos(angle) * RADIUS, 0, math.sin(angle) * RADIUS)
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        
        if onScreen and screenPos.Z > 0 then
            points[i] = Vector2.new(screenPos.X, screenPos.Y)
        end
    end
    
    -- Теперь соединяем соседние видимые точки
    for i = 0, SEGMENTS - 1 do
        local currentPoint = points[i]
        local nextPoint = points[i + 1] or points[0] -- замыкаем круг
        
        if currentPoint and nextPoint then
            local success, line = pcall(function()
                local newLine = Drawing.new("Line")
                newLine.From = currentPoint
                newLine.To = nextPoint
                newLine.Color = color
                newLine.Thickness = THICKNESS
                newLine.Transparency = 1
                newLine.Visible = true
                return newLine
            end)
            
            if success and line then
                table.insert(lines, line)
            end
        end
    end
    
    return lines
end

-- Основная функция обновления
local function UpdateCircles()
    -- Обновляем только существующих игроков, не очищаем все каждый раз
    local currentPlayers = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            currentPlayers[player.UserId] = true
            local root = player.Character.HumanoidRootPart
            local pos = root.Position - Vector3.new(0, root.Size.Y / 2, 0)
            
            -- Очищаем старые круги этого игрока
            ClearPlayerCircles(player.UserId)
            -- Создаем новые
            PlayerCircles[player.UserId] = DrawCircle(pos, circleColor)
        end
    end
    
    -- Удаляем круги игроков, которых больше нет
    for playerId, _ in pairs(PlayerCircles) do
        if not currentPlayers[playerId] then
            ClearPlayerCircles(playerId)
        end
    end
end

-- Корректное подключение событий
local function Connect()
    if not renderConnection then
        renderConnection = RunService.RenderStepped:Connect(function()
            if visibilityCircleEnabled then
                UpdateCircles()
            end
        end)
    end
    
    if not playerRemovingConnection then
        playerRemovingConnection = Players.PlayerRemoving:Connect(OnPlayerRemoving)
    end
end

-- Корректное отключение событий и чистка кругов
local function Disconnect()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    
    if playerRemovingConnection then
        playerRemovingConnection:Disconnect()
        playerRemovingConnection = nil
    end
    
    ClearAllCircles()
end

-- Если EspTab не существует, можно использовать простое управление:
if not EspTab then
    -- Простое включение/выключение
    visibilityCircleEnabled = false -- по умолчанию выключено
    
    if visibilityCircleEnabled then
        Connect()
    end
end

-- Функция для ручного управления
local function ToggleCircles()
    visibilityCircleEnabled = not visibilityCircleEnabled
    if visibilityCircleEnabled then
        Connect()
    else
        Disconnect()
    end
end

-- Если хочешь вручную включить:
-- ToggleCircles()

-- Если хочешь вручную отключать:
-- Disconnect()
