-- [ Darkteria Hub ] Optimized for EXILED + Android Fix
-- Функции: Бессмертие, 1 Hit Kill, Попытка выдачи монет, Сворачиваемый GUI

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ===
local Settings = {
    InfiniteHealth = false,
    OneHitKill = false,
    CoinsAmount = 80
}

local espObjects = {}
local noclipConnection = nil
local isGuiCollapsed = false

-- === ФУНКЦИИ ЧИТОВ ===

-- 1. БЕСКОНЕЧНОЕ ЗДОРОВЬЕ
task.spawn(function()
    while task.wait(0.1) do
        if Settings.InfiniteHealth and humanoid and humanoid.Parent then
            -- Попытка установить здоровье (может сбрасываться сервером)
            pcall(function() humanoid.Health = humanoid.MaxHealth end)
        end
    end
end)

-- 2. УБИЙСТВО С 1 УДАРА (OHK)
local function connectOHK(tool)
    if not tool:IsA("Tool") then return end
    local handle = tool:FindFirstChild("Handle")
    if handle and not handle:FindFirstChild("OHK_Conn") then
        local conn = handle.Touched:Connect(function(hit)
            if Settings.OneHitKill then
                local enemyHum = hit.Parent:FindFirstChildOfClass("Humanoid")
                if enemyHum and enemyHum ~= humanoid then
                    -- Попытка нанести урон (зависит от фильтрации игры)
                    pcall(function() enemyHum:TakeDamage(99999) end)
                end
            end
        end)
        conn.Name = "OHK_Conn"
    end
end

local function refreshOHK()
    if not Settings.OneHitKill then return end
    local tools = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then for _, t in ipairs(backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    for _, t in ipairs(character:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
    
    for _, t in ipairs(tools) do connectOHK(t) end
end

player.Backpack.ChildAdded:Connect(refreshOHK)
character.ChildAdded:Connect(refreshOHK)

-- 3. ПОПЫТКА ВЫДАЧИ МОНЕТ (80)
local function setCoins(amount)
    local success = false
    -- Поиск возможных значений валюты в Player или Leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if string.match(string.lower(stat.Name), "coin") or string.match(string.lower(stat.Name), "cash") or string.match(string.lower(stat.Name), "money") then
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    pcall(function() stat.Value = amount end)
                    success = true
                    break
                end
            end
        end
    end
    
    -- Поиск в самом объекте игрока
    if not success then
        for _, v in ipairs(player:GetChildren()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue")) and string.match(string.lower(v.Name), "coin") then
                pcall(function() v.Value = amount end)
                success = true
                break
            end
        end
    end

    if success then
        notify("Монеты установлены: " .. amount)
    else
        notify("Ошибка: Валюта защищена сервером!")
    end
end

-- === GUI СИСТЕМА ===

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkteriaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Основной фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true -- Включаем встроенную драг-функцию для надежности
MainFrame.Parent = ScreenGui

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Darkteria Hub | EXILED"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.Parent = TitleBar

-- Контент (Скролл)
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -50)
ContentFrame.Position = UDim2.new(0, 5, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 5
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.Parent = ContentFrame

-- Кнопка сворачивания (Внутри MainFrame, но поверх всего)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = MainFrame
MinimizeBtn.ZIndex = 10

-- Уведомления
local function notify(msg)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0, 100)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.BackgroundTransparency = 0.3
    notif.Text = msg
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.Font = Enum.Font.Gotham
    notif.TextSize = 16
    notif.Parent = ScreenGui
    
    TweenService:Create(notif, TweenInfo.new(2), {Position = UDim2.new(0.5, -150, 0, 50)}):Play()
    task.delay(2.5, function()
        TweenService:Create(notif, TweenInfo.new(0.5), {Transparency = 1}):Play()
        task.wait(0.5)
        notif:Destroy()
    end)
end

-- Создание кнопок и тумблеров
local function createToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = ContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -55, 0.5, -12.5)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return frame
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Parent = ContentFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- === ЭЛЕМЕНТЫ УПРАВЛЕНИЯ ===

createToggle("Бессмертие", false, function(v) 
    Settings.InfiniteHealth = v 
    notify(v and "Бессмертие ВКЛ" or "Бессмертие ВЫКЛ")
end)

createToggle("1 Hit Kill", false, function(v) 
    Settings.OneHitKill = v 
    if v then refreshOHK() end
    notify(v and "1 Hit Kill ВКЛ" or "1 Hit Kill ВЫКЛ")
end)

createButton("Получить 80 Монет", function()
    setCoins(Settings.CoinsAmount)
end)

createButton("Респawn Игрока", function()
    pcall(function() character:BreakJoints() end)
end)

createButton("Телепорт в Спавн", function()
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(0, 5, 0) -- Координаты спавна могут отличаться
    end
end)

-- === ЛОГИКА СВОРАЧИВАНИЯ (FIX) ===
MinimizeBtn.MouseButton1Click:Connect(function()
    isGuiCollapsed = not isGuiCollapsed
    
    if isGuiCollapsed then
        -- Сворачиваем
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 350, 0, 40), -- Оставляем только заголовок
            Position = UDim2.new(0.5, -175, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)
        }):Play()
        ContentFrame.Visible = false
        MinimizeBtn.Text = "+"
    else
        -- Разворачиваем
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 350, 0, 450),
            Position = UDim2.new(0.5, -175, 0.5, -225)
        }):Play()
        ContentFrame.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

-- === ИСПРАВЛЕНИЕ ДРАГ-СИСТЕМЫ (ANDROID + PC) ===
-- Встроенная MainFrame.Draggable = true обычно работает лучше на Android, 
-- но добавим ручную обработку для надежности с кнопкой сворачивания.

local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Не драгать, если нажали на кнопку сворачивания
        if UserInputService:GetMouseLocation().X >= MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X - 35 then return end
        
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

notify("Darkteria Hub Загружен!")
