local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local niveles = require(ReplicatedStorage.Niveles)

local carpetaNivelActual = nil

function cambiarNivel(levelName: string)
	if carpetaNivelActual then
		carpetaNivelActual:Destroy()
	end

	local nivelEncontrado
	for _, nivel in ipairs(niveles) do
		if nivel.nombre == levelName then
			nivelEncontrado = nivel
			break
		end
	end

	if not nivelEncontrado then
		error("No se encontró el nivel con nombre: " .. levelName)
		return
	end

	carpetaNivelActual = Instance.new("Folder")
	carpetaNivelActual.Name = nivelEncontrado.nombre
	carpetaNivelActual.Parent = Workspace

	local Destruibles = ServerStorage:FindFirstChild("Destruibles")
	for _, objeto in ipairs(nivelEncontrado.pista.destruibles) do
		local destruible = Destruibles:FindFirstChild(objeto.nombre)

		if not destruible then
			error("No se encontró el modelo para el destruible: " .. objeto.nombre)
		end

		local destruibleClon = destruible:Clone()
		destruibleClon.Name = objeto.nombre
		destruibleClon.Punto.Value = objeto.valor
		destruibleClon.CFrame = CFrame.new(
			objeto.posicion.X,
			objeto.posicion.Y,
			objeto.posicion.Z
		)

		destruibleClon.Parent = carpetaNivelActual
	end

	local goKart = ServerStorage:WaitForChild("Go-Karts"):FindFirstChild("Go-Kart")
	if not goKart then
		error ("No se encontro el goKart")
	end

	if not goKart.PrimaryPart  then
		error("El kart no tiene PrimaryPart")
	end

	local goKartClon = goKart:Clone()
	goKartClon.Name = "Go-Kart"
	goKartClon.Parent = carpetaNivelActual

	goKartClon:PivotTo(CFrame.new(
		nivelEncontrado.vehiculo.posicion.X,
		nivelEncontrado.vehiculo.posicion.Y,
		nivelEncontrado.vehiculo.posicion.Z
	))

	local pista = ServerStorage:WaitForChild("Pistas"):FindFirstChild(nivelEncontrado.pista.nombre)

	if not pista  then
		error("No se encontró la pista: " .. nivelEncontrado.pista.nombre)
	end

	local pistaClon = pista:Clone()
	pistaClon:MoveTo(Vector3.new(
		nivelEncontrado.pista.posicion.X,
		nivelEncontrado.pista.posicion.Y,
		nivelEncontrado.pista.posicion.Z
	))
	pistaClon.Parent = carpetaNivelActual

	local Players = game:GetService("Players")

	local function teleportarJugador(player)
    -- 1. Verificar y esperar por el personaje
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    local character = player.Character
    
    -- 2. Esperar por el HumanoidRootPart (con timeout)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5) -- Espera máximo 5 segundos
    
    if not humanoidRootPart then
        warn("No se encontró HumanoidRootPart para "..player.Name)
        player:LoadCharacter() -- Fuerza respawn si no se encuentra
        return false
    end
    
    -- 3. Desmontar de cualquier asiento
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        humanoid.Sit = false
        task.wait(0.5) -- Pequeña espera para asegurar desmontaje
    end
    
    -- 4. Verificar que tenemos posición destino válida
    if not nivelEncontrado or not nivelEncontrado.jugador or not nivelEncontrado.jugador.posicion then
        warn("Datos de posición destino inválidos")
        return false
    end
    
    -- 5. Realizar teleportación
    local destino = CFrame.new(
        Vector3.new(
            nivelEncontrado.jugador.posicion.X,
            nivelEncontrado.jugador.posicion.Y,
            nivelEncontrado.jugador.posicion.Z
        )
    )
    
    humanoidRootPart.CFrame = destino
    
    -- 6. Opcional: Forzar actualización de posición
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        task.wait()
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    return true
end

	-- -- local Players = game:GetService("Players")
	-- local Players = game.Players
	-- for _, player in pairs(Players:GetPlayers()) do
	-- 	local character = player.Character
	-- 	if not character then
	-- 		error("No se encontró el personaje del jugador")
	-- 	end
	-- 	local torso = character:FindFirstChildOfClass("HumanoidRootPart")
	-- 	if not torso  then
	-- 		error("No se encontró el HumanoidRootPart del personaje")
	-- 	end
	-- 	-- Desmontar jugadores
	-- 	if torso and torso.SeatPart then
	-- 		torso.Sit = false
	-- 	end

	-- 	torso.CFrame = CFrame.new(
	-- 		Vector3.new(
	-- 			nivelEncontrado.jugador.posicion.X,	
	-- 			nivelEncontrado.jugador.posicion.Y,
	-- 			nivelEncontrado.jugador.posicion.Z
	-- 		),
	-- 		Vector3.new(0, 1, 0)
	-- 	)
	-- end
	local function teleportarTodos()
  	for _, player in ipairs(Players:GetPlayers()) do
					local success, err = pcall(function()
							teleportarJugador(player)
					end)
					
					if not success then
							warn("Error al teleportar "..player.Name..": "..tostring(err))
							-- Intento alternativo: respawn completo
							pcall(function()
									player:LoadCharacter()
							end)
					end
		end
	end

	  teleportarTodos()
end

return cambiarNivel