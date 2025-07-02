-- Services
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = PlayersService.LocalPlayer

-- === НАСТРОЙКИ ===
local settings = {
    boxcolor = Color3.fromRGB(255, 255, 255), -- 2D Box
    teamcheck = false,
    teamcolor = false,
}
local highlightColor = Color3.fromRGB(0, 255, 0)
local box3dColor = Color3.fromRGB(255, 0, 0)
local espEnabled = false
local highlightEnabled = false
local box3dEnabled = false

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
        for _, player in ipairs(PlayersService:GetPlayers()) do
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
        for _, player in ipairs(PlayersService:GetPlayers()) do
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
                for _, l in ipairs(esp.Lines) do l.Visible = false end
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
        for _, esp in pairs(ESPObjects) do
            for _, l in ipairs(esp.Lines) do l.Color = box3dColor end
            for _, q in ipairs(esp.Quads) do q.Color = box3dColor end
        end
    end,
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

for _, player in next, PlayersService:GetPlayers() do
    if player ~= LocalPlayer then
        createEsp(player)
    end
end
PlayersService.PlayerAdded:Connect(function(player)
    createEsp(player)
end)
PlayersService.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

-- ========== 3D BOX (толстые линии) ==========
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
    ESPObjects[player] = {Lines={},Quads={}}
    for i = 1, #EDGE_PAIRS do
        local line = Drawing.new("Line")
        line.Thickness = 5  -- <=== ТОЛЩИНА ЛИНИЙ (можно 4, 5, 6 — смотри что нравится)
        line.Color = box3dColor
        line.Transparency = 0
        line.Visible = false
        table.insert(ESPObjects[player].Lines, line)
    end
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
    for _, obj in ipairs(ESPObjects[player].Lines) do pcall(function() obj:Remove() end) end
    for _, obj in ipairs(ESPObjects[player].Quads) do pcall(function() obj:Remove() end) end
    ESPObjects[player] = nil
end
local function updatePlayerESP(player)
    local esp = ESPObjects[player]
    if not esp then return end
    if not box3dEnabled or player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        for _, l in ipairs(esp.Lines) do l.Visible = false end
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
    for i,pair in ipairs(QUAD_PAIRS) do
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

for _,player in ipairs(PlayersService:GetPlayers()) do
    setupPlayerESP(player)
end
PlayersService.PlayerAdded:Connect(setupPlayerESP)
PlayersService.PlayerRemoving:Connect(clearPlayerESP)

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
    for _,player in ipairs(PlayersService:GetPlayers()) do
        updatePlayerESP(player)
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
for _, player in ipairs(PlayersService:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then handleHighlight(player, player.Character) end
        player.CharacterAdded:Connect(function(char)
            wait(1)
            handleHighlight(player, char)
        end)
    end
end
PlayersService.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            wait(1)
            handleHighlight(player, char)
        end)
    end
end)
