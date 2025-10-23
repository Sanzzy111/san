-- AVATAR CHANGER - FIXED TOOL PERSISTENCE + PRESET SYSTEM + FILE STORAGE
-- ✅ Tools tidak hilang saat equip
-- ✅ Auto reapply avatar setelah respawn
-- ✅ Speedcoil, Gravity Coil work 100%
-- 🆕 5 Preset Slots untuk simpan avatar favorit
-- 💾 Preset tersimpan di file (persistent across maps)

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

-- 🆕 PRESET STORAGE (5 SLOTS)
local AvatarPresets = {
    slot1 = nil,
    slot2 = nil,
    slot3 = nil,
    slot4 = nil,
    slot5 = nil
}

-- 💾 LOAD PRESETS FROM FILE
local function loadPresetsFromFile()
    local success, result = pcall(function()
        return readfile("Delta/Workspace/AvatarPresets.json")
    end)
    
    if success and result then
        local decoded = HttpService:JSONDecode(result)
        if decoded then
            AvatarPresets = decoded
            print("✅ Loaded presets from file")
            return true
        end
    end
    
    print("⚠️ No saved presets found, starting fresh")
    return false
end

-- 💾 SAVE PRESETS TO FILE
local function savePresetsToFile()
    local success, err = pcall(function()
        local encoded = HttpService:JSONEncode(AvatarPresets)
        writefile("Delta/Workspace/AvatarPresets.json", encoded)
    end)
    
    if success then
        print("✅ Presets saved to file")
        return true
    else
        warn("❌ Failed to save presets:", tostring(err))
        return false
    end
end

-- Toggle Button Creation (Draggable)
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

-- 🆕 PRESET BUTTONS CREATION
local function createPresetButtons(parent)
    local PresetFrame = Instance.new("Frame")
    PresetFrame.Name = "PresetFrame"
    PresetFrame.Size = UDim2.new(1, -20, 0, 70)
    PresetFrame.Position = UDim2.new(0, 10, 0, 120)
    PresetFrame.BackgroundTransparency = 1
    PresetFrame.Parent = parent
    
    local PresetTitle = Instance.new("TextLabel")
    PresetTitle.Size = UDim2.new(1, 0, 0, 20)
    PresetTitle.BackgroundTransparency = 1
    PresetTitle.Text = "💾 AVATAR PRESETS (Saved)"
    PresetTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
    PresetTitle.TextScaled = true
    PresetTitle.Font = Enum.Font.GothamBold
    PresetTitle.Parent = PresetFrame
    
    local ButtonsContainer = Instance.new("Frame")
    ButtonsContainer.Size = UDim2.new(1, 0, 0, 45)
    ButtonsContainer.Position = UDim2.new(0, 0, 0, 25)
    ButtonsContainer.BackgroundTransparency = 1
    ButtonsContainer.Parent = PresetFrame
    
    local presetButtons = {}
    
    for i = 1, 5 do
        local slotName = "slot" .. i
        
        local SlotButton = Instance.new("TextButton")
        SlotButton.Name = "PresetSlot" .. i
        SlotButton.Size = UDim2.new(0.18, 0, 1, 0)
        SlotButton.Position = UDim2.new((i-1) * 0.2 + 0.01, 0, 0, 0)
        SlotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SlotButton.BorderSizePixel = 0
        SlotButton.Text = "SLOT " .. i
        SlotButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        SlotButton.TextScaled = true
        SlotButton.Font = Enum.Font.GothamBold
        SlotButton.Parent = ButtonsContainer
        
        local SlotCorner = Instance.new("UICorner")
        SlotCorner.CornerRadius = UDim.new(0, 8)
        SlotCorner.Parent = SlotButton
        
        local SlotLabel = Instance.new("TextLabel")
        SlotLabel.Name = "SlotLabel"
        SlotLabel.Size = UDim2.new(1, 0, 0.4, 0)
        SlotLabel.Position = UDim2.new(0, 0, 0.6, 0)
        SlotLabel.BackgroundTransparency = 1
        SlotLabel.Text = "Empty"
        SlotLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        SlotLabel.TextScaled = true
        SlotLabel.Font = Enum.Font.Gotham
        SlotLabel.Parent = SlotButton
        
        presetButtons[slotName] = {button = SlotButton, label = SlotLabel}
    end
    
    return presetButtons
end

-- UI Creation
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
    MainFrame.Size = UDim2.new(0, 380, 0, 195)
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
    TitleText.Text = "🎮 AVATAR CHANGER (SAVED)"
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
    UsernameInput.Size = UDim2.new(0.5, -5, 1, 0)
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
    SubmitButton.Size = UDim2.new(0.25, -5, 1, 0)
    SubmitButton.Position = UDim2.new(0.5, 0, 0, 0)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "APPLY"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextScaled = true
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = InputFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitButton
    
    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Size = UDim2.new(0.25, -5, 1, 0)
    SaveButton.Position = UDim2.new(0.75, 0, 0, 0)
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    SaveButton.BorderSizePixel = 0
    SaveButton.Text = "SAVE"
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.TextScaled = true
    SaveButton.Font = Enum.Font.GothamBold
    SaveButton.Parent = InputFrame
    
    local SaveCorner = Instance.new("UICorner")
    SaveCorner.CornerRadius = UDim.new(0, 8)
    SaveCorner.Parent = SaveButton
    
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 40)
    StatusFrame.Position = UDim2.new(0, 10, 0, 75)
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
    StatusText.Text = "✨ Ready (Tools Protected)"
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusText.TextScaled = true
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusFrame
    
    local PresetButtons = createPresetButtons(MainFrame)
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, SaveButton, PresetButtons
end

