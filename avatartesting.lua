-- AVATAR CHANGER - MODERN PRESET SYSTEM
-- Mobile Friendly with Save/Load Dialog
-- 8 Preset Slots with File Persistence

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- State Management
local UIState = {
    isOpen = false,
    isAnimating = false,
    selectedPreset = nil
}

local lastAppliedUsername = nil
local presets = {}
local PRESET_FILE = "avatar_presets.json"

-- Colors
local Colors = {
    Background = Color3.fromRGB(18, 18, 24),
    Surface = Color3.fromRGB(25, 25, 35),
    Primary = Color3.fromRGB(139, 92, 246),
    PrimaryHover = Color3.fromRGB(167, 139, 250),
    Secondary = Color3.fromRGB(45, 45, 60),
    Success = Color3.fromRGB(74, 222, 128),
    Error = Color3.fromRGB(248, 113, 113),
    Warning = Color3.fromRGB(251, 191, 36),
    Text = Color3.fromRGB(226, 232, 240),
    TextMuted = Color3.fromRGB(148, 163, 184)
}

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
            print("Loaded " .. #presets .. " presets from file")
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
        print("Presets saved to file")
    end
end

-- Toggle Button Creation
local function createToggleButton()
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 15, 0, 15)
    ToggleButton.BackgroundColor3 = Colors.Primary
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "A"
    ToggleButton.TextColor3 = Colors.Text
    ToggleButton.TextSize = 24
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 10
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleButton
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = 9
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.Parent = ToggleButton
    
    return ToggleButton
end

-- Dialog untuk Save/Load
local function createPresetDialog(parent)
    local Dialog = Instance.new("Frame")
    Dialog.Name = "PresetDialog"
    Dialog.Size = UDim2.new(0, 200, 0, 100)
    Dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    Dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    Dialog.BackgroundColor3 = Colors.Surface
    Dialog.BorderSizePixel = 0
    Dialog.Visible = false
    Dialog.ZIndex = 100
    Dialog.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Dialog
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "Preset Actions"
    Title.TextColor3 = Colors.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 101
    Title.Parent = Dialog
    
    local LoadButton = Instance.new("TextButton")
    LoadButton.Name = "LoadButton"
    LoadButton.Size = UDim2.new(0, 85, 0, 35)
    LoadButton.Position = UDim2.new(0, 10, 0, 50)
    LoadButton.BackgroundColor3 = Colors.Primary
    LoadButton.BorderSizePixel = 0
    LoadButton.Text = "LOAD"
    LoadButton.TextColor3 = Colors.Text
    LoadButton.TextSize = 14
    LoadButton.Font = Enum.Font.GothamBold
    LoadButton.ZIndex = 101
    LoadButton.Parent = Dialog
    
    local LoadCorner = Instance.new("UICorner")
    LoadCorner.CornerRadius = UDim.new(0, 8)
    LoadCorner.Parent = LoadButton
    
    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Size = UDim2.new(0, 85, 0, 35)
    SaveButton.Position = UDim2.new(0, 105, 0, 50)
    SaveButton.BackgroundColor3 = Colors.Success
    SaveButton.BorderSizePixel = 0
    SaveButton.Text = "SAVE"
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.TextSize = 14
    SaveButton.Font = Enum.Font.GothamBold
    SaveButton.ZIndex = 101
    SaveButton.Parent = Dialog
    
    local SaveCorner = Instance.new("UICorner")
    SaveCorner.CornerRadius = UDim.new(0, 8)
    SaveCorner.Parent = SaveButton
    
    -- Backdrop
    local Backdrop = Instance.new("TextButton")
    Backdrop.Name = "Backdrop"
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Backdrop.BackgroundTransparency = 0.5
    Backdrop.BorderSizePixel = 0
    Backdrop.Text = ""
    Backdrop.ZIndex = 99
    Backdrop.Visible = false
    Backdrop.Parent = parent
    
    return Dialog, Backdrop, LoadButton, SaveButton
end

