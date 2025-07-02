-- Загружаем Rayfield UI
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

function GetBottomPart(character)
    -- Проверяем поочерёдно для R15 и R6
    if character:FindFirstChild("LeftFoot") then
        return character.LeftFoot
    elseif character:FindFirstChild("LeftLeg") then
        return character.LeftLeg
    elseif character:FindFirstChild("RightFoot") then
        return character.RightFoot
    elseif character:FindFirstChild("RightLeg") then
        return character.RightLeg
    elseif character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart
    else
        return nil
    end
end

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
            if character and character:FindFirstChild("Head") then
                local head = character.Head
                local bottomPart = GetBottomPart(character)

                if bottomPart then
                    local topWorld = head.Position + Vector3.new(0, head.Size.Y / 2, 0)
                    local bottomWorld = bottomPart.Position - Vector3.new(0, bottomPart.Size.Y / 2, 0)

                    local top2D, topOnScreen = Camera:WorldToViewportPoint(topWorld)
                    local bottom2D, bottomOnScreen = Camera:WorldToViewportPoint(bottomWorld)
                    local center2D = Camera:WorldToViewportPoint((head.Position + bottomPart.Position) / 2)

                    if topOnScreen and bottomOnScreen then
                        local height = math.abs(bottom2D.Y - top2D.Y)
                        local width = height / 2 -- Подстрой под нужную ширину

                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(center2D.X - width / 2, top2D.Y)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
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
    end,
})

Rayfield:LoadConfiguration()
