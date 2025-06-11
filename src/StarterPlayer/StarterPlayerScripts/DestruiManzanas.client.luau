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
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("Destruible")
	raycastParams.FilterType = Enum.RaycastFilterType.Include

	local rayo = workspace:Raycast(origen, direccion * distanciaEnStuds, raycastParams)
	if not rayo then
		return
	end

	local parte = rayo.Instance
	if parte and parte:IsA("BasePart") and not parte:FindFirstChild("Exploded") then
		local tag = Instance.new("BoolValue")
		tag.Name = "Exploded"
		tag.Parent = parte

		IncrementarPuntosEvent:FireServer(parte.Punto.Value)
		DestruirManzanasEvent:FireServer(parte);
	end
end)