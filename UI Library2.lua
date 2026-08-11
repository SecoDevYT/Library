Library = {}

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function makeDraggable(frame)
	local dragging = false
	local dragStart
	local startPos
	local currentPos

	local smoothness = 0.075 -- lower = snappier, higher = softer

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
	local TextLabel = Instance.new("TextLabel")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local UICorner = Instance.new("UICorner")

	-- ScreenGui
	ScreenGui.Parent = game:GetService("CoreGui") -- change to PlayerGui if you prefer
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Name = "MonstrumUI"

	-- Main Frame
	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.324, 0, 0.222, 0)
	Frame.Size = UDim2.new(0.365, 0, 0.554, 0)
	Frame.Active = true

	-- Soft drag
	makeDraggable(Frame)

	-- Aspect Ratio
	UIAspectRatioConstraint.Parent = Frame
	UIAspectRatioConstraint.AspectRatio = 1.043

	-- Corner
	UICorner.CornerRadius = UDim.new(0.04, 0)
	UICorner.Parent = Frame

	-- Title
	TextLabel.Parent = Frame
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0.015, 0, 0.01, 0)
	TextLabel.Size = UDim2.new(0.745, 0, 0.061, 0)
	TextLabel.FontFace = Font.fromName("Montserrat", Enum.FontWeight.ExtraBold)
	TextLabel.Text = title or "Window"
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextScaled = true
	TextLabel.TextWrapped = true
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Window = {
		ScreenGui = ScreenGui,
		Frame = Frame,
		Title = TextLabel
	}

	return Window
end

return Library
