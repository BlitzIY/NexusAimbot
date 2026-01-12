local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Teste | developed by Blitz",
   LoadingTitle = "LOading...",
   LoadingSubtitle = "By Blitz",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "AimbotESPConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

-- CONFIGURAÇÕES
local CONFIG = {
    -- Aimbot
    AIMBOT_ENABLED = true,
    AIM_FOV = 250,
    AIM_SMOOTHNESS = 0.2,
    AIM_PREDICTION = 0.15,
    AIM_KEY = Enum.UserInputType.MouseButton2,
    AIM_VISIBILITY_CHECK = true,
    AIM_TEAM_CHECK = true,
    AIM_USE_FOV_CIRCLE = true,
    AIM_LOCK_PART = "Head",
    AIM_MAX_DISTANCE = 1000,
    AIM_TRIGGERBOT = false,
    AIM_TRIGGER_DELAY = 0.1,
    
    -- ESP
    ESP_ENABLED = true,
    ESP_TEAM_COLOR = Color3.fromRGB(0, 120, 255),
    ESP_ENEMY_COLOR = Color3.fromRGB(255, 0, 0),
    ESP_TRANSPARENCY = 0.55,
    ESP_OUTLINE_TRANSPARENCY = 0,
    ESP_FILL_COLOR = true,
    ESP_SHOW_NAMES = true,
    ESP_SHOW_DISTANCE = true,
    ESP_SHOW_HEALTH = true,
    ESP_SHOW_BOXES = true,
    ESP_SHOW_TRACERS = true,
    ESP_HEALTH_BASED_COLOR = true,
    ESP_TEXT_SIZE = 14,
    ESP_MAX_DISTANCE = 500,
    
    -- Visual
    VISUAL_FOV_CIRCLE_COLOR = Color3.fromRGB(255, 255, 255),
    VISUAL_FOV_CIRCLE_TRANSPARENCY = 0.5,
    VISUAL_CROSSHAIR = false,
    VISUAL_CROSSHAIR_COLOR = Color3.fromRGB(255, 0, 0),
    VISUAL_WATERMARK = true,
    
    -- Misc
    MISC_AUTO_RESPAWN = false,
    MISC_SPEED_HACK = false,
    MISC_SPEED_MULTIPLIER = 2,
    MISC_JUMP_POWER = false,
    MISC_JUMP_MULTIPLIER = 2,
    MISC_NO_RECOIL = false,
    MISC_NO_SPREAD = false,
    MISC_INFINITE_AMMO = false,
    MISC_FLY_ENABLED = false,
    MISC_FLY_SPEED = 50,
    MISC_NOCLIP = false,
    MISC_FULLBRIGHT = true
}

local highlights = {}
local espLabels = {}
local aiming = false
local target = nil
local fovCircle = nil
local crosshair = nil
local connections = {}

-- Função 1: Criar Highlight ESP
local function createESP(player)
    if player == LocalPlayer then return end
    if highlights[player] then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.Adornee = character
    highlight.FillTransparency = CONFIG.ESP_TRANSPARENCY
    highlight.OutlineTransparency = CONFIG.ESP_OUTLINE_TRANSPARENCY
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Função 2: Atualizar cor do ESP baseado na vida
    local function updateHealthColor()
        if CONFIG.ESP_HEALTH_BASED_COLOR and humanoid.Health > 0 then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            highlight.FillColor = Color3.new(1 - healthPercent, healthPercent, 0)
        end
    end
    
    highlights[player] = {
        Highlight = highlight,
        Character = character,
        Humanoid = humanoid
    }
    
    highlight.Parent = Workspace
    
    -- Função 3: Criar labels do ESP
    if CONFIG.ESP_SHOW_NAMES or CONFIG.ESP_SHOW_DISTANCE or CONFIG.ESP_SHOW_HEALTH then
        createESPLabels(player)
    end
    
    connections[player] = humanoid.HealthChanged:Connect(updateHealthColor)
end

