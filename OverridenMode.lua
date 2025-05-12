local player = game.Players.LocalPlayer
local char = player.Character
local mainUI = player.PlayerGui.MainUI
local initiator = mainUI.Initiator
local main_Game = require(initiator.Main_Game)
main_Game.caption("Overriden Mode Executed, Good Luck Fellow player ".. char.Name, 4)
