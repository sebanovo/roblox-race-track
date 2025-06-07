-- game.Players.SebastianCR000.leaderstats.Puntos.Value = 100
local DataStoreService = game:GetService("DataStoreService")
local db = DataStoreService:GetDataStore("data")
local MAXIMO_INTENTOS = 10

function playerAdded(player: Player)
	local leaderStats = Instance.new("Folder")
	leaderStats.Name = "leaderstats"
	leaderStats.Parent = player

	local puntos = Instance.new("IntValue")
	puntos.Name = "Puntos"
	puntos.Parent = leaderStats

	local succes, data = nil, nil
	local intento = 0

	while not succes do
		if intento >= MAXIMO_INTENTOS then
			error("No se pudo obtener los datos del jugador")
		end
		succes, data = pcall(db.GetAsync, db, player.UserId)

		if succes then 
			puntos.Value = data and data["Puntos"] or 0
			print("Datos obtenidos con exito")
		else 
			warn("Fallo obtener dato intento: ", intento)
			intento += 1
			wait(2)
		end
	end 
end

function playerRemoving(player)
	local leaderStats = player:FindFirstChild("leaderstats")
	local puntos = leaderStats:FindFirstChild("Puntos")

	local succes = nil
	local intento = 0

	while not succes do
		if intento >= MAXIMO_INTENTOS then
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
			wait(2)
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