-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

-- VARIABLES
local safePoint = nil
local autoSafeTPEnabled = false
local autoSafeTPThreshold = 25
local hasAutoTPTriggered = false
local freezeEnabled = false
local clickTPEnabled = false
local fakeLagEnabled = false
local noclipEnabled = false
local infJumpEnabled = false
local speedValue = 16
local freezePosition = nil
local infinityYieldLoaded = false
local blinkDistance = 20
local autoFarmEnabled = {}
local activeLootItems = {}
local BossAlertsEnabled = false

-- Update character references on respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
end)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function teleportTo(cf)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(cf[1], cf[2], cf[3])
end


-- ================= LOAD RAYFIELD SAFELY =================
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Failed to load Rayfield UI Library. Script cannot continue.")
    return
end

-- Optional tiny delay to ensure everything initialized
task.wait(0.1)

-- CREATE WINDOW
local Window = Rayfield:CreateWindow({
   Name = "DurDom's World Of Stands",
   Icon = 0,
   LoadingTitle = "DurDom Hub",
   LoadingSubtitle = "by itzAyeJay",
   ShowText = "DurDom Hub",
   Theme = "Serenity",
   ToggleUIKeybind = Enum.KeyCode.Insert,  -- correct Enum
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "Big Hub" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   KeySystem = true,
   KeySettings = {
      Title = "DurDom Hub:",
      Subtitle = "By: itzayejay",
      Note = "Join The Discord For Free Keys!",
      FileName = "Key",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"joestar"}
   }
})

-- MAKE RAYFIELD UI LARGER
task.wait() -- wait a tiny moment for the UI to load

local RayfieldGui = game:GetService("CoreGui"):FindFirstChild("Rayfield")

if RayfieldGui then
	local scale = Instance.new("UIScale")
	scale.Scale = 1.2 -- adjust this for desired size
	scale.Parent = RayfieldGui
end


-- ================= PLAYER TAB =================
local PlayerTab = Window:CreateTab("Player", 4483362458)
local PlayerSection = PlayerTab:CreateSection("Movement")

-- SPEED (Default 25, Slider only when enabled)

local DEFAULT_WALKSPEED = 25
local speedValue = 25
local speedEnabled = false

-- SPEED SLIDER (ONLY USED WHEN TOGGLE IS ON)
local SpeedSlider = PlayerTab:CreateSlider({
	Name = "Speed",
	Range = {1, 50},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = speedValue,
	Flag = "SpeedSlider",
	Callback = function(Value)
		speedValue = Value
	end
})

-- SPEED TOGGLE
local SpeedToggle = PlayerTab:CreateToggle({
	Name = "Enable Speed",
	CurrentValue = false,
	Flag = "SpeedToggle",
	Callback = function(Value)
		speedEnabled = Value

		if humanoid then
			if speedEnabled then
				humanoid.WalkSpeed = speedValue
			else
				humanoid.WalkSpeed = DEFAULT_WALKSPEED
			end
		end

		-- Stop artificial velocity when disabling
		if not speedEnabled and root then
			root.AssemblyLinearVelocity =
				Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
		end
	end
})

-- APPLY SPEED (ONLY WHEN ENABLED)
RunService.RenderStepped:Connect(function()
	if not speedEnabled then return end
	if not character or not humanoid or not root then return end

	-- Match WalkSpeed so animations stay natural
	humanoid.WalkSpeed = speedValue

	local moveDir = humanoid.MoveDirection
	if moveDir.Magnitude > 0 then
		local currentY = root.AssemblyLinearVelocity.Y
		root.AssemblyLinearVelocity =
			(moveDir.Unit * speedValue) + Vector3.new(0, currentY, 0)
	end
end)

-- ENSURE DEFAULT SPEED ON RESPAWN
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")

	humanoid.WalkSpeed = DEFAULT_WALKSPEED
end)

-- APPLY DEFAULT IMMEDIATELY
if humanoid then
	humanoid.WalkSpeed = DEFAULT_WALKSPEED
end


-- INFINITE JUMP
local InfJumpToggle = PlayerTab:CreateToggle({
    Name = "Inf Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(state)
        infJumpEnabled = state
    end
})


UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and humanoid and root then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- NO CLIP
local NoClipToggle = PlayerTab:CreateToggle({
	Name = "No Clip",
	CurrentValue = noclipEnabled,
	Flag = "NoClip",
	Callback = function(state)
		noclipEnabled = state
	end
})

RunService.RenderStepped:Connect(function()
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not noclipEnabled
			end
		end
	end
end)

-- FAKE LAG
local FakeLagToggle = PlayerTab:CreateToggle({
	Name = "Fake Lag",
	CurrentValue = fakeLagEnabled,
	Flag = "FakeLag",
	Callback = function(state)
		fakeLagEnabled = state
	end
})

