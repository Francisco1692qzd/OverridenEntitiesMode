local currentRooms = workspace.CurrentRooms

local function replicate(room)
	task.wait(0.1) -- Give time for PathfindNodes to load
	
	local pathfindNodes = room:FindFirstChild("PathfindNodes")
	if not pathfindNodes then
		print("No PathfindNodes in", room.Name)
		return
	end
	
	-- Check if already replicated
	if room:FindFirstChild("Nodes") then 
		print("Already replicated", room.Name)
		return 
	end
	
	-- Clone and create
	local nodes = pathfindNodes:Clone()
	nodes.Name = "Nodes"
	nodes.Parent = room
	
	local tag = Instance.new("StringValue")
	tag.Name = "jiggle_my_ballz_lsplash"
	tag.Value = "jiggle it pls."
	tag.Parent = room
	
	print("Successfully replicated", #nodes:GetChildren(), "nodes in", room.Name)
end

-- Replicate existing rooms
for _, room in ipairs(currentRooms:GetChildren()) do
	replicate(room)
end

-- Watch for new rooms
currentRooms.ChildAdded:Connect(replicate)
