-- AVATAR CHANGER - DIRECT CHARACTER CAPTURE
-- ✅ Menyimpan SEMUA accessories langsung dari Character
-- ✅ Capture Shirt.ShirtTemplate, Pants.PantsTemplate
-- ✅ Capture semua Accessory objects (sepatu, dll)
-- ✅ 5 Preset Avatar tersimpan ke file
-- ✅ Tools tidak hilang saat equip

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local InsertService = game:GetService("InsertService")

local lp = Players.LocalPlayer

-- State Management
local UIState = {
    isOpen = false,
    isAnimating = false
}

local currentAvatarData = nil
local presets = {}
local PRESET_FILE = "avatar_character_capture.json"

-- Function untuk CAPTURE LANGSUNG dari Character
local function captureCharacterAvatar()
    if not lp.Character then
        warn("❌ Character tidak ada")
        return nil
    end
    
    local char = lp.Character
    local data = {
        accessories = {}, -- List semua accessories dengan Asset ID
        clothing = {},
        bodyColors = {},
        bodyParts = {},
        scales = {}
    }
    
    -- 1. CAPTURE ACCESSORIES (HAT, HAIR, FACE, SEPATU, DLL)
    print("📦 Capturing Accessories...")
    for _, obj in pairs(char:GetChildren()) do
        if obj:IsA("Accessory") then
            local assetId = nil
            
            -- Coba ambil Asset ID dari Handle
            if obj:FindFirstChild("Handle") then
                local handle = obj.Handle
                if handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChild("Weld") then
                    -- Try to get from mesh
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh and mesh.MeshId then
                        assetId = mesh.MeshId
                    end
                end
                
                -- Backup: Coba dari TextureID
                if not assetId then
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh and mesh.TextureId then
                        assetId = mesh.TextureId
                    end
                end
            end
            
            -- Jika masih tidak ada, gunakan obj name
            if not assetId then
                assetId = obj.Name
            end
            
            table.insert(data.accessories, {
                name = obj.Name,
                assetId = assetId,
                accessoryType = obj.AccessoryType and obj.AccessoryType.Name or "Unknown"
            })
            
            print("  ✓ " .. obj.Name .. " (" .. (obj.AccessoryType and obj.AccessoryType.Name or "Unknown") .. ")")
        end
    end
    
    -- 2. CAPTURE CLOTHING (SHIRT & PANTS TEMPLATE)
    print("👕 Capturing Clothing...")
    local shirt = char:FindFirstChildOfClass("Shirt")
    if shirt then
        data.clothing.Shirt = shirt.ShirtTemplate
        print("  ✓ Shirt: " .. shirt.ShirtTemplate)
    end
    
    local pants = char:FindFirstChildOfClass("Pants")
    if pants then
        data.clothing.Pants = pants.PantsTemplate
        print("  ✓ Pants: " .. pants.PantsTemplate)
    end
    
    local tshirt = char:FindFirstChildOfClass("ShirtGraphic")
    if tshirt then
        data.clothing.TShirt = tshirt.Graphic
        print("  ✓ T-Shirt: " .. tshirt.Graphic)
    end
    
    -- 3. CAPTURE BODY COLORS
    local bodyColors = char:FindFirstChildOfClass("BodyColors")
    if bodyColors then
        data.bodyColors = {
            HeadColor = bodyColors.HeadColor3,
            TorsoColor = bodyColors.TorsoColor3,
            LeftArmColor = bodyColors.LeftArmColor3,
            RightArmColor = bodyColors.RightArmColor3,
            LeftLegColor = bodyColors.LeftLegColor3,
            RightLegColor = bodyColors.RightLegColor3
        }
    end
    
    -- 4. CAPTURE BODY PARTS (untuk body type)
    for _, partName in pairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
        local part = char:FindFirstChild(partName)
        if part then
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                data.bodyParts[partName] = {
                    MeshId = mesh.MeshId,
                    TextureId = mesh.TextureId,
                    Scale = mesh.Scale
                }
            end
        end
    end
    
    -- 5. CAPTURE HUMANOID SCALES
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        data.scales = {
            BodyDepthScale = humanoid.BodyDepthScale,
            BodyHeightScale = humanoid.BodyHeightScale,
            BodyWidthScale = humanoid.BodyWidthScale,
            HeadScale = humanoid.HeadScale
        }
    end
    
    print("✅ Total Accessories: " .. #data.accessories)
    print("✅ Shirt: " .. (data.clothing.Shirt and "Yes" or "No"))
    print("✅ Pants: " .. (data.clothing.Pants and "Yes" or "No"))
    
    return data
end

-- Function untuk APPLY captured avatar
local function applyCharacterAvatar(data)
    if not data or not lp.Character then
        return false
    end
    
    local char = lp.Character
    
    -- 1. REMOVE EXISTING ACCESSORIES & CLOTHING
    print("🗑️ Removing old items...")
    for _, obj in pairs(char:GetChildren()) do
        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
            obj:Destroy()
        end
    end
    
    wait(0.3)
    
    -- 2. APPLY CLOTHING
    print("👕 Applying Clothing...")
    if data.clothing.Shirt then
        local shirt = Instance.new("Shirt")
        shirt.ShirtTemplate = data.clothing.Shirt
        shirt.Parent = char
        print("  ✓ Shirt applied")
    end
    
    if data.clothing.Pants then
        local pants = Instance.new("Pants")
        pants.PantsTemplate = data.clothing.Pants
        pants.Parent = char
        print("  ✓ Pants applied")
    end
    
    if data.clothing.TShirt then
        local tshirt = Instance.new("ShirtGraphic")
        tshirt.Graphic = data.clothing.TShirt
        tshirt.Parent = char
        print("  ✓ T-Shirt applied")
    end
    
    -- 3. APPLY BODY COLORS
    if data.bodyColors then
        local bodyColors = char:FindFirstChildOfClass("BodyColors")
        if not bodyColors then
            bodyColors = Instance.new("BodyColors")
            bodyColors.Parent = char
        end
        
        bodyColors.HeadColor3 = data.bodyColors.HeadColor
        bodyColors.TorsoColor3 = data.bodyColors.TorsoColor
        bodyColors.LeftArmColor3 = data.bodyColors.LeftArmColor
        bodyColors.RightArmColor3 = data.bodyColors.RightArmColor
        bodyColors.LeftLegColor3 = data.bodyColors.LeftLegColor
        bodyColors.RightLegColor3 = data.bodyColors.RightLegColor
    end
    
    -- 4. APPLY ACCESSORIES
    print("📦 Applying Accessories...")
    for _, accData in pairs(data.accessories) do
        local success = pcall(function()
            -- Try to load accessory by asset ID
            if accData.assetId and type(accData.assetId) == "string" and accData.assetId:match("rbxassetid://(%d+)") then
                local assetId = accData.assetId:match("rbxassetid://(%d+)")
                local model = game:GetObjects("rbxassetid://" .. assetId)[1]
                
                if model and model:IsA("Accessory") then
                    model.Parent = char
                    print("  ✓ " .. accData.name)
                end
            end
        end)
        
        if not success then
            warn("  ✗ Failed to load: " .. accData.name)
        end
    end
    
    -- 5. APPLY SCALES
    if data.scales then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.BodyDepthScale = data.scales.BodyDepthScale or 1
            humanoid.BodyHeightScale = data.scales.BodyHeightScale or 1
            humanoid.BodyWidthScale = data.scales.BodyWidthScale or 1
            humanoid.HeadScale = data.scales.HeadScale or 1
        end
    end
    
    print("✅ Avatar applied successfully!")
    return true
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
            print("✅ Loaded " .. #presets .. " character presets")
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
        print("✅ Character presets saved")
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
    TitleText.Text = "🎮 CHARACTER CAPTURE PRESET"
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
    PresetTitle.Text = "⭐ CHARACTER PRESETS (Right-Click to Save)"
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
    StatusText.Text = "✨ Ready (Character Capture Mode)"
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusText.TextScaled = true
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusFrame
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, presetButtons
end

-- Load Avatar Function
local function loadAvatar(username)
    if not username or username == "" then
        return false, "Username tidak boleh kosong!"
    end
    
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if not success then
        return false, "Username tidak ditemukan"
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
    
    wait(2) -- Wait untuk semua accessories fully load
    
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
    
    -- CAPTURE dari character
    local capturedData = captureCharacterAvatar()
    
    if capturedData then
        currentAvatarData = {
            username = username,
            avatarData = capturedData
        }
        return true, "Avatar changed: " .. username
    else
        return false, "Avatar applied tapi gagal capture"
    end
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
    
    local targetSize
    if isOpening then
        targetSize = UDim2.new(0, 380, 0, 240)
        frame.Visible = true
    else
        targetSize = UDim2.new(0, 0, 0, 0)
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
    local dragging, dragStart, startPos = false, nil, nil
    
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
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if not UIState.isOpen then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 35, 0, 35),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        }):Play()
    end
