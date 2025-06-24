local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cambiarNivel = require(ReplicatedStorage.CambiarNivel)
-- local niveles = require(ReplicatedStorage.Niveles)

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Lista ordenada de nombres de pistas
local ordenPistas = {"PistaCuadrado", "PistaCirculo", "Pista8"}

-- Progreso de cada jugador
local progresoJugadores = {}

local function iniciarJugador(jugador)
	progresoJugadores[jugador.UserId] = {
		pistaActualIndex = 1,
		checkpointEsperado = 1
	}
end

local function getTotalCheckpoints(pistaNombre)
	local pista = ServerStorage.Pistas:FindFirstChild(pistaNombre)
	if not pista then return 0 end

	local checkpointsFolder = pista:FindFirstChild("Checkpoints")
	if not checkpointsFolder then return 0 end

	local total = 0
	for _, checkpoint in ipairs(checkpointsFolder:GetChildren()) do
		local idValue = checkpoint:FindFirstChild("CheckpointID")
		if idValue and idValue:IsA("IntValue") then
			total += 1
		end
	end
	return total
end

game.Players.PlayerAdded:Connect(function(jugador)
	iniciarJugador(jugador)
	jugador.CharacterAdded:Connect(function()
		iniciarJugador(jugador)
	end)
	print("Jugadores añadidos")
  cambiarNivel("Nivel 1")
end)

function desmontarJugador(jugador : Player)
	local humanoide = jugador.Character:FindFirstChildOfClass("Humanoid")
	if humanoide then
		humanoide.Sit = false
		task.wait(0.1)
	end
end

-- Configurar checkpoints para todas las pistas en Workspace
function configurarCheckpoints(folder)
	local nivel1 = workspace:WaitForChild(folder)

	for _, pistaNombre in ipairs(ordenPistas) do
		local pista = nivel1:FindFirstChild(pistaNombre)
		if pista and pista:IsA("Model") then
			local checkpointsFolder = pista:FindFirstChild("Checkpoints")
			if checkpointsFolder then
				local totalCheckpoints = getTotalCheckpoints(pista.Name)

				for _, checkpoint in ipairs(checkpointsFolder:GetChildren()) do
					if checkpoint:IsA("BasePart") and checkpoint:FindFirstChild("CheckpointID") then
						local idValue = checkpoint.CheckpointID.Value

						-- Validación del ID del checkpoint
						if idValue < 1 or idValue > totalCheckpoints then
							warn("Checkpoint "..idValue.." en pista "..pista.Name.." es inválido.")
						else
							print("Checkpoint "..idValue.." en pista "..pista.Name.." es válido.")

							-- Configurar propiedades físicas
							checkpoint.CanCollide = false
							checkpoint.Anchored = true

							-- Conectar evento Touched
							checkpoint.Touched:Connect(function(hit)
								-- Verificar si es un jugador
								local character = hit.Parent
								local humanoid = character:FindFirstChildOfClass("Humanoid") or
									(character:IsA("Model") and character:FindFirstChild("Humanoid"))

								if humanoid then
									local jugador = Players:GetPlayerFromCharacter(humanoid.Parent)
									if jugador then
										print("Checkpoint" .. checkpoint.CheckpointID.Value .. "tocado por: "..jugador.Name)
										local progreso = progresoJugadores[jugador.UserId]
										if not progreso then
											print("Progreso no encontrado para el jugador: "..jugador.Name)
											return
										end
										-- Verificar pista actual
										local pistaActual = ordenPistas[progreso.pistaActualIndex]
										if pista.Name ~= pistaActual then return end

										-- Verificar checkpoint esperado
										if idValue == progreso.checkpointEsperado then
											progreso.checkpointEsperado += 1

											-- Verificar si completó todos los checkpoints
											if progreso.checkpointEsperado > totalCheckpoints then
												progreso.pistaActualIndex += 1
												progreso.checkpointEsperado = 1
												local nuevaPista = ordenPistas[progreso.pistaActualIndex]

												desmontarJugador(jugador)	
												if nuevaPista then
													if nuevaPista == "PistaCuadrado" then
														cambiarNivel("Nivel 1")
														task.wait(1)
														progresoJugadores[jugador.UserId].checkpointEsperado = 1
														print("¡Felicidades! "..jugador.Name.." ha completado la pista "..pista.Name.." y avanzó a la pista "..nuevaPista)
														configurarCheckpoints("Nivel 1")
													elseif nuevaPista == "PistaCirculo" then
														cambiarNivel("Nivel 2")
														task.wait(1) 
														progresoJugadores[jugador.UserId].checkpointEsperado = 1
														print("¡Felicidades! "..jugador.Name.." ha completado la pista "..pista.Name.." y avanzó a la pista "..nuevaPista)
														configurarCheckpoints("Nivel 2")
													elseif nuevaPista == "Pista8" then
														cambiarNivel("Nivel 3")
														task.wait(1) 
														progresoJugadores[jugador.UserId].checkpointEsperado = 1
														print("¡Felicidades! "..jugador.Name.." ha completado la pista "..pista.Name.." y avanzó a la pista "..nuevaPista)
														configurarCheckpoints("Nivel 3")
													end
													print(progresoJugadores[jugador.UserId].pistaActualIndex)
													print(progresoJugadores[jugador.UserId].checkpointEsperado)

													print(jugador.Name.." avanzó a "..nuevaPista)
												else
													print(jugador.Name.." completó todas las pistas!")
												end
											end
										end
									end
								end
							end)
						end
					end
				end

				print("Pista "..pista.Name.." tiene "..totalCheckpoints.." checkpoints.")
			else
				print("Pista "..pista.Name.." no tiene folder Checkpoints")
			end
		else
			print("Pista "..pistaNombre.." no encontrada en Workspace/Nivel 1")
		end
	end
end

configurarCheckpoints("Nivel 1")