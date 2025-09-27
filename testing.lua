-- Script ini untuk Roblox, jalankan di LocalScript (misalnya di StarterPlayerScripts)
-- Ini akan membuat UI sederhana untuk input nama pengguna, lalu copy avatarnya ke player kamu
-- UI bisa di-show/hide dengan menekan tombol 'E' (atau sesuaikan)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Buat ScreenGui jika belum ada
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AvatarCopyGui"
screenGui.Parent = playerGui
screenGui.Enabled = false  -- Mulai hidden

-- Buat Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Buat corner rounded (opsional, butuh UICorner)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

-- TextLabel judul
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "Copy Avatar"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Parent = frame

-- TextBox untuk input nama
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 40)
textBox.Position = UDim2.new(0, 10, 0, 40)
textBox.PlaceholderText = "Masukkan nama pengguna Roblox"
textBox.Font = Enum.Font.SourceSans
textBox.TextSize = 18
textBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
textBox.Parent = frame

-- TextButton untuk submit
local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(1, -20, 0, 40)
submitButton.Position = UDim2.new(0, 10, 0, 90)
submitButton.Text = "Copy Avatar"
submitButton.Font = Enum.Font.SourceSansBold
submitButton.TextSize = 18
submitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.Parent = frame

-- Fungsi untuk mendapatkan UserId dari username
local function getUserIdFromUsername(username)
    local success, result = pcall(function()
        local url = "https://api.roblox.com/users/get-by-username?username=" .. username
        local response = HttpService:GetAsync(url)
        local data = HttpService:JSONDecode(response)
        return data.Id
    end)
    if success and result then
        return result
    else
        warn("User tidak ditemukan atau error: " .. username)
        return nil
    end
end

-- Fungsi untuk mendapatkan HumanoidDescription dari UserId
local function getHumanoidDescription(userId)
    return Players:GetHumanoidDescriptionFromUserId(userId)
end

-- Fungsi untuk apply avatar ke player
local function applyAvatar(description)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ApplyDescription(description)
    end
end

-- Event untuk submit button
submitButton.MouseButton1Click:Connect(function()
    local username = textBox.Text:match("^%s*(.-)%s*$")  -- Trim whitespace
    if username ~= "" then
        local userId = getUserIdFromUsername(username)
        if userId then
            local description = getHumanoidDescription(userId)
            applyAvatar(description)
            print("Avatar berhasil dicopy dari " .. username)
            textBox.Text = ""  -- Clear input
            screenGui.Enabled = false  -- Hide UI setelah submit
        end
    end
end)

-- Toggle show/hide UI dengan key 'E'
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Catatan: Pastikan HttpService di-enable di game settings.
-- Ini hanya copy appearance, bukan takeover akun. Hanya visual di client-side.
-- UI muncul di tengah layar, bisa di-toggle dengan 'E'.
-- Sesuaikan desain jika perlu.