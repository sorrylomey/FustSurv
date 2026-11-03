
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

    AntiAFK = false,
    ChestESP = false,
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
    Font = "Code",

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

local NPCHighlightCache = {}
local NPCInfoCache = {}

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

    if model.Name ~= "Guard" then
        return
    end

    if isPlayerCharacter(model) then
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
                local model = obj.Parent

                if model and model:IsA("Model") then
                    registerNPC(model)
                end
            end

            if i % 250 == 0 then
                task.wait()
            end
        end

        descendants = nil
    end)

    NPCConnection = Workspace.DescendantAdded:Connect(function(obj)
        if not NPCScanEnabled then
            return
        end

        if obj:IsA("Humanoid") then
            local model = obj.Parent

            if model and model:IsA("Model") then
                registerNPC(model)
            end
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
        else
            for model in pairs(NPCHighlightCache) do
                if NPCHighlightCache[model] then
                    NPCHighlightCache[model]:Destroy()
                    NPCHighlightCache[model] = nil
                end
            end

            for model in pairs(NPCInfoCache) do
                if NPCInfoCache[model] then
                    NPCInfoCache[model]:Destroy()
                    NPCInfoCache[model] = nil
                end
            end

            stopNPCScan()
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

-- FULLBRIGHT
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

    pcall(function()
        Lighting.ExposureCompensation = 0.5
    end)
end

local function setFullBright(value)
    Settings.FullBright = value

    if value then
        applyFullBright()
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient

        pcall(function()
            Lighting.ExposureCompensation =
                OriginalLighting.ExposureCompensation
        end)
    end
end

RunService.Heartbeat:Connect(function()
    if Settings.FullBright then
        pcall(applyFullBright)
    end
end)

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

local SavedCharacterState = nil
local CharacterAddedConnection = nil

local function freezeCharacter(character)
    character = character or LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid", 10)

    local root = character:FindFirstChild("HumanoidRootPart")
        or character:WaitForChild("HumanoidRootPart", 10)

    if not FreeCamEnabled
        or LocalPlayer.Character ~= character
        or not humanoid
        or not root then
        return
    end

    if SavedCharacterState
        and SavedCharacterState.Character == character then
        return
    end

    SavedCharacterState = {
        Character = character,
        Humanoid = humanoid,
        Root = root,
        WalkSpeed = humanoid.WalkSpeed,
        JumpPower = humanoid.JumpPower,
        JumpHeight = humanoid.JumpHeight,
        AutoRotate = humanoid.AutoRotate,
        Anchored = root.Anchored
    }

    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0
    humanoid.AutoRotate = false
    humanoid:Move(Vector3.zero)

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.Anchored = true
end

local function restoreCharacterFreeze()
    local saved = SavedCharacterState
    if not saved then return end

    local humanoid = saved.Humanoid
    local root = saved.Root

    if root and root.Parent then
        root.Anchored = saved.Anchored
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = saved.WalkSpeed
        humanoid.JumpPower = saved.JumpPower
        humanoid.JumpHeight = saved.JumpHeight
        humanoid.AutoRotate = saved.AutoRotate
    end

    SavedCharacterState = nil
end

local function setFreeCam(value)
    if value == FreeCamEnabled then
        return
    end

    Camera = Workspace.CurrentCamera

    if not Camera then
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

        task.spawn(freezeCharacter, LocalPlayer.Character)

        if CharacterAddedConnection then
            CharacterAddedConnection:Disconnect()
        end

        CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
            if FreeCamEnabled then
                task.spawn(freezeCharacter, character)
            end
        end)

    else
        if CharacterAddedConnection then
            CharacterAddedConnection:Disconnect()
            CharacterAddedConnection = nil
        end

        restoreCharacterFreeze()

        Camera.CameraType = FreeCamOldType or Enum.CameraType.Custom

        local currentCharacter = LocalPlayer.Character
        local currentHumanoid = currentCharacter
            and currentCharacter:FindFirstChildOfClass("Humanoid")

        if FreeCamOldSubject and FreeCamOldSubject.Parent then
            Camera.CameraSubject = FreeCamOldSubject
        elseif currentHumanoid then
            Camera.CameraSubject = currentHumanoid
        end

        UserInputService.MouseBehavior =
            FreeCamOldMouseBehavior or Enum.MouseBehavior.Default

        UserInputService.MouseIconEnabled =
            FreeCamOldMouseIcon ~= nil and FreeCamOldMouseIcon or true

        FreeCamPosition = nil
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if WaitingForFreeCamKey then
        if input.UserInputType == Enum.UserInputType.Keyboard
            and input.KeyCode ~= Enum.KeyCode.Unknown then

            FreeCamKey = input.KeyCode
            WaitingForFreeCamKey = false

            pcall(function()
                Rayfield:Notify({
                    Title = "FreeCam",
                    Content = "Клавиша назначена: " .. FreeCamKey.Name,
                    Duration = 3
                })
            end)
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
        if not FreeCamEnabled then
            return
        end

        Camera = Workspace.CurrentCamera

        if not Camera then
            return
        end

        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

        local mouseDelta = UserInputService:GetMouseDelta()

        FreeCamYaw = FreeCamYaw - mouseDelta.X * 0.003
        FreeCamPitch = math.clamp(
            FreeCamPitch - mouseDelta.Y * 0.003,
            math.rad(-85),
            math.rad(85)
        )

        local rotation = CFrame.Angles(0, FreeCamYaw, 0)
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
            FreeCamPosition += rotation:VectorToWorldSpace(movement.Unit)
                * speed * deltaTime
        end

        Camera.CameraType = Enum.CameraType.Scriptable
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
    Name = "Set FreeCam Key",
    Callback = function()
        WaitingForFreeCamKey = true

        pcall(function()
            Rayfield:Notify({
                Title = "FreeCam",
                Content = "Нажми новую клавишу",
                Duration = 5
            })
        end)
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

        if humanoid and Camera then
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
            if model
                and model.Name == "Guard"
                and model.Parent
                and not isPlayerCharacter(model) then

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

