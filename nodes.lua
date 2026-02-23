local STEP_DISTANCE = 8 -- Slightly smaller for tighter turns
local MAX_NODES = 12    -- Increased for complex rooms
local OFFSET_Y = -3     -- Adjusted for floor level
local ENTITY_WIDTH = 5  -- How much space the entity needs to pass

-- Helper to find the floor height at a specific position
local function getFloorHeight(pos, room)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {room}
	rayParams.FilterType = Enum.RaycastFilterType.Include
	
	local result = workspace:Raycast(pos + Vector3.new(0, 5, 0), Vector3.new(0, -15, 0), rayParams)
	return result and result.Position or pos
end

-- Checks if a path is wide enough and not blocked
local function isClearPath(startPos, endPos, obstacles)
	local direction = (endPos - startPos).Unit
	local distance = (endPos - startPos).Magnitude
	local perpendicular = Vector3.new(-direction.Z, 0, direction.X).Unit
	
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = obstacles
	rayParams.FilterType = Enum.RaycastFilterType.Include

	-- Triple-Ray Check (Center, Left, Right) to ensure width clearance
	local offsets = {
		Vector3.new(0, 0, 0),
		perpendicular * (ENTITY_WIDTH/2),
		perpendicular * -(ENTITY_WIDTH/2)
	}

	for _, off in ipairs(offsets) do
		local result = workspace:Raycast(startPos + off, direction * distance, rayParams)
		if result then return false end
	end
	
	return true
end

local function createNode(pos, parent, index)
	local node = Instance.new("Part")
	node.Name = index
	node.Shape = Enum.PartType.Ball
	node.Size = Vector3.new(1.2, 1.2, 1.2)
	node.Position = pos + Vector3.new(0, 1.5, 0) -- Raised slightly to avoid floor clipping
	node.Transparency = 1 -- Set to 0.5 to debug!
	node.Color = Color3.fromRGB(255, 100, 0)
	node.CanCollide = false
	node.Anchored = true
	node.CanQuery = false
	node.Parent = parent
end

local function generateNodesForRoom(room)
	local entrance = room:WaitForChild("RoomEntrance", 5)
	local exit = room:WaitForChild("RoomExit", 5)
	if not (entrance and exit) then return end

	local nodesFolder = room:FindFirstChild("Nodes") or Instance.new("Folder")
	nodesFolder.Name = "Nodes"
	nodesFolder:ClearAllChildren()
	nodesFolder.Parent = room

	local obstacles = {}
	for _, obj in ipairs(room:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide and obj.Transparency < 1 then
			table.insert(obstacles, obj)
		end
	end

	local currentPos = entrance.Position
	local endPos = exit.Position
	local index = 1

	-- Start with entrance node
	createNode(getFloorHeight(currentPos, room), nodesFolder, index)
	index += 1

	-- Pathfinding Loop
	local attempts = 0
	while (currentPos - endPos).Magnitude > STEP_DISTANCE and attempts < MAX_NODES do
		attempts += 1
		local directDir = (endPos - currentPos).Unit
		local nextTarget = currentPos + (directDir * STEP_DISTANCE)
		
		if not isClearPath(currentPos, nextTarget, obstacles) then
			-- Obstacle hit! Search for an alternative angle (A* lite)
			local foundAlt = false
			for angle = 15, 90, 15 do -- Check 15 degree increments
				for _, side in ipairs({1, -1}) do
					local rad = math.rad(angle * side)
					local rotatedDir = Vector3.new(
						directDir.X * math.cos(rad) - directDir.Z * math.sin(rad),
						0,
						directDir.X * math.sin(rad) + directDir.Z * math.cos(rad)
					).Unit
					
					local testPos = currentPos + (rotatedDir * STEP_DISTANCE)
					if isClearPath(currentPos, testPos, obstacles) then
						nextTarget = testPos
						foundAlt = true
						break
					end
				end
				if foundAlt then break end
			end
		end

		currentPos = getFloorHeight(nextTarget, room)
		createNode(currentPos, nodesFolder, index)
		index += 1
	end

	-- Final exit node
	createNode(getFloorHeight(endPos, room), nodesFolder, index)
end

-- Hooking it up
workspace.CurrentRooms.ChildAdded:Connect(function(room)
	task.wait(1) -- Wait for room to generate fully
	generateNodesForRoom(room)
end)

-- Initial run
for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
	generateNodesForRoom(room)
end
