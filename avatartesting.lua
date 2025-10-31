
-- AVATAR CHANGER - MODERN PRESET SYSTEM
-- ✅ Mobile Friendly (Long Press to Save)
-- ✅ Simpan HumanoidDescription, bukan username
-- ✅ Modern UI tanpa emoji
-- ✅ Elegant & Clean Design

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

local lastAppliedDescription = nil
local presets = {}
local PRESET_FILE = "avatar_presets_hd.json"

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
            presets = data
            print("✅ Loaded " .. #presets .. " avatar presets")
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
        print("✅ Avatar presets saved")
    end
end

-- Convert HumanoidDescription to table
local function descriptionToTable(desc)
    return {
        Face = desc.Face,
        Head = desc.Head,
        LeftArm = desc.LeftArm,
        LeftLeg = desc.LeftLeg,
        RightArm = desc.RightArm,
        RightLeg = desc.RightLeg,
        Torso = desc.Torso,
        BodyTypeScale = desc.BodyTypeScale,
        DepthScale = desc.DepthScale,
        HeadScale = desc.HeadScale,
        HeightScale = desc.HeightScale,
        ProportionScale = desc.ProportionScale,
        WidthScale = desc.WidthScale,
        HeadColor = desc.HeadColor,
        LeftArmColor = desc.LeftArmColor,
        LeftLegColor = desc.LeftLegColor,
        RightArmColor = desc.RightArmColor,
        RightLegColor = desc.RightLegColor,
        TorsoColor = desc.TorsoColor,
        Shirt = desc.Shirt,
        Pants = desc.Pants,
        GraphicTShirt = desc.GraphicTShirt,
        HatAccessory = desc.HatAccessory,
        HairAccessory = desc.HairAccessory,
        FaceAccessory = desc.FaceAccessory,
        NeckAccessory = desc.NeckAccessory,
        ShoulderAccessory = desc.ShoulderAccessory,
        FrontAccessory = desc.FrontAccessory,
        BackAccessory = desc.BackAccessory,
        WaistAccessory = desc.WaistAccessory
    }
end

-- Convert table to HumanoidDescription
local function tableToDescription(tbl)
    local desc = Instance.new("HumanoidDescription")
    
    for key, value in pairs(tbl) do
        pcall(function()
            desc[key] = value
        end)
    end
    
    return desc
end

-- Toggle Button Creation
local function createToggleButton()
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 20, 0, 20)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "AC"
    ToggleButton.TextColor3 = Color3.fromRGB(120, 140, 255)
    ToggleButton.TextSize = 20
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 10
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleButton
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(120, 140, 255)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.5
    Stroke.Parent = ToggleButton
    
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
    ToggleButton.Parent = ScreenGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(60, 60, 70)
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.5
    MainStroke.Parent = MainFrame
    
    -- Glass Effect
    local Blur = Instance.new("Frame")
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Blur.BackgroundTransparency = 0.3
    Blur.BorderSizePixel = 0
    Blur.Parent = MainFrame
    
    local BlurCorner = Instance.new("UICorner")
    BlurCorner.CornerRadius = UDim.new(0, 16)
    BlurCorner.Parent = Blur
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "AVATAR CHANGER"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -40, 0, 15)
    Subtitle.Position = UDim2.new(0, 20, 0, 40)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Modern Preset System"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
    Subtitle.TextSize = 12
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header
    
    -- Input Section
    local InputContainer = Instance.new("Frame")
    InputContainer.Size = UDim2.new(1, -40, 0, 50)
    InputContainer.Position = UDim2.new(0, 20, 0, 70)
    InputContainer.BackgroundTransparency = 1
    InputContainer.Parent = MainFrame
    
    local InputBg = Instance.new("Frame")
    InputBg.Size = UDim2.new(0.7, -5, 1, 0)
    InputBg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    InputBg.BorderSizePixel = 0
    InputBg.Parent = InputContainer
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = InputBg
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(60, 60, 70)
    InputStroke.Thickness = 1
    InputStroke.Transparency = 0.5
    InputStroke.Parent = InputBg
    
    local UsernameInput = Instance.new("TextBox")
    UsernameInput.Name = "UsernameInput"
    UsernameInput.Size = UDim2.new(1, -20, 1, 0)
    UsernameInput.Position = UDim2.new(0, 10, 0, 0)
    UsernameInput.BackgroundTransparency = 1
    UsernameInput.Text = ""
    UsernameInput.PlaceholderText = "Enter username..."
    UsernameInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
    UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    UsernameInput.TextSize = 14
    UsernameInput.Font = Enum.Font.Gotham
    UsernameInput.TextXAlignment = Enum.TextXAlignment.Left
    UsernameInput.Parent = InputBg
    
    local ApplyButton = Instance.new("TextButton")
    ApplyButton.Name = "ApplyButton"
    ApplyButton.Size = UDim2.new(0.3, -5, 1, 0)
    ApplyButton.Position = UDim2.new(0.7, 0, 0, 0)
    ApplyButton.BackgroundColor3 = Color3.fromRGB(120, 140, 255)
    ApplyButton.BorderSizePixel = 0
    ApplyButton.Text = "APPLY"
    ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ApplyButton.TextSize = 14
    ApplyButton.Font = Enum.Font.GothamBold
    ApplyButton.Parent = InputContainer
    
    local ApplyCorner = Instance.new("UICorner")
    ApplyCorner.CornerRadius = UDim.new(0, 10)
    ApplyCorner.Parent = ApplyButton
    
    -- Preset Section
    local PresetLabel = Instance.new("TextLabel")
    PresetLabel.Size = UDim2.new(1, -40, 0, 20)
    PresetLabel.Position = UDim2.new(0, 20, 0, 135)
    PresetLabel.BackgroundTransparency = 1
    PresetLabel.Text = "PRESETS"
    PresetLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    PresetLabel.TextSize = 14
    PresetLabel.Font = Enum.Font.GothamBold
    PresetLabel.TextXAlignment = Enum.TextXAlignment.Left
    PresetLabel.Parent = MainFrame
    
    local PresetHint = Instance.new("TextLabel")
    PresetHint.Size = UDim2.new(1, -40, 0, 15)
    PresetHint.Position = UDim2.new(0, 20, 0, 155)
    PresetHint.BackgroundTransparency = 1
    PresetHint.Text = "Tap to load • Hold to save"
    PresetHint.TextColor3 = Color3.fromRGB(120, 120, 130)
    PresetHint.TextSize = 11
    PresetHint.Font = Enum.Font.Gotham
    PresetHint.TextXAlignment = Enum.TextXAlignment.Left
    PresetHint.Parent = MainFrame
    
    -- Preset Buttons Grid
    local PresetContainer = Instance.new("Frame")
    PresetContainer.Size = UDim2.new(1, -40, 0, 100)
    PresetContainer.Position = UDim2.new(0, 20, 0, 175)
    PresetContainer.BackgroundTransparency = 1
    PresetContainer.Parent = MainFrame
    
    local presetButtons = {}
    for i = 1, 5 do
        local col = (i - 1) % 5
        local row = math.floor((i - 1) / 5)
        
        local btn = Instance.new("TextButton")
        btn.Name = "Preset" .. i
        btn.Size = UDim2.new(0.18, 0, 0, 45)
        btn.Position = UDim2.new(col * 0.205, 0, row * 0.55, 0)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = PresetContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(60, 60, 70)
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.7
        btnStroke.Parent = btn
        
        local number = Instance.new("TextLabel")
        number.Name = "Number"
        number.Size = UDim2.new(1, 0, 0.6, 0)
        number.BackgroundTransparency = 1
        number.Text = tostring(i)
        number.TextColor3 = Color3.fromRGB(120, 120, 130)
        number.TextSize = 20
        number.Font = Enum.Font.GothamBold
        number.Parent = btn
        
        local status = Instance.new("TextLabel")
        status.Name = "Status"
        status.Size = UDim2.new(1, 0, 0.4, 0)
        status.Position = UDim2.new(0, 0, 0.6, 0)
        status.BackgroundTransparency = 1
        status.Text = "Empty"
        status.TextColor3 = Color3.fromRGB(100, 100, 110)
        status.TextSize = 10
        status.Font = Enum.Font.Gotham
        status.Parent = btn
        
        presetButtons[i] = btn
    end
    
    -- Status Bar
    local StatusBar = Instance.new("Frame")
    StatusBar.Size = UDim2.new(1, -40, 0, 45)
    StatusBar.Position = UDim2.new(0, 20, 1, -65)
    StatusBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    StatusBar.BorderSizePixel = 0
    StatusBar.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = StatusBar
    
    local StatusStroke = Instance.new("UIStroke")
    StatusStroke.Color = Color3.fromRGB(60, 60, 70)
    StatusStroke.Thickness = 1
    StatusStroke.Transparency = 0.5
    StatusStroke.Parent = StatusBar
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Ready"
    StatusText.TextColor3 = Color3.fromRGB(150, 150, 160)
    StatusText.TextSize = 12
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusBar
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, ApplyButton, presetButtons
end

