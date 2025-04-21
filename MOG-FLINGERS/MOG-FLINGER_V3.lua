local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CurrentTargets = {}
local Active = false
local Keybind = Enum.KeyCode.F
local Gui = nil
local TargetTime = 0.5
local TimeUnit = "MILLISECONDS"
local LastTargetTime = 0
local GuiPosition = UDim2.new(0.5, -225, 0.5, -175)
local FlingPower = 7500
local FlingMode = "CHAOTIC"
local TargetMode = "SINGLE"
local JumpSpam = true
local JumpInterval = 0.1
local LastJumpTime = 0

local function CreateGUI()
    if Gui then Gui:Destroy() end
    
    Gui = Instance.new("ScreenGui")
    Gui.Name = "MOG-FLINGER_V3"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 400)
    MainFrame.Position = GuiPosition
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 30)
    MainFrame.BorderSizePixel = 0
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 5)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    TopBar.BorderSizePixel = 0
    
    local TitleBar = Instance.new("TextButton")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 5)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 10, 60)
    TitleBar.BorderSizePixel = 0
    TitleBar.Text = ""
    TitleBar.AutoButtonColor = false
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Text = "MOG-FLINGER_V3"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0.9, 0, 0, 30)
    KeybindButton.Position = UDim2.new(0.05, 0, 0.15, 0)
    KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(100, 30, 150) or Color3.fromRGB(60, 20, 90)
    KeybindButton.TextColor3 = Color3.new(1, 1, 1)
    KeybindButton.Text = "TOGGLE KEY: "..Keybind.Name
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.TextSize = 14
    
    local TimeInput = Instance.new("TextBox")
    TimeInput.Size = UDim2.new(0.4, 0, 0, 30)
    TimeInput.Position = UDim2.new(0.05, 0, 0.25, 0)
    TimeInput.BackgroundColor3 = Color3.fromRGB(30, 5, 50)
    TimeInput.TextColor3 = Color3.new(1, 1, 1)
    TimeInput.Text = tostring(TargetTime)
    TimeInput.Font = Enum.Font.Gotham
    TimeInput.TextSize = 14
    TimeInput.PlaceholderText = "Time value"
    
    local UnitButton = Instance.new("TextButton")
    UnitButton.Size = UDim2.new(0.45, 0, 0, 30)
    UnitButton.Position = UDim2.new(0.5, 0, 0.25, 0)
    UnitButton.BackgroundColor3 = Color3.fromRGB(50, 15, 80)
    UnitButton.TextColor3 = Color3.new(1, 1, 1)
    UnitButton.Text = "UNIT: "..TimeUnit
    UnitButton.Font = Enum.Font.Gotham
    UnitButton.TextSize = 14
    
    local PowerInput = Instance.new("TextBox")
    PowerInput.Size = UDim2.new(0.9, 0, 0, 30)
    PowerInput.Position = UDim2.new(0.05, 0, 0.35, 0)
    PowerInput.BackgroundColor3 = Color3.fromRGB(30, 5, 50)
    PowerInput.TextColor3 = Color3.new(1, 1, 1)
    PowerInput.Text = tostring(FlingPower)
    PowerInput.Font = Enum.Font.Gotham
    PowerInput.TextSize = 14
    PowerInput.PlaceholderText = "Fling power"
    
    local ModeButton = Instance.new("TextButton")
    ModeButton.Size = UDim2.new(0.9, 0, 0, 30)
    ModeButton.Position = UDim2.new(0.05, 0, 0.45, 0)
    ModeButton.BackgroundColor3 = Color3.fromRGB(50, 15, 80)
    ModeButton.TextColor3 = Color3.new(1, 1, 1)
    ModeButton.Text = "MODE: "..FlingMode
    ModeButton.Font = Enum.Font.Gotham
    ModeButton.TextSize = 14
    
    local TargetModeButton = Instance.new("TextButton")
    TargetModeButton.Size = UDim2.new(0.9, 0, 0, 30)
    TargetModeButton.Position = UDim2.new(0.05, 0, 0.55, 0)
    TargetModeButton.BackgroundColor3 = Color3.fromRGB(50, 15, 80)
    TargetModeButton.TextColor3 = Color3.new(1, 1, 1)
    TargetModeButton.Text = "TARGET: "..TargetMode
    TargetModeButton.Font = Enum.Font.Gotham
    TargetModeButton.TextSize = 14
    
    local JumpToggle = Instance.new("TextButton")
    JumpToggle.Size = UDim2.new(0.9, 0, 0, 30)
    JumpToggle.Position = UDim2.new(0.05, 0, 0.65, 0)
    JumpToggle.BackgroundColor3 = JumpSpam and Color3.fromRGB(100, 30, 150) or Color3.fromRGB(60, 20, 90)
    JumpToggle.TextColor3 = Color3.new(1, 1, 1)
    JumpToggle.Text = "JUMP SPAM: "..(JumpSpam and "ON" or "OFF")
    JumpToggle.Font = Enum.Font.Gotham
    JumpToggle.TextSize = 14
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    StatusLabel.Text = Active and "STATUS: [ACTIVE]" or "STATUS: [INACTIVE]"
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 16
    
    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(1, 0, 0, 20)
    Credits.Position = UDim2.new(0, 0, 1, -20)
    Credits.BackgroundTransparency = 1
    Credits.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    Credits.Text = "By @misterofgames_yt | MOG-Development"
    Credits.Font = Enum.Font.Gotham
    Credits.TextSize = 12
    
    local function UpdateGUI()
        KeybindButton.Text = "TOGGLE KEY: "..Keybind.Name
        KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(100, 30, 150) or Color3.fromRGB(60, 20, 90)
        UnitButton.Text = "UNIT: "..TimeUnit
        ModeButton.Text = "MODE: "..FlingMode
        TargetModeButton.Text = "TARGET: "..TargetMode
        JumpToggle.Text = "JUMP SPAM: "..(JumpSpam and "ON" or "OFF")
        JumpToggle.BackgroundColor3 = JumpSpam and Color3.fromRGB(100, 30, 150) or Color3.fromRGB(60, 20, 90)
        StatusLabel.Text = Active and "STATUS: [ACTIVE]" or "STATUS: [INACTIVE]"
        StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    end
    
    KeybindButton.MouseButton1Click:Connect(function()
        KeybindButton.Text = "PRESS ANY KEY..."
        local Input = UIS.InputBegan:Wait()
        if Input.UserInputType == Enum.UserInputType.Keyboard then
            Keybind = Input.KeyCode
            UpdateGUI()
        end
    end)
    
    UnitButton.MouseButton1Click:Connect(function()
        TimeUnit = TimeUnit == "SECONDS" and "MILLISECONDS" or TimeUnit == "MILLISECONDS" and "MICROSECONDS" or "SECONDS"
        UpdateGUI()
    end)
    
    ModeButton.MouseButton1Click:Connect(function()
        FlingMode = FlingMode == "CHAOTIC" and "UPWARDS" or FlingMode == "UPWARDS" and "DOWNWARDS" or FlingMode == "DOWNWARDS" and "VORTEX" or "CHAOTIC"
        UpdateGUI()
    end)
    
    TargetModeButton.MouseButton1Click:Connect(function()
        TargetMode = TargetMode == "SINGLE" and "MULTI" or "SINGLE"
        UpdateGUI()
    end)
    
    JumpToggle.MouseButton1Click:Connect(function()
        JumpSpam = not JumpSpam
        UpdateGUI()
    end)
    
    TimeInput.FocusLost:Connect(function()
        local num = tonumber(TimeInput.Text)
        if num then
            if TimeUnit == "MICROSECONDS" then
                TargetTime = math.clamp(num, 100, 1000000)/1000000
            elseif TimeUnit == "MILLISECONDS" then
                TargetTime = math.clamp(num, 1, 10000)/1000
            else
                TargetTime = math.clamp(num, 0.01, 10)
            end
            TimeInput.Text = tostring(num)
        else
            TimeInput.Text = tostring(TargetTime * (TimeUnit == "MICROSECONDS" and 1000000 or TimeUnit == "MILLISECONDS" and 1000 or 1))
        end
    end)
    
    PowerInput.FocusLost:Connect(function()
        local num = tonumber(PowerInput.Text)
        if num then
            FlingPower = math.clamp(num, 1000, 20000)
            PowerInput.Text = tostring(FlingPower)
        else
            PowerInput.Text = tostring(FlingPower)
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)
    
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = newPos
            GuiPosition = newPos
        end
    end)
    
    Title.Parent = TitleBar
    CloseButton.Parent = TitleBar
    TitleBar.Parent = MainFrame
    TopBar.Parent = MainFrame
    KeybindButton.Parent = MainFrame
    TimeInput.Parent = MainFrame
    UnitButton.Parent = MainFrame
    PowerInput.Parent = MainFrame
    ModeButton.Parent = MainFrame
    TargetModeButton.Parent = MainFrame
    JumpToggle.Parent = MainFrame
    StatusLabel.Parent = MainFrame
    Credits.Parent = MainFrame
    MainFrame.Parent = Gui
    Gui.Parent = game:GetService("CoreGui")
    
    local tweenIn = TweenService:Create(MainFrame, TweenInfo.new(0.2), {Position = GuiPosition})
    MainFrame.Position = UDim2.new(GuiPosition.X.Scale, GuiPosition.X.Offset, GuiPosition.Y.Scale, -500)
    tweenIn:Play()
