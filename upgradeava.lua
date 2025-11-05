-- AVATAR CHANGER - ADVANCED PRESET SYSTEM
-- Multi-avatar rotation | No rate limits | Cosmic theme
-- Persistent storage | Dynamic preset slots | Smart cooldown

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer

-- State Management
local UIState = {
    isOpen = false,
    isAnimating = false
}

local lastAppliedUsername = nil
local presets = {}
local avatarQueue = {}
local currentAvatarIndex = 1
local isRotating = false
local rotationInterval = 30
local lastRequestTime = 0
local requestCooldown = 3

local PRESET_FILE = "avatar_presets_v2.json"

-- Cosmic Color Palette
local CosmicTheme = {
    background = Color3.fromRGB(15, 15, 25),
    surface = Color3.fromRGB(25, 25, 40),
    primary = Color3.fromRGB(138, 43, 226),
    secondary = Color3.fromRGB(75, 0, 130),
    accent = Color3.fromRGB(186, 85, 211),
    success = Color3.fromRGB(0, 255, 127),
    warning = Color3.fromRGB(255, 140, 0),
    error = Color3.fromRGB(220, 20, 60),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(160, 160, 180)
}

-- Load presets
local function loadPresets()
    if not readfile or not isfile then 
        warn("Executor does not support file operations")
        return 
    end
    
    if isfile(PRESET_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(PRESET_FILE))
        end)
        
        if success and data then
            presets = data
            print("Loaded " .. #presets .. " presets from file")
        end
    end
end

-- Save presets
local function savePresets()
    if not writefile then 
        warn("Executor does not support file writing")
        return 
    end
    
    local success = pcall(function()
        local json = HttpService:JSONEncode(presets)
        writefile(PRESET_FILE, json)
    end)
    
    if success then
        print("Presets saved successfully")
    end
end

-- Toggle Button
local function createToggleButton()
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 40, 0, 40)
    ToggleButton.Position = UDim2.new(0, 15, 0, 15)
    ToggleButton.BackgroundColor3 = CosmicTheme.surface
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "A"
    ToggleButton.TextColor3 = CosmicTheme.accent
    ToggleButton.TextSize = 20
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 10
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0.3, 0)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = CosmicTheme.primary
    ToggleStroke.Thickness = 2
    ToggleStroke.Parent = ToggleButton
    
    return ToggleButton
end

