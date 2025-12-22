-- Professional Freecam Script for Roblox Photography
-- Delta Executor Compatible (Mobile & PC)
-- Character stays visible with animations - Only movement blocked

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Detect platform
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Freecam state
local freecamEnabled = false
local freecamConnection

-- Camera settings
local cameraCFrame = CFrame.new()
local cameraFOV = 70
local moveSpeed = 0.5
local rotationSpeed = 0.004
local smoothFactor = 0.25
local minFOV = 5
local maxFOV = 120

-- Movement
local velocity = Vector3.zero
local targetVelocity = Vector3.zero
local moveVector = {
    forward = 0,
    backward = 0,
    left = 0,
    right = 0,
    up = 0,
    down = 0
}

-- Mouse/Touch rotation
local lastMousePosition = Vector2.new()
local rotationX = 0
local rotationY = 0
local isRotating = false

-- Original settings backup
local originalSettings = {
    cameraType = nil,
    cameraSubject = nil,
    character = nil,
    humanoid = nil,
    rootPart = nil,
    rootPartCFrame = nil
}

-- GUI Elements
local screenGui
local controlsFrame
local toggleButton

-- Character position tracking
local characterPositionConnection

-- Create main GUI
local function createMainGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FreecamProGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game:GetService("CoreGui")
    else
        screenGui.Parent = player:WaitForChild("PlayerGui")
    end

    -- Toggle Button (Camera Icon)
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 70, 0, 70)
    toggleButton.Position = UDim2.new(1, -90, 0, 20)
    toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "📷"
    toggleButton.TextSize = 35
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = screenGui
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0.25, 0)
    toggleCorner.Parent = toggleButton
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(100, 100, 100)
    toggleStroke.Thickness = 2
    toggleStroke.Parent = toggleButton
end

