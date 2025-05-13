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

function Eyes()
	local s = LoadCustomInstance("https://github.com/Francisco1692qzd/OverridenEntitiesMode/blob/main/eyes.rbxm?raw=true", workspace)
	s.Parent = workspace

	local entity = s:FindFirstChildWhichIsA("BasePart")
	entity.Parent = s
	entity.CFrame = CFrame.new((GetRoom():WaitForChild("RoomEntrance").Position + GetRoom():WaitForChild("RoomExit").Position) / 2)

	entity.Initiate:Play()
	task.delay(0.8, function()
		entity.Ambience:Play()
	end)

	local damageRange = 25
	local damagePerTick = 10
	local tickRate = 0.25

	local function isLookingAt(player, target)
		local character = player.Character
		if not character then return false end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return false end

		local directionToTarget = (target.Position - hrp.Position).Unit
		local lookVector = hrp.CFrame.LookVector

		local dot = lookVector:Dot(directionToTarget)
		return dot > 0.6 -- adjust for sensitivity of "looking"
	end

	task.spawn(function()
		while entity and entity.Parent do
			task.wait(tickRate)

			local player = game.Players.LocalPlayer
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local hrp = char and char:FindFirstChild("HumanoidRootPart")

				if hum and hrp and (hrp.Position - entity.Position).Magnitude <= damageRange then
					if isLookingAt(player, entity) then
						hum:TakeDamage(damagePerTick)
                                                entity.Attack:Play()
                                                firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
                                                        "You died to Eyes...",
                                                        "Watch For His Presence by Telling it In Its White Light...",
                                                        "Dont Look At It Or else...",
                                                        "You Know?",
                                                        "Will I see you again, Ain't i? Well... I will see you again in the next time..."
                                                }, "Blue")
					end
				end
		end
	end)
        game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait()
        s:Destroy()
end

pcall(Eyes)
