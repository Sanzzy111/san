-- AVATAR CHANGER - FULL DATA PRESET SYSTEM (FIXED & MODERN)
-- ✅ Fixed: Rate limit dengan caching username
-- ✅ Modern UI dengan glassmorphism
-- ✅ Auto-hide toggle button di PC (hanya F1)
-- ✅ Show toggle button di Mobile

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- Device Detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPC = UserInputService.KeyboardEnabled

-- State Management
local UIState = {
    isOpen = false,
    isAnimating = false
}

local currentAvatarData = nil
local presets = {}
local PRESET_FILE = "avatar_presets_full.json"

-- USERNAME CACHE untuk menghindari rate limit
local usernameCache = {}
local CACHE_FILE = "username_cache.json"

-- Load cache
local function loadCache()
    if not readfile or not isfile then return end
    
    if isfile(CACHE_FILE) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(CACHE_FILE))
        end)
        
        if success and data then
            usernameCache = data
            print("✅ Loaded username cache")
        end
    end
end

-- Save cache
local function saveCache()
    if not writefile then return end
    
    pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(usernameCache)
        writefile(CACHE_FILE, json)
    end)
end

-- Get UserID dengan cache
local function getUserIdFromUsername(username)
    local lowerUsername = string.lower(username)
    
    -- Cek cache dulu
    if usernameCache[lowerUsername] then
        print("📦 Using cached UserID for: " .. username)
        return true, usernameCache[lowerUsername]
    end
    
    -- Jika tidak ada di cache, fetch dari Roblox
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if success and userId then
        -- Simpan ke cache
        usernameCache[lowerUsername] = userId
        saveCache()
        print("💾 Cached UserID for: " .. username)
        return true, userId
    end
    
    return false, nil
end

-- Function untuk mengambil SEMUA data avatar
local function captureFullAvatarData(humanoidDesc)
    if not humanoidDesc then return nil end
    
    local avatarData = {
        -- Body Parts
        HeadColor = humanoidDesc.HeadColor,
        TorsoColor = humanoidDesc.TorsoColor,
        LeftArmColor = humanoidDesc.LeftArmColor,
        RightArmColor = humanoidDesc.RightArmColor,
        LeftLegColor = humanoidDesc.LeftLegColor,
        RightLegColor = humanoidDesc.RightLegColor,
        
        -- Body Scale
        BodyTypeScale = humanoidDesc.BodyTypeScale,
        DepthScale = humanoidDesc.DepthScale,
        HeadScale = humanoidDesc.HeadScale,
        HeightScale = humanoidDesc.HeightScale,
        ProportionScale = humanoidDesc.ProportionScale,
        WidthScale = humanoidDesc.WidthScale,
        
        -- Face & Hair
        Face = humanoidDesc.Face,
        Head = humanoidDesc.Head,
        HairAccessory = humanoidDesc.HairAccessory,
        FaceAccessory = humanoidDesc.FaceAccessory,
        NeckAccessory = humanoidDesc.NeckAccessory,
        ShoulderAccessory = humanoidDesc.ShoulderAccessory,
        FrontAccessory = humanoidDesc.FrontAccessory,
        BackAccessory = humanoidDesc.BackAccessory,
        WaistAccessory = humanoidDesc.WaistAccessory,
        
        -- Clothing
        Shirt = humanoidDesc.Shirt,
        Pants = humanoidDesc.Pants,
        GraphicTShirt = humanoidDesc.GraphicTShirt,
        
        -- Layered Clothing
        ShirtAccessory = humanoidDesc.ShirtAccessory,
        PantsAccessory = humanoidDesc.PantsAccessory,
        JacketAccessory = humanoidDesc.JacketAccessory,
        SweaterAccessory = humanoidDesc.SweaterAccessory,
        ShortsAccessory = humanoidDesc.ShortsAccessory,
        LeftShoeAccessory = humanoidDesc.LeftShoeAccessory,
        RightShoeAccessory = humanoidDesc.RightShoeAccessory,
        DressSkirtAccessory = humanoidDesc.DressSkirtAccessory,
        
        -- Animations
        ClimbAnimation = humanoidDesc.ClimbAnimation,
        FallAnimation = humanoidDesc.FallAnimation,
        IdleAnimation = humanoidDesc.IdleAnimation,
        JumpAnimation = humanoidDesc.JumpAnimation,
        RunAnimation = humanoidDesc.RunAnimation,
        SwimAnimation = humanoidDesc.SwimAnimation,
        WalkAnimation = humanoidDesc.WalkAnimation,
        
        -- Body Parts IDs
        LeftArm = humanoidDesc.LeftArm,
        RightArm = humanoidDesc.RightArm,
        LeftLeg = humanoidDesc.LeftLeg,
        RightLeg = humanoidDesc.RightLeg,
        Torso = humanoidDesc.Torso,
        
        -- Extra
        MoodAnimation = humanoidDesc.MoodAnimation,
        EmoteAnimation1 = pcall(function() return humanoidDesc.EmoteAnimation1 end) and humanoidDesc.EmoteAnimation1 or 0,
        EmoteAnimation2 = pcall(function() return humanoidDesc.EmoteAnimation2 end) and humanoidDesc.EmoteAnimation2 or 0,
        EmoteAnimation3 = pcall(function() return humanoidDesc.EmoteAnimation3 end) and humanoidDesc.EmoteAnimation3 or 0,
    }
    
    return avatarData