-- Load Avatar by HumanoidDescription
local function loadAvatarFromDescription(humanoidDesc)
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then
        return false, "Character tidak ada!"
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
    
    return true, "Avatar applied successfully"
end

-- Load Avatar by Username
local function loadAvatarFromUsername(username)
    if not username or username == "" then
        return false, "Username tidak boleh kosong!"
    end
    
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if not success then
        return false, "Username tidak ditemukan"
    end
    
    local humanoidDesc
    local success2 = pcall(function()
        humanoidDesc = Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success2 or not humanoidDesc then
        return false, "Gagal mendapatkan avatar"
    end
    
    local success3, message = loadAvatarFromDescription(humanoidDesc)
    
    if success3 then
        lastAppliedDescription = humanoidDesc
    end
    
    return success3, message
end

-- Update Preset UI
local function updatePresetUI(presetButtons)
    for i = 1, 5 do
        local btn = presetButtons[i]
        local status = btn:FindFirstChild("Status")
        local number = btn:FindFirstChild("Number")
        local stroke = btn:FindFirstChild("UIStroke")
        
        if presets[i] then
            btn.BackgroundColor3 = Color3.fromRGB(120, 140, 255)
            status.Text = "Saved"
            status.TextColor3 = Color3.fromRGB(255, 255, 255)
            number.TextColor3 = Color3.fromRGB(255, 255, 255)
            stroke.Color = Color3.fromRGB(150, 170, 255)
            stroke.Transparency = 0.3
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            status.Text = "Empty"
            status.TextColor3 = Color3.fromRGB(100, 100, 110)
            number.TextColor3 = Color3.fromRGB(120, 120, 130)
            stroke.Color = Color3.fromRGB(60, 60, 70)
            stroke.Transparency = 0.7
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
            Size = UDim2.new(0, 420, 0, 320),
            Position = UDim2.new(0.5, -210, 0.5, -160)
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
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if UIState.isOpen then
        local tween = TweenService:Create(toggleButton, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        })
        tween:Play()
    else
        local tween = TweenService:Create(toggleButton, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        })
        tween:Play()
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

