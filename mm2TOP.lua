-- Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local boxEnabled = false
local colorEnabled = false
local boxColor = Color3.fromRGB(255, 0, 0)
local highlightColor = Color3.fromRGB(0, 255, 0) -- по умолчанию зеленый для наглядности

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

ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = boxEnabled,
    Callback = function(Value)
        boxEnabled = Value
    end,
})

ESPTab:CreateColorPicker({
    Name = "Box Color",
    Color = boxColor,
    Callback = function(Value)
        boxColor = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Color (Highlight)",
    CurrentValue = colorEnabled,
    Callback = function(Value)
        colorEnabled = Value
        -- При включении — применяем Highlight, при выключении — удаляем
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and player.Character then
                local char = player.Character
                local hl = char:FindFirstChild("Highlight")
                if Value then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "Highlight"
                        hl.Parent = char
                        hl.FillTransparency = 0.2
                        hl.OutlineTransparency = 1
                    end
                    hl.FillColor = highlightColor
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
        -- Обновим только цвета Highlights (если они включены)
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("Highlight")
                if hl then
                    hl.FillColor = highlightColor
                end
            end
        end
    end,
})

Rayfield:LoadConfiguration()

-- ESP Box (Drawing)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local ESPs = {}

local function createESP(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = boxColor
    box.Visible = false
    box.ZIndex = 2

    ESPs[player] = box

    player.CharacterAdded:Connect(function(char)
        ESPs[player] = box
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPs[player] then
        ESPs[player]:Remove()
        ESPs[player] = nil
    end
end)

runService:BindToRenderStep("esp", Enum.RenderPriority.Camera.Value, function()
    for player, box in pairs(ESPs) do
        if player and player.Character and box and boxEnabled then
            local character = player.Character
            if character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local head = character.Head

                local topWorld = head.Position + Vector3.new(0, head.Size.Y/2, 0)
                local bottomWorld = hrp.Position - Vector3.new(0, hrp.Size.Y/2, 0)

                local top2D, topOnScreen = Camera:WorldToViewportPoint(topWorld)
                local bottom2D, bottomOnScreen = Camera:WorldToViewportPoint(bottomWorld)
                local hrp2D = Camera:WorldToViewportPoint(hrp.Position)

                if topOnScreen and bottomOnScreen then
                    local height = math.abs(bottom2D.Y - top2D.Y)
                    local width = height / 2

                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(hrp2D.X - width / 2, top2D.Y)
                    box.Color = boxColor
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        elseif box then
            box.Visible = false
        end
    end
end)
