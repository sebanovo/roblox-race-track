local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DestruirManzanasEvent = ReplicatedStorage:WaitForChild("DestruirManzanas")

DestruirManzanasEvent.OnServerEvent:Connect(function(_, parte)
  local explosion = Instance.new("Explosion")
  explosion.Position = parte.Position
  explosion.BlastRadius = 5
  explosion.BlastPressure = 0
  explosion.DestroyJointRadiusPercent = 0
  explosion.ExplosionType = Enum.ExplosionType.NoCraters
  explosion.Parent = workspace
	parte:Destroy()
end)