-- Função 4: Criar labels do ESP
local function createESPLabels(player)
    if espLabels[player] then return end
    
    local gui = Instance.new("BillboardGui")
    gui.Name = player.Name .. "_ESP_Labels"
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 200, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextSize = CONFIG.ESP_TEXT_SIZE
    nameLabel.Text = player.Name
    nameLabel.Visible = CONFIG.ESP_SHOW_NAMES
    nameLabel.Parent = gui
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextStrokeTransparency = 0.5
    infoLabel.TextSize = CONFIG.ESP_TEXT_SIZE
    infoLabel.Visible = CONFIG.ESP_SHOW_HEALTH or CONFIG.ESP_SHOW_DISTANCE
    infoLabel.Parent = gui
    
    espLabels[player] = {
        GUI = gui,
        NameLabel = nameLabel,
        InfoLabel = infoLabel
    }
    
    local char = player.Character
    if char then
        gui.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        gui.Parent = char
    end
end

-- Função 5: Atualizar labels do ESP
local function updateESPLabels(player)
    local labels = espLabels[player]
    if not labels then return end
    
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    local infoText = ""
    
    if CONFIG.ESP_SHOW_HEALTH then
        infoText = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
    end
    
    if CONFIG.ESP_SHOW_DISTANCE and LocalPlayer.Character then
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if localRoot then
            local distance = (rootPart.Position - localRoot.Position).Magnitude
            if CONFIG.ESP_SHOW_HEALTH then
                infoText = infoText .. " | "
            end
            infoText = infoText .. math.floor(distance) .. "m"
        end
    end
    
    labels.InfoLabel.Text = infoText
end

-- Função 6: Atualizar cor do ESP
local function updateESPColor(player)
    local data = highlights[player]
    if not data or not data.Highlight then return end
    
    if player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            data.Highlight.FillColor = CONFIG.ESP_TEAM_COLOR
            data.Highlight.OutlineColor = CONFIG.ESP_TEAM_COLOR
        else
            data.Highlight.FillColor = CONFIG.ESP_ENEMY_COLOR
            data.Highlight.OutlineColor = CONFIG.ESP_ENEMY_COLOR
        end
    else
        data.Highlight.FillColor = CONFIG.ESP_ENEMY_COLOR
        data.Highlight.OutlineColor = CONFIG.ESP_ENEMY_COLOR
    end
end

-- Função 7: Verificar se é inimigo
local function isEnemy(player)
    if not CONFIG.AIM_TEAM_CHECK then return true end
    if not player.Team or not LocalPlayer.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

-- Função 8: Verificar visibilidade
local function isVisible(part)
    if not CONFIG.AIM_VISIBILITY_CHECK then return true end
    
    local origin = Camera.CFrame.Position
    local targetPos = part.Position
    local direction = (targetPos - origin).Unit * 1000
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    
    if result and result.Instance:IsDescendantOf(part.Parent) then
        return true
    end
    
    return false
end

