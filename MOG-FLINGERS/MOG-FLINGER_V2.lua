local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CurrentTarget = nil
local Active = false
local Keybind = Enum.KeyCode.F
local Gui = nil
local TargetTime = 1
local TimeUnit = "SECONDS"
local LastTargetTime = 0
local GuiPosition = UDim2.new(0.5, -200, 0.5, -150)
local FlingPower = 5000
local FlingMode = "CHAOTIC"
local ToggleState = false

local function CreateGUI()
    if Gui then Gui:Destroy() end
    
    Gui = Instance.new("ScreenGui")
    Gui.Name = "MOG-FLINGER_V2"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 350)
    MainFrame.Position = GuiPosition
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 5, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 5)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
    TopBar.BorderSizePixel = 0
    
    local TitleBar = Instance.new("TextButton")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 5)
    TitleBar.BackgroundColor3 = Color3.fromRGB(50, 20, 70)
    TitleBar.BorderSizePixel = 0
    TitleBar.Text = ""
    TitleBar.AutoButtonColor = false
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Text = "MOG-FLINGER_V2"
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
    KeybindButton.Size = UDim2.new(0.9, 0, 0, 35)
    KeybindButton.Position = UDim2.new(0.05, 0, 0.15, 0)
    KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(90, 40, 120) or Color3.fromRGB(70, 30, 100)
    KeybindButton.TextColor3 = Color3.new(1, 1, 1)
    KeybindButton.Text = "TOGGLE KEY: "..Keybind.Name
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.TextSize = 16
    
    local TimeInput = Instance.new("TextBox")
    TimeInput.Size = UDim2.new(0.4, 0, 0, 35)
    TimeInput.Position = UDim2.new(0.05, 0, 0.3, 0)
    TimeInput.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
    TimeInput.TextColor3 = Color3.new(1, 1, 1)
    TimeInput.Text = tostring(TargetTime)
    TimeInput.Font = Enum.Font.Gotham
    TimeInput.TextSize = 16
    TimeInput.PlaceholderText = "Time value"
    TimeInput.ClearTextOnFocus = false
    
    local UnitButton = Instance.new("TextButton")
    UnitButton.Size = UDim2.new(0.45, 0, 0, 35)
    UnitButton.Position = UDim2.new(0.5, 0, 0.3, 0)
    UnitButton.BackgroundColor3 = Color3.fromRGB(60, 25, 90)
    UnitButton.TextColor3 = Color3.new(1, 1, 1)
    UnitButton.Text = "UNIT: "..TimeUnit
    UnitButton.Font = Enum.Font.Gotham
    UnitButton.TextSize = 16
    
    local PowerInput = Instance.new("TextBox")
    PowerInput.Size = UDim2.new(0.9, 0, 0, 35)
    PowerInput.Position = UDim2.new(0.05, 0, 0.45, 0)
    PowerInput.BackgroundColor3 = Color3.fromRGB(40, 15, 60)
    PowerInput.TextColor3 = Color3.new(1, 1, 1)
    PowerInput.Text = tostring(FlingPower)
    PowerInput.Font = Enum.Font.Gotham
    PowerInput.TextSize = 16
    PowerInput.PlaceholderText = "Fling power (1000-10000)"
    
    local ModeButton = Instance.new("TextButton")
    ModeButton.Size = UDim2.new(0.9, 0, 0, 35)
    ModeButton.Position = UDim2.new(0.05, 0, 0.6, 0)
    ModeButton.BackgroundColor3 = Color3.fromRGB(60, 25, 90)
    ModeButton.TextColor3 = Color3.new(1, 1, 1)
    ModeButton.Text = "MODE: "..FlingMode
    ModeButton.Font = Enum.Font.Gotham
    ModeButton.TextSize = 16
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    StatusLabel.Text = Active and "STATUS: ACTIVE" or "STATUS: INACTIVE"
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 18
    
    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(1, 0, 0, 20)
    Credits.Position = UDim2.new(0, 0, 1, -20)
    Credits.BackgroundTransparency = 1
    Credits.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    Credits.Text = "By @misterofgames_yt | MOG-Development"
    Credits.Font = Enum.Font.Gotham
    Credits.TextSize = 14
    
    local function UpdateGUI()
        KeybindButton.Text = "TOGGLE KEY: "..Keybind.Name
        KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(90, 40, 120) or Color3.fromRGB(70, 30, 100)
        UnitButton.Text = "UNIT: "..TimeUnit
        ModeButton.Text = "MODE: "..FlingMode
        StatusLabel.Text = Active and "STATUS: ACTIVE" or "STATUS: INACTIVE"
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
        TimeUnit = TimeUnit == "SECONDS" and "MILLISECONDS" or "SECONDS"
        UpdateGUI()
    end)
    
    ModeButton.MouseButton1Click:Connect(function()
        FlingMode = FlingMode == "CHAOTIC" and "UPWARDS" or FlingMode == "UPWARDS" and "DOWNWARDS" or "CHAOTIC"
        UpdateGUI()
    end)
    
    TimeInput.FocusLost:Connect(function()
        local num = tonumber(TimeInput.Text)
        if num then
            TargetTime = math.clamp(num, 0.1, TimeUnit == "SECONDS" and 10 or 10000)
            TimeInput.Text = tostring(TargetTime)
        else
            TimeInput.Text = tostring(TargetTime)
        end
    end)
    
    PowerInput.FocusLost:Connect(function()
        local num = tonumber(PowerInput.Text)
        if num then
            FlingPower = math.clamp(num, 1000, 10000)
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
    StatusLabel.Parent = MainFrame
    Credits.Parent = MainFrame
    MainFrame.Parent = Gui
    Gui.Parent = game:GetService("CoreGui")
    
    local tweenIn = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Position = GuiPosition})
    MainFrame.Position = UDim2.new(GuiPosition.X.Scale, GuiPosition.X.Offset, GuiPosition.Y.Scale, -400)
    tweenIn:Play()
