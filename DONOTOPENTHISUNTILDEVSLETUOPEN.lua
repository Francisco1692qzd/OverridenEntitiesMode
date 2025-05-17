local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mainUI = player:WaitForChild("PlayerGui"):WaitForChild("MainUI")
local initiator = mainUI:WaitForChild("Initiator")
local main_Game = require(initiator:WaitForChild("Main_Game"))

-- Mensagem inicial
main_Game.caption("Overriden Mode Executed, Good Luck Fellow player " .. char.Name .. "...", 4)

-- BoolValue pra evitar execuções múltiplas
local bool = workspace:FindFirstChild("hardcoreInit")
if not bool then
	bool = Instance.new("BoolValue")
	bool.Name = "hardcoreInit"
	bool.Value = false
	bool.Parent = workspace
end

if bool.Value then return end  -- Já iniciado? Cai fora

-- Tentativa segura de carregar nodes
pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/nodes.lua"))()
end)

-- Espera até a primeira mudança de sala
game.ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom").Changed:Wait()

-- Ativa o modo
bool.Value = true
main_Game.caption("Overriden Initiated.", 4)
task.wait(3)
main_Game.caption("Good luck!", 4)

-- Função segura pra spawnar entidades
local function safeSpawn(url)
	local success, err = pcall(function()
		loadstring(game:HttpGet(url))()
	end)
	if not success then
		warn("❌ Falha ao carregar: " .. url .. "\nErro: " .. tostring(err))
	end
end

-- Condição comum de spawn
local function canSpawn()
	return not workspace:FindFirstChild("SeekMovingNewClone") 
		and not workspace:FindFirstChild("SeekMoving") 
		and not game.ReplicatedStorage:WaitForChild("FloorReplicated"):WaitForChild("SeekMusic").IsPlaying
		and not workspace.CurrentRooms:FindFirstChild("50")
end

-- Entidades e seus tempos
local entities = {
	{url = "https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/obscura.lua", min = 50, max = 120, waitForRoom = true},
	{url = "https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/trauma.lua", min = 80, max = 170},
	{url = "https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/crackstep.lua", min = 140, max = 200},
	{url = "https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/eyes.lua", min = 100, max = 140, waitForRoom = true},
	{url = "https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/hunger.lua", min = 60, max = 120}
}

-- Cria todas as corrotinas de spawn
for _, entity in ipairs(entities) do
	task.defer(function()
		while task.wait(math.random(entity.min, entity.max)) do
			if canSpawn() then
				if entity.waitForRoom then
					game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait()
				end
				safeSpawn(entity.url)
			end
		end
	end)
end
