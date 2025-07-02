local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ESP Menu",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by YourName",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "RayfieldESPConfig"
   }
})

local ESPTab = Window:CreateTab("ESP", 4483362458)
local boxEnabled = false

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPs = {}

function CreateESP(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Visible = false

    ESPs[player] = box

    player.CharacterAdded:Connect(function()
        ESPs[player] = box
    end)
end

function UpdateESP()
    for player, box in pairs(ESPs) do
        if not boxEnabled then
            box.Visible = false
        else
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Head") then
                local hrp = character.HumanoidRootPart
                local head = character.Head
                local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                if hrpOnScreen and headOnScreen then
                    -- Динамический размер
                    local boxHeight = math.abs(hrpPos.Y - headPos.Y) * 2.3
                    local boxWidth = boxHeight / 1.8

                    box.Size = Vector2.new(boxWidth, boxHeight)
                    box.Position = Vector2.new(hrpPos.X - boxWidth/2, hrpPos.Y - boxHeight/2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)

game:GetService("RunService").RenderStepped:Connect(UpdateESP)

ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = boxEnabled,
    Callback = function(Value)
        boxEnabled = Value
        -- Можно сделать принт для отладки
        print("-- Box ESP:", Value)
    end,
})

Rayfield:LoadConfiguration()
