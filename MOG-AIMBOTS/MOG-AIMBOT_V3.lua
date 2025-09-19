local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")

local Aiming = false
local TeamCheck = true
local Smoothness = 0.05
local FOV = 180
local Keybind = Enum.KeyCode.Q
local AimLockPart = "Head"
local Prediction = 0.10
local VisibleCheck = true
local ESPEnabled = false
local WallCheck = true
local MultiTarget = false
local ESPColor = Color3.new(1, 1, 1)
local LegitMode = true
local AutoShoot = false
local MovementPrediction = false
local FullHeadMode = false
local AutoShootCPS = 15
local BulletDetection = false

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
    highlight.Transparency = 0.2
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

local movementHistory = {}
local function AnalyzeMovementPattern(character)
    if not MovementPrediction then return Vector3.new(0, 0, 0) end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return Vector3.new(0, 0, 0) end
    
    local currentTime = tick()
    local playerName = character.Parent.Name
    
    if not movementHistory[playerName] then
        movementHistory[playerName] = {}
    end
    
    table.insert(movementHistory[playerName], {
        time = currentTime,
        position = rootPart.Position,
        velocity = rootPart.Velocity
    })
    
    while #movementHistory[playerName] > 0 and currentTime - movementHistory[playerName][1].time > 2 do
        table.remove(movementHistory[playerName], 1)
    end
    
    if #movementHistory[playerName] < 2 then
        return rootPart.Velocity
    end
    
    local avgVelocity = Vector3.new(0, 0, 0)
    local totalWeight = 0
    
    for i, data in ipairs(movementHistory[playerName]) do
        local weight = 1 - (currentTime - data.time) / 2
        if weight > 0 then
            avgVelocity = avgVelocity + (data.velocity * weight)
            totalWeight = totalWeight + weight
        end
    end
    
    if totalWeight > 0 then
        avgVelocity = avgVelocity / totalWeight
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            avgVelocity = avgVelocity + (moveDirection * 12)
        end
        
        if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            avgVelocity = avgVelocity + Vector3.new(0, 15, 0)
        elseif humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            avgVelocity = avgVelocity + Vector3.new(0, -8, 0)
        end
    end
    
    return avgVelocity
end

local function GetHeadPartPosition(character)
    if not FullHeadMode then
        return character.Head.Position
    end
    
    local head = character:FindFirstChild("Head")
    if not head then return character.Head.Position end
    
    local randomOffset = Vector3.new(
        (math.random() - 0.5) * head.Size.X * 0.8,
        (math.random() - 0.5) * head.Size.Y * 0.8,
        (math.random() - 0.5) * head.Size.Z * 0.8
    )
    
    return head.Position + randomOffset
end

local function GetBulletTargets()
    local bulletTargets = {}
    if not BulletDetection then return bulletTargets end
    
    for _, part in pairs(workspace:GetChildren()) do
        if part:IsA("BasePart") and part.Velocity.Magnitude > 80 then
            local creator = part:FindFirstChild("Creator")
            if creator and creator.Value ~= Player then
                local screenPos = Camera:WorldToViewportPoint(part.Position)
                if screenPos.Z > 0 then
                    local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if distance <= FOV then
                        local bulletSpeed = part.Velocity.Magnitude
                        local timeToHit = (part.Position - Camera.CFrame.Position).Magnitude / bulletSpeed
                        local predictedPos = part.Position + (part.Velocity.Unit * bulletSpeed * timeToHit * 1.2)
                        
                        table.insert(bulletTargets, {
                            position = predictedPos,
                            distance = distance
                        })
                    end
                end
            end
        end
    end
    
    return bulletTargets
end

local function GetClosestPlayers()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 and IsEnemy(player) then
            local screenPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if screenPos.Z > 0 then
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if distance <= FOV then
                    if VisibleCheck and not IsVisible(player.Character[AimLockPart]) then continue end
                    
                    local targetPosition
                    if AimLockPart == "Head" then
                        targetPosition = GetHeadPartPosition(player.Character)
                    else
                        targetPosition = player.Character[AimLockPart].Position
                    end
                    
                    local movementVector = AnalyzeMovementPattern(player.Character)
                    table.insert(players, {
                        player = player,
                        distance = distance,
                        position = targetPosition + (movementVector * Prediction)
                    })
                end
            end
        end
    end
    
    local bulletTargets = GetBulletTargets()
    for _, bullet in pairs(bulletTargets) do
        table.insert(players, {
            distance = bullet.distance,
            position = bullet.position
        })
    end
    
    table.sort(players, function(a, b)
        return a.distance < b.distance
    end)
    
    return players