-- Main UI Creation
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AvatarChangerAdvanced"
    ScreenGui.Parent = lp.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local ToggleButton = createToggleButton()
    ToggleButton.Parent = ScreenGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
    MainFrame.BackgroundColor3 = CosmicTheme.background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = CosmicTheme.primary
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = CosmicTheme.surface
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar
    
    local TitleCover = Instance.new("Frame")
    TitleCover.Size = UDim2.new(1, 0, 0, 20)
    TitleCover.Position = UDim2.new(0, 0, 1, -20)
    TitleCover.BackgroundColor3 = CosmicTheme.surface
    TitleCover.BorderSizePixel = 0
    TitleCover.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "AVATAR CHANGER ADVANCED"
    TitleText.TextColor3 = CosmicTheme.accent
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Input Section
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -20, 0, 40)
    InputFrame.Position = UDim2.new(0, 10, 0, 50)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = MainFrame
    
    local UsernameInput = Instance.new("TextBox")
    UsernameInput.Name = "UsernameInput"
    UsernameInput.Size = UDim2.new(0.65, -5, 1, 0)
    UsernameInput.BackgroundColor3 = CosmicTheme.surface
    UsernameInput.BorderSizePixel = 0
    UsernameInput.Text = ""
    UsernameInput.PlaceholderText = "Enter username"
    UsernameInput.PlaceholderColor3 = CosmicTheme.textDim
    UsernameInput.TextColor3 = CosmicTheme.text
    UsernameInput.TextSize = 14
    UsernameInput.Font = Enum.Font.Gotham
    UsernameInput.Parent = InputFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = UsernameInput
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = CosmicTheme.primary
    InputStroke.Thickness = 1
    InputStroke.Transparency = 0.5
    InputStroke.Parent = UsernameInput
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Size = UDim2.new(0.35, -5, 1, 0)
    SubmitButton.Position = UDim2.new(0.65, 0, 0, 0)
    SubmitButton.BackgroundColor3 = CosmicTheme.primary
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "APPLY"
    SubmitButton.TextColor3 = CosmicTheme.text
    SubmitButton.TextSize = 14
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = InputFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitButton
    
    -- Preset Section
    local PresetFrame = Instance.new("ScrollingFrame")
    PresetFrame.Name = "PresetFrame"
    PresetFrame.Size = UDim2.new(1, -20, 0, 280)
    PresetFrame.Position = UDim2.new(0, 10, 0, 100)
    PresetFrame.BackgroundColor3 = CosmicTheme.surface
    PresetFrame.BorderSizePixel = 0
    PresetFrame.ScrollBarThickness = 6
    PresetFrame.ScrollBarImageColor3 = CosmicTheme.primary
    PresetFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PresetFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PresetFrame.Parent = MainFrame
    
    local PresetCorner = Instance.new("UICorner")
    PresetCorner.CornerRadius = UDim.new(0, 12)
    PresetCorner.Parent = PresetFrame
    
    local PresetTitle = Instance.new("TextLabel")
    PresetTitle.Size = UDim2.new(1, -10, 0, 30)
    PresetTitle.Position = UDim2.new(0, 5, 0, 5)
    PresetTitle.BackgroundTransparency = 1
    PresetTitle.Text = "PRESET SLOTS"
    PresetTitle.TextColor3 = CosmicTheme.accent
    PresetTitle.TextSize = 14
    PresetTitle.Font = Enum.Font.GothamBold
    PresetTitle.TextXAlignment = Enum.TextXAlignment.Left
    PresetTitle.Parent = PresetFrame
    
    local PresetList = Instance.new("UIListLayout")
    PresetList.Padding = UDim.new(0, 8)
    PresetList.SortOrder = Enum.SortOrder.LayoutOrder
    PresetList.Parent = PresetFrame
    
    local PresetPadding = Instance.new("UIPadding")
    PresetPadding.PaddingTop = UDim.new(0, 40)
    PresetPadding.PaddingLeft = UDim.new(0, 10)
    PresetPadding.PaddingRight = UDim.new(0, 10)
    PresetPadding.PaddingBottom = UDim.new(0, 10)
    PresetPadding.Parent = PresetFrame
    
    -- Add Preset Button
    local AddPresetBtn = Instance.new("TextButton")
    AddPresetBtn.Name = "AddPresetButton"
    AddPresetBtn.Size = UDim2.new(1, -20, 0, 35)
    AddPresetBtn.BackgroundColor3 = CosmicTheme.secondary
    AddPresetBtn.BorderSizePixel = 0
    AddPresetBtn.Text = "+"
    AddPresetBtn.TextColor3 = CosmicTheme.text
    AddPresetBtn.TextSize = 20
    AddPresetBtn.Font = Enum.Font.GothamBold
    AddPresetBtn.LayoutOrder = 999999
    AddPresetBtn.Parent = PresetFrame
    
    local AddPresetCorner = Instance.new("UICorner")
    AddPresetCorner.CornerRadius = UDim.new(0, 8)
    AddPresetCorner.Parent = AddPresetBtn
    
    -- Rotation Control
    local RotationFrame = Instance.new("Frame")
    RotationFrame.Size = UDim2.new(1, -20, 0, 50)
    RotationFrame.Position = UDim2.new(0, 10, 0, 390)
    RotationFrame.BackgroundColor3 = CosmicTheme.surface
    RotationFrame.BorderSizePixel = 0
    RotationFrame.Parent = MainFrame
    
    local RotationCorner = Instance.new("UICorner")
    RotationCorner.CornerRadius = UDim.new(0, 8)
    RotationCorner.Parent = RotationFrame
    
    local RotationToggle = Instance.new("TextButton")
    RotationToggle.Name = "RotationToggle"
    RotationToggle.Size = UDim2.new(0.6, -5, 1, -10)
    RotationToggle.Position = UDim2.new(0, 5, 0, 5)
    RotationToggle.BackgroundColor3 = CosmicTheme.secondary
    RotationToggle.BorderSizePixel = 0
    RotationToggle.Text = "AUTO ROTATE: OFF"
    RotationToggle.TextColor3 = CosmicTheme.text
    RotationToggle.TextSize = 12
    RotationToggle.Font = Enum.Font.GothamBold
    RotationToggle.Parent = RotationFrame
    
    local RotToggleCorner = Instance.new("UICorner")
    RotToggleCorner.CornerRadius = UDim.new(0, 6)
    RotToggleCorner.Parent = RotationToggle
    
    local IntervalInput = Instance.new("TextBox")
    IntervalInput.Name = "IntervalInput"
    IntervalInput.Size = UDim2.new(0.4, -10, 1, -10)
    IntervalInput.Position = UDim2.new(0.6, 5, 0, 5)
    IntervalInput.BackgroundColor3 = CosmicTheme.background
    IntervalInput.BorderSizePixel = 0
    IntervalInput.Text = "30"
    IntervalInput.PlaceholderText = "Seconds"
    IntervalInput.TextColor3 = CosmicTheme.text
    IntervalInput.TextSize = 12
    IntervalInput.Font = Enum.Font.Gotham
    IntervalInput.Parent = RotationFrame
    
    local IntervalCorner = Instance.new("UICorner")
    IntervalCorner.CornerRadius = UDim.new(0, 6)
    IntervalCorner.Parent = IntervalInput
    
    -- Status Bar
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 35)
    StatusFrame.Position = UDim2.new(0, 10, 0, 450)
    StatusFrame.BackgroundColor3 = CosmicTheme.surface
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, -10, 1, 0)
    StatusText.Position = UDim2.new(0, 5, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Ready | Tools Protected"
    StatusText.TextColor3 = CosmicTheme.textDim
    StatusText.TextSize = 12
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusFrame
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, PresetFrame, AddPresetBtn, RotationToggle, IntervalInput
end

-- Load Avatar with Smart Cooldown
local function loadAvatar(username)
    if not username or username == "" then
        return false, "Username cannot be empty"
    end
    
    local currentTime = tick()
    if currentTime - lastRequestTime < requestCooldown then
        local waitTime = requestCooldown - (currentTime - lastRequestTime)
        wait(waitTime)
    end
    
    lastRequestTime = tick()
    
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if not success then
        return false, "Username not found: " .. username
    end
    
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then
        return false, "Character not available"
    end
    
    local humanoidDesc
    local success2 = pcall(function()
        humanoidDesc = Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success2 or not humanoidDesc then
        return false, "Failed to get avatar data"
    end
    
    -- Save tools
    local savedTools = {}
    local equippedTool = nil
    
    for _, item in pairs(lp.Character:GetChildren()) do
        if item:IsA("Tool") then
            equippedTool = item
            table.insert(savedTools, item:Clone())
            item.Parent = nil
        end
    end
    
    for _, item in pairs(lp.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(savedTools, item:Clone())
        end
    end
    
    -- Remove current avatar items
    pcall(function()
        for _, accessory in pairs(lp.Character:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end
        
        for _, clothing in pairs(lp.Character:GetChildren()) do
            if clothing:IsA("Shirt") or clothing:IsA("Pants") or clothing:IsA("ShirtGraphic") then
                clothing:Destroy()
            end
        end
    end)
    
    wait(0.1)
    
    -- Apply avatar
    local success3 = pcall(function()
        lp.Character.Humanoid:ApplyDescriptionClientServer(humanoidDesc)
    end)
    
    if not success3 then
        for _, tool in pairs(savedTools) do
            tool.Parent = lp.Backpack
        end
        return false, "Failed to apply avatar"
    end
    
    wait(0.3)
    
    -- Restore tools
    for _, tool in pairs(savedTools) do
        if tool and tool:IsA("Tool") then
            tool.Parent = lp.Backpack
        end
    end
    
    if equippedTool then
        wait(0.1)
        local toolInBackpack = lp.Backpack:FindFirstChild(equippedTool.Name)
        if toolInBackpack then
            lp.Character.Humanoid:EquipTool(toolInBackpack)
        end
    end
    
    return true, "Avatar applied: " .. username
end

-- Create Preset Button
local function createPresetButton(index, username, parent)
    local btn = Instance.new("TextButton")
    btn.Name = "Preset" .. index
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = CosmicTheme.secondary
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = index
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = username or "Empty Slot"
    label.TextColor3 = username and CosmicTheme.text or CosmicTheme.textDim
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = btn
    
    local deleteBtn = Instance.new("TextButton")
    deleteBtn.Name = "DeleteButton"
    deleteBtn.Size = UDim2.new(0, 30, 0, 30)
    deleteBtn.Position = UDim2.new(1, -35, 0.5, -15)
    deleteBtn.BackgroundColor3 = CosmicTheme.error
    deleteBtn.BorderSizePixel = 0
    deleteBtn.Text = "X"
    deleteBtn.TextColor3 = CosmicTheme.text
    deleteBtn.TextSize = 14
    deleteBtn.Font = Enum.Font.GothamBold
    deleteBtn.Parent = btn
    
    local deleteCorner = Instance.new("UICorner")
    deleteCorner.CornerRadius = UDim.new(0, 6)
    deleteCorner.Parent = deleteBtn
    
    return btn, label, deleteBtn
end

-- Update All Presets UI
local function updatePresetsUI(presetFrame)
    for _, child in pairs(presetFrame:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "AddPresetButton" then
            child:Destroy()
        end
    end
    
    for i, username in ipairs(presets) do
        local btn, label, deleteBtn = createPresetButton(i, username, presetFrame)
        
        -- Load preset
        btn.MouseButton1Click:Connect(function()
            if username then
                local success, message = loadAvatar(username)
                if success then
                    lastAppliedUsername = username
                end
            end
        end)
        
        -- Save current avatar
        btn.MouseButton2Click:Connect(function()
            if lastAppliedUsername then
                presets[i] = lastAppliedUsername
                savePresets()
                label.Text = lastAppliedUsername
                label.TextColor3 = CosmicTheme.text
            end
        end)
        
        -- Delete preset
        deleteBtn.MouseButton1Click:Connect(function()
            table.remove(presets, i)
            savePresets()
            updatePresetsUI(presetFrame)
        end)
        
        -- Hover effects
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.primary}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.secondary}):Play()
        end)
    end
end

-- Animation Functions
local function animateUI(frame, isOpening)
    if UIState.isAnimating then return end
    UIState.isAnimating = true
    
    if isOpening then
        frame.Visible = true
        frame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 420, 0, 480)
        })
        tween:Play()
        tween.Completed:Connect(function()
            UIState.isAnimating = false
        end)
    else
        local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            frame.Visible = false
            UIState.isAnimating = false
        end)
    end
