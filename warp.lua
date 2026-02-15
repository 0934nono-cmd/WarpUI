--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "WarpUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

--// MAIN
local Main = Instance.new("Frame", gui)
Main.Size = UDim2.fromScale(0.35, 0.45)
Main.Position = UDim2.fromScale(0.3, 0.25)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

--// TITLE
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -300, 0, 35)
Title.Position = UDim2.new(0, 12, 0, 6)
Title.Text = "วาป"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

--// MINIMIZE
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.fromOffset(32,32)
MinBtn.Position = UDim2.new(1, -22, 0, 6)
MinBtn.Text = "–"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 22
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinBtn.BorderSizePixel = 0
Instance.new("UICorner", MinBtn)

--// MODE
local MoveMode = "FOLLOW"
local ModeBtn = Instance.new("TextButton", Main)
ModeBtn.Size = UDim2.fromOffset(70,30)
ModeBtn.Position = UDim2.new(0, 70, 0, 6)
ModeBtn.Text = "FOLLOW"
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = 14
ModeBtn.TextColor3 = Color3.new(1,1,1)
ModeBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
ModeBtn.BorderSizePixel = 0
Instance.new("UICorner", ModeBtn)

--// SPEED
local TweenSpeed = 0.25
local SpeedBox = Instance.new("TextBox", Main)
SpeedBox.Size = UDim2.fromOffset(60,28)
SpeedBox.Position = UDim2.new(0, 150, 0, 7)
SpeedBox.Text = tostring(TweenSpeed)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.TextSize = 14
SpeedBox.TextColor3 = Color3.new(1,1,1)
SpeedBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
SpeedBox.BorderSizePixel = 0
SpeedBox.ClearTextOnFocus = false
Instance.new("UICorner", SpeedBox)

SpeedBox.FocusLost:Connect(function()
	local n = tonumber(SpeedBox.Text)
	if n and n >= 0.05 and n <= 5 then
		TweenSpeed = n
	else
		SpeedBox.Text = tostring(TweenSpeed)
	end
end)

--// FRONT / BACK
local WarpSide = "BACK"
local function getOffset()
	return WarpSide == "FRONT" and CFrame.new(0,0,3) or CFrame.new(0,0,-3)
end

local SideBtn = Instance.new("TextButton", Main)
SideBtn.Size = UDim2.fromOffset(70,30)
SideBtn.Position = UDim2.new(0, 220, 0, 6)
SideBtn.Text = "BACK"
SideBtn.Font = Enum.Font.GothamBold
SideBtn.TextSize = 14
SideBtn.TextColor3 = Color3.new(1,1,1)
SideBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
SideBtn.BorderSizePixel = 0
Instance.new("UICorner", SideBtn)

SideBtn.MouseButton1Click:Connect(function()
	WarpSide = WarpSide == "BACK" and "FRONT" or "BACK"
	SideBtn.Text = WarpSide
end)

--// FILTER
local FilterMode = "ALL"
local FilterBtn = Instance.new("TextButton", Main)
FilterBtn.Size = UDim2.fromOffset(70,30)
FilterBtn.Position = UDim2.new(0, 300, 0, 6)
FilterBtn.Text = "ทั้งหมด"
FilterBtn.Font = Enum.Font.GothamBold
FilterBtn.TextSize = 14
FilterBtn.TextColor3 = Color3.new(1,1,1)
FilterBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
FilterBtn.BorderSizePixel = 0
Instance.new("UICorner", FilterBtn)

--// LIST
local ListFrame = Instance.new("ScrollingFrame", Main)
ListFrame.Position = UDim2.new(0, 12, 0, 48)
ListFrame.Size = UDim2.new(1, -24, 1, -60)
ListFrame.CanvasSize = UDim2.new(0,0,0,0)
ListFrame.ScrollBarImageTransparency = 0.4
ListFrame.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", ListFrame)
UIList.Padding = UDim.new(0,6)

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ListFrame.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y + 10)
end)

--// MINI
local Mini = Instance.new("Frame", gui)
Mini.Size = UDim2.fromOffset(100,38)
Mini.Position = UDim2.fromScale(0.05,0.45)
Mini.BackgroundColor3 = Color3.fromRGB(20,20,20)
Mini.Visible = false
Mini.Active = true
Mini.Draggable = true
Mini.BorderSizePixel = 0
Instance.new("UICorner", Mini)