end

local function GetOptimalTarget()
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
    
    if #ValidPlayers > 0 then
        table.sort(ValidPlayers, function(a, b) return a.Distance < b.Distance end)
        return ValidPlayers[1].Player
    end
    return nil
end

local function CalculateFlingVelocity()
    if FlingMode == "CHAOTIC" then
        return Vector3.new(
            math.random(-FlingPower, FlingPower),
            math.random(-FlingPower, FlingPower),
            math.random(-FlingPower, FlingPower)
        )
    elseif FlingMode == "UPWARDS" then
        return Vector3.new(
            math.random(-FlingPower/2, FlingPower/2),
            FlingPower,
            math.random(-FlingPower/2, FlingPower/2)
        )
    else
        return Vector3.new(
            math.random(-FlingPower/2, FlingPower/2),
            -FlingPower,
            math.random(-FlingPower/2, FlingPower/2)
        )
    end
end

local function ExecuteFling(Player)
    if not Player or not Player.Character then return end
    local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local lHRP = LocalPlayer.Character.HumanoidRootPart
        local vel = CalculateFlingVelocity()
        
        lHRP.CFrame = HRP.CFrame
        lHRP.Velocity = vel
        lHRP.RotVelocity = vel * 0.5
    end
end

UIS.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Keybind then
        Active = not Active
        ToggleState = not ToggleState
        
        if Gui and Gui:FindFirstChildOfClass("Frame") then
            local MainFrame = Gui:FindFirstChildOfClass("Frame")
            local KeybindButton = MainFrame:FindFirstChildOfClass("TextButton")
            local StatusLabel = MainFrame:FindFirstChildOfClass("TextLabel")
            
            if KeybindButton then
                KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(90, 40, 120) or Color3.fromRGB(70, 30, 100)
            end
            if StatusLabel then
                StatusLabel.Text = Active and "STATUS: ACTIVE" or "STATUS: INACTIVE"
                StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            end
        end
    end
end)

CreateGUI()

RunService.Heartbeat:Connect(function()
    if Active then
        local timeThreshold = TimeUnit == "SECONDS" and TargetTime or TargetTime/1000
        if os.clock() - LastTargetTime >= timeThreshold then
            CurrentTarget = GetOptimalTarget()
            if CurrentTarget then
                print("TARGETING: "..CurrentTarget.Name)
                LastTargetTime = os.clock()
            end
        end
        
        if CurrentTarget then
            ExecuteFling(CurrentTarget)
        end
    end
end)

print("MOG-FLINGER_V2 LOADED!")
print("THANKS FOR USING!!")
print("https://github.com/MOG-Developing/RBLX-Scripts")