-- Função 9: Encontrar alvo mais próximo
local function getClosestEnemy()
    local closest = nil
    local shortestDistance = CONFIG.AIM_FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer 
        and player.Character 
        and isEnemy(player) 
        and (player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")) then
            
            local targetPart = player.Character:FindFirstChild(CONFIG.AIM_LOCK_PART) or player.Character:FindFirstChild("HumanoidRootPart")
            if not targetPart then continue end
            
            -- Função 10: Verificar distância máxima
            local distanceToPlayer = (targetPart.Position - Camera.CFrame.Position).Magnitude
            if distanceToPlayer > CONFIG.AIM_MAX_DISTANCE then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen and isVisible(targetPart) then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = targetPart
                end
            end
        end
    end

    return closest
end

-- Função 11: Suavizar aimbot
local function smoothAim(targetPosition)
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    
    local tweenInfo = TweenInfo.new(
        CONFIG.AIM_SMOOTHNESS,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(Camera, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
end

-- Função 12: Prever movimento
local function predictPosition(part)
    local character = part.Parent
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then return part.Position end
    
    local velocity = humanoidRootPart.Velocity
    local distance = (part.Position - Camera.CFrame.Position).Magnitude
    local timeToTarget = distance / 1000 -- Aproximação
    
    return part.Position + (velocity * timeToTarget * CONFIG.AIM_PREDICTION)
end

-- Função 13: Criar círculo do FOV
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    
    local circle = Drawing.new("Circle")
    circle.Visible = CONFIG.AIM_USE_FOV_CIRCLE
    circle.Transparency = CONFIG.VISUAL_FOV_CIRCLE_TRANSPARENCY
    circle.Color = CONFIG.VISUAL_FOV_CIRCLE_COLOR
    circle.Thickness = 2
    circle.NumSides = 64
    circle.Radius = CONFIG.AIM_FOV
    circle.Filled = false
    circle.Position = UserInputService:GetMouseLocation()
    
    fovCircle = circle
    return circle
end

-- Função 14: Criar crosshair
local function createCrosshair()
    if crosshair then crosshair:Remove() end
    
    local center = Drawing.new("Line")
    center.Visible = CONFIG.VISUAL_CROSSHAIR
    center.Color = CONFIG.VISUAL_CROSSHAIR_COLOR
    center.Thickness = 2
    center.From = Vector2.new(0, 0)
    center.To = Vector2.new(0, 0)
    
    local horizontal = Drawing.new("Line")
    horizontal.Visible = CONFIG.VISUAL_CROSSHAIR
    horizontal.Color = CONFIG.VISUAL_CROSSHAIR_COLOR
    horizontal.Thickness = 2
    
    local vertical = Drawing.new("Line")
    vertical.Visible = CONFIG.VISUAL_CROSSHAIR
    vertical.Color = CONFIG.VISUAL_CROSSHAIR_COLOR
    vertical.Thickness = 2
    
    crosshair = {
        Center = center,
        Horizontal = horizontal,
        Vertical = vertical
    }
    
    return crosshair
end

-- Função 15: Atualizar crosshair
local function updateCrosshair()
    if not crosshair or not CONFIG.VISUAL_CROSSHAIR then return end
    
    local mousePos = UserInputService:GetMouseLocation()
    local centerX, centerY = mousePos.X, mousePos.Y
    local size = 8
    
    crosshair.Center.From = Vector2.new(centerX, centerY - size)
    crosshair.Center.To = Vector2.new(centerX, centerY + size)
    
    crosshair.Horizontal.From = Vector2.new(centerX - size, centerY)
    crosshair.Horizontal.To = Vector2.new(centerX + size, centerY)
    
    crosshair.Vertical.From = Vector2.new(centerX, centerY - size)
    crosshair.Vertical.To = Vector2.new(centerX, centerY + size)
end

-- Função 16: Fly hack
local flyConnection = nil
local function fly()
    if not CONFIG.MISC_FLY_ENABLED or not LocalPlayer.Character then return end
    
    -- Disconnect previous fly connection
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    humanoid.PlatformStand = true
    
    local flyBV = Instance.new("BodyVelocity")
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.P = 10000
    flyBV.Parent = rootPart
    
    local flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 10000
    flyBG.CFrame = rootPart.CFrame
    flyBG.Parent = rootPart
    
    -- Controles
    local function updateFly()
        if not flyBV or not flyBV.Parent or not flyBG or not flyBG.Parent then 
            flyConnection:Disconnect()
            return 
        end
        
        local camCF = Camera.CFrame
        local moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + (camCF.LookVector * CONFIG.MISC_FLY_SPEED)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - (camCF.LookVector * CONFIG.MISC_FLY_SPEED)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + (camCF.RightVector * CONFIG.MISC_FLY_SPEED)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - (camCF.RightVector * CONFIG.MISC_FLY_SPEED)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, CONFIG.MISC_FLY_SPEED, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, CONFIG.MISC_FLY_SPEED, 0)
        end
        
        flyBV.Velocity = moveVector
        flyBG.CFrame = Camera.CFrame
    end
    
    flyConnection = RunService.RenderStepped:Connect(updateFly)
end

-- Função 17: Noclip
local noclipActive = false
local function noclip()
    if not CONFIG.MISC_NOCLIP then 
        noclipActive = false
        return 
    end
    
    if noclipActive then return end
    noclipActive = true
    
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Função 18: Fullbright
local function setFullbright()
    if not CONFIG.MISC_FULLBRIGHT then return end
    
    local lighting = game:GetService("Lighting")
    lighting.Ambient = Color3.new(1, 1, 1)
    lighting.Brightness = 2
    lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

-- Função 19: Atualizar todas as configurações
local function updateAllSettings()
    -- ESP
    for player, data in pairs(highlights) do
        if data.Highlight then
            data.Highlight.FillTransparency = CONFIG.ESP_TRANSPARENCY
            data.Highlight.OutlineTransparency = CONFIG.ESP_OUTLINE_TRANSPARENCY
            updateESPColor(player)
        end
    end
    
    -- FOV Circle
    if fovCircle then
        fovCircle.Visible = CONFIG.AIM_USE_FOV_CIRCLE
        fovCircle.Color = CONFIG.VISUAL_FOV_CIRCLE_COLOR
        fovCircle.Transparency = CONFIG.VISUAL_FOV_CIRCLE_TRANSPARENCY
        fovCircle.Radius = CONFIG.AIM_FOV
    end
    
    -- Crosshair
    if crosshair then
        for _, drawing in pairs(crosshair) do
            drawing.Visible = CONFIG.VISUAL_CROSSHAIR
            drawing.Color = CONFIG.VISUAL_CROSSHAIR_COLOR
        end
    end
end

-- Função 20: Limpar tudo
local function cleanup()
    for player, data in pairs(highlights) do
        if data.Highlight then
            data.Highlight:Destroy()
        end
    end
    
    for player, labels in pairs(espLabels) do
        if labels.GUI then
            labels.GUI:Destroy()
        end
    end
    
    if fovCircle then
        fovCircle:Remove()
    end
    
    if crosshair then
        for _, drawing in pairs(crosshair) do
            drawing:Remove()
        end
    end
    
    highlights = {}
    espLabels = {}
    aiming = false
    target = nil
end

-- Função 21: Triggerbot
local function triggerbot()
    if not CONFIG.AIM_TRIGGERBOT or not aiming then return end
    
    if target and target.Parent then
        local mouse = LocalPlayer:GetMouse()
        mouse:TriggerButton1Down()
        task.wait(CONFIG.AIM_TRIGGER_DELAY)
        mouse:TriggerButton1Up()
    end
end

-- Função 22: Iniciar todos os sistemas
local function initializeAllSystems()
    -- Criar círculo FOV
    if CONFIG.AIM_USE_FOV_CIRCLE then
        createFOVCircle()
    end
    
    -- Criar crosshair
    if CONFIG.VISUAL_CROSSHAIR then
        createCrosshair()
    end
    
    -- Ativar Fullbright
    if CONFIG.MISC_FULLBRIGHT then
        setFullbright()
    end
    
    -- Inicializar ESP para jogadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and CONFIG.ESP_ENABLED then
            createESP(player)
        end
    end
end

-- INTERFACE RAYFIELD

-- Tab Principal
local MainTab = Window:CreateTab("Principal", 4483362458)

-- Seção Aimbot
local AimbotSection = MainTab:CreateSection("Aimbot")

MainTab:CreateToggle({
    Name = "Ativar Aimbot",
    CurrentValue = CONFIG.AIMBOT_ENABLED,
    Flag = "AimbotToggle",
    Callback = function(value)
        CONFIG.AIMBOT_ENABLED = value
    end,
})

MainTab:CreateSlider({
    Name = "FOV do Aimbot",
    Range = {1, 500},
    Increment = 1,
    Suffix = "px",
    CurrentValue = CONFIG.AIM_FOV,
    Flag = "AimbotFOV",
    Callback = function(value)
        CONFIG.AIM_FOV = value
        if fovCircle then
            fovCircle.Radius = value
        end
    end,
})

MainTab:CreateSlider({
    Name = "Suavidade",
    Range = {0.1, 1},
    Increment = 0.05,
    CurrentValue = CONFIG.AIM_SMOOTHNESS,
    Flag = "AimbotSmooth",
    Callback = function(value)
        CONFIG.AIM_SMOOTHNESS = value
    end,
})

MainTab:CreateDropdown({
    Name = "Parte do Corpo",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = CONFIG.AIM_LOCK_PART,
    Flag = "AimbotPart",
    Callback = function(value)
        CONFIG.AIM_LOCK_PART = value
    end,
})

MainTab:CreateToggle({
    Name = "Verificar Visibilidade",
    CurrentValue = CONFIG.AIM_VISIBILITY_CHECK,
    Flag = "VisibilityCheck",
    Callback = function(value)
        CONFIG.AIM_VISIBILITY_CHECK = value
    end,
})

MainTab:CreateToggle({
    Name = "Verificar Time",
    CurrentValue = CONFIG.AIM_TEAM_CHECK,
    Flag = "TeamCheck",
    Callback = function(value)
        CONFIG.AIM_TEAM_CHECK = value
    end,
})

MainTab:CreateSlider({
    Name = "Distância Máxima",
    Range = {100, 5000},
    Increment = 50,
    Suffix = "estudos",
    CurrentValue = CONFIG.AIM_MAX_DISTANCE,
    Flag = "MaxDistance",
    Callback = function(value)
        CONFIG.AIM_MAX_DISTANCE = value
    end,
})

MainTab:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = CONFIG.AIM_TRIGGERBOT,
    Flag = "Triggerbot",
    Callback = function(value)
        CONFIG.AIM_TRIGGERBOT = value
    end,
})