-- UI Creation dengan 8 Preset Buttons
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
    MainFrame.Size = UDim2.new(0, 360, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Colors.Surface
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar
    
    local TitleCover = Instance.new("Frame")
    TitleCover.Size = UDim2.new(1, 0, 0, 25)
    TitleCover.Position = UDim2.new(0, 0, 1, -25)
    TitleCover.BackgroundColor3 = Colors.Surface
    TitleCover.BorderSizePixel = 0
    TitleCover.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "AVATAR CHANGER"
    TitleText.TextColor3 = Colors.Text
    TitleText.TextSize = 18
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, -20, 0, 15)
    SubTitle.Position = UDim2.new(0, 10, 0, 28)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Preset System with Tool Protection"
    SubTitle.TextColor3 = Colors.TextMuted
    SubTitle.TextSize = 11
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.Parent = TitleBar
    
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -30, 0, 40)
    InputFrame.Position = UDim2.new(0, 15, 0, 65)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = MainFrame
    
    local UsernameInput = Instance.new("TextBox")
    UsernameInput.Name = "UsernameInput"
    UsernameInput.Size = UDim2.new(0.65, -5, 1, 0)
    UsernameInput.BackgroundColor3 = Colors.Secondary
    UsernameInput.BorderSizePixel = 0
    UsernameInput.Text = ""
    UsernameInput.PlaceholderText = "Enter username"
    UsernameInput.PlaceholderColor3 = Colors.TextMuted
    UsernameInput.TextColor3 = Colors.Text
    UsernameInput.TextSize = 14
    UsernameInput.Font = Enum.Font.Gotham
    UsernameInput.Parent = InputFrame
    
    local UsernameCorner = Instance.new("UICorner")
    UsernameCorner.CornerRadius = UDim.new(0, 10)
    UsernameCorner.Parent = UsernameInput
    
    local UsernamePadding = Instance.new("UIPadding")
    UsernamePadding.PaddingLeft = UDim.new(0, 12)
    UsernamePadding.Parent = UsernameInput
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Size = UDim2.new(0.35, -5, 1, 0)
    SubmitButton.Position = UDim2.new(0.65, 0, 0, 0)
    SubmitButton.BackgroundColor3 = Colors.Primary
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "APPLY"
    SubmitButton.TextColor3 = Colors.Text
    SubmitButton.TextSize = 14
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = InputFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 10)
    SubmitCorner.Parent = SubmitButton
    
    -- PRESET SECTION
    local PresetFrame = Instance.new("Frame")
    PresetFrame.Size = UDim2.new(1, -30, 0, 260)
    PresetFrame.Position = UDim2.new(0, 15, 0, 120)
    PresetFrame.BackgroundColor3 = Colors.Surface
    PresetFrame.BorderSizePixel = 0
    PresetFrame.Parent = MainFrame
    
    local PresetCorner = Instance.new("UICorner")
    PresetCorner.CornerRadius = UDim.new(0, 12)
    PresetCorner.Parent = PresetFrame
    
    local PresetTitle = Instance.new("TextLabel")
    PresetTitle.Size = UDim2.new(1, -20, 0, 30)
    PresetTitle.Position = UDim2.new(0, 10, 0, 10)
    PresetTitle.BackgroundTransparency = 1
    PresetTitle.Text = "PRESET SLOTS"
    PresetTitle.TextColor3 = Colors.Primary
    PresetTitle.TextSize = 14
    PresetTitle.Font = Enum.Font.GothamBold
    PresetTitle.TextXAlignment = Enum.TextXAlignment.Left
    PresetTitle.Parent = PresetFrame
    
    local PresetSubtitle = Instance.new("TextLabel")
    PresetSubtitle.Size = UDim2.new(1, -20, 0, 15)
    PresetSubtitle.Position = UDim2.new(0, 10, 0, 28)
    PresetSubtitle.BackgroundTransparency = 1
    PresetSubtitle.Text = "Tap preset to save or load avatar"
    PresetSubtitle.TextColor3 = Colors.TextMuted
    PresetSubtitle.TextSize = 11
    PresetSubtitle.Font = Enum.Font.Gotham
    PresetSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    PresetSubtitle.Parent = PresetFrame
    
    -- 8 Preset Buttons (2 rows x 4 columns)
    local presetButtons = {}
    for i = 1, 8 do
        local row = math.floor((i-1) / 4)
        local col = (i-1) % 4
        
        local btn = Instance.new("TextButton")
        btn.Name = "Preset" .. i
        btn.Size = UDim2.new(0, 70, 0, 80)
        btn.Position = UDim2.new(0, 10 + col * 75, 0, 50 + row * 90)
        btn.BackgroundColor3 = Colors.Secondary
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Font = Enum.Font.GothamBold
        btn.Parent = PresetFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn
        
        local number = Instance.new("TextLabel")
        number.Name = "Number"
        number.Size = UDim2.new(1, 0, 0, 25)
        number.Position = UDim2.new(0, 0, 0, 5)
        number.BackgroundTransparency = 1
        number.Text = tostring(i)
        number.TextColor3 = Colors.TextMuted
        number.TextSize = 18
        number.Font = Enum.Font.GothamBold
        number.Parent = btn
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -10, 0, 40)
        label.Position = UDim2.new(0, 5, 0, 35)
        label.BackgroundTransparency = 1
        label.Text = "Empty"
        label.TextColor3 = Colors.TextMuted
        label.TextSize = 10
        label.Font = Enum.Font.Gotham
        label.TextWrapped = true
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Parent = btn
        
        presetButtons[i] = btn
    end
    
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -30, 0, 35)
    StatusFrame.Position = UDim2.new(0, 15, 1, -45)
    StatusFrame.BackgroundColor3 = Colors.Surface
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = StatusFrame
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Ready"
    StatusText.TextColor3 = Colors.TextMuted
    StatusText.TextSize = 12
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusFrame
    
    -- Create Dialog
    local Dialog, Backdrop, LoadButton, SaveButton = createPresetDialog(ScreenGui)
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons, Dialog, Backdrop, LoadButton, SaveButton
end

