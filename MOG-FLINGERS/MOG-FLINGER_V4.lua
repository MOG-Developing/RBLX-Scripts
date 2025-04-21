local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CurrentTargets = {}
local Active = false
local Keybind = Enum.KeyCode.F
local Gui = nil
local TargetTime = 0.01
local TimeUnit = "MICROSECONDS"
local LastTargetTime = 0
local GuiPosition = UDim2.new(0.5, -250, 0.5, -200)
local FlingPower = 15000
local FlingMode = "VORTEX"
local TargetMode = "QUAD"
local JumpSpam = true
local JumpInterval = 0.05
local LastJumpTime = 0

local FLING_MODES = {
    "VORTEX",
    "NUCLEAR",
    "TORNADO",
    "GRAVITY",
    "CHAOTIC",
    "UPWARDS",
    "DOWNWARDS",
    "SHREDDER"
}

local function CreateGUI()
    if Gui then Gui:Destroy() end
    
    Gui = Instance.new("ScreenGui")
    Gui.Name = "MOG_GodModeCheat"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 450)
    MainFrame.Position = GuiPosition
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 0, 25)
    MainFrame.BorderSizePixel = 0
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 5)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
    TopBar.BorderSizePixel = 0
    
    local TitleBar = Instance.new("TextButton")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.Position = UDim2.new(0, 0, 0, 5)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 5, 55)
    TitleBar.BorderSizePixel = 0
    TitleBar.Text = ""
    TitleBar.AutoButtonColor = false
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Text = "MOG GOD MODE CHEAT"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0.5, -17)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBlack
    CloseButton.TextSize = 16
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0.9, 0, 0, 35)
    KeybindButton.Position = UDim2.new(0.05, 0, 0.15, 0)
    KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(120, 30, 180) or Color3.fromRGB(70, 20, 110)
    KeybindButton.TextColor3 = Color3.new(1, 1, 1)
    KeybindButton.Text = "TOGGLE KEY: "..Keybind.Name
    KeybindButton.Font = Enum.Font.GothamBold
    KeybindButton.TextSize = 15
    
    local PowerSlider = Instance.new("Frame")
    PowerSlider.Size = UDim2.new(0.9, 0, 0, 40)
    PowerSlider.Position = UDim2.new(0.05, 0, 0.25, 0)
    PowerSlider.BackgroundTransparency = 1
    
    local PowerLabel = Instance.new("TextLabel")
    PowerLabel.Size = UDim2.new(1, 0, 0.5, 0)
    PowerLabel.Position = UDim2.new(0, 0, 0, 0)
    PowerLabel.BackgroundTransparency = 1
    PowerLabel.TextColor3 = Color3.new(1, 1, 1)
    PowerLabel.Text = "FLING POWER: "..FlingPower
    PowerLabel.Font = Enum.Font.Gotham
    PowerLabel.TextSize = 14
    PowerLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local PowerBar = Instance.new("Frame")
    PowerBar.Size = UDim2.new(1, 0, 0, 10)
    PowerBar.Position = UDim2.new(0, 0, 0.6, 0)
    PowerBar.BackgroundColor3 = Color3.fromRGB(40, 10, 70)
    PowerBar.BorderSizePixel = 0
    
    local PowerFill = Instance.new("Frame")
    PowerFill.Size = UDim2.new((FlingPower-5000)/10000, 0, 1, 0)
    PowerFill.Position = UDim2.new(0, 0, 0, 0)
    PowerFill.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
    PowerFill.BorderSizePixel = 0
    
    local PowerButton = Instance.new("TextButton")
    PowerButton.Size = UDim2.new(1, 0, 1, 0)
    PowerButton.Position = UDim2.new(0, 0, 0, 0)
    PowerButton.BackgroundTransparency = 1
    PowerButton.Text = ""
    
    local ModeButton = Instance.new("TextButton")
    ModeButton.Size = UDim2.new(0.9, 0, 0, 35)
    ModeButton.Position = UDim2.new(0.05, 0, 0.35, 0)
    ModeButton.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
    ModeButton.TextColor3 = Color3.new(1, 1, 1)
    ModeButton.Text = "MODE: "..FlingMode
    ModeButton.Font = Enum.Font.GothamBold
    ModeButton.TextSize = 15
    
    local TargetModeButton = Instance.new("TextButton")
    TargetModeButton.Size = UDim2.new(0.9, 0, 0, 35)
    TargetModeButton.Position = UDim2.new(0.05, 0, 0.45, 0)
    TargetModeButton.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
    TargetModeButton.TextColor3 = Color3.new(1, 1, 1)
    TargetModeButton.Text = "TARGET MODE: "..TargetMode
    TargetModeButton.Font = Enum.Font.GothamBold
    TargetModeButton.TextSize = 15
    
    local JumpToggle = Instance.new("TextButton")
    JumpToggle.Size = UDim2.new(0.9, 0, 0, 35)
    JumpToggle.Position = UDim2.new(0.05, 0, 0.55, 0)
    JumpToggle.BackgroundColor3 = JumpSpam and Color3.fromRGB(120, 30, 180) or Color3.fromRGB(70, 20, 110)
    JumpToggle.TextColor3 = Color3.new(1, 1, 1)
    JumpToggle.Text = "JUMP SPAM: "..(JumpSpam and "ON" or "OFF")
    JumpToggle.Font = Enum.Font.GothamBold
    JumpToggle.TextSize = 15
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 40)
    StatusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    StatusLabel.Text = Active and "STATUS: [GOD MODE ACTIVE]" or "STATUS: [INACTIVE]"
    StatusLabel.Font = Enum.Font.GothamBlack
    StatusLabel.TextSize = 18
    
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
        KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(120, 30, 180) or Color3.fromRGB(70, 20, 110)
        ModeButton.Text = "MODE: "..FlingMode
        TargetModeButton.Text = "TARGET MODE: "..TargetMode
        JumpToggle.Text = "JUMP SPAM: "..(JumpSpam and "ON" or "OFF")
        JumpToggle.BackgroundColor3 = JumpSpam and Color3.fromRGB(120, 30, 180) or Color3.fromRGB(70, 20, 110)
        StatusLabel.Text = Active and "STATUS: [GOD MODE ACTIVE]" or "STATUS: [INACTIVE]"
        StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        PowerLabel.Text = "FLING POWER: "..FlingPower
        PowerFill.Size = UDim2.new((FlingPower-5000)/10000, 0, 1, 0)
    end
    
    KeybindButton.MouseButton1Click:Connect(function()
        KeybindButton.Text = "PRESS ANY KEY..."
        local Input = UIS.InputBegan:Wait()
        if Input.UserInputType == Enum.UserInputType.Keyboard then
            Keybind = Input.KeyCode
            UpdateGUI()
        end
    end)
    
    ModeButton.MouseButton1Click:Connect(function()
        local currentIndex = table.find(FLING_MODES, FlingMode) or 1
        FlingMode = FLING_MODES[(currentIndex % #FLING_MODES) + 1]
        UpdateGUI()
    end)
    
    TargetModeButton.MouseButton1Click:Connect(function()
        TargetMode = TargetMode == "SINGLE" and "DUAL" or TargetMode == "DUAL" and "QUAD" or "SINGLE"
        UpdateGUI()
    end)
    
    JumpToggle.MouseButton1Click:Connect(function()
        JumpSpam = not JumpSpam
        UpdateGUI()
    end)
    
    PowerButton.MouseButton1Down:Connect(function()
        local startX = PowerButton.AbsolutePosition.X
        local endX = startX + PowerButton.AbsoluteSize.X
        local connection
        
        connection = UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((input.Position.X - startX) / (endX - startX), 0, 1)
                FlingPower = math.floor(5000 + percent * 10000)
                UpdateGUI()
            end
        end)
        
        local function disconnect()
            connection:Disconnect()
        end
        
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                disconnect()
            end
        end)
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
    
    PowerFill.Parent = PowerBar
    PowerBar.Parent = PowerSlider
    PowerLabel.Parent = PowerSlider
    PowerButton.Parent = PowerSlider
    PowerSlider.Parent = MainFrame
    
    Title.Parent = TitleBar
    CloseButton.Parent = TitleBar
    TitleBar.Parent = MainFrame
    TopBar.Parent = MainFrame
    KeybindButton.Parent = MainFrame
    ModeButton.Parent = MainFrame
    TargetModeButton.Parent = MainFrame
    JumpToggle.Parent = MainFrame
    StatusLabel.Parent = MainFrame
    Credits.Parent = MainFrame
    MainFrame.Parent = Gui
    Gui.Parent = game:GetService("CoreGui")
    
    local tweenIn = TweenService:Create(MainFrame, TweenInfo.new(0.15), {Position = GuiPosition})
    MainFrame.Position = UDim2.new(GuiPosition.X.Scale, GuiPosition.X.Offset, GuiPosition.Y.Scale, -600)
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
    
    if TargetMode == "QUAD" and #ValidPlayers >= 4 then
        return {
            ValidPlayers[1].Player,
            ValidPlayers[2].Player,
            ValidPlayers[3].Player,
            ValidPlayers[4].Player
        }
    elseif TargetMode == "DUAL" and #ValidPlayers >= 2 then
        return {
            ValidPlayers[1].Player,
            ValidPlayers[2].Player
        }
    elseif #ValidPlayers > 0 then
        return {ValidPlayers[1].Player}
    end
    return {}
end

local function CalculateFlingVelocity(targetPos)
    local vel
    local powerMultiplier = 1 + (FlingPower - 5000) / 10000
    
    if FlingMode == "VORTEX" then
        local dir = (targetPos - LocalPlayer.Character.HumanoidRootPart.Position).Unit
        vel = dir * FlingPower * 0.7 + Vector3.new(
            math.sin(os.clock() * 20) * FlingPower * 0.5,
            FlingPower * 0.3,
            math.cos(os.clock() * 20) * FlingPower * 0.5
        )
    elseif FlingMode == "NUCLEAR" then
        vel = Vector3.new(
            math.random(-FlingPower, FlingPower) * powerMultiplier,
            math.random(FlingPower/2, FlingPower) * powerMultiplier,
            math.random(-FlingPower, FlingPower) * powerMultiplier
        )
    elseif FlingMode == "TORNADO" then
        vel = Vector3.new(
            math.sin(os.clock() * 15) * FlingPower,
            FlingPower * 0.7,
            math.cos(os.clock() * 15) * FlingPower
        )
    elseif FlingMode == "GRAVITY" then
        local dir = (targetPos - LocalPlayer.Character.HumanoidRootPart.Position).Unit
        vel = -dir * FlingPower * 1.5
    elseif FlingMode == "SHREDDER" then
        vel = Vector3.new(
            math.random(-FlingPower, FlingPower),
            math.random(-FlingPower, FlingPower),
            math.random(-FlingPower, FlingPower)
        )
    elseif FlingMode == "UPWARDS" then
        vel = Vector3.new(0, FlingPower * 1.5, 0)
    elseif FlingMode == "DOWNWARDS" then
        vel = Vector3.new(0, -FlingPower * 1.5, 0)
    else -- CHAOTIC
        vel = Vector3.new(
            math.random(-FlingPower, FlingPower) * 1.5,
            math.random(-FlingPower, FlingPower) * 1.5,
            math.random(-FlingPower, FlingPower) * 1.5
        )
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
                lHRP.RotVelocity = vel * 1.2
            end
        end
    end
    
    if count > 0 then
        avgPos = avgPos / count
        local vel = CalculateFlingVelocity(avgPos)
        lHRP.Velocity = vel
        lHRP.RotVelocity = vel * 1.2
    end
end

local function SimulateJump()
    if JumpSpam and os.clock() - LastJumpTime >= JumpInterval then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            LastJumpTime = os.clock()
        end
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
                KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(120, 30, 180) or Color3.fromRGB(70, 20, 110)
            end
            if StatusLabel then
                StatusLabel.Text = Active and "STATUS: [GOD MODE ACTIVE]" or "STATUS: [INACTIVE]"
                StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            end
        end
    end
end)

CreateGUI()

RunService.Heartbeat:Connect(function()
    if Active then
        CurrentTargets = GetOptimalTargets()
        if #CurrentTargets > 0 then
            local names = ""
            for _, target in pairs(CurrentTargets) do
                names = names..target.Name..", "
            end
            print("TARGETING: "..names:sub(1, -3))
            ExecuteFling(CurrentTargets)
        end
        
        SimulateJump()
    end
end)