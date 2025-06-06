local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ChangeLevel = ReplicatedStorage.ChangeLevel

local Destruibles = ReplicatedStorage.Destruibles
local niveles = require(ReplicatedStorage.Niveles)

local carpetaNivelActual

ChangeLevel.OnServerEvent:Connect(function(player, levelName)
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

	for _, objeto in ipairs(nivelEncontrado.pista.destruibles) do
		local destruible = Destruibles:FindFirstChild(objeto.tipo .. "-" .. objeto.color)

		if not destruible then
			error("No se encontró el modelo para el color: " .. objeto.color) 
		end

		local clon = destruible:Clone()
		clon.Name = objeto.tipo .. "-" .. objeto.color
		clon.CFrame = CFrame.new(
			objeto.posicion.X,
			objeto.posicion.Y,
			objeto.posicion.Z
		)
		clon.Parent = carpetaNivelActual
	end

	local goKart = ReplicatedStorage:WaitForChild("Go-Karts"):FindFirstChild("Go-Kart")
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

	local pista = ReplicatedStorage:WaitForChild("Pistas"):FindFirstChild(nivelEncontrado.pista.nombre)

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

	local character = player.Character
	if not character then
		error("No se encontró el personaje del jugador")
	end
	local torso = character:FindFirstChild("HumanoidRootPart")
	if not torso  then
		error("No se encontró el HumanoidRootPart del personaje")
	end

	torso.CFrame = CFrame.new(
		Vector3.new(
			nivelEncontrado.jugador.posicion.X,	
			nivelEncontrado.jugador.posicion.Y,
			nivelEncontrado.jugador.posicion.Z
		),
		Vector3.new(0, 1, 0)
	)
end)


