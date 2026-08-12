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
	ScreenGui.Name = "UI"
	ScreenGui.Parent = game:GetService("CoreGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false

	-- Main Window
	Main.Name = "Main"
	Main.Parent = ScreenGui
	Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.317, 0, 0.225, 0)
	Main.Size = UDim2.new(0.365, 0, 0.554, 0)
	Main.Active = true

	makeDraggable(Main)

	UIAspectRatioConstraint.Parent = Main
	UIAspectRatioConstraint.AspectRatio = 1.043

	UICorner.CornerRadius = UDim.new(0.03, 0)
	UICorner.Parent = Main

	UIStroke.Parent = Main
	UIStroke.Color = Color3.fromRGB(80, 80, 80)
	UIStroke.Thickness = 1

	-- Title
	Title.Parent = Main
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0.015, 0, 0.01, 0)
	Title.Size = UDim2.new(0.745, 0, 0.059, 0)
	Title.FontFace = Font.fromName("Montserrat", Enum.FontWeight.ExtraBold)
	Title.Text = title or "Window"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextScaled = true
	Title.TextXAlignment = Enum.TextXAlignment.Left

	-- Top & bottom lines
	Line1.Name = "Line1"
	Line1.Parent = Main
	Line1.BackgroundColor3 = Color3.fromRGB(148, 148, 148)
	Line1.BorderSizePixel = 0
	Line1.Position = UDim2.new(0, 0, 0.074, 0)
	Line1.Size = UDim2.new(1, 0, 0.004, 0)

	Line2.Name = "Line2"
	Line2.Parent = Main
	Line2.BackgroundColor3 = Color3.fromRGB(148, 148, 148)
	Line2.BorderSizePixel = 0
	Line2.Position = UDim2.new(0, 0, 0.17, 0)
	Line2.Size = UDim2.new(1, 0, 0.004, 0)

	-- Tab bar (horizontal scrolling)
	TabScroll.Name = "TabScroll"
	TabScroll.Parent = Main
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.Position = UDim2.new(0, 0, 0.085, 0)
	TabScroll.Size = UDim2.new(1, 0, 0.089, 0)
	TabScroll.ScrollBarThickness = 0
	TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabScroll.ScrollingDirection = Enum.ScrollingDirection.X

	TabContainer.Name = "TabContainer"
	TabContainer.Parent = TabScroll
	TabContainer.BackgroundTransparency = 1
	TabContainer.Size = UDim2.new(0, 0, 1, 0) -- width will grow

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = TabContainer
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 6)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = TabContainer
	UIPadding.PaddingLeft = UDim.new(0, 8)

	-- Window object
	local Window = {
		ScreenGui = ScreenGui,
		Main = Main,
		Title = Title,
		TabContainer = TabContainer,
		Tabs = {},
		CurrentTab = nil
	}

	function Window:CreateTab(name)
		-- Tab Button
		local TabButton = Instance.new("TextButton")
		TabButton.Name = name
		TabButton.Parent = TabContainer
		TabButton.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
		TabButton.Size = UDim2.new(0, 70, 0.7, 0)
		TabButton.FontFace = Font.fromName("Montserrat", Enum.FontWeight.ExtraBold)
		TabButton.Text = name
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.TextScaled = true
		TabButton.AutoButtonColor = false

		local ButtonCorner = Instance.new("UICorner")
		ButtonCorner.CornerRadius = UDim.new(0.35, 0)
		ButtonCorner.Parent = TabButton

		local ButtonStroke = Instance.new("UIStroke")
		ButtonStroke.Parent = TabButton
		ButtonStroke.Color = Color3.fromRGB(62, 62, 62)
		ButtonStroke.Thickness = 1.5

		-- Content Frame for this tab
		local TabFrame = Instance.new("Frame")
		TabFrame.Name = name .. "Frame"
		TabFrame.Parent = Main
		TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		TabFrame.BorderSizePixel = 0
		TabFrame.Position = UDim2.new(0, 0, 0.173, 0)
		TabFrame.Size = UDim2.new(1, 0, 0.826, 0)
		TabFrame.Visible = false
		TabFrame.ZIndex = 2

		local ContentCorner = Instance.new("UICorner")
		ContentCorner.CornerRadius = UDim.new(0.04, 0)
		ContentCorner.Parent = TabFrame

		-- Update canvas size when a new tab is added
		local function updateCanvas()
			local totalWidth = 0
			for _, child in ipairs(TabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					totalWidth += child.AbsoluteSize.X + 6
				end
			end
			TabContainer.Size = UDim2.new(0, totalWidth + 20, 1, 0)
			TabScroll.CanvasSize = UDim2.new(0, totalWidth + 20, 0, 0)
		end
		updateCanvas()
		TabButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)

		-- Tab switching logic
		local Tab = {
			Button = TabButton,
			Frame = TabFrame,
			Name = name
		}

		function Tab:Show()
			-- Hide all other tabs
			for _, otherTab in pairs(Window.Tabs) do
				otherTab.Frame.Visible = false
				otherTab.Button.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
			end

			TabFrame.Visible = true
			TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- active color
			Window.CurrentTab = Tab
		end

		TabButton.MouseButton1Click:Connect(function()
			Tab:Show()
		end)

		-- Store the tab
		Window.Tabs[name] = Tab

		-- Automatically show the first tab
		if not Window.CurrentTab then
			Tab:Show()
		end

		return Tab
	end

	return Window
end

return Library
