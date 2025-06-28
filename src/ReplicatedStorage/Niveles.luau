local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local JSON = require(ReplicatedStorage.JSON)
local niveles = HttpService:JSONDecode(JSON).niveles


-- local DataStoreService = game:GetService("DataStoreService")
-- local ds = DataStoreService:GetDataStore("DatosDeNiveles")
-- local success, err = pcall(function()
-- 	ds:SetAsync("Niveles", niveles)
-- end)

-- if success then
-- 	print("✅ Niveles guardados correctamente en DataStore.")
-- else
-- 	warn("❌ Error al guardar niveles:", err)
-- end

return niveles