MainTab:CreateSlider({
    Name = "Delay do Triggerbot",
    Range = {0.05, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = CONFIG.AIM_TRIGGER_DELAY,
    Flag = "TriggerDelay",
    Callback = function(value)
        CONFIG.AIM_TRIGGER_DELAY = value
    end,
})

-- Seção ESP
local ESPSection = MainTab:CreateSection("ESP")

MainTab:CreateToggle({
    Name = "Ativar ESP",
    CurrentValue = CONFIG.ESP_ENABLED,
    Flag = "ESPToggle",
    Callback = function(value)
        CONFIG.ESP_ENABLED = value
        if not value then
            cleanup()
        else
            initializeAllSystems()
        end
    end,
})

MainTab:CreateColorPicker({
    Name = "Cor do Time",
    Color = CONFIG.ESP_TEAM_COLOR,
    Flag = "TeamColor",
    Callback = function(value)
        CONFIG.ESP_TEAM_COLOR = value
        updateAllSettings()
    end,
})

MainTab:CreateColorPicker({
    Name = "Cor do Inimigo",
    Color = CONFIG.ESP_ENEMY_COLOR,
    Flag = "EnemyColor",
    Callback = function(value)
        CONFIG.ESP_ENEMY_COLOR = value
        updateAllSettings()
    end,
})

MainTab:CreateSlider({
    Name = "Transparência",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = CONFIG.ESP_TRANSPARENCY,
    Flag = "ESPTransparency",
    Callback = function(value)
        CONFIG.ESP_TRANSPARENCY = value
        updateAllSettings()
    end,
})

MainTab:CreateToggle({
    Name = "Mostrar Nomes",
    CurrentValue = CONFIG.ESP_SHOW_NAMES,
    Flag = "ShowNames",
    Callback = function(value)
        CONFIG.ESP_SHOW_NAMES = value
        for player, labels in pairs(espLabels) do
            if labels.NameLabel then
                labels.NameLabel.Visible = value
            end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Mostrar Vida",
    CurrentValue = CONFIG.ESP_SHOW_HEALTH,
    Flag = "ShowHealth",
    Callback = function(value)
        CONFIG.ESP_SHOW_HEALTH = value
    end,
})

MainTab:CreateToggle({
    Name = "Mostrar Distância",
    CurrentValue = CONFIG.ESP_SHOW_DISTANCE,
    Flag = "ShowDistance",
    Callback = function(value)
        CONFIG.ESP_SHOW_DISTANCE = value
    end,
})

MainTab:CreateToggle({
    Name = "Cor Baseada na Vida",
    CurrentValue = CONFIG.ESP_HEALTH_BASED_COLOR,
    Flag = "HealthBasedColor",
    Callback = function(value)
        CONFIG.ESP_HEALTH_BASED_COLOR = value
        updateAllSettings()
    end,
})

MainTab:CreateSlider({
    Name = "Tamanho do Texto",
    Range = {8, 24},
    Increment = 1,
    CurrentValue = CONFIG.ESP_TEXT_SIZE,
    Flag = "TextSize",
    Callback = function(value)
        CONFIG.ESP_TEXT_SIZE = value
        for player, labels in pairs(espLabels) do
            if labels.NameLabel then
                labels.NameLabel.TextSize = value
            end
            if labels.InfoLabel then
                labels.InfoLabel.TextSize = value
            end
        end
    end,
})

-- Tab Visual
local VisualTab = Window:CreateTab("Visual", 4483362458)

VisualTab:CreateToggle({
    Name = "Círculo do FOV",
    CurrentValue = CONFIG.AIM_USE_FOV_CIRCLE,
    Flag = "FOVCircle",
    Callback = function(value)
        CONFIG.AIM_USE_FOV_CIRCLE = value
        if value then
            createFOVCircle()
        elseif fovCircle then
            fovCircle.Visible = false
        end
    end,
})

VisualTab:CreateColorPicker({
    Name = "Cor do Círculo FOV",
    Color = CONFIG.VISUAL_FOV_CIRCLE_COLOR,
    Flag = "FOVColor",
    Callback = function(value)
        CONFIG.VISUAL_FOV_CIRCLE_COLOR = value
        if fovCircle then
            fovCircle.Color = value
        end
    end,
})

VisualTab:CreateSlider({
    Name = "Transparência do Círculo",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = CONFIG.VISUAL_FOV_CIRCLE_TRANSPARENCY,
    Flag = "FOVTransparency",
    Callback = function(value)
        CONFIG.VISUAL_FOV_CIRCLE_TRANSPARENCY = value
        if fovCircle then
            fovCircle.Transparency = value
        end
    end,
})

VisualTab:CreateToggle({
    Name = "Crosshair",
    CurrentValue = CONFIG.VISUAL_CROSSHAIR,
    Flag = "CrosshairToggle",
    Callback = function(value)
        CONFIG.VISUAL_CROSSHAIR = value
        if value then
            createCrosshair()
        elseif crosshair then
            for _, drawing in pairs(crosshair) do
                drawing.Visible = false
            end
        end
    end,
})

VisualTab:CreateColorPicker({
    Name = "Cor do Crosshair",
    Color = CONFIG.VISUAL_CROSSHAIR_COLOR,
    Flag = "CrosshairColor",
    Callback = function(value)
        CONFIG.VISUAL_CROSSHAIR_COLOR = value
        if crosshair then
            for _, drawing in pairs(crosshair) do
                drawing.Color = value
            end
        end
    end,
})

VisualTab:CreateToggle({
    Name = "Watermark",
    CurrentValue = CONFIG.VISUAL_WATERMARK,
    Flag = "Watermark",
    Callback = function(value)
        CONFIG.VISUAL_WATERMARK = value
        if value then
            Rayfield:Notify({
                Title = "Aimbot + ESP",
                Content = "Script ativado | 813737182^192",
                Duration = 5,
            })
        end
    end,
})

-- Tab Misc
local MiscTab = Window:CreateTab("Miscelânea", 4483362458)

MiscTab:CreateToggle({
    Name = "Fly Hack",
    CurrentValue = CONFIG.MISC_FLY_ENABLED,
    Flag = "FlyToggle",
    Callback = function(value)
        CONFIG.MISC_FLY_ENABLED = value
        if value then
            fly()
        end
    end,
})

MiscTab:CreateSlider({
    Name = "Velocidade do Fly",
    Range = {10, 200},
    Increment = 5,
    Suffix = "estudos/s",
    CurrentValue = CONFIG.MISC_FLY_SPEED,
    Flag = "FlySpeed",
    Callback = function(value)
        CONFIG.MISC_FLY_SPEED = value
    end,
})

MiscTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = CONFIG.MISC_NOCLIP,
    Flag = "NoclipToggle",
    Callback = function(value)
        CONFIG.MISC_NOCLIP = value
    end,
})

MiscTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = CONFIG.MISC_FULLBRIGHT,
    Flag = "FullbrightToggle",
    Callback = function(value)
        CONFIG.MISC_FULLBRIGHT = value
        if value then
            setFullbright()
        end
    end,
})

MiscTab:CreateToggle({
    Name = "Sem Recoil",
    CurrentValue = CONFIG.MISC_NO_RECOIL,
    Flag = "NoRecoil",
    Callback = function(value)
        CONFIG.MISC_NO_RECOIL = value
    end,
})

MiscTab:CreateToggle({
    Name = "Sem Spread",
    CurrentValue = CONFIG.MISC_NO_SPREAD,
    Flag = "NoSpread",
    Callback = function(value)
        CONFIG.MISC_NO_SPREAD = value
    end,
})

MiscTab:CreateToggle({
    Name = "Munição Infinita",
    CurrentValue = CONFIG.MISC_INFINITE_AMMO,
    Flag = "InfiniteAmmo",
    Callback = function(value)
        CONFIG.MISC_INFINITE_AMMO = value
    end,
})

MiscTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = CONFIG.MISC_SPEED_HACK,
    Flag = "SpeedHack",
    Callback = function(value)
        CONFIG.MISC_SPEED_HACK = value
        if value and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = humanoid.WalkSpeed * CONFIG.MISC_SPEED_MULTIPLIER
            end
        end
    end,
})

