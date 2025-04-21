local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local Aiming = false
local TeamCheck = true
local Smoothness = 0.1
local FOV = 100
local Keybind = Enum.KeyCode.Q
local AimLock = false
local AimLockPart = "Head"
local Prediction = 0.1
local VisibleCheck = true

local function GetClosestPlayer()
    local ClosestPlayer, ClosestDistance = nil, math.huge
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if TeamCheck and v.Team == Player.Team then continue end
            local ScreenPos = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if ScreenPos.Z > 0 then
                local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                if VisibleCheck then
                    local Ray = Ray.new(Camera.CFrame.Position, (v.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * 1000)
                    local Hit, Position = workspace:FindPartOnRay(Ray, Player.Character)
                    if Hit and Hit:IsDescendantOf(v.Character) then
                        if Distance < ClosestDistance and Distance <= FOV then
                            ClosestPlayer, ClosestDistance = v, Distance
                        end
                    end
                else
                    if Distance < ClosestDistance and Distance <= FOV then
                        ClosestPlayer, ClosestDistance = v, Distance
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

local function AimAt(Player)
    if Player and Player.Character and Player.Character:FindFirstChild(AimLockPart) then
        local TargetPos = Player.Character[AimLockPart].Position + (Player.Character.HumanoidRootPart.Velocity * Prediction)
        local CameraPos = Camera.CFrame.Position
        local Direction = (TargetPos - CameraPos).Unit
        local LookAt = CFrame.new(CameraPos, CameraPos + Direction)
        local SmoothCFrame = Camera.CFrame:Lerp(LookAt, Smoothness)
        Camera.CFrame = SmoothCFrame
    end
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Keybind then
        Aiming = not Aiming
    end
end)

RunService.RenderStepped:Connect(function()
    if Aiming then
        local ClosestPlayer = GetClosestPlayer()
        if ClosestPlayer then
            AimAt(ClosestPlayer)
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local KeybindButton = Instance.new("TextButton")
local TeamCheckToggle = Instance.new("TextButton")
local SmoothnessSlider = Instance.new("TextBox")
local FOVSlider = Instance.new("TextBox")
local AimLockToggle = Instance.new("TextButton")
local AimLockPartButton = Instance.new("TextButton")
local PredictionSlider = Instance.new("TextBox")
local VisibleCheckToggle = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "MOG-AIMBOT V1 (by @misterofgames_yt)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Title.TextColor3 = Color3.new(1, 1, 1)

KeybindButton.Parent = Frame
KeybindButton.Text = "Keybind: " .. tostring(Keybind)
KeybindButton.Size = UDim2.new(0.8, 0, 0, 20)
KeybindButton.Position = UDim2.new(0.1, 0, 0.1, 0)
KeybindButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
KeybindButton.TextColor3 = Color3.new(1, 1, 1)
KeybindButton.MouseButton1Click:Connect(function()
    KeybindButton.Text = "Press a key..."
    local Input = UserInputService.InputBegan:Wait()
    Keybind = Input.KeyCode
    KeybindButton.Text = "Keybind: " .. tostring(Keybind)
end)

TeamCheckToggle.Parent = Frame
TeamCheckToggle.Text = "Team Check: " .. tostring(TeamCheck)
TeamCheckToggle.Size = UDim2.new(0.8, 0, 0, 20)
TeamCheckToggle.Position = UDim2.new(0.1, 0, 0.2, 0)
TeamCheckToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
TeamCheckToggle.TextColor3 = Color3.new(1, 1, 1)
TeamCheckToggle.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    TeamCheckToggle.Text = "Team Check: " .. tostring(TeamCheck)
end)

