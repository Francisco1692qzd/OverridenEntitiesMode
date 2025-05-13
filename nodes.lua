local STEP_DISTANCE = 9
local MAX_NODES = 9
local OFFSET = Vector3.new(0, -3, 0)

-- Only big collidable stuff
local function getRoomObstacles(room)
	local obstacles = {}
	for _, obj in ipairs(room:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide == true then
			if obj.Size.Magnitude > 2 then -- Filters out tiny stuff
				table.insert(obstacles, obj)
			end
		end
	end
	return obstacles
end

-- Raycast check
local function isPathBlocked(startPos, endPos, obstacles)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = obstacles
	rayParams.FilterType = Enum.RaycastFilterType.Whitelist
	rayParams.IgnoreWater = true

	local direction = (endPos - startPos).Unit
	local distance = (endPos - startPos).Magnitude
	local result = workspace:Raycast(startPos, direction * distance, rayParams)
	return result ~= nil
end

-- Creates a single invisible node part
local function createNode(pos, parent, index)
	local node = Instance.new("Part")
	node.Name = tostring(index)
	node.Shape = Enum.PartType.Ball
	node.Size = Vector3.new(1, 1, 1)
	node.Position = pos + OFFSET
	node.Transparency = 1
	node.CanCollide = false
	node.Anchored = true
	node.CanQuery = false
	node.CanTouch = false
	node.Parent = parent
end

-- Main node generation logic
local function generateNodesForRoom(room)
	local entrance = room:FindFirstChild("RoomEntrance")
	local exit = room:FindFirstChild("RoomExit")
	if not (entrance and exit) then return end

	local nodesFolder = room:FindFirstChild("Nodes") or Instance.new("Folder")
	nodesFolder.Name = "Nodes"
	nodesFolder:ClearAllChildren()
	nodesFolder.Parent = room

	local startPos = entrance.Position
	local endPos = exit.Position
	local obstacles = getRoomObstacles(room)

	local direction = (endPos - startPos).Unit
	local distance = (endPos - startPos).Magnitude
	local currentPos = startPos
	local perpendicular = Vector3.new(-direction.Z, 0, direction.X)
	local index = 1
	local totalSteps = math.min(math.floor(distance / STEP_DISTANCE), MAX_NODES)

	for i = 1, totalSteps do
		local nextPos = currentPos + direction * STEP_DISTANCE

		-- Only curve if blocked
		if isPathBlocked(currentPos, nextPos, obstacles) then
			local found = false
			for offsetAmount = 1, 4 do
				for _, side in ipairs({1, -1}) do
					local offset = perpendicular * offsetAmount * STEP_DISTANCE * side
					local tryPos = nextPos + offset
					if not isPathBlocked(currentPos, tryPos, obstacles) then
						nextPos = tryPos
						found = true
						break
					end
				end
				if found then break end
			end

			if not found then
				-- No clear path? skip this step
				continue
			end
		end

		createNode(nextPos, nodesFolder, index)
		currentPos = nextPos
		index += 1
	end

	createNode(endPos, nodesFolder, index)
end

-- All existing rooms
for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
	generateNodesForRoom(room)
end

-- New rooms added
workspace.CurrentRooms.ChildAdded:Connect(function(room)
	room.ChildAdded:Wait()
	task.wait(0.5)
	generateNodesForRoom(room)
end)
