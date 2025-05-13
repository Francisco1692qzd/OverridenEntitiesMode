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

	local function NormalizeGitHubURL(url)
		if url:match("^https://github.com/.+%.rbxm$") and not url:find("?raw=true") then
			return url .. "?raw=true"
		end
		return url
	end

	while task.wait() and not model do
		if type(source) == "number" or tostring(source):match("^%d+$") then
			print("🔄 Trying to load model from Asset ID: " .. tostring(source))
			local success, result = pcall(function()
				return game:GetObjects("rbxassetid://" .. tostring(source))[1]
			end)

			if success and result then
				model = result
			else
				print("❌ Failed to load asset ID " .. tostring(source))
				task.wait(0.5)
			end

		elseif type(source) == "string" and source:match("^https?://") and source:match("%.rbxm") then
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
				print("❌ Failed to load from URL. Retrying...")
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

			print("✅ Model " .. model.Name .. " loaded into " .. model.Parent:GetFullName())
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

function Hunger()
	local s = LoadCustomInstance("https://github.com/Francisco1692qzd/OverridenEntitiesMode/blob/main/shockeryellow.rbxm?raw=true", workspace)
	local entity = s and s:FindFirstChild("Shockeeer")

	if not entity then
		warn("❌ Entity 'Shockeeer' not found in model!")
		return
	end

	entity.Name = "Hunger"
	entity.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame * CFrame.new(0, 0, -15)

	local playSound = entity:FindFirstChild("PlaySound")
	if playSound then
		playSound.TimePosition = 0
		playSound:Play()
	end

	local horrorScream = entity:FindFirstChild("HORROR SCREAM 15")

	local player = game.Players.LocalPlayer
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	local lookingStart = nil
	local runService = game:GetService("RunService")
	local tweenService = game:GetService("TweenService")
	local debris = game:GetService("Debris")

	local connection
	connection = runService.RenderStepped:Connect(function()
		if not entity or not entity:IsDescendantOf(s) then
			if connection then connection:Disconnect() end
			return
		end

		local cameraLook = camera.CFrame.LookVector
		local toEntity = (entity.Position - camera.CFrame.Position).Unit
		local dot = cameraLook:Dot(toEntity)

		if dot > 0.7 then
			if not lookingStart then
				lookingStart = tick()
			elseif tick() - lookingStart >= 3 then
				-- Efeito de avanço e dano
				local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local goal = {CFrame = root.CFrame + Vector3.new(0, 0, -3)}
				local tween = tweenService:Create(entity, tweenInfo, goal)

				if horrorScream then
					horrorScream:Play()
                                        task.delay(1.6, function()
                                                horrorScream:Stop()
                                        end)
				end

				tween:Play()
				tween.Completed:Connect(function()
					if hum then
						hum.Health = hum.Health - 25
                                                camShake:Shake(cameraShaker.Presets.Explosion)
                                                firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
                                                        "You died to Hunger...",
                                                        "He is Just Like Shocker...",
                                                        "Dont Look at it Or It Stuns you!"
                                                }, "Blue")
                                                game.ReplicatedStorage:FindFirstChild("Player_".. game.Players.LocalPlayer.Character.Name).Total.DeathCause = "Hunger"
					end
				end)

                                entity.Anchored = false
			        entity.CanCollide = false
				-- Desconectar após ataque
				if connection then connection:Disconnect() end
			end
		else
			-- Não tá olhando: sumir
			lookingStart = nil
			entity.Anchored = false
			entity.CanCollide = false
			debris:AddItem(entity, 5)
		end
	end)
end

pcall(Hunger)