-- Load Avatar Function
local function loadAvatar(username)
    if not username or username == "" then
        return false, "Username tidak boleh kosong"
    end
    
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if not success then
        return false, "Username tidak ditemukan: " .. username
    end
    
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then
        return false, "Character tidak ada"
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
    
    return true, "Avatar changed: " .. username
end

-- Update Preset UI
local function updatePresetUI(presetButtons)
    for i = 1, 8 do
        local btn = presetButtons[i]
        local label = btn:FindFirstChild("Label")
        
        if presets[i] then
            btn.BackgroundColor3 = Colors.Primary
            label.Text = presets[i]
            label.TextColor3 = Colors.Text
        else
            btn.BackgroundColor3 = Colors.Secondary
            label.Text = "Empty"
            label.TextColor3 = Colors.TextMuted
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
    end
    
    local targetSize = isOpening and UDim2.new(0, 360, 0, 420) or UDim2.new(0, 0, 0, 0)
    local targetPos = isOpening and UDim2.new(0.5, -180, 0.5, -210) or UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, isOpening and Enum.EasingDirection.Out or Enum.EasingDirection.In)
    local tween = TweenService:Create(frame, tweenInfo, {Size = targetSize, Position = targetPos})
    
    tween:Play()
    tween.Completed:Connect(function()
        if not isOpening then
            frame.Visible = false
        end
        UIState.isAnimating = false
    end)
end

local function toggleUI(mainFrame, toggleButton)
    if UIState.isAnimating then return end
    UIState.isOpen = not UIState.isOpen
    
    animateUI(mainFrame, UIState.isOpen)
    
    local tween = TweenService:Create(toggleButton, TweenInfo.new(0.2), {
        BackgroundColor3 = UIState.isOpen and Colors.Error or Colors.Primary,
        Rotation = UIState.isOpen and 90 or 0
    })
    tween:Play()
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

local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons, Dialog, Backdrop, LoadButton, SaveButton = createUI()

makeDraggable(ToggleButton)

ToggleButton.MouseButton1Click:Connect(function()
    toggleUI(MainFrame, ToggleButton)
end)

