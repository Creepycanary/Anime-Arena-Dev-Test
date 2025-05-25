local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local CharacterController = knit.CreateController({
	Name = "CharacterController",
})

function CharacterController:KnitStart()
	print("CharacterController started")
end

function CharacterController:KnitInit()
	print("CharacterController initialize")
end

return CharacterController
