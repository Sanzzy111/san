-- AVATAR CHANGER - PRESET SYSTEM
-- 5 Preset Avatar disimpan sebagai FULL SNAPSHOT
-- Auto load setelah rejoin/ganti map
-- Tools tidak hilang saat equip
-- Avatar tetap meski user asli ganti avatar

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
local lastAppliedDesc = nil
local presets = {}
local PRESET_FILE = "avatar_presets.json"

-- Serialize HumanoidDescription ke table
local function getDescTable(desc)
    local descTable = {}
    
    local props = {
        "Accessories", "BackAccessory", "ClimbAnimation", "FaceAccessory", "FallAnimation", 
        "FrontAccessory", "GraphicTShirt", "HairAccessory", "HatAccessory", "IdleAnimation", 
        "JumpAnimation", "MoodAnimation", "NeckAccessory", "Pants", "RunAnimation", 
        "Shirt", "ShouldersAccessory", "SwimAnimation", "WaistAccessory", "WalkAnimation", 
        "Emotes", "EquippedEmotes", "Face", "Head", "LeftArm", "LeftLeg", "RightArm", 
        "RightLeg", "Torso"
    }
    for _, prop in ipairs(props) do
        descTable[prop] = desc[prop]
    end
    
    local scales = {"BodyTypeScale", "DepthScale", "HeadScale", "HeightScale", "ProportionScale", "WidthScale"}
    for _, prop in ipairs(scales) do
        descTable[prop] = desc[prop]
    end
    
    local colors = {"HeadColor", "LeftArmColor", "LeftLegColor", "RightArmColor", "RightLegColor", "TorsoColor"}
    for _, prop in ipairs(colors) do
        local c = desc[prop]
        descTable[prop] = {c.R, c.G, c.B}
    end
    
    return descTable
end

-- Buat HumanoidDescription dari table
local function createDescFromTable(tbl)
    local desc = Instance.new("HumanoidDescription")
    for prop, value in pairs(tbl) do
        if type(value) == "table" and #value == 3 then
            desc[prop] = Color3.new(value[1], value[2], value[3])
        else
            desc[prop] = value
        end
    end
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
            return HttpService:JSONDecode(readfile(PRESET_FILE))
        end)
        
        if success and data then
            for i, p in ipairs(data) do
                if type(p) == "string" then
                    data[i] = {username = p}
                end
            end
            presets = data
            print("Loaded " .. #presets .. " presets dari file")
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
        local json = HttpService:JSONEncode(presets)
        writefile(PRESET_FILE, json)
    end)
    
    if success then
        print("Presets saved to file")
    end
end

-- Toggle Button
local function createToggleButton()
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 35, 0, 35)
    ToggleButton.Position = UDim2.new(0, 15, 0, 15)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "Game"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ToggleButton
    
    return ToggleButton
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
    TitleText.Text = "AVATAR CHANGER (PRESET)"
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
    PresetTitle.Text = "PRESETS (Right-Click to Save)"
    PresetTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
    PresetTitle.TextScaled = true
    PresetTitle.Font = Enum.Font.GothamBold
    PresetTitle.Parent = PresetFrame
    
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
    StatusText.Text = "Ready (Tools Protected)"
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusText.TextScaled = true
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusFrame
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons
end

-- Apply Avatar (dari username atau descTable)
local function applyAvatar(username, descTable)
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then
        return false, "Character tidak ada!"
    end
    
    local humanoidDesc
    if descTable then
        local success, result = pcall(createDescFromTable, descTable)
        if not success then return false, "Gagal load preset" end
        humanoidDesc = result
    else
        if not username or username == "" then
            return false, "Username kosong!"
        end
        local success, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
        if not success then return false, "User tidak ditemukan" end
        local success2, result = pcall(Players.GetHumanoidDescriptionFromUserId, Players, userId)
        if not success2 then return false, "Gagal ambil avatar" end
        humanoidDesc = result
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
        if item:IsA("Tool") then table.insert(savedTools, item:Clone()) end
    end
    
    -- Hapus aksesoris & pakaian
    pcall(function()
        for _, acc in pairs(lp.Character:GetChildren()) do
            if acc:IsA("Accessory") or acc:IsA("Shirt") or acc:IsA("Pants") or acc:IsA("ShirtGraphic") then
                acc:Destroy()
            end
        end
    end)
    
    wait(0.1)
    
    -- Apply
    local success = pcall(function()
        lp.Character.Humanoid:ApplyDescriptionClientServer(humanoidDesc)
    end)
    if not success then
        for _, t in pairs(savedTools) do t.Parent = lp.Backpack end
        return false, "Gagal apply avatar"
    end
    
    wait(0.3)
    
    -- Restore tools
    for _, t in pairs(savedTools) do
        if t and t.Parent == nil then t.Parent = lp.Backpack end
    end
    if equippedTool then
        wait(0.1)
        local tool = lp.Backpack:FindFirstChild(equippedTool.Name)
        if tool then lp.Character.Humanoid:EquipTool(tool) end
    end
    
    lastAppliedUsername = username or "Preset"
    lastAppliedDesc = lp.Character.Humanoid:GetAppliedDescription()
    
    return true, "Avatar applied"
