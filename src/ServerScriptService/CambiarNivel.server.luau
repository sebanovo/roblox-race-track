local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CambiarNivelEvent = ReplicatedStorage:WaitForChild("CambiarNivelEvent")
local cambiarNivel = require(ReplicatedStorage.CambiarNivel)

CambiarNivelEvent.OnServerEvent:Connect(function(_, levelName)
	cambiarNivel(levelName)
end)
