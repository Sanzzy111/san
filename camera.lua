-- Script Toggle Kamera Bawaan Roblox untuk Delta Executor
-- Tekan R untuk beralih antara Classic dan CameraToggle

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Akses UserGameSettings
local UserGameSettings = UserSettings():GetService("UserGameSettings")

-- Variabel untuk menyimpan status kamera saat ini
local isClassicMode = true

-- Fungsi untuk mengubah mode kamera
local function toggleCameraMode()
    local success, err = pcall(function()
        if isClassicMode then
            -- Ubah ke CameraToggle
            UserGameSettings.ComputerCameraMovementMode = Enum.ComputerCameraMovementMode.CameraToggle
            
            isClassicMode = false
            print("✓ Kamera diubah ke: CameraToggle")
            print("  → Klik kanan mouse untuk mouse lock mode!")
        else
            -- Ubah ke Classic
            UserGameSettings.ComputerCameraMovementMode = Enum.ComputerCameraMovementMode.Classic
            
            isClassicMode = true
            print("✓ Kamera diubah ke: Classic")
        end
    end)
    
    if not success then
        warn("Error saat mengubah kamera:", err)
    end
end

-- Fungsi untuk mendeteksi input keyboard
local function onInputBegan(input, gameProcessed)
    -- Jangan proses jika pemain sedang mengetik di chat
    if gameProcessed then return end
    
    -- Cek apakah tombol R ditekan
    if input.KeyCode == Enum.KeyCode.R then
        toggleCameraMode()
    end
end

-- Hubungkan fungsi dengan event input
UserInputService.InputBegan:Connect(onInputBegan)

-- Set mode awal ke Classic
pcall(function()
    UserGameSettings.ComputerCameraMovementMode = Enum.ComputerCameraMovementMode.Classic
end)
