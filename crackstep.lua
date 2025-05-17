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

function GetLastRoom()
	local gruh = workspace.CurrentRooms
	return gruh[game.ReplicatedStorage.GameData.LatestRoom.Value + 1]
end

local moduleScripts = {
	Module_Events = require(game.ReplicatedStorage.ClientModules.Module_Events),
	Main_Game = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
}

function CrackStep()
	local s = LoadCustomInstance("https://github.com/Francisco1692qzd/OverridenEntitiesMode/blob/main/crackstep.rbxm?raw=true", workspace)
	s.Parent = workspace
	local entity = s:FindFirstChildWhichIsA("BasePart")
	local killed = false
	local ambruhheight = Vector3.new(0,2,0)
	local ambruhspeed = 65
	local DEF_SPEED = 99999
	local storer = ambruhspeed
	camShake:Shake(cameraShaker.Presets.Earthquake)
	local colorLight = {Color = Color3.fromRGB(255,255,255)}
	local info = TweenInfo.new(1)
	for i, v in pairs(workspace.CurrentRooms:GetDescendants()) do
		if v:IsA("Light") then
			game.TweenService:Create(v, info, colorLight):Play()
			if v.Parent.Name == "LightFixture" then
				game.TweenService:Create(v.Parent, info, colorLight):Play()
			end
		end
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
	wait(1)
	spawn(function()
		while entity ~= nil and entity.Parent and s ~= nil and s.Parent do
			wait(0.1)
			local v = game.Players.LocalPlayer

			if v.Character then
				local humanoid = v.Character:FindFirstChild("Humanoid")
				local hrp = v.Character:FindFirstChild("HumanoidRootPart")

				if humanoid and hrp then
					local canSee = canSeeTarget(v.Character, 65)
					local hiding = v.Character:GetAttribute("Hiding")
					local moving = humanoid.MoveDirection.Magnitude > 0

					-- Kill if hiding and CrackStep sees you
					if canSee and hiding then
						humanoid:TakeDamage(100)
						v.Character:SetAttribute("Alive", false)
						v.Character:SetAttribute("Stunned", true)

						firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
							"You died to who you call CrackStep...",
							"It can check every moment that you Hide or move...",
							"Maybe try not Hiding or Not Moving next time?"
						}, "Blue")

						task.delay(0.3, function()
							local stats = game.ReplicatedStorage.GameStats:FindFirstChild("Player_" .. v.Character.Name)
							if stats then
								stats.Total.DeathCause = "CrackStep"
							end
						end)
					end

					-- Kill if moving and CrackStep sees you
					if canSee and moving then
						humanoid:TakeDamage(100)
						v.Character:SetAttribute("Alive", false)
						v.Character:SetAttribute("Stunned", true)

						firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
							"You died to who you call CrackStep...",
							"It can check every moment that you Hide or move...",
							"Maybe try not Hiding or Not Moving next time?"
						}, "Blue")
						
						task.delay(0.3, function()
							local stats = game.ReplicatedStorage.GameStats:FindFirstChild("Player_" .. v.Character.Name)
							if stats then
								stats.Total.DeathCause = "CrackStep"
							end
						end)
					end

					-- Camera shake if close
					if (entity.Position - hrp.Position).Magnitude <= 80 then
						camShake:ShakeOnce(10, 25, 0, 2, 1, 6)
					end
				end
			end
		end
	end)
	ambruhspeed = DEF_SPEED
	local gruh = workspace.CurrentRooms
	for i = 1, game.ReplicatedStorage.GameData.LatestRoom.Value do
		if gruh:FindFirstChild(i) then
			local room = gruh[i]
			if room ~= nil and room:FindFirstChild("Nodes") then
				local nodes = room:FindFirstChild("Nodes")
				for v = 1, #nodes:GetChildren() do
					if nodes:FindFirstChild(v) then
						local waypoint = nodes[v]
						local dist = (entity.Position - waypoint.Position).magnitude
						local fakejays = game.TweenService:Create(entity, TweenInfo.new(GetTime(dist, ambruhspeed), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0,false,0), {CFrame = waypoint.CFrame + ambruhheight})
						fakejays:Play()
						fakejays.Completed:Wait()
						ambruhspeed = storer
						if room.Name == tostring(game.ReplicatedStorage.GameData.LatestRoom.Value) then
							room:WaitForChild("Door").ClientOpen:FireServer()
						end
					end
				end
			end
		end
	end

	workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]:WaitForChild("Door").ClientOpen:FireServer()
	entity.Anchored = false
	entity.CanCollide = false
	game.Debris:AddItem(s, 5)
end


pcall(CrackStep)
