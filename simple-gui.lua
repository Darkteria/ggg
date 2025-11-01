-- Simple GEF GUI v2.0 (Mobile Optimized)
-- Работает в Roblox на Android (Delta, Hydrogen, Arceus X и др.)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- === ПАПКИ ===
local gefFolder = Workspace:FindFirstChild("GEFs")
local moneyFolder = Workspace:FindFirstChild("Pickups")

-- === ПЕРЕМЕННЫЕ ===
local texts = {}
local textVisible = false
local moneyTextVisible = false
local lightingActive = false
local hurtboxRemoved = false

-- === ESP ФУНКЦИИ ===
local function addESP(obj, text, color)
    if texts[obj] then return end
    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if not part then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 120, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    texts[obj] = billboard
end

local function removeESP(obj)
    if texts[obj] then
        texts[obj]:Destroy()
        texts[obj] = nil
    end
end

-- === ОСНОВНЫЕ ФУНКЦИИ ===
local function toggleGEFsESP()
    textVisible = not textVisible
    if textVisible then
        if gefFolder then
            for _, gef in pairs(gefFolder:GetChildren()) do
                if gef:IsA("Model") then
                    addESP(gef, "Mini GEF", Color3.new(1, 1, 0))
                end
            end
        end
        local bigGEF = Workspace:FindFirstChild("GEF")
        if bigGEF and bigGEF:IsA("Model") then
            addESP(bigGEF, "GEF", Color3.new(1, 0, 0))
        end
    else
        for obj, _ in pairs(texts) do
            if obj.Name == "GEF" or (gefFolder and obj.Parent == gefFolder) then
                removeESP(obj)
            end
        end
    end
end

local function toggleMoneyESP()
    moneyTextVisible = not moneyTextVisible
    if moneyTextVisible and moneyFolder then
        for _, money in pairs(moneyFolder:GetChildren()) do
            if money.Name == "Money" then
                addESP(money, "Money", Color3.new(0, 1, 0))
            end
        end
    else
        for obj, _ in pairs(texts) do
            if obj.Name == "Money" then
                removeESP(obj)
            end
        end
    end
end

local function removeHurtboxes()
    if hurtboxRemoved then return end
    hurtboxRemoved = true
    task.spawn(function()
        while true do
            if gefFolder then
                for _, gef in pairs(gefFolder:GetChildren()) do
                    if gef:IsA("Model") then
                        for _, child in pairs(gef:GetChildren()) do
                            if child.Name == "Hurtbox" then
                                child:Destroy()
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

local function setInfiniteDamage(toolName)
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    for _, tool in pairs(backpack:GetChildren()) do
        if tool.Name == toolName then
            local damage = tool:FindFirstChild("Damage") or Instance.new("NumberValue", tool)
            damage.Name = "Damage"
            damage.Value = 99999
        end
    end
end

local function toggleDaylight()
    lightingActive = not lightingActive
    if lightingActive then
        task.spawn(function()
            while lightingActive do
                Lighting.Ambient = Color3.fromRGB(100, 100, 100)
                Lighting.Brightness = 3
                Lighting.ClockTime = 12
                Lighting.FogEnd = 10000
                task.wait(2)
            end
        end)
    end
end

local function teleportToNearestGEF()
    if not gefFolder then return end
    local closest = nil
    local minDist = math.huge
    for _, gef in pairs(gefFolder:GetChildren()) do
        if gef:IsA("Model") and gef.PrimaryPart then
            local dist = (gef.PrimaryPart.Position - humanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = gef
            end
        end
    end
    if closest then
        humanoidRootPart.CFrame = closest.PrimaryPart.CFrame
    end
end

-- === АВТОДОБАВЛЕНИЕ НОВЫХ ОБЪЕКТОВ ===
task.spawn(function()
    while true do
        task.wait(1)
        if textVisible and gefFolder then
            for _, gef in pairs(gefFolder:GetChildren()) do
                if gef:IsA("Model") and not texts[gef] then
                    addESP(gef, "Mini GEF", Color3.new(1, 1, 0))
                end
            end
            local bigGEF = Workspace:FindFirstChild("GEF")
            if bigGEF and not texts[bigGEF] then
                addESP(bigGEF, "GEF", Color3.new(1, 0, 0))
            end
        end
        if moneyTextVisible and moneyFolder then
            for _, money in pairs(moneyFolder:GetChildren()) do
                if money.Name == "Money" and not texts[money] then
                    addESP(money, "Money", Color3.new(0, 1, 0))
                end
            end
        end
    end
end)

-- === СОЗДАНИЕ МОБИЛЬНОГО GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileGEFGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 500)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "GEF GUI Mobile"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

-- Кнопка сворачивания
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 40, 0, 40)
collapseBtn.Position = UDim2.new(1, -45, 0, 5)
collapseBtn.Text = "−"
collapseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.Parent = mainFrame

-- Контент
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -70)
content.Position = UDim2.new(0, 10, 0, 60)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = content

-- Функция создания кнопки
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.Parent = content
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Кнопки
createButton("Teleport to Nearest GEF", teleportToNearestGEF)
createButton("No Damage", removeHurtboxes)
createButton("Infinity Crowbar", function() setInfiniteDamage("Crowbar") end)
createButton("Infinity Bat", function() setInfiniteDamage("Bat") end)
createButton("GEFs ESP", toggleGEFsESP)
createButton("Money ESP", toggleMoneyESP)
createButton("Day Light", toggleDaylight)

-- Телепорт к предметам
local items = {"Shotgun", "Handgun", "Hammer", "Lantern", "Shells", "Soda", "Money", "Crowbar", "Food", "Bat", "Medkit", "GPS", "Bullets"}
for _, name in ipairs(items) do
    createButton("Teleport to " .. name, function()
        local folder = name == "Money" and moneyFolder or Workspace:FindFirstChild("Pickups")
        local item = folder and folder:FindFirstChild(name)
        if item then
            humanoidRootPart.CFrame = item.CFrame
        end
    end)
end

-- Сворачивание
local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    local targetSize = collapsed and UDim2.new(0, 60, 0, 60) or UDim2.new(0, 380, 0, 500)
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    collapseBtn.Text = collapsed and "+" or "−"
end)

-- Перетаскивание (опционально)
local dragging = false
local dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("Mobile GEF GUI загружен!")
