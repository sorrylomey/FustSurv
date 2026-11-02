local Rayfield = loadstring(game:HttpGet(
    "https://github.com/UnknownDeveloper-sqd/UnknownSquad-RayField-Lib/raw/refs/heads/main/Rayfield/CustomRayfield.luau"
))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- Настройки
local Settings = {
    PlayerESP = false,
    PlayerName = true,
    PlayerHealth = true,
    PlayerDistance = true,

    SmoothAim = false,
    VisibilityCheck = true,
    AimPart = "Head",
    Smoothness = 5,
    FOV = 150,
    ShowFOV = true
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
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local PvpTab = Window:CreateTab("PVP")
local PveTab = Window:CreateTab("PVE")
local VisualsTab = Window:CreateTab("Visuals")

-- SmoothAim настройки
PvpTab:CreateToggle({
    Name = "SmoothAim",
    CurrentValue = false,
    Callback = function(value)
        Settings.SmoothAim = value
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

-- ESP настройки
VisualsTab:CreateToggle({
    Name = "PlayerESP",
    CurrentValue = false,
    Callback = function(value)
        Settings.PlayerESP = value
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerName",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerName = value
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerHealth",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerHealth = value
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerDistance",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerDistance = value
    end
})

-- FOV Circle
local FOVCircle

pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 80
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(180, 100, 255)
        FOVCircle.Transparency = 1
    end
end)

-- Aim functions
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

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, params)

    return result == nil or result.Instance:IsDescendantOf(character)
end

local function getClosestTarget()
    if not Camera then
        return nil
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    local closestTarget = nil
    local shortestDistance = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local targetPart = getAimPart(character)

            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPosition, onScreen =
                    Camera:WorldToViewportPoint(targetPart.Position)

                if onScreen and screenPosition.Z > 0 then
                    local screenPoint = Vector2.new(
                        screenPosition.X,
                        screenPosition.Y
                    )

                    local distance = (screenPoint - center).Magnitude

                    if distance < shortestDistance
                        and isVisible(character, targetPart.Position) then

                        shortestDistance = distance
                        closestTarget = targetPart
                    end
                end
            end
        end
    end

    return closestTarget
end

-- SmoothAim работает при удержании ПКМ
local RightMouseDown = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = false
    end
end)

RunService.RenderStepped:Connect(function()
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

    if not Settings.SmoothAim or not RightMouseDown then
        return
    end

    local target = getClosestTarget()

    if target and target.Parent then
        local smoothness = math.clamp(Settings.Smoothness, 1, 10)
        local alpha = 1 / smoothness

        local targetCFrame = CFrame.lookAt(
            Camera.CFrame.Position,
            target.Position
        )

        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
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

local function createInfoGui(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerInfo"
    billboard.Size = UDim2.fromOffset(220, 65)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.Code
    label.TextWrapped = true
    label.Parent = billboard

    InfoCache[player] = billboard

    return billboard
end

local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")

            local root = character
                and (character:FindFirstChild("HumanoidRootPart")
                or character:FindFirstChild("Head"))

            if Settings.PlayerESP and character and humanoid
                and humanoid.Health > 0 and root then

                -- Highlight outline only
                local highlight = HighlightCache[player]

                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerHighlight"
                    highlight.FillTransparency = 1
                    highlight.OutlineTransparency = 0
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = ESPFolder

                    HighlightCache[player] = highlight
                end

                highlight.Adornee = character

                -- Name / HP / Distance
                local billboard = InfoCache[player]

                if not billboard then
                    billboard = createInfoGui(player)
                end

                local label = billboard:FindFirstChild("Info")
                billboard.Adornee = root

                local lines = {}

                if Settings.PlayerName then
                    table.insert(lines, player.DisplayName)
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
                        local distance = (localRoot.Position - root.Position).Magnitude

                        table.insert(lines, string.format(
                            "DIST: %d m",
                            math.floor(distance)
                        ))
                    end
                end

                if label then
                    label.Text = table.concat(lines, "\n")
                end

                billboard.Enabled = #lines > 0
            else
                removeESP(player)
            end
        end
    end
end

Players.PlayerRemoving:Connect(removeESP)

task.spawn(function()
    while task.wait(0.2) do
        updatePlayerESP()
    end
end)

-- Mobile UI button
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
            if gui:IsA("ScreenGui")
                and gui ~= toggleGui then
                gui.Enabled = not gui.Enabled
            end
        end
    end)
end
