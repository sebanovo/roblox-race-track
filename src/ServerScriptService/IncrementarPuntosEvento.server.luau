local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IncrementPuntos = ReplicatedStorage:WaitForChild("IncrementPuntos")

IncrementPuntos.OnServerEvent:Connect(function(jugador, cantidad)
	local leaderstats = jugador:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local puntos = leaderstats:FindFirstChild("Puntos")
	if not puntos then return end
	puntos.Value += cantidad
end)
