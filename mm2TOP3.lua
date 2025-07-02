-- settings
local settings = {
   boxcolor = Color3.fromRGB(255, 255, 255),   -- цвет бокса по умолчанию
   teamcheck = false,
   teamcolor = false
}
local espEnabled = false
local highlightEnabled = false
local box3dEnabled = false

local highlightColor = Color3.fromRGB(0, 255, 0) -- цвет контура по умолчанию
local box3dColor = Color3.fromRGB(0, 170, 255)   -- цвет 3d box по умолчанию

local Lines, Quads = {}, {}

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "ESP Menu",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by YourName",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "ESPMenuConfig"
   }
})
local ESPTab = Window:CreateTab("ESP", 4483362458)

-- Чекбокс 2D бокса
ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = espEnabled,
    Callback = function(Value)
        espEnabled = Value
    end,
})
-- Палитра цвета 2D бокса
ESPTab:CreateColorPicker({
    Name = "Box Color",
    Color = settings.boxcolor,
    Callback = function(Value)
        settings.boxcolor = Value
    end,
})
-- Чекбокс Outline Highlight
ESPTab:CreateToggle({
    Name = "Color (Highlight)",
    CurrentValue = highlightEnabled,
    Callback = function(Value)
        highlightEnabled = Value
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and player.Character then
                local char = player.Character
                local hl = char:FindFirstChild("Highlight")
                if Value then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "Highlight"
                        hl.Parent = char
                    end
                    hl.FillTransparency = 1           -- Прозрачный Fill (только Outline)
                    hl.OutlineTransparency = 0        -- Outline видимый
                    hl.OutlineColor = highlightColor  -- Цвет Outline
                    hl.Adornee = char
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    end,
})
-- Палитра цвета Highlight
ESPTab:CreateColorPicker({
    Name = "Highlight Color",
    Color = highlightColor,
    Callback = function(Value)
        highlightColor = Value
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("Highlight")
                if hl then
                    hl.OutlineColor = highlightColor -- Меняем только цвет Outline
                end
            end
        end
    end,
})

-- Чекбокс 3D бокса
ESPTab:CreateToggle({
    Name = "3D Box ESP",
    CurrentValue = box3dEnabled,
    Callback = function(Value)
        box3dEnabled = Value
    end,
})
-- Палитра цвета 3D Box
ESPTab:CreateColorPicker({
    Name = "3D Box Color",
    Color = box3dColor,
    Callback = function(Value)
        box3dColor = Value
    end,
})

Rayfield:LoadConfiguration()

-- services
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

-- functions
local newVector2, newDrawing = Vector2.new, Drawing.new
local tan, rad = math.tan, math.rad
local round = function(...) local a = {}; for i,v in next, table.pack(...) do a[i] = math.round(v); end return unpack(a); end
local wtvp = function(...) local a, b = camera.WorldToViewportPoint(camera, ...) return newVector2(a.X, a.Y), b, a.Z end

-- 2D BOX ESP
local espCache = {}
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
           local scaleFactor = 1 / (depth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000
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

for _, player in next, players:GetPlayers() do
   if player ~= localPlayer then
       createEsp(player)
   end
end

players.PlayerAdded:Connect(function(player)
   createEsp(player)
end)
players.PlayerRemoving:Connect(function(player)
   removeEsp(player)
end)

-- 3D BOX ESP
local function HasCharacter(Player)
    return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
end
local function Get3DBoxVertices(hrp, size)
    local cframe = hrp.CFrame
    local half = size / 2
    local points = {
        cframe * Vector3.new(-half.X, -half.Y, -half.Z),
        cframe * Vector3.new( half.X, -half.Y, -half.Z),
        cframe * Vector3.new( half.X, -half.Y,  half.Z),
        cframe * Vector3.new(-half.X, -half.Y,  half.Z),

        cframe * Vector3.new(-half.X,  half.Y, -half.Z),
        cframe * Vector3.new( half.X,  half.Y, -half.Z),
        cframe * Vector3.new( half.X,  half.Y,  half.Z),
        cframe * Vector3.new(-half.X,  half.Y,  half.Z),
    }
    return points
end

local function DrawLine(p1, p2)
    local line = Drawing.new("Line")
    line.From = p1
    line.To = p2
    line.Thickness = 2
    line.Color = box3dColor
    line.Visible = true
    table.insert(Lines, line)
end

local function WorldToScreen(vec)
    local v, onScreen = camera:WorldToViewportPoint(vec)
    return Vector2.new(v.X, v.Y), onScreen
end

local function DrawEsp3D(Player)
    local character = Player.Character
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local size = hrp.Size + Vector3.new(2, 6, 2) -- делаем коробку чуть больше
    local vertices = Get3DBoxVertices(hrp, size)
    local screen = {}
    local onScreenAll = true

    for i, v in ipairs(vertices) do
        local vec, onScreen = WorldToScreen(v)
        screen[i] = vec
        if not onScreen then onScreenAll = false end
    end

    if onScreenAll then
        -- Низ
        DrawLine(screen[1], screen[2])
        DrawLine(screen[2], screen[3])
        DrawLine(screen[3], screen[4])
        DrawLine(screen[4], screen[1])
        -- Верх
        DrawLine(screen[5], screen[6])
        DrawLine(screen[6], screen[7])
        DrawLine(screen[7], screen[8])
        DrawLine(screen[8], screen[5])
        -- Вертикали
        DrawLine(screen[1], screen[5])
        DrawLine(screen[2], screen[6])
        DrawLine(screen[3], screen[7])
        DrawLine(screen[4], screen[8])
    end
end

local function BoxEsp3D()
    -- Очищаем старые линии
    for i = 1, #Lines do
        local Line = rawget(Lines, i)
        if (Line) then Line:Remove() end
    end
    Lines = {}

    if not box3dEnabled then return end

    local playersList = players:GetPlayers()
    for i = 1, #playersList do
        local Player = playersList[i]
        if Player ~= localPlayer and HasCharacter(Player) then
            DrawEsp3D(Player)
        end
    end
end

-- RenderStepped: обновляет 2D Box, Highlight и 3D Box
runService:BindToRenderStep("esp", Enum.RenderPriority.Camera.Value, function()
    for player, drawings in next, espCache do
        if settings.teamcheck and player.Team == localPlayer.Team then
            continue
        end
        if drawings and player ~= localPlayer then
            updateEsp(player, drawings)
        end
    end
    -- Обновляем цвет бокса "на лету"
    for _, drawings in pairs(espCache) do
        if drawings.box then
            drawings.box.Color = settings.boxcolor
        end
    end
end)
runService:BindToRenderStep("esp3d", Enum.RenderPriority.Camera.Value+1, BoxEsp3D)

-- Поддержка Highlights для новых персонажей!
local function handleHighlight(player, char)
    if highlightEnabled and player ~= localPlayer then
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

for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer then
        if player.Character then
            handleHighlight(player, player.Character)
        end
        player.CharacterAdded:Connect(function(char)
            wait(1)
            handleHighlight(player, char)
        end)
    end
end

players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        player.CharacterAdded:Connect(function(char)
            wait(1)
            handleHighlight(player, char)
        end)
    end
end)
