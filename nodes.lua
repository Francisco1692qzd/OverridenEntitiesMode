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
		
		print("Nodes replicated for Room: " .. room.Name .. " - Found " .. #pathfindNodes:GetChildren() .. " nodes")
	end

	-- Give time for PathfindNodes to be created
	local function attemptReplication(retryCount)
		retryCount = retryCount or 0
		local maxRetries = 5
		local delayBetweenRetries = 0.5 -- seconds
		
		local existingNodes = room:FindFirstChild("PathfindNodes")
		if existingNodes then
			setupNodes(existingNodes)
		elseif retryCount < maxRetries then
			print("Waiting for PathfindNodes in " .. room.Name .. " (attempt " .. (retryCount + 1) .. "/" .. maxRetries .. ")")
			task.wait(delayBetweenRetries)
			attemptReplication(retryCount + 1)
		else
			print("Failed to find PathfindNodes in " .. room.Name .. " after " .. maxRetries .. " attempts")
			
			-- Keep listening just in case it appears later
			local connection
			connection = room.ChildAdded:Connect(function(child)
				if child.Name == "PathfindNodes" then
					setupNodes(child)
					connection:Disconnect()
				end
			end)
		end
	end
	
	-- Start the replication attempt with delay
	attemptReplication()
end

-- Watch for new rooms being generated
currentRooms.ChildAdded:Connect(function(child)
	if child:IsA("Model") or tonumber(child.Name) then
		task.wait(0.2) -- Small delay before processing new room
		replicate(child)
	end
end)

-- Initial scan for rooms already there
for _, room in ipairs(currentRooms:GetChildren()) do
	if room:IsA("Model") or tonumber(room.Name) then
		task.wait(0.1) -- Small delay between each room to prevent overwhelming
		replicate(room)
	end
end
