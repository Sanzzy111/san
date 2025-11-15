-- AVATAR CHANGER - MODERN UI + CACHE SYSTEM
-- ✅ Cache system untuk fix rate limit
-- ✅ Modern glassmorphism UI
-- ✅ No toggle button on PC (F1 only)
-- ✅ Toggle button only on mobile

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- Detect Platform
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- State Management
local UIState = {
    isOpen = false,
    isAnimating = false
}

local lastAppliedUsername = nil
local presets = {}
local PRESET_FILE = "avatar_presets.json"

-- CACHE SYSTEM untuk fix rate limit
local userIdCache = {}
local avatarDescCache = {}

-- Load presets dari file
local function loadPresets()
    if not readfile or not isfile then 
        warn("Executor tidak support file operations")
        return 
    end
    
    if isfile(PRESET_FILE) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(PRESET_FILE))
        end)
        
        if success and data then
            presets = data
            print("✅ Loaded " .. #presets .. " presets")
        end
    end
end

-- Save presets ke file
local function savePresets()
    if not writefile then 
        warn("Executor tidak support file writing")
        return 
    end
    
    pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(presets)
        writefile(PRESET_FILE, json)
    end)
end

-- Get User ID dengan cache
local function getUserId(username)
    username = string.lower(username)
    
    -- Check cache first
    if userIdCache[username] then
        return true, userIdCache[username]
    end
    
    -- Fetch dari API
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if success and userId then
        userIdCache[username] = userId
        return true, userId
    end
    
    return false, nil
end

-- Get Avatar Description dengan cache
local function getAvatarDesc(userId)
    -- Check cache first
    if avatarDescCache[userId] then
        return true, avatarDescCache[userId]
    end
    
    -- Fetch dari API
    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if success and desc then
        avatarDescCache[userId] = desc
        return true, desc
    end
    
    return false, nil
end

-- Toggle Button Creation (hanya untuk mobile)
local function createToggleButton()
    if not isMobile then return nil end
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 15, 0.5, -25)
    ToggleButton.AnchorPoint = Vector2.new(0, 0.5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.BackgroundTransparency = 0.3
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "👤"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 28
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 10
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0.5, 0)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(100, 180, 255)
    ToggleStroke.Thickness = 2
    ToggleStroke.Transparency = 0.5
    ToggleStroke.Parent = ToggleButton
    
    return ToggleButton
end

