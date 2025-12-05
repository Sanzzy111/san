pcall(function()

if not game.Players.LocalPlayer.Character or game.Players.LocalPlayer.Character:WaitForChild("Humanoid").RigType ~= Enum.HumanoidRigType.R15 then 
    game.StarterGui:SetCore("SendNotification", {Title = "R6", Text = "You're on R6, bro. Change to R15!", Duration = 60})
    return
end

local st = os.clock()
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

cloneref = cloneref or function(o) return o end
local SanGoGui = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Notification System
local Notifbro = {}
function Notify(titletxt, text, time)
    coroutine.wrap(function()
        local GUI = Instance.new("ScreenGui")
        local Main = Instance.new("Frame", GUI)
        local title = Instance.new("TextLabel", Main)
        local message = Instance.new("TextLabel", Main)
        local UICorner = Instance.new("UICorner", Main)
        UICorner.CornerRadius = UDim.new(0, 8)

        GUI.Name = "BackgroundNotif"
        GUI.Parent = SanGoGui

        local sw = workspace.CurrentCamera.ViewportSize.X
        local sh = workspace.CurrentCamera.ViewportSize.Y
        local nh = sh / 10
        local nw = sw / 5

        Main.Name = "MainFrame"
        Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Main.BackgroundTransparency = 0.1
        Main.BorderSizePixel = 0
        Main.Size = UDim2.new(0, nw, 0, nh)

        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -20, 0, nh / 2.5)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.Font = Enum.Font.GothamBold
        title.Text = titletxt
        title.TextColor3 = Color3.fromRGB(100, 200, 255)
        title.TextScaled = true
        title.TextXAlignment = Enum.TextXAlignment.Left

        message.BackgroundTransparency = 1
        message.Position = UDim2.new(0, 10, 0, nh / 2.5 + 5)
        message.Size = UDim2.new(1, -20, 1, -nh / 2.5 - 10)
        message.Font = Enum.Font.Gotham
        message.Text = text
        message.TextColor3 = Color3.fromRGB(220, 220, 220)
        message.TextScaled = true
        message.TextXAlignment = Enum.TextXAlignment.Left

        local offset = 10
        for _, notif in ipairs(Notifbro) do
            offset = offset + notif.Size.Y.Offset + 10
        end

        Main.Position = UDim2.new(1, 5, 0, offset)
        table.insert(Notifbro, Main)

        task.wait(0.1)
        Main:TweenPosition(UDim2.new(1, -nw - 10, 0, offset), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

        task.wait(time)

        Main:TweenPosition(UDim2.new(1, 5, 0, offset), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.3)

        GUI:Destroy()
        for i, notif in ipairs(Notifbro) do
            if notif == Main then
                table.remove(Notifbro, i)
                break
            end
        end

        for i, notif in ipairs(Notifbro) do
            local newOffset = 10 + (nh + 10) * (i - 1)
            notif:TweenPosition(UDim2.new(1, -nw - 10, 0, newOffset), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        end
    end)()
end

task.wait(0.1)

local guiName = "SanVerificator"
if SanGoGui:FindFirstChild(guiName) then
    Notify("Error","Script Already Executed", 1)
    return
end

-- Check if on mobile/touch device
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local core = cloneref(game.CoreGui)
local old = core:FindFirstChild("ModernSanUI")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernSanUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = core

-- Main Frame (Modern Design)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 500)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = isMobile -- Show by default on mobile, hidden on PC
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)

-- Shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = 0
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.Parent = mainFrame

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner", topBar)
topCorner.CornerRadius = UDim.new(0, 12)

local topBarBottom = Instance.new("Frame")
topBarBottom.Size = UDim2.new(1, 0, 0, 12)
topBarBottom.Position = UDim2.new(0, 0, 1, -12)
topBarBottom.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
topBarBottom.BorderSizePixel = 0
topBarBottom.Parent = topBar

-- Title with gradient
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Text = "SAN ANIMATIONS"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -45, 0.5, -17.5)
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 8)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Category Tabs Container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -20, 0, 45)
tabContainer.Position = UDim2.new(0, 10, 0, 60)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 8)
tabLayout.Parent = tabContainer

