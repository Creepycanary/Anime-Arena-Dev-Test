local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local knit = require(ReplicatedStorage.Packages.knit)

local InputController = knit.CreateController({
	Name = "InputController",
})

function InputController:SetContextStateEnabled(ContextName: string, State: boolean)
	local Player = Players.LocalPlayer
	local PlayerGUI = Player.PlayerGui

	local InputContext = PlayerGUI:FindFirstChild(ContextName)
	if InputContext then
		InputContext.Enabled = State
	end
end

function initCombatInstances()
	local Player = Players.LocalPlayer
	local PlayerGUI = Player.PlayerGui

	local InputContext = PlayerGUI:WaitForChild("CombatContext")

	local M1Action = InputContext:FindFirstChild("M1Action")
	local M2Action = InputContext:FindFirstChild("M2Action")
	local Ability1Action = InputContext:FindFirstChild("Ability1Action")
	local Ability2Action = InputContext:FindFirstChild("Ability2Action")
	local UltimateAction = InputContext:FindFirstChild("UltimateAction")

	local AbilityService = knit.GetService("AbilityService")

	if M1Action and M2Action and Ability1Action and Ability2Action and UltimateAction then
		M1Action.Released:Connect(function()
			AbilityService.AbilitySignal:Fire("M1", false)
		end)

		M2Action.Released:Connect(function()
			AbilityService.AbilitySignal:Fire("M2", false)
		end)

		Ability1Action.Released:Connect(function()
			AbilityService.AbilitySignal:Fire("Ability1", false)
		end)

		Ability2Action.Released:Connect(function()
			AbilityService.AbilitySignal:Fire("Ability2", false)
		end)

		UltimateAction.Released:Connect(function()
			AbilityService.AbilitySignal:Fire("Ultimate", false)
		end)

		M1Action.Pressed:Connect(function()
			AbilityService.AbilitySignal:Fire("M1", true)
		end)

		M2Action.Pressed:Connect(function()
			AbilityService.AbilitySignal:Fire("M2", true)
		end)

		Ability1Action.Pressed:Connect(function()
			AbilityService.AbilitySignal:Fire("Ability1", true)
		end)

		Ability2Action.Pressed:Connect(function()
			AbilityService.AbilitySignal:Fire("Ability2", true)
		end)

		UltimateAction.Pressed:Connect(function()
			AbilityService.AbilitySignal:Fire("Ultimate", true)
		end)
	end
end

function initCombatActions()
	local AbilityService = knit.GetService("AbilityService")
	initCombatInstances()
	UserInputService.InputBegan:Connect(function(Input: InputObject, GPE: boolean)
		if GPE then
			return
		end
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			AbilityService.AbilitySignal:Fire("M1", true)
		end
	end)

	UserInputService.InputEnded:Connect(function(Input: InputObject, GPE: boolean)
		if GPE then
			return
		end
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			AbilityService.AbilitySignal:Fire("M1", false)
		end
	end)

	UserInputService.InputBegan:Connect(function(Input: InputObject, GPE: boolean)
		if GPE then
			return
		end
		if Input.UserInputType == Enum.UserInputType.MouseButton2 then
			AbilityService.AbilitySignal:Fire("M2", true)
		end
	end)

	UserInputService.InputEnded:Connect(function(Input: InputObject, GPE: boolean)
		if GPE then
			return
		end
		if Input.UserInputType == Enum.UserInputType.MouseButton2 then
			AbilityService.AbilitySignal:Fire("M2", false)
		end
	end)
end

function InputController:KnitStart()
	print("InputManager started")
end

function InputController:KnitInit()
	print("InputManager initialize")
	initCombatActions()
	Players.LocalPlayer.CharacterAdded:Connect(function(a0: Model)
		initCombatInstances()
	end)
end

return InputController
