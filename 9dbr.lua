local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local MAX_DISTANCE = 200

local function aggressiveBlinkHack()
    local character = player.Character
    if not character then return end

    local blink = character:FindFirstChild("Blink")
    if not blink then return end

    -- Изменяем атрибуты дальности
    local attributesToSet = {
        "ChargedDistance", "Distance_Max", "MaxDistance",
        "BlinkDistance", "Range", "MaxRange",
        "Distance", "Limit", "MaxLimit",
        "Power", "Strength"
    }

    for _, attrName in ipairs(attributesToSet) do
        pcall(function()
            local currentValue = blink:GetAttribute(attrName)
            if currentValue and tonumber(currentValue) < MAX_DISTANCE then
                blink:SetAttribute(attrName, MAX_DISTANCE)
            end
        end)
    end

    -- Изменяем дочерние объекты Blink
    for _, child in ipairs(blink:GetChildren()) do
        if (child:IsA("NumberValue") or child:IsA("IntValue")) and child.Value < MAX_DISTANCE then
            pcall(function()
                child.Value = MAX_DISTANCE
            end)
        end

        for attrName, attrValue in pairs(child:GetAttributes()) do
            if tonumber(attrValue) and tonumber(attrValue) < MAX_DISTANCE then
                pcall(function()
                    child:SetAttribute(attrName, MAX_DISTANCE)
                end)
            end
        end
    end

    -- Изменяем PowerValues
    local powerValues = blink:FindFirstChild("PowerValues")
    if powerValues then
        for _, child in ipairs(powerValues:GetChildren()) do
            if (child:IsA("NumberValue") or child:IsA("IntValue")) and child.Value < MAX_DISTANCE then
                pcall(function()
                    child.Value = MAX_DISTANCE
                end)
            end
        end
    end

    -- Изменяем модуль Blink, если есть
    local blinkModule = blink:FindFirstChild("Blink")
    if blinkModule and blinkModule:IsA("ModuleScript") then
        pcall(function()
            local module = require(blinkModule)
            if module.Limits then
                module.Limits.Distance_Max = MAX_DISTANCE
                module.Limits.MaxDistance = MAX_DISTANCE
            end
        end)
    end
end

RunService.Heartbeat:Connect(aggressiveBlinkHack)

-- Автоперехват изменений при респавне
local function hookBlinkEvents()
    local character = player.Character
    if not character then return end

    local blink = character:FindFirstChild("Blink")
    if not blink then return end

    blink.AttributeChanged:Connect(function(attributeName)
        if attributeName == "ChargedDistance" or attributeName == "Distance_Max" then
            local value = blink:GetAttribute(attributeName)
            if value and tonumber(value) < MAX_DISTANCE then
                task.wait()
                blink:SetAttribute(attributeName, MAX_DISTANCE)
            end
        end
    end)
end

if player.Character then
    hookBlinkEvents()
end

player.CharacterAdded:Connect(function()
    task.wait(2)
    hookBlinkEvents()
end)

print("🚀 Усиленный Blink Hack активен. Дальность:", MAX_DISTANCE)
