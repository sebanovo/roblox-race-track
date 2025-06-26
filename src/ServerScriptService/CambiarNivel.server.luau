local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CargarNivelEvent = ReplicatedStorage:WaitForChild("CargarNivelEvent")
local cargarNivel = require(ReplicatedStorage.CargarNivel)

CargarNivelEvent.OnServerEvent:Connect(function(_, levelName)
	cargarNivel(levelName)
end)
