--// SERVICES //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

--// CONSTANTS //--
local PLAYER = Players.LocalPlayer

local SHOULDER_DIRECTION = { RIGHT = 1, LEFT = -1 }
local VERTICAL_ANGLE_LIMITS = NumberRange.new(-45, 45)

local IS_ON_DESKTOP = UserInputService.MouseEnabled

--// MODULES //--
local Input = require(script.Parent.input)

--// VARIABLES //--
local Character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local knit = require(ReplicatedStorage.Packages.knit)

local OTS_CamController = knit.CreateController({
	Name = "OTS_CamController",
})

--// CONFIG //--
OTS_CamController.CameraSettings = {
	Default = {
		Field_Of_View = 70,
		Offset = Vector3.new(2.5, 2.5, 8),
		Mouse_Sensitivity_X = 3,
		Mouse_Sensitivity_Y = 3,
		Touch_Sensitivity_X = 3,
		Touch_Sensitivity_Y = 3,
		Gamepad_Sensitivity_X = 10,
		Gamepad_Sensitivity_Y = 10,
		Lerp_Speed = 0.5,
		Align_Character = true,
		Lock_Mouse = true,
		Shoulder_Direction = SHOULDER_DIRECTION.RIGHT,
	},

	Zoomed = {
		Field_Of_View = 40,
		Offset = Vector3.new(1.5, 1.5, 6),
		Mouse_Sensitivity_X = 1.5,
		Mouse_Sensitivity_Y = 1.5,
		Touch_Sensitivity_X = 1.5,
		Touch_Sensitivity_Y = 1.5,
		Gamepad_Sensitivity_X = 5,
		Gamepad_Sensitivity_Y = 5,
		Lerp_Speed = 0.5,
		Align_Character = true,
		Lock_Mouse = true,
		Shoulder_Direction = SHOULDER_DIRECTION.RIGHT,
	},
}

--// PROPERTIES //--
local SavedCameraSettings: table
local SavedMouseBehavior: Enum.MouseBehavior

local CameraWasEnabled: boolean
local CameraMode: string

OTS_CamController.HorizontalAngle = 0
OTS_CamController.VerticalAngle = 0
OTS_CamController.ShoulderDirection = 1

OTS_CamController.IsCharacterAligned = false
OTS_CamController.IsMouseLocked = false
OTS_CamController.IsEnabled = false

--// FUNCTIONS //--

local function Lerp(x, y, a)
	return x + (y - x) * a
end

-- Saves the current Camera's settings
-- Called before enabling the OTS Camera
local function saveDefaultCamera()
	local currentCamera = workspace.CurrentCamera
	SavedCameraSettings = {
		FieldOfView = currentCamera.FieldOfView,
		CameraSubject = currentCamera.CameraSubject,
		CameraType = currentCamera.CameraType,
	}
	SavedMouseBehavior = UserInputService.MouseBehavior
end
--

-- Resets Player's Camera settings to original settings before Enabling
local function loadDefaultCamera()
	local currentCamera = workspace.CurrentCamera
	for setting, value in pairs(SavedCameraSettings) do
		currentCamera[setting] = value
	end
end

-- Returns Delta based on Input method
local function getDelta()
	local delta = Input.GetDelta()

	local xSensitivity, ySensitivity
	if UserInputService.GamepadEnabled then
		xSensitivity = OTS_CamController.CameraSettings[CameraMode].Gamepad_Sensitivity_X
		ySensitivity = OTS_CamController.CameraSettings[CameraMode].Gamepad_Sensitivity_Y
	elseif UserInputService.TouchEnabled then
		xSensitivity = OTS_CamController.CameraSettings[CameraMode].Touch_Sensitivity_X
		ySensitivity = OTS_CamController.CameraSettings[CameraMode].Touch_Sensitivity_Y
	else
		xSensitivity = OTS_CamController.CameraSettings[CameraMode].Mouse_Sensitivity_X
		ySensitivity = OTS_CamController.CameraSettings[CameraMode].Mouse_Sensitivity_Y
	end

	return Vector2.new(delta.X * xSensitivity, delta.Y * ySensitivity)
end
--

local function configureStateForEnabled()
	saveDefaultCamera()
	CameraMode = "Default"
	OTS_CamController.SetCharacterAlignment(OTS_CamController.CameraSettings[CameraMode].Align_Character)
	OTS_CamController.LockMouse(OTS_CamController.CameraSettings[CameraMode].Lock_Mouse)
	OTS_CamController.ShoulderDirection = OTS_CamController.CameraSettings[CameraMode].Shoulder_Direction

	--// Calculate angles //--
	local cameraCFrame = workspace.CurrentCamera.CFrame
	local x, y, z = cameraCFrame:ToOrientation()
	local horizontalAngle = y
	local verticalAngle = x
	----

	OTS_CamController.HorizontalAngle = horizontalAngle
	OTS_CamController.VerticalAngle = verticalAngle
end

