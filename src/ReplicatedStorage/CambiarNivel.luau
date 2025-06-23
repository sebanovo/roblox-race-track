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

	local function cambiarPosicion(player)
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
				nivelEncontrado.jugador.posicion.X,
				nivelEncontrado.jugador.posicion.Y,
				nivelEncontrado.jugador.posicion.Z
			)
		)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		cambiarPosicion(player)
	end
end

return cambiarNivel