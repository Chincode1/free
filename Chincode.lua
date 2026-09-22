local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- สร้าง ScreenGui สำหรับตกแต่งธีมสีน้ำเงินและโลโก้
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChinCodeUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- กรอบหลัก (Main Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 160)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- สีน้ำเงินเข้มเกือบดำ (Modern Dark Blue)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(0, 102, 255) -- ขอบเรืองแสงสีน้ำเงิน
uiStroke.Thickness = 2
uiStroke.Parent = mainFrame

-- โลโก้จำลองข้อความ/แบรนด์ "chin code" ตามรูปภาพ
local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(1, 0, 0, 40)
logoLabel.Position = UDim2.new(0, 0, 0, 10)
logoLabel.BackgroundTransparency = 1
logoLabel.Font = Enum.Font.GothamBold
logoLabel.Text = "C chin code"
logoLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
logoLabel.TextSize = 20
logoLabel.Parent = mainFrame

-- ปุ่มกดบิน (Fly Button)
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 180, 0, 40)
flyButton.Position = UDim2.new(0.5, -90, 0, 60)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
flyButton.Font = Enum.Font.GothamBold
flyButton.Text = "FLY: OFF (Press F)"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 14
flyButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = flyButton

-- ข้อความบอกสถานะวิ่งเร็ว
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 30)
speedLabel.Position = UDim2.new(0, 0, 0, 115)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.Text = "Hold [Shift] to Run Fast"
speedLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
speedLabel.TextSize = 12
speedLabel.Parent = mainFrame

------------------------------------------------------------------
-- ระบบการทำงานของตัวละคร (วิ่งเร็ว & บิน)
------------------------------------------------------------------
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local normalSpeed = 16
local fastSpeed = 60
local flying = false
local flySpeed = 50
local bodyVelocity, bodyGyro
local ctrl = {f = 0, b = 0, l = 0, r = 0}

local function startFly()
	if flying then return end
	flying = true
	humanoid.PlatformStand = true
	flyButton.Text = "FLY: ON (Press F)"
	flyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100) -- เปลี่ยนเป็นสีเขียวเมื่อเปิด

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Parent = rootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
	bodyGyro.CFrame = rootPart.CFrame
	bodyGyro.Parent = rootPart
end

local function stopFly()
	if not flying then return end
	flying = false
	humanoid.PlatformStand = false
	flyButton.Text = "FLY: OFF (Press F)"
	flyButton.BackgroundColor3 = Color3.fromRGB(0, 80, 200) -- กลับเป็นสีน้ำเงิน

	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end
	ctrl = {f = 0, b = 0, l = 0, r = 0}
end

RunService.RenderStepped:Connect(function()
	if flying and character and rootPart then
		local camera = workspace.CurrentCamera
		local direction = Vector3.new()
		if ctrl.f == 1 then direction = direction + camera.CFrame.LookVector end
		if ctrl.b == 1 then direction = direction - camera.CFrame.LookVector end
		if ctrl.l == 1 then direction = direction - camera.CFrame.RightVector end
		if ctrl.r == 1 then direction = direction + camera.CFrame.RightVector end
		
		bodyVelocity.Velocity = direction * flySpeed
		bodyGyro.CFrame = camera.CFrame
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		humanoid.WalkSpeed = fastSpeed
	end

	if input.KeyCode == Enum.KeyCode.F then
		if flying then stopFly() else startFly() end
	end

	if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1 end
	if input.KeyCode == Enum.KeyCode.S then ctrl.b = 1 end
	if input.KeyCode == Enum.KeyCode.A then ctrl.l = 1 end
	if input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		humanoid.WalkSpeed = normalSpeed
	end

	if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0 end
	if input.KeyCode == Enum.KeyCode.S then ctrl.b = 0 end
	if input.KeyCode == Enum.KeyCode.A then ctrl.l = 0 end
	if input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
end)

-- กดที่ปุ่มบนจอเพื่อเปิด-ปิดบินได้ด้วย
flyButton.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	stopFly()
end)
