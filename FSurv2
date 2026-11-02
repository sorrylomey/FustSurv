local Rayfield = loadstring(game:HttpGet(
    "https://github.com/UnknownDeveloper-sqd/UnknownSquad-RayField-Lib/raw/refs/heads/main/Rayfield/CustomRayfield.luau"
))()

local Window = Rayfield:CreateWindow({
    Name = "FustSurv | SomeCheats",
    LoadingTitle = "FustSurv | SomeCheats",
    LoadingSubtitle = "By: UnknownSquad",
    Theme = "Amethyst",
    Width = 460,
    Height = 360,
    Font = "Code",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local PvpTab = Window:CreateTab("PVP")
local PveTab = Window:CreateTab("PVE")
local VisualsTab = Window:CreateTab("Visuals")

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")

local lp = Players.LocalPlayer

-- SETTINGS

local Settings = {
    SilentAim = false,
    AutoCross = false,

    SmoothAim = false,
    AimPart = "Head",
    Smoothness = 5,
    FOV = 150,
    ShowFOV = true,

    NoRecoil = false,
    NoCameraShake = false,

    PlayerESP = false,
    PlayerName = false,
    PlayerDistance = false,
    PlayerHealth = false,
    NPCESP = false,

    Noclip = false
}

-- PVP

PvpTab:CreateToggle({
    Name = "SilentAim",
    CurrentValue = false,
    Callback = function(v)
        Settings.SilentAim = v
    end
})

PvpTab:CreateToggle({
    Name = "SmoothAim",
    CurrentValue = false,
    Callback = function(v)
        Settings.SmoothAim = v
    end
})

PvpTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Torso", "Legs"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Callback = function(v)
        Settings.AimPart = typeof(v) == "table" and v[1] or v
    end
})

PvpTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v)
        Settings.Smoothness = v
    end
})

PvpTab:CreateSlider({
    Name = "FOV",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(v)
        Settings.FOV = v
    end
})

PvpTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
    Callback = function(v)
        Settings.ShowFOV = v
    end
})

PvpTab:CreateToggle({
    Name = "NoRecoil",
    CurrentValue = false,
    Callback = function(v)
        Settings.NoRecoil = v
    end
})

PvpTab:CreateToggle({
    Name = "No Camera Shake",
    CurrentValue = false,
    Callback = function(v)
        Settings.NoCameraShake = v
    end
})

-- PVE

PveTab:CreateToggle({
    Name = "AutoCross",
    CurrentValue = false,
    Callback = function(v)
        Settings.AutoCross = v
    end
})

-- NOCLIP

local noclipConnection
local originalCollision = {}

local function restoreCollision()
    for part, value in pairs(originalCollision) do
        if part and part.Parent then
            part.CanCollide = value
        end
    end

    table.clear(originalCollision)
end

local function setNoclip(enabled)
    Settings.Noclip = enabled

    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    if not enabled then
        restoreCollision()
        return
    end

    noclipConnection = RS.Stepped:Connect(function()
        local character = lp.Character
        if not character then return end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCollision[part] == nil then
                    originalCollision[part] = part.CanCollide
                end

                part.CanCollide = false
            end
        end
    end)
end

PveTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = setNoclip
})

lp.CharacterAdded:Connect(function()
    if Settings.Noclip then
        task.wait(0.5)
        setNoclip(true)
    else
        restoreCollision()
    end
end)

-- VISUALS

VisualsTab:CreateToggle({
    Name = "PlayerESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerESP = v
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerName",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerName = v
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerDistance",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerDistance = v
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerHealth",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerHealth = v
    end
})

VisualsTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.NPCESP = v
    end
})

-- SMOOTH AIM + PLAYER ESP
-- Intended for development/testing in your own Roblox experience.
-- Aim assist is active only while the right mouse button is held.

local aimConnection
local espObjects = {}

local function getAimPart(character)
    if not character then return nil end

    if Settings.AimPart == "Head" then
        return character:FindFirstChild("Head")
    elseif Settings.AimPart == "Torso" then
        return character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("HumanoidRootPart")
    else -- Legs
        local left = character:FindFirstChild("LeftUpperLeg")
            or character:FindFirstChild("Left Leg")
        local right = character:FindFirstChild("RightUpperLeg")
            or character:FindFirstChild("Right Leg")
        if left and right then
            return (left.Position + right.Position) / 2
        end
        return left or right or character:FindFirstChild("HumanoidRootPart")
    end
end

local function getClosestAimTarget()
    local camera = WS.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize / 2
    local bestPart, bestDistance = nil, Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local part = getAimPart(player.Character)
            if humanoid and humanoid.Health > 0 and part then
                local screenPos, onScreen = camera:WorldToViewportPoint(
                    typeof(part) == "Vector3" and part or part.Position
                )
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if distance <= bestDistance then
                        bestDistance = distance
                        bestPart = typeof(part) == "Vector3" and CFrame.new(part) or part
                    end
                end
            end
        end
    end

    return bestPart
