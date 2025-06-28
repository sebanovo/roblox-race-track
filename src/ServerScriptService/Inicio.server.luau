local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cargarNivel = require(ReplicatedStorage.CargarNivel)
local evento = ReplicatedStorage:WaitForChild("MostrarPantallaCarga")
local niveles = require(ReplicatedStorage.Niveles)

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Lista ordenada de nombres de pistas
local ordenPistas = {"PistaCuadrado", "PistaCirculo", "Pista8"}

-- Progreso de cada jugador
local progresoJugadores = {}

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


function desmontarJugador(jugador : Player)
	local humanoide = jugador.Character:FindFirstChildOfClass("Humanoid")
	if humanoide then
		humanoide.Sit = false
		task.wait(0.1)
	end
end

function cambiarPosicion(player, posicion)
	if not player.Character then
		player.CharacterAdded:Wait()
	end
	local character = player.Character
	local torso = character:WaitForChild("HumanoidRootPart")
	if not torso then
		warn("No se encontró HumanoidRootPart para "..player.Name)
		player:LoadCharacter()
	end

	torso.CFrame = CFrame.new(
		Vector3.new(
			posicion.X,
			posicion.Y,
			posicion.Z
		)
	)
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
							checkpoint.Transparency = 1

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
														local n = 1
														evento:FireClient(jugador, true)
														if not niveles[n].estaCargado then
															cargarNivel(niveles[n].nombre)
														end
														niveles[n].estaCargado = true
														task.wait(3)
														cambiarPosicion(jugador, niveles[n].jugador.posicion)
														evento:FireClient(jugador, false)
														progresoJugadores[jugador.UserId].checkpointEsperado = 1
														print("¡Felicidades! "..jugador.Name.." ha completado la pista "..pista.Name.." y avanzó a la pista "..nuevaPista)
														configurarCheckpoints("Nivel 1")
													elseif nuevaPista == "PistaCirculo" then
														local n = 2
														evento:FireClient(jugador, true)
														if not niveles[n].estaCargado then
															cargarNivel(niveles[n].nombre)
														end
														niveles[n].estaCargado = true
														task.wait(3)
														cambiarPosicion(jugador, niveles[n].jugador.posicion)
														evento:FireClient(jugador, false)
														progresoJugadores[jugador.UserId].checkpointEsperado = 1
														print("¡Felicidades! "..jugador.Name.." ha completado la pista "..pista.Name.." y avanzó a la pista "..nuevaPista)
														configurarCheckpoints("Nivel 2")
													elseif nuevaPista == "Pista8" then
														local n = 3
														evento:FireClient(jugador, true)
														if not niveles[n].estaCargado then
															cargarNivel(niveles[n].nombre)
														end
														niveles[n].estaCargado = true
														task.wait(3)
														cambiarPosicion(jugador, niveles[n].jugador.posicion)
														evento:FireClient(jugador, false)
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

local MAX_JUGADORES = 2
local jugadoresListos = 0

function iniciarJugador(jugador)
	progresoJugadores[jugador.UserId] = {
		pistaActualIndex = 1,
		checkpointEsperado = 1
	}
	jugadoresListos += 1

	if jugadoresListos == MAX_JUGADORES then
		print("Todos los jugadores están listos. Iniciando juego.")
		evento:FireClient(jugador, true)
		task.wait(3)
		cargarNivel(niveles[1].nombre)
		for _, player in ipairs(Players:GetPlayers()) do
			cambiarPosicion(player, niveles[1].jugador.posicion)
		end
		evento:FireClient(jugador, false)
		configurarCheckpoints(niveles[1].nombre)
	end
end

game.Players.PlayerAdded:Connect(function(jugador)
	jugador.CharacterAdded:Connect(function()
		iniciarJugador(jugador)
	end)
end)
