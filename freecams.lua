------------------------------------------------------------------------
-- Freecam Executor Version (PC & Mobile Support)
-- PC: Tekan LeftShift + P untuk toggle
-- Mobile: Tekan icon untuk toggle
------------------------------------------------------------------------

local pi = math.pi
local abs = math.abs
local clamp = math.clamp
local exp = math.exp
local rad = math.rad
local sign = math.sign
local sqrt = math.sqrt
local tan = math.tan

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

------------------------------------------------------------------------

local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
local FREECAM_MACRO_KB = {Enum.KeyCode.LeftShift, Enum.KeyCode.P}

local NAV_GAIN = Vector3.new(1, 1, 1) * 64
local PAN_GAIN = Vector2.new(0.75, 1) * 8
local FOV_GAIN = 300

local PITCH_LIMIT = rad(90)

local VEL_STIFFNESS = 1.5
local PAN_STIFFNESS = 1.0
local FOV_STIFFNESS = 4.0

------------------------------------------------------------------------
-- GUI Creation for Mobile
------------------------------------------------------------------------

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FreecamMobileGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ScreenInsets = Enum.ScreenInsets.None
    
    -- Toggle Button (Icon)
    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 60, 0, 60)
    ToggleButton.Position = UDim2.new(0, 10, 0.5, -30)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Image = "rbxassetid://3926305904" -- Camera icon
    ToggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.ScaleType = Enum.ScaleType.Fit
    ToggleButton.Parent = ScreenGui
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleButton
    
    -- Controls Container
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Name = "ControlsFrame"
    ControlsFrame.Size = UDim2.new(1, 0, 1, 0)
    ControlsFrame.Position = UDim2.new(0, 0, 0, 0)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.Visible = false
    ControlsFrame.Parent = ScreenGui
    
    -- Movement Controls (Left Bottom)
    local MovementFrame = Instance.new("Frame")
    MovementFrame.Name = "Movement"
    MovementFrame.Size = UDim2.new(0, 180, 0, 180)
    MovementFrame.Position = UDim2.new(0, 20, 1, -200)
    MovementFrame.AnchorPoint = Vector2.new(0, 1)
    MovementFrame.BackgroundTransparency = 1
    MovementFrame.Parent = ControlsFrame
    
    local function createArrowButton(name, position, rotation, text)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 50, 0, 50)
        btn.Position = position
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 24
        btn.Font = Enum.Font.GothamBold
        btn.Rotation = rotation
        btn.Parent = MovementFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        return btn
    end
    
    local Forward = createArrowButton("Forward", UDim2.new(0.5, -25, 0, 0), 0, "▲")
    local Back = createArrowButton("Back", UDim2.new(0.5, -25, 1, -50), 0, "▼")
    local Left = createArrowButton("Left", UDim2.new(0, 0, 0.5, -25), 0, "◀")
    local Right = createArrowButton("Right", UDim2.new(1, -50, 0.5, -25), 0, "▶")
    
    -- Up/Down buttons (middle)
    local Up = Instance.new("TextButton")
    Up.Name = "Up"
    Up.Size = UDim2.new(0, 50, 0, 50)
    Up.Position = UDim2.new(0.5, -25, 0.35, 0)
    Up.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Up.BorderSizePixel = 0
    Up.Text = "↑"
    Up.TextColor3 = Color3.fromRGB(255, 255, 255)
    Up.TextSize = 32
    Up.Font = Enum.Font.GothamBold
    Up.Parent = MovementFrame
    
    local UpCorner = Instance.new("UICorner")
    UpCorner.CornerRadius = UDim.new(0, 8)
    UpCorner.Parent = Up
    
    local Down = Instance.new("TextButton")
    Down.Name = "Down"
    Down.Size = UDim2.new(0, 50, 0, 50)
    Down.Position = UDim2.new(0.5, -25, 0.65, 0)
    Down.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Down.BorderSizePixel = 0
    Down.Text = "↓"
    Down.TextColor3 = Color3.fromRGB(255, 255, 255)
    Down.TextSize = 32
    Down.Font = Enum.Font.GothamBold
    Down.Parent = MovementFrame
    
    local DownCorner = Instance.new("UICorner")
    DownCorner.CornerRadius = UDim.new(0, 8)
    DownCorner.Parent = Down
    
    -- Zoom Controls (Right Bottom)
    local ZoomFrame = Instance.new("Frame")
    ZoomFrame.Name = "Zoom"
    ZoomFrame.Size = UDim2.new(0, 60, 0, 130)
    ZoomFrame.Position = UDim2.new(1, -80, 1, -150)
    ZoomFrame.AnchorPoint = Vector2.new(0, 1)
    ZoomFrame.BackgroundTransparency = 1
    ZoomFrame.Parent = ControlsFrame
    
    local ZoomIn = Instance.new("TextButton")
    ZoomIn.Name = "ZoomIn"
    ZoomIn.Size = UDim2.new(0, 60, 0, 60)
    ZoomIn.Position = UDim2.new(0, 0, 0, 0)
    ZoomIn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ZoomIn.BorderSizePixel = 0
    ZoomIn.Text = "+"
    ZoomIn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ZoomIn.TextSize = 36
    ZoomIn.Font = Enum.Font.GothamBold
    ZoomIn.Parent = ZoomFrame
    
    local ZoomInCorner = Instance.new("UICorner")
    ZoomInCorner.CornerRadius = UDim.new(0, 12)
    ZoomInCorner.Parent = ZoomIn
    
    local ZoomOut = Instance.new("TextButton")
    ZoomOut.Name = "ZoomOut"
    ZoomOut.Size = UDim2.new(0, 60, 0, 60)
    ZoomOut.Position = UDim2.new(0, 0, 1, -60)
    ZoomOut.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ZoomOut.BorderSizePixel = 0
    ZoomOut.Text = "−"
    ZoomOut.TextColor3 = Color3.fromRGB(255, 255, 255)
    ZoomOut.TextSize = 36
    ZoomOut.Font = Enum.Font.GothamBold
    ZoomOut.Parent = ZoomFrame
    
    local ZoomOutCorner = Instance.new("UICorner")
    ZoomOutCorner.CornerRadius = UDim.new(0, 12)
    ZoomOutCorner.Parent = ZoomOut
    
    -- Hide Controls Button
    local HideButton = Instance.new("TextButton")
    HideButton.Name = "HideButton"
    HideButton.Size = UDim2.new(0, 100, 0, 35)
    HideButton.Position = UDim2.new(0.5, -50, 0, 10)
    HideButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    HideButton.BorderSizePixel = 0
    HideButton.Text = "Hide Controls"
    HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HideButton.TextSize = 14
    HideButton.Font = Enum.Font.Gotham
    HideButton.Parent = ControlsFrame
    
    local HideCorner = Instance.new("UICorner")
    HideCorner.CornerRadius = UDim.new(0, 8)
    HideCorner.Parent = HideButton
    
    ScreenGui.Parent = game:GetService("CoreGui")
    
    return ScreenGui, ToggleButton, ControlsFrame, {
        Forward = Forward,
        Back = Back,
        Left = Left,
        Right = Right,
        Up = Up,
        Down = Down,
        ZoomIn = ZoomIn,
        ZoomOut = ZoomOut,
        HideButton = HideButton
    }