MiscTab:CreateSlider({
    Name = "Multiplicador de Velocidade",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = CONFIG.MISC_SPEED_MULTIPLIER,
    Flag = "SpeedMultiplier",
    Callback = function(value)
        CONFIG.MISC_SPEED_MULTIPLIER = value
    end,
})

MiscTab:CreateToggle({
    Name = "Pulo Aprimorado",
    CurrentValue = CONFIG.MISC_JUMP_POWER,
    Flag = "JumpPower",
    Callback = function(value)
        CONFIG.MISC_JUMP_POWER = value
        if value and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = humanoid.JumpPower * CONFIG.MISC_JUMP_MULTIPLIER
            end
        end
    end,
})

MiscTab:CreateSlider({
    Name = "Multiplicador de Pulo",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = CONFIG.MISC_JUMP_MULTIPLIER,
    Flag = "JumpMultiplier",
    Callback = function(value)
        CONFIG.MISC_JUMP_MULTIPLIER = value
    end,
})

MiscTab:CreateButton({
    Name = "Limpar Tudo",
    Callback = function()
        cleanup()
        Rayfield:Notify({
            Title = "Limpeza",
            Content = "Todos os elementos foram removidos",
            Duration = 3,
        })
    end,
})

MiscTab:CreateButton({
    Name = "Reiniciar Sistemas",
    Callback = function()
        cleanup()
        initializeAllSystems()
        Rayfield:Notify({
            Title = "Reiniciado",
            Content = "Sistemas reiniciados com sucesso",
            Duration = 3,
        })
    end,
})