-- Create mobile controls
local function createMobileControls()
    if not isMobile then return end
    
    controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "MobileControls"
    controlsFrame.Size = UDim2.new(1, 0, 1, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Visible = false
    controlsFrame.Parent = screenGui

    local buttonSize = UDim2.new(0, 70, 0, 70)
    local buttonAlpha = 0.5
    
    -- Create directional button
    local function createDirButton(name, pos, text, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = buttonSize
        btn.Position = pos
        btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 50)
        btn.BackgroundTransparency = buttonAlpha
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextSize = 28
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = controlsFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.2, 0)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 80, 85)
        stroke.Thickness = 2
        stroke.Transparency = 0.3
        stroke.Parent = btn
        
        return btn
    end

    -- Movement pad (left side)
    local padX = 30
    local padY = 0.65
    local spacing = 80

    local btnW = createDirButton("Forward", UDim2.new(0, padX + spacing, padY, -spacing), "▲")
    local btnS = createDirButton("Backward", UDim2.new(0, padX + spacing, padY, spacing), "▼")
    local btnA = createDirButton("Left", UDim2.new(0, padX, padY, 0), "◄")
    local btnD = createDirButton("Right", UDim2.new(0, padX + spacing * 2, padY, 0), "►")

    -- Up/Down (right side)
    local btnUp = createDirButton("Up", UDim2.new(1, -100, padY, -40), "▲", Color3.fromRGB(50, 100, 50))
    local btnDown = createDirButton("Down", UDim2.new(1, -100, padY, 40), "▼", Color3.fromRGB(100, 50, 50))

    -- Settings panel
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Size = UDim2.new(0, 250, 0, 160)
    settingsPanel.Position = UDim2.new(0.5, -125, 0, 20)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    settingsPanel.BackgroundTransparency = 0.3
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Parent = controlsFrame
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0.15, 0)
    panelCorner.Parent = settingsPanel

    -- Speed control
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -20, 0, 30)
    speedLabel.Position = UDim2.new(0, 10, 0, 10)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: 0.5"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 16
    speedLabel.Font = Enum.Font.GothamMedium
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = settingsPanel

    local speedSlider = Instance.new("Frame")
    speedSlider.Size = UDim2.new(1, -20, 0, 8)
    speedSlider.Position = UDim2.new(0, 10, 0, 45)
    speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    speedSlider.BorderSizePixel = 0
    speedSlider.Parent = settingsPanel
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(1, 0)
    speedCorner.Parent = speedSlider
    
    local speedFill = Instance.new("Frame")
    speedFill.Name = "Fill"
    speedFill.Size = UDim2.new(0.16, 0, 1, 0)
    speedFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    speedFill.BorderSizePixel = 0
    speedFill.Parent = speedSlider
    
    local speedFillCorner = Instance.new("UICorner")
    speedFillCorner.CornerRadius = UDim.new(1, 0)
    speedFillCorner.Parent = speedFill

    -- FOV (Zoom) control
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(1, -20, 0, 30)
    fovLabel.Position = UDim2.new(0, 10, 0, 75)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV: 70 (Zoom)"
    fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovLabel.TextSize = 16
    fovLabel.Font = Enum.Font.GothamMedium
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left
    fovLabel.Parent = settingsPanel

    local fovSlider = Instance.new("Frame")
    fovSlider.Size = UDim2.new(1, -20, 0, 8)
    fovSlider.Position = UDim2.new(0, 10, 0, 110)
    fovSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    fovSlider.BorderSizePixel = 0
    fovSlider.Parent = settingsPanel
    
    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(1, 0)
    fovCorner.Parent = fovSlider
    
    local fovFill = Instance.new("Frame")
    fovFill.Name = "Fill"
    fovFill.Size = UDim2.new(0.565, 0, 1, 0)
    fovFill.BackgroundColor3 = Color3.fromRGB(255, 150, 100)
    fovFill.BorderSizePixel = 0
    fovFill.Parent = fovSlider
    
    local fovFillCorner = Instance.new("UICorner")
    fovFillCorner.CornerRadius = UDim.new(1, 0)
    fovFillCorner.Parent = fovFill

    -- Button interactions
    local function setupButton(btn, key)
        btn.MouseButton1Down:Connect(function()
            moveVector[key] = 1
            btn.BackgroundTransparency = 0.2
        end)
        
        btn.MouseButton1Up:Connect(function()
            moveVector[key] = 0
            btn.BackgroundTransparency = buttonAlpha
        end)
        
        btn.TouchLongPress:Connect(function()
            moveVector[key] = 1
            btn.BackgroundTransparency = 0.2
        end)
    end

    setupButton(btnW, "forward")
    setupButton(btnS, "backward")
    setupButton(btnA, "left")
    setupButton(btnD, "right")
    setupButton(btnUp, "up")
    setupButton(btnDown, "down")

    -- Slider interactions
    local function setupSlider(slider, label, min, max, current, callback)
        local dragging = false
        
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = input.Position
                local sliderPos = slider.AbsolutePosition
                local sliderSize = slider.AbsoluteSize
                
                local relativeX = math.clamp((pos.X - sliderPos.X) / sliderSize.X, 0, 1)
                local value = min + (max - min) * relativeX
                
                slider.Fill.Size = UDim2.new(relativeX, 0, 1, 0)
                callback(value, label)
            end
        end)
    end

    setupSlider(speedSlider, speedLabel, 0.1, 3, moveSpeed, function(val, lbl)
        moveSpeed = val
        lbl.Text = string.format("Speed: %.1f", val)
    end)

    setupSlider(fovSlider, fovLabel, minFOV, maxFOV, cameraFOV, function(val, lbl)
        cameraFOV = val
        if freecamEnabled then
            camera.FieldOfView = val
        end
        local zoomLevel = (maxFOV - val) / (maxFOV - minFOV) * 100
        lbl.Text = string.format("FOV: %d (Zoom: %.0f%%)", math.floor(val), zoomLevel)
    end)
end

