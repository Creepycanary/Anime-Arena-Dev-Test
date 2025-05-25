local Input = {}

--// SERVICES //--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

--// CONSTANTS //--
local PLAYER = Players.LocalPlayer

local IS_ON_MOBILE = UserInputService.TouchEnabled
local IS_ON_DESKTOP = UserInputService.MouseEnabled
local IS_ON_CONSOLE = UserInputService.GamepadEnabled

--// VARIABLES //--
local touchDelta = Vector2.new()
local selectedTouchInputs = {}

--// CONFIG //--
local GAMEPAD_DEADZONE = 0.15
local GAMEPAD_X_SENSITIVITY, GAMEPAD_Y_SENSITIVITY = 20, 15

local function IsInDynamicThumbstickArea(pos)
	local playerGui = PLAYER:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local thumbstickFrame = touchFrame and touchFrame:FindFirstChild("DynamicThumbstickFrame")

	if not thumbstickFrame then
		return false
	end

	if not touchGui.Enabled then
		return false
	end

	local posTopLeft = thumbstickFrame.AbsolutePosition
	local posBottomRight = posTopLeft + thumbstickFrame.AbsoluteSize

	return pos.X >= posTopLeft.X and pos.Y >= posTopLeft.Y and pos.X <= posBottomRight.X and pos.Y <= posBottomRight.Y
end

function CheckInput()
	if IS_ON_MOBILE then
		UserInputService.TouchStarted:Connect(function(inputObject, gameProcessedEvent)
			if not gameProcessedEvent then
				local position = inputObject.Position
				position = Vector2.new(position.X, position.Y)
				if not IsInDynamicThumbstickArea(position) then
					selectedTouchInputs[inputObject] = true
				end
			end
		end)

		UserInputService.TouchMoved:Connect(function(inputObject, gameProcessedEvent)
			if selectedTouchInputs[inputObject] then
				local delta = inputObject.Delta
				touchDelta = Vector2.new(delta.X, delta.Y)
			end
		end)

		UserInputService.TouchEnded:Connect(function(inputObject, gameProcessedEvent)
			if selectedTouchInputs[inputObject] then
				selectedTouchInputs[inputObject] = nil
			end
		end)
	elseif IS_ON_CONSOLE then
		UserInputService.InputChanged:Connect(function(inputObject, processed)
			--print("joystick moved")
			if not processed then
				IS_ON_DESKTOP = false
				if inputObject.KeyCode == Enum.KeyCode.Thumbstick2 then
					local input = inputObject.Position
					local x, y

					if input.Magnitude > GAMEPAD_DEADZONE then
						x = (input.X * GAMEPAD_X_SENSITIVITY)
						y = -(input.Y * GAMEPAD_Y_SENSITIVITY)
						--print(x, y)
					else
						x = 0
						y = 0
					end
					touchDelta = Vector2.new(x, y)
					--print(x, y)
					--print(touchDelta)
				end
			end
		end)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	-- Check if the input came from a gamepad
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		print("Gamepad button pressed:", input.KeyCode.Name)
		IS_ON_DESKTOP = false
		IS_ON_CONSOLE = true
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- Ignore input if it's already used by UI, etc.
	if gameProcessed then
		return
	end

	-- Detect keyboard input
	if input.UserInputType == Enum.UserInputType.Keyboard then
		print("Keyboard key pressed:", input.KeyCode.Name)
		IS_ON_DESKTOP = true

	-- Detect mouse button input
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		print("Left mouse button pressed")
		IS_ON_DESKTOP = true
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		print("Right mouse button pressed")
		IS_ON_DESKTOP = true
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		print("Middle mouse button pressed")
		IS_ON_DESKTOP = true
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		--print("Mouse moved to:", input.Position)
		IS_ON_DESKTOP = true
	end
end)

function Input.GetDelta()
	CheckInput()
	local temp = touchDelta
	--print(IS_ON_CONSOLE)
	if IS_ON_MOBILE then
		touchDelta = Vector2.new(0, 0)
	elseif IS_ON_DESKTOP then
		temp = UserInputService:GetMouseDelta()
	end
	return temp
end

return Input