end

-- Function untuk apply avatar dari data tersimpan
local function applyAvatarFromData(avatarData)
    if not avatarData then return false, "No avatar data" end
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then
        return false, "Character not found"
    end
    
    local humanoidDesc = Instance.new("HumanoidDescription")
    
    for property, value in pairs(avatarData) do
        pcall(function()
            humanoidDesc[property] = value
        end)
    end
    
    -- Simpan tools
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
    
    -- Hapus accessories & clothing lama
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
    
    local success = pcall(function()
        lp.Character.Humanoid:ApplyDescriptionClientServer(humanoidDesc)
    end)
    
    if not success then
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
    
    return true, "Avatar applied successfully"
end

-- Load presets dari file
local function loadPresets()
    if not readfile or not isfile then return end
    
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
    if not writefile then return end
    
    pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(presets)
        writefile(PRESET_FILE, json)
    end)
end

-- Load Avatar dari Username (FIXED dengan cache)
local function loadAvatarFromUsername(username)
    if not username or username == "" then
        return false, "Username tidak boleh kosong!"
    end
    
    local success, userId = getUserIdFromUsername(username)
    
    if not success then
        return false, "Username tidak ditemukan: " .. username
    end
    
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then
        return false, "Character tidak ada!"
    end
    
    local humanoidDesc
    local success2 = pcall(function()
        humanoidDesc = Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success2 or not humanoidDesc then
        return false, "Gagal mendapatkan avatar"
    end
    
    currentAvatarData = captureFullAvatarData(humanoidDesc)
    currentAvatarData.username = username
    
    local applySuccess, applyMessage = applyAvatarFromData(currentAvatarData)
    
    if applySuccess then
        return true, "Avatar loaded: " .. username
    else
        return false, applyMessage
    end
end

-- MODERN UI Creation
local function createToggleButton()
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 20, 0, 20)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleButton.BackgroundTransparency = 0.3
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "👤"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 24
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 100
    
    -- Hide di PC, show di Mobile
    ToggleButton.Visible = isMobile
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = ToggleButton
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 100, 255)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.5
    Stroke.Parent = ToggleButton
    
    return ToggleButton
end