-- Content Container
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -125)
contentFrame.Position = UDim2.new(0, 10, 0, 115)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner", contentFrame)
contentCorner.CornerRadius = UDim.new(0, 10)

-- Search Bar
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, -20, 0, 40)
searchFrame.Position = UDim2.new(0, 10, 0, 10)
searchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
searchFrame.BorderSizePixel = 0
searchFrame.Parent = contentFrame

local searchCorner = Instance.new("UICorner", searchFrame)
searchCorner.CornerRadius = UDim.new(0, 8)

local searchIcon = Instance.new("TextLabel")
searchIcon.Text = "🔍"
searchIcon.TextSize = 18
searchIcon.BackgroundTransparency = 1
searchIcon.Size = UDim2.new(0, 30, 1, 0)
searchIcon.Parent = searchFrame

local searchBar = Instance.new("TextBox")
searchBar.Name = "SearchBar"
searchBar.Text = ""
searchBar.PlaceholderText = "Search animations..."
searchBar.Font = Enum.Font.Gotham
searchBar.TextSize = 14
searchBar.TextColor3 = Color3.fromRGB(220, 220, 220)
searchBar.BackgroundTransparency = 1
searchBar.Size = UDim2.new(1, -40, 1, 0)
searchBar.Position = UDim2.new(0, 35, 0, 0)
searchBar.TextXAlignment = Enum.TextXAlignment.Left
searchBar.ClearTextOnFocus = false
searchBar.Parent = searchFrame

-- Scroll Frame for animations
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = contentFrame

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 8)
scrollLayout.Parent = scrollFrame

scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
end)

-- Animation data
OriginalAnimations = {
    ["Idle"] = {
        ["2016 Animation (mm2)"] = {"387947158", "387947464"},
        ["(UGC) Oh Really?"] = {"98004748982532", "98004748982532"},
        ["Astronaut"] = {"891621366", "891633237"},
        ["Adidas Community"] = {"122257458498464", "102357151005774"},
        ["Bold"] = {"16738333868", "16738334710"},
        ["(UGC) Slasher"] = {"140051337061095", "140051337061095"},
        ["(UGC) Retro"] = "121075390792786",
        ["NFL"] = "134630013742019",
        ["OldSchool"] = "10921229866",
        ["Patrol"] = "1148811837",
        ["Popstar"] = "1213044953",
        ["Princess"] = "940996062",
        ["R6"] = "12520982150",
        ["Reanimated R15"] = "4211214992",
        ["Robot"] = "616086039",
        ["Sneaky"] = "1132461372",
        ["Sports (Adidas)"] = "18537363391",
        ["Stylish"] = "10921271391",
        ["Stylized Female"] = "4708184253",
        ["SuperHero"] = "10921286911",
        ["Toy"] = "10921300839",
        ["Vampire"] = "1083439238",
        ["WereWolf"] = "10921329322",
        ["Wicked (Popular)"] = "131326830509784",
        ["No Boundaries (Walmart)"] = "18747060903",
        ["Zombie"] = "616156119"
    }
}

-- Load/Save Animations
local Animations
if isfile("GreyLikesToSmellUrFeet.json") then
    local data = readfile("GreyLikesToSmellUrFeet.json")
    Animations = HttpService:JSONDecode(data)
    Notify("Loaded", "Animations from file", 2)
else
    writefile("GreyLikesToSmellUrFeet.json", HttpService:JSONEncode(OriginalAnimations))
    Animations = OriginalAnimations
    Notify("Saved", "Original animations to file", 2)
end

-- Last used animations
local lastAnimations = {}

-- Category tabs data
local categories = {"Idle", "Walk", "Run", "Jump", "Fall", "Swim", "SwimIdle", "Climb"}
local currentCategory = "Idle"
local categoryButtons = {}

