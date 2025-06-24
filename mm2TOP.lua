-- LocalScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Удаляем старое меню если есть
if playerGui:FindFirstChild("SkeetMenu") then
    playerGui.SkeetMenu:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "SkeetMenu"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- ESP переменные и состояния
local ESPStates = {
    box = false,
    color = false,
    gradient = false,
    ["3d box"] = false,
    nickname = false,
    ping = false,
    tracer = false,
    distance = false,
    ["radius of visibility"] = false,
    chams = false
}

-- Хранилища для ESP объектов
local ESPs = {}
local GradientHighlights = {}
local ColorHighlights = {}
local Lines3D = {}
local Quads3D = {}
local NameTags = {}
local PingTags = {}
local PingValues = {}
local Tracers = {}
local Circles = {}
local DistanceLabels = {}

-- Подключения
local ESPConnections = {}

-- Настройки для Box ESP (теперь множественный выбор)
local BoxESPSettings = {
    showAll = true,
    showMurderer = false,
    showSheriff = false,
    customColor = Color3.fromRGB(255, 255, 255), -- Пользовательский цвет
    useCustomColor = false -- Использовать ли пользовательский цвет
}

-- Безопасное удаление объектов
local function SafeRemove(obj)
    if obj then
        pcall(function() obj:Remove() end)
        pcall(function() obj:Destroy() end)
        if obj.Visible ~= nil then
            obj.Visible = false
        end
    end
end

-- Проверка персонажа
local function HasCharacter(targetPlayer)
    return targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- Проверка на наличие ножа (murderer)