end

------------------------------------------------------------------------

local Spring = {}
Spring.__index = Spring

function Spring.new(freq, pos)
    local self = setmetatable({}, Spring)
    self.f = freq
    self.p = pos
    self.v = pos * 0
    return self
end

function Spring:Update(dt, goal)
    local f = self.f * 2 * pi
    local p0 = self.p
    local v0 = self.v

    local offset = goal - p0
    local decay = exp(-f * dt)

    local p1 = goal + (v0 * dt - offset * (f * dt + 1)) * decay
    local v1 = (f * dt * (offset * f - v0) + v0) * decay

    self.p = p1
    self.v = v1

    return p1
end

function Spring:Reset(pos)
    self.p = pos
    self.v = pos * 0
end

------------------------------------------------------------------------

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 0

local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
local fovSpring = Spring.new(FOV_STIFFNESS, 0)

------------------------------------------------------------------------

local Input = {}

local function thumbstickCurve(x)
    local K_CURVATURE = 2.0
    local K_DEADZONE = 0.15
    
    local function fCurve(x)
        return (exp(K_CURVATURE * x) - 1) / (exp(K_CURVATURE) - 1)
    end
    
    local function fDeadzone(x)
        return fCurve((x - K_DEADZONE) / (1 - K_DEADZONE))
    end
    
    return sign(x) * clamp(fDeadzone(abs(x)), 0, 1)
end

