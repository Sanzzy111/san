-- Roblox Freecam Script for Delta Executor (Mobile & PC)
-- Smooth movement with touch controls and keyboard support
-- Freecam By Shann

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Freecam Settings
local freecamEnabled = false
local freecamCFrame = CFrame.new()
local moveSpeed = 1
local smoothness = 0.15
local targetVelocity = Vector3.new()
local currentVelocity = Vector3.new()

-- Movement state
local moveState = {
    forward = false,
    backward = false,
    left = false,
    right = false,
    up = false,
    down = false
}

-- GUI Variables
local screenGui
local mobileControls
local freecamButton

-- Original camera settings
local originalCameraType
local originalCameraCFrame

-- Create GUI
local function createGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FreecamGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = player:WaitForChild("PlayerGui")
    end

    -- Freecam Toggle Button (Always visible)
    freecamButton = Instance.new("ImageButton")
    freecamButton.Name = "FreecamToggle"
    freecamButton.Size = UDim2.new(0, 60, 0, 60)
    freecamButton.Position = UDim2.new(1, -80, 0, 20)
    freecamButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    freecamButton.BackgroundTransparency = 0.3
    freecamButton.BorderSizePixel = 0
    freecamButton.Parent = screenGui
    
    local freecamCorner = Instance.new("UICorner")
    freecamCorner.CornerRadius = UDim.new(0.3, 0)
    freecamCorner.Parent = freecamButton
    
    local freecamIcon = Instance.new("TextLabel")
    freecamIcon.Size = UDim2.new(1, 0, 1, 0)
    freecamIcon.BackgroundTransparency = 1
    freecamIcon.Text = "📷"
    freecamIcon.TextSize = 30
    freecamIcon.Font = Enum.Font.SourceSansBold
    freecamIcon.Parent = freecamButton

    -- Mobile Controls Container
    mobileControls = Instance.new("Frame")
    mobileControls.Name = "MobileControls"
    mobileControls.Size = UDim2.new(1, 0, 1, 0)
    mobileControls.BackgroundTransparency = 1
    mobileControls.Visible = false
    mobileControls.Parent = screenGui

    -- WASD Buttons (Left side)
    local buttonSize = UDim2.new(0, 60, 0, 60)
    local buttonOffset = 70

    local function createButton(name, position, text, color)
        local button = Instance.new("ImageButton")
        button.Name = name
        button.Size = buttonSize
        button.Position = position
        button.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
        button.BackgroundTransparency = 0.4
        button.BorderSizePixel = 0
        button.Parent = mobileControls
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.2, 0)
        corner.Parent = button
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextSize = 24
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.SourceSansBold
        label.Parent = button
        
        return button
    end

    -- WASD Layout
    local centerX = 100
    local centerY = 0.7
    
    local wButton = createButton("Forward", UDim2.new(0, centerX, centerY, -buttonOffset), "W")
    local aButton = createButton("Left", UDim2.new(0, centerX - buttonOffset, centerY, 0), "A")
    local sButton = createButton("Backward", UDim2.new(0, centerX, centerY, buttonOffset), "S")
    local dButton = createButton("Right", UDim2.new(0, centerX + buttonOffset, centerY, 0), "D")

    -- Up/Down Buttons (Right side)
    local upDownX = -100
    local upButton = createButton("Up", UDim2.new(1, upDownX, centerY, -buttonOffset/2), "↑", Color3.fromRGB(60, 120, 60))
    local downButton = createButton("Down", UDim2.new(1, upDownX, centerY, buttonOffset/2), "↓", Color3.fromRGB(120, 60, 60))

    -- Zoom Buttons (Top right)
    local zoomInButton = createButton("ZoomIn", UDim2.new(1, -180, 0, 100), "+", Color3.fromRGB(70, 70, 100))
    local zoomOutButton = createButton("ZoomOut", UDim2.new(1, -100, 0, 100), "-", Color3.fromRGB(70, 70, 100))

    -- Speed Label
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 150, 0, 30)
    speedLabel.Position = UDim2.new(0.5, -75, 0, 20)
    speedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    speedLabel.BackgroundTransparency = 0.3
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.Text = "Speed: 1.0x"
    speedLabel.TextSize = 18
    speedLabel.Font = Enum.Font.SourceSansBold
    speedLabel.Parent = mobileControls
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0.3, 0)
    speedCorner.Parent = speedLabel

    -- Button Events
    local function setupButton(button, key)
        button.MouseButton1Down:Connect(function()
            moveState[key] = true
            button.BackgroundTransparency = 0.1
        end)
        
        button.MouseButton1Up:Connect(function()
            moveState[key] = false
            button.BackgroundTransparency = 0.4
        end)
    end

    setupButton(wButton, "forward")
    setupButton(aButton, "left")
    setupButton(sButton, "backward")
    setupButton(dButton, "right")
    setupButton(upButton, "up")
    setupButton(downButton, "down")

    -- Zoom Buttons
    zoomInButton.MouseButton1Down:Connect(function()
        moveSpeed = math.min(moveSpeed + 0.2, 5)
        speedLabel.Text = "Speed: " .. string.format("%.1f", moveSpeed) .. "x"
    end)
    
    zoomOutButton.MouseButton1Down:Connect(function()
        moveSpeed = math.max(moveSpeed - 0.2, 0.2)
        speedLabel.Text = "Speed: " .. string.format("%.1f", moveSpeed) .. "x"
    end)

    return speedLabel
