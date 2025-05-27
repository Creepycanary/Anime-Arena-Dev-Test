local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local GumGumPistol = {}

local Config = {
	Cooldown = 5.2,
	MaxChargeTime = 3, -- max seconds for full charge
	MinChargeTime = 0.2,
}

-- Tracks when the player started holding
local HoldStartTimes = {}

function GumGumPistol.Activate(player, isHeld)
	local CooldownService = knit.GetService("CooldownService")

	if isHeld then
		-- Player just pressed the key (started holding)
		if CooldownService:IsOnCooldown(player, script.Name) then
			return
		end
		print(player.Name .. " started holding " .. script.Name)
		HoldStartTimes[player] = tick()
	else
		local startTime = HoldStartTimes[player]
		if not startTime then
			return
		end -- They never started holding

		HoldStartTimes[player] = nil
		local heldDuration = tick() - startTime

		local clamped = math.clamp(heldDuration, Config.MinChargeTime, Config.MaxChargeTime)

		print(player.Name .. " released " .. script.Name .. " after " .. clamped .. "s")

		-- Run the actual ability logic here
		-- You can adjust the effect based on how long they held if you tracked time

		CooldownService:StartCooldown(player, script.Name, Config.Cooldown)
	end
end

return GumGumPistol