SmoothnessSlider.Parent = Frame
SmoothnessSlider.PlaceholderText = "Smoothness: " .. tostring(Smoothness)
SmoothnessSlider.Size = UDim2.new(0.8, 0, 0, 20)
SmoothnessSlider.Position = UDim2.new(0.1, 0, 0.3, 0)
SmoothnessSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SmoothnessSlider.TextColor3 = Color3.new(1, 1, 1)
SmoothnessSlider.FocusLost:Connect(function()
    Smoothness = tonumber(SmoothnessSlider.Text) or Smoothness
    SmoothnessSlider.Text = "Smoothness: " .. tostring(Smoothness)
end)

FOVSlider.Parent = Frame
FOVSlider.PlaceholderText = "FOV: " .. tostring(FOV)
FOVSlider.Size = UDim2.new(0.8, 0, 0, 20)
FOVSlider.Position = UDim2.new(0.1, 0, 0.4, 0)
FOVSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
FOVSlider.TextColor3 = Color3.new(1, 1, 1)
FOVSlider.FocusLost:Connect(function()
    FOV = tonumber(FOVSlider.Text) or FOV
    FOVSlider.Text = "FOV: " .. tostring(FOV)
end)

AimLockToggle.Parent = Frame
AimLockToggle.Text = "Aim Lock: " .. tostring(AimLock)
AimLockToggle.Size = UDim2.new(0.8, 0, 0, 20)
AimLockToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
AimLockToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
AimLockToggle.TextColor3 = Color3.new(1, 1, 1)
AimLockToggle.MouseButton1Click:Connect(function()
    AimLock = not AimLock
    AimLockToggle.Text = "Aim Lock: " .. tostring(AimLock)
end)

AimLockPartButton.Parent = Frame
AimLockPartButton.Text = "Aim Lock Part: " .. AimLockPart
AimLockPartButton.Size = UDim2.new(0.8, 0, 0, 20)
AimLockPartButton.Position = UDim2.new(0.1, 0, 0.6, 0)
AimLockPartButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
AimLockPartButton.TextColor3 = Color3.new(1, 1, 1)
AimLockPartButton.MouseButton1Click:Connect(function()
    if AimLockPart == "Head" then
        AimLockPart = "HumanoidRootPart"
    else
        AimLockPart = "Head"
    end
    AimLockPartButton.Text = "Aim Lock Part: " .. AimLockPart
end)

PredictionSlider.Parent = Frame
PredictionSlider.PlaceholderText = "Prediction: " .. tostring(Prediction)
PredictionSlider.Size = UDim2.new(0.8, 0, 0, 20)
PredictionSlider.Position = UDim2.new(0.1, 0, 0.7, 0)
PredictionSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
PredictionSlider.TextColor3 = Color3.new(1, 1, 1)
PredictionSlider.FocusLost:Connect(function()
    Prediction = tonumber(PredictionSlider.Text) or Prediction
    PredictionSlider.Text = "Prediction: " .. tostring(Prediction)
end)

VisibleCheckToggle.Parent = Frame
VisibleCheckToggle.Text = "Visible Check: " .. tostring(VisibleCheck)
VisibleCheckToggle.Size = UDim2.new(0.8, 0, 0, 20)
VisibleCheckToggle.Position = UDim2.new(0.1, 0, 0.8, 0)
VisibleCheckToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
VisibleCheckToggle.TextColor3 = Color3.new(1, 1, 1)
VisibleCheckToggle.MouseButton1Click:Connect(function()
    VisibleCheck = not VisibleCheck
    VisibleCheckToggle.Text = "Visible Check: " .. tostring(VisibleCheck)
end)

StatusLabel.Parent = Frame
StatusLabel.Text = "Aimbot: " .. (Aiming and "ON" or "OFF")
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.9, 0)
StatusLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
StatusLabel.TextColor3 = Color3.new(1, 1, 1)

RunService.RenderStepped:Connect(function()
    StatusLabel.Text = "Aimbot: " .. (Aiming and "ON" or "OFF")
end)

print("MOG-AIMBOT_V1 Loaded")

print("Thank you for using MOG-AIMBOT_V1! Made by @misterofgames| MOG-Development")