local Restore = Instance.new("TextButton", Mini)
Restore.Size = UDim2.fromScale(1,1)
Restore.Text = "เปิดวาป"
Restore.Font = Enum.Font.GothamBold
Restore.TextSize = 14
Restore.TextColor3 = Color3.new(1,1,1)
Restore.BackgroundTransparency = 1

--// STATE
local selectedButton
local followConn
local activeTween

local function stopAll()
	if followConn then followConn:Disconnect() followConn=nil end
	if activeTween then activeTween:Cancel() activeTween=nil end
end

local function clearList()
	for _,v in ipairs(ListFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
end

--// ADD PLAYER
local function addPlayer(plr)
	if plr == LocalPlayer then return end
	if FilterMode == "FRIENDS" and not LocalPlayer:IsFriendsWith(plr.UserId) then return end

	local Btn = Instance.new("TextButton", ListFrame)
	Btn.Size = UDim2.new(1,0,0,50)
	Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	Btn.Text = ""
	Btn.BorderSizePixel = 0
	Instance.new("UICorner", Btn)

	local Avatar = Instance.new("ImageLabel", Btn)
	Avatar.Size = UDim2.fromOffset(36,36)
	Avatar.Position = UDim2.fromOffset(6,7)
	Avatar.BackgroundTransparency = 1
	Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=150&height=150&format=png"

	local Name = Instance.new("TextLabel", Btn)
	Name.Position = UDim2.fromOffset(48,6)
	Name.Size = UDim2.new(1,-100,0,18)
	Name.Text = plr.Name
	Name.TextXAlignment = Enum.TextXAlignment.Left
	Name.Font = Enum.Font.Gotham
	Name.TextSize = 14
	Name.TextColor3 = Color3.new(1,1,1)
	Name.BackgroundTransparency = 1

	if LocalPlayer:IsFriendsWith(plr.UserId) then
		Name.Text = plr.Name.." ★"
	end

	local Dist = Instance.new("TextLabel", Btn)
	Dist.Position = UDim2.fromOffset(48,24)
	Dist.Size = UDim2.new(1,-60,0,18)
	Dist.Text = "[ ? studs ]"
	Dist.Font = Enum.Font.Gotham
	Dist.TextSize = 12
	Dist.TextColor3 = Color3.fromRGB(170,170,170)
	Dist.BackgroundTransparency = 1
	Dist.TextXAlignment = Enum.TextXAlignment.Left

	task.spawn(function()
		while Btn.Parent do
			task.wait(0.25)
			local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local b = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if a and b then
				Dist.Text = string.format("[ %d studs ]",(a.Position-b.Position).Magnitude)
			end
		end
	end)

	Btn.MouseButton1Click:Connect(function()
		if selectedButton == Btn then
			stopAll()
			Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
			selectedButton = nil
			return
		end

		stopAll()
		if selectedButton then
			selectedButton.BackgroundColor3 = Color3.fromRGB(35,35,35)
		end

		selectedButton = Btn
		Btn.BackgroundColor3 = Color3.fromRGB(70,70,70)

		if MoveMode == "FOLLOW" then
			followConn = RunService.Heartbeat:Connect(function()
				local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local b = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
				if a and b then
					a.CFrame = b.CFrame * getOffset()
				end
			end)
		else
			task.spawn(function()
				while selectedButton == Btn do
					local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local b = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					if a and b then
						activeTween = TweenService:Create(
							a,
							TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear),
							{CFrame = b.CFrame * getOffset()}
						)
						activeTween:Play()
						activeTween.Completed:Wait()
					end
					task.wait(0.05)
				end
			end)
		end
	end)
end

local function refresh()
	clearList()
	for _,p in ipairs(Players:GetPlayers()) do
		addPlayer(p)
	end
end

Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)

ModeBtn.MouseButton1Click:Connect(function()
	MoveMode = MoveMode == "FOLLOW" and "TWEEN" or "FOLLOW"
	ModeBtn.Text = MoveMode
	stopAll()
end)

FilterBtn.MouseButton1Click:Connect(function()
	FilterMode = FilterMode == "ALL" and "FRIENDS" or "ALL"
	FilterBtn.Text = FilterMode == "ALL" and "ทั้งหมด" or "เพื่อน"
	refresh()
end)

-- 🔥 แก้ตรงนี้อย่างเดียว
MinBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
	Mini.Visible = true
	-- ไม่ stopAll() เพื่อให้ยังตามต่อ
end)

Restore.MouseButton1Click:Connect(function()
	Mini.Visible = false
	Main.Visible = true
	refresh()
end)

-- INIT
refresh()