end

local function toggleUI(mainFrame, toggleButton)
    if UIState.isAnimating then return end
    UIState.isOpen = not UIState.isOpen
    
    if UIState.isOpen then
        animateUI(mainFrame, true)
        toggleButton.Text = "X"
        toggleButton.BackgroundColor3 = CosmicTheme.error
    else
        animateUI(mainFrame, false)
        toggleButton.Text = "A"
        toggleButton.BackgroundColor3 = CosmicTheme.surface
    end
end

local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Auto Rotation System
local function startRotation(statusText)
    isRotating = true
    
    spawn(function()
        while isRotating do
            if #presets > 0 then
                local username = presets[currentAvatarIndex]
                if username then
                    statusText.Text = "Rotating to: " .. username
                    statusText.TextColor3 = CosmicTheme.warning
                    
                    local success, message = loadAvatar(username)
                    
                    if success then
                        lastAppliedUsername = username
                        statusText.Text = "Active: " .. username
                        statusText.TextColor3 = CosmicTheme.success
                    else
                        statusText.Text = "Failed: " .. message
                        statusText.TextColor3 = CosmicTheme.error
                    end
                    
                    currentAvatarIndex = currentAvatarIndex + 1
                    if currentAvatarIndex > #presets then
                        currentAvatarIndex = 1
                    end
                end
            end
            
            wait(rotationInterval)
        end
    end)