-- ESP
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
local InfoCache = {}

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

local function createInfoGui(name, offset)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = name
    billboard.Size = UDim2.fromOffset(160, 48)
    billboard.StudsOffset = Vector3.new(0, offset, 0)
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
    if HighlightCache[player] then
        HighlightCache[player]:Destroy()
        HighlightCache[player] = nil
    end

    if InfoCache[player] then
        InfoCache[player]:Destroy()
        InfoCache[player] = nil
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

-- ORE ESP
local OreSettings = {
    Enabled = false,
    Sulfur = true,
    Metal = true,
    Stone = true,
    ShowName = true,
    MaxDistance = 300
}

local OreCache = {}

local OreDefinitions = {
    {
        key = "Sulfur",
        names = {
            ["SulfurOrePile"] = true,
            ["SulfurNode"] = true
        },
        label = "Сера",
        color = Color3.fromRGB(255, 220, 0)
    },
    {
        key = "Metal",
        names = {
            ["MetalOrePile"] = true,
            ["MetalNode"] = true
        },
        label = "Металл",
        color = Color3.fromRGB(194, 145, 95)
    },
    {
        key = "Stone",
        names = {
            ["StoneNode"] = true
        },
        label = "Камень",
        color = Color3.fromRGB(155, 155, 155)
    }
}

local function getOreDefinition(object)
    if not object then
        return nil
    end

    for _, definition in ipairs(OreDefinitions) do
        if definition.names[object.Name] then
            return definition
        end
    end

    return nil
end

local function isOreTypeEnabled(definition)
    if not definition then
        return false
    end

    return OreSettings.Enabled and OreSettings[definition.key]
end

local function getOreAdornee(object)
    if object:IsA("Model") then
        return object.PrimaryPart
            or object:FindFirstChildWhichIsA("BasePart", true)
    end

    if object:IsA("BasePart") then
        return object
    end

    return nil
end

