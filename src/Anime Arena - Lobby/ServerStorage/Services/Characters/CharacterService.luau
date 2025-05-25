local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local CharacterService = knit.CreateService({
	Name = "CharacterService",

	PlayersCharacters = {},

	Client = {},
})

function CharacterService:ChangeCharacter(Player: Player, CharacterName: string)
	print("Changed " .. Player.Name .. "'s Character to : " .. CharacterName)
	self.PlayersCharacters[Player] = CharacterName
	Player:SetAttribute("Character", CharacterName)
end

function CharacterService:KnitStart()
	print("CharacterService started")
end

function CharacterService:KnitInit()
	print("CharacterService initialize")

	for _, v in Players:GetPlayers() do
		self:ChangeCharacter(v, "Ruffy")
	end

	Players.PlayerAdded:Connect(function(Player: Player)
		self:ChangeCharacter(Player, "Ruffy")
	end)

	Players.PlayerRemoving:Connect(function(Player: Player)
		self.PlayersCharacters[Player] = nil
	end)
end

return CharacterService
