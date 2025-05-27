local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CharactersData = require(ServerStorage.Services.Characters.CharactersData)
local knit = require(ReplicatedStorage.Packages.knit)

local AbilityService = knit.CreateService({
	Name = "AbilityService",

	Client = {
		AbilitySignal = knit.CreateSignal(),
	},
})

function AbilityService:KnitStart()
	print("AbilityService started")
end

function AbilityService:KnitInit()
	print("AbilityService initialize")
	local CharacterService = knit.GetService("CharacterService")

	local CooldownService = knit.GetService("CooldownService")

	self.Client.AbilitySignal:Connect(function(Player: Player, Ability: string, Held: boolean)
		local Data = CharactersData[CharacterService.PlayersCharacters[Player]]

		if CooldownService:IsOnCooldown(Player, Data[Ability]) then
			return
		end

		require(ServerStorage.Services.Ability.Abilities[Data.Name][Data[Ability]]).Activate(Player, Held)
	end)
end

return AbilityService
