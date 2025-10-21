local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local mouseLocked = false
local connection = nil

-- Function untuk simulate right click held
local function enableMouseLock()
    mouseLocked = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
    
    -- Simulate right mouse button held down
    connection = RunService.RenderStepped:Connect(function()
        mouse2press()
    end)
    
    print("Mouse Lock: ON")
end

local function disableMouseLock()
    mouseLocked = false
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
    
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    mouse2release()
    
    print("Mouse Lock: OFF")
end

-- Toggle dengan tombol V
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        if mouseLocked then
            disableMouseLock()
        else
            enableMouseLock()
        end
    end
end)

print("Script loaded! Press V to toggle mouse lock")
