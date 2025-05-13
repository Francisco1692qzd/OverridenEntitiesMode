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

function Hunger()
	local s = LoadCustomInstance("https://github.com/Francisco1692qzd/OverridenEntitiesMode/blob/main/shockeryellow.rbxm?raw=true", workspace)
	local entity = s:FindFirstChild("Shockeeer")

	if not entity then
		warn("❌ Entity 'Shockeeer' not found in model!")
		return
	end

  entity.CFrame = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0,0,-15)
  entity.PlaySound.TimePosition = 0
  entity.PlaySound:Play()

	local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	local lookingStart = nil

	game:GetService("RunService").RenderStepped:Connect(function()
		if not entity or not entity:FindFirstChild("PrimaryPart") then return end

		local directionToEntity = (entity.PrimaryPart.Position - root.Position).Unit
		local playerLookVector = root.CFrame.LookVector
		local dot = directionToEntity:Dot(playerLookVector)

		-- Tá olhando? (dot perto de 1 = olhando)
		if dot > 0.7 then
			if not lookingStart then
				lookingStart = tick()
			elseif tick() - lookingStart >= 4 then
				-- TWEEN PRA FRENTE E DANO!
				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local goal = {CFrame = root.CFrame + Vector3.new(0, 0, -3)}
				local tween = game:GetService("TweenService"):Create(entity.PrimaryPart, tweenInfo, goal)
        entity["HORROR SCREAM 15"]:Play()
				tween:Play()

				tween.Completed:Connect(function()
					if hum then hum.Health = hum.Health - 50 end
				end)
			end
		else
			-- Não tá olhando: sumir
			lookingStart = nil

			entity.Anchored = false
      entity.CanCollide = false

			game:GetService("Debris"):AddItem(entity, 5)
		end
	end)
end

pcall(Hunger)
