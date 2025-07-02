local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ESP Menu",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by 123",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "RayfieldESPConfig"
   }
})

local ESPTab = Window:CreateTab("ESP", 4483362458)

local boxEnabled = false

ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = boxEnabled,
    Callback = function(Value)
        boxEnabled = Value
        print("Box ESP:", Value)
       function UpdateESP()
    if not boxEnabled then
        for _, box in pairs(ESPs) do
            box.Visible = false
        end
        return
    end

    for player, box in pairs(ESPs) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Ищем нужные точки (например, голова и HumanoidRootPart)
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local rootPos, onScreen1 = Camera:WorldToViewportPoint(hrp.Position)
            local headPos, onScreen2 = Camera:WorldToViewportPoint(head.Position)
            if onScreen1 and onScreen2 then
                -- Высота бокса — от головы до HRP (или чуть ниже для ног)
                local boxHeight = math.abs(rootPos.Y - headPos.Y) * 2.3 -- множитель по ситуации
                local boxWidth = boxHeight / 1.8

                box.Size = Vector2.new(boxWidth, boxHeight)
                box.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

    end,
})

Rayfield:LoadConfiguration()
