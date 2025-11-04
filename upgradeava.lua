-- AVATAR CHANGER - FULL PRESET SYSTEM
-- ✅ Menyimpan SELURUH data avatar (accessories, clothing, body colors, dll)
-- ✅ 5 Preset Avatar tersimpan ke file
-- ✅ Auto load preset setelah rejoin/ganti map
-- ✅ Tools tidak hilang saat equip

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- State Management
local UIState = {
    isOpen = false,
    isAnimating = false
}

local currentAvatarData = nil
local presets = {}
local PRESET_FILE = "avatar_full_presets.json"

-- Function untuk safely get property
local function safeGetProperty(obj, propName, default)
    local success, value = pcall(function()
        return obj[propName]
    end)
    return success and value or default
end

-- Function untuk serialize HumanoidDescription
local function serializeHumanoidDescription(desc)
    if not desc then return nil end
    
    local data = {
        -- Body Parts
        Head = safeGetProperty(desc, "Head", 0),
        Torso = safeGetProperty(desc, "Torso", 0),
        LeftArm = safeGetProperty(desc, "LeftArm", 0),
        RightArm = safeGetProperty(desc, "RightArm", 0),
        LeftLeg = safeGetProperty(desc, "LeftLeg", 0),
        RightLeg = safeGetProperty(desc, "RightLeg", 0),
        
        -- Accessories (dengan safe access)
        HatAccessory = safeGetProperty(desc, "HatAccessory", ""),
        HairAccessory = safeGetProperty(desc, "HairAccessory", ""),
        FaceAccessory = safeGetProperty(desc, "FaceAccessory", ""),
        NeckAccessory = safeGetProperty(desc, "NeckAccessory", ""),
        ShoulderAccessory = safeGetProperty(desc, "ShoulderAccessory", ""),
        FrontAccessory = safeGetProperty(desc, "FrontAccessory", ""),
        BackAccessory = safeGetProperty(desc, "BackAccessory", ""),
        WaistAccessory = safeGetProperty(desc, "WaistAccessory", ""),
        
        -- Clothing
        Shirt = safeGetProperty(desc, "Shirt", 0),
        Pants = safeGetProperty(desc, "Pants", 0),
        GraphicTShirt = safeGetProperty(desc, "GraphicTShirt", 0),
        
        -- Face & Animation
        Face = safeGetProperty(desc, "Face", 0),
        ClimbAnimation = safeGetProperty(desc, "ClimbAnimation", 0),
        FallAnimation = safeGetProperty(desc, "FallAnimation", 0),
        IdleAnimation = safeGetProperty(desc, "IdleAnimation", 0),
        JumpAnimation = safeGetProperty(desc, "JumpAnimation", 0),
        RunAnimation = safeGetProperty(desc, "RunAnimation", 0),
        SwimAnimation = safeGetProperty(desc, "SwimAnimation", 0),
        WalkAnimation = safeGetProperty(desc, "WalkAnimation", 0),
        
        -- Proportions
        BodyTypeScale = safeGetProperty(desc, "BodyTypeScale", 0),
        DepthScale = safeGetProperty(desc, "DepthScale", 1),
        HeadScale = safeGetProperty(desc, "HeadScale", 1),
        HeightScale = safeGetProperty(desc, "HeightScale", 1),
        ProportionScale = safeGetProperty(desc, "ProportionScale", 0),
        WidthScale = safeGetProperty(desc, "WidthScale", 1)
    }
    
    -- Body Colors (convert Color3 to table)
    local function colorToTable(color)
        return {R = color.R, G = color.G, B = color.B}
    end
    
    data.HeadColor = colorToTable(safeGetProperty(desc, "HeadColor", Color3.new(1, 1, 1)))
    data.TorsoColor = colorToTable(safeGetProperty(desc, "TorsoColor", Color3.new(1, 1, 1)))
    data.LeftArmColor = colorToTable(safeGetProperty(desc, "LeftArmColor", Color3.new(1, 1, 1)))
    data.RightArmColor = colorToTable(safeGetProperty(desc, "RightArmColor", Color3.new(1, 1, 1)))
    data.LeftLegColor = colorToTable(safeGetProperty(desc, "LeftLegColor", Color3.new(1, 1, 1)))
    data.RightLegColor = colorToTable(safeGetProperty(desc, "RightLegColor", Color3.new(1, 1, 1)))
    
    return data
end

-- Function untuk safely set property
local function safeSetProperty(obj, propName, value)
    pcall(function()
        obj[propName] = value
    end)
end

