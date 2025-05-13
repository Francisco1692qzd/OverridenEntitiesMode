local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
local camera = workspace.CurrentCamera

local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
	camera.CFrame = camera.CFrame * cf
end)

camShake:Start()

function GetTime(Distance, Speed)
	return Distance / Speed
end

function LoadCustomInstance(source, parent)
	local model

	-- Normalize GitHub URL if needed
	local function NormalizeGitHubURL(url)
		if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
			return url .. "?raw=true"
		end
		return url
	end

	while task.wait() and not model do
		if type(source) == "number" or tostring(source):match("^%d+$") then
			-- Asset ID loading
			print("🔄 Trying to load model from Asset ID: " .. tostring(source))

			local success, result = pcall(function()
				return game:GetObjects("rbxassetid://" .. tostring(source))[1]
			end)

			if success and result then
				model = result
			else
				print("❌ [LoadCustomInstance]: Failed to load asset ID " .. tostring(source) .. ". Retrying... 🔄")
				task.wait(0.5)
			end

		elseif type(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
			-- GitHub URL loading
			local url = NormalizeGitHubURL(source)
			print("🌐 Trying to load .rbxm model from URL: " .. url)

			local success, result = pcall(function()
				local fileName = "temp_" .. tostring(math.random(100000, 999999)) .. ".rbxm"
				writefile(fileName, game:HttpGet(url))
				local obj = game:GetObjects((getcustomasset or getsynasset)(fileName))[1]
				delfile(fileName)
				return obj
			end)

			if success and result then
				model = result
			else
				print("❌ [LoadCustomInstance]: Failed to load from URL. Retrying... 🔄")
				task.wait(0.5)
			end

		else
			warn("🚫 Invalid source type. Must be Asset ID (number) or .rbxm GitHub URL.")
			break
		end

		if model then
			model.Parent = parent or workspace

			for _, obj in ipairs(model:GetDescendants()) do
				if obj:IsA("Script") or obj:IsA("LocalScript") then
					obj:Destroy()
				end
			end

			pcall(function()
				model:SetAttribute("LoadedByExecutor", true)
			end)

			print("✅ [LoadCustomInstance]: Model " .. model.Name .. " successfully loaded into " .. model.Parent:GetFullName())
		end
	end

	return model
end

function GetRoom()
        local gruh = workspace.CurrentRooms
        return gruh:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value)
end

local moduleScripts = {
        Module_Events = require(game.ReplicatedStorage.ClientModules.Module_Events),
        Main_Game = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
}

