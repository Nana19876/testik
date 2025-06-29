-- LocalScript, вставить в StarterPlayerScripts

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Utility: HSV → RGB
local function HSVtoRGB(h, s, v)
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then return v, t, p end
	if i == 1 then return q, v, p end
	if i == 2 then return p, v, t end
	if i == 3 then return p, q, v end
	if i == 4 then return t, p, v end
	if i == 5 then return v, p, q end
end

-- Удаляем старый GUI, если был
if playerGui:FindFirstChild("ColorPickerDemo") then
	playerGui.ColorPickerDemo:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ColorPickerDemo"
gui.Parent = playerGui
gui.ResetOnSpawn = false

-- Основной фон
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 220)
frame.Position = UDim2.new(0, 60, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(35,35,38)
frame.Parent = gui

-- Предпросмотр цвета
local preview = Instance.new("Frame")
preview.Size = UDim2.new(0, 60, 0, 60)
preview.Position = UDim2.new(0, 10, 0, 10)
preview.BackgroundColor3 = Color3.new(1,1,1)
preview.BorderSizePixel = 1
preview.Parent = frame

-- Градиентная область (Sat/Bright)
local colorPad = Instance.new("ImageButton")
colorPad.Size = UDim2.new(0, 220, 0, 120)
colorPad.Position = UDim2.new(0, 80, 0, 10)
colorPad.AutoButtonColor = false
colorPad.BorderSizePixel = 1
colorPad.Parent = frame
colorPad.Image = "rbxassetid://6020299389" -- Базовый бело-чёрно-прозрачный градиент

-- Цветовой слайдер (Hue)
local hueSlider = Instance.new("Frame")
hueSlider.Size = UDim2.new(0, 220, 0, 18)
hueSlider.Position = UDim2.new(0, 80, 0, 140)
hueSlider.BackgroundColor3 = Color3.fromRGB(0,0,0)
hueSlider.BorderSizePixel = 1
hueSlider.Parent = frame

local hueGradient = Instance.new("UIGradient")
hueGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
}
hueGradient.Parent = hueSlider

local hueSelector = Instance.new("Frame")
hueSelector.Size = UDim2.new(0, 6, 1, 0)
hueSelector.Position = UDim2.new(0, 0, 0, 0)
hueSelector.BackgroundColor3 = Color3.fromRGB(255,255,255)
hueSelector.BorderSizePixel = 0
hueSelector.Parent = hueSlider

-- Курсор на colorPad
local padCursor = Instance.new("Frame")
padCursor.Size = UDim2.new(0, 8, 0, 8)
padCursor.AnchorPoint = Vector2.new(0.5,0.5)
padCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
padCursor.BorderColor3 = Color3.fromRGB(20,20,20)
padCursor.BorderSizePixel = 1
padCursor.Parent = colorPad

-- Данные цвета
local hue, sat, val = 0, 1, 1 -- начально - яркий цвет
local selectedColor = Color3.new(1,1,1)

-- Функция обновления всего
local function updateColor()
	local r,g,b = HSVtoRGB(hue, sat, val)
	selectedColor = Color3.new(r,g,b)
	preview.BackgroundColor3 = selectedColor
	-- Обновляем градиент colorPad для текущего hue
	local hCol = Color3.fromHSV(hue, 1, 1)
	colorPad.ImageColor3 = hCol
end

-- Hue-ползунок
hueSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local moveConn
		moveConn = game:GetService("UserInputService").InputChanged:Connect(function(changed)
			if changed.UserInputType == Enum.UserInputType.MouseMovement then
				local rel = math.clamp((changed.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
				hue = rel
				hueSelector.Position = UDim2.new(rel, -3, 0, 0)
				updateColor()
			end
		end)
		game:GetService("UserInputService").InputEnded:Connect(function(ended)
			if ended.UserInputType == Enum.UserInputType.MouseButton1 then
				if moveConn then moveConn:Disconnect() end
			end
		end)
	end
end)

-- ColorPad (Sat/Bright)
colorPad.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local moveConn
		local function setSV(pos)
			local x = math.clamp((pos.X - colorPad.AbsolutePosition.X) / colorPad.AbsoluteSize.X, 0, 1)
			local y = math.clamp((pos.Y - colorPad.AbsolutePosition.Y) / colorPad.AbsoluteSize.Y, 0, 1)
			sat = x
			val = 1 - y
			padCursor.Position = UDim2.new(x, 0, y, 0)
			updateColor()
		end
		setSV(input.Position)
		moveConn = game:GetService("UserInputService").InputChanged:Connect(function(changed)
			if changed.UserInputType == Enum.UserInputType.MouseMovement then
				setSV(changed.Position)
			end
		end)
		game:GetService("UserInputService").InputEnded:Connect(function(ended)
			if ended.UserInputType == Enum.UserInputType.MouseButton1 then
				if moveConn then moveConn:Disconnect() end
			end
		end)
	end
end)

-- Начальное положение
updateColor()
padCursor.Position = UDim2.new(sat, 0, 1-val, 0)

-- Теперь переменная selectedColor содержит твой гибко выбранный цвет!
-- Используй selectedColor для своих Box/ESP/GUI

