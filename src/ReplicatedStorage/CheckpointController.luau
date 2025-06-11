local ReplicatedStorage = game:GetService("ReplicatedStorage")
local niveles = require(ReplicatedStorage.Niveles)
local cambiarNivel = require(ReplicatedStorage.CambiarNivel)

function iniciarCheckpoints()
	local Checkpoints = nil

	for _, value in pairs(workspace:GetChildren()) do
		if value:IsA("Folder") and value.Name == "Nivel 1" then
			Checkpoints = value.PistaCuadrado.Checkpoints
		end
	end

	local progresoJugadores = {}

	local listaCheckpoints = {}
	for _, checkpoint in pairs(Checkpoints:GetChildren()) do
		if checkpoint:IsA("BasePart") and checkpoint:FindFirstChild("CheckpointID") then
			table.insert(listaCheckpoints, {
				part = checkpoint,
				id = checkpoint.CheckpointID.Value
			})
			checkpoint.Transparency = 1
			checkpoint.CanCollide = false
		end
	end

	-- Ordenar por ID
	table.sort(listaCheckpoints, function(a, b)
		return a.id < b.id
	end)

	-- Función para activar el próximo checkpoint de un jugador
	local function activarProximoCheckpoint(jugador)
		local progreso = progresoJugadores[jugador] or 0
		local siguienteCheckpoint = progreso + 1

		if siguienteCheckpoint > #listaCheckpoints then
			print(jugador.Name .. " ha completado toda la pista")
			cambiarNivel(jugador, niveles[2].nombre)
			return
		end

		local checkpoint = listaCheckpoints[siguienteCheckpoint].part
		checkpoint.Transparency = 0.5

		print("Checkpoint "..siguienteCheckpoint.." activado para "..jugador.Name)
	end

	-- Inicializar checkpoints para jugadores nuevos
	game.Players.PlayerAdded:Connect(function(jugador)
		progresoJugadores[jugador] = 0
		activarProximoCheckpoint(jugador)

		-- Limpiar cuando el jugador abandone
		jugador.CharacterRemoving:Connect(function()
			progresoJugadores[jugador] = nil
		end)
	end)

	-- Conectar eventos para checkpoints
	for _, data in ipairs(listaCheckpoints) do
		local checkpoint = data.part
		local numeroCheckpoint = data.id

		checkpoint.Touched:Connect(function(hit)
			local jugador = game.Players:GetPlayerFromCharacter(hit.Parent)
			if not jugador then 
				return
			end

			if not progresoJugadores[jugador] then
				progresoJugadores[jugador] = 0
			end

			-- Verificar si es el checkpoint correcto
			if progresoJugadores[jugador] ~= numeroCheckpoint - 1 then
				return
			end

			print(jugador.Name .. " completó CORRECTAMENTE el checkpoint " .. numeroCheckpoint)

			-- Ocultar y destruir este checkpoint
			checkpoint.Transparency = 1

			-- Actualizar progreso
			progresoJugadores[jugador] = numeroCheckpoint

			-- Activar siguiente checkpoint
			activarProximoCheckpoint(jugador)
		end)
	end

	-- Activar primer checkpoint para jugadores ya conectados
	for _, jugador in pairs(game.Players:GetPlayers()) do
		progresoJugadores[jugador] = 0
		activarProximoCheckpoint(jugador)
	end
end
return iniciarCheckpoints