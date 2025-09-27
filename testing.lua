-- Script ini untuk executor Roblox, jalankan sebagai LocalScript
-- Membuat UI untuk input nama pengguna, copy avatar, dan show/hide UI dengan tombol 'E'

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AvatarCopyGui"
screenGui.IgnoreGuiInset = true -- Penting untuk executor agar GUI tidak tergeser oleh Roblox UI
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.Enabled = false

-- Buat Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Buat corner rounded
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

-- TextLabel untuk feedback error/sukses
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size = UDim2.new(1, -20, 0, 30)
feedbackLabel.Position = UDim2.new(0, 10, 0, 90)
feedbackLabel.Text = ""
feedbackLabel.Font = Enum.Font.SourceSans
feedbackLabel.TextSize = 16
feedbackLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.TextWrapped = true
feedbackLabel.Parent = frame

-- TextButton untuk submit
local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(1, -20, 0, 40)
submitButton.Position = UDim2.new(0, 10, 0, 130)
submitButton.Text = "Copy Avatar"
submitButton.Font = Enum.Font.SourceSansBold
submitButton.TextSize = 18
submitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.Parent = frame

-- Fungsi untuk mendapatkan UserId dari username menggunakan API resmi
local function getUserIdFromUsername(username)
    local success, result = pcall(function()
        local url = "https://users.roblox.com/v1/usernames/users"
        local requestBody = {
            usernames = {username},
            excludeBannedUsers = true
        }
        local response = HttpService:PostAsync(url, HttpService:JSONEncode(requestBody), Enum.HttpContentType.ApplicationJson)
        local data = HttpService:JSONDecode(response)
        if data.data and #data.data > 0 then
            return data.data[1].id
        end
        return nil
    end)
    if success and result then
        feedbackLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        feedbackLabel.Text = "User ditemukan, mengambil data avatar..."
        return result
    else
        feedbackLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        feedbackLabel.Text = "Error: User '" .. username .. "' tidak ditemukan atau API gagal!"
        warn("HTTP Error: " .. tostring(result))
        return nil
    end
end

-- Fungsi untuk mendapatkan HumanoidDescription dari UserId
local function getHumanoidDescription(userId)
    local success, description = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if success and description then
        feedbackLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        feedbackLabel.Text = "Data avatar berhasil diambil!"
        return description
    else
        feedbackLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        feedbackLabel.Text = "Error: Gagal mengambil data avatar!"
        warn("Description Error: " .. tostring(description))
        return nil
    end
end

-- Fungsi untuk apply avatar ke player
local function applyAvatar(description)
    local success, errorMsg = pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ApplyDescription(description)
        else
            error("Karakter atau Humanoid tidak ditemukan!")
        end
    end)
    if success then
        feedbackLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        feedbackLabel.Text = "Avatar berhasil dicopy!"
    else
        feedbackLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        feedbackLabel.Text = "Error: Gagal menerapkan avatar!"
        warn("Apply Avatar Error: " .. tostring(errorMsg))
    end
end

-- Event untuk submit button
submitButton.MouseButton1Click:Connect(function()
    local username = textBox.Text:match("^%s*(.-)%s*$")  -- Trim whitespace
    feedbackLabel.Text = ""  -- Clear feedback
    if username == "" then
        feedbackLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        feedbackLabel.Text = "Error: Masukkan nama pengguna!"
        return
    end
    feedbackLabel.Text = "Mencari user '" .. username .. "'..."
    local userId = getUserIdFromUsername(username)
    if userId then
        local description = getHumanoidDescription(userId)
        if description then
            applyAvatar(description)
            textBox.Text = ""  -- Clear input
            wait(2)  -- Tunggu sebentar agar user melihat feedback
            screenGui.Enabled = false  -- Hide UI setelah sukses
        end
    end
end)

-- Toggle show/hide UI dengan key 'E'
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        screenGui.Enabled = not screenGui.Enabled
        feedbackLabel.Text = ""  -- Clear feedback saat toggle
    end
end)

-- Debug info untuk executor
print("Avatar Copy Script Loaded")
print("Tekan 'E' untuk show/hide UI")
print("Pastikan executor mendukung HttpService dan GUI rendering")