spawn(function()
	while true do
		task.wait(math.random(0.2,2.8))
		if fakeLagEnabled and root then
			local forward = math.random(-16,16)
			local sideways = math.random(-10,10)
			root.CFrame = root.CFrame * CFrame.new(sideways,0,forward)
		end
	end
end)

-- CLICK TP TO MOUSE
local ClickTPToggle = PlayerTab:CreateToggle({
	Name = "Click TP",
	CurrentValue = clickTPEnabled,
	Flag = "ClickTP",
	Callback = function(state)
		clickTPEnabled = state
	end
})

local ClickTPBind = PlayerTab:CreateKeybind({
    Name = "Click TP Key",
    CurrentKeybind = "F",
    HoldToInteract = true,
    Flag = "ClickTPKey",
    Callback = function(held)
        -- This variable 'held' is true while the key is held if HoldToInteract = true
        clickTPEnabled = held
    end,
})


mouse.Button1Down:Connect(function()
	if clickTPEnabled and UserInputService:IsKeyDown(Enum.KeyCode.F) and root then
		local targetPos = mouse.Hit.Position + Vector3.new(0,5,0)
		root.CFrame = CFrame.new(targetPos)
	end
end)

-- ================= BLATANT TAB =================
local BlatantTab = Window:CreateTab("Blatant", 4483362458)
local BlatantSection = BlatantTab:CreateSection("Player Exploits")