local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ModernAvatarChanger"
    ScreenGui.Parent = lp.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local ToggleButton = createToggleButton()
    ToggleButton.Parent = ScreenGui
    
    -- Main Frame (Modern Glassmorphism)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(100, 100, 255)
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.7
    MainStroke.Parent = MainFrame
    
    -- Gradient Background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    }
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleBar.BackgroundTransparency = 0.3
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar
    
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 80, 255))
    }
    TitleGradient.Rotation = 90
    TitleGradient.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -60, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "👤 AVATAR CHANGER"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 18
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BackgroundTransparency = 0.3
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    -- Input Frame
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -30, 0, 40)
    InputFrame.Position = UDim2.new(0, 15, 0, 55)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = MainFrame
    
    local UsernameInput = Instance.new("TextBox")
    UsernameInput.Name = "UsernameInput"
    UsernameInput.Size = UDim2.new(0.68, 0, 1, 0)
    UsernameInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    UsernameInput.BackgroundTransparency = 0.3
    UsernameInput.BorderSizePixel = 0
    UsernameInput.Text = ""
    UsernameInput.PlaceholderText = "Enter username..."
    UsernameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    UsernameInput.TextSize = 14
    UsernameInput.Font = Enum.Font.Gotham
    UsernameInput.Parent = InputFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = UsernameInput
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(80, 80, 255)
    InputStroke.Thickness = 1
    InputStroke.Transparency = 0.7
    InputStroke.Parent = UsernameInput
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Size = UDim2.new(0.3, 0, 1, 0)
    SubmitButton.Position = UDim2.new(0.7, 0, 0, 0)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    SubmitButton.BackgroundTransparency = 0.2
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "LOAD"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = InputFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 10)
    SubmitCorner.Parent = SubmitButton
    
    local SubmitGradient = Instance.new("UIGradient")
    SubmitGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 255))
    }
    SubmitGradient.Parent = SubmitButton
    
    -- Preset Section
    local PresetFrame = Instance.new("Frame")
    PresetFrame.Size = UDim2.new(1, -30, 0, 130)
    PresetFrame.Position = UDim2.new(0, 15, 0, 105)
    PresetFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    PresetFrame.BackgroundTransparency = 0.4
    PresetFrame.BorderSizePixel = 0
    PresetFrame.Parent = MainFrame
    
    local PresetCorner = Instance.new("UICorner")
    PresetCorner.CornerRadius = UDim.new(0, 12)
    PresetCorner.Parent = PresetFrame
    
    local PresetStroke = Instance.new("UIStroke")
    PresetStroke.Color = Color3.fromRGB(80, 80, 200)
    PresetStroke.Thickness = 1
    PresetStroke.Transparency = 0.7
    PresetStroke.Parent = PresetFrame
    
    local PresetTitle = Instance.new("TextLabel")
    PresetTitle.Size = UDim2.new(1, 0, 0, 25)
    PresetTitle.BackgroundTransparency = 1
    PresetTitle.Text = "⭐ PRESETS"
    PresetTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    PresetTitle.TextSize = 14
    PresetTitle.Font = Enum.Font.GothamBold
    PresetTitle.Parent = PresetFrame
    
    -- Preset Buttons (Modern Cards)
    local presetButtons = {}
    for i = 1, 5 do
        local btn = Instance.new("TextButton")
        btn.Name = "Preset" .. i
        btn.Size = UDim2.new(0.18, 0, 0, 45)
        btn.Position = UDim2.new((i-1) * 0.2 + 0.01, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Text = tostring(i)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 20
        btn.Font = Enum.Font.GothamBold
        btn.Parent = PresetFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(100, 100, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.8
        stroke.Parent = btn
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 18)
        label.Position = UDim2.new(0, 0, 1, 2)
        label.BackgroundTransparency = 1
        label.Text = "Empty"
        label.TextColor3 = Color3.fromRGB(150, 150, 150)
        label.TextSize = 10
        label.Font = Enum.Font.Gotham
        label.Parent = btn
        
        presetButtons[i] = btn
    end
    
    -- Help Text
    local HelpText = Instance.new("TextLabel")
    HelpText.Size = UDim2.new(1, 0, 0, 15)
    HelpText.Position = UDim2.new(0, 0, 1, -18)
    HelpText.BackgroundTransparency = 1
    HelpText.Text = "Left: Load • Right: Save"
    HelpText.TextColor3 = Color3.fromRGB(150, 150, 200)
    HelpText.TextSize = 10
    HelpText.Font = Enum.Font.Gotham
    HelpText.Parent = PresetFrame
    
    -- Status Bar
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -30, 0, 35)
    StatusFrame.Position = UDim2.new(0, 15, 1, -45)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    StatusFrame.BackgroundTransparency = 0.4
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = StatusFrame
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, -10, 1, 0)
    StatusText.Position = UDim2.new(0, 5, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "✨ Ready"
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 255)
    StatusText.TextSize = 12
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusFrame
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons, CloseButton
end

-- Update Preset UI
local function updatePresetUI(presetButtons)
    for i = 1, 5 do
        local btn = presetButtons[i]
        local label = btn:FindFirstChild("Label")
        local stroke = btn:FindFirstChild("UIStroke")
        
        if presets[i] and presets[i].username then
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
            label.Text = presets[i].username
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            stroke.Color = Color3.fromRGB(150, 150, 255)
            stroke.Transparency = 0.3
        else
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            label.Text = "Empty"
            label.TextColor3 = Color3.fromRGB(150, 150, 150)
            stroke.Color = Color3.fromRGB(100, 100, 255)
            stroke.Transparency = 0.8
        end
    end
end

-- Animation Functions
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
        tween.Completed:Connect(function()
            UIState.isAnimating = false
        end)
    else
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        local tween = TweenService:Create(frame, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
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
    
    animateUI(mainFrame, UIState.isOpen)
    
    if isMobile and toggleButton then
        if UIState.isOpen then
            toggleButton.Text = "✕"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        else
            toggleButton.Text = "👤"
            toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        end
    end
end

local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local titleBar = frame:FindFirstChild("TitleBar")
    if not titleBar then return end
    
    titleBar.InputBegan:Connect(function(input)
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

-- Main Script
loadCache()
loadPresets()

local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons, CloseButton = createUI()

makeDraggable(MainFrame)

-- Toggle Button Events (hanya untuk mobile)
if isMobile and ToggleButton then
    ToggleButton.MouseButton1Click:Connect(function()
        toggleUI(MainFrame, ToggleButton)
    end)
    
    ToggleButton.MouseEnter:Connect(function()
        if not UIState.isOpen then
            local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 55, 0, 55),
                BackgroundTransparency = 0.1
            })
            tween:Play()
        end
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        if not UIState.isOpen then
            local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 50, 0, 50),
                BackgroundTransparency = 0.3
            })
            tween:Play()
        end
    end)