end

local function GetOptimalTargets()
    local AllPlayers = Players:GetPlayers()
    local ValidPlayers = {}
    local LocalPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    
    for _, Player in pairs(AllPlayers) do
        if Player ~= LocalPlayer and Player.Character then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if Humanoid and HRP and Humanoid.Health > 0 then
                if LocalPos then
                    local dist = (HRP.Position - LocalPos).Magnitude
                    table.insert(ValidPlayers, {Player = Player, Distance = dist})
                else
                    table.insert(ValidPlayers, {Player = Player, Distance = 0})
                end
            end
        end
    end
    
    table.sort(ValidPlayers, function(a, b) return a.Distance < b.Distance end)
    
    if TargetMode == "MULTI" and #ValidPlayers > 1 then
        return {ValidPlayers[1].Player, ValidPlayers[2].Player}
    elseif #ValidPlayers > 0 then
        return {ValidPlayers[1].Player}
    end
    return {}
end

local function CalculateFlingVelocity(targetPos)
    local vel
    if FlingMode == "CHAOTIC" then
        vel = Vector3.new(
            math.random(-FlingPower, FlingPower),
            math.random(-FlingPower/2, FlingPower),
            math.random(-FlingPower, FlingPower)
        )
    elseif FlingMode == "UPWARDS" then
        vel = Vector3.new(
            math.random(-FlingPower/3, FlingPower/3),
            FlingPower,
            math.random(-FlingPower/3, FlingPower/3)
        )
    elseif FlingMode == "DOWNWARDS" then
        vel = Vector3.new(
            math.random(-FlingPower/3, FlingPower/3),
            -FlingPower,
            math.random(-FlingPower/3, FlingPower/3)
        )
    else
        local dir = (targetPos - LocalPlayer.Character.HumanoidRootPart.Position).Unit
        vel = dir * FlingPower + Vector3.new(0, FlingPower/2, 0)
    end
    return vel
