local function aggressiveBlinkHack()
    local character = player.Character
    if not character then return end

    local blink = character:FindFirstChild("Blink")
    if not blink then return end

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
            if currentValue and tonumber(currentValue) and tonumber(currentValue) < MAX_DISTANCE then
                blink:SetAttribute(attrName, MAX_DISTANCE)
                print("[Blink.Attribute] Изменён:", attrName, "->", MAX_DISTANCE)
            end
        end)
    end

    for _, child in pairs(blink:GetChildren()) do
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            pcall(function()
                if child.Value < MAX_DISTANCE then
                    print("[Blink.ValueObject] Изменён:", child.Name, "->", MAX_DISTANCE)
                    child.Value = MAX_DISTANCE
                end
            end)
        end

        for attrName, attrValue in pairs(child:GetAttributes()) do
            if tonumber(attrValue) and tonumber(attrValue) < MAX_DISTANCE then
                pcall(function()
                    child:SetAttribute(attrName, MAX_DISTANCE)
                    print("[Blink.Child.Attribute] Изменён:", child.Name.."."..attrName, "->", MAX_DISTANCE)
                end)
            end
        end
    end

    local powerValues = blink:FindFirstChild("PowerValues")
    if powerValues then
        for _, child in pairs(powerValues:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                pcall(function()
                    if child.Value < MAX_DISTANCE then
                        print("[PowerValues] Изменён:", child.Name, "->", MAX_DISTANCE)
                        child.Value = MAX_DISTANCE
                    end
                end)
            end
        end
    end

    local blinkModule = blink:FindFirstChild("Blink")
    if blinkModule and blinkModule:IsA("ModuleScript") then
        pcall(function()
            local module = require(blinkModule)
            if module.Limits then
                module.Limits.Distance_Max = MAX_DISTANCE
                module.Limits.MaxDistance = MAX_DISTANCE
                print("[ModuleScript] Модифицирован модуль Blink.Limits")
            end
        end)
    end
end