-- BLINK SLIDER
local BlinkSlider = BlatantTab:CreateSlider({
    Name = "Blink Distance",
    Range = {10, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = blinkDistance,
    Flag = "BlinkSlider",
    Callback = function(val)
        blinkDistance = val
    end,
})

-- BLINK KEYBIND
local BlinkKeybind = BlatantTab:CreateKeybind({
    Name = "Blink Key",
    CurrentKeybind = "Z",
    HoldToInteract = false,
    Flag = "BlinkKeybind",
    Callback = function()
        if root then
            root.CFrame = root.CFrame + root.CFrame.LookVector * blinkDistance
        end
    end,
})

-- ANTI-RAGDOLL TOGGLE
local AntiRagdollToggle = BlatantTab:CreateToggle({
    Name = "Anti-Ragdoll",
    CurrentValue = false,
    Flag = "AntiRagdoll",
    Callback = function(state)
        AntiRagdollEnabled = state
    end,
})

-- WATCH RAGDOLL FUNCTION
local function watchRagdoll(char)
    local ragdollFlag = char:FindFirstChild("Ragdolled")
    if ragdollFlag then
        ragdollFlag:GetPropertyChangedSignal("Value"):Connect(function()
            if AntiRagdollEnabled and ragdollFlag.Value then
                ragdollFlag.Value = false
            end
        end)
    end
end

watchRagdoll(character)
player.CharacterAdded:Connect(function(char)
    watchRagdoll(char)
end)

-- ================= AUTO FARM NPCS =================
--[[ local AutoFarmSection = BlatantTab:CreateSection("Auto Farm NPCs")

local npcTypes = {"Thug","Strong Thug","Criminal","Speedwagon Gang Member","Slugger","Evil Vampire","Vampire Capo","Capo","Corrupt Cop","Mobster","Cult Commander","Desert Bandit"}
local miniBosses = {"Tarkus","Bruford","Chaka","Banks"}
local followDistance = 8

for _, npcName in ipairs(npcTypes) do
    autoFarmEnabled[npcName] = false
    AutoFarmSection:CreateToggle({
        Name = "Auto Farm "..npcName,
        CurrentValue = false,
        Flag = "AutoFarm"..npcName,
        Callback = function(state)
            autoFarmEnabled[npcName] = state
        end,
    })
end

for _, bossName in ipairs(miniBosses) do
    autoFarmEnabled[bossName] = false
    AutoFarmSection:CreateToggle({
        Name = "Auto Farm "..bossName,
        CurrentValue = false,
        Flag = "AutoFarm"..bossName,
        Callback = function(state)
            autoFarmEnabled[bossName] = state
        end,
    })
end

-- AUTO FARM LOGIC
RunService.RenderStepped:Connect(function()
    if not root then return end
    for npcName, enabled in pairs(autoFarmEnabled) do
        if enabled then
            local candidates = {}
            for _, npc in pairs(workspace:GetChildren()) do
                if npc.Name == npcName and npc:FindFirstChild("HumanoidRootPart") then
                    local hum = npc:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        table.insert(candidates, npc)
                    end
                end
            end
            local closestNpc = nil
            local shortestDist = math.huge
            for _, npc in pairs(candidates) do
                local dist = (npc.HumanoidRootPart.Position - root.Position).Magnitude
                if dist < shortestDist then
                    closestNpc = npc
                    shortestDist = dist
                end
            end
            if closestNpc then
                local npcHRP = closestNpc.HumanoidRootPart
                local behindPos = npcHRP.CFrame * CFrame.new(0,0,followDistance)
                root.CFrame = CFrame.new(behindPos.Position, npcHRP.Position)
            end
        end
    end
end)
]]

-- ================= SAFETY TAB =================
local SafetyTab = Window:CreateTab("Safety", 4483362458)

-- SAFE POINT LABEL
local SafePointLabel = SafetyTab:CreateLabel("Safe Point: Not Set", 0, Color3.fromRGB(255,255,255), false)

-- PLACE SAFE POINT
SafetyTab:CreateButton({
    Name = "Place Safe Point",
    Callback = function()
        if root then
            safePoint = root.CFrame
            SafePointLabel:Set("Safe Point: Set", 0, Color3.fromRGB(255,255,255), false)
        end
    end
})

local SafeTPKeybind = SafetyTab:CreateKeybind({
    Name = "Teleport to Safe Point",
    CurrentKeybind = "T", -- change to whatever key you want
    HoldToInteract = false,
    Flag = "SafeTPKey",
    Callback = function()
        if safePoint and root then
            root.CFrame = safePoint
        end
    end
})


-- AUTO TP ON LOW HP
SafetyTab:CreateToggle({
	Name = "Auto TP on Low HP",
	CurrentValue = false,
	Flag = "AutoSafeTP",
	Callback = function(state)
		autoSafeTPEnabled = state
		hasAutoTPTriggered = false
	end
})

SafetyTab:CreateSlider({
	Name = "Auto TP Health",
	Range = {10, 500},
	Increment = 5,
	Suffix = "HP",
	CurrentValue = autoSafeTPThreshold,
	Flag = "AutoSafeTPSlider",
	Callback = function(val)
		autoSafeTPThreshold = val
	end
})


-- AUTO TP LOGIC
RunService.Heartbeat:Connect(function()
	if autoSafeTPEnabled and humanoid and root and safePoint then
		if humanoid.Health <= autoSafeTPThreshold and not hasAutoTPTriggered then
			hasAutoTPTriggered = true
			root.CFrame = safePoint
			Rayfield:Notify({
				Title = "Safety",
				Content = "Auto TP Activated!",
				Duration = 3,
				Image = 4483362458
			})
		elseif humanoid.Health > autoSafeTPThreshold then
			hasAutoTPTriggered = false
		end
	end
end)


-- FREEZE TOGGLE
local FreezeToggle = SafetyTab:CreateToggle({
    Name = "Freeze",
    CurrentValue = false,
    Flag = "FreezeToggle",
    Callback = function(state)
        freezeEnabled = state
        if freezeEnabled and root then
            freezePosition = root.CFrame
            humanoid.PlatformStand = true
        else
            humanoid.PlatformStand = false
        end
    end
})

-- RenderStepped for freeze
RunService.RenderStepped:Connect(function()
    if freezeEnabled and root then
        root.CFrame = freezePosition
    end
end)

RunService.Heartbeat:Connect(function()
	if autoSafeTPEnabled and humanoid and root and safePoint then
		if humanoid.Health <= autoSafeTPThreshold and not hasAutoTPTriggered then
			hasAutoTPTriggered = true
			root.CFrame = safePoint
			Rayfield:Notify({
				Title = "Safety",
				Content = "Auto TP Activated!",
				Duration = 3
			})
		elseif humanoid.Health > autoSafeTPThreshold then
			hasAutoTPTriggered = false
		end
	end
end)

-- ================= CHESTS TAB =================
local ChestsTab = Window:CreateTab("Chests", 4483362458)

-- ================= RARE CHESTS =================
local RareChestsTab = ChestsTab -- Already have Chests tab

local activeChestList = {}
local autoCollectEnabled = false

-- Function to populate chest buttons
local function populateChestButtons()
    -- Clear previous buttons
    if RareChestsTab.ChestButtons then
        for _, btn in pairs(RareChestsTab.ChestButtons) do
            btn:Destroy()
        end
    end
    RareChestsTab.ChestButtons = {}

    activeChestList = {}

    for i = 1, 54 do
        local chest = workspace:FindFirstChild(tostring(i))
        if chest and chest.PrimaryPart then
            activeChestList[i] = chest

            local btn = RareChestsTab:CreateButton({
                Name = "Chest "..i,
                Callback = function()
                    if chest.PrimaryPart and root then
                        root.CFrame = chest.PrimaryPart.CFrame + Vector3.new(0,10,0) -- 10 studs above
                    end
                end
            })

            table.insert(RareChestsTab.ChestButtons, btn)
        end
    end
end


local createdChestButtons = createdChestButtons or {}
local chestCache = chestCache or {}




-- Initialize on load
populateChestButtons()



-- ===== NORMAL CHESTS =====
local chestsTable = {}
local ChestsDropdown = ChestsTab:CreateDropdown({
    Name = "Normal Chests",
    Options = {},
    CurrentOption = {},
    Flag = "NormalChestsDropdown",
    Callback = function(selected)
        local chosen = selected[1]
        if chosen and chestsTable[chosen] and root then
            root.CFrame = chestsTable[chosen] + Vector3.new(0,10,0) -- teleport 10 studs above
        end
    end,
})

local function updateChests()
    chestsTable = {}
    local container = workspace:FindFirstChild("ChestContainer")
    if not container then return end
    for _, model in pairs(container:GetChildren()) do
        local base = model:FindFirstChild("Base") or model:FindFirstChildWhichIsA("BasePart")
        if base then
            chestsTable[model.Name] = base.CFrame
        end
    end

    -- refresh dropdown options
    local options = {}
    for k in pairs(chestsTable) do table.insert(options, k) end
    table.sort(options)
    ChestsDropdown:Refresh(options)
end

-- initial load
updateChests()

-- listen for additions/removals
workspace.ChildAdded:Connect(function(child)
    if tonumber(child.Name) then
        updateRareChests()
    elseif child.Parent == workspace:FindFirstChild("ChestContainer") then
        updateChests()
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if tonumber(child.Name) then
        updateRareChests()
    elseif child.Parent == workspace:FindFirstChild("ChestContainer") then
        updateChests()
    end
end)

-- ================= AUTO COLLECT TOGGLE =================
ChestsTab:CreateToggle({
    Name = "Instant Open Chests",
    CurrentValue = false,
    Flag = "AutoCollectChests",
    Callback = function(state)
        autoCollectEnabled = state
    end
})

local pps = game:GetService("ProximityPromptService")

-- Function to instantly fire a prompt
local function firePromptInstant(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    local success, err = pcall(function()
        fireproximityprompt(prompt, 0, true) -- true skips hold duration
    end)
    if not success then
        warn("Failed to fire prompt: "..tostring(err))
    end
end

-- Watch for prompts being “held” and fire instantly
pps.PromptButtonHoldBegan:Connect(function(prompt)
    if autoCollectEnabled then
        firePromptInstant(prompt)
    end
end)

-- Auto collect loop for chests we know
task.spawn(function()
    while true do
        if autoCollectEnabled then
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart

                -- Rare chests
                for _, chest in pairs(activeChestList) do
                    if chest and chest.PrimaryPart then
                        local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt and (prompt.Parent.Position - hrp.Position).Magnitude <= prompt.MaxActivationDistance then
                            firePromptInstant(prompt)
                        end
                    end
                end

                -- Normal chests
                for name, cframe in pairs(chestsTable) do
                    local model = workspace:FindFirstChild(name)
                    if model then
                        local prompt = model:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt and (prompt.Parent.Position - hrp.Position).Magnitude <= prompt.MaxActivationDistance then
                            firePromptInstant(prompt)
                        end
                    end
                end
            end
        end
        task.wait(0.05) -- fast loop for instant collection
    end
end)


-- ================= FLOOR LOOT TAB =================
local FloorLootTab = Window:CreateTab("Floor Loot", 4483362458)

local floorLootItems = {
    "StandArrow",
    "ShinyArrow",
    "LocacacaFruit",
    "Pluck",
    "LegendaryArrow"
}

local activeLootItems = {}
local autoCollect = false

-- Dropdown to teleport
local LootDropdown = FloorLootTab:CreateDropdown({
    Name = "Teleport to Floor Loot",
    Options = {},
    CurrentOption = {},
    Flag = "FloorLootDropdown",
    Callback = function(selection)
        local selectedItem = selection[1]
        if not selectedItem then return end

        local model = workspace:FindFirstChild(selectedItem)
        if model then
            local part = model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Part")
            if part and root then
                root.CFrame = part.CFrame + Vector3.new(0,5,0)
            end
        end
    end
})

-- Toggle for auto-collect
local AutoCollectToggle = FloorLootTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(state)
        autoCollect = state
    end
})

