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

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "ESP Menu",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "Role Tags",
	ConfigurationSaving = { Enabled = false }
})

local EspTab = Window:CreateTab("ESP", 4483362458)
EspTab:CreateSection("Role Tags")

-- Global settings
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

-- ESP Logic
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local roleTags = {} -- [player] = BillboardGui

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
	return not isMurder(player) and not isSheriff(player) and player ~= LocalPlayer
end

local function createRoleTag(player, text, color)
	if roleTags[player] then return end
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

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

	tag.Parent = char
	roleTags[player] = tag
end

local function updateRoleColor(player, color)
	local gui = roleTags[player]
	if gui and gui:FindFirstChild("RoleLabel") then
		gui.RoleLabel.TextColor3 = color
	end
end

local function removeRoleTag(player)
	if roleTags[player] then
		roleTags[player]:Destroy()
		roleTags[player] = nil
	end
end

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

Players.PlayerRemoving:Connect(removeRoleTag)

