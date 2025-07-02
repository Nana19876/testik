-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==== НАСТРОЙКИ (можно менять через меню ниже) ====
local box2dEnabled      = false
local box2dColor        = Color3.fromRGB(255,255,255)

local box3dEnabled      = false
local box3dColor        = Color3.fromRGB(255,0,0)
local box3dThickness    = 2

local highlightEnabled  = false
local highlightColor    = Color3.fromRGB(0,255,0)

local tracersEnabled    = false
local tracersColor      = Color3.fromRGB(255,0,0)
local tracersThickness  = 2

local radiusEnabled     = false
local radiusColor       = Color3.fromRGB(0,255,0)
local RADIUS            = 2
local SEGMENTS          = 12
local RADIUS_THICKNESS  = 1.5

-- =============== Rayfield меню ===============
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "ESP Menu",
   LoadingTitle = "ESP",
   LoadingSubtitle = "by ChatGPT",
   ConfigurationSaving = {Enabled = false}
})
local Tab = Window:CreateTab("ESP", 4483362458)

Tab:CreateToggle({
    Name = "2D Box ESP",
    CurrentValue = box2dEnabled,
    Callback = function(val) box2dEnabled = val end
})
Tab:CreateColorPicker({
    Name = "2D Box Color",
    Color = box2dColor,
    Callback = function(val) box2dColor = val end
})

Tab:CreateToggle({
    Name = "3D Box ESP",
    CurrentValue = box3dEnabled,
    Callback = function(val) box3dEnabled = val end
})
Tab:CreateColorPicker({
    Name = "3D Box Color",
    Color = box3dColor,
    Callback = function(val) box3dColor = val end
})

Tab:CreateToggle({
    Name = "Highlight (Outline) ESP",
    CurrentValue = highlightEnabled,
    Callback = function(val) highlightEnabled = val end
})
Tab:CreateColorPicker({
    Name = "Highlight Color",
    Color = highlightColor,
    Callback = function(val) highlightColor = val end
})

Tab:CreateToggle({
    Name = "Tracers",
    CurrentValue = tracersEnabled,
    Callback = function(val) tracersEnabled = val end
})
Tab:CreateColorPicker({
    Name = "Tracers Color",
    Color = tracersColor,
    Callback = function(val) tracersColor = val end
})

Tab:CreateToggle({
    Name = "Radius of Visibility",
    CurrentValue = radiusEnabled,
    Callback = function(val) radiusEnabled = val end
})
Tab:CreateColorPicker({
    Name = "Radius Color",
    Color = radiusColor,
    Callback = function(val) radiusColor = val end
})

Rayfield:LoadConfiguration()

-- ================= 2D Box ESP =================
local espCache = {}
local newVector2 = Vector2.new
local tan, rad = math.tan, math.rad
local round = function(...) local a = {}; for i,v in next, table.pack(...) do a[i] = math.round(v); end return unpack(a); end
local wtvp = function(...) local a, b = Camera.WorldToViewportPoint(Camera, ...) return newVector2(a.X, a.Y), b, a.Z end

local function create2dEsp(player)
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
    if rawget(espCache, player) then
        for _, drawing in next, espCache[player] do drawing:Remove() end
        espCache[player] = nil
    end
end

local function update2dEsp(player, esp)
    local character = player and player.Character
    if character and box2dEnabled then
        local cframe = character:GetModelCFrame()
        local position, visible, depth = wtvp(cframe.Position)
        esp.box.Visible = visible
        if cframe and visible then
            local scaleFactor = 1 / (depth * tan(rad(Camera.FieldOfView / 2)) * 2) * 1000
            local width, height = round(4 * scaleFactor, 5 * scaleFactor)
            local x, y = round(position.X, position.Y)
            esp.box.Size = newVector2(width, height)
            esp.box.Position = newVector2(round(x - width / 2, y - height / 2))
            esp.box.Color = box2dColor
        end
    else
        esp.box.Visible = false
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then create2dEsp(player) end
end
Players.PlayerAdded:Connect(function(player) create2dEsp(player) end)
Players.PlayerRemoving:Connect(function(player) remove2dEsp(player) end)

-- ================= 3D Box ESP =================
local EDGE_PAIRS = {
    {1,2},{2,6},{6,5},{5,1},
    {3,4},{4,8},{8,7},{7,3},
    {1,3},{2,4},{6,8},{5,7}
}
local ESPObjects = {}

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

local function setupPlayerESP(player)
    if ESPObjects[player] then return end
    ESPObjects[player] = {Lines={}}
    for i = 1, #EDGE_PAIRS do
        local line = Drawing.new("Line")
        line.Thickness = box3dThickness
        line.Color = box3dColor
        line.Transparency = 0
        line.Visible = false
        table.insert(ESPObjects[player].Lines, line)
    end
end
local function clearPlayerESP(player)
    if not ESPObjects[player] then return end
    for _, obj in ipairs(ESPObjects[player].Lines) do pcall(function() obj:Remove() end) end
    ESPObjects[player] = nil
end

local function updatePlayerESP(player)
    local esp = ESPObjects[player]
    if not esp then return end
    if not box3dEnabled or player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        for _, l in ipairs(esp.Lines) do l.Visible = false end
        return
    end
    local HRP = player.Character.HumanoidRootPart
    local size = Vector3.new(3, 5.5, 3)
    local offset = CFrame.new(0, -0.5, 0)
    local verts = GetCorners(HRP.CFrame * offset, size)
    for i, pair in ipairs(EDGE_PAIRS) do
        local a, va = screen(verts[pair[1]])
        local b, vb = screen(verts[pair[2]])
        local line = esp.Lines[i]
        if va and vb then
            line.From = a
            line.To = b
            line.Color = box3dColor
            line.Visible = true
        else
            line.Visible = false
        end
    end
end

for _,player in ipairs(Players:GetPlayers()) do setupPlayerESP(player) end
Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(clearPlayerESP)

-- =============== Tracers =================
local Tracers = {}
local function ClearTracers()
    for _, tracer in ipairs(Tracers) do if tracer and tracer.Remove then tracer:Remove() end end
    Tracers = {}
end
local function DrawTracers()
    ClearTracers()
    if not tracersEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local tracer = Drawing.new("Line")
                tracer.Thickness = tracersThickness
                tracer.Color = tracersColor
                tracer.Transparency = 1
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- низ экрана
                tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                tracer.Visible = true
                table.insert(Tracers, tracer)
            end
        end
    end
end

-- ========== Radius of Visibility (малый) ===========
local Circles = {}
local function ClearCircles()
    for _, v in ipairs(Circles) do if v.Remove then v:Remove() end end
    table.clear(Circles)
end
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

-- ========== Главный цикл ==========
RunService.RenderStepped:Connect(function()
    -- 2D box
    for player, drawings in next, espCache do
        if drawings and player ~= LocalPlayer then update2dEsp(player, drawings) end
    end
    -- 3D box
    for _,player in ipairs(Players:GetPlayers()) do updatePlayerESP(player) end
    -- Tracers
    DrawTracers()
    -- Radius
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

-- =========== Highlight поддержка ============
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
