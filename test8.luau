local Rayfield = loadstring(game:HttpGet(
    "https://github.com/UnknownDeveloper-sqd/UnknownSquad-RayField-Lib/raw/refs/heads/main/Rayfield/CustomRayfield.luau"
))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- SETTINGS
local Settings = {
    PlayerESP = false,
    PlayerName = true,
    PlayerHealth = true,
    PlayerDistance = true,
    PlayerItem = true,
    PlayerTextSize = 14,

    NPCESP = false,
    NPCName = true,
    GuardTextSize = 14,
    NPCAim = false,

    SmoothAim = false,
    VisibilityCheck = true,
    AimPart = "Head",
    Smoothness = 5,
    FOV = 150,
    ShowFOV = true,

    FullBright = false,
    FreeCam = false,
    FreeCamSpeed = 50,

    AntiAFK = true,
    OreESP = false
}

-- GUI
local Window = Rayfield:CreateWindow({
    Name = "FustSurv | SomeCheats",
    LoadingTitle = "FustSurv | SomeCheats",
    LoadingSubtitle = "By: UnknownSquad",
    Theme = "Amethyst",
    Width = 460,
    Height = 360,

    -- Сохранение настроек
    ConfigurationSaving = {
        Enabled = true,
        Folder = "SomeCheats",
        FileName = "FustSurv"
    },

    KeySystem = false
})

local PvpTab = Window:CreateTab("PVP")
local PveTab = Window:CreateTab("PVE")
local VisualsTab = Window:CreateTab("Visuals")

-- NPC SCANNER
local NPCList = {}
local NPCScanEnabled = false
local NPCConnection

local function isPlayerCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return true
        end
    end
    return false
end

local function registerNPC(model)
    if not model or not model:IsA("Model") then
        return
    end

    if model.Name ~= "Guard" or isPlayerCharacter(model) then
        return
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health > 0 then
        NPCList[model] = true
    end
end

local function startNPCScan()
    if NPCScanEnabled then
        return
    end

    NPCScanEnabled = true

    task.spawn(function()
        local descendants = Workspace:GetDescendants()

        for i, obj in ipairs(descendants) do
            if not NPCScanEnabled then
                break
            end

            if obj:IsA("Humanoid") then
                registerNPC(obj.Parent)
            end

            if i % 250 == 0 then
                task.wait()
            end
        end
    end)

    NPCConnection = Workspace.DescendantAdded:Connect(function(obj)
        if NPCScanEnabled and obj:IsA("Humanoid") then
            registerNPC(obj.Parent)
        end
    end)
end

local function stopNPCScan()
    if Settings.NPCESP or Settings.NPCAim then
        return
    end

    NPCScanEnabled = false

    if NPCConnection then
        NPCConnection:Disconnect()
        NPCConnection = nil
    end
end

-- PVP SETTINGS
PvpTab:CreateToggle({
    Name = "SmoothAim",
    CurrentValue = false,
    Callback = function(value)
        Settings.SmoothAim = value
    end
})

PvpTab:CreateToggle({
    Name = "Aim NPC",
    CurrentValue = false,
    Callback = function(value)
        Settings.NPCAim = value

        if value then
            startNPCScan()
        else
            stopNPCScan()
        end
    end
})

PvpTab:CreateToggle({
    Name = "Visibility Check",
    CurrentValue = true,
    Callback = function(value)
        Settings.VisibilityCheck = value
    end
})

PvpTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Torso", "Legs"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Callback = function(value)
        Settings.AimPart = typeof(value) == "table" and value[1] or value
    end
})

PvpTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        Settings.Smoothness = value
    end
})

PvpTab:CreateSlider({
    Name = "FOV",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(value)
        Settings.FOV = value
    end
})

PvpTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
    Callback = function(value)
        Settings.ShowFOV = value
    end
})

-- PVE: ANTI-AFK
local AntiAFKConnection

local function setAntiAFK(value)
    Settings.AntiAFK = value

    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end

    if value then
        AntiAFKConnection = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end
end

PveTab:CreateSection("Anti-AFK")

PveTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = setAntiAFK
})

setAntiAFK(true)

-- VISUALS: PLAYER ESP
VisualsTab:CreateSection("Player ESP")

VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(value)
        Settings.PlayerESP = value
    end
})

VisualsTab:CreateToggle({
    Name = "Player Name",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerName = value
    end
})

