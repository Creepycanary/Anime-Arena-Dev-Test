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

	self.Client.AbilitySignal:Connect(function(Player: Player, Ability: string)
		local Data = CharactersData[CharacterService.PlayersCharacters[Player]]
		--print(Data)
		--print(Player.Name .. " fired ability : " .. Data[Ability])
		--print(ServerStorage.Services.Ability.Abilities[Data.Name][Data[Ability]])
		require(ServerStorage.Services.Ability.Abilities[Data.Name][Data[Ability]]).Activate(Player)
	end)
end

return AbilityService
