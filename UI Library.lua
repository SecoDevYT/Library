Library = {}

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function makeDraggable(frame)
	local dragging = false
	local dragStart
	local startPos
	local currentPos

	local smoothness = 0.18 -- lower = snappier, higher = softer

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			currentPos = startPos

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			currentPos = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	RunService.Heartbeat:Connect(function()
		if dragging then
			frame.Position = frame.Position:Lerp(currentPos, smoothness)
		end
	end)
end

function Library:CreateWindow(title)
	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local TextLabel = Instance.new("TextLabel")

	ScreenGui.Parent = game:GetService("CoreGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false

	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.5, -196, 0.5, -188)
	Frame.Size = UDim2.new(0, 392, 0, 376)
	Frame.Active = true

	-- Soft drag
	makeDraggable(Frame)

	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = Frame

	TextLabel.Parent = Frame
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0, 12, 0, 8)
	TextLabel.Size = UDim2.new(1, -24, 0, 24)
	TextLabel.Font = Enum.Font.Montserrat
	TextLabel.Text = title or "Window"
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextSize = 16
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Window = {
		ScreenGui = ScreenGui,
		Frame = Frame,
		Title = TextLabel
	}

	return Window
end

return Library
