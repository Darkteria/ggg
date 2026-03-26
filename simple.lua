-- ═══════════════════════════════════════════════════
-- 📚 EDUCATIONAL PURPOSE ONLY - Roblox GUI Example
-- ⚠️ Не использовать на публичных серверах!
-- ═══════════════════════════════════════════════════

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ─── Создание ScreenGui ─────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExiledHelper_GUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 100

-- ─── Основной фрейм интерфейса ──────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Selectable = true
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
Title.Text = "⚡ Exiled Helper [EDU]"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Кнопка сворачивания
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 2)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 20
MinimizeBtn.Parent = Title

-- ─── Контейнер для кнопок (скрывается при сворачивании) ─
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, 0, 1, -30)
ButtonContainer.Position = UDim2.new(0, 0, 0, 30)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

-- ─── Функция создания кнопок ─────────────────────────
local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, (#ButtonContainer:GetChildren() * 40) + 5)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = ButtonContainer
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ─── 🔐 GOD MODE (только визуальная защита) ─────────
-- ⚠️ Настоящий год-мод требует доступа к серверу!
local godMode = false
local originalHealth = 100

createButton("🛡️ God Mode: OFF", Color3.fromRGB(0, 180, 80), function(btn)
    godMode = not godMode
    btn.Text = ("🛡️ God Mode: %s"):format(godMode and "ON" or "OFF")
    btn.BackgroundColor3 = godMode and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(0, 180, 80)
    
    if godMode and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local humanoid = Player.Character.Humanoid
        originalHealth = humanoid.Health
        
        -- 🔁 Мягкое восстановление здоровья БЕЗ лагов
        task.spawn(function()
            while godMode and Player.Character and humanoid.Parent do
                if humanoid.Health < originalHealth then
                    humanoid.Health = math.min(humanoid.Health + 5, originalHealth)
                end
                task.wait(0.2) -- Небольшая задержка, чтобы не лагать
            end
        end)
    end
end)

-- Обработка возрождения для God Mode
Player.CharacterAdded:Connect(function(char)
    if godMode then
        char:WaitForChild("Humanoid").Health = 100
    end
end)

-- ─── 💰 ДОБАВЛЕНИЕ МОНЕТ (КЛИЕНТ-САЙД ВИЗУАЛИЗАЦИЯ) ─
-- ⚠️ Реальное изменение валюты требует RemoteEvent на сервер!
createButton("💰 +1000 Coins [VISUAL]", Color3.fromRGB(255, 215, 0), function()
    -- 🎭 Это только визуальный эффект для обучения!
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, -100, 0.5, -20)
    notification.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    notification.Text = "✅ +1000 Coins (визуально)"
    notification.TextColor3 = Color3.new(0, 1, 0)
    notification.TextScaled = true
    notification.Font = Enum.Font.SourceSansBold
    notification.Parent = ScreenGui
    
    -- Анимация исчезновения
    task.delay(2, function()
        notification:TweenSize(UDim2.new(0, 200, 0, 0), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        notification:Destroy()
    end)
    
    -- 📝 Чтобы реально добавить монеты, нужен серверный скрипт:
    --[[
    -- Пример серверного кода (ServerScriptService):
    local RemoteEvent = Instance.new("RemoteEvent")
    RemoteEvent.Name = "AddCoinsEvent"
    RemoteEvent.Parent = game.ReplicatedStorage
    
    RemoteEvent.OnServerEvent:Connect(function(player, amount)
        -- 🔐 Здесь должна быть проверка прав!
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Coins") then
            leaderstats.Coins.Value = leaderstats.Coins.Value + amount
        end
    end)
    ]]
end)

-- ─── ⚔️ ONE-HIT KILL (только если есть доступ к инструменту) ─
createButton("⚔️ One-Hit Kill [EDU]", Color3.fromRGB(200, 50, 50), function()
    -- 🎯 Учебный пример: изменение урона оружия в руке
    local character = Player.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        -- ⚠️ Это работает ТОЛЬКО если у оружия есть локальный скрипт урона
        -- В большинстве игр урон рассчитывается на сервере!
        
        local originalDamage = tool:FindFirstChild("Damage")
        if originalDamage and originalDamage:IsA("NumberValue") then
            originalDamage.Value = 9999
            task.delay(5, function() originalDamage.Value = 25 end) -- Сброс через 5 сек
        end
    else
        -- Уведомление, если инструмент не найден
        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(0, 250, 0, 30)
        msg.Position = UDim2.new(0.5, -125, 0.6, 0)
        msg.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        msg.Text = "⚠️ Нет оружия в руке или урон на сервере"
        msg.TextColor3 = Color3.new(1, 1, 1)
        msg.TextScaled = true
        msg.Font = Enum.Font.SourceSans
        msg.Parent = ScreenGui
        task.delay(2, function() msg:Destroy() end)
    end
end)

-- ─── 🔄 Кнопка обновления статуса ───────────────────
createButton("🔄 Refresh Status", Color3.fromRGB(100, 100, 180), function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local h = Player.Character.Humanoid
        print(string.format("❤️ Health: %.1f | 🏃 Speed: %.1f | 🦘 Jump: %.1f", 
            h.Health, h.WalkSpeed, h.JumpPower))
    end
end)

-- ─── 🗑️ Кнопка закрытия ─────────────────────────────
createButton("❌ Close GUI", Color3.fromRGB(180, 50, 50), function()
    ScreenGui:Destroy()
end)

-- ─── 🎛️ Логика сворачивания/разворачивания ─────────
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Сворачиваем: оставляем только заголовок
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 30), "Out", "Quad", 0.2, true)
        ButtonContainer.Visible = false
        MinimizeBtn.Text = "+"
    else
        -- Разворачиваем
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 200), "Out", "Quad", 0.2, true)
        ButtonContainer.Visible = true
        MinimizeBtn.Text = "−"
    end
end)

-- ─── 🎨 Дополнительные улучшения интерфейса ─────────
-- Плавное появление
MainFrame.BackgroundTransparency = 1
MainFrame:TweenProperty("BackgroundTransparency", 0, 0.3)

-- Автоматическое позиционирование кнопок
local function updateButtonPositions()
    for i, btn in ipairs(ButtonContainer:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.Position = UDim2.new(0.05, 0, 0, (i-1) * 40 + 5)
        end
    end
end
updateButtonPositions()

-- Поддержка изменения размера окна
MainFrame:GetPropertyChangedSignal("Size"):Connect(updateButtonPositions)

-- Горячая клавиша для сворачивания (Insert)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MinimizeBtn:Fire()
    end
end)

-- ─── ✅ Почему этот скрипт НЕ замедляет игрока: ─────
-- 1. Все циклы используют task.wait() с задержками
-- 2. Нет бесконечных while true без пауз
-- 3. Визуальные эффекты удаляются после использования
-- 4. Отсутствуют тяжёлые вычисления в реальном времени
-- 5. Изменения применяются только при нажатии кнопок

print("✅ Exiled Helper GUI loaded (EDUCATIONAL MODE)")