end

local function stopRotation(statusText)
    isRotating = false
    statusText.Text = "Rotation stopped"
    statusText.TextColor3 = CosmicTheme.textDim
end

-- Main Script
loadPresets()

local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, PresetFrame, AddPresetBtn, RotationToggle, IntervalInput = createUI()

makeDraggable(ToggleButton)
makeDraggable(MainFrame:FindFirstChild("TitleBar"))

updatePresetsUI(PresetFrame)

-- Toggle Button
ToggleButton.MouseButton1Click:Connect(function()
    toggleUI(MainFrame, ToggleButton)
end)

ToggleButton.MouseEnter:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 45, 0, 45),
            BackgroundColor3 = CosmicTheme.primary
        }):Play()
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundColor3 = CosmicTheme.surface
        }):Play()
    end
end)

-- Submit Button
local function handleSubmit()
    local username = UsernameInput.Text
    if username and username ~= "" then
        UsernameInput.Text = ""
        StatusText.Text = "Applying avatar..."
        StatusText.TextColor3 = CosmicTheme.warning
        
        local success, message = loadAvatar(username)
        
        if success then
            lastAppliedUsername = username
            StatusText.Text = "Active: " .. username
            StatusText.TextColor3 = CosmicTheme.success
        else
            StatusText.Text = message
            StatusText.TextColor3 = CosmicTheme.error
            
            wait(3)
            StatusText.Text = "Ready | Tools Protected"
            StatusText.TextColor3 = CosmicTheme.textDim
        end
    end