VisualsTab:CreateToggle({
    Name = "Player Health",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerHealth = value
    end
})

VisualsTab:CreateToggle({
    Name = "Player Distance",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerDistance = value
    end
})

VisualsTab:CreateToggle({
    Name = "Player Item",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerItem = value
    end
})

VisualsTab:CreateSlider({
    Name = "Player Text Size",
    Range = {10, 24},
    Increment = 1,
    CurrentValue = 14,
    Callback = function(value)
        Settings.PlayerTextSize = value
    end
})

-- VISUALS: NPC ESP
VisualsTab:CreateDivider()
VisualsTab:CreateSection("NPC ESP")

VisualsTab:CreateToggle({
    Name = "NPC ESP (Guard)",
    CurrentValue = false,
    Callback = function(value)
        Settings.NPCESP = value

        if value then
            startNPCScan()
        end
    end
})

VisualsTab:CreateToggle({
    Name = "Guard Name",
    CurrentValue = true,
    Callback = function(value)
        Settings.NPCName = value
    end
})

VisualsTab:CreateSlider({
    Name = "Guard Text Size",
    Range = {10, 24},
    Increment = 1,
    CurrentValue = 14,
    Callback = function(value)
        Settings.GuardTextSize = value
    end
})

-- LIGHTING / FULLBRIGHT
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ExposureCompensation = Lighting.ExposureCompensation
}

local function applyFullBright()
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.ExposureCompensation = 0.5
end

local function restoreLighting()
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.ClockTime = OriginalLighting.ClockTime
    Lighting.FogEnd = OriginalLighting.FogEnd
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    Lighting.Ambient = OriginalLighting.Ambient
    Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    Lighting.ExposureCompensation = OriginalLighting.ExposureCompensation
end

local function setFullBright(value)
    Settings.FullBright = value

    if value then
        applyFullBright()
    else
        restoreLighting()
    end
end

VisualsTab:CreateDivider()
VisualsTab:CreateSection("Lighting")

VisualsTab:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Callback = setFullBright
})

-- FREECAM
local FreeCamEnabled = false
local FreeCamPosition
local FreeCamYaw = 0
local FreeCamPitch = 0
local FreeCamOldType
local FreeCamOldSubject
local FreeCamOldMouseBehavior
local FreeCamOldMouseIcon
local FreeCamKey = Enum.KeyCode.F
local WaitingForFreeCamKey = false

local function setFreeCam(value)
    if value == FreeCamEnabled then
        return
    end

    FreeCamEnabled = value
    Settings.FreeCam = value

    if value then
        FreeCamPosition = Camera.CFrame.Position

        local look = Camera.CFrame.LookVector
        FreeCamYaw = math.atan2(-look.X, -look.Z)
        FreeCamPitch = math.asin(math.clamp(look.Y, -1, 1))

        FreeCamOldType = Camera.CameraType
        FreeCamOldSubject = Camera.CameraSubject
        FreeCamOldMouseBehavior = UserInputService.MouseBehavior
        FreeCamOldMouseIcon = UserInputService.MouseIconEnabled

        Camera.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
    else
        Camera.CameraType = FreeCamOldType or Enum.CameraType.Custom

        if FreeCamOldSubject then
            Camera.CameraSubject = FreeCamOldSubject
        end

        UserInputService.MouseBehavior =
            FreeCamOldMouseBehavior or Enum.MouseBehavior.Default

        if FreeCamOldMouseIcon ~= nil then
            UserInputService.MouseIconEnabled = FreeCamOldMouseIcon
        end

        FreeCamPosition = nil
    end
end

-- Назначение клавиши FreeCam
UserInputService.InputBegan:Connect(function(input, processed)
    if WaitingForFreeCamKey then
        if input.UserInputType == Enum.UserInputType.Keyboard
            and input.KeyCode ~= Enum.KeyCode.Unknown then

            FreeCamKey = input.KeyCode
            WaitingForFreeCamKey = false
        end
        return
    end

    if processed then
        return
    end

    if input.KeyCode == FreeCamKey then
        setFreeCam(not FreeCamEnabled)
    end
end)

