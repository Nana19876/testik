-- Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local highlightColor = Color3.fromRGB(255, 0, 0)
local boxEnabled = false

local Window = Rayfield:CreateWindow({
   Name = "ESP & Highlight Menu",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by YourName",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "ESPHighlightConfig"
   }
})

local ESPTab = Window:CreateTab("ESP", 4483362458)
local ColorTab = Window:CreateTab("Color", 4483362458)

ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = boxEnabled,
    Callback = function(Value)
        boxEnabled = Value
    end,
})

ColorTab:CreateColorPicker({
    Name = "Highlight/Box Color",
    Color = highlightColor,
    Callback = function(Value)
        highlightColor = Value
        -- обновим все Highlights
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

-- ESP Box (Drawing) и Highlight logic
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local ESPs = {}

local function applyHighlight(character)
    local hl = character:FindFirstChild("Highlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "Highlight"
        hl.Parent = character
        hl.FillTransparency = 0.2
        hl.OutlineTransparency = 1
    end
    hl.FillColor = highlightColor
    hl.Adornee = character
end

local function createESP(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = highlightColor
    box.Visible = false
    box.ZIndex = 2

    ESPs[player] = box

    player.CharacterAdded:Connect(function(char)
        ESPs[player] = box
        wait(1)
        applyHighlight(char)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
        if player.Character then
            applyHighlight(player.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
        player.CharacterAdded:Connect(function(char)
            wait(1)
            applyHighlight(char)
        end)
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

                -- Динамический бокс (сверху головы до HRP)
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
                    box.Color = highlightColor
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
