--local CollectionService = game.CollectionService
---- Add a tag

--local manzanasRojas = CollectionService:GetTagged("ManzanaRoja")
--local manzanasVerdes = CollectionService:GetTagged("ManzanaVerde")

--local destruibles = {}
--local id = 1

---- Manzanas rojas
--for _, manzana in ipairs(manzanasRojas) do
--	table.insert(destruibles, {
--		id = id,
--		tipo = "manzana",
--		color = "roja",
--		valor = 10,
--		posicion = {
--			X = manzana.Position.X,
--			Y = manzana.Position.Y,
--			Z = manzana.Position.Z
--		}
--	})
--	id += 1
--end

---- Manzanas verdes
--for _, manzana in ipairs(manzanasVerdes) do
--	table.insert(destruibles, {
--		id = id,
--		tipo = "manzana",
--		color = "verde",
--		valor = 20,
--		posicion = {
--			X = manzana.Position.X,
--			Y = manzana.Position.Y,
--			Z = manzana.Position.Z
--		}
--	})
--	id += 1
--end

--local HttpService = game:GetService("HttpService")

--local json = HttpService:JSONEncode(destruibles)
--print(json)