local function isMurderer(targetPlayer)
    local backpack = targetPlayer:FindFirstChild("Backpack")
    local character = targetPlayer.Character
    
    return (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife"))
end

-- Проверка на наличие пистолета (sheriff)
local function isSheriff(targetPlayer)
    local backpack = targetPlayer:FindFirstChild("Backpack")
    local character = targetPlayer.Character
    
    return (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun"))
end

-- ========== BOX ESP ==========
function CreateBoxESP(targetPlayer)
    if targetPlayer == player then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Filled = false
    box.Visible = false

    ESPs[targetPlayer] = box
end

function UpdateBoxESP()
    if not ESPStates.box then return end
    
    for targetPlayer, box in pairs(ESPs) do
        if targetPlayer and targetPlayer.Parent then
            local shouldShow = false
            local boxColor = BoxESPSettings.customColor -- Используем пользовательский цвет по умолчанию

            if BoxESPSettings.showAll then
                shouldShow = true
                if not BoxESPSettings.useCustomColor then
                    boxColor = Color3.fromRGB(255, 255, 255) -- Белый для всех если не используется пользовательский цвет
                end
            else
                -- Проверяем конкретные роли только если showAll выключен
                local isMurd = isMurderer(targetPlayer)
                local isSher = isSheriff(targetPlayer)
                
                if BoxESPSettings.showMurderer and isMurd then
                    shouldShow = true
                    if not BoxESPSettings.useCustomColor then
                        boxColor = Color3.fromRGB(255, 0, 0) -- Красный для murderer
                    end
                elseif BoxESPSettings.showSheriff and isSher then
                    shouldShow = true
                    if not BoxESPSettings.useCustomColor then
                        boxColor = Color3.fromRGB(0, 150, 255) -- Синий для sheriff
                    end
                end
                
                -- Если игрок одновременно и murderer и sheriff
                if BoxESPSettings.showMurderer and BoxESPSettings.showSheriff and isMurd and isSher then
                    shouldShow = true
                    if not BoxESPSettings.useCustomColor then
                        boxColor = Color3.fromRGB(255, 0, 0) -- Красный приоритет
                    end
                end
            end
            
            if shouldShow then
                local character = targetPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    local pos, onscreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onscreen then
                        local size = Vector2.new(80, 120)
                        box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                        box.Size = size
                        box.Color = boxColor
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

-- ========== COLOR ESP ==========
local function applyStaticRedHighlight(character)
    if not character:FindFirstChild("ColorHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "ColorHighlight"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency = 0.2
        hl.OutlineTransparency = 1
        hl.Adornee = character
        hl.Parent = character
        ColorHighlights[character] = hl
    end
end

-- ========== GRADIENT ESP ==========
local function createGradientHighlight(char)
    if not char:FindFirstChild("GradientHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "GradientHighlight"
        hl.FillTransparency = 0.3
        hl.OutlineTransparency = 1
        hl.Adornee = char
        hl.Parent = char
        GradientHighlights[char] = hl

        local t = 0
        local connection
        connection = RunService.RenderStepped:Connect(function(dt)
            if hl and hl.Parent and ESPStates.gradient then
                t = t + dt * 2
                local r = math.abs(math.sin(t)) * 255
                local g = math.abs(math.sin(t + 1)) * 255
                local b = math.abs(math.sin(t + 2)) * 255
                hl.FillColor = Color3.fromRGB(r, g, b)
            else
                connection:Disconnect()
            end
        end)
    end
end

-- ========== 3D BOX ESP ==========
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

local function DrawQuad(PosA, PosB, PosC, PosD)
    local function screen(pos)
        local s, vis = Camera:WorldToViewportPoint(pos)
        return Vector2.new(s.X, s.Y), vis
    end

    local A, va = screen(PosA)
    local B, vb = screen(PosB)
    local C, vc = screen(PosC)
    local D, vd = screen(PosD)

    if not (va or vb or vc or vd) then return end

    local Quad = Drawing.new("Quad")
    Quad.Thickness = 1
    Quad.Color = Color3.fromRGB(255, 0, 0)
    Quad.Transparency = 0.15
    Quad.Filled = false
    Quad.Visible = true
    Quad.PointA = A
    Quad.PointB = B
    Quad.PointC = C
    Quad.PointD = D
    table.insert(Quads3D, Quad)
end

local function DrawLine3D(from, to)
    local function screen(pos)
        local s, vis = Camera:WorldToViewportPoint(pos)
        return Vector2.new(s.X, s.Y), vis
    end

    local A, va = screen(from)
    local B, vb = screen(to)

    if not (va or vb) then return end

    local Line = Drawing.new("Line")
    Line.Thickness = 1
    Line.Color = Color3.fromRGB(255, 0, 0)
    Line.From = A
    Line.To = B
    Line.Transparency = 1
    Line.Visible = true
    table.insert(Lines3D, Line)
end

local function DrawEsp3D(targetPlayer)
    local HRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local size = Vector3.new(3, 5.5, 3)
    local offset = CFrame.new(0, -0.5, 0)
    local CubeVertices = GetCorners(HRP.CFrame * offset, size)

    -- Bottom face
    DrawLine3D(CubeVertices[1], CubeVertices[2])
    DrawLine3D(CubeVertices[2], CubeVertices[6])
    DrawLine3D(CubeVertices[6], CubeVertices[5])
    DrawLine3D(CubeVertices[5], CubeVertices[1])
    DrawQuad(CubeVertices[1], CubeVertices[2], CubeVertices[6], CubeVertices[5])

    -- Sides
    DrawLine3D(CubeVertices[1], CubeVertices[3])
    DrawLine3D(CubeVertices[2], CubeVertices[4])
    DrawLine3D(CubeVertices[6], CubeVertices[8])
    DrawLine3D(CubeVertices[5], CubeVertices[7])
    DrawQuad(CubeVertices[2], CubeVertices[4], CubeVertices[8], CubeVertices[6])
    DrawQuad(CubeVertices[1], CubeVertices[2], CubeVertices[4], CubeVertices[3])
    DrawQuad(CubeVertices[1], CubeVertices[5], CubeVertices[7], CubeVertices[3])
    DrawQuad(CubeVertices[5], CubeVertices[7], CubeVertices[8], CubeVertices[6])

    -- Top face
    DrawLine3D(CubeVertices[3], CubeVertices[4])
    DrawLine3D(CubeVertices[4], CubeVertices[8])
    DrawLine3D(CubeVertices[8], CubeVertices[7])
    DrawLine3D(CubeVertices[7], CubeVertices[3])
    DrawQuad(CubeVertices[3], CubeVertices[4], CubeVertices[8], CubeVertices[7])
end

-- ========== NICKNAME ESP ==========
local function DrawName(targetPlayer)
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
    if onScreen then
        local nameTag = Drawing.new("Text")
        nameTag.Text = targetPlayer.DisplayName or targetPlayer.Name
        nameTag.Position = Vector2.new(screenPos.X, screenPos.Y)
        nameTag.Color = Color3.fromRGB(255, 255, 255)
        nameTag.Size = 16
        nameTag.Center = true
        nameTag.Outline = true
        nameTag.OutlineColor = Color3.new(0, 0, 0)
        nameTag.Visible = true
        table.insert(NameTags, nameTag)
    end
end

-- ========== PING ESP ==========
local function GetPing(targetPlayer)
    return math.random(50, 150) -- fallback
end

-- ========== TRACER ESP ==========
local function DrawTracers()
    for _, line in ipairs(Tracers) do
        SafeRemove(line)
    end
    Tracers = {}

    if not ESPStates.tracer then return end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = targetPlayer.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local tracer = Drawing.new("Line")
                tracer.Thickness = 1.5
                tracer.Color = Color3.fromRGB(255, 0, 0)
                tracer.Transparency = 1
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                tracer.Visible = true
                table.insert(Tracers, tracer)
            end
        end
    end
end

-- ========== RADIUS ESP ==========
local function DrawCircle(center)
    local RADIUS = 5
    local SEGMENTS = 30
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
            line.Color = Color3.fromRGB(0, 255, 0)
            line.Thickness = 1.5
            line.Transparency = 1
            line.Visible = true
            table.insert(Circles, line)
        end
    end
end

-- ========== DISTANCE ESP ==========
local function DrawDistance()
    for _, label in ipairs(DistanceLabels) do
        SafeRemove(label)
    end
    DistanceLabels = {}

    if not ESPStates.distance then return end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = targetPlayer.Character.HumanoidRootPart
            local distance = math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude)

            local screenPos, visible = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            if visible then
                local text = Drawing.new("Text")
                text.Text = tostring(distance) .. "m"
                text.Size = 16
                text.Center = true
                text.Outline = true
                text.Color = Color3.fromRGB(255, 255, 0)
                text.Position = Vector2.new(screenPos.X, screenPos.Y)
                text.Visible = true
                table.insert(DistanceLabels, text)
            end
        end
    end
end

-- ========== ГЛАВНЫЕ ФУНКЦИИ УПРАВЛЕНИЯ ==========
local function EnableESP(espType)
    ESPStates[espType] = true
    
    if espType == "box" then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            CreateBoxESP(targetPlayer)
        end
        if not ESPConnections.box then
            ESPConnections.box = RunService.RenderStepped:Connect(UpdateBoxESP)
        end
    elseif espType == "color" then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                applyStaticRedHighlight(targetPlayer.Character)
            end
        end
    elseif espType == "gradient" then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                createGradientHighlight(targetPlayer.Character)
            end
        end
    elseif espType == "3d box" then
        if not ESPConnections["3d box"] then
            ESPConnections["3d box"] = RunService.RenderStepped:Connect(function()
                if not ESPStates["3d box"] then return end
                
                for _, line in ipairs(Lines3D) do SafeRemove(line) end
                for _, quad in ipairs(Quads3D) do SafeRemove(quad) end
                Lines3D = {}
                Quads3D = {}
                
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if targetPlayer ~= player and HasCharacter(targetPlayer) then
                        DrawEsp3D(targetPlayer)
                    end
                end
            end)
        end
    elseif espType == "nickname" then
        if not ESPConnections.nickname then
            ESPConnections.nickname = RunService.RenderStepped:Connect(function()
                if not ESPStates.nickname then return end
                
                for _, tag in ipairs(NameTags) do SafeRemove(tag) end
                NameTags = {}
                
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if targetPlayer ~= player and HasCharacter(targetPlayer) then
                        DrawName(targetPlayer)
                    end
                end
            end)
        end
    elseif espType == "ping" then
        if not ESPConnections.ping then
            local LastPingUpdate = 0
            ESPConnections.ping = RunService.RenderStepped:Connect(function(dt)
                if not ESPStates.ping then return end
                
                LastPingUpdate = LastPingUpdate + dt
                
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if targetPlayer ~= player and HasCharacter(targetPlayer) then
                        local head = targetPlayer.Character:FindFirstChild("Head")
                        if head then
                            if not PingTags[targetPlayer] then
                                local tag = Drawing.new("Text")
                                tag.Size = 16
                                tag.Color = Color3.fromRGB(0, 255, 0)
                                tag.Center = false
                                tag.Outline = true
                                tag.OutlineColor = Color3.new(0, 0, 0)
                                tag.Visible = true
                                PingTags[targetPlayer] = tag
                                PingValues[targetPlayer] = GetPing(targetPlayer)
                            end

                            if LastPingUpdate >= 0.5 then
                                PingValues[targetPlayer] = GetPing(targetPlayer)
                            end

                            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
                            if onScreen then
                                PingTags[targetPlayer].Text = tostring(PingValues[targetPlayer]) .. " ms"
                                PingTags[targetPlayer].Position = Vector2.new(screenPos.X + 30, screenPos.Y)
                                PingTags[targetPlayer].Visible = true
                            else
                                PingTags[targetPlayer].Visible = false
                            end
                        end
                    end
                end
                
                if LastPingUpdate >= 0.5 then
                    LastPingUpdate = 0
                end
            end)
        end
    elseif espType == "tracer" then
        if not ESPConnections.tracer then
            ESPConnections.tracer = RunService.RenderStepped:Connect(DrawTracers)
        end
    elseif espType == "radius of visibility" then
        if not ESPConnections["radius of visibility"] then
            ESPConnections["radius of visibility"] = RunService.RenderStepped:Connect(function()
                if not ESPStates["radius of visibility"] then return end
                
                for _, v in ipairs(Circles) do SafeRemove(v) end
                Circles = {}
                
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = targetPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, targetPlayer.Character.HumanoidRootPart.Size.Y / 2, 0)
                        DrawCircle(pos)
                    end
                end
            end)
        end
    elseif espType == "distance" then
        if not ESPConnections.distance then
            ESPConnections.distance = RunService.RenderStepped:Connect(DrawDistance)
        end
    end
    
    print(espType .. " ESP включен")
end

local function DisableESP(espType)
    ESPStates[espType] = false
    
    if espType == "box" then
        for _, box in pairs(ESPs) do 
            if box then
                box.Visible = false
                SafeRemove(box) 
            end
        end
        ESPs = {}
        if ESPConnections.box then
            ESPConnections.box:Disconnect()
            ESPConnections.box = nil
        end
    elseif espType == "color" then
        for char, hl in pairs(ColorHighlights) do 
            if hl and hl.Parent then
                hl:Destroy()
            end
        end
        ColorHighlights = {}
        -- Удаляем из всех персонажей
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer.Character then
                local highlight = targetPlayer.Character:FindFirstChild("ColorHighlight")
                if highlight then highlight:Destroy() end
            end
        end
    elseif espType == "gradient" then
        for char, hl in pairs(GradientHighlights) do 
            if hl and hl.Parent then
                hl:Destroy()
            end
        end
        GradientHighlights = {}
        -- Удаляем из всех персонажей
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer.Character then
                local highlight = targetPlayer.Character:FindFirstChild("GradientHighlight")
                if highlight then highlight:Destroy() end
            end
        end
    elseif espType == "3d box" then
        for _, line in ipairs(Lines3D) do SafeRemove(line) end
        for _, quad in ipairs(Quads3D) do SafeRemove(quad) end
        Lines3D = {}
        Quads3D = {}
        if ESPConnections["3d box"] then
            ESPConnections["3d box"]:Disconnect()
            ESPConnections["3d box"] = nil
        end
    elseif espType == "nickname" then
        for _, tag in ipairs(NameTags) do SafeRemove(tag) end
        NameTags = {}
        if ESPConnections.nickname then
            ESPConnections.nickname:Disconnect()
            ESPConnections.nickname = nil
        end
    elseif espType == "ping" then
        for _, tag in pairs(PingTags) do SafeRemove(tag) end
        PingTags = {}
        PingValues = {}
        if ESPConnections.ping then
            ESPConnections.ping:Disconnect()
            ESPConnections.ping = nil
        end
    elseif espType == "tracer" then
        for _, tracer in ipairs(Tracers) do SafeRemove(tracer) end
        Tracers = {}
        if ESPConnections.tracer then
            ESPConnections.tracer:Disconnect()
            ESPConnections.tracer = nil
        end
    elseif espType == "radius of visibility" then
        for _, v in ipairs(Circles) do SafeRemove(v) end
        Circles = {}
        if ESPConnections["radius of visibility"] then
            ESPConnections["radius of visibility"]:Disconnect()
            ESPConnections["radius of visibility"] = nil
        end
    elseif espType == "distance" then
        for _, label in ipairs(DistanceLabels) do SafeRemove(label) end
        DistanceLabels = {}
        if ESPConnections.distance then
            ESPConnections.distance:Disconnect()
            ESPConnections.distance = nil
        end
    end
    
    print(espType .. " ESP выключен")
end

-- Цвета skeet
local colors = {
    background = Color3.fromRGB(17, 17, 17),
    secondary = Color3.fromRGB(25, 25, 25),
    accent = Color3.fromRGB(165, 194, 97),
    text = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(180, 180, 180),
    border = Color3.fromRGB(60, 60, 60),
    hover = Color3.fromRGB(35, 35, 35)
}

-- Настройки с callback функциями
local settings = {
    ESP = {
        title = "ESP",
        options = {
            {name = "box", enabled = false, hasDropdown = true, hasColorPicker = true, callback = function(enabled)
                if enabled then EnableESP("box") else DisableESP("box") end
            end},
            {name = "color", enabled = false, callback = function(enabled)
                if enabled then EnableESP("color") else DisableESP("color") end
            end},
            {name = "gradient", enabled = false, callback = function(enabled)
                if enabled then EnableESP("gradient") else DisableESP("gradient") end
            end},
            {name = "3d box", enabled = false, callback = function(enabled)
                if enabled then EnableESP("3d box") else DisableESP("3d box") end
            end},
            {name = "nickname", enabled = false, callback = function(enabled)
                if enabled then EnableESP("nickname") else DisableESP("nickname") end
            end},
            {name = "ping", enabled = false, callback = function(enabled)
                if enabled then EnableESP("ping") else DisableESP("ping") end
            end},
            {name = "tracer", enabled = false, callback = function(enabled)
                if enabled then EnableESP("tracer") else DisableESP("tracer") end
            end},
            {name = "distance", enabled = false, callback = function(enabled)
                if enabled then EnableESP("distance") else DisableESP("distance") end
            end},
            {name = "radius of visibility", enabled = false, callback = function(enabled)
                if enabled then EnableESP("radius of visibility") else DisableESP("radius of visibility") end
            end},
            {name = "chams", enabled = false}
        }
    },
    Aimbot = {
        title = "Aimbot", 
        options = {
            {name = "Enable Aimbot", enabled = false},
            {name = "FOV Circle", enabled = false},
            {name = "Silent Aim", enabled = false},
            {name = "Triggerbot", enabled = false}
        }
    },
    Misc = {
        title = "Misc",
        options = {
            {name = "Speed Hack", enabled = false},
            {name = "Jump Power", enabled = false},
            {name = "Noclip", enabled = false},
            {name = "Fly", enabled = false}
        }
    }
}

local currentTab = "ESP"

-- Функция для выключения всех ESP
local function DisableAllESP()
    for espType, _ in pairs(ESPStates) do
        if ESPStates[espType] then
            DisableESP(espType)
            -- Обновляем состояние в настройках
            for _, option in ipairs(settings.ESP.options) do
                if option.name == espType then
                    option.enabled = false
                    break
                end
            end
        end
    end
    
    -- Обновляем все чекбоксы в интерфейсе
    local espPage = contentContainer:FindFirstChild("ESPPage")
    if espPage then
        for _, child in pairs(espPage:GetChildren()) do
            if child:IsA("Frame") then
                local checkbox = child:FindFirstChild("TextButton")
                local checkmark = checkbox and checkbox:FindFirstChild("TextLabel")
                if checkbox and checkmark then
                    checkbox.BackgroundColor3 = colors.secondary
                    checkmark.Visible = false
                end
            end
        end
    end
    
    print("Все ESP функции выключены")
end

-- Функция для создания закругленных углов
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
createCorner(mainFrame, 8)

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = colors.secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
createCorner(titleBar, 8)

-- Фикс для закругленных углов только сверху
local titleBarBottom = Instance.new("Frame")
titleBarBottom.Size = UDim2.new(1, 0, 0, 8)
titleBarBottom.Position = UDim2.new(0, 0, 1, -8)
titleBarBottom.BackgroundColor3 = colors.secondary
titleBarBottom.BorderSizePixel = 0
titleBarBottom.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 200, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Text = "skeet.cc"
titleText.TextColor3 = colors.accent
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

-- Кнопка выключения всех ESP
local disableAllButton = Instance.new("TextButton")
disableAllButton.Size = UDim2.new(0, 80, 0, 20)
disableAllButton.Position = UDim2.new(1, -115, 0, 5)
disableAllButton.Text = "Disable All"
disableAllButton.TextColor3 = colors.text
disableAllButton.Font = Enum.Font.SourceSans
disableAllButton.TextSize = 10
disableAllButton.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
disableAllButton.BorderSizePixel = 0
disableAllButton.Parent = titleBar
createCorner(disableAllButton, 4)

disableAllButton.MouseButton1Click:Connect(function()
    DisableAllESP()
end)

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 20)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text = "X"
closeButton.TextColor3 = colors.text
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 12
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar
createCorner(closeButton, 4)

closeButton.MouseButton1Click:Connect(function()
    -- Выключаем все ESP при закрытии
    for espType, _ in pairs(ESPStates) do
        DisableESP(espType)
    end
    gui:Destroy()
end)

-- Контейнер для табов
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 35)
tabContainer.Position = UDim2.new(0, 5, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

-- Контейнер для контента
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -10, 1, -75)
contentContainer.Position = UDim2.new(0, 5, 0, 70)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Функция создания таба
local function createTab(name, index)
    local tabCount = 3 -- ESP, Aimbot, Misc
    
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1/tabCount, -2, 1, 0)
    tabButton.Position = UDim2.new((index-1)/tabCount, (index-1)*2, 0, 0)
    tabButton.Text = name
    tabButton.TextColor3 = (name == currentTab) and colors.accent or colors.textSecondary
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 12
    tabButton.BackgroundColor3 = (name == currentTab) and colors.secondary or colors.background
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabContainer
    createCorner(tabButton, 6)
    
    tabButton.MouseButton1Click:Connect(function()
        -- Обновляем все табы
        for _, child in pairs(tabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = colors.textSecondary
                child.BackgroundColor3 = colors.background
            end
        end
        
        -- Активируем текущий таб
        tabButton.TextColor3 = colors.accent
        tabButton.BackgroundColor3 = colors.secondary
        currentTab = name
        
        -- Показываем соответствующий контент
        for _, page in pairs(contentContainer:GetChildren()) do
            if page:IsA("ScrollingFrame") then
                page.Visible = (page.Name == name .. "Page")
            end
        end
    end)
end

-- Функция создания color picker
local function createColorPicker(parent, yPos)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0, 20, 0, 15)
    colorFrame.Position = UDim2.new(1, -25, 0.5, -7.5)
    colorFrame.BackgroundColor3 = BoxESPSettings.customColor
    colorFrame.BorderSizePixel = 1
    colorFrame.BorderColor3 = colors.border
    colorFrame.ZIndex = 15
    colorFrame.Parent = parent
    createCorner(colorFrame, 3)
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(1, 0, 1, 0)
    colorButton.Text = ""
    colorButton.BackgroundTransparency = 1
    colorButton.ZIndex = 16
    colorButton.Parent = colorFrame
    
    local colorPalette = Instance.new("Frame")
    colorPalette.Size = UDim2.new(0, 200, 0, 120)
    colorPalette.Position = UDim2.new(0, -180, 1, 2)
    colorPalette.BackgroundColor3 = colors.secondary
    colorPalette.BorderSizePixel = 1
    colorPalette.BorderColor3 = colors.border
    colorPalette.Visible = false
    colorPalette.ZIndex = 25
    colorPalette.Parent = colorFrame
    createCorner(colorPalette, 3)
    
    -- Предустановленные цвета
    local presetColors = {
        Color3.fromRGB(255, 255, 255), -- Белый
        Color3.fromRGB(255, 0, 0),     -- Красный
        Color3.fromRGB(0, 255, 0),     -- Зеленый
        Color3.fromRGB(0, 0, 255),     -- Синий
        Color3.fromRGB(255, 255, 0),   -- Желтый
        Color3.fromRGB(255, 0, 255),   -- Фиолетовый
        Color3.fromRGB(0, 255, 255),   -- Голубой
        Color3.fromRGB(255, 165, 0),   -- Оранжевый
        Color3.fromRGB(128, 0, 128),   -- Пурпурный
        Color3.fromRGB(255, 192, 203), -- Розовый
        Color3.fromRGB(0, 128, 0),     -- Темно-зеленый
        Color3.fromRGB(165, 42, 42),   -- Коричневый
    }
    
    -- Создаем кнопки цветов
    for i, color in ipairs(presetColors) do
        local row = math.floor((i-1) / 4)
        local col = (i-1) % 4
        
        local colorSample = Instance.new("TextButton")
        colorSample.Size = UDim2.new(0, 40, 0, 25)
        colorSample.Position = UDim2.new(0, 10 + col * 45, 0, 10 + row * 30)
        colorSample.Text = ""
        colorSample.BackgroundColor3 = color
        colorSample.BorderSizePixel = 1
        colorSample.BorderColor3 = colors.border
        colorSample.ZIndex = 26
        colorSample.Parent = colorPalette
        createCorner(colorSample, 3)
        
        colorSample.MouseButton1Click:Connect(function()
            BoxESPSettings.customColor = color
            BoxESPSettings.useCustomColor = true
            colorFrame.BackgroundColor3 = color
            colorPalette.Visible = false
            print("Выбран цвет ESP:", color)
        end)
        
        colorSample.MouseEnter:Connect(function()
            colorSample.BorderColor3 = colors.accent
        end)
        
        colorSample.MouseLeave:Connect(function()
            colorSample.BorderColor3 = colors.border
        end)
    end
    
    -- Кнопка "Авто цвет" (отключает пользовательский цвет)
    local autoColorButton = Instance.new("TextButton")
    autoColorButton.Size = UDim2.new(0, 180, 0, 20)
    autoColorButton.Position = UDim2.new(0, 10, 1, -25)
    autoColorButton.Text = "Auto Color (Role-based)"
    autoColorButton.TextColor3 = colors.text
    autoColorButton.Font = Enum.Font.SourceSans
    autoColorButton.TextSize = 10
    autoColorButton.BackgroundColor3 = colors.hover
    autoColorButton.BorderSizePixel = 1
    autoColorButton.BorderColor3 = colors.border
    autoColorButton.ZIndex = 26
    autoColorButton.Parent = colorPalette
    createCorner(autoColorButton, 3)
    
    autoColorButton.MouseButton1Click:Connect(function()
        BoxESPSettings.useCustomColor = false
        colorFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Серый для авто режима
        colorPalette.Visible = false
        print("Включен авто цвет ESP (по ролям)")
    end)
    
    local paletteOpen = false
    
    colorButton.MouseButton1Click:Connect(function()
        paletteOpen = not paletteOpen
        colorPalette.Visible = paletteOpen
        print("Color picker clicked, visible:", paletteOpen)
    end)
    
    -- Закрываем палитру при клике вне её
    spawn(function()
        while colorFrame.Parent do
            wait(0.1)
            if paletteOpen then
                local mouse = UserInputService:GetMouseLocation()
                local framePos = colorFrame.AbsolutePosition
                local palettePos = colorPalette.AbsolutePosition
                local paletteSize = colorPalette.AbsoluteSize
                
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local insidePalette = (mouse.X >= palettePos.X and mouse.X <= palettePos.X + paletteSize.X and
                                         mouse.Y >= palettePos.Y and mouse.Y <= palettePos.Y + paletteSize.Y)
                    local insideButton = (mouse.X >= framePos.X and mouse.X <= framePos.X + 20 and
                                         mouse.Y >= framePos.Y and mouse.Y <= framePos.Y + 15)
                    
                    if not insidePalette and not insideButton then
                        wait(0.1)
                        paletteOpen = false
                        colorPalette.Visible = false
                    end
                end
            end
        end
    end)
    
    return colorFrame
