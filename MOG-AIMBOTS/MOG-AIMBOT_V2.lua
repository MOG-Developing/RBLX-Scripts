local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")

local Aiming = false
local TeamCheck = true
local Smoothness = 0.1
local FOV = 100
local Keybind = Enum.KeyCode.Q
local AimLockPart = "Head"
local Prediction = 0.1
local VisibleCheck = true
local ESPEnabled = false
local WallCheck = true
local MultiTarget = false
local ESPColor = Color3.fromRGB(255, 0, 0)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "MOG_ESPFolder"
ESPFolder.Parent = workspace

local function IsEnemy(player)
    if not TeamCheck then return true end
    if not Player.Team then return true end
    return player.Team ~= Player.Team
end

local function CreateESP(character, player)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local highlight = Instance.new("BoxHandleAdornment")
    highlight.Name = "MOG_ESP"
    highlight.Adornee = character.HumanoidRootPart
    highlight.Size = character.HumanoidRootPart.Size + Vector3.new(0.5, 0.5, 0.5)
    highlight.Color3 = ESPColor
    highlight.Transparency = 0.3
    highlight.AlwaysOnTop = true
    highlight.ZIndex = 10
    highlight.Parent = ESPFolder
    
    local nameTag = Instance.new("BillboardGui")
    nameTag.Name = "MOG_NameTag"
    nameTag.Adornee = character.Head
    nameTag.Size = UDim2.new(0, 200, 0, 50)
    nameTag.StudsOffset = Vector3.new(0, 2, 0)
    nameTag.AlwaysOnTop = true
    nameTag.Parent = ESPFolder
    
    local tag = Instance.new("TextLabel")
    tag.Text = player.Name
    tag.Size = UDim2.new(1, 0, 1, 0)
    tag.BackgroundTransparency = 1
    tag.TextColor3 = ESPColor
    tag.TextStrokeTransparency = 0
    tag.Font = Enum.Font.GothamBold
    tag.TextSize = 18
    tag.Parent = nameTag
    
    return {highlight = highlight, nameTag = nameTag}
end

local function ClearESP()
    for _, child in pairs(ESPFolder:GetChildren()) do
        child:Destroy()
    end
end

local function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and IsEnemy(player) then
            CreateESP(player.Character, player)
        end
    end
end

local function IsVisible(targetPart)
    if not WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 2000
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character, Camera})
    return hit and hit:IsDescendantOf(targetPart.Parent)
end

local function GetClosestPlayers()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 and IsEnemy(player) then
            local screenPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if screenPos.Z > 0 then
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if VisibleCheck and not IsVisible(player.Character[AimLockPart]) then continue end
                if distance <= FOV then
                    table.insert(players, {
                        player = player,
                        distance = distance,
                        position = player.Character[AimLockPart].Position + (player.Character.HumanoidRootPart.Velocity * Prediction)
                    })
                end
            end
        end
    end
    
    table.sort(players, function(a, b)
        return a.distance < b.distance
    end)
    
    return players
end

local function SmoothLerp(c1, c2, alpha)
    local cf = c1:lerp(c2, alpha)
    local smoothAlpha = 1 - math.pow(1 - alpha, 3)
    return c1:lerp(c2, smoothAlpha)
end

local lastTargetPos = nil
local lastSmoothTime = 0

local function AimAt(targets)
    if #targets == 0 then 
        lastTargetPos = nil
        return 
    end
    
    local currentTime = tick()
    local deltaTime = currentTime - lastSmoothTime
    lastSmoothTime = currentTime
    
    local targetPositions = {}
    for _, target in pairs(targets) do
        table.insert(targetPositions, target.position)
    end
    
    local finalPosition
    if MultiTarget and #targets > 1 then
        local avg = Vector3.new(0, 0, 0)
        for _, pos in pairs(targetPositions) do
            avg = avg + pos
        end
        finalPosition = avg / #targets
    else
        finalPosition = targets[1].position
    end
    
    local cameraPos = Camera.CFrame.Position
    local direction = (finalPosition - cameraPos).Unit
    local lookAt = CFrame.new(cameraPos, cameraPos + direction)
    
    if lastTargetPos then
        local distance = (finalPosition - lastTargetPos).Magnitude
        local dynamicSmoothness = math.clamp(Smoothness * (1 + distance/10), 0, 0.5)
        Camera.CFrame = SmoothLerp(Camera.CFrame, lookAt, dynamicSmoothness)
    else
        Camera.CFrame = Camera.CFrame:lerp(lookAt, Smoothness)
    end
    
    lastTargetPos = finalPosition
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MOG_Aimbot"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 350, 0, 500)
Frame.Position = UDim2.new(0.5, -175, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Text = "MOG-AIMBOT_V2 by MOG-Developing"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
Title.TextColor3 = Color3.fromRGB(200, 0, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = Frame
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 750)

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = ScrollFrame
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingTop = UDim.new(0, 5)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 5)

