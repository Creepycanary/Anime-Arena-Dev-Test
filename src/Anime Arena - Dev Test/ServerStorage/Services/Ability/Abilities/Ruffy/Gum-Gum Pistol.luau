local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local GumGumPistol = {}

local Config = {}
Config.Cooldown = 0.75

function GumGumPistol.Activate(player)
	local CooldownService = knit.GetService("CooldownService")
	-- Placeholder logic
	print(player.Name .. " used " .. script.Name)

	-- Insert ability logic here later

	CooldownService:StartCooldown(player, script.Name, Config.Cooldown)
end

return GumGumPistol