-- FUNGSI UTAMA: SIMPAN DAN RESTORE TOOLS
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
    
    -- ===== KUNCI: SIMPAN SEMUA TOOLS SEBELUM APPLY =====
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
    
    -- ===== RESTORE SEMUA TOOLS =====
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

-- 🆕 UPDATE PRESET BUTTON DISPLAY
local function updatePresetDisplay(presetButtons)
    for i = 1, 5 do
        local slotName = "slot" .. i
        local button = presetButtons[slotName].button
        local label = presetButtons[slotName].label
        
        if AvatarPresets[slotName] then
            label.Text = AvatarPresets[slotName]
            label.TextColor3 = Color3.fromRGB(0, 255, 100)
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            label.Text = "Empty"
            label.TextColor3 = Color3.fromRGB(100, 100, 100)
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            button.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

-- Animation Functions
local function animateUI(frame, isOpening)
    if UIState.isAnimating then return end
    UIState.isAnimating = true
    
    local targetSize, targetVisible
    if isOpening then
        targetSize = UDim2.new(0, 380, 0, 195)
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

-- Drag Function
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

-- 💾 LOAD PRESETS SAAT START
loadPresetsFromFile()

-- Main Script
local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, SaveButton, PresetButtons = createUI()

-- Update display setelah load
updatePresetDisplay(PresetButtons)

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
        StatusText.Text = "⏳ Applying avatar..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success, message = loadAvatar(username)
        
        if success then
            lastAppliedUsername = username
            UsernameInput.PlaceholderText = "✓ Active: " .. username
            StatusText.Text = "✅ Tools Protected: " .. username
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            UsernameInput.PlaceholderText = "✗ Failed"
            StatusText.Text = "❌ " .. message
            StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            
            wait(3)
            UsernameInput.PlaceholderText = "Enter username..."
            StatusText.Text = "✨ Ready (Tools Protected)"
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

-- 💾 SAVE BUTTON LOGIC (NOW WITH FILE SAVE)
local selectedSlot = nil

SaveButton.MouseButton1Click:Connect(function()
    if not lastAppliedUsername then
        StatusText.Text = "⚠️ Apply avatar dulu sebelum save!"
        StatusText.TextColor3 = Color3.fromRGB(255, 150, 0)
        wait(2)
        StatusText.Text = "✨ Ready (Tools Protected)"
        StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        return
    end
    
    if not selectedSlot then
        StatusText.Text = "⚠️ Pilih slot preset dulu (klik salah satu slot)!"
        StatusText.TextColor3 = Color3.fromRGB(255, 150, 0)
        wait(3)
        StatusText.Text = "✨ Ready (Tools Protected)"
        StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        return
    end
    
    AvatarPresets[selectedSlot] = lastAppliedUsername
    savePresetsToFile() -- 💾 SAVE TO FILE
    updatePresetDisplay(PresetButtons)
    
    StatusText.Text = "💾 Saved to file: " .. lastAppliedUsername
    StatusText.TextColor3 = Color3.fromRGB(0, 200, 255)
    
    wait(2)
    StatusText.Text = "✅ Tools Protected: " .. lastAppliedUsername
    StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    selectedSlot = nil
end)

SaveButton.MouseEnter:Connect(function()
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
end)

SaveButton.MouseLeave:Connect(function()
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
end)

-- PRESET BUTTONS LOGIC
for i = 1, 5 do
    local slotName = "slot" .. i
    local button = PresetButtons[slotName].button
    
    button.MouseButton1Click:Connect(function()
        if AvatarPresets[slotName] then
            StatusText.Text = "⏳ Loading preset..."
            StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
            
            local success, message = loadAvatar(AvatarPresets[slotName])
            
            if success then
                lastAppliedUsername = AvatarPresets[slotName]
                UsernameInput.PlaceholderText = "✓ Preset: " .. AvatarPresets[slotName]
                StatusText.Text = "✅ Loaded: " .. AvatarPresets[slotName]
                StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                StatusText.Text = "❌ " .. message
                StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        else
            selectedSlot = slotName
            StatusText.Text = "📌 Selected " .. slotName:upper() .. " for saving"
            StatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
            
            for j = 1, 5 do
                local otherSlot = "slot" .. j
                if AvatarPresets[otherSlot] then
                    PresetButtons[otherSlot].button.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
                else
                    PresetButtons[otherSlot].button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end
            end
            button.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        end
    end)
    
    -- Long press to delete preset
    local pressTime = 0
    button.MouseButton1Down:Connect(function()
        pressTime = tick()
    end)
    
    button.MouseButton1Up:Connect(function()
        if tick() - pressTime >= 1.5 and AvatarPresets[slotName] then
            AvatarPresets[slotName] = nil
            savePresetsToFile() -- 💾 SAVE AFTER DELETE
            updatePresetDisplay(PresetButtons)
            StatusText.Text = "🗑️ Deleted " .. slotName:upper()
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            wait(2)
            StatusText.Text = "✨ Ready (Tools Protected)"
            StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
    
    button.MouseEnter:Connect(function()
        if AvatarPresets[slotName] then
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
        else
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if AvatarPresets[slotName] then
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
        else
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end)
end

-- AUTO REAPPLY ON RESPAWN
lp.CharacterAdded:Connect(function(char)
    if lastAppliedUsername then
        char:WaitForChild("Humanoid")
        wait(1)
        
        StatusText.Text = "🔄 Auto-reapplying: " .. lastAppliedUsername
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success, message = loadAvatar(lastAppliedUsername)
        
        if success then
            StatusText.Text = "✅ Auto-applied: " .. lastAppliedUsername
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

print("=
