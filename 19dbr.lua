local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local MAX_DISTANCE = 200

local function aggressiveBlinkHack()
    local character = player.Character
    if not character then return end

    local blink = character:FindFirstChild("Blink")
    if not blink then return end

    -- Только параметры дальности
    local attributesToSet = {
        "ChargedDistance", "Distance_Max", "MaxDistance",
        "BlinkDistance", "Range", "MaxRange",
        "Distance"
    }

    for _, attrName in ipairs(attributesToSet) do
        pcall(function()
            local val = blink:GetAttribute(attrName)
            if val and tonumber(val) and val < MAX_DISTANCE then
                blink:SetAttribute(attrName, MAX_DISTANCE)
            end
        end)
    end

    -- Меняем только безопасные дочерние значения
    for _, child in ipairs(blink:GetChildren()) do
        if (child:IsA("NumberValue") or child:IsA("IntValue")) and child.Value < MAX_DISTANCE then
            local n = child.Name:lower()
            if not (n:find("blink") or n:find("charge") or n:find("power") or n:find("count")) then
                pcall(function()
                    child.Value = MAX_DISTANCE
                end)
            end
        end

        -- Также фильтруем атрибуты дочерних объектов
        for attrName, attrValue in pairs(child:GetAttributes()) do
            local nameLower = attrName:lower()
            if tonumber(attrValue) and tonumber(attrValue) < MAX_DISTANCE and not (
                nameLower:find("blink") or nameLower:find("charge") or nameLower:find("power") or nameLower:find("count")
            ) then
                pcall(function()
                    child:SetAttribute(attrName, MAX_DISTANCE)
                end)
            end
        end
    end

    -- PowerValues: фильтруем только на "дальность"
    local powerValues = blink:FindFirstChild("PowerValues")
    if powerValues then
        for _, child in ipairs(powerValues:GetChildren()) do
            if (child:IsA("NumberValue") or child:IsA("IntValue")) and child.Value < MAX_DISTANCE then
                local n = child.Name:lower()
                if not (n:find("blink") or n:find("charge") or n:find("power") or n:find("count")) then
                    pcall(function()
                        child.Value = MAX_DISTANCE
                    end)
                end
            end
        end
    end

    -- Модификация модуля Blink: безопасно только для Distance
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

local function hookBlinkEvents()
    local character = player.Character
    if not character then return end

    local blink = character:FindFirstChild("Blink")
    if not blink then return end

    blink.AttributeChanged:Connect(function(attributeName)
        if attributeName == "ChargedDistance" or attributeName == "Distance_Max" then
            local val = blink:GetAttribute(attributeName)
            if val and tonumber(val) and val < MAX_DISTANCE then
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

print("🚀 Blink дальность увеличена, без затрагивания количества зарядов")
