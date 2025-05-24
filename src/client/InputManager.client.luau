local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputModule = require(ReplicatedStorage.Shared.Modules.InputModule)

local NewAction = InputModule.New("UI", "Interact", {
	KeyboardBinding = { Enum.KeyCode.E },
	GamepadBinding = { Enum.KeyCode.ButtonY },
}, 0)

local Connection = NewAction:Connect(function()
	print("Hi")
end)
