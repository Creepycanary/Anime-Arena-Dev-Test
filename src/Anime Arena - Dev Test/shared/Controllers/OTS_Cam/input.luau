local Input = {}

--// SERVICES //--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// CONSTANTS //--
local PLAYER = Players.LocalPlayer

--// VARIABLES //--
local touchDelta = Vector2.new()
local selectedTouchInputs = {}
local inputType = nil -- "Mobile", "Console", "Desktop"

--// CONFIG //--
local GAMEPAD_DEADZONE = 0.15
local GAMEPAD_X_SENSITIVITY, GAMEPAD_Y_SENSITIVITY = 20, 15

local function IsInDynamicThumbstickArea(pos)
	local playerGui = PLAYER:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local thumbstickFrame = touchFrame and touchFrame:FindFirstChild("DynamicThumbstickFrame")

	if not thumbstickFrame or not touchGui.Enabled then
		return false
	end

	local posTopLeft = thumbstickFrame.AbsolutePosition
	local posBottomRight = posTopLeft + thumbstickFrame.AbsoluteSize

	return pos.X >= posTopLeft.X and pos.Y >= posTopLeft.Y and pos.X <= posBottomRight.X and pos.Y <= posBottomRight.Y
end

--// Input Detection Setup //--
local function SetupInputConnections()
	-- MOBILE
	UserInputService.TouchStarted:Connect(function(inputObject, gameProcessedEvent)
		if inputType ~= "Mobile" then
			inputType = "Mobile"
		end
		if not gameProcessedEvent then
			local pos = inputObject.Position
			if not IsInDynamicThumbstickArea(Vector2.new(pos.X, pos.Y)) then
				selectedTouchInputs[inputObject] = true
			end
		end
	end)

	UserInputService.TouchMoved:Connect(function(inputObject)
		if selectedTouchInputs[inputObject] then
			local delta = inputObject.Delta
			touchDelta = Vector2.new(delta.X, delta.Y)
		end
	end)

	UserInputService.TouchEnded:Connect(function(inputObject)
		selectedTouchInputs[inputObject] = nil
	end)

	-- CONSOLE
	UserInputService.InputChanged:Connect(function(inputObject, processed)
		if
			inputObject.UserInputType == Enum.UserInputType.Gamepad1
			and inputObject.KeyCode == Enum.KeyCode.Thumbstick2
		then
			if inputType ~= "Console" then
				inputType = "Console"
			end

			local input = inputObject.Position
			if input.Magnitude > GAMEPAD_DEADZONE then
				touchDelta = Vector2.new(input.X * GAMEPAD_X_SENSITIVITY, -input.Y * GAMEPAD_Y_SENSITIVITY)
			else
				touchDelta = Vector2.new(0, 0)
			end
		end
	end)

	-- DETECT INPUT TYPE CHANGE
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if
			input.UserInputType == Enum.UserInputType.Keyboard
			or input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3
		then
			inputType = "Desktop"
		elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
			inputType = "Console"
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inputType = "Desktop"
		end
	end)
end

SetupInputConnections()

function Input.GetDelta()
	local temp = touchDelta
	if inputType == "Mobile" then
		touchDelta = Vector2.new(0, 0)
	elseif inputType == "Desktop" then
		temp = UserInputService:GetMouseDelta()
	end
	return temp
end

return Input
