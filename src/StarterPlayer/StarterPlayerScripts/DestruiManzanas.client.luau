local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local IncrementPuntos = game:GetService("ReplicatedStorage"):WaitForChild("IncrementPuntos")

local player = Players.LocalPlayer
local distanciaEnStuds = 15

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end

	local torso = character:FindFirstChild("HumanoidRootPart")
	if not torso then return end

	local origen = torso.Position
	local direccion = torso.CFrame.LookVector

	-- Obtener todas las partes etiquetadas
	local manzanasRojas = CollectionService:GetTagged("manzana-roja")
	local manzanasVerdes = CollectionService:GetTagged("manzana-verde")

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
		-- Marcar como explotado
		local tag = Instance.new("BoolValue")
		tag.Name = "Exploded"
		tag.Parent = parte

		-- Crear explosión
		local explosion = Instance.new("Explosion")
		explosion.Position = parte.Position
		explosion.BlastRadius = 5
		explosion.BlastPressure = 500000
		explosion.Parent = workspace
		
		if CollectionService:HasTag(parte, "manzana-roja") then
			IncrementPuntos:FireServer(10)
		end
		if CollectionService:HasTag(parte, "manzana-verde") then
			IncrementPuntos:FireServer(20)
		end
		parte:Destroy()
	end
end)