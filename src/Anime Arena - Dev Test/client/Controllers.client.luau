local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
print("Hello world, from client!")

for _, v in ipairs(ReplicatedStorage.Shared.Controllers:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match("Controller$") then
		require(v)
	end
end

knit.Start()
	:andThen(function()
		print("Knit started on client")
	end)
	:catch(warn)
