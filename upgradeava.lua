-- AVATAR CHANGER - APPLIED CAPTURE + PREVIEW + MOBILE FRIENDLY
-- FIX: Semua baju, celana, aksesoris tersimpan
-- NEW: Preview, Tambah Preset, Mobile Support

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- State
local UIState = { isOpen = false, isAnimating = false }
local currentAvatarData = nil
local presets = {}
local PRESET_FILE = "avatar_applied_presets_v2.json"
local MAX_PRESETS = 10

-- UI Elements
local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, PresetContainer, AddPresetButton

-- Safe Get/Set
local function safeGet(obj, prop, default) local s,v = pcall(function() return obj[prop] end) return s and v or default end
local function safeSet(obj, prop, val) pcall(function() obj[prop] = val end) end

-- MANUAL CAPTURE (FIX BAJU & AKSESORIS)
local function captureCurrentAvatar()
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then return nil end
    local char = lp.Character
    local hum = char.Humanoid

    local desc = nil
    pcall(function() desc = hum:GetAppliedDescription() end)
    if not desc then warn("No AppliedDescription") return nil end

    local data = {}

    -- Body Parts & Scales
    local props = {"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg","Face",
        "ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation","RunAnimation","SwimAnimation","WalkAnimation",
        "BodyTypeScale","DepthScale","HeadScale","HeightScale","ProportionScale","WidthScale","MoodAnimation","PoseAnimation"}
    for _,p in ipairs(props) do data[p] = safeGet(desc, p, 0) end

    -- Colors
    local function c2t(c) return {R=c.R, G=c.G, B=c.B} end
    data.HeadColor = c2t(desc.HeadColor)
    data.TorsoColor = c2t(desc.TorsoColor)
    data.LeftArmColor = c2t(desc.LeftArmColor)
    data.RightArmColor = c2t(desc.RightArmColor)
    data.LeftLegColor = c2t(desc.LeftLegColor)
    data.RightLegColor = c2t(desc.RightLegColor)

    -- CLOTHING MANUAL
    data.ShirtTemplate = ""
    data.PantsTemplate = ""
    data.GraphicTShirtTemplate = ""

    local shirt = char:FindFirstChildOfClass("Shirt")
    local pants = char:FindFirstChildOfClass("Pants")
    local graphic = char:FindFirstChildOfClass("ShirtGraphic")

    if shirt and shirt.ShirtTemplate ~= "" then
        data.ShirtTemplate = shirt.ShirtTemplate
        data.Shirt = tonumber(shirt.ShirtTemplate:match("%d+")) or 0
    end
    if pants and pants.PantsTemplate ~= "" then
        data.PantsTemplate = pants.PantsTemplate
        data.Pants = tonumber(pants.PantsTemplate:match("%d+")) or 0
    end
    if graphic and graphic.Graphic ~= "" then
        data.GraphicTShirtTemplate = graphic.Graphic
        data.GraphicTShirt = tonumber(graphic.Graphic:match("%d+")) or 0
    end

    -- ACCESSORIES MANUAL
    local accMap = {Hat={},Hair={},Face={},Neck={},Shoulder={},Front={},Back={},Waist={}}
    for _, acc in pairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChildOfClass("MeshPart")
                if mesh then
                    local id = 0
                    if mesh.MeshId and mesh.MeshId ~= "" then
                        id = tonumber(mesh.MeshId:match("%d+")) or 0
                    elseif mesh.TextureID and mesh.TextureID ~= "" then
                        id = tonumber(mesh.TextureID:match("%d+")) or 0
                    end
                    if id > 0 then
                        local typeName = acc.AccessoryType.Name
                        if accMap[typeName] then table.insert(accMap[typeName], id) end
                    end
                end
            end
        end
    end

    data.HatAccessory = table.concat(accMap.Hat, ",")
    data.HairAccessory = table.concat(accMap.Hair, ",")
    data.FaceAccessory = table.concat(accMap.Face, ",")
    data.NeckAccessory = table.concat(accMap.Neck, ",")
    data.ShoulderAccessory = table.concat(accMap.Shoulder, ",")
    data.FrontAccessory = table.concat(accMap.Front, ",")
    data.BackAccessory = table.concat(accMap.Back, ",")
    data.WaistAccessory = table.concat(accMap.Waist, ",")

    print("CAPTURED: Shirt="..(data.Shirt or 0)..", Pants="..(data.Pants or 0)..", Hats="..data.HatAccessory)
    return data
end

