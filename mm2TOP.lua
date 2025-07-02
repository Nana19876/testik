-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- === НАСТРОЙКИ ===
local settings = {
    boxcolor = Color3.fromRGB(255, 255, 255), -- 2D Box
    teamcheck = false,
    teamcolor = false,
}
local highlightColor = Color3.fromRGB(0, 255, 0)
local box3dColor = Color3.fromRGB(255, 0, 0)
local tracerColor = Color3.fromRGB(255, 0, 0)
local radiusColor = Color3.fromRGB(0, 255, 0)
local espEnabled = false
local highlightEnabled = false
local box3dEnabled = false
local tracersEnabled = false
local radiusEnabled = false
local box3dThickness = 5

-- Radius of visibility settings
local RADIUS = 5 -- студийных единиц
local SEGMENTS = 30
local RADIUS_THICKNESS = 1.5

-- Drawing storage для 2D Box
local espCache = {}
-- 3D Box индексы
local EDGE_PAIRS = {
    {1,2},{2,6},{6,5},{5,1}, -- Bottom
    {3,4},{4,8},{8,7},{7,3}, -- Top
    {1,3},{2,4},{6,8},{5,7}  -- Sides
}
local QUAD_PAIRS = {
    {1,2,6,5}, -- Bottom
    {3,4,8,7}, -- Top
    {1,2,4,3}, -- Side1
    {2,6,8,4}, -- Side2
    {6,5,7,8}, -- Side3
    {5,1,3,7}  -- Side4
}
local ESPObjects = {}

-- Tracers
local Tracers = {}
local function ClearTracers()
    for _, tracer in ipairs(Tracers) do
        if tracer and tracer.Remove then tracer:Remove() end
    end
    Tracers = {}
end

-- Radius Circles
local Circles = {}
local function ClearCircles()
    for _, v in ipairs(Circles) do
        if v.Remove then v:Remove() end
    end
    table.clear(Circles)
end

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "ESP Menu",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Universal ESP",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "ESPMenuConfig"
   }
})
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = espEnabled,
    Callback = function(Value) espEnabled = Value end,
})
ESPTab:CreateColorPicker({
    Name = "Box Color",
    Color = settings.boxcolor,
    Callback = function(Value) settings.boxcolor = Value end,
})

ESPTab:CreateToggle({
    Name = "Color (Highlight)",
    CurrentValue = highlightEnabled,
    Callback = function(Value)
        highlightEnabled = Value
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local hl = char:FindFirstChild("Highlight")
                if Value then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "Highlight"
                        hl.Parent = char
                    end
                    hl.FillTransparency = 1
                    hl.OutlineTransparency = 0
                    hl.OutlineColor = highlightColor
                    hl.Adornee = char
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    end,
})
ESPTab:CreateColorPicker({
    Name = "Highlight Color",
    Color = highlightColor,
    Callback = function(Value)
        highlightColor = Value
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("Highlight")
                if hl then hl.OutlineColor = highlightColor end
            end
        end
    end,
})

ESPTab:CreateToggle({
    Name = "3D Box ESP",
    CurrentValue = box3dEnabled,
    Callback = function(Value)
        box3dEnabled = Value
        if not box3dEnabled then
            for _, esp in pairs(ESPObjects) do
                for _, l in ipairs(esp.Lines) do pcall(function() l:Remove() end) end
                esp.Lines = {}
                for _, q in ipairs(esp.Quads) do q.Visible = false end
            end
        end
    end,
})
ESPTab:CreateColorPicker({
    Name = "3D Box Color",
    Color = box3dColor,
    Callback = function(Value)
        box3dColor = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = tracersEnabled,
    Callback = function(Value) tracersEnabled = Value end,
})
ESPTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = tracerColor,
    Callback = function(Value) tracerColor = Value end,
})

ESPTab:CreateToggle({
    Name = "Radius of Visibility",
    CurrentValue = radiusEnabled,
    Callback = function(Value) radiusEnabled = Value end,
})
ESPTab:CreateColorPicker({
    Name = "Radius Color",
    Color = radiusColor,
    Callback = function(Value) radiusColor = Value end,
})

Rayfield:LoadConfiguration()

-- ========== 2D BOX ==========
local newVector2, newDrawing = Vector2.new, Drawing.new
local tan, rad = math.tan, math.rad
local round = function(...) local a = {}; for i,v in next, table.pack(...) do a[i] = math.round(v); end return unpack(a); end
local wtvp = function(...) local a, b = Camera.WorldToViewportPoint(Camera, ...) return newVector2(a.X, a.Y), b, a.Z end

local function createEsp(player)
    local drawings = {}
    drawings.box = newDrawing("Square")
    drawings.box.Thickness = 2
    drawings.box.Filled = false
    drawings.box.Color = settings.boxcolor
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
    if character and espEnabled then
        local cframe = character:GetModelCFrame()
        local position, visible, depth = wtvp(cframe.Position)
        esp.box.Visible = visible

        if cframe and visible then
            local scaleFactor = 1 / (depth * tan(rad(Camera.FieldOfView / 2)) * 2) * 1000
            local width, height = round(4 * scaleFactor, 5 * scaleFactor)
            local x, y = round(position.X, position.Y)
            esp.box.Size = newVector2(width, height)
            esp.box.Position = newVector2(round(x - width / 2, y - height / 2))
            esp.box.Color = settings.boxcolor
        end
    else
        esp.box.Visible = false
    end
end

for _, player in next, Players:GetPlayers() do
    if player ~= LocalPlayer then
        createEsp(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    createEsp(player)
end)
Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

-- ========== 3D BOX (жирные линии-имитация) ==========
local function screen(pos)
	local s, vis = Camera:WorldToViewportPoint(pos)
	return Vector2.new(s.X, s.Y), vis
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