end

-- Функция создания dropdown меню с множественным выбором
local function createMultiDropdown(parent, yPos)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 120, 0, 15)
    dropdownFrame.Position = UDim2.new(1, -150, 0.5, -7.5)
    dropdownFrame.BackgroundColor3 = colors.secondary
    dropdownFrame.BorderSizePixel = 1
    dropdownFrame.BorderColor3 = colors.border
    dropdownFrame.ZIndex = 15
    dropdownFrame.Parent = parent
    createCorner(dropdownFrame, 3)
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Text = "All Players ▼"
    dropdownButton.TextColor3 = colors.text
    dropdownButton.Font = Enum.Font.SourceSans
    dropdownButton.TextSize = 9
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.ZIndex = 16
    dropdownButton.Parent = dropdownFrame
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, 75)
    dropdownList.Position = UDim2.new(0, 0, 1, 2)
    dropdownList.BackgroundColor3 = colors.secondary
    dropdownList.BorderSizePixel = 1
    dropdownList.BorderColor3 = colors.border
    dropdownList.Visible = false
    dropdownList.ZIndex = 20
    dropdownList.Parent = dropdownFrame
    createCorner(dropdownList, 3)
    
    local options = {
        {text = "All Players", setting = "showAll"},
        {text = "Murderer", setting = "showMurderer"},
        {text = "Sheriff", setting = "showSheriff"}
    }
    
    -- Создаем чекбоксы для каждой опции
    for i, option in ipairs(options) do
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, -4, 1/3, -2)
        optionFrame.Position = UDim2.new(0, 2, (i-1)/3, (i-1))
        optionFrame.BackgroundTransparency = 1
        optionFrame.ZIndex = 21
        optionFrame.Parent = dropdownList
        
        local optionCheckbox = Instance.new("TextButton")
        optionCheckbox.Size = UDim2.new(0, 12, 0, 12)
        optionCheckbox.Position = UDim2.new(0, 5, 0.5, -6)
        optionCheckbox.Text = ""
        optionCheckbox.BackgroundColor3 = BoxESPSettings[option.setting] and colors.accent or colors.background
        optionCheckbox.BorderSizePixel = 1
        optionCheckbox.BorderColor3 = colors.border
        optionCheckbox.ZIndex = 22
        optionCheckbox.Parent = optionFrame
        createCorner(optionCheckbox, 2)
        
        local optionCheckmark = Instance.new("TextLabel")
        optionCheckmark.Size = UDim2.new(1, 0, 1, 0)
        optionCheckmark.Text = "✓"
        optionCheckmark.TextColor3 = colors.background
        optionCheckmark.Font = Enum.Font.SourceSansBold
        optionCheckmark.TextSize = 8
        optionCheckmark.BackgroundTransparency = 1
        optionCheckmark.Visible = BoxESPSettings[option.setting]
        optionCheckmark.ZIndex = 23
        optionCheckmark.Parent = optionCheckbox
        
        local optionLabel = Instance.new("TextLabel")
        optionLabel.Size = UDim2.new(1, -25, 1, 0)
        optionLabel.Position = UDim2.new(0, 20, 0, 0)
        optionLabel.Text = option.text
        optionLabel.TextColor3 = colors.text
        optionLabel.Font = Enum.Font.SourceSans
        optionLabel.TextSize = 9
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.BackgroundTransparency = 1
        optionLabel.ZIndex = 22
        optionLabel.Parent = optionFrame
        
        optionCheckbox.MouseButton1Click:Connect(function()
            -- Если выбираем "All Players", отключаем остальные
            if option.setting == "showAll" then
                BoxESPSettings.showAll = not BoxESPSettings.showAll
                if BoxESPSettings.showAll then
                    BoxESPSettings.showMurderer = false
                    BoxESPSettings.showSheriff = false
                end
            else
                -- Если выбираем конкретную роль, отключаем "All Players"
                BoxESPSettings[option.setting] = not BoxESPSettings[option.setting]
                if BoxESPSettings[option.setting] then
                    BoxESPSettings.showAll = false
                end
            end
            
            -- Обновляем ВСЕ чекбоксы в dropdown (исправленная логика)
            for j, opt in ipairs(options) do
                local frame = dropdownList:GetChildren()[j]
                if frame and frame:IsA("Frame") then
                    local checkbox = frame:FindFirstChild("TextButton")
                    local checkmark = checkbox and checkbox:FindFirstChild("TextLabel")
                    if checkbox and checkmark then
                        local isActive = BoxESPSettings[opt.setting]
                        checkbox.BackgroundColor3 = isActive and colors.accent or colors.background
                        checkmark.Visible = isActive
                    end
                end
            end
            
            -- Обновляем текст кнопки (исправленная логика)
            local activeOptions = {}
            if BoxESPSettings.showAll then
                table.insert(activeOptions, "All Players")
            end
            if BoxESPSettings.showMurderer then
                table.insert(activeOptions, "Murderer")
            end
            if BoxESPSettings.showSheriff then
                table.insert(activeOptions, "Sheriff")
            end
            
            if #activeOptions == 0 then
                dropdownButton.Text = "None ▼"
            elseif #activeOptions == 1 then
                dropdownButton.Text = activeOptions[1] .. " ▼"
            else
                dropdownButton.Text = table.concat(activeOptions, "+") .. " ▼"
            end
            
            print("Box ESP настройки обновлены:")
            print("  All Players:", BoxESPSettings.showAll)
            print("  Murderer:", BoxESPSettings.showMurderer) 
            print("  Sheriff:", BoxESPSettings.showSheriff)
            print("  Dropdown показывает:", dropdownButton.Text)
        end)
        
        optionFrame.MouseEnter:Connect(function()
            optionFrame.BackgroundColor3 = colors.hover
            optionFrame.BackgroundTransparency = 0.5
        end)
        
        optionFrame.MouseLeave:Connect(function()
            optionFrame.BackgroundTransparency = 1
        end)
    end
    
    -- Правильная инициализация dropdown (добавить после создания всех опций)
    local function updateDropdownDisplay()
        -- Обновляем все чекбоксы
        for j, opt in ipairs(options) do
            local frame = dropdownList:GetChildren()[j]
            if frame and frame:IsA("Frame") then
                local checkbox = frame:FindFirstChild("TextButton")
                local checkmark = checkbox and checkbox:FindFirstChild("TextLabel")
                if checkbox and checkmark then
                    local isActive = BoxESPSettings[opt.setting]
                    checkbox.BackgroundColor3 = isActive and colors.accent or colors.background
                    checkmark.Visible = isActive
                end
            end
        end
        
        -- Обновляем текст кнопки
        local activeOptions = {}
        if BoxESPSettings.showAll then
            table.insert(activeOptions, "All Players")
        end
        if BoxESPSettings.showMurderer then
            table.insert(activeOptions, "Murderer")
        end
        if BoxESPSettings.showSheriff then
            table.insert(activeOptions, "Sheriff")
        end
        
        if #activeOptions == 0 then
            dropdownButton.Text = "None ▼"
        elseif #activeOptions == 1 then
            dropdownButton.Text = activeOptions[1] .. " ▼"
        else
            dropdownButton.Text = table.concat(activeOptions, "+") .. " ▼"
        end
    end

    -- Вызываем инициализацию
    updateDropdownDisplay()
    
    local dropdownOpen = false
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        dropdownList.Visible = dropdownOpen
        print("Multi-dropdown clicked, visible:", dropdownOpen)
    end)
    
    -- Закрываем dropdown при клике вне его
    spawn(function()
        while dropdownFrame.Parent do
            wait(0.1)
            if dropdownOpen then
                local mouse = UserInputService:GetMouseLocation()
                local framePos = dropdownFrame.AbsolutePosition
                local frameSize = dropdownFrame.AbsoluteSize
                local listSize = dropdownList.AbsoluteSize
                
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local insideDropdown = (mouse.X >= framePos.X and mouse.X <= framePos.X + frameSize.X and
                                          mouse.Y >= framePos.Y and mouse.Y <= framePos.Y + frameSize.Y + listSize.Y)
                    
                    if not insideDropdown then
                        wait(0.1)
                        dropdownOpen = false
                        dropdownList.Visible = false
                    end
                end
            end
        end
    end)
    
    return dropdownFrame