end

SubmitButton.MouseButton1Click:Connect(handleSubmit)
UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then handleSubmit() end
end)

-- Add Preset Button
AddPresetBtn.MouseButton1Click:Connect(function()
    if lastAppliedUsername then
        table.insert(presets, lastAppliedUsername)
        savePresets()
        updatePresetsUI(PresetFrame)
        StatusText.Text = "Preset added: " .. lastAppliedUsername
        StatusText.TextColor3 = CosmicTheme.success
    else
        StatusText.Text = "Apply an avatar first"
        StatusText.TextColor3 = CosmicTheme.warning
    end
end)

-- Rotation Toggle
RotationToggle.MouseButton1Click:Connect(function()
    if isRotating then
        stopRotation(StatusText)
        RotationToggle.Text = "AUTO ROTATE: OFF"
        RotationToggle.BackgroundColor3 = CosmicTheme.secondary
    else
        if #presets > 0 then
            local interval = tonumber(IntervalInput.Text)
            if interval and interval >= 5 then
                rotationInterval = interval
                startRotation(StatusText)
                RotationToggle.Text = "AUTO ROTATE: ON"
                RotationToggle.BackgroundColor3 = CosmicTheme.success
            else
                StatusText.Text = "Interval minimum 5 seconds"
                StatusText.TextColor3 = CosmicTheme.error
            end
        else
            StatusText.Text = "Add presets first"
            StatusText.TextColor3 = CosmicTheme.warning
        end
    end
end)

-- Interval Input Validation
IntervalInput.FocusLost:Connect(function()
    local value = tonumber(IntervalInput.Text)
    if not value or value < 5 then
        IntervalInput.Text = "30"
    end
end)

-- Hover Effects
SubmitButton.MouseEnter:Connect(function()
    TweenService:Create(SubmitButton, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.accent}):Play()
end)

SubmitButton.MouseLeave:Connect(function()
    TweenService:Create(SubmitButton, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.primary}):Play()
end)

AddPresetBtn.MouseEnter:Connect(function()
    TweenService:Create(AddPresetBtn, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.primary}):Play()
end)

AddPresetBtn.MouseLeave:Connect(function()
    TweenService:Create(AddPresetBtn, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.secondary}):Play()
end)

RotationToggle.MouseEnter:Connect(function()
    if not isRotating then
        TweenService:Create(RotationToggle, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.primary}):Play()
    end
end)

RotationToggle.MouseLeave:Connect(function()
    if not isRotating then
        TweenService:Create(RotationToggle, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.secondary}):Play()
    end
end)

-- Input Focus Effects
UsernameInput.Focused:Connect(function()
    local stroke = UsernameInput:FindFirstChild("UIStroke")
    if stroke then
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2}):Play()
    end
end)

UsernameInput.FocusLost:Connect(function()
    local stroke = UsernameInput:FindFirstChild("UIStroke")
    if stroke then
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1}):Play()
    end
end)

-- Auto Reapply on Respawn
lp.CharacterAdded:Connect(function(char)
    if lastAppliedUsername then
        char:WaitForChild("Humanoid")
        wait(1.5)
        
        StatusText.Text = "Auto-reapplying: " .. lastAppliedUsername
        StatusText.TextColor3 = CosmicTheme.warning
        
        local success, message = loadAvatar(lastAppliedUsername)
        
        if success then
            StatusText.Text = "Active: " .. lastAppliedUsername
            StatusText.TextColor3 = CosmicTheme.success
        else
            StatusText.Text = "Auto-apply failed"
            StatusText.TextColor3 = CosmicTheme.error
        end
    end
end)