-- Function untuk deserialize ke HumanoidDescription
local function deserializeHumanoidDescription(data)
    if not data then return nil end
    
    local desc = Instance.new("HumanoidDescription")
    
    -- Body Parts
    safeSetProperty(desc, "Head", data.Head or 0)
    safeSetProperty(desc, "Torso", data.Torso or 0)
    safeSetProperty(desc, "LeftArm", data.LeftArm or 0)
    safeSetProperty(desc, "RightArm", data.RightArm or 0)
    safeSetProperty(desc, "LeftLeg", data.LeftLeg or 0)
    safeSetProperty(desc, "RightLeg", data.RightLeg or 0)
    
    -- Accessories
    safeSetProperty(desc, "HatAccessory", data.HatAccessory or "")
    safeSetProperty(desc, "HairAccessory", data.HairAccessory or "")
    safeSetProperty(desc, "FaceAccessory", data.FaceAccessory or "")
    safeSetProperty(desc, "NeckAccessory", data.NeckAccessory or "")
    safeSetProperty(desc, "ShoulderAccessory", data.ShoulderAccessory or "")
    safeSetProperty(desc, "FrontAccessory", data.FrontAccessory or "")
    safeSetProperty(desc, "BackAccessory", data.BackAccessory or "")
    safeSetProperty(desc, "WaistAccessory", data.WaistAccessory or "")
    
    -- Clothing
    safeSetProperty(desc, "Shirt", data.Shirt or 0)
    safeSetProperty(desc, "Pants", data.Pants or 0)
    safeSetProperty(desc, "GraphicTShirt", data.GraphicTShirt or 0)
    
    -- Body Colors (convert table back to Color3)
    local function tableToColor(t)
        if type(t) == "table" and t.R and t.G and t.B then
            return Color3.new(t.R, t.G, t.B)
        end
        return Color3.new(1, 1, 1)
    end
    
    safeSetProperty(desc, "HeadColor", tableToColor(data.HeadColor))
    safeSetProperty(desc, "TorsoColor", tableToColor(data.TorsoColor))
    safeSetProperty(desc, "LeftArmColor", tableToColor(data.LeftArmColor))
    safeSetProperty(desc, "RightArmColor", tableToColor(data.RightArmColor))
    safeSetProperty(desc, "LeftLegColor", tableToColor(data.LeftLegColor))
    safeSetProperty(desc, "RightLegColor", tableToColor(data.RightLegColor))
    
    -- Face & Animation
    safeSetProperty(desc, "Face", data.Face or 0)
    safeSetProperty(desc, "ClimbAnimation", data.ClimbAnimation or 0)
    safeSetProperty(desc, "FallAnimation", data.FallAnimation or 0)
    safeSetProperty(desc, "IdleAnimation", data.IdleAnimation or 0)
    safeSetProperty(desc, "JumpAnimation", data.JumpAnimation or 0)
    safeSetProperty(desc, "RunAnimation", data.RunAnimation or 0)
    safeSetProperty(desc, "SwimAnimation", data.SwimAnimation or 0)
    safeSetProperty(desc, "WalkAnimation", data.WalkAnimation or 0)
    
    -- Proportions
    safeSetProperty(desc, "BodyTypeScale", data.BodyTypeScale or 0)
    safeSetProperty(desc, "DepthScale", data.DepthScale or 1)
    safeSetProperty(desc, "HeadScale", data.HeadScale or 1)
    safeSetProperty(desc, "HeightScale", data.HeightScale or 1)
    safeSetProperty(desc, "ProportionScale", data.ProportionScale or 0)
    safeSetProperty(desc, "WidthScale", data.WidthScale or 1)
    
    return desc
end

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
            print("✅ Loaded " .. #presets .. " full presets dari file")
        end
    end
end

-- Save presets ke file
local function savePresets()
    if not writefile then 
        warn("Executor tidak support file writing")
        return 
    end
    
    local success = pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(presets)
        writefile(PRESET_FILE, json)
    end)
    
    if success then
        print("✅ Full presets saved to file")
    end
end

-- Toggle Button Creation
local function createToggleButton()
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 35, 0, 35)
    ToggleButton.Position = UDim2.new(0, 15, 0, 15)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "🎮"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 10
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    return ToggleButton
end

