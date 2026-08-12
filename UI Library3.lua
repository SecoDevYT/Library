Library = {}

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function makeDraggable(frame)
	local dragging = false
	local dragStart
	local startPos
	local currentPos
	local smoothness = 0.075

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
	local Main = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local UICorner = Instance.new("UICorner")
	local TabScroll = Instance.new("ScrollingFrame")
	local TabContainer = Instance.new("Frame")
	local Line1 = Instance.new("Frame")
	local Line2 = Instance.new("Frame")
	local UIStroke = Instance.new("UIStroke")

	-- ScreenGui
	ScreenGui.Name = "MonstrumUI"
	ScreenGui.Parent = game:GetService("CoreGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false

	-- Main Frame (exact from your new export)
	Main.Name = "Main"
	Main.Parent = ScreenGui
	Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.381714672, 0, 0.285714298, 0)
	Main.Size = UDim2.new(0.248437494, 0, 0.427098662, 0)
	Main.Active = true

	makeDraggable(Main)

	UIAspectRatioConstraint.Parent = Main
	UIAspectRatioConstraint.AspectRatio = 1.043

	UICorner.CornerRadius = UDim.new(0.03, 0)
	UICorner.Parent = Main

	UIStroke.Parent = Main
	UIStroke.Color = Color3.fromRGB(80, 80, 80)

	-- Title
	Title.Parent = Main
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0.0153061338, 0, 0.0100000398, 0)
	Title.Size = UDim2.new(0.744897842, 0, 0.0591489486, 0)
	Title.FontFace = Font.fromName("Montserrat", Enum.FontWeight.ExtraBold)
	Title.Text = title or "Title"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextScaled = true
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left

	-- Lines (updated thickness 0.003)
	Line1.Name = "Line1"
	Line1.Parent = Main
	Line1.BackgroundColor3 = Color3.fromRGB(148, 148, 148)
	Line1.BorderSizePixel = 0
	Line1.Position = UDim2.new(0, 0, 0.085, 0)
	Line1.Size = UDim2.new(0.9984, 0, 0.003, 0)

	Line2.Name = "Line2"
	Line2.Parent = Main
	Line2.BackgroundColor3 = Color3.fromRGB(148, 148, 148)
	Line2.BorderSizePixel = 0
	Line2.Position = UDim2.new(0, 0, 0.17, 0)
	Line2.Size = UDim2.new(0.9984, 0, 0.003, 0)

	-- Tab ScrollingFrame
	TabScroll.Name = "TabScroll"
	TabScroll.Parent = Main
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.Position = UDim2.new(0, 0, 0.085, 0)
	TabScroll.Size = UDim2.new(1, 0, 0.089, 0)
	TabScroll.ScrollBarThickness = 0
	TabScroll.CanvasSize = UDim2.new(2, 0, 0, 0)
	TabScroll.ScrollingDirection = Enum.ScrollingDirection.X

	-- Tab Container
	TabContainer.Name = "TabContainer"
	TabContainer.Parent = TabScroll
	TabContainer.BackgroundTransparency = 1
	TabContainer.Size = UDim2.new(2, 0, 1, 0)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = TabContainer
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 6)
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = TabContainer
	UIPadding.PaddingLeft = UDim.new(0, 6)

	local Window = {
		ScreenGui = ScreenGui,
		Main = Main,
		Title = Title,
		TabContainer = TabContainer,
		Tabs = {},
		CurrentTab = nil
	}

	function Window:CreateTab(name)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = name
		TabButton.Parent = TabContainer
		TabButton.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(0.0094806506, 0, 0.704105675, 0) -- exact from your export
		TabButton.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold)
		TabButton.Text = name
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.TextScaled = true
		TabButton.TextWrapped = true
		TabButton.AutoButtonColor = false

		local ButtonCorner = Instance.new("UICorner")
		ButtonCorner.CornerRadius = UDim.new(0.35, 0)
		ButtonCorner.Parent = TabButton

		local ButtonStroke = Instance.new("UIStroke")
		ButtonStroke.Parent = TabButton
		ButtonStroke.Color = Color3.fromRGB(62, 62, 62)
		ButtonStroke.Thickness = 1.5
		ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		-- Content Frame (exact values)
		local TabFrame = Instance.new("Frame")
		TabFrame.Name = name .. "Frame"
		TabFrame.Parent = Main
		TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		TabFrame.BorderSizePixel = 0
		TabFrame.Position = UDim2.new(0, 0, 0.172687039, 0)
		TabFrame.Size = UDim2.new(0.9984, 0, 0.8257, 0)
		TabFrame.Visible = false
		TabFrame.ZIndex = 2

		local ContentCorner = Instance.new("UICorner")
		ContentCorner.CornerRadius = UDim.new(0.04, 0)
		ContentCorner.Parent = TabFrame

		local function updateCanvas()
			task.wait()
			local totalWidth = 12
			for _, child in ipairs(TabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					totalWidth += child.AbsoluteSize.X + 7
				end
			end
			TabContainer.Size = UDim2.new(0, math.max(totalWidth, 400), 1, 0)
			TabScroll.CanvasSize = UDim2.new(0, math.max(totalWidth, 400), 0, 0)
		end

		updateCanvas()
		TabButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)

		local Tab = {
			Button = TabButton,
			Frame = TabFrame,
			Name = name
		}

		function Tab:Show()
			for _, other in pairs(Window.Tabs) do
				other.Frame.Visible = false
				other.Button.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
				other.Button.TextColor3 = Color3.fromRGB(170, 170, 170)
			end

			TabFrame.Visible = true
			TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
			TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			Window.CurrentTab = Tab
		end

		TabButton.MouseButton1Click:Connect(function()
			Tab:Show()
		end)

		Window.Tabs[name] = Tab

		if not Window.CurrentTab then
			Tab:Show()
		else
			TabButton.TextColor3 = Color3.fromRGB(170, 170, 170)
		end

		return Tab
	end

	return Window
end

return Library
