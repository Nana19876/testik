-- Усиленный скрипт для изменения дальности Blink
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local MAX_DISTANCE = 200

print("=== УСИЛЕННЫЙ BLINK HACK ===")

local function aggressiveBlinkHack()
    local character = player.Character
    if not character then return end
    
    local blink = character:FindFirstChild("Blink")
    if not blink then return end
    
    -- Пробуем ВСЕ возможные атрибуты
    local attributesToSet = {
        "ChargedDistance",
        "Distance_Max", 
        "MaxDistance",
        "BlinkDistance",
        "Range",
        "MaxRange",
        "Distance",
        "Limit",
        "MaxLimit",
        "Power",
        "Strength"
    }
    
    for _, attrName in pairs(attributesToSet) do
        pcall(function()
            local currentValue = blink:GetAttribute(attrName)
            if currentValue and tonumber(currentValue) then
                blink:SetAttribute(attrName, MAX_DISTANCE)
            end
        end)
    end
    
    -- Пробуем модифицировать дочерние объекты
    for _, child in pairs(blink:GetChildren()) do
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            pcall(function()
                if child.Value < MAX_DISTANCE then
                    child.Value = MAX_DISTANCE
                end
            end)
        end
        
        -- Проверяем атрибуты дочерних объектов
        for attrName, attrValue in pairs(child:GetAttributes()) do
            if tonumber(attrValue) and tonumber(attrValue) < MAX_DISTANCE then
                pcall(function()
                    child:SetAttribute(attrName, MAX_DISTANCE)
                end)
            end
        end
    end
    
    -- Пробуем найти и модифицировать PowerValues
    local powerValues = blink:FindFirstChild("PowerValues")
    if powerValues then
        for _, child in pairs(powerValues:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                pcall(function()
                    if child.Value < MAX_DISTANCE then
                        child.Value = MAX_DISTANCE
                        print("Изменен PowerValues." .. child.Name .. " на", MAX_DISTANCE)
                    end
                end)
            end
        end
    end
    
    -- Пробуем модифицировать сам модуль (если доступен)
    local blinkModule = blink:FindFirstChild("Blink") 
    if blinkModule and blinkModule:IsA("ModuleScript") then
        pcall(function()
            local module = require(blinkModule)
            if module.Limits then
                module.Limits.Distance_Max = MAX_DISTANCE
                module.Limits.MaxDistance = MAX_DISTANCE
                print("Модифицирован модуль Blink")
            end
        end)
    end
end

-- Запускаем очень часто чтобы перебить игровые сбросы
local connection = RunService.Heartbeat:Connect(aggressiveBlinkHack)

-- Также пробуем хукнуть события
local function hookBlinkEvents()
    local character = player.Character
    if not character then return end
    
    local blink = character:FindFirstChild("Blink")
    if not blink then return end
    
    -- Отслеживаем изменения атрибутов и сразу перезаписываем
    blink.AttributeChanged:Connect(function(attributeName)
        if attributeName == "ChargedDistance" or attributeName == "Distance_Max" then
            local value = blink:GetAttribute(attributeName)
            if value and tonumber(value) and tonumber(value) < MAX_DISTANCE then
                wait() -- Небольшая задержка
                blink:SetAttribute(attributeName, MAX_DISTANCE)
                print("Перезаписан", attributeName, "на", MAX_DISTANCE)
            end
        end
    end)
end

-- Хукаем при появлении персонажа
if player.Character then
    hookBlinkEvents()
end

player.CharacterAdded:Connect(function()
    wait(2)
    hookBlinkEvents()
end)

print("Агрессивный хак запущен! Дистанция:", MAX_DISTANCE)
print("Если не работает - игра использует серверную валидацию")
