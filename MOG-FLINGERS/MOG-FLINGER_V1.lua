local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CurrentTarget = nil
local Active = false
local Keybind = Enum.KeyCode.F
local Gui = nil
local TargetTime = 3
local LastTargetTime = 0
local GuiPosition = UDim2.new(0.5, -175, 0.5, -125)

local function CreateGUI()
    if Gui then Gui:Destroy() end
    
    Gui = Instance.new("ScreenGui")
    Gui.Name = "MOG-FLINGER_V1"
    Gui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 250)
    MainFrame.Position = GuiPosition
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 40)
    MainFrame.BorderSizePixel = 0
    
    local TitleBar = Instance.new("TextButton")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(50, 20, 60)
    TitleBar.BorderSizePixel = 0
    TitleBar.Text = ""
    TitleBar.AutoButtonColor = false
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Text = "MOG-FLINGER_V1"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0.8, 0, 0, 40)
    KeybindButton.Position = UDim2.new(0.1, 0, 0.25, 0)
    KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(90, 40, 110) or Color3.fromRGB(70, 30, 90)
    KeybindButton.TextColor3 = Color3.new(1, 1, 1)
    KeybindButton.Text = "Toggle Key: "..Keybind.Name
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.TextSize = 16
    
    local TimeButton = Instance.new("TextButton")
    TimeButton.Size = UDim2.new(0.8, 0, 0, 40)
    TimeButton.Position = UDim2.new(0.1, 0, 0.55, 0)
    TimeButton.BackgroundColor3 = Color3.fromRGB(70, 30, 90)
    TimeButton.TextColor3 = Color3.new(1, 1, 1)
    TimeButton.Text = "Target Time: "..TargetTime.."s"
    TimeButton.Font = Enum.Font.Gotham
    TimeButton.TextSize = 16
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.8, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    StatusLabel.Text = Active and "ACTIVE" or "INACTIVE"
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
    
    KeybindButton.MouseButton1Click:Connect(function()
        KeybindButton.Text = "Press any key..."
        local Input = UIS.InputBegan:Wait()
        if Input.UserInputType == Enum.UserInputType.Keyboard then
            Keybind = Input.KeyCode
            KeybindButton.Text = "Toggle Key: "..Keybind.Name
        end
    end)
    
    TimeButton.MouseButton1Click:Connect(function()
        TargetTime = TargetTime == 3 and 5 or TargetTime == 5 and 10 or 3
        TimeButton.Text = "Target Time: "..TargetTime.."s"
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
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            GuiPosition = MainFrame.Position
        end
    end)
    
    Title.Parent = TitleBar
    TitleBar.Parent = MainFrame
    KeybindButton.Parent = MainFrame
    TimeButton.Parent = MainFrame
    StatusLabel.Parent = MainFrame
    Credits.Parent = MainFrame
    MainFrame.Parent = Gui
    Gui.Parent = game:GetService("CoreGui")
end

local function GetBestPlayer()
    local AllPlayers = Players:GetPlayers()
    local ValidPlayers = {}
    
    for _, Player in pairs(AllPlayers) do
        if Player ~= LocalPlayer and Player.Character then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if Humanoid and HRP and Humanoid.Health > 0 then
                table.insert(ValidPlayers, Player)
            end
        end
    end
    
    if #ValidPlayers > 0 then
        return ValidPlayers[math.random(1, #ValidPlayers)]
    end
    return nil
end

local function TeleportAndFling(Player)
    if not Player or not Player.Character then return end
    local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Vel = Vector3.new(math.random(4000, 5000), math.random(4000, 5000), math.random(4000, 5000))
        LocalPlayer.Character.HumanoidRootPart.CFrame = HRP.CFrame
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vel
        LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vel
    end
end

UIS.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Keybind then
        Active = not Active
        if Gui and Gui:FindFirstChildOfClass("Frame") then
            local MainFrame = Gui:FindFirstChildOfClass("Frame")
            local KeybindButton = MainFrame:FindFirstChildOfClass("TextButton")
            local StatusLabel = MainFrame:FindFirstChildOfClass("TextLabel")
            
            if KeybindButton then
                KeybindButton.BackgroundColor3 = Active and Color3.fromRGB(90, 40, 110) or Color3.fromRGB(70, 30, 90)
            end
            if StatusLabel then
                StatusLabel.Text = Active and "ACTIVE" or "INACTIVE"
                StatusLabel.TextColor3 = Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    end
end)

CreateGUI()

RunService.Heartbeat:Connect(function()
    if Active then
        if os.clock() - LastTargetTime >= TargetTime then
            CurrentTarget = GetBestPlayer()
            if CurrentTarget then
                print("Targeting: "..CurrentTarget.Name)
                LastTargetTime = os.clock()
            end
        end
        
        if CurrentTarget then
            TeleportAndFling(CurrentTarget)
        end
    end
end)

print("MOG-FLINGER_V1 LOADED!")
print("THANKS FOR USING!!")
print("https://github.com/MOG-Developing/RBLX-Scripts")
