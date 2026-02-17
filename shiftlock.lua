local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShiftLockUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local shiftLockButton = Instance.new("ImageButton")
shiftLockButton.Name = "ShiftLockButton"
shiftLockButton.Size = UDim2.new(0, 60, 0, 60)
shiftLockButton.Position = UDim2.new(1, -70, 1, -70)
shiftLockButton.AnchorPoint = Vector2.new(0, 0)
shiftLockButton.BackgroundTransparency = 1
shiftLockButton.Image = "rbxassetid://105987953182009"
shiftLockButton.Draggable = true
shiftLockButton.Active = true
shiftLockButton.Parent = screenGui

-- Label indikator tombol G
local keyLabel = Instance.new("TextLabel")
keyLabel.Name = "KeyHint"
keyLabel.Size = UDim2.new(0, 60, 0, 16)
keyLabel.Position = UDim2.new(0, 0, 1, 2)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "[G] Toggle"
keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
keyLabel.TextSize = 10
keyLabel.Font = Enum.Font.GothamBold
keyLabel.Parent = shiftLockButton

local isShiftLockEnabled = false

local function toggleShiftLock(forceState)
    if forceState ~= nil then
        isShiftLockEnabled = forceState
    else
        isShiftLockEnabled = not isShiftLockEnabled
    end

    if isShiftLockEnabled then
        shiftLockButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
        keyLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
    else
        shiftLockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
        keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

local lastTapTime = 0
local tapCount = 0
local tapConnection = nil

local function handleDoubleTap()
    if shiftLockButton.Size == UDim2.new(0, 60, 0, 60) then
        shiftLockButton.Size = UDim2.new(0, 60, 0, 60)
    else
        shiftLockButton.Size = UDim2.new(0, 60, 0, 60)
    end
end

local function handleTripleTap()
    shiftLockButton.Visible = false
    isShiftLockEnabled = false
    shiftLockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
end

local function processTap()
    local currentTime = tick()
    if currentTime - lastTapTime > 0.5 then
        tapCount = 1
    else
        tapCount += 1
    end
    lastTapTime = currentTime

    if tapConnection then
        tapConnection:Disconnect()
        tapConnection = nil
    end

    tapConnection = RunService.Heartbeat:Connect(function()
        if tick() - lastTapTime >= 0.3 then
            tapConnection:Disconnect()
            tapConnection = nil

            if tapCount == 1 then
                toggleShiftLock()
            elseif tapCount == 2 then
                handleDoubleTap()
            elseif tapCount >= 3 then
                handleTripleTap()
            end
            tapCount = 0
        end
    end)
end

-- Tap on mobile button
shiftLockButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch 
        and input.UserInputState == Enum.UserInputState.Begin then
        processTap()
    end
end)

-- Keyboard input: Shift key & G key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Toggle dengan Shift (behaviour lama tetap ada)
    if input.KeyCode == Enum.KeyCode.LeftShift 
        or input.KeyCode == Enum.KeyCode.RightShift then
        processTap()
    end

    -- Toggle dengan tombol G
    if input.KeyCode == Enum.KeyCode.G then
        -- Jika button tersembunyi, tampilkan dulu lalu toggle
        if not shiftLockButton.Visible then
            shiftLockButton.Visible = true
        end
        toggleShiftLock()
    end
end)

RunService.Heartbeat:Connect(function()
    if isShiftLockEnabled and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if hrp and cam then
            local look = cam.CFrame.LookVector
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z).Unit)
        end
    end
end)

player.CharacterAdded:Connect(function()
    isShiftLockEnabled = false
    if screenGui then
        screenGui:Destroy()
    end
end)