-- Block only WASD movement (keep animations/emotes working)
local function blockCharacterMovement()
    local character = player.Character
    if not character then return end
    
    originalSettings.character = character
    originalSettings.rootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- Save original position
    if originalSettings.rootPart then
        originalSettings.rootPartCFrame = originalSettings.rootPart.CFrame
    end
    
    -- Block movement keys only (not animations/emotes)
    ContextActionService:BindAction(
        "BlockMovementKeys",
        function(actionName, inputState, inputObject)
            -- Only block WASD and Space when freecam is active
            if freecamEnabled then
                return Enum.ContextActionResult.Sink
            end
            return Enum.ContextActionResult.Pass
        end,
        false,
        Enum.KeyCode.W,
        Enum.KeyCode.A,
        Enum.KeyCode.S,
        Enum.KeyCode.D,
        Enum.KeyCode.Space
    )
    
    -- Keep character in place by constantly resetting position
    -- But DON'T anchor it (so animations still work)
    characterPositionConnection = RunService.Heartbeat:Connect(function()
        if freecamEnabled and originalSettings.rootPart and originalSettings.rootPartCFrame then
            -- Reset position but keep rotation (for emotes that rotate)
            local currentRotation = originalSettings.rootPart.CFrame - originalSettings.rootPart.CFrame.Position
            originalSettings.rootPart.CFrame = CFrame.new(originalSettings.rootPartCFrame.Position) * currentRotation
            
            -- Keep velocity at zero to prevent any movement
            originalSettings.rootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

-- Unblock character movement
local function unblockCharacterMovement()
    -- Unbind movement block
    ContextActionService:UnbindAction("BlockMovementKeys")
    
    -- Disconnect position lock
    if characterPositionConnection then
        characterPositionConnection:Disconnect()
        characterPositionConnection = nil
    end
end

-- Enable freecam
local function enableFreecam()
    if freecamEnabled then return end
    freecamEnabled = true
    
    -- Save original camera settings
    originalSettings.cameraType = camera.CameraType
    originalSettings.cameraSubject = camera.CameraSubject
    
    -- Set camera to scriptable (detach from character)
    cameraCFrame = camera.CFrame
    rotationX = 0
    rotationY = 0
    
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CameraSubject = nil
    camera.FieldOfView = cameraFOV
    
    -- Block only movement, keep animations working
    blockCharacterMovement()
    
    -- UI updates
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    toggleButton.Text = "📸"
    
    if isMobile and controlsFrame then
        controlsFrame.Visible = true
    end
    
    -- Update loop for freecam
    freecamConnection = RunService.RenderStepped:Connect(function(dt)
        -- Calculate movement direction
        local moveDir = Vector3.new(
            moveVector.right - moveVector.left,
            moveVector.up - moveVector.down,
            moveVector.backward - moveVector.forward
        )
        
        if moveDir.Magnitude > 0 then
            targetVelocity = moveDir.Unit * moveSpeed * 50
        else
            targetVelocity = Vector3.zero
        end
        
        -- Smooth velocity interpolation
        velocity = velocity:Lerp(targetVelocity, smoothFactor)
        
        -- Apply movement to freecam
        local cf = cameraCFrame
        local moveOffset = (cf.RightVector * velocity.X + Vector3.new(0, velocity.Y, 0) + cf.LookVector * velocity.Z) * dt
        cameraCFrame = cf + moveOffset
        
        -- Apply rotation
        cameraCFrame = CFrame.new(cameraCFrame.Position) * CFrame.Angles(rotationY, rotationX, 0)
        
        -- Update camera
        camera.CFrame = cameraCFrame
        camera.FieldOfView = cameraFOV
    end)
end

-- Disable freecam
local function disableFreecam()
    if not freecamEnabled then return end
    freecamEnabled = false
    
    -- Disconnect update loop
    if freecamConnection then
        freecamConnection:Disconnect()
        freecamConnection = nil
    end
    
    -- Restore camera to character
    camera.CameraType = originalSettings.cameraType
    camera.CameraSubject = originalSettings.cameraSubject
    camera.FieldOfView = 70
    
    -- Unblock character movement
    unblockCharacterMovement()
    
    -- Reset movement state
    for k in pairs(moveVector) do
        moveVector[k] = 0
    end
    velocity = Vector3.zero
    targetVelocity = Vector3.zero
    
    -- UI updates
    toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleButton.Text = "📷"
    
    if isMobile and controlsFrame then
        controlsFrame.Visible = false
    end
end

-- Toggle freecam
local function toggleFreecam()
    if freecamEnabled then
        disableFreecam()
    else
        enableFreecam()
    end
end

-- Setup input handling
local function setupInput()
    -- Toggle button
    toggleButton.MouseButton1Click:Connect(toggleFreecam)
    
    -- Keyboard controls (PC only)
    if not isMobile then
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            
            -- Toggle with L key
            if input.KeyCode == Enum.KeyCode.L then
                toggleFreecam()
                return
            end
            
            -- Movement controls (only when freecam is active)
            if freecamEnabled then
                if input.KeyCode == Enum.KeyCode.W then 
                    moveVector.forward = 1
                elseif input.KeyCode == Enum.KeyCode.S then 
                    moveVector.backward = 1
                elseif input.KeyCode == Enum.KeyCode.A then 
                    moveVector.left = 1
                elseif input.KeyCode == Enum.KeyCode.D then 
                    moveVector.right = 1
                elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then 
                    moveVector.up = 1
                elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.Q then 
                    moveVector.down = 1
                elseif input.KeyCode == Enum.KeyCode.LeftControl then
                    moveSpeed = math.min(moveSpeed * 1.5, 3)
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then 
                moveVector.forward = 0
            elseif input.KeyCode == Enum.KeyCode.S then 
                moveVector.backward = 0
            elseif input.KeyCode == Enum.KeyCode.A then 
                moveVector.left = 0
            elseif input.KeyCode == Enum.KeyCode.D then 
                moveVector.right = 0
            elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then 
                moveVector.up = 0
            elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.Q then 
                moveVector.down = 0
            end
        end)
        
        -- Mouse wheel for zoom (FOV adjustment)
        UserInputService.InputChanged:Connect(function(input)
            if not freecamEnabled then return end
            
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                cameraFOV = math.clamp(cameraFOV - input.Position.Z * 5, minFOV, maxFOV)
                camera.FieldOfView = cameraFOV
            end
        end)
    end
    
    -- Mouse/Touch rotation (both platforms)
    UserInputService.InputBegan:Connect(function(input)
        if not freecamEnabled then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton2 or 
           (input.UserInputType == Enum.UserInputType.Touch and isMobile) then
            isRotating = true
            lastMousePosition = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 or 
           input.UserInputType == Enum.UserInputType.Touch then
            isRotating = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not freecamEnabled or not isRotating then return end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            local currentPos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = currentPos - lastMousePosition
            lastMousePosition = currentPos
            
            -- Apply rotation with smooth sensitivity
            rotationX = rotationX - delta.X * rotationSpeed
            rotationY = math.clamp(rotationY - delta.Y * rotationSpeed, -math.pi/2 + 0.01, math.pi/2 - 0.01)
        end
    end)
end

-- Hide controls during screenshot
local function setupScreenshotHandler()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local screenshotHud = game:GetService("CoreGui"):FindFirstChild("ScreenshotHud")
            if screenshotHud then
                screenshotHud.ChildAdded:Connect(function()
                    if controlsFrame then
                        local wasVisible = controlsFrame.Visible
                        controlsFrame.Visible = false
                        toggleButton.Visible = false
                        task.wait(0.5)
                        if freecamEnabled and wasVisible then
                            controlsFrame.Visible = true
                        end
                        toggleButton.Visible = true
                    end
                end)
                connection:Disconnect()
            end
        end)
    end)
end

-- Initialize everything
local function init()
    createMainGUI()
    createMobileControls()
    setupInput()
    setupScreenshotHandler()
    
    -- Print success message
    print("✅ Freecam Photography Mode Loaded!")
    print("📷 Press L (PC) or tap camera icon to toggle")
end

-- Start the script
init()