function Obscura()
	local killed = false
	local s = LoadCustomInstance("https://github.com/Francisco1692qzd/OverridenEntitiesMode/blob/main/obscura.rbxm?raw=true", workspace)
	s.Parent = workspace
	local entity = s:FindFirstChildWhichIsA("BasePart")
	print("Obscura!!!!!!!!!!!!!!!!!!!!!!!LOL!1111111!!!!!!!!!!1!!!!!1!!!¹¹¹¹!11!!1!!!11111!!!!!!1!1111!!1!!1")
        local ClientModules = game.ReplicatedStorage.ClientModules
        local Module_Events = moduleScripts.Module_Events
        local currentRoom = GetRoom()
        moduleScripts.Module_Events.flicker(currentRoom, 1)
	local ambruhspeed = 75
	local ambruhheight = Vector3.new(0,2.5,0)
	local DEF_SPEED = 99999
	local storer = ambruhspeed
	local function SpawnSound()
		local Sound = Instance.new("Sound")
		Sound.Parent = workspace
		Sound.SoundId = "rbxassetid://9125713501"
		local Pitch = Instance.new("PitchShiftSoundEffect", Sound)
		Pitch.Octave = 0.875
		Sound.Volume = 6
		Sound.TimePosition = 0
                Sound.PlaybackSpeed = 0.4
		
		return Sound
	end
	local SpawnerSound = SpawnSound()
	SpawnerSound:Play()
	camShake:Shake(cameraShaker.Presets.Earthquake)
        task.delay(2, function()
                camShake:Shake(cameraShaker.Presets.Earthquake)
        end)
	local function GetLastRoom()
		return workspace.CurrentRooms:FindFirstChild(game.ReplicatedStorage.GameData.LatestRoom.Value + 1)
	end
	local function canSeeTarget(target, size)
		if killed == true then
			return
		end

		local origin = entity.Position
		local direction = (target.HumanoidRootPart.Position - origin).unit * size
		local ray = Ray.new(origin, direction)

		local hit, pos = workspace:FindPartOnRay(ray, entity)

		if hit then
			if hit:IsDescendantOf(target) then
				killed = true
				return true
			end
		else
			return false
		end
	end
	game.Debris:AddItem(SpawnerSound, 20)
	wait(11)
	spawn(function()
		while entity ~= nil and entity.Parent and s ~= nil and s.Parent do wait(0.2)
			local v = game.Players.LocalPlayer
			if v.Character ~= nil and not v.Character:GetAttribute("Hiding") then
				if canSeeTarget(v.Character, 50) then
					local char = v.Character
					local humanoid = char:WaitForChild("Humanoid")
					local blackScreen = Instance.new("ScreenGui", v.PlayerGui)
					local image = Instance.new("Frame", blackScreen)
					local jumpcare = Instance.new("ImageLabel")
					image.Parent = blackScreen
					image.Position = UDim2.new(0.5,0,0.5,0)
					image.AnchorPoint = Vector2.new(0.5,0.5)
					image.Size = UDim2.new(2,0,2,0)
					local scream = Instance.new("Sound")
					wait(1.5)
					jumpcare.Parent = blackScreen
					jumpcare.Image = "rbxassetid://17617519012"
                                        jumpcare.Position = UDim2.new(0.5, 0, 0.5, 0)
                                        jumpcare.AnchorPoint = Vector2.new(0.5, 0.5)
					jumpcare.Size = UDim2.new(0.1,0,0.1,0)
					local tween = game.TweenService:Create(jumpcare, TweenInfo.new(0.5), {
						Position = UDim2.new(0.5,0,0.5,0),
						Size = UDim2.new(2.2, 0, 2.2, 0)
					})
					tween:Play()
					scream.SoundId = "rbxassetid://18564431123"
					scream.Volume = 10
					local dist = Instance.new("DistortionSoundEffect")
					dist.Parent = scream
					wait(0.6)
					dist:Destroy()
					scream:Destroy()
					jumpcare:Destroy()
					image:Destroy()
					blackScreen:Destroy()
					humanoid:TakeDamage(100)
					v.Character:SetAttribute("Alive", false)
					v.Character:SetAttribute("Stunned", true)
					firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
						"You died to Obscura...",
						"Listen closely... his arrival is always loud.",
						"Watch for flickering lights—it’s not always Rush.",
						"Obscura doesn’t always come once. Sometimes, he returns.",
						"He might even appear at the final door.",
						"If the lights go wild and the air feels wrong... find a place to hide."
					}, "Blue")
				end
			end
                        if v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") and (entity.Position - v.Character.HumanoidRootPart.Position).magnitude <= 80 then
                                camShake:ShakeOnce(10, 25, 0, 2, 1, 6)
                        end
		end
	end)
	local gruh = workspace.CurrentRooms
	local ra = math.random(1, 3)
	ambruhspeed = DEF_SPEED
	if ra == 1 then
                print(ra)
		for i = 1, game.ReplicatedStorage.GameData.LatestRoom.Value do
			if gruh:FindFirstChild(i) then
				local room = gruh:FindFirstChild(i)
				if room ~= nil and room:FindFirstChild("Nodes") then
					local nodes = room:FindFirstChild("Nodes")
					for v = 1, #nodes:GetChildren() do
						if nodes:FindFirstChild(v) then
							local waypoint = nodes:FindFirstChild(v)
							local dist = (entity.Position - waypoint.Position).magnitude
							local Time = GetTime(dist, ambruhspeed)
							local tween = game.TweenService:Create(entity, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0,false,0), {CFrame = waypoint.CFrame + ambruhheight})
							tween:Play()
							tween.Completed:Wait()
							ambruhspeed = storer
						end
					end
				end
			end
		end
	elseif ra == 2 then
		--entity.CFrame = GetLastRoom().RoomExit.CFrame + ambruhheight
                print(ra)
		for i = game.ReplicatedStorage.GameData.LatestRoom.Value, 1, -1 do
			if gruh:FindFirstChild(i) then
				local room = gruh:FindFirstChild(i)
				if room ~= nil and room:FindFirstChild("Nodes") then
					local nodes = room:FindFirstChild("Nodes")
					for v = #nodes:GetChildren(), 1, -1 do
						if nodes:FindFirstChild(v) then
							local waypoint = nodes:FindFirstChild(v)
							local dist = (entity.Position - waypoint.Position).magnitude
							local Time = GetTime(dist, ambruhspeed)
							local tween = game.TweenService:Create(entity, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0,false,0), {CFrame = waypoint.CFrame + ambruhheight})
							tween:Play()
							tween.Completed:Wait()
							ambruhspeed = storer
						end
					end
				end
			end
		end
	elseif ra == 3 then
                print(ra)
		for i = 1, game.ReplicatedStorage.GameData.LatestRoom.Value do
			if gruh:FindFirstChild(i) then
				local room = gruh:FindFirstChild(i)
				if room ~= nil and room:FindFirstChild("Nodes") then
					local nodes = room:FindFirstChild("Nodes")
					for v = 1, #nodes:GetChildren() do
						if nodes:FindFirstChild(v) then
							local waypoint = nodes:FindFirstChild(v)
							local dist = (entity.Position - waypoint.Position).magnitude
							local Time = GetTime(dist, ambruhspeed)
							local tween = game.TweenService:Create(entity, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0,false,0), {CFrame = waypoint.CFrame + ambruhheight})
							tween:Play()
							tween.Completed:Wait()
							ambruhspeed = storer
						end
					end
				end
			end
		end
		wait(2)
		for i = game.ReplicatedStorage.GameData.LatestRoom.Value, 1, -1 do
			if gruh:FindFirstChild(i) then
				local room = gruh:FindFirstChild(i)
				if room ~= nil and room:FindFirstChild("Nodes") then
					local nodes = room:FindFirstChild("Nodes")
					for v = #nodes:GetChildren(), 1, -1 do
						if nodes:FindFirstChild(v) then
							local waypoint = nodes:FindFirstChild(v)
							local dist = (entity.Position - waypoint.Position).magnitude
							local Time = GetTime(dist, ambruhspeed)
							local tween = game.TweenService:Create(entity, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0,false,0), {CFrame = waypoint.CFrame + ambruhheight})
							tween:Play()
							tween.Completed:Wait()
							ambruhspeed = storer
						end
					end
				end
			end
		end
	end
        workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]:WaitForChild("Door").ClientOpen:FireServer()
	local slam = Instance.new("Sound", entity)
	slam.Volume = 10
	slam.SoundId = "rbxassetid://1837829565"
        slam:Play()
	camShake:Shake(cameraShaker.Presets.Explosion)
        wait(1)
	entity.Anchored = false
	entity.CanCollide = false
	game.Debris:AddItem(s, 5)
	print("get rekt nub, by Obscura loler")
end

pcall(Obscura)