-- Create category tabs
local function createCategoryTabs()
    for _, category in ipairs(categories) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = category .. "Tab"
        tabButton.Text = category
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 12
        tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        tabButton.Size = UDim2.new(0, 70, 1, 0)
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner", tabButton)
        tabCorner.CornerRadius = UDim.new(0, 6)
        
        categoryButtons[category] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            currentCategory = category
            updateCategoryDisplay()
            populateAnimations(category)
        end)
    end
    
    -- Set initial active tab
    updateCategoryDisplay()
end

-- Update active tab visual
local function updateCategoryDisplay()
    for cat, btn in pairs(categoryButtons) do
        if cat == currentCategory then
            btn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
end

-- Create animation button
local function createAnimButton(name, animId, category)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = ""
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.Size = UDim2.new(1, 0, 0, 50)
    button.AutoButtonColor = false
    button.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, -60, 1, 0)
    nameLabel.Position = UDim2.new(0, 15, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = button
    
    local useButton = Instance.new("TextButton")
    useButton.Text = "USE"
    useButton.Font = Enum.Font.GothamBold
    useButton.TextSize = 12
    useButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    useButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    useButton.Size = UDim2.new(0, 50, 0, 30)
    useButton.Position = UDim2.new(1, -60, 0.5, -15)
    useButton.Parent = button
    
    local useCorner = Instance.new("UICorner", useButton)
    useCorner.CornerRadius = UDim.new(0, 6)
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end)
    
    useButton.MouseButton1Click:Connect(function()
        setAnimation(category, animId)
        Notify("Applied", name, 1.5)
    end)
    
    return button
end

-- Populate animations for category
local function populateAnimations(category)
    -- Clear existing buttons
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local anims = Animations[category]
    if not anims then return end
    
    local count = 0
    for name, animId in pairs(anims) do
        createAnimButton(name, animId, category)
        count = count + 1
        if count % 10 == 0 then
            RunService.RenderStepped:Wait()
        end
    end
end

-- Search functionality
searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = searchBar.Text:lower()
    
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            if searchText == "" or child.Name:lower():find(searchText) then
                child.Visible = true
            else
                child.Visible = false
            end
        end
    end
end)

-- Animation control functions
local function freeze()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.PlatformStand = true
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored then
            part.Anchored = true
        end
    end
end

local function unfreeze()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.PlatformStand = false
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Anchored then
            part.Anchored = false
        end
    end
end

local function refresh()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

local function refreshswim()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    task.wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
end

local function refreshclimb()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    task.wait(0.1)
    humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
end

local function StopAnim()
    local speaker = Players.LocalPlayer
    local Char = speaker.Character or speaker.CharacterAdded:Wait()
    local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
    if Hum then
        for _, track in ipairs(Hum:GetPlayingAnimationTracks()) do
            track:Stop(0)
        end
    end
end

-- Reset animation functions
local function ResetAnimation(animationType)
    local speaker = Players.LocalPlayer
    local Char = speaker.Character
    if not Char then return end
    
    local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
    for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
    
    pcall(function()
        local Animate = Char.Animate
        if animationType == "Idle" then
            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
        elseif animationType == "Walk" then
            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        elseif animationType == "Run" then
            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        elseif animationType == "Jump" then
            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        elseif animationType == "Fall" then
            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        elseif animationType == "Swim" and Animate:FindFirstChild("swim") then
            Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0"
        elseif animationType == "SwimIdle" and Animate:FindFirstChild("swimidle") then
            Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0"
        elseif animationType == "Climb" then
            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end
    end)
end

-- Save last animations
local function saveLastAnimations()
    local data = HttpService:JSONEncode(lastAnimations)
    pcall(function() writefile("MeWhenUrMom.json", data) end)
end