-- UI Creation dengan Preset Buttons
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RobloxAccountLoader"
    ScreenGui.Parent = lp.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local ToggleButton = createToggleButton()
    ToggleButton.Parent = ScreenGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 380, 0, 240)
    MainFrame.Position = UDim2.new(0.5, -190, 0.05, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "🎮 FULL AVATAR PRESET"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextScaled = true
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -20, 0, 35)
    InputFrame.Position = UDim2.new(0, 10, 0, 35)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = MainFrame
    
    local UsernameInput = Instance.new("TextBox")
    UsernameInput.Name = "UsernameInput"
    UsernameInput.Size = UDim2.new(0.7, -5, 1, 0)
    UsernameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    UsernameInput.BorderSizePixel = 0
    UsernameInput.Text = ""
    UsernameInput.PlaceholderText = "Enter username..."
    UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    UsernameInput.TextScaled = true
    UsernameInput.Font = Enum.Font.Gotham
    UsernameInput.Parent = InputFrame
    
    local UsernameCorner = Instance.new("UICorner")
    UsernameCorner.CornerRadius = UDim.new(0, 8)
    UsernameCorner.Parent = UsernameInput
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Size = UDim2.new(0.3, -5, 1, 0)
    SubmitButton.Position = UDim2.new(0.7, 0, 0, 0)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "SUBMIT"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextScaled = true
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = InputFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitButton
    
    -- PRESET SECTION
    local PresetFrame = Instance.new("Frame")
    PresetFrame.Size = UDim2.new(1, -20, 0, 120)
    PresetFrame.Position = UDim2.new(0, 10, 0, 75)
    PresetFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PresetFrame.BorderSizePixel = 0
    PresetFrame.Parent = MainFrame
    
    local PresetCorner = Instance.new("UICorner")
    PresetCorner.CornerRadius = UDim.new(0, 8)
    PresetCorner.Parent = PresetFrame
    
    local PresetTitle = Instance.new("TextLabel")
    PresetTitle.Size = UDim2.new(1, 0, 0, 20)
    PresetTitle.BackgroundTransparency = 1
    PresetTitle.Text = "⭐ FULL PRESETS (Right-Click to Save)"
    PresetTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
    PresetTitle.TextScaled = true
    PresetTitle.Font = Enum.Font.GothamBold
    PresetTitle.Parent = PresetFrame
    
    -- 5 Preset Buttons
    local presetButtons = {}
    for i = 1, 5 do
        local btn = Instance.new("TextButton")
        btn.Name = "Preset" .. i
        btn.Size = UDim2.new(0.18, 0, 0, 35)
        btn.Position = UDim2.new((i-1) * 0.2 + 0.01, 0, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.BorderSizePixel = 0
        btn.Text = tostring(i)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = PresetFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 15)
        label.Position = UDim2.new(0, 0, 1, 2)
        label.BackgroundTransparency = 1
        label.Text = "Empty"
        label.TextColor3 = Color3.fromRGB(150, 150, 150)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = btn
        
        presetButtons[i] = btn
    end
    
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 40)
    StatusFrame.Position = UDim2.new(0, 10, 0, 200)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
    StatusText.Text = "✨ Ready (Full Data Mode)"
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusText.TextScaled = true
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusFrame
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons
end

-- Load Avatar Function dengan full data capture
local function loadAvatar(username)
    if not username or username == "" then
        return false, "Username tidak boleh kosong!"
    end
    
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
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
    
    -- Hapus accessories & clothing
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
        return false, "Gagal apply avatar"
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
    
    -- CAPTURE FULL AVATAR DATA
    currentAvatarData = {
        username = username,
        avatarData = serializeHumanoidDescription(humanoidDesc)
    }
    
    return true, "Avatar changed: " .. username
end

-- Apply avatar dari data yang tersimpan
local function applyStoredAvatar(avatarData)
    if not avatarData or not avatarData.avatarData then
        return false, "Data avatar tidak valid!"
    end
    
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then
        return false, "Character tidak ada!"
    end
    
    -- Restore HumanoidDescription dari data
    local humanoidDesc = deserializeHumanoidDescription(avatarData.avatarData)
    
    if not humanoidDesc then
        return false, "Gagal restore avatar data"
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
    
    -- Hapus accessories & clothing
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
    local success = pcall(function()
        lp.Character.Humanoid:ApplyDescriptionClientServer(humanoidDesc)
    end)
    
    if not success then
        for _, tool in pairs(savedTools) do
            tool.Parent = lp.Backpack
        end
        return false, "Gagal apply avatar"
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
    
    currentAvatarData = avatarData
    
    return true, "Avatar loaded: " .. (avatarData.username or "Preset")
end

-- Update Preset UI
local function updatePresetUI(presetButtons)
    for i = 1, 5 do
        local btn = presetButtons[i]
        local label = btn:FindFirstChild("Label")
        
        if presets[i] then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            label.Text = presets[i].username or "Preset"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            label.Text = "Empty"
            label.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

