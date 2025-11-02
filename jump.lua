-- Custom Tombol Jump Bawaan Roblox untuk Delta Executor
-- Script ini memodifikasi tombol jump default Roblox

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variabel konfigurasi
local config = {
    size = 70,
    xPos = 85,
    yPos = 70,
}

-- Fungsi untuk menemukan tombol jump bawaan
local function findJumpButton()
    local touchGui = playerGui:FindFirstChild("TouchGui")
    if touchGui then
        local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
        if touchControlFrame then
            local jumpButton = touchControlFrame:FindFirstChild("JumpButton")
            return jumpButton
        end
    end
    return nil
end

-- Fungsi untuk membuat GUI pengaturan
local function createSettingsGUI()
    -- ScreenGui untuk settings
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JumpButtonCustomizer"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Settings Button (Icon)
    local settingsButton = Instance.new("ImageButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(0, 45, 0, 45)
    settingsButton.Position = UDim2.new(0.85, 0, 0.6, 0)
    settingsButton.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    settingsButton.BackgroundTransparency = 0.3
    settingsButton.BorderSizePixel = 0
    settingsButton.Parent = screenGui
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0.25, 0)
    settingsCorner.Parent = settingsButton
    
    -- Icon Settings (⚙)
    local settingsIcon = Instance.new("TextLabel")
    settingsIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
    settingsIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    settingsIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsIcon.BackgroundTransparency = 1
    settingsIcon.Text = "⚙"
    settingsIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsIcon.TextScaled = true
    settingsIcon.Font = Enum.Font.GothamBold
    settingsIcon.Parent = settingsButton
    
    -- Settings Frame (Panel)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsPanel"
    settingsFrame.Size = UDim2.new(0, 320, 0, 0)
    settingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    settingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Visible = false
    settingsFrame.ClipsDescendants = true
    settingsFrame.Parent = screenGui
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0.04, 0)
    frameCorner.Parent = settingsFrame
    
    -- Stroke untuk border
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(60, 60, 60)
    frameStroke.Thickness = 2
    frameStroke.Parent = settingsFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 55)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    header.BorderSizePixel = 0
    header.Parent = settingsFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0.04, 0)
    headerCorner.Parent = header
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(0.7, 0, 1, 0)
    headerTitle.Position = UDim2.new(0, 20, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Jump Button Settings"
    headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextSize = 17
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -45, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(0, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.BorderSizePixel = 0
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0.25, 0)
    closeCorner.Parent = closeButton
    
    -- Fungsi untuk membuat slider
    local function createSlider(name, labelText, unit, minVal, maxVal, defaultVal, yPos, callback)
        local container = Instance.new("Frame")
        container.Name = name
        container.Size = UDim2.new(0.88, 0, 0, 65)
        container.Position = UDim2.new(0.06, 0, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = settingsFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 22)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "ValueLabel"
        valueLabel.Size = UDim2.new(0, 60, 0, 22)
        valueLabel.Position = UDim2.new(1, -60, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(defaultVal) .. unit
        valueLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 15
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = container
        
        -- Slider background
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 6)
        sliderBg.Position = UDim2.new(0, 0, 0, 35)
        sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = container
        
        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(1, 0)
        sliderBgCorner.Parent = sliderBg
        
        -- Slider fill
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "Fill"
        sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = sliderFill
        
        -- Slider button (handle)
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 22, 0, 22)
        sliderButton.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -11, 0.5, -11)
        sliderButton.AnchorPoint = Vector2.new(0, 0)
        sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderButton.Text = ""
        sliderButton.BorderSizePixel = 0
        sliderButton.AutoButtonColor = false
        sliderButton.Parent = sliderBg
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = sliderButton
        
        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Color = Color3.fromRGB(100, 180, 255)
        buttonStroke.Thickness = 2
        buttonStroke.Parent = sliderButton
        
        local dragging = false
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
            sliderButton.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(minVal + (maxVal - minVal) * pos)
                
                sliderButton.Position = UDim2.new(pos, -11, 0.5, -11)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = tostring(value) .. unit
                
                callback(value)
            end
        end)
        
        return container
    end
    
    -- Membuat sliders
    createSlider("SizeSlider", "Size", "px", 50, 150, config.size, 75, function(val)
        config.size = val
        local jumpButton = findJumpButton()
        if jumpButton then
            jumpButton.Size = UDim2.new(0, val, 0, val)
        end
    end)
    
    createSlider("XPosSlider", "X Position", "%", 0, 100, config.xPos, 155, function(val)
        config.xPos = val
        local jumpButton = findJumpButton()
        if jumpButton then
            jumpButton.Position = UDim2.new(config.xPos / 100, 0, config.yPos / 100, 0)
        end
    end)
    
    createSlider("YPosSlider", "Y Position", "%", 0, 100, config.yPos, 235, function(val)
        config.yPos = val
        local jumpButton = findJumpButton()
        if jumpButton then
            jumpButton.Position = UDim2.new(config.xPos / 100, 0, config.yPos / 100, 0)
        end
    end)
    
    -- Toggle settings panel
    local panelOpen = false
    settingsButton.MouseButton1Click:Connect(function()
        panelOpen = not panelOpen
        settingsFrame.Visible = true
        
        if panelOpen then
            settingsFrame:TweenSize(
                UDim2.new(0, 320, 0, 320),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quint,
                0.35,
                true
            )
            -- Rotate icon
            TweenService:Create(settingsIcon, TweenInfo.new(0.35), {Rotation = 180}):Play()
        else
            settingsFrame:TweenSize(
                UDim2.new(0, 320, 0, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quint,
                0.35,
                true,
                function()
                    settingsFrame.Visible = false
                end
            )
            TweenService:Create(settingsIcon, TweenInfo.new(0.35), {Rotation = 0}):Play()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        panelOpen = false
        settingsFrame:TweenSize(
            UDim2.new(0, 320, 0, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quint,
            0.35,
            true,
            function()
                settingsFrame.Visible = false
            end
        )
        TweenService:Create(settingsIcon, TweenInfo.new(0.35), {Rotation = 0}):Play()
    end)
    
    -- Drag functionality untuk settings button
    local dragging = false
    local dragStart, startPos
    local dragDelay = false
    
    settingsButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragDelay = true
            wait(0.2) -- Delay untuk membedakan click dan drag
            if dragDelay then
                dragging = true
                dragStart = input.Position
                startPos = settingsButton.Position
            end
        end
    end)
    
    settingsButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragDelay = false
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            settingsButton.Position = newPos
        end
    end)
    
    return screenGui
end

-- Fungsi untuk apply custom ke jump button
local function customizeJumpButton()
    local jumpButton = findJumpButton()
    
    if jumpButton then
        -- Apply custom settings
        jumpButton.Size = UDim2.new(0, config.size, 0, config.size)
        jumpButton.Position = UDim2.new(config.xPos / 100, 0, config.yPos / 100, 0)
        
        print("✓ Tombol jump bawaan Roblox berhasil di-custom!")
        return true
    else
        warn("⚠ Tombol jump belum ditemukan, mencoba lagi...")
        return false
    end
end

-- Main execution
local function initialize()
    -- Tunggu hingga TouchGui loaded
    local attempt = 0
    local maxAttempts = 20
    
    repeat
        wait(0.5)
        attempt = attempt + 1
        local success = customizeJumpButton()
        if success then
            break
        end
    until attempt >= maxAttempts
    
    -- Buat GUI settings
    createSettingsGUI()
    
    -- Monitor jika player respawn
    player.CharacterAdded:Connect(function()
        wait(2)
        customizeJumpButton()
    end)
    
    print("✓ Jump Button Customizer aktif!")
end

-- Jalankan script
initialize()
