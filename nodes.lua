local latestRoom = game.ReplicatedStorage.GameData.LatestRoom
local currentRooms = workspace.CurrentRooms
local function replicate(room)
	if room ~= nil and room.Parent ~= nil then
		local roomNodes = room:WaitForChild("PathfindNodes", 5)
		local nodes = roomNodes:Clone()
		if not room:FindFirstChild("Nodes") then
			nodes.Parent = room
			nodes.Name = "Nodes"
		end
		local valueString = "StringValue"
		valueString.Name = "jiggle my ballz lsplash"
		valueString.Value = "jiggle it pls."
	end
end
currentRooms.ChildAdded:Connect(function(child)
	if child.Name == child.Name then
		replicate(child)
		print("ahhhhhhhhh my ballz are jiggly")
	end
end)
