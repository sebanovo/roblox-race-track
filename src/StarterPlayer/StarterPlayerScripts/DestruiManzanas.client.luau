local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IncrementarPuntosEvent = ReplicatedStorage:WaitForChild("IncrementarPuntosEvent")
local DestruirManzanasEvent = ReplicatedStorage:WaitForChild("DestruirManzanas")

local player = Players.LocalPlayer
local distanciaEnStuds = 15

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end

	local cabeza = character:FindFirstChild("Head")
	if not cabeza then return end

	local origen = cabeza.Position
	local direccion = cabeza.CFrame.LookVector

	-- Obtener todas las partes etiquetadas
	local manzanasRojas = CollectionService:GetTagged("ManzanaRoja")
	local manzanasVerdes = CollectionService:GetTagged("ManzanaVerde")

	-- Unir ambas listas en una sola tabla
	local todasLasManzanas = {}
	for _, m in ipairs(manzanasRojas) do
		table.insert(todasLasManzanas, m)
	end
	for _, m in ipairs(manzanasVerdes) do
		table.insert(todasLasManzanas, m)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = todasLasManzanas
	raycastParams.FilterType = Enum.RaycastFilterType.Include

	local rayo = workspace:Raycast(origen, direccion * distanciaEnStuds, raycastParams)
	if not rayo then 
		return
	end
	
	local parte = rayo.Instance
	if parte and parte:IsA("BasePart") and not parte:FindFirstChild("Exploded") then
		if CollectionService:HasTag(parte, "ManzanaRoja") then
			IncrementarPuntosEvent:FireServer(10)
		end
		if CollectionService:HasTag(parte, "ManzanaVerde") then
			IncrementarPuntosEvent:FireServer(20)
		end
		DestruirManzanasEvent:FireServer(parte);
	end
end)