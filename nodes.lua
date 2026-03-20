local currentRooms = workspace.CurrentRooms

local function replicate(room)
	if not room or not room.Parent then return end

	-- Internal function to handle the cloning once nodes exist
	local function setupNodes(roomNodes)
		if room:FindFirstChild("Nodes") then return end -- Already done
		
		local nodes = roomNodes:Clone()
		nodes.Name = "Nodes"
		nodes.Parent = room
		
		-- Your custom identification tags
		local valueString = Instance.new("StringValue", room)
		valueString.Name = "jiggle my ballz lsplash"
		valueString.Value = "jiggle it pls."
		
		print("Nodes replicated for Room: " .. room.Name)
	end

	-- 1. Check if they already exist
	local existingNodes = room:FindFirstChild("PathfindNodes")
	if existingNodes then
		setupNodes(existingNodes)
	end

	-- 2. Listen for them being added or changed later
	room.ChildAdded:Connect(function(child)
		if child.Name == "PathfindNodes" then
			setupNodes(child)
		end
	end)
end

-- Watch for new rooms being generated
currentRooms.ChildAdded:Connect(function(child)
	-- Only run if the child is a room (usually named by number)
	if tonumber(child.Name) or child:IsA("Model") then
		replicate(child)
	end
end)

-- Initial scan for rooms already there
for _, room in ipairs(currentRooms:GetChildren()) do
	replicate(room)
end
