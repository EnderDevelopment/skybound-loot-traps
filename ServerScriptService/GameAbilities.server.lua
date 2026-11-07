local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local remote = ReplicatedStorage:FindFirstChild("GameAbilities")
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "GameAbilities"
	remote.Parent = ReplicatedStorage
end

local TRAP_COOLDOWN = 8
local TRAP_RANGE = 45
local TRAP_DAMAGE = 35
local TRAP_RADIUS = 12
local FLIGHT_SPEED = 55
local SHIPMENT_INTERVAL = 180
local LOOT_REWARD = 25

local lastTrapAt = {}
local flying = {}

local function getRoot(player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function setFly(player, enabled)
	local root = getRoot(player)
	if not root then return end
	if enabled then
		local attachment = Instance.new("Attachment")
		attachment.Name = "AbilityFlightAttachment"
		attachment.Parent = root
		local velocity = Instance.new("LinearVelocity")
		velocity.Name = "AbilityFlightVelocity"
		velocity.Attachment0 = attachment
		velocity.RelativeTo = Enum.ActuatorRelativeTo.World
		velocity.MaxForce = 100000
		velocity.VectorVelocity = Vector3.zero
		velocity.Parent = root
		flying[player] = {attachment = attachment, velocity = velocity}
		remote:FireClient(player, "FlyState", true)
	else
		local state = flying[player]
		if state then
			state.velocity:Destroy()
			state.attachment:Destroy()
		end
		flying[player] = nil
		remote:FireClient(player, "FlyState", false)
	end
end

remote.OnServerEvent:Connect(function(player, action, value)
	if action == "Fly" then
		setFly(player, value == true and flying[player] == nil)
	elseif action == "FlightVector" then
		local state = flying[player]
		if state and typeof(value) == "Vector3" then
			local direction = value.Magnitude > 1 and value.Unit or value
			state.velocity.VectorVelocity = direction * FLIGHT_SPEED
		end
	elseif action == "Trap" then
		if typeof(value) ~= "Vector3" then return end
		local root = getRoot(player)
		if not root or (value - root.Position).Magnitude > TRAP_RANGE then return end
		local now = os.clock()
		if now - (lastTrapAt[player] or 0) < TRAP_COOLDOWN then return end
		lastTrapAt[player] = now
		local trap = Instance.new("Part")
		trap.Name = "ImpactTrap"
		trap.Size = Vector3.new(3, 0.5, 3)
		trap.Anchored = true
		trap.CanCollide = true
		trap.Material = Enum.Material.Metal
		trap.Color = Color3.fromRGB(210, 80, 55)
		trap.CFrame = CFrame.new(value + Vector3.new(0, 0.25, 0))
		trap.Parent = workspace
		local triggered = false
		trap.Touched:Connect(function(hit)
			if triggered or hit:IsDescendantOf(player.Character or workspace) then return end
			local model = hit:FindFirstAncestorOfClass("Model")
			local humanoid = model and model:FindFirstChildOfClass("Humanoid")
			if not humanoid or Players:GetPlayerFromCharacter(model) == player then return end
			triggered = true
			local position = trap.Position
			local blast = Instance.new("Explosion")
			blast.Position = position
			blast.BlastRadius = TRAP_RADIUS
			blast.BlastPressure = 0
			blast.DestroyJointRadiusPercent = 0
			blast.Parent = workspace
			for _, target in Players:GetPlayers() do
				local targetRoot = getRoot(target)
				local targetHumanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
				if target ~= player and targetRoot and targetHumanoid and (targetRoot.Position - position).Magnitude <= TRAP_RADIUS then
					targetHumanoid:TakeDamage(TRAP_DAMAGE)
				end
			end
			trap:Destroy()
		end)
		Debris:AddItem(trap, 90)
	elseif action == "Loot" then
		if typeof(value) ~= "Instance" then return end
		local object = value
		if not object:IsA("Model") and not object:IsA("BasePart") then return end
		if not CollectionService:HasTag(object, "Lootable") then return end
		local root = getRoot(player)
		local part = object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
		if not root or not part or (part.Position - root.Position).Magnitude > 12 then return end
		if object:GetAttribute("Looted") then return end
		object:SetAttribute("Looted", true)
		local stats = player:FindFirstChild("leaderstats")
		local currency = stats and stats:FindFirstChild("Coins")
		if currency and (currency:IsA("IntValue") or currency:IsA("NumberValue")) then
			currency.Value += LOOT_REWARD
		end
		object:Destroy()
	end
end)

local function spawnShipment()
	local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	local position = spawn and spawn.Position + Vector3.new(0, 18, 0) or Vector3.new(0, 18, 0)
	local crate = Instance.new("Part")
	crate.Name = "SupplyShipment"
	crate.Size = Vector3.new(5, 5, 5)
	crate.Position = position
	crate.Anchored = false
	crate.Material = Enum.Material.WoodPlanks
	crate.Color = Color3.fromRGB(130, 87, 48)
	crate.Parent = workspace
	CollectionService:AddTag(crate, "Lootable")
	Debris:AddItem(crate, 300)
end

task.spawn(function()
	while true do
		task.wait(SHIPMENT_INTERVAL)
		spawnShipment()
	end
end)

local function initializePlayer(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	if not leaderstats:FindFirstChild("Coins") then
		local coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = 0
		coins.Parent = leaderstats
	end
	player.CharacterAdded:Connect(function()
		if flying[player] then setFly(player, false) end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	setFly(player, false)
	lastTrapAt[player] = nil
end)

Players.PlayerAdded:Connect(initializePlayer)
for _, player in Players:GetPlayers() do
	initializePlayer(player)
end

RunService.Heartbeat:Connect(function()
	for player in flying do
		if not getRoot(player) then setFly(player, false) end
	end
end)