-- Submit Button
local function handleSubmit()
    local username = UsernameInput.Text
    if username and username ~= "" then
        UsernameInput.PlaceholderText = "Loading..."
        UsernameInput.Text = ""
        StatusText.Text = "Applying avatar..."
        StatusText.TextColor3 = Colors.Warning
        
        local success, message = loadAvatar(username)
        
        if success then
            lastAppliedUsername = username
            UsernameInput.PlaceholderText = "Active: " .. username
            StatusText.Text = "Tools Protected: " .. username
            StatusText.TextColor3 = Colors.Success
        else
            UsernameInput.PlaceholderText = "Failed"
            StatusText.Text = message
            StatusText.TextColor3 = Colors.Error
            
            wait(3)
            UsernameInput.PlaceholderText = "Enter username"
            StatusText.Text = "Ready"
            StatusText.TextColor3 = Colors.TextMuted
        end
    end
end

SubmitButton.MouseButton1Click:Connect(handleSubmit)

UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        handleSubmit()
    end
end)

-- Button Hover Effects
local function addButtonHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

addButtonHover(SubmitButton, Colors.Primary, Colors.PrimaryHover)

-- Dialog Functions
local function showDialog(presetIndex)
    UIState.selectedPreset = presetIndex
    Dialog.Visible = true
    Backdrop.Visible = true
    
    Dialog:FindFirstChild("Title").Text = "Preset " .. presetIndex
    
    Dialog.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(Dialog, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 200, 0, 100)
    }):Play()
end

local function hideDialog()
    TweenService:Create(Dialog, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    wait(0.2)
    Dialog.Visible = false
    Backdrop.Visible = false
    UIState.selectedPreset = nil
end

Backdrop.MouseButton1Click:Connect(hideDialog)

-- Load Button
LoadButton.MouseButton1Click:Connect(function()
    if UIState.selectedPreset and presets[UIState.selectedPreset] then
        hideDialog()
        
        StatusText.Text = "Loading Preset " .. UIState.selectedPreset .. "..."
        StatusText.TextColor3 = Colors.Warning
        
        local success, message = loadAvatar(presets[UIState.selectedPreset])
        
        if success then
            lastAppliedUsername = presets[UIState.selectedPreset]
            StatusText.Text = "Preset " .. UIState.selectedPreset .. " loaded"
            StatusText.TextColor3 = Colors.Success
        else
            StatusText.Text = message
            StatusText.TextColor3 = Colors.Error
        end
    else
        StatusText.Text = "Preset is empty"
        StatusText.TextColor3 = Colors.Warning
        hideDialog()
    end
end)

-- Save Button
SaveButton.MouseButton1Click:Connect(function()
    if UIState.selectedPreset and lastAppliedUsername then
        presets[UIState.selectedPreset] = lastAppliedUsername
        savePresets()
        updatePresetUI(presetButtons)
        
        StatusText.Text = "Saved to Preset " .. UIState.selectedPreset
        StatusText.TextColor3 = Colors.Success
        hideDialog()
    else
        StatusText.Text = "Apply avatar first"
        StatusText.TextColor3 = Colors.Warning
        hideDialog()
    end
end)

addButtonHover(LoadButton, Colors.Primary, Colors.PrimaryHover)
addButtonHover(SaveButton, Colors.Success, Color3.fromRGB(34, 197, 94))

-- Preset Buttons Logic
for i, btn in ipairs(presetButtons) do
    btn.MouseButton1Click:Connect(function()
        showDialog(i)
    end)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 75, 0, 85)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 70, 0, 80)
        }):Play()
    end)
end

updatePresetUI(presetButtons)

-- Toggle Button Hover
ToggleButton.MouseEnter:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 55, 0, 55),
            BackgroundColor3 = Colors.PrimaryHover
        }):Play()
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 50, 0, 50),
            BackgroundColor3 = Colors.Primary
        }):Play()
    end
end)

-- AUTO REAPPLY ON RESPAWN
lp.CharacterAdded:Connect(function(char)
    if lastAppliedUsername then
        char:WaitForChild("Humanoid")
        wait(1)
        
        StatusText.Text = "Auto-reapplying: " .. lastAppliedUsername
        StatusText.TextColor3 = Colors.Warning
        
        local success, message = loadAvatar(lastAppliedUsername)
        
        if success then
            StatusText.Text = "Auto-applied: " .. lastAppliedUsername
            StatusText.TextColor3 = Colors.Success
        else
            StatusText.Text = "Auto-apply failed"
            StatusText.TextColor3 = Colors.Error
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

print("===========================================")
print("Hello World")
print("===========================================")
