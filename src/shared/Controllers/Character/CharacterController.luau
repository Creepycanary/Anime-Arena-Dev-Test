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
	local AbilityService = knit.GetService("AbilityService")
	task.wait(5)
	AbilityService.AbilitySignal:Fire("Ability1")
	print("Fired Ability")
end

return CharacterController