local function DrawThickLine(from, to, color, thickness, linesTable)
    local offsets = {{0,0}}
    for i = 1, thickness-1 do
        table.insert(offsets, {i,0})
        table.insert(offsets, {-i,0})
        table.insert(offsets, {0,i})
        table.insert(offsets, {0,-i})
    end
    for _,off in ipairs(offsets) do
        local l = Drawing.new("Line")
        l.From = from + Vector2.new(off[1],off[2])
        l.To = to + Vector2.new(off[1],off[2])
        l.Color = color
        l.Transparency = 0
        l.Visible = true
        table.insert(linesTable, l)
    end
end

local function setupPlayerESP(player)
    if ESPObjects[player] then return end
    ESPObjects[player] = {Lines={},Quads={}}
    for i = 1, #QUAD_PAIRS do
        local quad = Drawing.new("Quad")
        quad.Color = box3dColor
        quad.Transparency = 0.15
        quad.Filled = false
        quad.Visible = false
        table.insert(ESPObjects[player].Quads, quad)
    end
end
local function clearPlayerESP(player)
    if not ESPObjects[player] then return end
    for _, l in ipairs(ESPObjects[player].Lines) do pcall(function() l:Remove() end) end
    for _, q in ipairs(ESPObjects[player].Quads) do pcall(function() q:Remove() end) end
    ESPObjects[player] = nil
end
local function updatePlayerESP(player)
    local esp = ESPObjects[player]
    if not esp then return end
    for _, l in ipairs(esp.Lines) do pcall(function() l:Remove() end) end
    esp.Lines = {}

    if not box3dEnabled or player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        for _, q in ipairs(esp.Quads) do q.Visible = false end
        return
    end

    local HRP = player.Character.HumanoidRootPart
    local size = Vector3.new(3, 5.5, 3)
    local offset = CFrame.new(0, -0.5, 0)
    local verts = GetCorners(HRP.CFrame * offset, size)
    for i,pair in ipairs(EDGE_PAIRS) do
        local a, va = screen(verts[pair[1]])
        local b, vb = screen(verts[pair[2]])
        if va and vb then
            DrawThickLine(a, b, box3dColor, box3dThickness, esp.Lines)
        end
    end
    for i, pair in ipairs(QUAD_PAIRS) do
        local a, va = screen(verts[pair[1]])
        local b, vb = screen(verts[pair[2]])
        local c, vc = screen(verts[pair[3]])
        local d, vd = screen(verts[pair[4]])
        local quad = esp.Quads[i]
        if va and vb and vc and vd then
            quad.PointA = a
            quad.PointB = b
            quad.PointC = c
            quad.PointD = d
            quad.Color = box3dColor
            quad.Visible = true
        else
            quad.Visible = false
        end
    end
end

for _,player in ipairs(Players:GetPlayers()) do
    setupPlayerESP(player)
end
Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(clearPlayerESP)

-- Tracers
local function DrawTracers()
    ClearTracers()
    if not tracersEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local tracer = Drawing.new("Line")
                tracer.Thickness = 2
                tracer.Color = tracerColor
                tracer.Transparency = 1
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- нижняя середина
                tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                tracer.Visible = true
                table.insert(Tracers, tracer)
            end
        end
    end
end

-- Радиусы
local function DrawCircle(center)
    local step = math.pi * 2 / SEGMENTS
    local points = {}

    for i = 0, SEGMENTS do
        local angle = i * step
        local pos = center + Vector3.new(math.cos(angle) * RADIUS, 0, math.sin(angle) * RADIUS)
        table.insert(points, pos)
    end

    for i = 1, #points - 1 do
        local p1 = Camera:WorldToViewportPoint(points[i])
        local p2 = Camera:WorldToViewportPoint(points[i + 1])

        if p1.Z > 0 and p2.Z > 0 then
            local line = Drawing.new("Line")
            line.From = Vector2.new(p1.X, p1.Y)
            line.To = Vector2.new(p2.X, p2.Y)
            line.Color = radiusColor
            line.Thickness = RADIUS_THICKNESS
            line.Transparency = 1
            line.Visible = true
            table.insert(Circles, line)
        end
    end
end

-- ========== Render Step ==========
RunService.RenderStepped:Connect(function()
    -- 2D box
    for player, drawings in next, espCache do
        if settings.teamcheck and player.Team == LocalPlayer.Team then continue end
        if drawings and player ~= LocalPlayer then
            updateEsp(player, drawings)
        end
    end
    for _, drawings in pairs(espCache) do
        if drawings.box then drawings.box.Color = settings.boxcolor end
    end

    -- 3D box
    for _,player in ipairs(Players:GetPlayers()) do
        updatePlayerESP(player)
    end

    -- Tracers
    DrawTracers()

    -- Радиусы
    ClearCircles()
    if radiusEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = player.Character.HumanoidRootPart.Position - Vector3.new(0, player.Character.HumanoidRootPart.Size.Y / 2, 0)
                DrawCircle(pos)
            end
        end
    end
end)

-- ========== Highlight поддержка ==========
local function handleHighlight(player, char)
    if highlightEnabled and player ~= LocalPlayer then
        local hl = char:FindFirstChild("Highlight")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "Highlight"
            hl.Parent = char
        end
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = highlightColor
        hl.Adornee = char
    else
        local hl = char:FindFirstChild("Highlight")
        if hl then hl:Destroy() end
    end
end
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then handleHighlight(player, player.Character) end
        player.CharacterAdded:Connect(function(char)
            wait(1)
            handleHighlight(player, char)
        end)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            wait(1)
            handleHighlight(player, char)
        end)
    end
end)
