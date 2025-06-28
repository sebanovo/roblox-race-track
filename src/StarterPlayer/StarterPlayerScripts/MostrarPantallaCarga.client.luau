local ReplicatedStorage = game:GetService("ReplicatedStorage")
local evento = ReplicatedStorage:WaitForChild("MostrarPantallaCarga")

-- Crea una pantalla de carga simple
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "PantallaCarga"
loadingGui.ResetOnSpawn = false

local texto = Instance.new("TextLabel")
texto.Size = UDim2.new(1, 0, 1, 0)
texto.BackgroundColor3 = Color3.new(0, 0, 0)
texto.TextColor3 = Color3.new(1, 1, 1)
texto.TextScaled = true
texto.Text = "Cargando nivel..."
texto.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
texto.Parent = loadingGui

evento.OnClientEvent:Connect(function(mostrar)
	if mostrar then
		loadingGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	else
		loadingGui.Parent = nil
	end
end)