-- Set animation function
function setAnimation(animationType, animationId)
    if type(animationId) ~= "table" and type(animationId) ~= "string" then return end
    
    local player = Players.LocalPlayer
    if not player.Character then return end
    
    local Char = player.Character
    local Animate = Char:FindFirstChild("Animate")
    if not Animate then return end

    freeze()
    wait(0.1)

    local success = pcall(function()
        ResetAnimation(animationType)
        
        if animationType == "Idle" then
            lastAnimations.Idle = animationId
            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[1]
            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[2]
            refresh()
        elseif animationType == "Walk" then
            lastAnimations.Walk = animationId
            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refresh()
        elseif animationType == "Run" then
            lastAnimations.Run = animationId
            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refresh()
        elseif animationType == "Jump" then
            lastAnimations.Jump = animationId
            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refresh()
        elseif animationType == "Fall" then
            lastAnimations.Fall = animationId
            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refresh()
        elseif animationType == "Swim" and Animate:FindFirstChild("swim") then
            lastAnimations.Swim = animationId
            Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refreshswim()
        elseif animationType == "SwimIdle" and Animate:FindFirstChild("swimidle") then
            lastAnimations.SwimIdle = animationId
            Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refreshswim()
        elseif animationType == "Climb" then
            lastAnimations.Climb = animationId
            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refreshclimb()
        end
        
        saveLastAnimations()
    end)

    wait(0.1)
    unfreeze()
end

-- Load last animations on startup
local function loadLastAnimations()
    if isfile("MeWhenUrMom.json") then
        local data = readfile("MeWhenUrMom.json")
        lastAnimations = HttpService:JSONDecode(data)
        Notify("Restored", "Last used animations loaded", 2)
        
        task.wait(0.5)
        
        for animType, animId in pairs(lastAnimations) do
            setAnimation(animType, animId)
        end
    end
end

-- Character respawn handler
Players.LocalPlayer.CharacterAdded:Connect(function(character)
    local hum = character:WaitForChild("Humanoid")
    local animate = character:WaitForChild("Animate", 10)
    
    if not animate then
        Notify("Error", "Animate script not found!", 3)
        return
    end
    
    task.wait(1)
    
    -- Reapply last animations
    for animType, animId in pairs(lastAnimations) do
        setAnimation(animType, animId)
    end
end)

-- Toggle UI with 'V' key (PC only)
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.V then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
end

-- Make frame draggable on mobile
if isMobile then
    local dragging = false
    local dragStart = nil
    local startPos = nil

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Initialize UI
createCategoryTabs()
populateAnimations(currentCategory)
loadLastAnimations()

-- Load time
local lt = os.clock() - st
Notify("Loaded", string.format("UI ready in %.2f seconds", lt), 3)
Notify("Controls", isMobile and "Drag to move UI" or "Press V to toggle UI", 4)

