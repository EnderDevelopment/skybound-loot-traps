local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("GameAbilities")
local camera = workspace.CurrentCamera
local flyEnabled = false
local flyConnection
local trapReady = true
local TRAP_COOLDOWN = 8

local function sendFlightVector()
	if not flyEnabled then return end
	local direction = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end
	remote:FireServer("FlightVector", direction)
end

local function toggleFly()
	remote:FireServer("Fly", true)
end

local function placeTrap()
	if not trapReady then return end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local target = root.Position + root.CFrame.LookVector * 8
	remote:FireServer("Trap", target)
	trapReady = false
	task.delay(TRAP_COOLDOWN, function() trapReady = true end)
end

local function lootNearby()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _, object in CollectionService:GetTagged("Lootable") do
		local part = object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
		if part and (part.Position - root.Position).Magnitude <= 12 then
			remote:FireServer("Loot", object)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then
		toggleFly()
	elseif input.KeyCode == Enum.KeyCode.T then
		placeTrap()
	elseif input.KeyCode == Enum.KeyCode.E then
		lootNearby()
	end
end)

remote.OnClientEvent:Connect(function(action, enabled)
	if action ~= "FlyState" then return end
	flyEnabled = enabled
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if enabled then
		flyConnection = RunService.RenderStepped:Connect(sendFlightVector)
	end
end)