RunService:BindToRenderStep(
    "SomeCheatsFreeCam",
    Enum.RenderPriority.Camera.Value + 1,
    function(deltaTime)
        if not FreeCamEnabled or not Camera then
            return
        end

        -- Получаем движение мыши каждый кадр
        local mouseDelta = UserInputService:GetMouseDelta()

        FreeCamYaw = FreeCamYaw - mouseDelta.X * 0.003
        FreeCamPitch = math.clamp(
            FreeCamPitch - mouseDelta.Y * 0.003,
            math.rad(-85),
            math.rad(85)
        )

        local rotation =
            CFrame.Angles(0, FreeCamYaw, 0)
            * CFrame.Angles(FreeCamPitch, 0, 0)

        local movement = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            movement += Vector3.new(0, 0, -1)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            movement += Vector3.new(0, 0, 1)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            movement += Vector3.new(-1, 0, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            movement += Vector3.new(1, 0, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            movement += Vector3.new(0, 1, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            movement += Vector3.new(0, -1, 0)
        end

        local speed = Settings.FreeCamSpeed

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            speed *= 2
        end

        if movement.Magnitude > 0 then
            FreeCamPosition +=
                rotation:VectorToWorldSpace(movement.Unit)
                * speed * deltaTime
        end

        Camera.CFrame = CFrame.new(FreeCamPosition) * rotation
    end
)

VisualsTab:CreateDivider()
VisualsTab:CreateSection("FreeCam")

VisualsTab:CreateToggle({
    Name = "FreeCam",
    CurrentValue = false,
    Callback = setFreeCam
})

VisualsTab:CreateSlider({
    Name = "FreeCam Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(value)
        Settings.FreeCamSpeed = value
    end
})

VisualsTab:CreateButton({
    Name = "Assign FreeCam Key",
    Callback = function()
        WaitingForFreeCamKey = true
    end
})

VisualsTab:CreateButton({
    Name = "Reset Camera",
    Callback = function()
        if FreeCamEnabled then
            setFreeCam(false)
        end

        local character = LocalPlayer.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            Camera.CameraSubject = humanoid
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
})

-- FOV CIRCLE
local FOVCircle

pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 60
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(180, 100, 255)
        FOVCircle.Transparency = 1
    end
end)

-- AIM
local RightMouseDown = false
local CachedTarget = nil
local LastAimUpdate = 0
local AIM_UPDATE_INTERVAL = 0.05

local RaycastParamsCache = RaycastParams.new()
RaycastParamsCache.FilterType = Enum.RaycastFilterType.Exclude
RaycastParamsCache.IgnoreWater = true

local function getAimPart(character)
    if not character then
        return nil
    end

    if Settings.AimPart == "Head" then
        return character:FindFirstChild("Head")
    elseif Settings.AimPart == "Torso" then
        return character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("HumanoidRootPart")
    elseif Settings.AimPart == "Legs" then
        return character:FindFirstChild("LeftLowerLeg")
            or character:FindFirstChild("Left Leg")
            or character:FindFirstChild("RightLowerLeg")
            or character:FindFirstChild("Right Leg")
    end

    return character:FindFirstChild("Head")
end

local function isVisible(character, targetPosition)
    if not Settings.VisibilityCheck then
        return true
    end

    local origin = Camera.CFrame.Position
    local direction = targetPosition - origin

    RaycastParamsCache.FilterDescendantsInstances = {
        LocalPlayer.Character
    }

    local result = Workspace:Raycast(
        origin,
        direction,
        RaycastParamsCache
    )

    return result == nil
        or result.Instance:IsDescendantOf(character)
end

local function checkTarget(character, shortestDistance, center)
    if not character then
        return nil, shortestDistance
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        return nil, shortestDistance
    end

    local targetPart = getAimPart(character)

    if not targetPart then
        return nil, shortestDistance
    end

    local screenPosition, onScreen =
        Camera:WorldToViewportPoint(targetPart.Position)

    if not onScreen or screenPosition.Z <= 0 then
        return nil, shortestDistance
    end

    local screenPoint = Vector2.new(
        screenPosition.X,
        screenPosition.Y
    )

    local distance = (screenPoint - center).Magnitude

    if distance < shortestDistance
        and isVisible(character, targetPart.Position) then

        return targetPart, distance
    end

    return nil, shortestDistance
end

local function getClosestTarget()
    if not Camera then
        return nil
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    local closestTarget = nil
    local shortestDistance = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local target, distance = checkTarget(
                player.Character,
                shortestDistance,
                center
            )

            if target then
                closestTarget = target
                shortestDistance = distance
            end
        end
    end

    if Settings.NPCAim then
        for model in pairs(NPCList) do
            if model and model.Name == "Guard"
                and model.Parent and not isPlayerCharacter(model) then

                local target, distance = checkTarget(
                    model,
                    shortestDistance,
                    center
                )

                if target then
                    closestTarget = target
                    shortestDistance = distance
                end
            else
                NPCList[model] = nil
            end
        end
    end

    return closestTarget
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = false
        CachedTarget = nil
    end
end)

-- ESP FOLDER
local GuiParent

pcall(function()
    if gethui then
        GuiParent = gethui()
    end
end)

if not GuiParent then
    GuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = GuiParent

local HighlightCache = {}
local PlayerNameCache = {}
local PlayerStatsCache = {}
local PlayerItemCache = {}

local NPCHighlightCache = {}
local NPCInfoCache = {}

local OreCache = {}

local function createHighlight(color)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ESPFolder
    return highlight
end

local function createInfoGui(name, size, offset)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = name
    billboard.Size = size
    billboard.StudsOffset = offset or Vector3.zero
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextSize = 10
    label.Font = Enum.Font.Code
    label.TextWrapped = true
    label.Parent = billboard

    return billboard
end

local function removeESP(player)
    for _, cache in ipairs({
        HighlightCache,
        PlayerNameCache,
        PlayerStatsCache,
        PlayerItemCache
    }) do
        if cache[player] then
            cache[player]:Destroy()
            cache[player] = nil
        end
    end
end

local function removeNPCESP(model)
    if NPCHighlightCache[model] then
        NPCHighlightCache[model]:Destroy()
        NPCHighlightCache[model] = nil
    end

    if NPCInfoCache[model] then
        NPCInfoCache[model]:Destroy()
        NPCInfoCache[model] = nil
    end
end

local function clearNPCESP()
    for model in pairs(NPCHighlightCache) do
        removeNPCESP(model)
    end

    for model in pairs(NPCInfoCache) do
        removeNPCESP(model)
    end
end

-- PLAYER ESP: NAME ABOVE HEAD, STATS TO THE RIGHT
local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end

        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        local head = character and character:FindFirstChild("Head")
        local root = character
            and (character:FindFirstChild("HumanoidRootPart") or head)

        if not Settings.PlayerESP then
            if HighlightCache[player] then
                HighlightCache[player].Enabled = false
            end

            for _, cache in ipairs({
                PlayerNameCache,
                PlayerStatsCache,
                PlayerItemCache
            }) do
                if cache[player] then
                    cache[player].Enabled = false
                end
            end

            continue
        end

        if not character or not humanoid or humanoid.Health <= 0
            or not root or not head then

            if HighlightCache[player] then
                HighlightCache[player].Adornee = nil
            end

            for _, cache in ipairs({
                PlayerNameCache,
                PlayerStatsCache,
                PlayerItemCache
            }) do
                if cache[player] then
                    cache[player].Adornee = nil
                    cache[player].Enabled = false
                end
            end

            continue
        end

        local highlight = HighlightCache[player]

        if not highlight then
            highlight = createHighlight(Color3.fromRGB(255, 255, 255))
            HighlightCache[player] = highlight
        end

        highlight.Adornee = character
        highlight.Enabled = true

        -- NAME: above head
        local nameBillboard = PlayerNameCache[player]

        if not nameBillboard then
            nameBillboard = createInfoGui(
                "PlayerName",
                UDim2.fromOffset(180, 24),
                Vector3.new(0, 2.1, 0)
            )
            PlayerNameCache[player] = nameBillboard
        end

        nameBillboard.Adornee = head
        nameBillboard.Enabled = Settings.PlayerName

        local nameLabel = nameBillboard:FindFirstChild("Info")

        if nameLabel then
            nameLabel.Text = player.Name
            nameLabel.TextSize = Settings.PlayerTextSize
        end

        -- HEALTH + DISTANCE: right beside head, two rows
        local statsBillboard = PlayerStatsCache[player]

        if not statsBillboard then
            statsBillboard = createInfoGui(
                "PlayerStats",
                UDim2.fromOffset(90, 42),
                Vector3.zero
            )
            PlayerStatsCache[player] = statsBillboard
        end

        statsBillboard.Adornee = head

        -- Offset in camera-right direction, so it stays on the right side
        if Camera then
            statsBillboard.StudsOffsetWorldSpace =
                Camera.CFrame.RightVector * 1.35
        end

        local stats = {}

        if Settings.PlayerHealth then
            local healthPercent = 0

            if humanoid.MaxHealth > 0 then
                healthPercent = math.floor(
                    (humanoid.Health / humanoid.MaxHealth) * 100
                )
            end

            table.insert(stats, tostring(healthPercent) .. "%")
        end

        if Settings.PlayerDistance then
            local localCharacter = LocalPlayer.Character
            local localRoot = localCharacter
                and localCharacter:FindFirstChild("HumanoidRootPart")

            if localRoot then
                local distance =
                    (localRoot.Position - root.Position).Magnitude

                table.insert(stats, tostring(math.floor(distance)) .. " m")
            end
        end

        local statsLabel = statsBillboard:FindFirstChild("Info")

        if statsLabel then
            statsLabel.Text = table.concat(stats, "\n")
            statsLabel.TextSize = Settings.PlayerTextSize
        end

        statsBillboard.Enabled = #stats > 0

        -- ITEM: separate billboard, fixed size (not affected by slider)
        local itemBillboard = PlayerItemCache[player]

        if not itemBillboard then
            itemBillboard = createInfoGui(
                "PlayerItem",
                UDim2.fromOffset(160, 20),
                Vector3.new(0, -3, 0)
            )
            PlayerItemCache[player] = itemBillboard
        end

        itemBillboard.Adornee = root

        local tool = character:FindFirstChildOfClass("Tool")
        local itemLabel = itemBillboard:FindFirstChild("Info")

        if itemLabel then
            itemLabel.Text = tool and tool.Name or ""
            itemLabel.TextSize = 10
        end

        itemBillboard.Enabled = Settings.PlayerItem and tool ~= nil
    end
end

-- NPC ESP
local function updateNPCESP()
    if not Settings.NPCESP then
        clearNPCESP()
        stopNPCScan()
        return
    end

    for model in pairs(NPCList) do
        if not model or not model.Parent then
            removeNPCESP(model)
            NPCList[model] = nil
            continue
        end

        if model.Name ~= "Guard" then
            removeNPCESP(model)
            NPCList[model] = nil
            continue
        end

        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("Head")

        if not humanoid or humanoid.Health <= 0 or not root then
            removeNPCESP(model)
            continue
        end

        local highlight = NPCHighlightCache[model]

        if not highlight then
            highlight = createHighlight(Color3.fromRGB(255, 140, 50))
            NPCHighlightCache[model] = highlight
        end

        highlight.Adornee = model
        highlight.Enabled = true

        local billboard = NPCInfoCache[model]

        if not billboard then
            billboard = createInfoGui(
                "NPCInfo",
                UDim2.fromOffset(160, 48),
                Vector3.new(0, -3, 0)
            )
            NPCInfoCache[model] = billboard
        end

        billboard.Adornee = root

        local label = billboard:FindFirstChild("Info")

        if label then
            label.Text = Settings.NPCName and "Guard" or ""
            label.TextSize = Settings.GuardTextSize
        end

        billboard.Enabled = Settings.NPCName
    end
end

-- ORE ESP
local OreDefinitions = {
    {
        FullName = "Металлическая руда",
        Label = "Металл",
        Color = Color3.fromRGB(190, 150, 105)
    },
    {
        FullName = "Сефировая руда",
        Label = "Сера",
        Color = Color3.fromRGB(255, 220, 40)
    },
    {
        FullName = "Камень",
        Label = "Камень",
        Color = Color3.fromRGB(145, 145, 145)
    }
}

local function getOreDefinition(obj)
    if not obj then
        return nil
    end

    local objectName = string.lower(obj.Name)

    for _, definition in ipairs(OreDefinitions) do
        if objectName == string.lower(definition.FullName) then
            return definition
        end
    end

    return nil
end

local function getOreAdornee(obj)
    if obj:IsA("Model") then
        return obj
    end

    if obj:IsA("BasePart") then
        return obj
    end

    return nil
end

local function removeOreESP(obj)
    local data = OreCache[obj]

    if data then
        if data.Highlight then
            data.Highlight:Destroy()
        end

        if data.Billboard then
            data.Billboard:Destroy()
        end

        OreCache[obj] = nil
    end
end

local function addOreESP(obj)
    if not Settings.OreESP or OreCache[obj] then
        return
    end

    local definition = getOreDefinition(obj)
    local adornee = getOreAdornee(obj)

    if not definition or not adornee then
        return
    end

    -- Не создаём дубликаты на деталях внутри уже найденной модели
    if obj:IsA("BasePart") then
        local parentModel = obj:FindFirstAncestorOfClass("Model")

        if parentModel and getOreDefinition(parentModel) then
            return
        end
    end

    local highlight = createHighlight(definition.Color)
    highlight.Adornee = adornee
    highlight.Enabled = true

    local billboard = createInfoGui(
        "OreInfo",
        UDim2.fromOffset(140, 24),
        Vector3.new(0, 2, 0)
    )

    billboard.Adornee = adornee
    billboard.Enabled = true

    local label = billboard:FindFirstChild("Info")

    if label then
        label.Text = definition.Label
        label.TextSize = 14
    end

    OreCache[obj] = {
        Highlight = highlight,
        Billboard = billboard
    }
end

local function scanOres()
    if not Settings.OreESP then
        return
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            addOreESP(obj)
        end
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if Settings.OreESP then
        task.defer(function()
            if obj.Parent then
                addOreESP(obj)
            end
        end)
    end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    removeOreESP(obj)

    if obj:IsA("Model") and NPCList[obj] then
        removeNPCESP(obj)
        NPCList[obj] = nil
    end
end)