-- Keyboard Shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1: Toggle UI
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleUI(MainFrame, ToggleButton)
    end
    
    -- F2: Quick Apply from Input
    if input.KeyCode == Enum.KeyCode.F2 then
        handleSubmit()
    end
    
    -- F3: Toggle Rotation
    if input.KeyCode == Enum.KeyCode.F3 then
        RotationToggle.MouseButton1Click:Fire()
    end
    
    -- Number Keys 1-9: Quick Load Presets
    local keyCodeToNumber = {
        [Enum.KeyCode.One] = 1,
        [Enum.KeyCode.Two] = 2,
        [Enum.KeyCode.Three] = 3,
        [Enum.KeyCode.Four] = 4,
        [Enum.KeyCode.Five] = 5,
        [Enum.KeyCode.Six] = 6,
        [Enum.KeyCode.Seven] = 7,
        [Enum.KeyCode.Eight] = 8,
        [Enum.KeyCode.Nine] = 9
    }
    
    local presetIndex = keyCodeToNumber[input.KeyCode]
    if presetIndex and presets[presetIndex] then
        StatusText.Text = "Quick loading preset " .. presetIndex
        StatusText.TextColor3 = CosmicTheme.warning
        
        local success, message = loadAvatar(presets[presetIndex])
        
        if success then
            lastAppliedUsername = presets[presetIndex]
            StatusText.Text = "Active: " .. presets[presetIndex]
            StatusText.TextColor3 = CosmicTheme.success
        else
            StatusText.Text = message
            StatusText.TextColor3 = CosmicTheme.error
        end
    end
end)

-- Export/Import Functions
local function exportPresets()
    if #presets == 0 then
        StatusText.Text = "No presets to export"
        StatusText.TextColor3 = CosmicTheme.warning
        return
    end
    
    local exportData = table.concat(presets, ",")
    
    if setclipboard then
        setclipboard(exportData)
        StatusText.Text = "Presets copied to clipboard"
        StatusText.TextColor3 = CosmicTheme.success
    else
        StatusText.Text = "Clipboard not supported"
        StatusText.TextColor3 = CosmicTheme.error
    end
end

local function importPresets(data)
    if not data or data == "" then
        StatusText.Text = "No data to import"
        StatusText.TextColor3 = CosmicTheme.warning
        return
    end
    
    local importedPresets = {}
    for username in string.gmatch(data, "([^,]+)") do
        local trimmed = username:match("^%s*(.-)%s*$")
        if trimmed ~= "" then
            table.insert(importedPresets, trimmed)
        end
    end
    
    if #importedPresets > 0 then
        for _, username in ipairs(importedPresets) do
            table.insert(presets, username)
        end
        savePresets()
        updatePresetsUI(PresetFrame)
        StatusText.Text = "Imported " .. #importedPresets .. " presets"
        StatusText.TextColor3 = CosmicTheme.success
    else
        StatusText.Text = "Invalid import data"
        StatusText.TextColor3 = CosmicTheme.error
    end
end

-- Context Menu for Advanced Options
local ContextMenu = Instance.new("Frame")
ContextMenu.Name = "ContextMenu"
ContextMenu.Size = UDim2.new(0, 180, 0, 140)
ContextMenu.BackgroundColor3 = CosmicTheme.surface
ContextMenu.BorderSizePixel = 0
ContextMenu.Visible = false
ContextMenu.ZIndex = 100
ContextMenu.Parent = ScreenGui

local ContextCorner = Instance.new("UICorner")
ContextCorner.CornerRadius = UDim.new(0, 8)
ContextCorner.Parent = ContextMenu

local ContextStroke = Instance.new("UIStroke")
ContextStroke.Color = CosmicTheme.primary
ContextStroke.Thickness = 2
ContextStroke.Parent = ContextMenu

local ContextList = Instance.new("UIListLayout")
ContextList.Padding = UDim.new(0, 5)
ContextList.SortOrder = Enum.SortOrder.LayoutOrder
ContextList.Parent = ContextMenu

