local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== KONFIGURASI ==========
local CROSSHAIR_ASSET_ID = "rbxassetid://7831350554" -- Ganti ID crosshair
local TOGGLE_KEY = Enum.KeyCode.F -- Key toggle (F)
-- =================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShiftLockUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Tombol Shiftlock
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

-- Crosshair
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 64, 0, 64)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Image = CROSSHAIR_ASSET_ID
crosshair.ImageColor3 = Color3.fromRGB(255, 255, 255)
crosshair.Visible = false
crosshair.Parent = screenGui

local isShiftLockEnabled = false

local function toggleShiftLock()
    isShiftLockEnabled = not isShiftLockEnabled
    
    if isShiftLockEnabled then
        shiftLockButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
        crosshair.Visible = true
    else
        shiftLockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
        crosshair.Visible = false
    end
end

-- Klik button
shiftLockButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch 
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if input.UserInputState == Enum.UserInputState.Begin then
            toggleShiftLock()
        end
    end
end)

-- Keyboard (F atau Shift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == TOGGLE_KEY 
        or input.KeyCode == Enum.KeyCode.LeftShift 
        or input.KeyCode == Enum.KeyCode.RightShift then
        toggleShiftLock()
    end
end)

-- Custom shiftlock logic
RunService.RenderStepped:Connect(function()
    if isShiftLockEnabled and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        
        if hrp and cam then
            local look = cam.CFrame.LookVector
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z))
        end
    end
end)

-- Reset saat respawn
player.CharacterAdded:Connect(function()
    isShiftLockEnabled = false
    shiftLockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    crosshair.Visible = false
end)