end

-- Функция создания чекбокса
local function createCheckbox(parent, option, yPos)
    local checkFrame = Instance.new("Frame")
    checkFrame.Size = UDim2.new(1, -10, 0, 25)
    checkFrame.Position = UDim2.new(0, 5, 0, yPos)
    checkFrame.BackgroundTransparency = 1
    checkFrame.ZIndex = 2
    checkFrame.Parent = parent
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 15, 0, 15)
    checkbox.Position = UDim2.new(0, 0, 0.5, -7.5)
    checkbox.Text = ""
    checkbox.BackgroundColor3 = option.enabled and colors.accent or colors.secondary
    checkbox.BorderColor3 = colors.border
    checkbox.BorderSizePixel = 1
    checkbox.ZIndex = 3
    checkbox.Parent = checkFrame
    createCorner(checkbox, 3)
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.Text = "✓"
    checkmark.TextColor3 = colors.background
    checkmark.Font = Enum.Font.SourceSansBold
    checkmark.TextSize = 10
    checkmark.BackgroundTransparency = 1
    checkmark.Visible = option.enabled
    checkmark.ZIndex = 4
    checkmark.Parent = checkbox
    
    local labelWidth = 1
    if option.hasDropdown and option.hasColorPicker then
        labelWidth = -175 -- Место для dropdown и color picker
    elseif option.hasDropdown then
        labelWidth = -150 -- Место только для dropdown
    elseif option.hasColorPicker then
        labelWidth = -50 -- Место только для color picker
    else
        labelWidth = -25 -- Стандартное место
    end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, labelWidth, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.Text = option.name
    label.TextColor3 = colors.text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 3
    label.Parent = checkFrame
    
    -- Добавляем dropdown если нужно
    if option.hasDropdown then
        createMultiDropdown(checkFrame, yPos)
    end
    
    -- Добавляем color picker если нужно
    if option.hasColorPicker then
        createColorPicker(checkFrame, yPos)
    end
    
    checkbox.MouseButton1Click:Connect(function()
        option.enabled = not option.enabled
        checkmark.Visible = option.enabled
        checkbox.BackgroundColor3 = option.enabled and colors.accent or colors.secondary
        
        -- Вызываем callback если есть
        if option.callback then
            option.callback(option.enabled)
        end
        
        print(option.name .. " is now " .. (option.enabled and "enabled" or "disabled"))
    end)