-- Modern UI Creation
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ModernAvatarChanger"
    ScreenGui.Parent = lp.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local ToggleButton = createToggleButton()
    if ToggleButton then
        ToggleButton.Parent = ScreenGui
    end
    
    -- Main Frame dengan Glassmorphism
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(100, 150, 255)
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.6
    MainStroke.Parent = MainFrame
    
    -- Gradient Background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    -- Close Button (hanya di PC)
    if not isMobile then
        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Size = UDim2.new(0, 30, 0, 30)
        CloseButton.Position = UDim2.new(1, -35, 0, 5)
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        CloseButton.BackgroundTransparency = 0.2
        CloseButton.BorderSizePixel = 0
        CloseButton.Text = "✕"
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextSize = 18
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Parent = MainFrame
        
        local CloseCorner = Instance.new("UICorner")
        CloseCorner.CornerRadius = UDim.new(0.5, 0)
        CloseCorner.Parent = CloseButton
    end
    
    -- Title
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 0, 35)
    TitleText.Position = UDim2.new(0, 20, 0, 10)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "✨ AVATAR CHANGER"
    TitleText.TextColor3 = Color3.fromRGB(150, 200, 255)
    TitleText.TextSize = 20
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = MainFrame
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, -40, 0, 15)
    SubTitle.Position = UDim2.new(0, 20, 0, 35)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Tools Protected • Auto Save"
    SubTitle.TextColor3 = Color3.fromRGB(150, 150, 170)
    SubTitle.TextSize = 11
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.Parent = MainFrame
    
    -- Input Section
    local InputContainer = Instance.new("Frame")
    InputContainer.Size = UDim2.new(1, -40, 0, 45)
    InputContainer.Position = UDim2.new(0, 20, 0, 60)
    InputContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    InputContainer.BackgroundTransparency = 0.3
    InputContainer.BorderSizePixel = 0
    InputContainer.Parent = MainFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = InputContainer
    
    local UsernameInput = Instance.new("TextBox")
    UsernameInput.Name = "UsernameInput"
    UsernameInput.Size = UDim2.new(1, -120, 1, -10)
    UsernameInput.Position = UDim2.new(0, 15, 0, 5)
    UsernameInput.BackgroundTransparency = 1
    UsernameInput.Text = ""
    UsernameInput.PlaceholderText = "Enter username..."
    UsernameInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    UsernameInput.TextSize = 14
    UsernameInput.Font = Enum.Font.Gotham
    UsernameInput.TextXAlignment = Enum.TextXAlignment.Left
    UsernameInput.ClearTextOnFocus = false
    UsernameInput.Parent = InputContainer
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Size = UDim2.new(0, 95, 1, -10)
    SubmitButton.Position = UDim2.new(1, -105, 0, 5)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "APPLY"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 13
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = InputContainer
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitButton
    
    -- Preset Section
    local PresetContainer = Instance.new("Frame")
    PresetContainer.Size = UDim2.new(1, -40, 0, 120)
    PresetContainer.Position = UDim2.new(0, 20, 0, 115)
    PresetContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    PresetContainer.BackgroundTransparency = 0.4
    PresetContainer.BorderSizePixel = 0
    PresetContainer.Parent = MainFrame
    
    local PresetCorner = Instance.new("UICorner")
    PresetCorner.CornerRadius = UDim.new(0, 12)
    PresetCorner.Parent = PresetContainer
    
    local PresetTitle = Instance.new("TextLabel")
    PresetTitle.Size = UDim2.new(1, -20, 0, 25)
    PresetTitle.Position = UDim2.new(0, 10, 0, 5)
    PresetTitle.BackgroundTransparency = 1
    PresetTitle.Text = "⭐ PRESET SLOTS"
    PresetTitle.TextColor3 = Color3.fromRGB(255, 215, 100)
    PresetTitle.TextSize = 13
    PresetTitle.Font = Enum.Font.GothamBold
    PresetTitle.TextXAlignment = Enum.TextXAlignment.Left
    PresetTitle.Parent = PresetContainer
    
    local PresetHint = Instance.new("TextLabel")
    PresetHint.Size = UDim2.new(1, -20, 0, 12)
    PresetHint.Position = UDim2.new(0, 10, 0, 28)
    PresetHint.BackgroundTransparency = 1
    PresetHint.Text = "Left Click: Load • Right Click: Save"
    PresetHint.TextColor3 = Color3.fromRGB(130, 130, 150)
    PresetHint.TextSize = 10
    PresetHint.Font = Enum.Font.Gotham
    PresetHint.TextXAlignment = Enum.TextXAlignment.Left
    PresetHint.Parent = PresetContainer
    
    -- 5 Preset Buttons
    local presetButtons = {}
    for i = 1, 5 do
        local btn = Instance.new("TextButton")
        btn.Name = "Preset" .. i
        btn.Size = UDim2.new(0.18, 0, 0, 50)
        btn.Position = UDim2.new((i-1) * 0.2 + 0.01, 0, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = PresetContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 80, 100)
        stroke.Thickness = 1
        stroke.Transparency = 0.5
        stroke.Parent = btn
        
        local number = Instance.new("TextLabel")
        number.Size = UDim2.new(1, 0, 0, 20)
        number.Position = UDim2.new(0, 0, 0, 5)
        number.BackgroundTransparency = 1
        number.Text = tostring(i)
        number.TextColor3 = Color3.fromRGB(200, 200, 220)
        number.TextSize = 16
        number.Font = Enum.Font.GothamBold
        number.Parent = btn
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -4, 0, 20)
        label.Position = UDim2.new(0, 2, 1, -25)
        label.BackgroundTransparency = 1
        label.Text = "Empty"
        label.TextColor3 = Color3.fromRGB(130, 130, 150)
        label.TextSize = 9
        label.Font = Enum.Font.Gotham
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Parent = btn
        
        presetButtons[i] = btn
    end
    
    -- Status Bar
    local StatusBar = Instance.new("Frame")
    StatusBar.Size = UDim2.new(1, -40, 0, 35)
    StatusBar.Position = UDim2.new(0, 20, 1, -45)
    StatusBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    StatusBar.BackgroundTransparency = 0.4
    StatusBar.BorderSizePixel = 0
    StatusBar.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = StatusBar
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "✨ Ready"
    StatusText.TextColor3 = Color3.fromRGB(150, 200, 255)
    StatusText.TextSize = 12
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusBar
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons
end

-- Load Avatar Function dengan Cache
local function loadAvatar(username)
    if not username or username == "" then
        return false, "Username kosong!"
    end
    
    -- Get User ID (with cache)
    local success, userId = getUserId(username)
    if not success then
        return false, "Username tidak ditemukan"
    end
    
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then
        return false, "Character tidak ada!"
    end
    
    -- Get Avatar Description (with cache)
    local success2, humanoidDesc = getAvatarDesc(userId)
    if not success2 then
        return false, "Gagal load avatar"
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
    
    -- Remove old avatar parts
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
        return false, "Gagal apply"
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
    
    return true, username
end

-- Update Preset UI
local function updatePresetUI(presetButtons)
    for i = 1, 5 do
        local btn = presetButtons[i]
        local label = btn:FindFirstChild("Label")
        local stroke = btn:FindFirstChild("UIStroke")
        
        if presets[i] then
            btn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            stroke.Color = Color3.fromRGB(100, 150, 255)
            stroke.Transparency = 0.3
            label.Text = presets[i]
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            stroke.Color = Color3.fromRGB(80, 80, 100)
            stroke.Transparency = 0.5
            label.Text = "Empty"
            label.TextColor3 = Color3.fromRGB(130, 130, 150)
        end
    end