-- CREATE DESCRIPTION
local function createHumanoidDescription(data)
    if not data then return nil end
    local desc = Instance.new("HumanoidDescription")

    local props = {"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg","Face",
        "ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation","RunAnimation","SwimAnimation","WalkAnimation",
        "BodyTypeScale","DepthScale","HeadScale","HeightScale","ProportionScale","WidthScale","MoodAnimation","PoseAnimation"}
    for _,p in ipairs(props) do safeSet(desc, p, data[p] or 0) end

    local function t2c(t) return t and Color3.new(t.R or 1, t.G or 1, t.B or 1) or Color3.new(1,1,1) end
    desc.HeadColor = t2c(data.HeadColor)
    desc.TorsoColor = t2c(data.TorsoColor)
    desc.LeftArmColor = t2c(data.LeftArmColor)
    desc.RightArmColor = t2c(data.RightArmColor)
    desc.LeftLegColor = t2c(data.LeftLegColor)
    desc.RightLegColor = t2c(data.RightLegColor)

    safeSet(desc, "HatAccessory", data.HatAccessory or "")
    safeSet(desc, "HairAccessory", data.HairAccessory or "")
    safeSet(desc, "FaceAccessory", data.FaceAccessory or "")
    safeSet(desc, "NeckAccessory", data.NeckAccessory or "")
    safeSet(desc, "ShoulderAccessory", data.ShoulderAccessory or "")
    safeSet(desc, "FrontAccessory", data.FrontAccessory or "")
    safeSet(desc, "BackAccessory", data.BackAccessory or "")
    safeSet(desc, "WaistAccessory", data.WaistAccessory or "")

    return desc, data
end

-- APPLY CLOTHING MANUAL
local function applyClothingManual(data)
    local char = lp.Character
    if data.ShirtTemplate and data.ShirtTemplate ~= "" then
        local s = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt")
        s.ShirtTemplate = data.ShirtTemplate
        s.Parent = char
    end
    if data.PantsTemplate and data.PantsTemplate ~= "" then
        local p = char:FindFirstChildOfClass("Pants") or Instance.new("Pants")
        p.PantsTemplate = data.PantsTemplate
        p.Parent = char
    end
    if data.GraphicTShirtTemplate and data.GraphicTShirtTemplate ~= "" then
        local g = char:FindFirstChildOfClass("ShirtGraphic") or Instance.new("ShirtGraphic")
        g.Graphic = data.GraphicTShirtTemplate
        g.Parent = char
    end
end

-- TOOLS
local function saveTools()
    local tools, equipped = {}, nil
    for _, t in pairs(lp.Character:GetChildren()) do
        if t:IsA("Tool") then equipped = t; t.Parent = nil; table.insert(tools, t:Clone()) end
    end
    for _, t in pairs(lp.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t:Clone()) end end
    return tools, equipped
end

local function restoreTools(tools, equipped)
    for _, t in pairs(tools) do t.Parent = lp.Backpack end
    if equipped then task.wait(0.1)
        local t = lp.Backpack:FindFirstChild(equipped.Name)
        if t then lp.Character.Humanoid:EquipTool(t) end
    end
end

local function clearAvatar()
    pcall(function()
        for _, v in pairs(lp.Character:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
                v:Destroy()
            end
        end
    end)
end

-- LOAD AVATAR FROM USERNAME
local function loadAvatar(username)
    if not username or username == "" then return false, "Username kosong" end

    local userId = nil
    local success = pcall(function() userId = Players:GetUserIdFromNameAsync(username) end)
    if not success or not userId then return false, "User tidak ditemukan" end

    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then return false, "No character" end

    local desc = nil
    pcall(function() desc = Players:GetHumanoidDescriptionFromUserId(userId) end)
    if not desc then return false, "Gagal ambil avatar" end

    local tools, equipped = saveTools()
    clearAvatar()
    task.wait(0.2)

    pcall(function() lp.Character.Humanoid:ApplyDescriptionClientServer(desc) end)
    task.wait(1.5)
    applyClothingManual({Shirt = desc.Shirt, Pants = desc.Pants, GraphicTShirt = desc.GraphicTShirt}) -- fallback

    restoreTools(tools, equipped)

    task.wait(0.5)
    local captured = captureCurrentAvatar()
    if captured then
        currentAvatarData = { username = username, avatarData = captured }
        return true, "Captured: " .. username
    else
        return false, "Gagal capture"
    end
end

-- APPLY STORED
local function applyStoredAvatar(presetData)
    if not presetData or not presetData.avatarData then return false, "Invalid" end
    if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then return false, "No char" end

    local tools, equipped = saveTools()
    clearAvatar()
    task.wait(0.2)

    local desc, raw = createHumanoidDescription(presetData.avatarData)
    if not desc then return false, "Failed desc" end

    pcall(function() lp.Character.Humanoid:ApplyDescriptionClientServer(desc) end)
    task.wait(1.5)
    applyClothingManual(raw)

    restoreTools(tools, equipped)
    currentAvatarData = presetData
    return true, "Loaded"
end

-- FILE
local function loadPresets()
    if not readfile or not isfile then return end
    if isfile(PRESET_FILE) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(PRESET_FILE)) end)
        if ok and data then presets = data end
    end