local function getOreObject(object)
    if not object then
        return nil
    end

    local parentModel = object:FindFirstAncestorOfClass("Model")

    if parentModel and getOreDefinition(parentModel) then
        return parentModel
    end

    if (object:IsA("Model") or object:IsA("BasePart"))
        and getOreDefinition(object) then
        return object
    end

    return nil
end

local function removeOreESP(object)
    local entry = OreCache[object]

    if not entry then
        return
    end

    if entry.Highlight then
        entry.Highlight:Destroy()
    end

    if entry.Billboard then
        entry.Billboard:Destroy()
    end

    OreCache[object] = nil
end

local function registerOre(object)
    if not OreSettings.Enabled then
        return
    end

    object = getOreObject(object)

    if not object or OreCache[object] then
        return
    end

    local definition = getOreDefinition(object)

    if not isOreTypeEnabled(definition) then
        return
    end

    local adornee = getOreAdornee(object)

    if not adornee then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "OreHighlight"
    highlight.Adornee = object
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = definition.color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ESPFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "OreInfo"
    billboard.Size = UDim2.fromOffset(150, 28)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = adornee
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = definition.label
    label.TextColor3 = definition.color
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.Code
    label.Parent = billboard

    OreCache[object] = {
        Highlight = highlight,
        Billboard = billboard,
        Definition = definition
    }
end

local function clearOreESP()
    for object in pairs(OreCache) do
        removeOreESP(object)
    end
end

local function scanOres()
    if not OreSettings.Enabled then
        return
    end

    for _, object in ipairs(Workspace:GetDescendants()) do
        registerOre(object)
    end
end

local function refreshOreESP()
    clearOreESP()

    if OreSettings.Enabled then
        scanOres()
    end
end

Workspace.DescendantAdded:Connect(function(object)
    if OreSettings.Enabled then
        task.defer(function()
            registerOre(object)
        end)
    end
end)

Workspace.DescendantRemoving:Connect(function(object)
    if OreCache[object] then
        removeOreESP(object)
    end
end)

RunService.Heartbeat:Connect(function()
    if not OreSettings.Enabled then
        return
    end

    local character = LocalPlayer.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    for object, entry in pairs(OreCache) do
        if not object.Parent then
            removeOreESP(object)
            continue
        end

        local adornee = getOreAdornee(object)

        if not adornee then
            removeOreESP(object)
            continue
        end

        local distance = (root.Position - adornee.Position).Magnitude
        local visible = distance <= OreSettings.MaxDistance

        entry.Highlight.Enabled = visible

        if entry.Billboard then
            entry.Billboard.Enabled =
                visible and OreSettings.ShowName
        end
    end
end)

-- CHEST ESP
local ChestSettings = {
    Enabled = false,
    ShelfBox = true,
    Supply = true,
    CrateSpawn = true,
    EliteCrate = true,
    ShowName = true,
    MaxDistance = 1000
}

local ChestCache = {}

local ChestDefinitions = {
    ShelfBox = {
        Color = Color3.fromRGB(255, 220, 80)
    },
    Supply = {
        Color = Color3.fromRGB(80, 200, 255)
    },
    CrateSpawn = {
        Color = Color3.fromRGB(100, 255, 120)
    },
    EliteCrate = {
        Color = Color3.fromRGB(255, 80, 80)
    }
}

local function getChestObject(object)
    local current = object

    while current and current ~= Workspace do
        if ChestDefinitions[current.Name]
            and (current:IsA("Model") or current:IsA("BasePart")) then
            return current
        end

        current = current.Parent
    end

    return nil
end

local function getChestPart(object)
    if object:IsA("BasePart") then
        return object
    end

    if object:IsA("Model") then
        return object.PrimaryPart
            or object:FindFirstChildWhichIsA("BasePart", true)
    end

    return nil
end

local function removeChestESP(object)
    local data = ChestCache[object]
    if not data then return end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    ChestCache[object] = nil
end

local function clearChestESP()
    for object in pairs(ChestCache) do
        removeChestESP(object)
    end
end

