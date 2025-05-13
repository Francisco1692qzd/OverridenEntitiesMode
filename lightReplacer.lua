--// Lights

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
			print("🔄 Trying to load model from Asset ID: " .. tostring(source))
			local success, result = pcall(function()
				return game:GetObjects("rbxassetid://" .. tostring(source))[1]
			end)

			if success and result then
				model = result
			else
				print("❌ [LoadCustomInstance]: Failed to load asset ID. Retrying...")
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
				print("❌ [LoadCustomInstance]: Failed to load from URL. Retrying...")
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
			print("✅ Loaded model: " .. model.Name .. " into " .. model.Parent:GetFullName())
		end
	end

	return model
end

function ReplaceAllLights()
	local fakeLightTemplate = LoadCustomInstance("https://github.com/Francisco1692qzd/OverridenEntitiesMode/blob/main/Light.rbxm?raw=true")
	if not fakeLightTemplate then
		warn("❌ Could not load light template.")
		return
	end
        local currentRoomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
        local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(currentRoomNum))
        if currentRoom then
		local assets = currentRoom:FindFirstChild("Assets")
		if assets then
			local light_Fixtures = assets:FindFirstChild("Light_Fixtures")
			if light_Fixtures then
				print("💡 Replacing lights in: " .. currentRoom.Name)
				for _, lightModel in pairs(light_Fixtures:GetChildren()) do
					if lightModel:IsA("Model") and lightModel.Name:find("Light") then
						local pos = lightModel:GetPivot()
						lightModel:Destroy()
						local newLight = fakeLightTemplate:Clone()
						newLight.Parent = light_Fixtures
						newLight.Name = "LightFixture"
						newLight:PivotTo(pos)
					end
				end
			end
		end
	end

	fakeLightTemplate:Destroy()
end

pcall(ReplaceAllLights)

-- Optional: replace lights in new rooms dynamically
workspace.CurrentRooms.ChildAdded:Connect(function(room)
	ReplaceAllLights()
end)
