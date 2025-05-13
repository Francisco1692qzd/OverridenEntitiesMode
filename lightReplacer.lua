--// Lights
function GetAllRooms()
    local rooms = nil
    for i, v in pairs(workspace.CurrentRooms:GetChildren()) do
        rooms = v
    end
end

function GetAddedRooms()
    local addedRoom = nil
    workspace.CurrentRooms.ChildAdded:Connect(function(child)
        wait(0.5)
        addedRoom = child
    end)
end