end)"] = {"80479383912838", "80479383912838"},
        ["(UGC) Magician"] = {"139433213852503", "139433213852503"},
        ["(UGC) John Doe"] = {"72526127498800", "72526127498800"},
        ["(UGC) Noli"] = {"139360856809483", "139360856809483"},
        ["(UGC) Coolkid"] = {"95203125292023", "95203125292023"},
        ["(UGC) Survivor Injured"] = {"73905365652295", "73905365652295"},
        ["(UGC) Retro Zombie"] = {"90806086002292", "90806086002292"},
        ["(UGC) 1x1x1x1"] = {"76780522821306", "76780522821306"},
        ["Borock"] = {"3293641938", "3293642554"},
        ["Bubbly"] = {"910004836", "910009958"},
        ["Cartoony"] = {"742637544", "742638445"},
        ["Confident"] = {"1069977950", "1069987858"},
        ["Catwalk Glam"] = {"133806214992291","94970088341563"},
        ["Cowboy"] = {"1014390418", "1014398616"},
        ["Drooling Zombie"] = {"3489171152", "3489171152"},
        ["Elder"] = {"10921101664", "10921102574"},
        ["Ghost"] = {"616006778","616008087"},
        ["Knight"] = {"657595757", "657568135"},
        ["Levitation"] = {"616006778", "616008087"},
        ["Mage"] = {"707742142", "707855907"},
        ["MrToilet"] = {"4417977954", "4417978624"},
        ["Ninja"] = {"656117400", "656118341"},
        ["NFL"] = {"92080889861410", "74451233229259"},
        ["OldSchool"] = {"10921230744", "10921232093"},
        ["Patrol"] = {"1149612882", "1150842221"},
        ["Pirate"] = {"750781874", "750782770"},
        ["Default Retarget"] = {"95884606664820", "95884606664820"},
        ["Very Long"] = {"18307781743", "18307781743"},
        ["Sway"] = {"560832030", "560833564"},
        ["Popstar"] = {"1212900985", "1150842221"},
        ["Princess"] = {"941003647", "941013098"},
        ["R6"] = {"12521158637","12521162526"},
        ["R15 Reanimated"] = {"4211217646", "4211218409"},
        ["Realistic"] = {"17172918855", "17173014241"},
        ["Robot"] = {"616088211", "616089559"},
        ["Sneaky"] = {"1132473842", "1132477671"},
        ["Sports (Adidas)"] = {"18537376492", "18537371272"},
        ["Soldier"] = {"3972151362", "3972151362"},
        ["Stylish"] = {"616136790", "616138447"},
        ["Stylized Female"] = {"4708191566", "4708192150"},
        ["Superhero"] = {"10921288909", "10921290167"},
        ["Toy"] = {"782841498", "782845736"},
        ["Udzal"] = {"3303162274", "3303162549"},
        ["Vampire"] = {"1083445855", "1083450166"},
        ["Werewolf"] = {"1083195517", "1083214717"},
        ["Wicked (Popular)"] = {"118832222982049", "76049494037641"},
        ["No Boundaries (Walmart)"] = {"18747067405", "18747063918"},
        ["Zombie"] = {"616158929", "616160636"},
        ["(UGC) Zombie"] = {"77672872857991", "77672872857991"},
        ["(UGC) TailWag"] = {"129026910898635", "129026910898635"}
    },
    ["Walk"] = {
        ["Gojo"] = "95643163365384",
        ["Geto"] = "85811471336028",
        ["Astronaut"] = "891667138",
        ["(UGC) Zombie"] = "113603435314095",
        ["Adidas Community"] = "122150855457006",
        ["Bold"] = "16738340646",
        ["Bubbly"] = "910034870",
        ["(UGC) Smooth"] = "76630051272791",
        ["Cartoony"] = "742640026",
        ["Confident"] = "1070017263",
        ["Cowboy"] = "1014421541",
        ["(UGC) Retro"] = "107806791584829",
        ["(UGC) Retro Zombie"] = "140703855480494",
        ["Catwalk Glam"] = "109168724482748",
        ["Drooling Zombie"] = "3489174223",
        ["Elder"] = "10921111375",
        ["Ghost"] = "616013216",
        ["Knight"] = "10921127095",
        ["Levitation"] = "616013216",
        ["Mage"] = "707897309",
        ["Ninja"] = "656121766",
        ["NFL"] = "110358958299415",
        ["OldSchool"] = "10921244891",
        ["Patrol"] = "1151231493",
        ["Pirate"] = "750785693",
        ["Default Retarget"] = "115825677624788",
        ["Popstar"] = "1212980338",
        ["Princess"] = "941028902",
        ["R6"] = "12518152696",
        ["R15 Reanimated"] = "4211223236",
        ["2016 Animation (mm2)"] = "387947975",
        ["Robot"] = "616095330",
        ["Sneaky"] = "1132510133",
        ["Sports (Adidas)"] = "18537392113",
        ["Stylish"] = "616146177",
        ["Stylized Female"] = "4708193840",
        ["Superhero"] = "10921298616",
        ["Toy"] = "782843345",
        ["Udzal"] = "3303162967",
        ["Vampire"] = "1083473930",
        ["Werewolf"] = "1083178339",
        ["Wicked (Popular)"] = "92072849924640",
        ["No Boundaries (Walmart)"] = "18747074203",
        ["Zombie"] = "616168032"
    },
    ["Run"] = {
        ["2016 Animation (mm2)"] = "387947975",
        ["(UGC) Soccer"] = "116881956670910",
        ["Adidas Community"] = "82598234841035",
        ["Astronaut"] = "10921039308",
        ["Bold"] = "16738337225",
        ["Bubbly"] = "10921057244",
        ["Cartoony"] = "10921076136",
        ["(UGC) Dog"] = "130072963359721",
        ["Confident"] = "1070001516",
        ["(UGC) Pride"] = "116462200642360",
        ["(UGC) Retro"] = "107806791584829",
        ["(UGC) Retro Zombie"] = "140703855480494", 
        ["Cowboy"] = "1014401683",
        ["Catwalk Glam"] = "81024476153754",
        ["Drooling Zombie"] = "3489173414",
        ["Elder"] = "10921104374",
        ["Ghost"] = "616013216",
        ["Heavy Run (Udzal / Borock)"] = "3236836670",
        ["Knight"] = "10921121197",
        ["Levitation"] = "616010382",
        ["Mage"] = "10921148209",
        ["MrToilet"] = "4417979645",
        ["Ninja"] = "656118852",
        ["NFL"] = "117333533048078",
        ["OldSchool"] = "10921240218",
        ["Patrol"] = "1150967949",
        ["Pirate"] = "750783738",
        ["Default Retarget"] = "102294264237491",
        ["Popstar"] = "1212980348",
        ["Princess"] = "941015281",
        ["R6"] = "12518152696",
        ["R15 Reanimated"] = "4211220381",
        ["Robot"] = "10921250460",
        ["Sneaky"] = "1132494274",
        ["Sports (Adidas)"] = "18537384940",
        ["Stylish"] = "10921276116",
        ["Stylized Female"] = "4708192705",
        ["Superhero"] = "10921291831",
        ["Toy"] = "10921306285",
        ["Vampire"] = "10921320299",
        ["Werewolf"] = "10921336997",
        ["Wicked (Popular)"] = "72301599441680",
        ["No Boundaries (Walmart)"] = "18747070484",
        ["Zombie"] = "616163682"
    },
    ["Jump"] = {
        ["Astronaut"] = "891627522",
        ["Adidas Community"] = "75290611992385",
        ["Bold"] = "16738336650",
        ["Bubbly"] = "910016857",
        ["Cartoony"] = "742637942",
        ["Catwalk Glam"] = "116936326516985",
        ["Confident"] = "1069984524",
        ["Cowboy"] = "1014394726",
        ["Elder"] = "10921107367",
        ["Ghost"] = "616008936",
        ["Knight"] = "910016857",
        ["Levitation"] = "616008936",
        ["Mage"] = "10921149743",
        ["Ninja"] = "656117878",
        ["NFL"] = "119846112151352",
        ["OldSchool"] = "10921242013",
        ["Patrol"] = "1148811837",
        ["Pirate"] = "750782230",
        ["(UGC) Retro"] = "139390570947836",
        ["Default Retarget"] = "117150377950987",
        ["Popstar"] = "1212954642",
        ["Princess"] = "941008832",
        ["Robot"] = "616090535",
        ["R15 Reanimated"] = "4211219390",
        ["R6"] = "12520880485",
        ["Sneaky"] = "1132489853",
        ["Sports (Adidas)"] = "18537380791",
        ["Stylish"] = "616139451",
        ["Stylized Female"] = "4708188025",
        ["Superhero"] = "10921294559",
        ["Toy"] = "10921308158",
        ["Vampire"] = "1083455352",
        ["Werewolf"] = "1083218792",
        ["Wicked (Popular)"] = "104325245285198",
        ["No Boundaries (Walmart)"] = "18747069148",
        ["Zombie"] = "616161997"
    },
    ["Fall"] = {
        ["Astronaut"] = "891617961",
        ["Adidas Community"] = "98600215928904",
        ["Bold"] = "16738333171",
        ["Bubbly"] = "910001910",
        ["Cartoony"] = "742637151",
        ["Catwalk Glam"] = "92294537340807",
        ["Confident"] = "1069973677",
        ["Cowboy"] = "1014384571",
        ["Elder"] = "10921105765",
        ["Knight"] = "10921122579",
        ["Levitation"] = "616005863",
        ["Mage"] = "707829716",
        ["Ninja"] = "656115606",
        ["NFL"] = "129773241321032",
        ["OldSchool"] = "10921241244",
        ["Patrol"] = "1148863382",
        ["Pirate"] = "750780242",
        ["Default Retarget"] = "110205622518029",
        ["Popstar"] = "1212900995",
        ["Princess"] = "941000007",
        ["Robot"] = "616087089",
        ["R15 Reanimated"] = "4211216152",
        ["R6"] = "12520972571",
        ["Sneaky"] = "1132469004",
        ["Sports (Adidas)"] = "18537367238",
        ["Stylish"] = "616134815",
        ["Stylized Female"] = "4708186162",
        ["Superhero"] = "10921293373",
        ["Toy"] = "782846423",
        ["Vampire"] = "1083443587",
        ["Werewolf"] = "1083189019",
        ["Wicked (Popular)"] = "121152442762481",
        ["No Boundaries (Walmart)"] = "18747062535",
        ["Zombie"] = "616157476"
    },
    ["SwimIdle"] = {
        ["Astronaut"] = "891663592",
        ["Adidas Community"] = "109346520324160",
        ["Bold"] = "16738339817",
        ["Bubbly"] = "910030921",
        ["Cartoony"] = "10921079380",
        ["Catwalk Glam"] = "98854111361360",
        ["Confident"] = "1070012133",
        ["CowBoy"] = "1014411816",
        ["Elder"] = "10921110146",
        ["Mage"] = "707894699",
        ["Ninja"] = "656118341",
        ["NFL"] = "79090109939093",
        ["Patrol"] = "1151221899",
        ["Knight"] = "10921125935",
        ["OldSchool"] = "10921244018",
        ["Levitation"] = "10921139478",
        ["Popstar"] = "1212998578",
        ["Princess"] = "941025398",
        ["Pirate"] = "750785176",
        ["R6"] = "12518152696",
        ["Robot"] = "10921253767",
        ["Sneaky"] = "1132506407",
        ["Sports (Adidas)"] = "18537387180",
        ["Stylish"] = "10921281964",
        ["Stylized"] = "4708190607",
        ["SuperHero"] = "10921297391",
        ["Toy"] = "10921310341",
        ["Vampire"] = "10921325443",
        ["Werewolf"] = "10921341319",
        ["Wicked (Popular)"] = "113199415118199",
        ["No Boundaries (Walmart)"] = "18747071682"
    },
    ["Swim"] = {
        ["Astronaut"] = "891663592",
        ["Adidas Community"] = "133308483266208",
        ["Bubbly"] = "910028158",
        ["Bold"] = "16738339158",
        ["Cartoony"] = "10921079380",
        ["Catwalk Glam"] = "134591743181628",
        ["CowBoy"] = "1014406523",
        ["Confident"] = "1070009914",
        ["Elder"] = "10921108971",
        ["Knight"] = "10921125160",
        ["Mage"] = "707876443",
        ["NFL"] = "132697394189921",
        ["OldSchool"] = "10921243048",
        ["PopStar"] = "1212998578",
        ["Princess"] = "941018893",
        ["Pirate"] = "750784579",
        ["Patrol"] = "1151204998",
        ["R6"] = "12518152696",
        ["Robot"] = "10921253142",
        ["Levitation"] = "10921138209",
        ["Stylish"] = "10921281000",
        ["SuperHero"] = "10921295495",
        ["Sneaky"] = "1132500520",
        ["Sports (Adidas)"] = "18537389531",
        ["Toy"] = "10921309319",
        ["Vampire"] = "10921324408",
        ["Werewolf"] = "10921340419",
        ["Wicked (Popular)"] = "99384245425157",
        ["No Boundaries (Walmart)"] = "18747073181",
        ["Zombie"] = "616165109"
    },
    ["Climb"] = {
        ["Astronaut"] = "10921032124",
        ["Adidas Community"] = "88763136693023",
        ["Bold"] = "16738332169",
        ["Cartoony"] = "742636889",
        ["Catwalk Glam"] = "119377220967554",
        ["Confident"] = "1069946257",
        ["CowBoy"] = "1014380606",
        ["Elder"] = "845392038",
        ["Ghost"] = "616003713",
        ["Knight"] = "10921125160",
        ["Levitation"] = "10921132092",
        ["Mage"] = "707826056",
        ["Ninja"] = "656114359",
        ["(UGC) Retro