-- Update dropdown options
local function updateLootDropdown()
    LootDropdown:Refresh(activeLootItems)
end

-- Show a notification when loot spawns
local function showLootNotification(itemName)
    Rayfield:Notify({
        Title = "Floor Loot Spawned",
        Content = itemName .. " has appeared!",
        Duration = 6,
        Image = 4483362458
    })
end

-- Add loot to active list
local function addLoot(itemName)
    if table.find(activeLootItems, itemName) then return end
    table.insert(activeLootItems, itemName)
    updateLootDropdown()
    showLootNotification(itemName)
end

-- Remove loot after disappearing
local function removeLoot(itemName)
    for i, name in ipairs(activeLootItems) do
        if name == itemName then
            table.remove(activeLootItems, i)
            break
        end
    end
    updateLootDropdown()
end

-- Initial scan for loot
for _, itemName in ipairs(floorLootItems) do
    if workspace:FindFirstChild(itemName) then
        addLoot(itemName)
    end
end

-- Listen for loot spawning/removal
workspace.ChildAdded:Connect(function(child)
    if table.find(floorLootItems, child.Name) then
        addLoot(child.Name)
    end
end)
workspace.ChildRemoved:Connect(function(child)
    if table.find(floorLootItems, child.Name) then
        removeLoot(child.Name)
    end
end)

