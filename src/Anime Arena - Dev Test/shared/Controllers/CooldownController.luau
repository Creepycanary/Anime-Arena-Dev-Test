local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local CooldownController = Knit.CreateController({ Name = "CooldownController" })

local cooldowns = {} -- [Id] = EndTime
local updateCallbacks = {} -- [Id] = {callback1, callback2, ...}

function CooldownController:IsOnCooldown(id: string): boolean
	return cooldowns[id] and os.clock() < cooldowns[id]
end

function CooldownController:GetRemaining(id: string): number
	return cooldowns[id] and math.max(0, cooldowns[id] - os.clock()) or 0
end

function CooldownController:OnCooldownUpdated(id: string, callback: (remaining: number) -> ())
	updateCallbacks[id] = updateCallbacks[id] or {}
	table.insert(updateCallbacks[id], callback)
end

function CooldownController:KnitStart()
	local CooldownService = Knit.GetService("CooldownService")

	CooldownService.CooldownUpdated:Connect(function(id, duration)
		local endTime = os.clock() + duration
		if duration <= 0 then
			cooldowns[id] = nil
		else
			cooldowns[id] = endTime
		end

		if updateCallbacks[id] then
			for _, callback in pairs(updateCallbacks[id]) do
				task.spawn(callback, self:GetRemaining(id))
			end
		end
	end)
end

return CooldownController