end

-- Close Button
CloseButton.MouseButton1Click:Connect(function()
    toggleUI(MainFrame, ToggleButton)
end)

CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundTransparency = 0.1
end)

CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundTransparency = 0.3
end)

-- Submit Button Logic
local function handleSubmit()
    local username = UsernameInput.Text
    if username and username ~= "" then
        UsernameInput.PlaceholderText = "Loading..."
        UsernameInput.Text = ""
        StatusText.Text = "⏳ Loading avatar..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        task.wait(0.1)
        
        local success, message = loadAvatarFromUsername(username)
        
        if success then
            UsernameInput.PlaceholderText = "✓ " .. username
            StatusText.Text = "✅ " .. message
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            UsernameInput.PlaceholderText = "✗ Failed"
            StatusText.Text = "❌ " .. message
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            task.wait(3)
            UsernameInput.PlaceholderText = "Enter username..."
            StatusText.Text = "✨ Ready"
            StatusText.TextColor3 = Color3.fromRGB(200, 200, 255)
        end
    end
end

SubmitButton.MouseButton1Click:Connect(handleSubmit)

UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        handleSubmit()
    end
end)

-- Submit Button Hover
SubmitButton.MouseEnter:Connect(function()
    local tween = TweenService:Create(SubmitButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0
    })
    tween:Play()
end)

SubmitButton.MouseLeave:Connect(function()
    local tween = TweenService:Create(SubmitButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end)

-- Input Focus Effects
UsernameInput.Focused:Connect(function()
    local stroke = UsernameInput:FindFirstChild("UIStroke")
    if stroke then
        local tween = TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0.3,
            Thickness = 2
        })
        tween:Play()
    end
end)

UsernameInput.FocusLost:Connect(function()
    local stroke = UsernameInput:FindFirstChild("UIStroke")
    if stroke then
        local tween = TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0.7,
            Thickness = 1
        })
        tween:Play()
    end
end)

-- Preset Buttons Logic
for i, btn in ipairs(presetButtons) do
    -- Left Click: Load preset
    btn.MouseButton1Click:Connect(function()
        if presets[i] then
            StatusText.Text = "⏳ Loading Preset " .. i .. "..."
            StatusText.TextColor3 = Color3.fromRGB(255, 255, 100)
            
            task.wait(0.1)
            
            local success, message = applyAvatarFromData(presets[i])
            
            if success then
                currentAvatarData = presets[i]
                StatusText.Text = "✅ Preset " .. i .. " loaded!"
                StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                StatusText.Text = "❌ " .. message
                StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        else
            StatusText.Text = "⚠️ Preset " .. i .. " is empty!"
            StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end)
    
    -- Right Click: Save preset
    btn.MouseButton2Click:Connect(function()
        if currentAvatarData then
            presets[i] = currentAvatarData
            savePresets()
            updatePresetUI(presetButtons)
            
            StatusText.Text = "💾 Saved to Preset " .. i .. "!"
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            StatusText.Text = "⚠️ Load avatar first!"
            StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end)
    
    -- Hover Effects
    btn.MouseEnter:Connect(function()
        local tween = TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(0.19, 0, 0, 50),
            BackgroundTransparency = 0.1
        })
        tween:Play()
        
        local stroke = btn:FindFirstChild("UIStroke")
        if stroke then
            local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.2), {
                Transparency = 0.3
            })
            strokeTween:Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        local tween = TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(0.18, 0, 0, 45),
            BackgroundTransparency = 0.3
        })
        tween:Play()
        
        local stroke = btn:FindFirstChild("UIStroke")
        if stroke then
            local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.2), {
                Transparency = presets[i] and 0.3 or 0.8
            })
            strokeTween:Play()
        end
    end)
end

updatePresetUI(presetButtons)

-- Auto Reapply on Respawn
lp.CharacterAdded:Connect(function(char)
    if currentAvatarData then
        char:WaitForChild("Humanoid")
        task.wait(1)
        
        StatusText.Text = "🔄 Auto-reapplying..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        local success, message = applyAvatarFromData(currentAvatarData)
        
        if success then
            StatusText.Text = "✅ Auto-applied: " .. (currentAvatarData.username or "Avatar")
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            StatusText.Text = "❌ Auto-apply failed"
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)

-- Keyboard Shortcuts (F1 untuk PC)
if isPC then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F1 then
            toggleUI(MainFrame, ToggleButton)
        end
    end)
end


print("Hello")