end

local function savePresets()
    if not writefile then return end
    pcall(function() writefile(PRESET_FILE, HttpService:JSONEncode(presets)) end)
end

-- UI CREATION
local function createUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AvatarPresetUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = playerGui

    -- Toggle
    ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 15, 0, 15)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.Text = "Avatar"
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.Parent = ScreenGui
    local tc = Instance.new("UICorner", ToggleButton) tc.CornerRadius = UDim.new(1,0)

    -- Main Frame
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -190, 0.05, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    local mc = Instance.new("UICorner", MainFrame) mc.CornerRadius = UDim.new(0,12)

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,35)
    title.BackgroundColor3 = Color3.fromRGB(40,40,40)
    title.Text = "APPLIED AVATAR PRESET"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = MainFrame
    local tc2 = Instance.new("UICorner", title) tc2.CornerRadius = UDim.new(0,12)

    -- Input
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1,-20,0,40)
    inputFrame.Position = UDim2.new(0,10,0,40)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = MainFrame

    UsernameInput = Instance.new("TextBox")
    UsernameInput.Size = UDim2.new(0.7,0,1,0)
    UsernameInput.BackgroundColor3 = Color3.fromRGB(45,45,45)
    UsernameInput.PlaceholderText = "Enter username..."
    UsernameInput.Text = ""
    UsernameInput.TextColor3 = Color3.new(1,1,1)
    UsernameInput.Font = Enum.Font.Gotham
    UsernameInput.Parent = inputFrame
    local ic = Instance.new("UICorner", UsernameInput) ic.CornerRadius = UDim.new(0,8)

    SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(0.3,0,1,0)
    SubmitButton.Position = UDim2.new(0.7,0,0,0)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0,150,255)
    SubmitButton.Text = "GO"
    SubmitButton.TextColor3 = Color3.new(1,1,1)
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = inputFrame
    local sc = Instance.new("UICorner", SubmitButton) sc.CornerRadius = UDim.new(0,8)

    -- Preset Area
    PresetContainer = Instance.new("Frame")
    PresetContainer.Size = UDim2.new(1,-20,0,200)
    PresetContainer.Position = UDim2.new(0,10,0,90)
    PresetContainer.BackgroundColor3 = Color3.fromRGB(35,35,35)
    PresetContainer.Parent = MainFrame
    local pc = Instance.new("UICorner", PresetContainer) pc.CornerRadius = UDim.new(0,8)

    -- Scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.Parent = PresetContainer

    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0, 70, 0, 90)
    layout.CellPadding = UDim2.new(0, 8, 0, 8)
    layout.Parent = scroll

    -- Add Button
    AddPresetButton = Instance.new("TextButton")
    AddPresetButton.Size = UDim2.new(0, 70, 0, 90)
    AddPresetButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    AddPresetButton.Text = "+"
    AddPresetButton.TextScaled = true
    AddPresetButton.Font = Enum.Font.GothamBold
    AddPresetButton.Parent = scroll
    local ac = Instance.new("UICorner", AddPresetButton) ac.CornerRadius = UDim.new(0,8)

    -- Status
    StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1,-20,0,30)
    StatusText.Position = UDim2.new(0,10,1,-35)
    StatusText.BackgroundColor3 = Color3.fromRGB(35,35,35)
    StatusText.Text = "Ready"
    StatusText.TextColor3 = Color3.fromRGB(200,200,200)
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextScaled = true
    StatusText.Parent = MainFrame
    local stc = Instance.new("UICorner", StatusText) stc.CornerRadius = UDim.new(0,8)

    return scroll, layout
end