-- Tab Config
local ConfigTab = Window:CreateTab("Configurações", 4483362458)

ConfigTab:CreateButton({
    Name = "Salvar Configurações",
    Callback = function()
        Rayfield:Notify({
            Title = "Configurações",
            Content = "Configurações salvas com sucesso",
            Duration = 3,
        })
    end,
})

ConfigTab:CreateButton({
    Name = "Carregar Configurações",
    Callback = function()
        Rayfield:Notify({
            Title = "Configurações",
            Content = "Configurações carregadas",
            Duration = 3,
        })
    end,
})

ConfigTab:CreateButton({
    Name = "Configurações Padrão",
    Callback = function()
        CONFIG = {
            AIMBOT_ENABLED = true,
            AIM_FOV = 250,
            AIM_SMOOTHNESS = 0.2,
            AIM_PREDICTION = 0.15,
            AIM_KEY = Enum.UserInputType.MouseButton2,
            AIM_VISIBILITY_CHECK = true,
            AIM_TEAM_CHECK = true,
            AIM_USE_FOV_CIRCLE = true,
            AIM_LOCK_PART = "Head",
            AIM_MAX_DISTANCE = 1000,
            AIM_TRIGGERBOT = false,
            AIM_TRIGGER_DELAY = 0.1,
            
            ESP_ENABLED = true,
            ESP_TEAM_COLOR = Color3.fromRGB(0, 120, 255),
            ESP_ENEMY_COLOR = Color3.fromRGB(255, 0, 0),
            ESP_TRANSPARENCY = 0.55,
            ESP_OUTLINE_TRANSPARENCY = 0,
            ESP_FILL_COLOR = true,
            ESP_SHOW_NAMES = true,
            ESP_SHOW_DISTANCE = true,
            ESP_SHOW_HEALTH = true,
            ESP_SHOW_BOXES = true,
            ESP_SHOW_TRACERS = true,
            ESP_HEALTH_BASED_COLOR = true,
            ESP_TEXT_SIZE = 14,
            ESP_MAX_DISTANCE = 500,
            
            VISUAL_FOV_CIRCLE_COLOR = Color3.fromRGB(255, 255, 255),
            VISUAL_FOV_CIRCLE_TRANSPARENCY = 0.5,
            VISUAL_CROSSHAIR = false,
            VISUAL_CROSSHAIR_COLOR = Color3.fromRGB(255, 0, 0),
            VISUAL_WATERMARK = true,
            
            MISC_AUTO_RESPAWN = false,
            MISC_SPEED_HACK = false,
            MISC_SPEED_MULTIPLIER = 2,
            MISC_JUMP_POWER = false,
            MISC_JUMP_MULTIPLIER = 2,
            MISC_NO_RECOIL = false,
            MISC_NO_SPREAD = false,
            MISC_INFINITE_AMMO = false,
            MISC_FLY_ENABLED = false,
            MISC_FLY_SPEED = 50,
            MISC_NOCLIP = false,
            MISC_FULLBRIGHT = true
        }
        
        cleanup()
        initializeAllSystems()
        updateAllSettings()
        
        Rayfield:Notify({
            Title = "Configurações",
            Content = "Configurações padrão restauradas",
            Duration = 3,
        })
    end,
})