end

local function ExecuteFling(Targets)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local lHRP = LocalPlayer.Character.HumanoidRootPart
    local avgPos = Vector3.new(0,0,0)
    local count = 0
    
    for _, Player in pairs(Targets) do
        if Player and Player.Character then
            local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
            if HRP then
                avgPos = avgPos + HRP.Position
                count = count + 1
                local vel = CalculateFlingVelocity(HRP.Position)
                lHRP.CFrame = HRP.CFrame
                lHRP.Velocity = vel
                lHRP.RotVelocity = vel * 0.7
            end
        end
    end
    
    if count > 0 then
        avgPos = avgPos / count
        local vel = CalculateFlingVelocity(avgPos)
        lHRP.Velocity = vel
        lHRP.RotVelocity = vel * 0.7
    end
end

local function SimulateJump()
    if JumpSpam and os.clock() - LastJumpTime >= JumpInterval then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        LastJumpTime = os.clock()
    end
end

UIS.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Keybind then
        Active = not Active
        if Gui and Gui:FindFirstChildOfClass("Frame") then
            local MainFrame = Gui:FindFirstChildOfClass("Frame")
            local KeybindButton = MainFrame:FindFirstChild("KeybindButton")
            local StatusLabel = MainFrame:FindFirstChild("StatusLabel")
            
            if KeybindButton then
                KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(100, 30, 150) or Color3.fromRGB(60, 20, 90)
            end
            if StatusLabel then
                StatusLabel.Text = Active and "STATUS: [ACTIVE]" or "STATUS: [INACTIVE]"
                StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            end
        end
    end
end)

CreateGUI()

RunService.Heartbeat:Connect(function()
    if Active then
        local timeThreshold = TargetTime
        if os.clock() - LastTargetTime >= timeThreshold then
            CurrentTargets = GetOptimalTargets()
            if #CurrentTargets > 0 then
                local names = ""
                for _, target in pairs(CurrentTargets) do
                    names = names..target.Name..", "
                end
                print("TARGETING: "..names:sub(1, -3))
                LastTargetTime = os.clock()
            end
        end
        
        if #CurrentTargets > 0 then
            ExecuteFling(CurrentTargets)
        end
        
        SimulateJump()
    end
end)

print("MOG-FLINGER_V3 LOADED!")
print("THANKS FOR USING!!")
print("https://github.com/MOG-Developing/RBLX-Scripts")