PveTab:CreateDivider()
PveTab:CreateSection("Ore ESP")

PveTab:CreateToggle({
    Name = "Ore ESP",
    CurrentValue = false,
    Callback = function(value)
        Settings.OreESP = value

        if value then
            task.spawn(scanOres)
        else
            for obj in pairs(OreCache) do
                removeOreESP(obj)
            end
        end
    end
})

-- PLAYER CLEANUP
Players.PlayerRemoving:Connect(removeESP)

-- MAIN LOOP
local ESP_UPDATE_INTERVAL = 0.35
local lastESPUpdate = 0
local lastFullBrightUpdate = 0

RunService.RenderStepped:Connect(function()
    if not Camera then
        return
    end

    -- Keep FullBright active while enabled
    if Settings.FullBright then
        local now = os.clock()

        if now - lastFullBrightUpdate >= 0.5 then
            lastFullBrightUpdate = now
            pcall(applyFullBright)
        end
    end

    -- FOV
    if FOVCircle then
        local viewport = Camera.ViewportSize

        FOVCircle.Position = Vector2.new(
            viewport.X / 2,
            viewport.Y / 2
        )

        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.ShowFOV
            and Settings.SmoothAim
    end

    -- SMOOTH AIM
    if Settings.SmoothAim and RightMouseDown then
        local now = os.clock()

        if now - LastAimUpdate >= AIM_UPDATE_INTERVAL then
            LastAimUpdate = now
            CachedTarget = getClosestTarget()
        end

        local target = CachedTarget

        if target and target.Parent then
            local smoothness = math.clamp(Settings.Smoothness, 1, 10)
            local alpha = 1 / smoothness

            local targetCFrame = CFrame.lookAt(
                Camera.CFrame.Position,
                target.Position
            )

            Camera.CFrame = Camera.CFrame:Lerp(
                targetCFrame,
                alpha
            )
        else
            CachedTarget = nil
        end
    else
        CachedTarget = nil
    end

    -- ESP UPDATE
    local now = os.clock()

    if now - lastESPUpdate >= ESP_UPDATE_INTERVAL then
        lastESPUpdate = now

        updatePlayerESP()
        updateNPCESP()
    end
end)

-- MOBILE UI
if UserInputService.TouchEnabled then
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "MobileToggleGui"
    toggleGui.ResetOnSpawn = false
    toggleGui.Parent = GuiParent

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleUI"
    toggleBtn.Size = UDim2.fromOffset(45, 45)
    toggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "UI"
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.Code
    toggleBtn.Parent = toggleGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toggleBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 90, 220)
    stroke.Thickness = 1.5
    stroke.Parent = toggleBtn

    toggleBtn.Activated:Connect(function()
        for _, gui in ipairs(GuiParent:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= toggleGui then
                gui.Enabled = not gui.Enabled
            end
        end
    end)
end