local ContextPadding = Instance.new("UIPadding")
ContextPadding.PaddingTop = UDim.new(0, 5)
ContextPadding.PaddingLeft = UDim.new(0, 5)
ContextPadding.PaddingRight = UDim.new(0, 5)
ContextPadding.PaddingBottom = UDim.new(0, 5)
ContextPadding.Parent = ContextMenu

local function createContextButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = CosmicTheme.background
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = CosmicTheme.text
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.Parent = ContextMenu
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        callback()
        ContextMenu.Visible = false
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.primary}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CosmicTheme.background}):Play()
    end)
    
    return btn
end

createContextButton("Export Presets", exportPresets)
createContextButton("Import Presets", function()
    if getclipboard then
        importPresets(getclipboard())
    else
        StatusText.Text = "Clipboard not supported"
        StatusText.TextColor3 = CosmicTheme.error
    end
end)
createContextButton("Clear All Presets", function()
    presets = {}
    savePresets()
    updatePresetsUI(PresetFrame)
    StatusText.Text = "All presets cleared"
    StatusText.TextColor3 = CosmicTheme.warning
end)
createContextButton("Reset Avatar", function()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        local success = pcall(function()
            local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
            lp.Character.Humanoid:ApplyDescriptionClientServer(humanoidDesc)
        end)
        
        if success then
            lastAppliedUsername = nil
            StatusText.Text = "Avatar reset to original"
            StatusText.TextColor3 = CosmicTheme.success
        else
            StatusText.Text = "Failed to reset avatar"
            StatusText.TextColor3 = CosmicTheme.error
        end
    end
end)

-- Right-click on MainFrame TitleBar to show context menu
MainFrame:FindFirstChild("TitleBar").MouseButton2Click:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    ContextMenu.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y - 36)
    ContextMenu.Visible = not ContextMenu.Visible
end)

-- Hide context menu when clicking outside
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if ContextMenu.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = ContextMenu.AbsolutePosition
            local menuSize = ContextMenu.AbsoluteSize
            
            if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
               mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                ContextMenu.Visible = false
            end
        end
    end
end)

-- Status Update Helper
local function updateStatus(message, color)
    StatusText.Text = message
    StatusText.TextColor3 = color or CosmicTheme.textDim
end

-- Random Avatar from Presets
local function loadRandomPreset()
    if #presets == 0 then
        updateStatus("No presets available", CosmicTheme.warning)
        return
    end
    
    local randomIndex = math.random(1, #presets)
    local username = presets[randomIndex]
    
    updateStatus("Loading random: " .. username, CosmicTheme.warning)
    
    local success, message = loadAvatar(username)
    
    if success then
        lastAppliedUsername = username
        updateStatus("Active: " .. username, CosmicTheme.success)
    else
        updateStatus(message, CosmicTheme.error)
    end
end

-- Add Random Button to Context Menu
createContextButton("Random Preset", loadRandomPreset)

-- Performance Monitor
local lastFPS = 0
local fpsConnection

local function updateFPS()
    local RunService = game:GetService("RunService")
    local lastTime = tick()
    local frameCount = 0
    
    fpsConnection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 1 then
            lastFPS = frameCount
            frameCount = 0
            lastTime = currentTime
        end
    end)
end

updateFPS()

-- Notification System
local function showNotification(message, duration, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, -320, 1, -80)
    notif.BackgroundColor3 = CosmicTheme.surface
    notif.BorderSizePixel = 0
    notif.Parent = ScreenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notif
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = color or CosmicTheme.primary
    notifStroke.Thickness = 2
    notifStroke.Parent = notif
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 1, -20)
    notifText.Position = UDim2.new(0, 10, 0, 10)
    notifText.BackgroundTransparency = 1
    notifText.Text = message
    notifText.TextColor3 = CosmicTheme.text
    notifText.TextSize = 13
    notifText.Font = Enum.Font.Gotham
    notifText.TextWrapped = true
    notifText.Parent = notif
    
    -- Slide in animation
    notif.Position = UDim2.new(1, 0, 1, -80)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -320, 1, -80)
    }):Play()
    
    -- Auto dismiss
    wait(duration or 3)
    
    local slideOut = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, 0, 1, -80)
    })
    slideOut:Play()
    slideOut.Completed:Connect(function()
        notif:Destroy()
    end)
end

-- Welcome Message
wait(0.5)
showNotification("Avatar Changer Advanced Loaded\nPress F1 to toggle", 4, CosmicTheme.success)
