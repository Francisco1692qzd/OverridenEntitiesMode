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

function Trauma()
    local s = LoadCustomInstance("https://github.com/Francisco1692qzd/OverridenEntitiesMode/blob/main/taraumar.rbxm?raw=true", workspace)
    s.Parent = workspace
    local entity = s:FindFirstChildWhichIsA("BasePart")
    local killed = false
    local currentRoom = GetRoom()
    moduleScripts.Module_Events.flicker(currentRoom, 2)
    local ambruhheight = Vector3.new(0,1,0)
    local ambruhspeed = 130
    local DEF_SPEED = 99999
    local storer = ambruhspeed
    entity.CFrame = GetLastRoom().RoomExit.CFrame + ambruhheight
    local function GetTime(Dist, Speed)
        return Dist / Speed
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
    wait(4)
    spawn(function()
        while entity ~= nil and entity.Parent and s ~= nil and s.Parent do wait(0.2)
            local v = game.Players.LocalPlayer
            if v.Character ~= nil and not v.Character:GetAttribute("Hiding") then
                if canSeeTarget(v.Character, 50) then
                    v.Character:WaitForChild("Humanoid"):TakeDamage(100)
                    firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
                          "You died to Trauma...",
                          "Use what you've learned with Rush and Ambush!",
                          "This Mob has no pattern to it"
                    }, "Blue")
                end
            end
            if v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") and (entity.Position - v.Character:FindFirstChild("HumanoidRootPart").Position).magnitude <= 100 then
                camShake:ShakeOnce(20, 20, 0.2, 1)
            end
        end
    end)

    ambruhspeed = DEF_SPEED
    local gruh = workspace.CurrentRooms
    for i = game.ReplicatedStorage.GameData.LatestRoom.Value, 1, -1 do
        if gruh:FindFirstChild(i) then
            local room = gruh[i]
            if room ~= nil and room:FindFirstChild("Nodes") then
                local nodes = room:FindFirstChild("Nodes")
                for v = #nodes:GetChildren(), 1, -1 do
                    if nodes:FindFirstChild(v) then
                        local waypoint = nodes[v]
                        local dist = (entity.Position - waypoint.Position).magnitude
                        local tween = game.TweenService:Create(entity, TweenInfo.new(GetTime(dist, ambruhspeed), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0,false,0), {CFrame = waypoint.CFrame + ambruhheight})
                        tween:Play()
                        tween.Completed:Wait()
                        ambruhspeed = storer
                    end
                end
            end
        end
    end
    entity.Anchored = false
    entity.CanCollide = false
    game.Debris:AddItem(s, 5)
end

pcall(Trauma)