end

local function updateSmoothAim()
    if not Settings.SmoothAim or not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        return
    end

    local camera = WS.CurrentCamera
    local target = getClosestAimTarget()
    if not camera or not target then return end

    local targetPosition = target.Position
    local goal = CFrame.lookAt(camera.CFrame.Position, targetPosition)
    -- 1 = instant; 10 = slower/smoother.
    local alpha = 1 / math.clamp(Settings.Smoothness, 1, 10)
    camera.CFrame = camera.CFrame:Lerp(goal, alpha)
end

local function clearPlayerESP(player)
    local objects = espObjects[player]
    if not objects then return end
    if objects.highlight then objects.highlight:Destroy() end
    if objects.billboard then objects.billboard:Destroy() end
    espObjects[player] = nil
end

local function createOrUpdatePlayerESP(player)
    if player == lp then return end
    local character = player.Character
    if not character then
        clearPlayerESP(player)
        return
    end

    local objects = espObjects[player]
    if not objects or objects.character ~= character then
        clearPlayerESP(player)
        objects = {character = character}
        espObjects[player] = objects

        local highlight = Instance.new("Highlight")
        highlight.Name = "FustSurv_PlayerHighlight"
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(170, 90, 255)
        highlight.OutlineColor = Color3.fromRGB(230, 210, 255)
        highlight.FillTransparency = 0.55
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        objects.highlight = highlight

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "FustSurv_PlayerInfo"
        billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        billboard.Size = UDim2.fromOffset(180, 54)
        billboard.StudsOffset = Vector3.new(0, 2.8, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = true
        billboard.Parent = lp:WaitForChild("PlayerGui")

        local label = Instance.new("TextLabel")
        label.Name = "Info"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.Code
        label.TextSize = 13
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.25
        label.TextWrapped = true
        label.Parent = billboard
        objects.billboard = billboard
        objects.label = label
    end

    local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    objects.billboard.Adornee = head
    objects.highlight.Enabled = Settings.PlayerESP
    objects.billboard.Enabled = Settings.PlayerESP and (Settings.PlayerName or Settings.PlayerDistance or Settings.PlayerHealth)

    local pieces = {}
    if Settings.PlayerName then
        table.insert(pieces, player.DisplayName)
    end
    if Settings.PlayerDistance and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local distance = (root.Position - lp.Character.HumanoidRootPart.Position).Magnitude
            table.insert(pieces, string.format("%dm", math.floor(distance + 0.5)))
        end
    end
    if Settings.PlayerHealth then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            table.insert(pieces, string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)))
        end
    end
    objects.label.Text = table.concat(pieces, " | ")
end

local function refreshPlayerESP()
    if not Settings.PlayerESP then
        for player in pairs(espObjects) do
            clearPlayerESP(player)
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        createOrUpdatePlayerESP(player)
    end
end

Players.PlayerRemoving:Connect(clearPlayerESP)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.25)
        if Settings.PlayerESP then createOrUpdatePlayerESP(player) end
    end)
end)

RS.RenderStepped:Connect(function()
    updateSmoothAim()
    refreshPlayerESP()
end)

-- FOV CIRCLE

local FOVCircle

if Drawing and Drawing.new then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 80
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(180, 100, 255)
    FOVCircle.Visible = false
end

RS.RenderStepped:Connect(function()
    if not FOVCircle then return end

    local Camera = WS.CurrentCamera
    if not Camera then
        FOVCircle.Visible = false
        return
    end

    local Viewport = Camera.ViewportSize

    FOVCircle.Position = Vector2.new(
        Viewport.X / 2,
        Viewport.Y / 2
    )

    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.SmoothAim and Settings.ShowFOV
end)

-- MOBILE UI BUTTON

if UIS.TouchEnabled then
    local GuiParent = (gethui and gethui())
        or lp:WaitForChild("PlayerGui")

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "MobileToggleGui"
    ToggleGui.ResetOnSpawn = false
    ToggleGui.Parent = GuiParent

    local Button = Instance.new("TextButton")
    Button.Name = "ToggleUI"
    Button.Size = UDim2.fromOffset(45, 45)
    Button.Position = UDim2.new(0.02, 0, 0.25, 0)
    Button.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = "UI"
    Button.TextSize = 16
    Button.Font = Enum.Font.Code
    Button.Parent = ToggleGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(150, 90, 220)
    Stroke.Thickness = 1.5
    Stroke.Parent = Button

    Button.Activated:Connect(function()
        for _, Gui in ipairs(GuiParent:GetChildren()) do
            if Gui:IsA("ScreenGui") and Gui ~= ToggleGui then
                Gui.Enabled = not Gui.Enabled
            end
        end
    end)
end

-- NOTIFICATION

Rayfield:Notify({
    Title = "FustSurv | SomeCheats",
    Content = "Interface loaded successfully!",
    Duration = 4
})