local gamepad = {
    ButtonX = 0,
    ButtonY = 0,
    DPadDown = 0,
    DPadUp = 0,
    ButtonL2 = 0,
    ButtonR2 = 0,
    Thumbstick1 = Vector2.new(),
    Thumbstick2 = Vector2.new(),
}

local keyboard = {
    W = 0, A = 0, S = 0, D = 0,
    E = 0, Q = 0, U = 0, H = 0,
    J = 0, K = 0, I = 0, Y = 0,
    Up = 0, Down = 0,
    LeftShift = 0, RightShift = 0,
}

local mouse = {
    Delta = Vector2.new(),
    MouseWheel = 0,
}

local NAV_GAMEPAD_SPEED = Vector3.new(1, 1, 1)
local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
local PAN_MOUSE_SPEED = Vector2.new(1, 1) * (pi / 64)
local PAN_GAMEPAD_SPEED = Vector2.new(1, 1) * (pi / 8)
local FOV_WHEEL_SPEED = 1.0
local FOV_GAMEPAD_SPEED = 0.25
local NAV_ADJ_SPEED = 0.75
local NAV_SHIFT_MUL = 0.25

local navSpeed = 1

function Input.Vel(dt)
    navSpeed = clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4)

    local kGamepad = Vector3.new(
        thumbstickCurve(gamepad.Thumbstick1.X),
        thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
        thumbstickCurve(-gamepad.Thumbstick1.Y)
    ) * NAV_GAMEPAD_SPEED

    local kKeyboard = Vector3.new(
        keyboard.D - keyboard.A + keyboard.K - keyboard.H,
        keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
        keyboard.S - keyboard.W + keyboard.J - keyboard.U
    ) * NAV_KEYBOARD_SPEED

    local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

    return (kGamepad + kKeyboard) * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
end

function Input.Pan(dt)
    -- Mobile touch controls for camera pan
    if isMobile and UserInputService.TouchEnabled then
        local touchDelta = UserInputService:GetMouseDelta()
        mouse.Delta = Vector2.new(-touchDelta.Y, -touchDelta.X) * 0.5
    end
    
    local kGamepad = Vector2.new(
        thumbstickCurve(gamepad.Thumbstick2.Y),
        thumbstickCurve(-gamepad.Thumbstick2.X)
    ) * PAN_GAMEPAD_SPEED
    
    local kMouse = mouse.Delta * PAN_MOUSE_SPEED
    mouse.Delta = Vector2.new()
    return kGamepad + kMouse
end

function Input.Fov(dt)
    local kGamepad = (gamepad.ButtonX - gamepad.ButtonY) * FOV_GAMEPAD_SPEED
    local kMouse = mouse.MouseWheel * FOV_WHEEL_SPEED
    mouse.MouseWheel = 0
    return kGamepad + kMouse
end

