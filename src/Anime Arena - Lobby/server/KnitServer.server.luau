local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local knit = require(ReplicatedStorage.Packages.knit)

for _, v in ipairs(ServerStorage.Services:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Service$") then
		require(v)
	end
end

knit.Start()
	:andThen(function()
		print("Knit Started")
	end)
	:catch(warn)