end)

-- Submit Button
local function handleSubmit()
    local username = UsernameInput.Text
    if username and username ~= "" then
        UsernameInput.PlaceholderText = "Loading..."
        UsernameInput.Text = ""
        StatusText.Text = "⏳ Applying & capturing..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success, message = loadAvatar(username)
        
        if success then
            UsernameInput.PlaceholderText = "✓ Active: " .. username
            StatusText.Text = "✅ Character Captured!"
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            UsernameInput.PlaceholderText = "✗ Failed"
            StatusText.Text = "❌ " .. message
            StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            
            wait(3)
            UsernameInput.PlaceholderText = "Enter username..."
            StatusText.Text = "✨ Ready (Character Capture Mode)"
            StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

SubmitButton.MouseButton1Click:Connect(handleSubmit)
UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then handleSubmit() end
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
            StatusText.Text = "⏳ Loading Preset " .. i .. "..."
            StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
            
            -- Save tools
            local savedTools = {}
            for _, item in pairs(lp.Character:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(savedTools, item:Clone())
                    item.Parent = nil
                end
            end
            for _, item in pairs(lp.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(savedTools, item:Clone())
                end
            end
            
            local success = applyCharacterAvatar(presets[i].avatarData)
            
            -- Restore tools
            wait(0.3)
            for _, tool in pairs(savedTools) do
                if tool and tool:IsA("Tool") then
                    tool.Parent = lp.Backpack
                end
            end
            
            if success then
                currentAvatarData = presets[i]
                StatusText.Text = "✅ Preset " .. i .. " loaded!"
                StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                StatusText.Text = "❌ Preset failed to load"
                StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        else
            StatusText.Text = "⚠️ Preset " .. i .. " is empty!"
            StatusText.TextColor3 = Color3.fromRGB(255, 165, 0)
        end
    end)
    
    -- Right Click: Save CURRENT character
    btn.MouseButton2Click:Connect(function()
        StatusText.Text = "📸 Capturing character..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        wait(0.2)
        
        local capturedData = captureCharacterAvatar()
        
        if capturedData then
            currentAvatarData = {
                username = "Preset " .. i,
                avatarData = capturedData
            }
            
            presets[i] = currentAvatarData
            savePresets()
            updatePresetUI(presetButtons)
            
            StatusText.Text = "💾 Character saved to Preset " .. i .. "!"
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusText.Text = "❌ Failed to capture!"
            StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
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
        wait(1.5)
        
        StatusText.Text = "🔄 Auto-reapplying character..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success = applyCharacterAvatar(currentAvatarData.avatarData)
        
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

print("=== AVATAR CHANGER - CHARACTER CAPTURE ===")
print("✅ Capture LANGSUNG dari Character objects")
print("✅ Shirt.ShirtTemplate, Pants.PantsTemplate")
print("✅ Semua Accessory objects (hat, hair, sepatu, dll)")
print("✅ Body Colors & Scales")
print("✅ Right-Click = Capture & Save current character")
print("✅ Left-Click = Load saved character")
print("✅ Tekan F1 untuk toggle UI")
print("===========================================")