-- Continuous auto-collect loop
spawn(function()
    while true do
        task.wait(0.3)
        if autoCollect and root then
            for _, itemName in ipairs(activeLootItems) do
                local model = workspace:FindFirstChild(itemName)
                if model then
                    local part = model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Part")
                    if part then
                        root.CFrame = part.CFrame + Vector3.new(0,5,0)
                    end
                end
            end
        end
    end
end)


-- ================= LOCATIONS TAB =================
local LocationsTab = Window:CreateTab("Locations", 4483362458)

-- Track which buttons we already created
local createdLocationButtons = {}

local function updateLocations()
	local folder = workspace:WaitForChild("TravelLocations")

	for _, part in ipairs(folder:GetChildren()) do
		if part:IsA("BasePart") then
			local locationName = tostring(part.Name)

			if not createdLocationButtons[locationName] then
				createdLocationButtons[locationName] = true

				LocationsTab:CreateButton({
					Name = locationName,
					Callback = function()
						if root then
							root.CFrame = part.CFrame
						end
					end
				})
			end
		end
	end
end

-- Update when new locations are added
workspace.TravelLocations.ChildAdded:Connect(updateLocations)

-- Initial load
updateLocations()

-- ================= NPC TAB =================

-- ================= NPC STORY TELEPORTS (ORDERED) =================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function teleportTo(x, y, z)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(x, y, z)
end

-- ================================================================
-- DIO STORY NPCs
-- ================================================================
local DioTab = Window:CreateTab("Dio Story NPCs", 4483362458)

local DioStory = {
    {"Talk to Jonathan in the Mansion", 490, 11, 201},
    {"Defeat 2 Thugs", 331, 10, 390},
    {"Return to Jonathan", 490, 11, 201},
    {"Free Danny", 389, 10, 452},
    {"Sewer Key", 600, 10, 390},
    {"Talk to Jonathan in the Mansion (Again)", 490, 11, 201},
    {"Go find William Zeppeli", 135, 10, 123},
    {"Meet with Jonathan outside mansion", 231, 10, 226},
    {"Meet with Zeppeli", 135, 10, 123},
    {"Meet with Speedwagon", 62, 10, 394},
    {"Go back to Zeppeli", 138, 10, 154},
    {"Look for Zeppeli graveyard", 355, 10, 585},
    {"Go find Valentina", -153, 17, 555},
    {"Meet Jonathan at Castle", -17, 41, 727},
    {"Return to Jonathan", -16, 41, 728},
}

for _, data in ipairs(DioStory) do
    DioTab:CreateButton({
        Name = data[1],
        Callback = function()
            teleportTo(data[2], data[3], data[4])
        end
    })
end

-- ================================================================
-- NY STORY NPCs
-- ================================================================
local NYTab = Window:CreateTab("NY Story NPCs", 4483362458)

local NYStory = {
    {"Head to New York", -428, 10, 180},
    {"Go to the Cafe", -859, 10, 245},
    {"Talk to Police Chief", -573, 12, 288},
    {"Report back to Joseph", -859, 10, 245},
    {"Head to Parking Garage", -617, 10, -13},
    {"Construction Manager", -486, 10, 143},
    {"Clint", -488, 70, -21},
    {"Strange Looking Man", -937, -482, 202},
    {"Exit Sewer", -1163, -443, 495},
    {"Meet Smokey at Cafe", -861, 10, 242},
    {"Talk to Smokey", -886, 10, 258},
    {"Speak to Clint", -997, 10, 256},
    {"Return to Smokey", -886, 10, 258},
    {"Meet Joseph Outside Warehouse", -968, 10, 390},
    {"Report to Joseph Cafe", -861, 10, 242},
    {"Meet up with Joseph Warehouse", -968, 10, 390},
    {"Meet with Joseph back of Warehouse", -1029, 10, 583},
    {"Joseph Suspicious Container", -935, 10, 467},
    {"Defeat Banks", -960, -25, 498},
    {"Meet back with Smokey", -886, 10, 258},
    {"Meet Lisa Lisa Docks", -1153, -5, -153},
    {"Return to Lisa Lisa Docks", -1153, -5, -153},
}

