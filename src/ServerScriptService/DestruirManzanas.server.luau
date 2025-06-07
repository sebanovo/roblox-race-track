local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DestruirManzanasEvent = ReplicatedStorage:WaitForChild("DestruirManzanas")

DestruirManzanasEvent.OnServerEvent:Connect(function(_, parte)
  local explosion = Instance.new("Explosion")
  explosion.Position = parte.Position
  explosion.BlastRadius = 5
  explosion.BlastPressure = 500000
  explosion.Parent = workspace
	parte:Destroy()
end)
