local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local CooldownService = Knit.CreateService({
	Name = "CooldownService",
	Client = {
		CooldownUpdated = Knit.CreateSignal(), -- RemoteSignal to update client
	},
})

local playersCooldowns = {} -- [Player] = { [CooldownId] = EndTime }

function CooldownService:StartCooldown(player: Player, id: string, duration: number)
	playersCooldowns[player] = playersCooldowns[player] or {}

	local now = os.clock()
	local endTime = now + duration

	playersCooldowns[player][id] = endTime

	-- Notify client
	self.Client.CooldownUpdated:Fire(player, id, duration)

	-- Use task.delay to avoid memory leaks/yielding
	task.delay(duration, function()
		-- Only clear if still the same cooldown (not overwritten)
		if playersCooldowns[player] and playersCooldowns[player][id] == endTime then
			playersCooldowns[player][id] = nil
			self.Client.CooldownUpdated:Fire(player, id, 0)
		end
	end)
end

function CooldownService:IsOnCooldown(player: Player, id: string): boolean
	local endTime = playersCooldowns[player] and playersCooldowns[player][id]
	return endTime and os.clock() < endTime
end

function CooldownService:GetRemaining(player: Player, id: string): number
	local endTime = playersCooldowns[player] and playersCooldowns[player][id]
	return endTime and math.max(0, endTime - os.clock()) or 0
end

function CooldownService.Client:IsOnCooldown(player, id)
	return self.Server:IsOnCooldown(player, id)
end

function CooldownService.Client:GetRemaining(player, id)
	return self.Server:GetRemaining(player, id)
end

function CooldownService:KnitInit()
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		playersCooldowns[player] = nil -- Cleanup
	end)
end

return CooldownService