local function registerChest(object)
    if not ChestSettings.Enabled then return end
    if not object or not object.Parent then return end
    if ChestCache[object] then return end

    local definition = ChestDefinitions[object.Name]
    if not definition or not ChestSettings[object.Name] then return end

    local part = getChestPart(object)
    if not part then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ChestHighlight"
    highlight.Adornee = object
    highlight.FillColor = definition.Color
    highlight.OutlineColor = definition.Color
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ESPFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ChestName"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = ChestSettings.ShowName
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = object.Name
    label.TextColor3 = definition.Color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    ChestCache[object] = {
        Highlight = highlight,
        Billboard = billboard,
        Part = part
    }
end

local function refreshChestESP()
    clearChestESP()

    if not ChestSettings.Enabled then
        return
    end

    for _, object in ipairs(Workspace:GetDescendants()) do
        if ChestDefinitions[object.Name]
            and (object:IsA("Model") or object:IsA("BasePart"))
            and ChestSettings[object.Name] then
            registerChest(object)
        end
    end
end

Workspace.DescendantAdded:Connect(function(object)
    if not ChestSettings.Enabled then return end

    task.defer(function()
        local chest = getChestObject(object)

        if chest and ChestSettings[chest.Name] then
            registerChest(chest)
        end
    end)
end)

Workspace.DescendantRemoving:Connect(function(object)
    if ChestCache[object] then
        removeChestESP(object)
    end
end)

RunService.Heartbeat:Connect(function()
    if not ChestSettings.Enabled then return end

    local character = LocalPlayer.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    for object, data in pairs(ChestCache) do
        if not object.Parent or not data.Part or not data.Part.Parent then
            removeChestESP(object)
        else
            local distance = (root.Position - data.Part.Position).Magnitude
            local visible = distance <= ChestSettings.MaxDistance

            if data.Highlight then
                data.Highlight.Enabled = visible
            end

            if data.Billboard then
                data.Billboard.Enabled =
                    visible and ChestSettings.ShowName
            end
        end
    end
end)

-- PVE SETTINGS
PveTab:CreateSection("Ore ESP")

PveTab:CreateToggle({
    Name = "Ore ESP",
    CurrentValue = false,
    Callback = function(value)
        OreSettings.Enabled = value
        Settings.OreESP = value
        refreshOreESP()
    end
})

PveTab:CreateToggle({
    Name = "Sulfur",
    CurrentValue = true,
    Callback = function(value)
        OreSettings.Sulfur = value
        refreshOreESP()
    end
})

PveTab:CreateToggle({
    Name = "Metal",
    CurrentValue = true,
    Callback = function(value)
        OreSettings.Metal = value
        refreshOreESP()
    end
})

PveTab:CreateToggle({
    Name = "Stone",
    CurrentValue = true,
    Callback = function(value)
        OreSettings.Stone = value
        refreshOreESP()
    end
})

PveTab:CreateToggle({
    Name = "Ore Name",
    CurrentValue = true,
    Callback = function(value)
        OreSettings.ShowName = value
    end
})

PveTab:CreateSlider({
    Name = "Ore Distance",
    Range = {25, 1000},
    Increment = 25,
    CurrentValue = 300,
    Callback = function(value)
        OreSettings.MaxDistance = value
    end
})

-- CHEST ESP UI
PveTab:CreateDivider()
PveTab:CreateSection("Chest ESP")

PveTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Callback = function(value)
        ChestSettings.Enabled = value
        Settings.ChestESP = value
        refreshChestESP()
    end
})

PveTab:CreateToggle({
    Name = "ShelfBox",
    CurrentValue = true,
    Callback = function(value)
        ChestSettings.ShelfBox = value
        refreshChestESP()
    end
})

PveTab:CreateToggle({
    Name = "Supply",
    CurrentValue = true,
    Callback = function(value)
        ChestSettings.Supply = value
        refreshChestESP()
    end
})

PveTab:CreateToggle({
    Name = "CrateSpawn",
    CurrentValue = true,
    Callback = function(value)
        ChestSettings.CrateSpawn = value
        refreshChestESP()
    end
})