for _, data in ipairs(NYStory) do
    NYTab:CreateButton({
        Name = data[1],
        Callback = function()
            teleportTo(data[2], data[3], data[4])
        end
    })
end

-- ================================================================
-- NY / SEWER STORY NPCs
-- ================================================================
local SewerTab = Window:CreateTab("NY / Sewer Story NPCs", 4483362458)

local SewerStory = {
    {"Meet Caesar at Cafe", -913, 10, 223},
    {"Enter Sewer", -433, -4, 110},
    {"Catch up to Joseph", -903, -482, 207},
    {"Deeper into Sewers with Joseph", -994, -482, -116},
    {"Red Button", -784, -482, -1},
    {"Talk to Joseph again", -926, -482, -105},
    {"Talk to Joseph", -558, -490, -79},
    {"Return to Joseph", -560, -490, -113},
    {"Speak to Joseph Other Side", -898, -517, -137},
    {"Maintenance Room", -1157, -510, -269},
    {"Place the Fuse", -634, -510, -338},
    {"Meet Joseph at Cafe", -856, 10, 244},
    {"Talk to Caesar at the Boat", -625, 15, 533},
    {"Meet Joseph back Cafe", -856, 10, 244},
    {"Top of Cafe", -895, 66, 248},
    {"Meet Stroheim at Boat", -592, 15, 533},
    {"Head to sewers", -435, -4, 114},
    {"Entrance of Underground Base", -547, -517, -492},
    {"Stroheim in the Base", -612, -534, -827},
    {"Radio Interceptor 1", -444, -533, -644},
    {"Radio Interceptor 2", -487, -533, -608},
    {"Radio Interceptor 3", -472, -533, -614},
    {"Place Interceptors", -711, -504, -794},
    {"Navigate Traps Regroup with Joseph", -248, -539, -419},
    {"Talk to Smokey at the Cafe", -889, 10, 259},
    {"Meet Joseph on the Boat", -631, 15, 548},
    {"Gather Supplies 1/4", -997, 10, 597},
    {"Gather Supplies 2/4", -914, 12, 433},
    {"Gather Supplies 3/4", -983, -25, 446},
    {"Gather Supplies 4/4", -1003, 11, 438},
    {"Bring items back to Stroheim", -594, 15, 532},
    {"Debrief with Stroheim", -594, 15, 532},
    {"Underground Parking Garage", -465, -10, -12},
    {"Head to Docks for Joseph", -957, -5, -255},
    {"Meet Valentina at the Bridge", -1188, 10, 5},
}

for _, data in ipairs(SewerStory) do
    SewerTab:CreateButton({
        Name = data[1],
        Callback = function()
            teleportTo(data[2], data[3], data[4])
        end
    })
end

-- ================================================================
-- VALLEY STORY NPCs
-- ================================================================
local ValleyTab = Window:CreateTab("Valley Story", 4483362458)

local ValleyStory = {
    {"Head Further up the Valley Valentina", -2992, -339, 74},
    {"Mirrors area", -3326, -223, 249},
    {"Discuss with Valentina", -3604, -138, 404},
    {"Catch up with Valentina", -4200, 28, 64},
    {"Head toward bandits with Joseph", -4432, 12, 424},
    {"Regroup at Desert Outposts Joseph", -4446, -1, 88},
    {"Follow Strange Mother", -4631, 23, 477},
    {"Meet Joseph at Mist", -5106, 12, 192},
    {"Clear Misty Valley Domain", -5364, -56, 51},
}

for _, data in ipairs(ValleyStory) do
    ValleyTab:CreateButton({
        Name = data[1],
        Callback = function()
            teleportTo(data[2], data[3], data[4])
        end
    })
end

-- ================= STAND FARM TAB (FULL REPLACEMENT) =================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Network = require(ReplicatedStorage.Network)

-- ===== CONFIG =====
local STAND_LIST = {
    "Anubis","Anubis Chariot","Crazy Diamond","Cream","D4C","Death 13",
    "Echoes","Emperor","Gold Experience","GEB","Heirophant Green","Hamon",
    "Killer Queen","King Crimson","Magician's Red","Red Hot Chili Pepper",
    "Silver Chariot","Star Platinum","Sticky Fingers","The Hand","The World",
    "The Sun","Ultimate Lifeform","Vampire","Weather Report","White Snake"
}

