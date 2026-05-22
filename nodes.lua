local currentRooms = workspace.CurrentRooms

local function replicate(room)
	if not room or not room.Parent then return end

	-- Internal function to handle the cloning once nodes exist
	local function setupNodes(pathfindNodes)
		-- Check if Nodes already exists AND has children
		local existingNodes = room:FindFirstChild("Nodes")
		
		if existingNodes then
			-- If Nodes folder exists but is empty, delete it
			if #existingNodes:GetChildren() == 0 then
				print("Empty Nodes folder found in " .. room.Name .. ", replacing...")
				existingNodes:Destroy()
			else
				-- Nodes folder already has content, skip replication
				print("Nodes already exist in " .. room.Name .. ", skipping")
				return
			end
		end
		
		-- Clone the PathfindNodes folder/parts
		local nodes = pathfindNodes:Clone()
		nodes.Name = "Nodes"
		nodes.Parent = room
		
		-- Make sure parts are visible/replicable
		for _, descendant in ipairs(nodes:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true -- Keep them in place
			end
		end
		
		-- Your custom identification tags
		local valueString = Instance.new("StringValue")
		valueString.Name = "jiggle_my_ballz_lsplash"
		valueString.Value = "jiggle it pls."
		valueString.Parent = room
		
		print("Nodes replicated for Room: " .. room.Name .. " - Found " .. #nodes:GetChildren() .. " nodes")
	end

	-- 1. Check if PathfindNodes already exists IN the room
	local existingNodes = room:FindFirstChild("PathfindNodes")
	if existingNodes then
		setupNodes(existingNodes)
	else
		print("Waiting for PathfindNodes in room: " .. room.Name)
	end

	-- 2. Listen for PathfindNodes being added later
	local connection
	connection = room.ChildAdded:Connect(function(child)
		if child.Name == "PathfindNodes" then
			setupNodes(child)
			connection:Disconnect()
		end
	end)
end

-- Watch for new rooms being generated
currentRooms.ChildAdded:Connect(function(child)
	if child:IsA("Model") or tonumber(child.Name) then
		replicate(child)
	end
end)

-- Initial scan for rooms already there
for _, room in ipairs(currentRooms:GetChildren()) do
	if room:IsA("Model") or tonumber(room.Name) then
		replicate(room)
	end
end