-- CREATE PREVIEW
local function createPreview(parent, data)
    for _, c in pairs(parent:GetChildren()) do if c.Name == "Preview" then c:Destroy() end end

    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(1,0,0.6,0)
    viewport.Position = UDim2.new(0,0,0,0)
    viewport.BackgroundTransparency = 1
    viewport.Name = "Preview"
    viewport.Parent = parent

    local cam = Instance.new("Camera")
    cam.FieldOfView = 30
    viewport.CurrentCamera = cam
    cam.Parent = viewport

    local hum = Instance.new("Humanoid")
    local char = Instance.new("Model")
    hum.Parent = char
    char.Parent = viewport

    -- Dummy parts
    local head = Instance.new("Part") head.Name = "Head" head.Size = Vector3.new(2,1,1) head.Parent = char
    local torso = Instance.new("Part") torso.Name = "Torso" torso.Size = Vector3.new(2,2,1) torso.Parent = char
    local la = Instance.new("Part") la.Name = "Left Arm" la.Size = Vector3.new(1,2,1) la.Parent = char
    local ra = Instance.new("Part") ra.Name = "Right Arm" ra.Size = Vector3.new(1,2,1) ra.Parent = char
    local ll = Instance.new("Part") ll.Name = "Left Leg" ll.Size = Vector3.new(1,2,1) ll.Parent = char
    local rl = Instance.new("Part") rl.Name = "Right Leg" rl.Size = Vector3.new(1,2,1) rl.Parent = char

    local desc = createHumanoidDescription(data)
    if desc then
        pcall(function() hum:ApplyDescription(desc) end)
        task.wait(0.5)
        cam.CFrame = CFrame.new(Vector3.new(0,1,5)) * CFrame.Angles(0, math.pi, 0)
    end
end

-- UPDATE PRESETS UI
local scrollFrame, gridLayout
local presetFrames = {}

local function updatePresetsUI()
    for _, f in pairs(presetFrames) do f:Destroy() end
    presetFrames = {}

    for i = 1, #presets do
        if i > MAX_PRESETS then break end
        local frame = Instance.new("Frame")
        frame.BackgroundColor3 = Color3.fromRGB(60,60,60)
        frame.Parent = scrollFrame
        table.insert(presetFrames, frame)
        local c = Instance.new("UICorner", frame) c.CornerRadius = UDim.new(0,8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,20)
        label.Position = UDim2.new(0,0,1,-25)
        label.BackgroundTransparency = 1
        label.Text = presets[i].username or ("P"..i)
        label.TextColor3 = Color3.new(1,1,1)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = frame

        -- Preview
        if presets[i].avatarData then
            spawn(function() createPreview(frame, presets[i].avatarData) end)
        end

        -- Left Click: Load
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                StatusText.Text = "Loading Preset "..i
                local ok, msg = applyStoredAvatar(presets[i])
                StatusText.Text = ok and "Loaded!" or "Failed"
            end
        end)

        -- Right Click: Save
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                StatusText.Text = "Saving..."
                task.wait(0.3)
                local captured = captureCurrentAvatar()
                if captured then
                    presets[i] = { username = "Preset "..i, avatarData = captured }
                    savePresets()
                    updatePresetsUI()
                    StatusText.Text = "Saved to "..i
                else
                    StatusText.Text = "Capture failed"
                end
            end
        end)
    end

    scrollFrame.CanvasSize = UDim2.new(0,0,0, gridLayout.AbsoluteCellCount.Y * 100)
end

-- ANIMATION
local function animate(open)
    if UIState.isAnimating then return end
    UIState.isAnimating = true
    local target = open and UDim2.new(0,380,0,320) or UDim2.new(0,0,0,0)
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = target})
    MainFrame.Visible = true
    tween:Play()
    tween.Completed:Connect(function()
        if not open then MainFrame.Visible = false end
        UIState.isAnimating = false
    end)
end

-- MAIN
loadPresets()
scrollFrame, gridLayout = createUI()
updatePresetsUI()

ToggleButton.MouseButton1Click:Connect(function()
    UIState.isOpen = not UIState.isOpen
    animate(UIState.isOpen)
    ToggleButton.Text = UIState.isOpen and "X" or "Avatar"
end)

SubmitButton.MouseButton1Click:Connect(function()
    local name = UsernameInput.Text
    if name ~= "" then
        UsernameInput.Text = ""
        StatusText.Text = "Applying..."
        local ok, msg = loadAvatar(name)
        StatusText.Text = ok and "Captured: "..name or msg
        if ok then task.wait(1); updatePresetsUI() end
    end
end)

UsernameInput.FocusLost:Connect(function(enter)
    if enter then SubmitButton.MouseButton1Click:Fire() end
end)

-- Add Preset Button
AddPresetButton.MouseButton1Click:Connect(function()
    if #presets < MAX_PRESETS then
        table.insert(presets, { username = "Empty", avatarData = nil })
        savePresets()
        updatePresetsUI()
    else
        StatusText.Text = "Max 10 presets"
    end
end)

-- Auto Reapply
lp.CharacterAdded:Connect(function(char)
    if currentAvatarData then
        char:WaitForChild("Humanoid")
        task.wait(1.5)
        applyStoredAvatar(currentAvatarData)
    end
end)

-- F1 Toggle
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F1 then
        ToggleButton.MouseButton1Click:Fire()
    end
end)

print("AVATAR PRESET LOADED | F1 = Toggle | + = Add Slot")