end

local function SmoothLerp(c1, c2, alpha)
    local dynamicSmoothness = LegitMode and math.clamp(Smoothness * 1.5, 0.02, 0.18) or Smoothness
    local smoothAlpha = 1 - math.pow(1 - dynamicSmoothness, 3)
    return c1:lerp(c2, smoothAlpha)
end

local lastTargetPos = nil
local lastSmoothTime = 0
local lastShotTime = 0

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
        local dynamicSmoothness = LegitMode and math.clamp(Smoothness * (1 + distance/12), 0.02, 0.2) or math.clamp(Smoothness * (1 + distance/8), 0, 0.5)
        Camera.CFrame = SmoothLerp(Camera.CFrame, lookAt, dynamicSmoothness)
    else
        Camera.CFrame = Camera.CFrame:lerp(lookAt, Smoothness)
    end
    
    lastTargetPos = finalPosition
    
    if AutoShoot and #targets > 0 and currentTime - lastShotTime >= (1 / AutoShootCPS) then
        if not UserInputService:GetFocusedTextBox() then
            mouse1click()
            lastShotTime = currentTime
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MOG_Aimbot"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 350, 0, 650)
Frame.Position = UDim2.new(0.5, -175, 0.5, -325)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Text = "MOG-AIMBOT_V3 by MOG-Developing"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Title.TextColor3 = Color3.new(1, 1, 1)
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
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1050)

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
    button.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    button.TextColor3 = Color3.new(1, 1, 1)
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
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Text = tostring(value)
    box.Size = UDim2.new(1, 0, 0, 30)
    box.Position = UDim2.new(0, 0, 0, 25)
    box.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    box.TextColor3 = Color3.new(1, 1, 1)
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
local LegitModeToggle = CreateButton("Legit Mode: "..tostring(LegitMode))
local AutoShootToggle = CreateButton("Auto Shoot: "..tostring(AutoShoot))
local MovementPredictionToggle = CreateButton("Movement Prediction: "..tostring(MovementPrediction))
local FullHeadToggle = CreateButton("Full Head Mode: "..tostring(FullHeadMode))
local BulletDetectionToggle = CreateButton("Bullet Detection: "..tostring(BulletDetection))
local CPSSlider = CreateSlider("Auto Shoot CPS", AutoShootCPS)
local ColorPickerButton = CreateButton("ESP Color: [255,255,255]")

local function UpdateColorPickerText()
    ColorPickerButton.Text = string.format("ESP Color: [%d,%d,%d]", 
        math.floor(ESPColor.R * 255), 
        math.floor(ESPColor.G * 255), 
        math.floor(ESPColor.B * 255))
end

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
    if value and value > 0 and value <= 360 then
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

LegitModeToggle.MouseButton1Click:Connect(function()
    LegitMode = not LegitMode
    LegitModeToggle.Text = "Legit Mode: "..tostring(LegitMode)
end)

AutoShootToggle.MouseButton1Click:Connect(function()
    AutoShoot = not AutoShoot
    AutoShootToggle.Text = "Auto Shoot: "..tostring(AutoShoot)
end)

MovementPredictionToggle.MouseButton1Click:Connect(function()
    MovementPrediction = not MovementPrediction
    MovementPredictionToggle.Text = "Movement Prediction: "..tostring(MovementPrediction)
end)

FullHeadToggle.MouseButton1Click:Connect(function()
    FullHeadMode = not FullHeadMode
    FullHeadToggle.Text = "Full Head Mode: "..tostring(FullHeadMode)
end)

BulletDetectionToggle.MouseButton1Click:Connect(function()
    BulletDetection = not BulletDetection
    BulletDetectionToggle.Text = "Bullet Detection: "..tostring(BulletDetection)
end)

CPSSlider.FocusLost:Connect(function()
    local value = tonumber(CPSSlider.Text)
    if value and value >= 1 and value <= 30 then
        AutoShootCPS = value
        CPSSlider.Text = tostring(AutoShootCPS)
    else
        CPSSlider.Text = tostring(AutoShootCPS)
    end
end)

ColorPickerButton.MouseButton1Click:Connect(function()
    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)
    ESPColor = Color3.fromRGB(r, g, b)
    UpdateColorPickerText()
    UpdateESP()
end)

UpdateColorPickerText()

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

print("MOG-AIMBOT_V3 LOADED!")
print("THANKS FOR USING!!❤️")
print("Made by @misterofgames_yt | MOG-Developing")