end

-- Animation
local function animateUI(frame, isOpening)
    if UIState.isAnimating then return end
    UIState.isAnimating = true
    
    if isOpening then
        frame.Visible = true
        frame.Size = UDim2.new(0, 0, 0, 0)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local tween = TweenService:Create(frame, tweenInfo, {
            Size = UDim2.new(0, 420, 0, 280),
            Position = UDim2.new(0.5, -210, 0.5, -140)
        })
        tween:Play()
        tween.Completed:Wait()
    else
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        local tween = TweenService:Create(frame, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        frame.Visible = false
    end
    
    UIState.isAnimating = false
end

local function toggleUI(mainFrame, toggleButton)
    if UIState.isAnimating then return end
    UIState.isOpen = not UIState.isOpen
    
    animateUI(mainFrame, UIState.isOpen)
    
    if toggleButton and isMobile then
        if UIState.isOpen then
            toggleButton.Text = "✕"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        else
            toggleButton.Text = "👤"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
end

-- Main Initialization
loadPresets()

local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons = createUI()

-- Toggle Button Events (hanya mobile)
if ToggleButton and isMobile then
    ToggleButton.MouseButton1Click:Connect(function()
        toggleUI(MainFrame, ToggleButton)
    end)
    
    ToggleButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 55, 0, 55)
        })
        tween:Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 50, 0, 50)
        })
        tween:Play()
    end)
end

-- Close Button (PC only)
if not isMobile then
    local CloseButton = MainFrame:FindFirstChild("CloseButton")
    if CloseButton then
        CloseButton.MouseButton1Click:Connect(function()
            toggleUI(MainFrame, ToggleButton)
        end)
    end
end

-- Submit Handler
local function handleSubmit()
    local username = UsernameInput.Text:gsub("^%s*(.-)%s*$", "%1")
    
    if username == "" then
        StatusText.Text = "⚠️ Enter username first!"
        StatusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        return
    end
    
    StatusText.Text = "⏳ Applying..."
    StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    task.wait(0.1)
    
    local success, result = loadAvatar(username)
    
    if success then
        lastAppliedUsername = result
        UsernameInput.Text = ""
        UsernameInput.PlaceholderText = "✓ " .. result
        StatusText.Text = "✅ Applied: " .. result
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
    else
        StatusText.Text = "❌ " .. result
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        task.wait(2)
        StatusText.Text = "✨ Ready"
        StatusText.TextColor3 = Color3.fromRGB(150, 200, 255)
    end
end

SubmitButton.MouseButton1Click:Connect(handleSubmit)

UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        handleSubmit()
    end
end)

-- Button Hover Effects
SubmitButton.MouseEnter:Connect(function()
    SubmitButton.BackgroundColor3 = Color3.fromRGB(120, 170, 255)
end)

SubmitButton.MouseLeave:Connect(function()
    SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
end)

-- Preset Button Logic
for i, btn in ipairs(presetButtons) do
    -- Left Click: Load
    btn.MouseButton1Click:Connect(function()
        if presets[i] then
            StatusText.Text = "⏳ Loading Preset " .. i .. "..."
            StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
            
            task.wait(0.1)
            
            local success, result = loadAvatar(presets[i])
            
            if success then
                lastAppliedUsername = result
                StatusText.Text = "✅ Preset " .. i .. " loaded!"
                StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
            else
                StatusText.Text = "❌ Failed to load"
                StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        else
            StatusText.Text = "⚠️ Preset " .. i .. " is empty"
            StatusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    -- Right Click: Save
    btn.MouseButton2Click:Connect(function()
        if lastAppliedUsername then
            presets[i] = lastAppliedUsername
            savePresets()
            updatePresetUI(presetButtons)
            
            StatusText.Text = "💾 Saved to Preset " .. i
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            StatusText.Text = "⚠️ Apply avatar first!"
            StatusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    -- Hover
    btn.MouseEnter:Connect(function()
        local stroke = btn:FindFirstChild("UIStroke")
        if stroke then
            stroke.Thickness = 2
        end
    end)
    
    btn.MouseLeave:Connect(function()
        local stroke = btn:FindFirstChild("UIStroke")
        if stroke then
            stroke.Thickness = 1
        end
    end)
end

updatePresetUI(presetButtons)

-- Auto Reapply on Respawn
lp.CharacterAdded:Connect(function(char)
    if lastAppliedUsername then
        char:WaitForChild("Humanoid")
        task.wait(1)
        
        StatusText.Text = "🔄 Auto-reapplying..."
        StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        local success = loadAvatar(lastAppliedUsername)
        
        if success then
            StatusText.Text = "✅ Auto-applied: " .. lastAppliedUsername
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
        end
    end
end)

-- F1 Keyboard Shortcut
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleUI(MainFrame, ToggleButton)
    end
end)

print("hi how are you?")