end

-- Функция создания страницы
local function createPage(name, data)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundColor3 = colors.secondary
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = colors.accent
    page.CanvasSize = UDim2.new(0, 0, 0, #data.options * 30 + 20)
    page.Visible = (name == currentTab)
    page.ZIndex = 1
    page.Parent = contentContainer
    createCorner(page, 6)
    
    for i, option in ipairs(data.options) do
        createCheckbox(page, option, (i-1) * 30 + 5)
    end
end

-- Создаем табы и страницы
local tabNames = {"ESP", "Aimbot", "Misc"}
for i, name in ipairs(tabNames) do
    createTab(name, i)
    createPage(name, settings[name])
end

-- Подключаем создание ESP для новых игроков
Players.PlayerAdded:Connect(function(newPlayer)
    if ESPStates.box then CreateBoxESP(newPlayer) end
    if ESPStates.color and newPlayer.Character then applyStaticRedHighlight(newPlayer.Character) end
    if ESPStates.gradient and newPlayer.Character then createGradientHighlight(newPlayer.Character) end
end)

-- Делаем окно перетаскиваемым
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Анимация появления
mainFrame.Size = UDim2.new(0, 0, 0, 0)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 600, 0, 400)})
tween:Play()

-- Горячая клавиша для выключения всех ESP (клавиша END)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.End then
        DisableAllESP()
    end
end)

print("Complete Skeet menu with color picker loaded!")
