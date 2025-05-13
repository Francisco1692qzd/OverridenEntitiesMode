local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local mainUI = player:WaitForChild("PlayerGui"):WaitForChild("MainUI")
local initiator = mainUI:WaitForChild("Initiator")
local main_Game = require(initiator:WaitForChild("Main_Game"))

-- Mensagem de inicialização
main_Game.caption("Overriden Mode Executed, Good Luck Fellow player ".. char.Name .."...", 4)

-- Criação segura do BoolValue de controle
local bool = workspace:FindFirstChild("hardcoreInit")
if not bool then
	bool = Instance.new("BoolValue")
	bool.Name = "hardcoreInit"
	bool.Value = false
	bool.Parent = workspace
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/lightReplacer.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/nodes.lua"))()

if bool.Value then return end

-- Espera a mudança da sala
game.ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom").Changed:Wait()

-- Se o modo hardcore já iniciou, não faz nada
if bool.Value then return end

-- Ativa modo hardcore
bool.Value = true
main_Game.caption("Overriden Initiated.", 4)
task.wait(3)
main_Game.caption("Good luck!", 4)

-- Função auxiliar pra spawnar entidades com proteção
local function safeSpawn(url)
	local success, err = pcall(function()
		loadstring(game:HttpGet(url))()
	end)
	if not success then
		warn("❌ Falha ao carregar: " .. url .. "\nErro: " .. tostring(err))
	end
end

-- Condição comum pra todas as entidades
local function canSpawn()
	return not workspace:FindFirstChild("SeekMovingNewClone") 
		and not workspace:FindFirstChild("SeekMoving") 
		and not game.ReplicatedStorage:WaitForChild("FloorReplicated"):WaitForChild("SeekMusic").IsPlaying
end

-- Spawn automático das entidades com delays aleatórios
task.spawn(function()
	while task.wait(math.random(50, 120)) do
		if canSpawn() then
			safeSpawn("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/obscura.lua")
		end
	end
end)

task.spawn(function()
	while task.wait(math.random(80, 170)) do
		if canSpawn() then
			safeSpawn("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/trauma.lua")
		end
	end
end)

task.spawn(function()
	while task.wait(math.random(140, 200)) do
		if canSpawn() then
			safeSpawn("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/crackstep.lua")
		end
	end
end)

task.spawn(function()
	while task.wait(math.random(30, 60)) do
		if canSpawn() then
			safeSpawn("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/eyes.lua")
		end
	end
end)

task.spawn(function()
	while task.wait(math.random(60, 120)) do
		if canSpawn() then
			safeSpawn("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/hunger.lua")
		end
	end
end)