-- ===== SKIN LIST =====
local SKIN_LIST = {
    -- Crazy Diamond
    "Rectifier",
    "Shining Paladin",
    "Champion of Ra",

    -- Gold Experience
    "Derezzed",
    "Golden Sentinel",
    "Subzero",
    "Celestial Warlord",

    -- Star Platinum
    "Dark Star",
    "Savage Star",
    "World Destroyer",
    "Platinum Pugilist",

    -- The World
    "Divine World",
    "Infernal World",
    "Pharaoh Of Time",
    "Bane Of Souls",
    "Dark Eclipse",

    -- Sticky Fingers
    "Revenant",
    "The Boss",
    "Crypt Keeper",

    -- Magician's Red
    "Purple Blaze",
    "Tainted Magician",
    "Spirit Tengu",
    "Master Zhulong",
    "Fire Fighter",

    -- Anubis
    "Master Sword",
    "Saber",
    "Yamato",
    "HF Murasama",
    "Soul Edge",

    -- Killer Queen
    "Killer Panther",
    "Arctic Queen",
    "Neuromancer",

    -- Weather Report
    "Avatar State",
    "Heat Wave",
    "Zeus The Almighty",
    "Storm Deity",

    -- Silver Chariot
    "RX-78-2",
    "Cyber Chariot Mk. IV",
    "Baron Baguette",

    -- The Hand
    "Hand of the Dragon",
    "Space Ripper",

    -- Red Hot Chili Pepper
    "Godspeed",
    "Thunderclap",
    "Red Hot Rockstar",
    "Divine Spark",

    -- Echoes
    "Celestial Echoes",
    "Exomantis",
    "Night Watcher",

    -- King Crimson
    "King of Shadows",
    "The Executioner",
    "Mr. Infinity",
    "Tyrant of Tragedies",

    -- Anubis Chariot
    "Greatest Swordsman",
    "Mr. Motivated",
    "Gilded Knight",

    -- Death 13
    "Angel of Death",
    "Demon Lord",

    -- The Sun
    "The Nerd",
    "Hollow Purple",

    -- Hierophant Green
    "Magma Fiend",
    "Emerald Invader",
    "Steel Man",

    -- Whitesnake
    "Darksnake",
    "Blood Angel",
    "Serpent of Chaos",

    -- Cream
    "Galaxy Eater",
    "Abyss Monster",

    -- Emperor
    "Raygun",
    "Desert Eagle",

    -- D4C
    "Quantum Killer",
    "Funny Valentine"
}

local ARROW_NORMAL = "StandArrow"
local ARROW_SHINY = "ShinyArrow"
local ARROW_LEGENDARY = "LegendaryArrow"
local FRUIT_NAME = "LocacacaFruit"
local FARM_DELAY = 1

-- ===== STATE =====
local standFarmEnabled = false
local skinFarmEnabled = false
local targetStand = nil
local targetSkin = nil
local selectedArrow = ARROW_NORMAL

-- ===== UTIL =====
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function destroyArrowGui()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return end
    local baseGui = pg:FindFirstChild("BaseGui")
    if baseGui and baseGui:FindFirstChild("Frame") then
        baseGui.Frame:Destroy()
    end
end

-- ===== STAND / SKIN DETECTION =====
local function findAnyStandModel()
    local char = getCharacter()
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Model") then
            return obj.Name
        end
    end
    return nil
end

local function hasTargetStand(name)
    if not name then return false end
    local char = getCharacter()
    name = name:lower()
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Model") and obj.Name:lower():find(name) then
            return true
        end
    end
    return false
end

local function playerHasSkin(skinName)
    if not skinName then return false end
    local char = getCharacter()
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Model") and obj.Name:lower() == skinName:lower() then
            return true
        end
    end
    return false
end

-- ===== ITEM USE =====
local function useItem(itemName)
    pcall(function()
        Network:InvokeServer("UseItem", itemName)
    end)
end

local function getArrowToUse()
    return selectedArrow
end

-- ===== MAIN FARM LOOP =====
task.spawn(function()
    while true do
        task.wait(FARM_DELAY)

        if not standFarmEnabled or not targetStand then
            continue
        end

        destroyArrowGui()

        -- ===== STOP CONDITIONS =====
        if skinFarmEnabled and targetSkin and playerHasSkin(targetSkin) then
            standFarmEnabled = false
            Rayfield:Notify({
                Title = "Stand Farm",
                Content = "Obtained skin: "..targetSkin,
                Duration = 6
            })
            continue
        end

        if not skinFarmEnabled and hasTargetStand(targetStand) then
            standFarmEnabled = false
            Rayfield:Notify({
                Title = "Stand Farm",
                Content = "Obtained stand: "..targetStand,
                Duration = 6
            })
            continue
        end

        -- ===== FARM LOGIC =====
        local currentStand = findAnyStandModel()

        if not currentStand then
            useItem(getArrowToUse())
        else
            useItem(FRUIT_NAME)
        end
    end
end)