-- INPUT
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == CONFIG.AIM_KEY then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == CONFIG.AIM_KEY then
        aiming = false
        target = nil
    end
end)

-- LOOP PRINCIPAL
local lastNoclipTime = 0
RunService.RenderStepped:Connect(function()
    -- Atualizar círculo FOV
    if fovCircle and CONFIG.AIM_USE_FOV_CIRCLE then
        local mousePos = UserInputService:GetMouseLocation()
        fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
    
    -- Atualizar crosshair
    if CONFIG.VISUAL_CROSSHAIR then
        updateCrosshair()
    end
    
    -- ESP
    if CONFIG.ESP_ENABLED then
        for player, data in pairs(highlights) do
            if data and data.Highlight and player.Character then
                updateESPColor(player)
                if CONFIG.ESP_SHOW_HEALTH or CONFIG.ESP_SHOW_DISTANCE then
                    updateESPLabels(player)
                end
            else
                -- Remover se o jogador não tiver character
                if highlights[player] and highlights[player].Highlight then
                    pcall(function() highlights[player].Highlight:Destroy() end)
                    highlights[player] = nil
                end
            end
        end
    end
    
    -- Noclip (throttled to every 0.1 seconds)
    if CONFIG.MISC_NOCLIP then
        local currentTime = tick()
        if currentTime - lastNoclipTime >= 0.1 then
            noclip()
            lastNoclipTime = currentTime
        end
    end
    
    -- Aimbot
    if CONFIG.AIMBOT_ENABLED and aiming then
        local closest = getClosestEnemy()
        if closest then
            target = closest
            local predictedPosition = predictPosition(closest)
            
            if CONFIG.AIM_SMOOTHNESS > 0 then
                smoothAim(predictedPosition)
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
            end
            
            -- Triggerbot
            if CONFIG.AIM_TRIGGERBOT then
                triggerbot()
            end
        end
    end
end)

-- SETUP PLAYERS
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if CONFIG.ESP_ENABLED then
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player].Highlight:Destroy()
        highlights[player] = nil
    end
    if espLabels[player] then
        espLabels[player].GUI:Destroy()
        espLabels[player] = nil
    end
    if connections[player] then
        connections[player]:Disconnect()
        connections[player] = nil
    end
end)

-- Inicializar
initializeAllSystems()

Rayfield:Notify({
    Title = "Aimbot + ESP Carregado",
    Content = "45 funções ativas | developed by Blitz",
    Duration = 5,
})