end

-- Update UI Preset
local function updatePresetUI(presetButtons)
    for i = 1, 5 do
        local btn = presetButtons[i]
        local label = btn:FindFirstChild("Label")
        if presets[i] and presets[i].username then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            label.Text = presets[i].username
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            label.Text = "Empty"
            label.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

-- Animasi UI
local function animateUI(frame, open)
    if UIState.isAnimating then return end
    UIState.isAnimating = true
    local target = open and UDim2.new(0, 380, 0, 240) or UDim2.new(0, 0, 0, 0)
    frame.Visible = true
    local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = target})
    tween:Play()
    tween.Completed:Connect(function()
        if not open then frame.Visible = false end
        UIState.isAnimating = false
    end)
end

local function toggleUI(mainFrame, toggleButton)
    if UIState.isAnimating then return end
    UIState.isOpen = not UIState.isOpen
    animateUI(mainFrame, UIState.isOpen)
    toggleButton.Text = UIState.isOpen and "X" or "Game"
    toggleButton.BackgroundColor3 = UIState.isOpen and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 40)
end

local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Main
loadPresets()
local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons = createUI()
makeDraggable(ToggleButton)

ToggleButton.MouseButton1Click:Connect(function() toggleUI(MainFrame, ToggleButton) end)

-- Hover Toggle
ToggleButton.MouseEnter:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0,40,0,40), BackgroundColor3 = Color3.fromRGB(60,60,60)}):Play()
    end
end)
ToggleButton.MouseLeave:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {Size = UDim2.new(0,35,0,35), BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    end
end)

-- Submit
local function handleSubmit()
    local username = UsernameInput.Text
    if username ~= "" then
        UsernameInput.PlaceholderText = "Loading..."
        UsernameInput.Text = ""
        StatusText.Text = "Applying..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success, msg = applyAvatar(username, nil)
        if success then
            UsernameInput.PlaceholderText = "Active: " .. username
            StatusText.Text = "Success: " .. username
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            UsernameInput.PlaceholderText = "Failed"
            StatusText.Text = msg
            StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            wait(3)
            UsernameInput.PlaceholderText = "Enter username..."
            StatusText.Text = "Ready (Tools Protected)"
            StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end
SubmitButton.MouseButton1Click:Connect(handleSubmit)
UsernameInput.FocusLost:Connect(function(enter) if enter then handleSubmit() end end)

-- Preset Buttons
for i, btn in ipairs(presetButtons) do
    btn.MouseButton1Click:Connect(function()
        if presets[i] then
            StatusText.Text = "Loading Preset " .. i .. "..."
            StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
            local success, msg = applyAvatar(presets[i].username, presets[i].desc)
            StatusText.Text = success and "Preset " .. i .. " loaded!" or "Failed: " .. msg
            StatusText.TextColor3 = success and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        else
            StatusText.Text = "Preset " .. i .. " kosong!"
            StatusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    btn.MouseButton2Click:Connect(function()
        if lastAppliedUsername and lastAppliedDesc then
            presets[i] = {username = lastAppliedUsername, desc = getDescTable(lastAppliedDesc)}
            savePresets()
            updatePresetUI(presetButtons)
            StatusText.Text = "Saved to Preset " .. i .. "!"
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusText.Text = "Apply avatar dulu!"
            StatusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    btn.MouseEnter:Connect(function() btn.Size = UDim2.new(0.19, 0, 0, 38) end)
    btn.MouseLeave:Connect(function() btn.Size = UDim2.new(0.18, 0, 0, 35) end)
end

updatePresetUI(presetButtons)

-- Auto Reapply
lp.CharacterAdded:Connect(function(char)
    if lastAppliedUsername then
        char:WaitForChild("Humanoid")
        wait(1)
        StatusText.Text = "Reapplying: " .. lastAppliedUsername
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        local descTable = lastAppliedDesc and getDescTable(lastAppliedDesc) or nil
        local success, msg = applyAvatar(lastAppliedUsername, descTable)
        StatusText.Text = success and "Auto-applied!" or "Failed"
        StatusText.TextColor3 = success and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    end
end)

-- F1 Toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F1 then
        toggleUI(MainFrame, ToggleButton)
    end
end)