local function CreateButton(text)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, -10, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(30, 0, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.AutoButtonColor = true
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    button.Parent = ScrollFrame
    return button
end

local function CreateSlider(text, value)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Text = tostring(value)
    box.Size = UDim2.new(1, 0, 0, 30)
    box.Position = UDim2.new(0, 0, 0, 25)
    box.BackgroundColor3 = Color3.fromRGB(30, 0, 45)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.BorderSizePixel = 0
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box
    
    box.Parent = frame
    frame.Parent = ScrollFrame
    return box
end

local KeybindButton = CreateButton("Keybind: "..tostring(Keybind))
local ToggleButton = CreateButton("Aimbot: "..(Aiming and "ON" or "OFF"))
local TeamCheckToggle = CreateButton("Team Check: "..tostring(TeamCheck))
local SmoothnessSlider = CreateSlider("Smoothness", Smoothness)
local FOVSlider = CreateSlider("FOV", FOV)
local AimLockPartButton = CreateButton("Aim Part: "..AimLockPart)
local PredictionSlider = CreateSlider("Prediction", Prediction)
local VisibleCheckToggle = CreateButton("Visible Check: "..tostring(VisibleCheck))
local WallCheckToggle = CreateButton("Wall Check: "..tostring(WallCheck))
local ESPToggle = CreateButton("ESP: "..tostring(ESPEnabled))
local MultiTargetToggle = CreateButton("Multi-Target: "..tostring(MultiTarget))
local ColorPickerButton = CreateButton("ESP Color: [255,0,0]")

KeybindButton.MouseButton1Click:Connect(function()
    KeybindButton.Text = "Press any key..."
    local input = UserInputService.InputBegan:Wait()
    Keybind = input.KeyCode
    KeybindButton.Text = "Keybind: "..tostring(Keybind)
end)

ToggleButton.MouseButton1Click:Connect(function()
    Aiming = not Aiming
    ToggleButton.Text = "Aimbot: "..(Aiming and "ON" or "OFF")
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Keybind then
        Aiming = not Aiming
        ToggleButton.Text = "Aimbot: "..(Aiming and "ON" or "OFF")
    end
end)

TeamCheckToggle.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    TeamCheckToggle.Text = "Team Check: "..tostring(TeamCheck)
    UpdateESP()
end)

SmoothnessSlider.FocusLost:Connect(function()
    local value = tonumber(SmoothnessSlider.Text)
    if value and value >= 0 and value <= 1 then
        Smoothness = value
    else
        SmoothnessSlider.Text = tostring(Smoothness)
    end
end)

FOVSlider.FocusLost:Connect(function()
    local value = tonumber(FOVSlider.Text)
    if value and value > 0 then
        FOV = value
    else
        FOVSlider.Text = tostring(FOV)
    end
end)

AimLockPartButton.MouseButton1Click:Connect(function()
    if AimLockPart == "Head" then
        AimLockPart = "HumanoidRootPart"
    elseif AimLockPart == "HumanoidRootPart" then
        AimLockPart = "UpperTorso"
    else
        AimLockPart = "Head"
    end
    AimLockPartButton.Text = "Aim Part: "..AimLockPart
end)

PredictionSlider.FocusLost:Connect(function()
    local value = tonumber(PredictionSlider.Text)
    if value and value >= 0 then
        Prediction = value
    else
        PredictionSlider.Text = tostring(Prediction)
    end
end)

VisibleCheckToggle.MouseButton1Click:Connect(function()
    VisibleCheck = not VisibleCheck
    VisibleCheckToggle.Text = "Visible Check: "..tostring(VisibleCheck)
end)

WallCheckToggle.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    WallCheckToggle.Text = "Wall Check: "..tostring(WallCheck)
end)

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = "ESP: "..tostring(ESPEnabled)
    UpdateESP()
end)

MultiTargetToggle.MouseButton1Click:Connect(function()
    MultiTarget = not MultiTarget
    MultiTargetToggle.Text = "Multi-Target: "..tostring(MultiTarget)
end)

ColorPickerButton.MouseButton1Click:Connect(function()
    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)
    ESPColor = Color3.fromRGB(r, g, b)
    ColorPickerButton.Text = string.format("ESP Color: [%d,%d,%d]", r, g, b)
    UpdateESP()
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if ESPEnabled then
            UpdateESP()
        end
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Player then
        player.CharacterAdded:Connect(function(character)
            if ESPEnabled then
                UpdateESP()
            end
        end)
    end
end

UpdateESP()

RunService.RenderStepped:Connect(function()
    if Aiming then
        local targets = GetClosestPlayers()
        AimAt(targets)
    end
end)

while true do
    wait(1)
    if ESPEnabled then
        UpdateESP()
    end
end

print("MOG-AIMBOT_V2 LOADED!")
print("THANKS FOR USING!!❤️")
print("Made by @misterofgames_yt | MOG-Developing")
