local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local JSON = require(ReplicatedStorage.JSON)

return HttpService:JSONDecode(JSON).niveles