local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, ApplyButton, presetButtons = createUI()

makeDraggable(ToggleButton)

ToggleButton.MouseButton1Click:Connect(function()
    toggleUI(MainFrame, ToggleButton)
end)

-- Apply Button
local function handleApply()
    local username = UsernameInput.Text
    if username and username ~= "" then
        UsernameInput.Text = ""
        StatusText.Text = "Applying avatar..."
        StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        local success, message = loadAvatarFromUsername(username)
        
        if success then
            StatusText.Text = "Avatar applied: " .. username
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            StatusText.Text = message
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            wait(3)
            StatusText.Text = "Ready"
            StatusText.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
    end
end

ApplyButton.MouseButton1Click:Connect(handleApply)

UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        handleApply()
    end
end)

-- Button Hover Effects
ApplyButton.MouseEnter:Connect(function()
    TweenService:Create(ApplyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(140, 160, 255)
    }):Play()
end)

ApplyButton.MouseLeave:Connect(function()
    TweenService:Create(ApplyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(120, 140, 255)
    }):Play()
end)

-- Preset Buttons Logic (Mobile Friendly)
for i, btn in ipairs(presetButtons) do
    local holdTime = 0
    local holding = false
    local holdConnection = nil
    
    -- Touch/Click Start
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            holding = true
            holdTime = 0
            
            -- Visual feedback
            TweenService:Create(btn, TweenInfo.new(0.1), {
                Size = UDim2.new(0.17, 0, 0, 42)
            }):Play()
            
            holdConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
                if holding then
                    holdTime = holdTime + dt
                    
                    -- Long press detected (0.5 seconds)
                    if holdTime >= 0.5 then
                        holding = false
                        if holdConnection then
                            holdConnection:Disconnect()
                        end
                        
                        -- SAVE PRESET
                        if lastAppliedDescription then
                            presets[i] = descriptionToTable(lastAppliedDescription)
                            savePresets()
                            updatePresetUI(presetButtons)
                            
                            StatusText.Text = "Preset " .. i .. " saved!"
                            StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
                            
                            -- Flash effect
                            btn.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
                            wait(0.2)
                            btn.BackgroundColor3 = Color3.fromRGB(120, 140, 255)
                        else
                            StatusText.Text = "Apply an avatar first!"
                            StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
                        end
                    end
                end
            end)
        end
    end)
    
    -- Touch/Click End
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if holdConnection then
                holdConnection:Disconnect()
            end
            
            TweenService:Create(btn, TweenInfo.new(0.1), {
                Size = UDim2.new(0.18, 0, 0, 45)
            }):Play()
            
            -- Short tap = LOAD PRESET
            if holding and holdTime < 0.5 then
                holding = false
                
                if presets[i] then
                    StatusText.Text = "Loading preset " .. i .. "..."
                    StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
                    
                    local desc = tableToDescription(presets[i])
                    local success, message = loadAvatarFromDescription(desc)
                    
                    if success then
                        lastAppliedDescription = desc
                        StatusText.Text = "Preset " .. i .. " loaded!"
                        StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
                    else
                        StatusText.Text = message
                        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
                    end
                else
                    StatusText.Text = "Preset " .. i .. " is empty!"
                    StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
                end
            end
            
            holding = false
        end
    end)
end

updatePresetUI(presetButtons)

-- AUTO REAPPLY ON RESPAWN
lp.CharacterAdded:Connect(function(char)
    if lastAppliedDescription then
        char:WaitForChild("Humanoid")        
        wait(1)
        
        StatusText.Text = "Auto-reapplying avatar..."
        StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        local success, message = loadAvatarFromDescription(lastAppliedDescription)
        
        if success then
            StatusText.Text = "Avatar auto-applied!"
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            StatusText.Text = "Auto-apply failed"
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)

-- Keyboard Shortcut (F1) - Desktop only
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleUI(MainFrame, ToggleButton)
    end
end)

-- Toggle Button Hover (Desktop)
ToggleButton.MouseEnter:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 55, 0, 55),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        }):Play()
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 50, 0, 50),
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        }):Play()
    end
end)

print("===================================")
print("MODERN AVATAR CHANGER - LOADED")
print("✓ Preset saves HumanoidDescription")
print("✓ Mobile friendly (hold to save)")
print("✓ Clean modern UI")
print("✓ Press F1 to toggle (desktop)")
print("===================================")

