-- [ Developer UI Template ] - Только для обучения и своих игр
-- Не используйте в чужих проектах для нарушения правил

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === НАСТРОЙКИ GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Основной фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true -- Важно для перетаскивания
mainFrame.Draggable = false -- Мы сделаем свой драг для контроля
mainFrame.Parent = screenGui

-- Заголовок (для перетаскивания)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Настройки Игры"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = header

-- Контент
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "Это меню для твоей собственной игры.\nЗдесь нет чит-функций."
label.TextColor3 = Color3.new(1, 1, 1)
label.TextWrapped = true
label.Parent = content

-- Кнопка сворачивания
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(1, -35, 0, 5)
collapseBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
collapseBtn.Text = "−"
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.TextSize = 20
collapseBtn.Parent = header

-- === ЛОГИКА ПЕРЕТАСКИВАНИЯ (DRAG) ===
local dragging = false
local dragInput, mousePos, framePos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- === ЛОГИКА СВОРАЧИВАНИЯ ===
local isCollapsed = false

collapseBtn.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    
    if isCollapsed then
        -- Сворачиваем
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 300, 0, 40)})
        tween:Play()
        content.Visible = false
        collapseBtn.Text = "+"
    else
        -- Разворачиваем
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 300, 0, 200)})
        tween:Play()
        content.Visible = true
        collapseBtn.Text = "−"
    end
end)

-- === КУРСОР (Для ПК) ===
-- В Roblox курсор обычно управляется системой, но можно включить иконку
UserInputService.MouseIconEnabled = true 

print("Интерфейс загружен (Легальная версия)")
