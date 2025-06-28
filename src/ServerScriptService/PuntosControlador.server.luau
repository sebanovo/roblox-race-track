-- game.Players.SebastianCR000.leaderstats.Puntos.Value = 100
local DataStoreService = game:GetService("DataStoreService")
local db = DataStoreService:GetDataStore("data")

local TOTAL_MAX_INTENTOS = 10
local posicionesRecientes = {}


local mejoresPuntajes = {}

function tareaGuardarPosicion(player: Player)
	task.spawn(function()
		while player and player.Parent do
			local character = player.Character
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root then
					posicionesRecientes[player.UserId] = root.Position
				end
			end
			task.wait(5)
		end
	end)
end


function getDataPlayer(player: Player)
	local success, data
	local intento = 0

	while not success and intento < TOTAL_MAX_INTENTOS do
		success, data = pcall(function()
			return db:GetAsync(player.UserId)
		end)

		if not success then
			warn("Fallo obtener dato intento:", intento)
			intento += 1
			task.wait(2)
		end
	end

	return typeof(data) == "table" and data or {}
end

function actualizarCampo(player: Player, campo: string, valor: any)
	local intentos = 0
	local success = false

	while not success and intentos < TOTAL_MAX_INTENTOS do
		success = pcall(function()
			local datos = db:GetAsync(player.UserId) or {}
			if not datos["Puntos"] then
				db:SetAsync(player.UserId, {Puntos = 0})	
			end
			if not datos["MejorPuntaje"] then
				db:SetAsync(player.UserId, {MejorPuntaje= 0})	
			end
			if not datos["Posicion"] then
				db:SetAsync(player.UserId, {Posicion = {x = 0, y = 0, z = 0}})
			end

			datos[campo] = valor
			db:SetAsync(player.UserId, datos)
		end)

		if not success then
			intentos += 1
			warn("⚠️ Fallo al actualizar campo '" .. campo .. "' para " .. player.Name .. " - Intento: " .. intentos)
			task.wait(2)
		end
	end

	if success then
		print("✅ Campo '" .. campo .. "' actualizado correctamente para " .. player.Name)
	else
		warn("❌ No se pudo actualizar el campo '" .. campo .. "' después de " .. intentos .. " intentos.")
	end
end

function getDataPlayer(player: Player)
	local succes, data = nil, nil
	local intento = 0

	while not succes do
		if intento >= TOTAL_MAX_INTENTOS then
			error("No se pudo obtener los datos del jugador")
		end
		succes, data = pcall(db.GetAsync, db, player.UserId)

		if succes then
			return data
		else
			warn("Fallo obtener dato intento: ", intento)
			intento += 1
			task.wait(2)
		end
	end
end

function playerAdded(player: Player)
	local leaderStats = Instance.new("Folder")
	leaderStats.Name = "leaderstats"
	leaderStats.Parent = player

	local puntos = Instance.new("IntValue")
	puntos.Name = "Puntos"
	puntos.Parent = leaderStats

	actualizarCampo(player, 'Puntos', 0)

	puntos.Value = 0
	tareaGuardarPosicion(player)
	local datos = getDataPlayer(player)
	mejoresPuntajes[player.UserId] = datos["MejorPuntaje"]
end


-- function getDataPlayer(player: Player)
-- 	local succes, data = nil, nil
-- 	local intento = 0

-- 	while not succes do
-- 		if intento >= TOTAL_MAX_INTENTOS then
-- 			error("No se pudo obtener los datos del jugador")
-- 		end
-- 		succes, data = pcall(db.GetAsync, db, player.UserId)

-- 		if succes then
-- 			return data
-- 		else
-- 			warn("Fallo obtener dato intento: ", intento)
-- 			intento += 1
-- 			task.wait(2)
-- 		end
-- 	end
-- end

function playerRemoving(player)
	local leaderStats = player:FindFirstChild("leaderstats")
	local puntos = leaderStats:FindFirstChild("Puntos")

	local succes = nil
	local intento = 0

	-- print("Informacion: ", getDataPlayer(player))
	local mejorPuntaje = mejoresPuntajes[player.UserId]
	if mejorPuntaje < puntos.Value then
		mejorPuntaje = puntos.Value
	end

	while not succes do
		if intento >= TOTAL_MAX_INTENTOS then
			error("No se pudo guardar los datos del jugador")
		end

		succes = pcall(function()
			local posicionFinal = posicionesRecientes[player.UserId] or Vector3.zero
			db:SetAsync(player.UserId, {
				Puntos =  puntos.Value,
				MejorPuntaje = mejorPuntaje,
				Posicion = {x = posicionFinal.X, y = posicionFinal.Y, z = posicionFinal.Z}
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