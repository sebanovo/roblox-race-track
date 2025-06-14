local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IncrementarPuntosEvent = ReplicatedStorage:WaitForChild("IncrementarPuntosEvent")

IncrementarPuntosEvent.OnServerEvent:Connect(function(jugador, cantidad)
	local leaderstats = jugador:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local puntos = leaderstats:FindFirstChild("Puntos")
	if not puntos then return end
	puntos.Value += cantidad
end)
