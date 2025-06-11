local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeLevel = ReplicatedStorage:WaitForChild("CambiarNivelEvent")
local iniciarCheckpoints = require(ReplicatedStorage.CheckpointController)
local cambiarNivel = require(ReplicatedStorage.CambiarNivel)

ChangeLevel.OnServerEvent:Connect(function(player, levelName)
	cambiarNivel(player, levelName)
	iniciarCheckpoints()
end)


