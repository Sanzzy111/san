local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== KONFIGURASI ==========
local CROSSHAIR_ASSET_ID = "rbxassetid://5516824280"
local TOGGLE_KEY = Enum.KeyCode.F
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
shiftLockButton.BackgroundTransparency = 1
shiftLockButton.Image = CROSSHAIR_ASSET_ID
shiftLockButton.Draggable = true
shiftLockButton.Active = true
shiftLockButton.Parent = screenGui

-- Crosshair
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 32, 0, 32)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Image = CROSSHAIR_ASSET_ID
crosshair.Visible = false
crosshair.Parent = screenGui

local isShiftLockEnabled = false
local debounce = false

local function toggleShiftLock()
	if debounce then return end
	debounce = true

	isShiftLockEnabled = not isShiftLockEnabled

	if isShiftLockEnabled then
		-- Aktifkan shiftlock
		shiftLockButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
		crosshair.Visible = true
		
		-- ✅ FIX: Harus LockCenter supaya kamera bisa 360°
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	else
		-- Matikan shiftlock
		shiftLockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
		crosshair.Visible = false
		
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end

	task.wait(0.2)
	debounce = false
end

-- Klik button
shiftLockButton.MouseButton1Click:Connect(toggleShiftLock)

shiftLockButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		toggleShiftLock()
	end
end)

-- Keyboard Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == TOGGLE_KEY
	or input.KeyCode == Enum.KeyCode.LeftShift
	or input.KeyCode == Enum.KeyCode.RightShift then
		toggleShiftLock()
	end
end)

-- Logic karakter menghadap kamera
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

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
end)