PveTab:CreateToggle({
    Name = "EliteCrate",
    CurrentValue = true,
    Callback = function(value)
        ChestSettings.EliteCrate = value
        refreshChestESP()
    end
})

PveTab:CreateToggle({
    Name = "Chest Name",
    CurrentValue = true,
    Callback = function(value)
        ChestSettings.ShowName = value

        for _, data in pairs(ChestCache) do
            if data.Billboard then
                data.Billboard.Enabled = value
            end
        end
    end
})

PveTab:CreateSlider({
    Name = "Chest Distance",
    Range = {50, 2000},
    Increment = 50,
    CurrentValue = 1000,
    Callback = function(value)
        ChestSettings.MaxDistance = value
    end
})

PveTab:CreateDivider()
PveTab:CreateSection("Anti-AFK")

PveTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Callback = function(value)
        Settings.AntiAFK = value
    end
})

LocalPlayer.Idled:Connect(function()
    if not Settings.AntiAFK then
        return
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- PLAYER ESP
-- ORIGINAL FUNCTION: UNCHANGED
local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end

        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        local root = character
            and (character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("Head"))

        if not Settings.PlayerESP then
            if HighlightCache[player] then
                HighlightCache[player].Enabled = false
            end

            if InfoCache[player] then
                InfoCache[player].Enabled = false
            end

            continue
        end

        if not character or not humanoid
            or humanoid.Health <= 0 or not root then

            if HighlightCache[player] then
                HighlightCache[player].Adornee = nil
            end

            if InfoCache[player] then
                InfoCache[player].Adornee = nil
                InfoCache[player].Enabled = false
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

        local billboard = InfoCache[player]

        if not billboard then
            billboard = createInfoGui("PlayerInfo", -3)
            InfoCache[player] = billboard
        end

        billboard.Adornee = root

        local lines = {}

        if Settings.PlayerName then
            table.insert(lines, player.Name)
        end

        if Settings.PlayerHealth then
            table.insert(lines, string.format(
                "HP: %d / %d",
                math.floor(humanoid.Health),
                math.floor(humanoid.MaxHealth)
            ))
        end

        if Settings.PlayerDistance then
            local localCharacter = LocalPlayer.Character
            local localRoot = localCharacter
                and localCharacter:FindFirstChild("HumanoidRootPart")

            if localRoot then
                local distance =
                    (localRoot.Position - root.Position).Magnitude

                table.insert(lines, string.format(
                    "DIST: %d m",
                    math.floor(distance)
                ))
            end
        end

        if Settings.PlayerItem then
            local tool = character:FindFirstChildOfClass("Tool")

            if tool then
                table.insert(lines, tool.Name)
            end
        end

        local label = billboard:FindFirstChild("Info")

        if label then
            label.Text = table.concat(lines, "\n")
            label.TextSize = Settings.PlayerTextSize
        end

        billboard.Enabled = #lines > 0
    end
end

-- NPC ESP
local function updateNPCESP()
    if not Settings.NPCESP then
        clearNPCESP()
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
            billboard = createInfoGui("NPCInfo", 2.5)
            NPCInfoCache[model] = billboard
        end

        local head = model:FindFirstChild("Head")
        billboard.Adornee = head or root

        local label = billboard:FindFirstChild("Info")

        if label then
            label.Text = Settings.NPCName and "Guard" or ""
            label.TextSize = Settings.GuardTextSize
        end

        billboard.Enabled = Settings.NPCName
    end
end

Players.PlayerRemoving:Connect(removeESP)

Workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Model") and NPCList[obj] then
        removeNPCESP(obj)
        NPCList[obj] = nil
    end
end)

-- MAIN LOOP
local ESP_UPDATE_INTERVAL = 0.35
local lastESPUpdate = 0

RunService.RenderStepped:Connect(function()
    if not Camera then
        return
    end

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

    if Settings.SmoothAim and RightMouseDown and not FreeCamEnabled then
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