local function configureStateForDisabled()
	OTS_CamController.SetCharacterAlignment(false)
	loadDefaultCamera()
	UserInputService.MouseBehavior = SavedMouseBehavior
	OTS_CamController.HorizontalAngle = 0
	OTS_CamController.VerticalAngle = 0
end

--
-- Main function which modifies the Camera
local function updateCamera()
	local currentCamera = workspace.CurrentCamera
	local activeCameraSettings = OTS_CamController.CameraSettings[CameraMode]

	currentCamera.CameraType = Enum.CameraType.Scriptable

	--// Moves camera based on Input //--
	local inputDelta = getDelta()
	--print(inputDelta)
	OTS_CamController.HorizontalAngle -= inputDelta.X / currentCamera.ViewportSize.X
	OTS_CamController.VerticalAngle -= inputDelta.Y / currentCamera.ViewportSize.Y
	OTS_CamController.VerticalAngle = math.rad(
		math.clamp(math.deg(OTS_CamController.VerticalAngle), VERTICAL_ANGLE_LIMITS.Min, VERTICAL_ANGLE_LIMITS.Max)
	)
	----

	local humanoidRootPart = Character ~= nil and Character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart ~= nil then -- Disable if Player dies
		currentCamera.FieldOfView =
			Lerp(currentCamera.FieldOfView, activeCameraSettings.Field_Of_View, activeCameraSettings.Lerp_Speed)

		--// Address shoulder direction //--
		local offset = activeCameraSettings.Offset
		offset = Vector3.new(offset.X * OTS_CamController.ShoulderDirection, offset.Y, offset.Z)
		----

		--// Calculate new camera cframe //--
		local newCameraCFrame = CFrame.new(humanoidRootPart.Position)
			* CFrame.Angles(0, OTS_CamController.HorizontalAngle, 0)
			* CFrame.Angles(OTS_CamController.VerticalAngle, 0, 0)
			* CFrame.new(offset)

		newCameraCFrame = currentCamera.CFrame:Lerp(newCameraCFrame, activeCameraSettings.Lerp_Speed)
		----

		--// Raycast for obstructions //--
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { Character }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local raycastResult =
			workspace:Raycast(humanoidRootPart.Position, newCameraCFrame.p - humanoidRootPart.Position, raycastParams)
		----

		--// Address obstructions if any //--
		if raycastResult ~= nil then
			local obstructionDisplacement = (raycastResult.Position - humanoidRootPart.Position)
			local obstructionPosition = humanoidRootPart.Position
				+ (obstructionDisplacement.Unit * (obstructionDisplacement.Magnitude - 0.1))
			local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = newCameraCFrame:GetComponents()
			newCameraCFrame = CFrame.new(
				obstructionPosition.x,
				obstructionPosition.y,
				obstructionPosition.z,
				r00,
				r01,
				r02,
				r10,
				r11,
				r12,
				r20,
				r21,
				r22
			)
		end
		----

		--// Address character alignment //--
		if activeCameraSettings.Align_Character == true then
			local newHumanoidRootPartCFrame = CFrame.new(humanoidRootPart.Position)
				* CFrame.Angles(0, OTS_CamController.HorizontalAngle, 0)
			humanoidRootPart.CFrame =
				humanoidRootPart.CFrame:Lerp(newHumanoidRootPartCFrame, activeCameraSettings.Lerp_Speed / 2)
		end
		----

		--print(newCameraCFrame)
		currentCamera.CFrame = newCameraCFrame
	else
		OTS_CamController.Disable()
		CameraWasEnabled = true
	end
end
----

--// METHODS //--

function OTS_CamController.SetCharacterAlignment(aligned: boolean)
	Humanoid.AutoRotate = not aligned
	OTS_CamController.IsCharacterAligned = aligned
end

function OTS_CamController.LockMouse(lock: boolean)
	OTS_CamController.IsMouseLocked = lock
	if lock == true then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end
end

function OTS_CamController.Enable()
	OTS_CamController.IsEnabled = true
	CameraWasEnabled = true
	configureStateForEnabled()

	RunService:BindToRenderStep("OTS_CamControllerERA", Enum.RenderPriority.Camera.Value - 10, function()
		if OTS_CamController.IsEnabled == true then
			updateCamera()
		end
	end)
end

function OTS_CamController.Disable()
	configureStateForDisabled()
	OTS_CamController.IsEnabled = false
	CameraWasEnabled = false
	RunService:UnbindFromRenderStep("OTS_CamControllerERA")
end
----

--// CONTROLS //--

function OTS_CamController:KnitStart()
	print("OTS_CamController started")
end

function OTS_CamController:KnitInit()
	print("OTS_CamController initialize")

	OTS_CamController.Enable()

	PLAYER.CharacterAdded:Connect(function(character)
		Character = character
		Humanoid = character:WaitForChild("Humanoid")

		if CameraWasEnabled then
			OTS_CamController.Enable()
		end
	end)
end

return OTS_CamController