do
    local function Keypress(action, state, input)
        keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
        return Enum.ContextActionResult.Sink
    end

    local function GpButton(action, state, input)
        gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
        return Enum.ContextActionResult.Sink
    end

    local function MousePan(action, state, input)
        local delta = input.Delta
        mouse.Delta = Vector2.new(-delta.y, -delta.x)
        return Enum.ContextActionResult.Sink
    end

    local function Thumb(action, state, input)
        gamepad[input.KeyCode.Name] = input.Position
        return Enum.ContextActionResult.Sink
    end

    local function Trigger(action, state, input)
        gamepad[input.KeyCode.Name] = input.Position.z
        return Enum.ContextActionResult.Sink
    end

    local function MouseWheel(action, state, input)
        mouse[input.UserInputType.Name] = -input.Position.z
        return Enum.ContextActionResult.Sink
    end

    local function Zero(t)
        for k, v in pairs(t) do
            t[k] = v * 0
        end
    end

    function Input.StartCapture()
        ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
            Enum.KeyCode.W, Enum.KeyCode.U,
            Enum.KeyCode.A, Enum.KeyCode.H,
            Enum.KeyCode.S, Enum.KeyCode.J,
            Enum.KeyCode.D, Enum.KeyCode.K,
            Enum.KeyCode.E, Enum.KeyCode.I,
            Enum.KeyCode.Q, Enum.KeyCode.Y,
            Enum.KeyCode.Up, Enum.KeyCode.Down
        )
        ContextActionService:BindActionAtPriority("FreecamMousePan", MousePan, false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
        ContextActionService:BindActionAtPriority("FreecamMouseWheel", MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
        ContextActionService:BindActionAtPriority("FreecamGamepadButton", GpButton, false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
        ContextActionService:BindActionAtPriority("FreecamGamepadTrigger", Trigger, false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
        ContextActionService:BindActionAtPriority("FreecamGamepadThumbstick", Thumb, false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
    end

    function Input.StopCapture()
        navSpeed = 1
        Zero(gamepad)
        Zero(keyboard)
        Zero(mouse)
        ContextActionService:UnbindAction("FreecamKeyboard")
        ContextActionService:UnbindAction("FreecamMousePan")
        ContextActionService:UnbindAction("FreecamMouseWheel")
        ContextActionService:UnbindAction("FreecamGamepadButton")
        ContextActionService:UnbindAction("FreecamGamepadTrigger")
        ContextActionService:UnbindAction("FreecamGamepadThumbstick")
    end
end

------------------------------------------------------------------------

local function GetFocusDistance(cameraFrame)
    local znear = 0.1
    local viewport = Camera.ViewportSize
    local projy = 2 * tan(cameraFov / 2)
    local projx = viewport.x / viewport.y * projy
    local fx = cameraFrame.rightVector
    local fy = cameraFrame.upVector
    local fz = cameraFrame.lookVector

    local minVect = Vector3.new()
    local minDist = 512

    for x = 0, 1, 0.5 do
        for y = 0, 1, 0.5 do
            local cx = (x - 0.5) * projx
            local cy = (y - 0.5) * projy
            local offset = fx * cx - fy * cy + fz
            local origin = cameraFrame.p + offset * znear
            local _, hit = Workspace:FindPartOnRay(Ray.new(origin, offset.unit * minDist))
            local dist = (hit - origin).magnitude
            if minDist > dist then
                minDist = dist
                minVect = offset.unit
            end
        end
    end

    return fz:Dot(minVect) * minDist
end

------------------------------------------------------------------------

local function StepFreecam(dt)
    local vel = velSpring:Update(dt, Input.Vel(dt))
    local pan = panSpring:Update(dt, Input.Pan(dt))
    local fov = fovSpring:Update(dt, Input.Fov(dt))

    local zoomFactor = sqrt(tan(rad(70 / 2)) / tan(rad(cameraFov / 2)))

    cameraFov = clamp(cameraFov + fov * FOV_GAIN * (dt / zoomFactor), 1, 120)
    cameraRot = cameraRot + pan * PAN_GAIN * (dt / zoomFactor)
    cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y % (2 * pi))

    local cameraCFrame = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0) * CFrame.new(vel * NAV_GAIN * dt)
    cameraPos = cameraCFrame.p

    Camera.CFrame = cameraCFrame
    Camera.Focus = cameraCFrame * CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
    Camera.FieldOfView = cameraFov
end

------------------------------------------------------------------------

local PlayerState = {}
local savedState = {}

function PlayerState.Push()
    savedState.cameraFieldOfView = Camera.FieldOfView
    savedState.cameraType = Camera.CameraType
    savedState.cameraCFrame = Camera.CFrame
    savedState.cameraFocus = Camera.Focus
    savedState.mouseIconEnabled = UserInputService.MouseIconEnabled
    savedState.mouseBehavior = UserInputService.MouseBehavior

    Camera.FieldOfView = 70
    Camera.CameraType = Enum.CameraType.Custom
    
    if not isMobile then
        UserInputService.MouseIconEnabled = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UserInputService.MouseIconEnabled = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

function PlayerState.Pop()
    Camera.FieldOfView = savedState.cameraFieldOfView
    Camera.CameraType = savedState.cameraType
    Camera.CFrame = savedState.cameraCFrame
    Camera.Focus = savedState.cameraFocus
    UserInputService.MouseIconEnabled = savedState.mouseIconEnabled
    UserInputService.MouseBehavior = savedState.mouseBehavior
end

------------------------------------------------------------------------

local function StartFreecam()
    local cameraCFrame = Camera.CFrame
    cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
    cameraPos = cameraCFrame.p
    cameraFov = Camera.FieldOfView

    velSpring:Reset(Vector3.new())
    panSpring:Reset(Vector2.new())
    fovSpring:Reset(0)

    PlayerState.Push()
    RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
    Input.StartCapture()
end

local function StopFreecam()
    Input.StopCapture()
    RunService:UnbindFromRenderStep("Freecam")
    PlayerState.Pop()
end

------------------------------------------------------------------------

local enabled = false
local gui, toggleButton, controlsFrame, buttons

if isMobile then
    gui, toggleButton, controlsFrame, buttons = createGUI()
    
    -- Toggle button animation
    local function animateToggle(isEnabled)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if isEnabled then
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
            TweenService:Create(toggleButton, tweenInfo, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            TweenService:Create(toggleButton, tweenInfo, {ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end
    
    -- Mobile button handlers
    local function setupMobileButton(button, keyName)
        button.MouseButton1Down:Connect(function()
            keyboard[keyName] = 1
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
        end)
        
        button.MouseButton1Up:Connect(function()
            keyboard[keyName] = 0
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end)
        
        button.MouseLeave:Connect(function()
            keyboard[keyName] = 0
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end)
    end
    
    setupMobileButton(buttons.Forward, "W")
    setupMobileButton(buttons.Back, "S")
    setupMobileButton(buttons.Left, "A")
    setupMobileButton(buttons.Right, "D")
    setupMobileButton(buttons.Up, "E")
    setupMobileButton(buttons.Down, "Q")
    
    -- Zoom buttons
    local zoomingIn = false
    local zoomingOut = false
    
    buttons.ZoomIn.MouseButton1Down:Connect(function()
        zoomingIn = true
        buttons.ZoomIn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
        spawn(function()
            while zoomingIn do
                mouse.MouseWheel = mouse.MouseWheel - 0.5
                wait()
            end
        end)
    end)
    
    buttons.ZoomIn.MouseButton1Up:Connect(function()
        zoomingIn = false
        buttons.ZoomIn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    
    buttons.ZoomIn.MouseLeave:Connect(function()
        zoomingIn = false
        buttons.ZoomIn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    
    buttons.ZoomOut.MouseButton1Down:Connect(function()
        zoomingOut = true
        buttons.ZoomOut.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
        spawn(function()
            while zoomingOut do
                mouse.MouseWheel = mouse.MouseWheel + 0.5
                wait()
            end
        end)
    end)
    
    buttons.ZoomOut.MouseButton1Up:Connect(function()
        zoomingOut = false
        buttons.ZoomOut.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    
    buttons.ZoomOut.MouseLeave:Connect(function()
        zoomingOut = false
        buttons.ZoomOut.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    
    -- Hide controls button
    local controlsVisible = true
    buttons.HideButton.MouseButton1Click:Connect(function()
        controlsVisible = not controlsVisible
        
        if controlsVisible then
            buttons.HideButton.Text = "Hide Controls"
            controlsFrame:FindFirstChild("Movement").Visible = true
            controlsFrame:FindFirstChild("Zoom").Visible = true
        else
            buttons.HideButton.Text = "Show Controls"
            controlsFrame:FindFirstChild("Movement").Visible = false
            controlsFrame:FindFirstChild("Zoom").Visible = false
        end
    end)
    
    -- Hide GUI when taking screenshot
    game:GetService("GuiService").MenuOpened:Connect(function()
        if gui then
            gui.Enabled = false
        end
    end)
    
    game:GetService("GuiService").MenuClosed:Connect(function()
        if gui then
            gui.Enabled = true
        end
    end)
    
    -- Toggle freecam
    toggleButton.MouseButton1Click:Connect(function()
        if enabled then
            StopFreecam()
            controlsFrame.Visible = false
            animateToggle(false)
        else
            StartFreecam()
            controlsFrame.Visible = true
            animateToggle(true)
        end
        enabled = not enabled
    end)
end

-- PC Controls
local function ToggleFreecam()
    if enabled then
        StopFreecam()
        if isMobile and controlsFrame then
            controlsFrame.Visible = false
        end
    else
        StartFreecam()
        if isMobile and controlsFrame then
            controlsFrame.Visible = true
        end
    end
    enabled = not enabled
end

local function CheckMacro(macro)
    for i = 1, #macro - 1 do
        if not UserInputService:IsKeyDown(macro[i]) then
            return
        end
    end
    ToggleFreecam()
end

local function HandleActivationInput(action, state, input)
    if state == Enum.UserInputState.Begin then
        if input.KeyCode == FREECAM_MACRO_KB[#FREECAM_MACRO_KB] then
            CheckMacro(FREECAM_MACRO_KB)
        end
    end
    return Enum.ContextActionResult.Pass
end

-- Bind keyboard controls for PC
if not isMobile then
    ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, TOGGLE_INPUT_PRIORITY, FREECAM_MACRO_KB[#FREECAM_MACRO_KB])
end
