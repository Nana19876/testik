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
        -- Тут ваша логика для включения/выключения Box ESP
    end,
})

Rayfield:LoadConfiguration()
