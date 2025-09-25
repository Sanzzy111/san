pcall(function()
    if not game.Players.LocalPlayer.Character or game.Players.LocalPlayer.Character:WaitForChild("Humanoid").RigType ~= Enum.HumanoidRigType.R15 then 
        game.StarterGui:SetCore("SendNotification", {Title = "R6", Text = "You're on R6, bro. Change to R15!", Duration = 60})
        return
    end

    local st = os.clock()
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    cloneref = cloneref or function(o) return o end
    local GazeGoGui = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Notifbro = {}

    function Notify(titletxt, text, time)
        coroutine.wrap(function()
            local GUI = Instance.new("ScreenGui")
            local Main = Instance.new("Frame", GUI)
            local UICorner = Instance.new("UICorner", Main)
            local UIStroke = Instance.new("UIStroke", Main)
            local title = Instance.new("TextLabel", Main)
            local message = Instance.new("TextLabel", Main)

            GUI.Name = "BackgroundNotif"
            GUI.Parent = GazeGoGui

            local sw = workspace.CurrentCamera.ViewportSize.X
            local sh = workspace.CurrentCamera.ViewportSize.Y
            local nh = sh / 8
            local nw = sw / 4

            Main.Name = "MainFrame"
            Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Main.BackgroundTransparency = 0.1
            Main.BorderSizePixel = 0
            Main.Size = UDim2.new(0, nw, 0, nh)
            UICorner.CornerRadius = UDim.new(0, 10)
            UIStroke.Thickness = 1
            UIStroke.Color = Color3.fromRGB(100, 100, 100)
            UIStroke.Transparency = 0.5

            title.BackgroundTransparency = 1
            title.Size = UDim2.new(1, 0, 0, nh / 2)
            title.Font = Enum.Font.GothamBold
            title.Text = titletxt
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextScaled = true
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Position = UDim2.new(0, 10, 0, 5)

            message.BackgroundTransparency = 1
            message.Position = UDim2.new(0, 10, 0, nh / 2)
            message.Size = UDim2.new(1, -10, 1, -nh / 2 - 5)
            message.Font = Enum.Font.Gotham
            message.Text = text
            message.TextColor3 = Color3.fromRGB(200, 200, 200)
            message.TextScaled = true
            message.TextXAlignment = Enum.TextXAlignment.Left

            local offset = 50
            for _, notif in ipairs(Notifbro) do
                offset = offset + notif.Size.Y.Offset + 10
            end

            Main.Position = UDim2.new(1, 5, 0, offset)
            table.insert(Notifbro, Main)

            task.wait(0.1)
            Main:TweenPosition(UDim2.new(1, -nw - 5, 0, offset), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
            task.wait(time)
            Main:TweenPosition(UDim2.new(1, 5, 0, offset), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true)
            task.wait(0.5)
            GUI:Destroy()
            for i, notif in ipairs(Notifbro) do
                if notif == Main then
                    table.remove(Notifbro, i)
                    break
                end
            end

            for i, notif in ipairs(Notifbro) do
                local newOffset = 50 + (nh + 10) * (i - 1)
                notif:TweenPosition(UDim2.new(1, -nw - 5, 0, newOffset), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
            end
        end)()
    end

    local guiName = "GazeVerificator"
    if GazeGoGui:FindFirstChild(guiName) then
        Notify("Error", "Script Already Executed", 1)
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = guiName
    screenGui.Parent = GazeGoGui
    screenGui.ResetOnSpawn = false

    local camera = workspace.CurrentCamera
    local function getScaledSize(relativeWidth, relativeHeight)
        local viewportSize = camera.ViewportSize
        return UDim2.new(0, viewportSize.X * relativeWidth, 0, viewportSize.Y * relativeHeight)
    end

    local mainFrame = Instance.new("TextButton")
    mainFrame.Name = "GazeBro"
    mainFrame.Text = ""
    mainFrame.Size = getScaledSize(0.5, 0.45)
    mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset / 2, 0.5, -mainFrame.Size.Y.Offset / 2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    local UICorner = Instance.new("UICorner", mainFrame)
    UICorner.CornerRadius = UDim.new(0, 15)
    local UIStroke = Instance.new("UIStroke", mainFrame)
    UIStroke.Thickness = 1
    UIStroke.Color = Color3.fromRGB(100, 100, 100)
    UIStroke.Transparency = 0.5

    local animListFrame = Instance.new("Frame")
    animListFrame.Name = "AnimListFrame"
    animListFrame.Size = UDim2.new(0.55, 0, 1, 0)
    animListFrame.Position = UDim2.new(0, 0, 0, 0)
    animListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    animListFrame.BackgroundTransparency = 0.2
    animListFrame.BorderSizePixel = 0
    animListFrame.Parent = mainFrame
    local UICornerAnimList = Instance.new("UICorner", animListFrame)
    UICornerAnimList.CornerRadius = UDim.new(0, 15)

    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(0.45, -10, 1, 0)
    statusFrame.Position = UDim2.new(0.55, 5, 0, 0)
    statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    statusFrame.BackgroundTransparency = 0.2
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainFrame
    local UICornerStatus = Instance.new("UICorner", statusFrame)
    UICornerStatus.CornerRadius = UDim.new(0, 15)

    local gazeLabel = Instance.new("TextLabel")
    gazeLabel.Name = "GazeLabel"
    gazeLabel.Text = "GAZE ANIMATOR"
    gazeLabel.Font = Enum.Font.GothamBlack
    gazeLabel.TextScaled = true
    gazeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    gazeLabel.BackgroundTransparency = 1
    gazeLabel.Size = UDim2.new(0.7, 0, 0.1, 0)
    gazeLabel.Position = UDim2.new(0, 5, 0, 5)
    gazeLabel.Parent = animListFrame

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextScaled = true
    closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Parent = animListFrame

    local hideButton = Instance.new("TextButton")
    hideButton.Name = "HideButton"
    hideButton.Text = "-"
    hideButton.Font = Enum.Font.GothamBold
    hideButton.TextScaled = true
    hideButton.TextColor3 = Color3.fromRGB(255, 255, 100)
    hideButton.BackgroundTransparency = 1
    hideButton.Size = UDim2.new(0, 30, 0, 30)
    hideButton.Position = UDim2.new(1, -75, 0, 5) -- Adjusted for spacing
    hideButton.Parent = animListFrame

    local searchBar = Instance.new("TextBox")
    searchBar.Name = "SearchBar"
    searchBar.Text = ""
    searchBar.PlaceholderText = "Search Animations..."
    searchBar.Font = Enum.Font.Gotham
    searchBar.TextScaled = true
    searchBar.TextColor3 = Color3.fromRGB(200, 200, 200)
    searchBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    searchBar.BackgroundTransparency = 0.2
    searchBar.BorderSizePixel = 0
    searchBar.Size = UDim2.new(0.9, 0, 0.08, 0)
    searchBar.Position = UDim2.new(0.05, 0, 0.15, 0) -- Adjusted for spacing
    searchBar.Parent = animListFrame
    local UICornerSB = Instance.new("UICorner", searchBar)
    UICornerSB.CornerRadius = UDim.new(0, 8)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(0.9, 0, 0.75, 0) -- Adjusted to fit layout
    scrollFrame.Position = UDim2.new(0.05, 0, 0.25, 0) -- Adjusted for spacing
    scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    scrollFrame.BackgroundTransparency = 0.2
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = animListFrame
    local UICornerScroll = Instance.new("UICorner", scrollFrame)
    UICornerScroll.CornerRadius = UDim.new(0, 8)

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Padding = UDim.new(0, 5)
    scrollLayout.Parent = scrollFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "CURRENT ANIMATIONS"
    statusLabel.Font = Enum.Font.GothamBlack
    statusLabel.TextScaled = true
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, -10, 0.1, 0)
    statusLabel.Position = UDim2.new(0, 5, 0, 5)
    statusLabel.Parent = statusFrame

    local statusListFrame = Instance.new("ScrollingFrame")
    statusListFrame.Name = "StatusListFrame"
    statusListFrame.Size = UDim2.new(0.9, 0, 0.65, 0)
    statusListFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
    statusListFrame.BackgroundTransparency = 1
    statusListFrame.ScrollBarThickness = 4
    statusListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    statusListFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    statusListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    statusListFrame.Parent = statusFrame

    local statusLayout = Instance.new("UIListLayout")
    statusLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statusLayout.Padding = UDim.new(0, 5)
    statusLayout.Parent = statusListFrame

    local resetAllButton = Instance.new("TextButton")
    resetAllButton.Name = "ResetAllButton"
    resetAllButton.Text = "Reset All Animations"
    resetAllButton.Font = Enum.Font.GothamBold
    resetAllButton.TextScaled = true
    resetAllButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    resetAllButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    resetAllButton.BackgroundTransparency = 0.3
    resetAllButton.Size = UDim2.new(0.9, 0, 0.15, 0)
    resetAllButton.Position = UDim2.new(0.05, 0, 0.80, 0)
    resetAllButton.Parent = statusFrame
    local UICornerReset = Instance.new("UICorner", resetAllButton)
    UICornerReset.CornerRadius = UDim.new(0, 8)

    local animationTypes = {"Idle", "Walk", "Run", "Jump", "Fall", "SwimIdle", "Swim", "Climb"}
    local currentAnimations = {
        Idle = "None",
        Walk = "None",
        Run = "None",
        Jump = "None",
        Fall = "None",
        SwimIdle = "None",
        Swim = "None",
        Climb = "None"
    }
    local statusLabels = {}

    for _, animType in ipairs(animationTypes) do
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = animType .. "Status"
        statusLabel.Text = animType .. ": None"
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextScaled = true
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Size = UDim2.new(1, -10, 0, 20)
        statusLabel.TextTruncate = Enum.TextTruncate.AtEnd -- Prevent text overflow
        statusLabel.Parent = statusListFrame
        statusLabels[animType] = statusLabel
        statusListFrame.CanvasSize = UDim2.new(0, 0, 0, statusLayout.AbsoluteContentSize.Y)
    end

    local buttons = {}

    local function createTheButton(text, callback)
        local button = Instance.new("TextButton")
        button.Text = text
        button.Font = Enum.Font.GothamBold
        button.TextScaled = true
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.BackgroundTransparency = 0.3
        button.Size = UDim2.new(1, -10, 0, 35)
        button.Position = UDim2.new(0, 5, 0, #buttons * 40)
        button.BorderSizePixel = 0
        button.Parent = scrollFrame
        local UICornerBtn = Instance.new("UICorner", button)
        UICornerBtn.CornerRadius = UDim.new(0, 8)
        local UIStrokeBtn = Instance.new("UIStroke", button)
        UIStrokeBtn.Thickness = 1
        UIStrokeBtn.Color = Color3.fromRGB(100, 100, 100)
        UIStrokeBtn.Transparency = 0.5

        button.MouseButton1Click:Connect(callback)
        table.insert(buttons, button)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #buttons * 40)
    end

    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = searchBar.Text:lower()
        local order = 0
        for _, button in ipairs(buttons) do
            if searchText == "" or button.Text:lower():find(searchText) then
                button.Visible = true
                button.Position = UDim2.new(0, 5, 0, order * 40)
                order += 1
            else
                button.Visible = false
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, order * 40)
    end)

    local normalSize = getScaledSize(0.5, 0.45)
    local normalPosition = UDim2.new(0.5, -normalSize.X.Offset / 2, 0.5, -normalSize.Y.Offset / 2)
    local iconSize = getScaledSize(0.05, 0.05)
    local iconPosition = UDim2.new(0.95, -iconSize.X.Offset, 0.05, 0)
    local isMinimized = false
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function handleMinimize()
        if isMinimized then
            local tween = TweenService:Create(mainFrame, tweenInfo, {Size = normalSize, Position = normalPosition})
            tween:Play()
            task.wait(0.3)
            animListFrame.Visible = true
            statusFrame.Visible = true
            gazeLabel.Text = "GAZE ANIMATOR"
            mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            UICorner.CornerRadius = UDim.new(0, 15)
        else
            local tween = TweenService:Create(mainFrame, tweenInfo, {Size = iconSize, Position = iconPosition})
            animListFrame.Visible = false
            statusFrame.Visible = false
            gazeLabel.Text = "GAZE"
            mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            UICorner.CornerRadius = UDim.new(0.5, 0)
            task.wait(0.3)
            tween:Play()
        end
        isMinimized = not isMinimized
        Notify("GUI", isMinimized and "Minimized" or "Restored", 1)
    end

    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        Notify("GUI", mainFrame.Visible and "Opened" or "Closed", 1)
    end)

    hideButton.MouseButton1Click:Connect(handleMinimize)

    mainFrame.MouseButton1Click:Connect(function()
        if isMinimized then
            handleMinimize()
        end
    end)

    local lastAnimations = {}

    local function saveLastAnimations()
        local data = HttpService:JSONEncode(lastAnimations)
        writefile("MeWhenUrMom.json", data)
    end

    local function loadLastAnimations()
        if isfile("MeWhenUrMom.json") then
            local data = readfile("MeWhenUrMom.json")
            Notify("Yippe", "Saved Animations Found, loading...", 5)
            lastAnimations = HttpService:JSONDecode(data) or {}
            for animType, animId in pairs(lastAnimations) do
                if animType ~= "IdleName" and animType ~= "WalkName" and animType ~= "RunName" and animType ~= "JumpName" and
                   animType ~= "FallName" and animType ~= "SwimIdleName" and animType ~= "SwimName" and animType ~= "ClimbName" then
                    setAnimation(animType, animId, lastAnimations[animType .. "Name"])
                end
            end
        else
            Notify("First?", "No Saved Animations Found", 5)
        end
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

    local function ResetIdle()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop(0)
        end
        pcall(function()
            local Animate = Char.Animate
            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
        currentAnimations.Idle = "None"
        statusLabels.Idle.Text = "Idle: None"
        lastAnimations.Idle = nil
        lastAnimations.IdleName = nil
        saveLastAnimations()
        Notify("Reset", "Idle Animation Reset", 1)
    end

    local function ResetWalk()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop(0)
        end
        pcall(function()
            local Animate = Char.Animate
            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
        currentAnimations.Walk = "None"
        statusLabels.Walk.Text = "Walk: None"
        lastAnimations.Walk = nil
        lastAnimations.WalkName = nil
        saveLastAnimations()
        Notify("Reset", "Walk Animation Reset", 1)
    end

    local function ResetRun()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop(0)
        end
        pcall(function()
            local Animate = Char.Animate
            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
        currentAnimations.Run = "None"
        statusLabels.Run.Text = "Run: None"
        lastAnimations.Run = nil
        lastAnimations.RunName = nil
        saveLastAnimations()
        Notify("Reset", "Run Animation Reset", 1)
    end

    local function ResetJump()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop(0)
        end
        pcall(function()
            local Animate = Char.Animate
            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
        currentAnimations.Jump = "None"
        statusLabels.Jump.Text = "Jump: None"
        lastAnimations.Jump = nil
        lastAnimations.JumpName = nil
        saveLastAnimations()
        Notify("Reset", "Jump Animation Reset", 1)
    end

    local function ResetFall()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop(0)
        end
        pcall(function()
            local Animate = Char.Animate
            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
        currentAnimations.Fall = "None"
        statusLabels.Fall.Text = "Fall: None"
        lastAnimations.Fall = nil
        lastAnimations.FallName = nil
        saveLastAnimations()
        Notify("Reset", "Fall Animation Reset", 1)
    end

    local function ResetSwim()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop(0)
        end
        pcall(function()
            local Animate = Char.Animate
            if Animate.swim then
                Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
        currentAnimations.Swim = "None"
        statusLabels.Swim.Text = "Swim: None"
        lastAnimations.Swim = nil
        lastAnimations.SwimName = nil
        saveLastAnimations()
        Notify("Reset", "Swim Animation Reset", 1)
    end

    local function ResetSwimIdle()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop(0)
        end
        pcall(function()
            local Animate = Char.Animate
            if Animate.swimidle then
                Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0"
            end
        end)
        currentAnimations.SwimIdle = "None"
        statusLabels.SwimIdle.Text = "SwimIdle: None"
        lastAnimations.SwimIdle = nil
        lastAnimations.SwimIdleName = nil
        saveLastAnimations()
        Notify("Reset", "SwimIdle Animation Reset", 1)
    end

    local function ResetClimb()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop(0)
        end
        pcall(function()
            local Animate = Char.Animate
            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
        currentAnimations.Climb = "None"
        statusLabels.Climb.Text = "Climb: None"
        lastAnimations.Climb = nil
        lastAnimations.ClimbName = nil
        saveLastAnimations()
        Notify("Reset", "Climb Animation Reset", 1)
    end

    resetAllButton.MouseButton1Click:Connect(function()
        ResetIdle()
        ResetWalk()
        ResetRun()
        ResetJump()
        ResetFall()
        ResetSwim()
        ResetSwimIdle()
        ResetClimb()
        Notify("Reset", "All Animations Reset", 2)
    end)

    local function setAnimation(animationType, animationId, animName)
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        if not Char then return end
        local Animate = Char:FindFirstChild("Animate")
        if not Animate then return end
        freeze()
        task.wait(0.1)

        if animationType == "Idle" then
            lastAnimations.Idle = animationId
            lastAnimations.IdleName = animName
            ResetIdle()
            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[1]
            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[2]
            refresh()
        elseif animationType == "Walk" then
            lastAnimations.Walk = animationId
            lastAnimations.WalkName = animName
            ResetWalk()
            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refresh()
        elseif animationType == "Run" then
            lastAnimations.Run = animationId
            lastAnimations.RunName = animName
            ResetRun()
            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refresh()
        elseif animationType == "Jump" then
            lastAnimations.Jump = animationId
            lastAnimations.JumpName = animName
            ResetJump()
            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refresh()
        elseif animationType == "Fall" then
            lastAnimations.Fall = animationId
            lastAnimations.FallName = animName
            ResetFall()
            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refresh()
        elseif animationType == "Swim" then
            lastAnimations.Swim = animationId
            lastAnimations.SwimName = animName
            if Animate.swim then
                ResetSwim()
                Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refreshswim()
            end
        elseif animationType == "SwimIdle" then
            lastAnimations.SwimIdle = animationId
            lastAnimations.SwimIdleName = animName
            if Animate.swimidle then
                ResetSwimIdle()
                Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refreshswim()
            end
        elseif animationType == "Climb" then
            lastAnimations.Climb = animationId
            lastAnimations.ClimbName = animName
            ResetClimb()
            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            refreshclimb()
        end
        currentAnimations[animationType] = animName or "None"
        statusLabels[animationType].Text = animationType .. ": " .. (animName or "None")
        saveLastAnimations()
        unfreeze()
        Notify(animationType, (animName or "None") .. " Applied", 1)
    end

    local function applySavedAnimations(character)
        local humanoid = character:WaitForChild("Humanoid")
        while humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll do
            task.wait(0.3)
        end
        task.wait(0.1)
        for animType, animId in pairs(lastAnimations) do
            if animType ~= "IdleName" and animType ~= "WalkName" and animType ~= "RunName" and animType ~= "JumpName" and
               animType ~= "FallName" and animType ~= "SwimIdleName" and animType ~= "SwimName" and animType ~= "ClimbName" then
                setAnimation(animType, animId, lastAnimations[animType .. "Name"])
            end
        end
    end

    local function createButton(tab, text, animationType, animationId)
        createTheButton(text .. " - " .. animationType, function()
            setAnimation(animationType, animationId, text)
        end)
    end

    local function Buy(gamePassID)
        local MarketplaceService = game:GetService("MarketplaceService")
        local success, errorMessage = pcall(function()
            MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, gamePassID)
        end)
        if not success then
            setclipboard("https://www.roblox.com/game-pass/" .. gamePassID)
            Notify("Copied", "Gamepass Link Copied", 5)
        end
    end

    local function PlayEmote(animationId)
        StopAnim()
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. animationId
        local animationTrack = humanoid:LoadAnimation(animation)
        animationTrack:Play()
        local function onMoved()
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                animationTrack:Stop()
            end
        end
        local checkMovement = game:GetService("RunService").RenderStepped:Connect(onMoved)
    end

    local function AddEmote(name, id)
        createTheButton(name .. " - Emote", function()
            PlayEmote(id)
            Notify("Emote", name .. " Played", 1)
        end)
    end

    local function AddDonate(Price, Id)
        createTheButton("Donate " .. Price .. " Robux", function()
            Buy(Id)
        end)
    end

    local Animations = {
        ["Idle"] = {
            ["2016 Animation (mm2)"] = {"387947158", "387947464"},
            ["(UGC) Oh Really?"] = {"98004748982532", "98004748982532"},
            ["Astronaut"] = {"891621366", "891633237"},
            ["Adidas Community"] = {"122257458498464", "102357151005774"},
            ["Bold"] = {"16738333868", "16738334710"},
            ["(UGC) Slasher"] = {"140051337061095", "140051337061095"},
            ["(UGC) Classic"] = {"80479383912838", "80479383912838"},
            ["(UGC) Magician"] = {"139433213852503", "139433213852503"},
            ["(UGC) John Doe"] = {"72526127498800", "72526127498800"},
            ["(UGC) Noli"] = {"139360856809483", "139360856809483"},
            ["(UGC) Coolkid"] = {"95203125292023", "95203125292023"},
            ["(UGC) Survivor Injured"] = {"73905365652295", "73905365652295"},
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
            ["Smooth"] = "76630051272791",
            ["Cartoony"] = "742640026",
            ["Confident"] = "1070017263",
            ["Cowboy"] = "1014421541",
            ["(UGC) Classic"] = "107806791584829",
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
            ["(UGC) Classic"] = "139390570947836",
            ["Ninja"] = "656117878",
            ["NFL"] = "119846112151352",
            ["OldSchool"] = "10921242013",
            ["Patrol"] = "1148811837",
            ["Pirate"] = "750782230",
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

    for name, ids in pairs(Animations.Idle) do
        createButton(Animations.Idle, name, "Idle", ids)
    end
    for name, id in pairs(Animations.Walk) do
        createButton(Animations.Walk, name, "Walk", id)
    end
    for name, id in pairs(Animations.Run) do
        createButton(Animations.Run, name, "Run", id)
    end
    for name, id in pairs(Animations.Jump) do
        createButton(Animations.Jump, name, "Jump", id)
    end
    for name, id in pairs(Animations.Fall) do
        createButton(Animations.Fall, name, "Fall", id)
    end
    for name, id in pairs(Animations.SwimIdle) do
        createButton(Animations.SwimIdle, name, "SwimIdle", id)
    end
    for name, id in pairs(Animations.Swim) do
        createButton(Animations.Swim, name, "Swim", id)
    end
    for name, id in pairs(Animations.Climb) do
        createButton(Animations.Climb, name, "Climb", id)
    end

    Players.LocalPlayer.CharacterAdded:Connect(applySavedAnimations)

    -- Apply saved animations on script start if character exists
    if Players.LocalPlayer.Character then
        applySavedAnimations(Players.LocalPlayer.Character)
    end

    AddDonate(20, 1131371530)
    AddDonate(200, 1131065702)
    AddDonate(183, 1129915318)
    AddDonate(2000, 1128299749)
    AddEmote("Dance 1", 12521009666)
    AddEmote("Dance 2", 12521169800)
    AddEmote("Dance 3", 12521178362)
    AddEmote("Cheer", 12521021991)
    AddEmote("Laugh", 12521018724)
    AddEmote("Point", 12521007694)
    AddEmote("Wave", 12521004586)

    loadLastAnimations()

    Notify("PLEASE", "Donate if you enjoy, I'm poor :(", 1)
    local lt = os.clock() - st
    Notify("Loaded", string.format("Script loaded in %.2f seconds.", lt), 5)
    Notify("Changelog", "Added auto-save/load, fixed UI spacing, and status text overflow", 30)
end)