-- ===== UI =====
local StandFarmTab = Window:CreateTab("Stand Farm", 4483362458)

StandFarmTab:CreateToggle({
    Name = "Enable Stand Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        standFarmEnabled = v
    end
})

StandFarmTab:CreateDropdown({
    Name = "Target Stand",
    Options = STAND_LIST,
    CurrentOption = {},
    Callback = function(v)
        targetStand = v[1]
    end
})

StandFarmTab:CreateToggle({
    Name = "Enable Skin Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        skinFarmEnabled = v
    end
})

StandFarmTab:CreateDropdown({
    Name = "Target Skin",
    Options = SKIN_LIST,
    CurrentOption = {},
    Callback = function(v)
        targetSkin = v[1]
    end
})

StandFarmTab:CreateDropdown({
    Name = "Arrow Type",
    Options = {"Normal","Shiny","Legendary"},
    CurrentOption = {"Normal"},
    Callback = function(v)
        if v[1] == "Shiny" then
            selectedArrow = ARROW_SHINY
        elseif v[1] == "Legendary" then
            selectedArrow = ARROW_LEGENDARY
        else
            selectedArrow = ARROW_NORMAL
        end
    end
})

StandFarmTab:CreateLabel(
    "Stand Farm rolls until stand. Skin Farm rerolls until skin model exists.",
    0,
    Color3.fromRGB(255,255,255),
    false
)



-- ================= MISC TAB =================
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- ================= INFINITY YIELD =================
MiscTab:CreateButton({
	Name = "Open Infinity Yield",
	Callback = function()
		if infinityYieldLoaded then
			Rayfield:Notify({
				Title = "Infinity Yield",
				Content = "Infinity Yield is already loaded.",
				Duration = 5,
				Image = 4483362458
			})
			return
		end

		infinityYieldLoaded = true

		loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
			true
		))()

		Rayfield:Notify({
			Title = "Infinity Yield",
			Content = "Infinity Yield loaded successfully.",
			Duration = 5,
			Image = 4483362458
		})
	end
})

local BossAlertsEnabled = false

MiscTab:CreateToggle({
	Name = "Boss Alerts",
	CurrentValue = false,
	Flag = "BossAlerts",
	Callback = function(state)
		BossAlertsEnabled = state
	end
})

local bossList = {
	"Bruford",
	"Chaka",
	"Banks",
	"Straizo",
	"N'Doul",
	"Lucy"
}
local function showBossNotification(bossName)
	if not BossAlertsEnabled then return end

	Rayfield:Notify({
		Title = "Boss Spawned",
		Content = bossName .. " has spawned!",
		Duration = 7,
		Image = 4483362458
	})
end
workspace.ChildAdded:Connect(function(child)
	if table.find(bossList, child.Name) then
		showBossNotification(child.Name)
	end
end)


-- ================= FAST AUTO DROP (MISC TAB) =================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Network = require(ReplicatedStorage.Network)

-- MUCH faster delay (Heartbeat-driven)
local DROP_INTERVAL = 0.1

-- Server item names
local DROP_ITEMS = {
    "StandArrow",
    "ShinyArrow",
    "LegendaryArrow",
    "LocacacaFruit"
}

local dropAllEnabled = false
local lastDropTime = 0
local dropIndex = 1

-- Single safe drop
local function dropItem(itemName)
    pcall(function()
        Network:InvokeServer("DropItem", itemName)
    end)
end

-- Manual buttons (single drop)
MiscTab:CreateButton({
    Name = "Drop Arrow",
    Callback = function()
        dropItem("StandArrow")
    end
})

MiscTab:CreateButton({
    Name = "Drop Shiny Arrow",
    Callback = function()
        dropItem("ShinyArrow")
    end
})

MiscTab:CreateButton({
    Name = "Drop Legendary Arrow",
    Callback = function()
        dropItem("LegendaryArrow")
    end
})

MiscTab:CreateButton({
    Name = "Drop Locacaca Fruit",
    Callback = function()
        dropItem("LocacacaFruit")
    end
})

-- DROP ALL TOGGLE
MiscTab:CreateToggle({
    Name = "Auto Drop All Arrows / Fruits",
    CurrentValue = false,
    Flag = "AutoDropAll",
    Callback = function(state)
        dropAllEnabled = state
        dropIndex = 1
        lastDropTime = 0
    end
})

-- High-speed drop loop (VERY fast but stable)
RunService.Heartbeat:Connect(function()
    if not dropAllEnabled then return end

    if os.clock() - lastDropTime >= DROP_INTERVAL then
        lastDropTime = os.clock()

        local itemName = DROP_ITEMS[dropIndex]
        if itemName then
            dropItem(itemName)
            dropIndex += 1
        else
            dropIndex = 1
        end
    end
end)

