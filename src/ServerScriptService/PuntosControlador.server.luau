-- game.Players.SebastianCR000.leaderstats.Puntos.Value = 100
local DataStoreService = game:GetService("DataStoreService")
local db = DataStoreService:GetDataStore("data")

local TOTAL_MAX_INTENTOS = 10

function playerAdded(player: Player)
	local leaderStats = Instance.new("Folder")
	leaderStats.Name = "leaderstats"
	leaderStats.Parent = player

	local puntos = Instance.new("IntValue")
	puntos.Name = "Puntos"
	puntos.Parent = leaderStats

	local succes = false
	local intento = 0

	while not succes do
		if intento >= TOTAL_MAX_INTENTOS then
			error("No se pudo eliminar los datos del jugador")
		end

		-- Intentamos eliminar los datos del jugador
		succes = pcall(function()
			db:RemoveAsync(player.UserId)
		end)

		if succes then
			print("Datos eliminados con éxito")
		else
			warn("Fallo al eliminar datos. Intento: ", intento)
			intento += 1
			task.wait(2)
		end
	end

	-- Reiniciamos los valores a cero
	puntos.Value = 0
end

function playerRemoving(player)
	local leaderStats = player:FindFirstChild("leaderstats")
	local puntos = leaderStats:FindFirstChild("Puntos")

	local succes = nil
	local intento = 0

	while not succes do
		if intento >= TOTAL_MAX_INTENTOS then
			error("No se pudo guardar los datos del jugador")
		end

		succes = pcall(function()
			db:SetAsync(player.UserId, {
				Puntos =  puntos.Value
			})
		end)
		if succes then
			print("Datos guardados con exito")
		else
			warn("Fallo al guardar datos intento: ", intento)
			intento += 1
			task.wait(2)
		end
	end
end

function bindToClose() 
	for _, player in ipairs(game.Players:GetPlayers()) do
		playerRemoving(player)
	end
end

game.Players.PlayerAdded:Connect(playerAdded)
game.Players.PlayerRemoving:Connect(playerRemoving)
game:BindToClose(bindToClose)