end

-- Enable Freecam
local function enableFreecam()
    if freecamEnabled then return end
    freecamEnabled = true
    
    originalCameraType = camera.CameraType
    originalCameraCFrame = camera.CFrame
    freecamCFrame = camera.CFrame
    
    camera.CameraType = Enum.CameraType.Custom
    
    if isMobile then
        mobileControls.Visible = true
    end
    
    -- Visual feedback
    freecamButton.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
    
    -- Hide character
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.LocalTransparencyModifier = 1
            end
        end
    end
end

-- Disable Freecam
local function disableFreecam()
    if not freecamEnabled then return end
    freecamEnabled = false
    
    camera.CameraType = originalCameraType
    camera.CFrame = originalCameraCFrame
    
    if isMobile then
        mobileControls.Visible = false
    end
    
    freecamButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    -- Reset movement
    moveState = {
        forward = false,
        backward = false,
        left = false,
        right = false,
        up = false,
        down = false
    }
    currentVelocity = Vector3.new()
    targetVelocity = Vector3.new()
    
    -- Show character
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

-- Toggle Freecam
local function toggleFreecam()
    if freecamEnabled then
        disableFreecam()
    else
        enableFreecam()
    end
end

-- Setup Controls
local function setupControls()
    -- Freecam button click
    freecamButton.MouseButton1Click:Connect(toggleFreecam)
    
    -- Keyboard Controls (PC)
    if not isMobile then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.L then
                toggleFreecam()
            elseif freecamEnabled then
                if input.KeyCode == Enum.KeyCode.W then
                    moveState.forward = true
                elseif input.KeyCode == Enum.KeyCode.S then
                    moveState.backward = true
                elseif input.KeyCode == Enum.KeyCode.A then
                    moveState.left = true
                elseif input.KeyCode == Enum.KeyCode.D then
                    moveState.right = true
                elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
                    moveState.up = true
                elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftShift then
                    moveState.down = true
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                moveState.forward = false
            elseif input.KeyCode == Enum.KeyCode.S then
                moveState.backward = false
            elseif input.KeyCode == Enum.KeyCode.A then
                moveState.left = false
            elseif input.KeyCode == Enum.KeyCode.D then
                moveState.right = false
            elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
                moveState.up = false
            elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftShift then
                moveState.down = false
            end
        end)
        
        -- Mouse wheel for speed
        UserInputService.InputChanged:Connect(function(input)
            if freecamEnabled and input.UserInputType == Enum.UserInputType.MouseWheel then
                moveSpeed = math.clamp(moveSpeed + input.Position.Z * 0.3, 0.2, 5)
            end
        end)
    end
end

-- Update Freecam
local function updateFreecam(dt)
    if not freecamEnabled then return end
    
    -- Calculate target velocity
    local move = Vector3.new()
    
    if moveState.forward then move = move + Vector3.new(0, 0, -1) end
    if moveState.backward then move = move + Vector3.new(0, 0, 1) end
    if moveState.left then move = move + Vector3.new(-1, 0, 0) end
    if moveState.right then move = move + Vector3.new(1, 0, 0) end
    if moveState.up then move = move + Vector3.new(0, 1, 0) end
    if moveState.down then move = move + Vector3.new(0, -1, 0) end
    
    if move.Magnitude > 0 then
        move = move.Unit
    end
    
    targetVelocity = move * moveSpeed * 50
    
    -- Smooth velocity interpolation
    currentVelocity = currentVelocity:Lerp(targetVelocity, smoothness)
    
    -- Apply movement
    local cameraCFrame = freecamCFrame
    local moveVector = (cameraCFrame.RightVector * currentVelocity.X + 
                       Vector3.new(0, currentVelocity.Y, 0) + 
                       cameraCFrame.LookVector * currentVelocity.Z) * dt
    
    freecamCFrame = cameraCFrame + moveVector
    camera.CFrame = freecamCFrame
end

-- Hide GUI during screenshot
local function setupScreenshotHandler()
    local ScreenshotHud = game:GetService("CoreGui"):FindFirstChild("ScreenshotHud")
    if ScreenshotHud then
        ScreenshotHud.ChildAdded:Connect(function()
            if mobileControls then
                mobileControls.Visible = false
            end
            wait(0.1)
            if freecamEnabled and isMobile then
                mobileControls.Visible = true
            end
        end)
    end
end

-- Main Initialization
local function init()
    local speedLabel = createGUI()
    setupControls()
    setupScreenshotHandler()
    
    -- Update loop
    RunService.RenderStepped:Connect(function(dt)
        updateFreecam(dt)
    end)
    
    -- Mouse movement for camera rotation
    UserInputService.InputChanged:Connect(function(input)
        if not freecamEnabled then return end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Delta
            local sensitivity = 0.005
            
            local rotation = freecamCFrame:ToEulerAnglesYXZ()
            local yaw = rotation - delta.X * sensitivity
            local pitch = math.clamp(rotation - delta.Y * sensitivity, -math.pi/2 + 0.1, math.pi/2 - 0.1)
            
            freecamCFrame = CFrame.new(freecamCFrame.Position) * 
                           CFrame.Angles(0, yaw, 0) * 
                           CFrame.Angles(pitch, 0, 0)
        end
    end)
    
    print("Freecam Script Loaded!")
    print("Press L (PC) or tap camera icon to toggle freecam")
end

-- Run
init()
