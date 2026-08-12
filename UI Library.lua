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
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

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
		if dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			) then

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
		if dragging and currentPos then
			frame.Position = frame.Position:Lerp(currentPos, smoothness)
		end
	end)
end


-- ============================================================
-- Executes either a normal Lua callback or a pasted script.
-- ============================================================

local function executeAction(action, ...)
	if action == nil then
		return
	end

	-- Normal callback function
	if typeof(action) == "function" then
		local success, err = pcall(action, ...)

		if not success then
			warn("[MonstrumUI] Callback error:", err)
		end

		return
	end

	-- String containing code
	if typeof(action) == "string" then

		-- loadstring may not exist in normal LocalScripts.
		if typeof(loadstring) ~= "function" then
			warn(
				"[MonstrumUI] loadstring is unavailable. " ..
				"Use a function callback or run this in an environment " ..
				"where loadstring is available."
			)

			return
		end

		local success, loadedFunction = pcall(loadstring, action)

		if not success then
			warn("[MonstrumUI] Failed to compile script:", loadedFunction)
			return
		end

		if typeof(loadedFunction) ~= "function" then
			warn("[MonstrumUI] Compiled script did not return a function.")
			return
		end

		local runSuccess, err = pcall(loadedFunction, ...)

		if not runSuccess then
			warn("[MonstrumUI] Script error:", err)
		end

		return
	end

	warn(
		"[MonstrumUI] Expected a function or string for the action, got:",
		typeof(action)
	)
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

	-- ============================================================
	-- ScreenGui
	-- ============================================================

	ScreenGui.Name = "MonstrumUI"
	ScreenGui.Parent = game:GetService("CoreGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false

	-- ============================================================
	-- Main
	-- ============================================================

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

	-- ============================================================
	-- Title
	-- ============================================================

	Title.Parent = Main
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0.0153061338, 0, 0.0100000398, 0)
	Title.Size = UDim2.new(0.744897842, 0, 0.0591489486, 0)

	Title.FontFace = Font.fromName(
		"Montserrat",
		Enum.FontWeight.ExtraBold
	)

	Title.Text = title or "Title"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextScaled = true
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left

	-- ============================================================
	-- Lines
	-- ============================================================

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

	-- ============================================================
	-- Tab scrolling
	-- ============================================================

	TabScroll.Name = "TabScroll"
	TabScroll.Parent = Main
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.Position = UDim2.new(0, 0, 0.085, 0)
	TabScroll.Size = UDim2.new(1, 0, 0.089, 0)
	TabScroll.ScrollBarThickness = 0
	TabScroll.CanvasSize = UDim2.new(2, 0, 0, 0)
	TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
	TabScroll.Active = true

	-- ============================================================
	-- Tab container
	-- ============================================================

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

	-- ============================================================
	-- Window object
	-- ============================================================

	local Window = {
		ScreenGui = ScreenGui,
		Main = Main,
		Title = Title,
		TabContainer = TabContainer,
		Tabs = {},
		CurrentTab = nil
	}


	-- ============================================================
	-- CreateTab
	-- ============================================================

	function Window:CreateTab(name)

		name = tostring(name or "Tab")

		-- --------------------------------------------------------
		-- Tab button
		-- --------------------------------------------------------

		local TabButton = Instance.new("TextButton")

		TabButton.Name = name
		TabButton.Parent = TabContainer
		TabButton.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
		TabButton.BorderSizePixel = 0

		TabButton.Size = UDim2.new(
			0.164806506,
			0,
			0.704105675,
			0
		)

		TabButton.FontFace = Font.fromName(
			"Montserrat",
			Enum.FontWeight.Bold
		)

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

		-- --------------------------------------------------------
		-- Content frame
		-- --------------------------------------------------------

		local TabFrame = Instance.new("Frame")

		TabFrame.Name = name .. "Frame"
		TabFrame.Parent = Main
		TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		TabFrame.BorderSizePixel = 0
		TabFrame.Position = UDim2.new(
			0,
			0,
			0.172687039,
			0
		)

		TabFrame.Size = UDim2.new(
			0.9984,
			0,
			0.8257,
			0
		)

		TabFrame.Visible = false
		TabFrame.ZIndex = 2

		local ContentCorner = Instance.new("UICorner")
		ContentCorner.CornerRadius = UDim.new(0.04, 0)
		ContentCorner.Parent = TabFrame

		-- --------------------------------------------------------
		-- Automatic control layout
		--
		-- This fixes the original problem where every newly
		-- created button would use the exact same Position.
		-- --------------------------------------------------------

		local ControlLayout = Instance.new("UIListLayout")

		ControlLayout.Name = "ControlLayout"
		ControlLayout.Parent = TabFrame
		ControlLayout.FillDirection = Enum.FillDirection.Vertical
		ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		ControlLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ControlLayout.Padding = UDim.new(0, 8)

		local ControlPadding = Instance.new("UIPadding")

		ControlPadding.Name = "ControlPadding"
		ControlPadding.Parent = TabFrame

		-- Original Temp button started around this Y position.
		ControlPadding.PaddingTop = UDim.new(
			0.170993626,
			0
		)

		ControlPadding.PaddingLeft = UDim.new(
			0.00984760094,
			0
		)

		-- --------------------------------------------------------
		-- Tab object
		-- --------------------------------------------------------

		local Tab = {
			Button = TabButton,
			Frame = TabFrame,
			Name = name,
			Controls = {}
		}


		-- ========================================================
		-- Tab:Show
		-- ========================================================

		function Tab:Show()

			for _, other in pairs(Window.Tabs) do

				if other.Frame then
					other.Frame.Visible = false
				end

				if other.Button then
					other.Button.BackgroundColor3 =
						Color3.fromRGB(43, 43, 43)

					other.Button.TextColor3 =
						Color3.fromRGB(170, 170, 170)
				end
			end

			TabFrame.Visible = true

			TabButton.BackgroundColor3 =
				Color3.fromRGB(55, 55, 55)

			TabButton.TextColor3 =
				Color3.fromRGB(255, 255, 255)

			Window.CurrentTab = Tab
		end


		-- ========================================================
		-- Canvas update
		-- ========================================================

		local function updateTabCanvas()

			task.defer(function()

				if not TabContainer.Parent then
					return
				end

				local totalWidth = 12

				for _, child in ipairs(
					TabContainer:GetChildren()
				) do

					if child:IsA("TextButton") then
						totalWidth += child.AbsoluteSize.X + 7
					end
				end

				totalWidth = math.max(
					totalWidth,
					400
				)

				TabContainer.Size = UDim2.new(
					0,
					totalWidth,
					1,
					0
				)

				TabScroll.CanvasSize = UDim2.new(
					0,
					totalWidth,
					0,
					0
				)
			end)
		end

		updateTabCanvas()

		TabButton:GetPropertyChangedSignal(
			"AbsoluteSize"
		):Connect(updateTabCanvas)

		TabContainer.ChildAdded:Connect(updateTabCanvas)
		TabContainer.ChildRemoved:Connect(updateTabCanvas)


		-- ========================================================
		-- Tab button click
		-- ========================================================

		TabButton.MouseButton1Click:Connect(function()
			Tab:Show()
		end)


		-- ========================================================
		-- CreateButton
		--
		-- Usage:
		--
		-- Tab:CreateButton(
		--     "Button",
		--     "Button1",
		--     function()
		--         print("Clicked")
		--     end
		-- )
		--
		-- Tab:CreateButton(
		--     "Toggle",
		--     "My Toggle",
		--     function(enabled)
		--         print(enabled)
		--     end
		-- )
		--
		-- A string can also be supplied as the action when
		-- loadstring is available.
		-- ========================================================

		function Tab:CreateButton(buttonType, action, callback)

			buttonType = tostring(
				buttonType or "Button"
			)

			action = tostring(
				action or "Button"
			)

			local normalizedType =
				string.lower(buttonType)

			-- ====================================================
			-- NORMAL BUTTON
			-- ====================================================

			if normalizedType == "button" then

				local Button = Instance.new("TextButton")

				Button.Name = action
				Button.Parent = TabFrame

				Button.BackgroundColor3 =
					Color3.fromRGB(43, 43, 43)

				Button.BorderSizePixel = 0

				-- Same size as your exported Temp button.
				Button.Size = UDim2.new(
					0.274753273,
					0,
					0.119450592,
					0
				)

				Button.FontFace = Font.fromName(
					"Montserrat",
					Enum.FontWeight.Bold
				)

				Button.Text = action

				Button.TextColor3 =
					Color3.fromRGB(255, 255, 255)

				Button.TextScaled = true
				Button.TextWrapped = true
				Button.AutoButtonColor = false

				local Corner = Instance.new("UICorner")

				Corner.CornerRadius =
					UDim.new(0.35, 0)

				Corner.Parent = Button

				local Stroke = Instance.new("UIStroke")

				Stroke.Parent = Button

				Stroke.Color =
					Color3.fromRGB(62, 62, 62)

				Stroke.Thickness = 1.5

				Stroke.ApplyStrokeMode =
					Enum.ApplyStrokeMode.Border

				Button.MouseButton1Click:Connect(function()
					executeAction(callback)
				end)

				local Control = {
					Instance = Button,
					Type = "Button",
					Name = action
				}

				table.insert(Tab.Controls, Control)

				return Control
			end


			-- ====================================================
			-- TOGGLE
			-- ====================================================

			if normalizedType == "toggle" then

				local ToggleFrame = Instance.new("Frame")

				ToggleFrame.Name = action
				ToggleFrame.Parent = TabFrame

				ToggleFrame.BackgroundTransparency = 1
				ToggleFrame.BorderSizePixel = 0

				-- Same size as your exported toggle Temp frame.
				ToggleFrame.Size = UDim2.new(
					0.268339217,
					0,
					0.129459336,
					0
				)

				-- ------------------------------------------------
				-- Red/green background
				-- ------------------------------------------------

				local ToggleColorFrame =
					Instance.new("Frame")

				ToggleColorFrame.Name =
					"RedGreenToggleColorFrame"

				ToggleColorFrame.Parent =
					ToggleFrame

				ToggleColorFrame.BackgroundColor3 =
					Color3.fromRGB(255, 0, 0)

				ToggleColorFrame.BorderSizePixel = 0

				ToggleColorFrame.Position =
					UDim2.new(
						0.0617283955,
						0,
						0.129032254,
						0
					)

				ToggleColorFrame.Size =
					UDim2.new(
						0.876543224,
						0,
						0.709677398,
						0
					)

				local ToggleCorner =
					Instance.new("UICorner")

				ToggleCorner.CornerRadius =
					UDim.new(0.3, 0)

				ToggleCorner.Parent =
					ToggleColorFrame


				-- ------------------------------------------------
				-- Gray slider area
				-- ------------------------------------------------

				local SliderFrame =
					Instance.new("Frame")

				SliderFrame.Name =
					"SliderFrame"

				SliderFrame.Parent =
					ToggleFrame

				SliderFrame.BackgroundColor3 =
					Color3.fromRGB(88, 88, 88)

				SliderFrame.BorderSizePixel = 0

				SliderFrame.Position =
					UDim2.new(
						0.604938209,
						0,
						0,
						0
					)

				SliderFrame.Size =
					UDim2.new(
						0.39,
						0,
						1,
						0
					)

				local SliderCorner =
					Instance.new("UICorner")

				SliderCorner.CornerRadius =
					UDim.new(0.3, 0)

				SliderCorner.Parent =
					SliderFrame


				-- ------------------------------------------------
				-- Invisible clickable button
				-- ------------------------------------------------

				local ToggleButton =
					Instance.new("TextButton")

				ToggleButton.Name = "Toggler"
				ToggleButton.Parent = ToggleFrame

				ToggleButton.BackgroundTransparency = 1
				ToggleButton.BorderSizePixel = 0

				ToggleButton.Size = UDim2.new(
					1,
					0,
					1.03225803,
					0
				)

				ToggleButton.Font =
					Enum.Font.SourceSans

				ToggleButton.Text = ""

				ToggleButton.TextColor3 =
					Color3.fromRGB(0, 0, 0)

				ToggleButton.TextSize = 14

				ToggleButton.AutoButtonColor = false


				-- ------------------------------------------------
				-- Action text
				-- ------------------------------------------------

				local ActionText =
					Instance.new("TextLabel")

				ActionText.Name = "ActionText"
				ActionText.Parent = ToggleFrame

				ActionText.BackgroundTransparency = 1
				ActionText.BorderSizePixel = 0

				ActionText.Position =
					UDim2.new(
						1.00090575,
						0,
						0.0634982213,
						0
					)

				ActionText.Size =
					UDim2.new(
						1.20987654,
						0,
						0.90322578,
						0
					)

				ActionText.FontFace =
					Font.fromName(
						"Montserrat",
						Enum.FontWeight.Bold
					)

				ActionText.Text = action

				ActionText.TextColor3 =
					Color3.fromRGB(
						179,
						179,
						179
					)

				ActionText.TextScaled = true
				ActionText.TextWrapped = true


				-- ------------------------------------------------
				-- Toggle state
				-- ------------------------------------------------

				local enabled = false


				local Control = {
					Instance = ToggleFrame,
					Button = ToggleButton,
					Label = ActionText,
					ToggleFrame = ToggleColorFrame,
					SliderFrame = SliderFrame,
					Type = "Toggle",
					Name = action,
					Enabled = false
				}


				-- ------------------------------------------------
				-- State setter
				-- ------------------------------------------------

				function Control:SetState(state, fireCallback)

					state = state == true

					enabled = state
					Control.Enabled = state

					if state then

						ToggleColorFrame.BackgroundColor3 =
							Color3.fromRGB(
								0,
								255,
								0
							)

					else

						ToggleColorFrame.BackgroundColor3 =
							Color3.fromRGB(
								255,
								0,
								0
							)
					end

					if fireCallback ~= false then
						executeAction(
							callback,
							enabled
						)
					end
				end


				function Control:GetState()
					return enabled
				end


				-- ------------------------------------------------
				-- Click
				-- ------------------------------------------------

				ToggleButton.MouseButton1Click:Connect(function()

					Control:SetState(
						not enabled,
						true
					)

				end)


				table.insert(
					Tab.Controls,
					Control
				)

				return Control
			end


			-- ====================================================
			-- UNKNOWN TYPE
			-- ====================================================

			warn(
				"[MonstrumUI] Unknown button type:",
				buttonType
			)

			return nil
		end


		-- ========================================================
		-- Register tab
		-- ========================================================

		Window.Tabs[name] = Tab

		if not Window.CurrentTab then
			Tab:Show()
		else
			TabButton.TextColor3 =
				Color3.fromRGB(170, 170, 170)
		end

		return Tab
	end


	return Window
end


return Library
