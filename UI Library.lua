Library = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function makeDraggable(frame)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		local goal = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X,
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)

		TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = goal
		}):Play()
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
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
	Frame.Draggable = true

	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = Frame

	TextLabel.Parent = Frame
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0, 12, 0, 8)
	TextLabel.Size = UDim2.new(1, -24, 0, 24)
	TextLabel.Font = Enum.Font.Montserrat
	TextLabel.FontFace.Weight = Enum.FontWeight.ExtraBold
	TextLabel.Text = title or "Window"
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextSize = 16
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- THIS is the important part
	local Window = {
		ScreenGui = ScreenGui,
		Frame = Frame,
		Title = TextLabel
	}

	return Window
	
	
end

return Library
