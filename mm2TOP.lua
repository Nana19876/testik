-- settings
local settings = {
   boxcolor = Color3.fromRGB(255, 255, 255),   -- цвет бокса по умолчанию
   teamcheck = false,
   teamcolor = false
}
local espEnabled = false
local highlightEnabled = false
local highlightColor = Color3.fromRGB(0, 255, 0) -- цвет контура по умолчанию

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

-- Чекбокс включения бокса
ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = espEnabled,
    Callback = function(Value)
        espEnabled = Value
    end,
})

-- Палитра цвета бокса
ESPTab:CreateColorPicker({
    Name = "Box Color",
    Color = settings.boxcolor,
    Callback = function(Value)
        settings.boxcolor = Value
    end,
})

-- Чекбокс включения Outline (Highlight)
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

-- Палитра цвета Outline
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