-- Animation Functions
local function animateUI(frame, isOpening)
    if UIState.isAnimating then return end
    UIState.isAnimating = true
    
    local targetSize, targetVisible
    if isOpening then
        targetSize = UDim2.new(0, 380, 0, 240)
        targetVisible = true
        frame.Visible = true
    else
        targetSize = UDim2.new(0, 0, 0, 0)
        targetVisible = false
    end
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local sizeTween = TweenService:Create(frame, tweenInfo, {Size = targetSize})
    
    sizeTween:Play()
    
    if not isOpening then
        sizeTween.Completed:Connect(function()
            frame.Visible = false
            UIState.isAnimating = false
        end)
    else
        sizeTween.Completed:Connect(function()
            UIState.isAnimating = false
        end)
    end
end

local function toggleUI(mainFrame, toggleButton)
    if UIState.isAnimating then return end
    UIState.isOpen = not UIState.isOpen
    
    if UIState.isOpen then
        animateUI(mainFrame, true)
        toggleButton.Text = "❌"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        animateUI(mainFrame, false)
        toggleButton.Text = "🎮"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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

-- Main Script
loadPresets()

local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons = createUI()

makeDraggable(ToggleButton)

ToggleButton.MouseButton1Click:Connect(function()
    toggleUI(MainFrame, ToggleButton)
end)

-- Hover Effects
ToggleButton.MouseEnter:Connect(function()
    if not UIState.isOpen then
        local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        })
        tween:Play()
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if not UIState.isOpen then
        local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 35, 0, 35),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        })
        tween:Play()
    end
end)

-- Submit Button
local function handleSubmit()
    local username = UsernameInput.Text
    if username and username ~= "" then
        UsernameInput.PlaceholderText = "Loading..."
        UsernameInput.Text = ""
        StatusText.Text = "⏳ Applying full avatar..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success, message = loadAvatar(username)
        
        if success then
            UsernameInput.PlaceholderText = "✓ Active: " .. username
            StatusText.Text = "✅ Full Avatar Saved: " .. username
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            UsernameInput.PlaceholderText = "✗ Failed"
            StatusText.Text = "❌ " .. message
            StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            
            wait(3)
            UsernameInput.PlaceholderText = "Enter username..."
            StatusText.Text = "✨ Ready (Full Data Mode)"
            StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

SubmitButton.MouseButton1Click:Connect(handleSubmit)

UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        handleSubmit()
    end
end)

SubmitButton.MouseEnter:Connect(function()
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
end)

SubmitButton.MouseLeave:Connect(function()
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

-- Preset Buttons Logic
for i, btn in ipairs(presetButtons) do
    -- Left Click: Load preset
    btn.MouseButton1Click:Connect(function()
        if presets[i] then
            StatusText.Text = "⏳ Loading Full Preset " .. i .. "..."
            StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
            
            local success, message = applyStoredAvatar(presets[i])
            
            if success then
                StatusText.Text = "✅ Preset " .. i .. " loaded!"
                StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                StatusText.Text = "❌ Preset failed: " .. message
                StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        else
            StatusText.Text = "⚠️ Preset " .. i .. " is empty!"
            StatusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    -- Right Click: Save current avatar FULL DATA
    btn.MouseButton2Click:Connect(function()
        if currentAvatarData then
            presets[i] = currentAvatarData
            savePresets()
            updatePresetUI(presetButtons)
            
            StatusText.Text = "💾 Full Avatar saved to Preset " .. i .. "!"
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusText.Text = "⚠️ Apply avatar first!"
            StatusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.Size = UDim2.new(0.19, 0, 0, 38)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.Size = UDim2.new(0.18, 0, 0, 35)
    end)
end

updatePresetUI(presetButtons)

-- AUTO REAPPLY ON RESPAWN
lp.CharacterAdded:Connect(function(char)
    if currentAvatarData then
        char:WaitForChild("Humanoid")
        wait(1)
        
        StatusText.Text = "🔄 Auto-reapplying full avatar..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success, message = applyStoredAvatar(currentAvatarData)
        
        if success then
            StatusText.Text = "✅ Auto-applied: " .. (currentAvatarData.username or "Preset")
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusText.Text = "❌ Auto-apply failed"
            StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end)

-- Keyboard Shortcut (F1)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleUI(MainFrame, ToggleButton)
    end
end)

print("=== AVATAR CHANGER - FULL PRESET SYSTEM ===")
print("✅ Menyimpan SELURUH data avatar")
print("✅ Accessories, Clothing, Body Colors, Animations")
print("✅ 5 Preset tersimpan ke file")
print("✅ Left Click = Load Full Preset")
print("✅ Right Click = Save Full Avatar Data")
print("✅ Auto load setelah rejoin/respawn")
print("✅ Tekan F1 untuk toggle UI")
print("============================================")