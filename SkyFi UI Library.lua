-- SkyFi-UI
-- Advanced Roblox UI Library
-- Revised after code review and original GUI notes

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {}

Library.Config = {
    Title = "SkyFi-UI",
    DefaultTabIcon = "rbxassetid://103521649749710",

    -- Ordered on purpose. Earlier entries have higher priority.
    TabIcons = {},

    Colors = {
        Background = Color3.fromRGB(15, 15, 15),
        Container = Color3.fromRGB(21, 21, 21),
        Button = Color3.fromRGB(27, 27, 27),
        ButtonHover = Color3.fromRGB(23, 23, 23),
        ToggleOff = Color3.fromRGB(88, 88, 88),
        ToggleOn = Color3.fromRGB(255, 255, 255),
        ToggleKnob = Color3.fromRGB(4, 4, 4),
        SliderBar = Color3.fromRGB(84, 84, 84),
        SliderKnob = Color3.fromRGB(117, 117, 117),
        Text = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(144, 144, 144),
        Stroke = Color3.fromRGB(26, 26, 26),
        ButtonStroke = Color3.fromRGB(30, 30, 30),
    },

    Animation = {
        Fast = 0.12,
        Normal = 0.18,
    },
}

Library.Tabs = {}
Library.CurrentTab = nil
Library._connections = {}
Library._destroyed = false

local function TrackConnection(owner, connection)
    owner._connections = owner._connections or {}
    table.insert(owner._connections, connection)
    return connection
end

local function DisconnectAll(owner)
    if not owner or not owner._connections then
        return
    end

    for _, connection in ipairs(owner._connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end

    table.clear(owner._connections)
end

local function Tween(instance, properties, duration)
    if not instance or not instance.Parent then
        return nil
    end

    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Library.Config.Animation.Normal,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()
    return tween
end

local function Create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function AddCorner(parent, scale)
    return Create("UICorner", {
        CornerRadius = UDim.new(scale or 0.1, 0),
    }, parent)
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Library.Config.Colors.Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function RoundNumber(value, decimals)
    local multiplier = 10 ^ (decimals or 0)
    return math.floor(value * multiplier + 0.5) / multiplier
end

local function GetTabIcon(tabName)
    local lowered = string.lower(tabName)

    for _, entry in ipairs(Library.Config.TabIcons) do
        if string.find(lowered, string.lower(entry.Keyword), 1, true) then
            return entry.Image
        end
    end

    return Library.Config.DefaultTabIcon
end

---------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------

local ScreenGui = Create("ScreenGui", {
    Name = "SkyFi_UI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, PlayerGui)

Library.ScreenGui = ScreenGui

local MainFrame = Create("Frame", {
    Name = "Main",
    BackgroundColor3 = Library.Config.Colors.Background,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.355, 0.44),
}, ScreenGui)

Library.MainFrame = MainFrame

AddCorner(MainFrame, 0.075)

Create("UIAspectRatioConstraint", {
    AspectRatio = 1.536,
}, MainFrame)

---------------------------------------------------------------------
-- TOP BAR
---------------------------------------------------------------------

local TopBar = Create("Frame", {
    Name = "TopBar",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 0.164),
}, MainFrame)

-- Intentional visual design: creates the thin split/fade line.
Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39)),
    }),
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.96, 1),
        NumberSequenceKeypoint.new(0.96, 0),
        NumberSequenceKeypoint.new(1, 0),
    }),
}, TopBar)

local Title = Create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(0.005, 0),
    Size = UDim2.fromScale(0.86, 0.95),
    Font = Enum.Font.Nunito,
    Text = Library.Config.Title,
    TextColor3 = Library.Config.Colors.Text,
    TextScaled = true,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

local Close = Create("ImageButton", {
    Name = "Close",
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.fromScale(0.99, 0.08),
    Size = UDim2.fromScale(0.075, 0.82),
    Image = "rbxassetid://97652315417935",
    AutoButtonColor = false,
}, TopBar)

TrackConnection(Library, Close.MouseEnter:Connect(function()
    Tween(Close, {ImageTransparency = 0.3}, Library.Config.Animation.Fast)
end))

TrackConnection(Library, Close.MouseLeave:Connect(function()
    Tween(Close, {ImageTransparency = 0}, Library.Config.Animation.Fast)
end))

---------------------------------------------------------------------
-- TAB SIDEBAR
---------------------------------------------------------------------

local Sidebar = Create("Frame", {
    Name = "TabButtons",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromScale(0, 0.164),
    Size = UDim2.fromScale(0.126, 0.836),
}, MainFrame)

-- Intentional visual design: this creates the split between sidebar and content.
Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39)),
    }),
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.96, 1),
        NumberSequenceKeypoint.new(0.96, 0),
        NumberSequenceKeypoint.new(1, 0),
    }),
}, Sidebar)

local TabButtonScrolling = Create("ScrollingFrame", {
    Name = "Scrolling",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    Active = true,
    ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
}, Sidebar)

Create("UIPadding", {
    PaddingTop = UDim.new(0.025, 0),
    PaddingBottom = UDim.new(0.025, 0),
    PaddingLeft = UDim.new(0.08, 0),
    PaddingRight = UDim.new(0.08, 0),
}, TabButtonScrolling)

local TabButtonLayout = Create("UIListLayout", {
    Padding = UDim.new(0.02, 0),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, TabButtonScrolling)

---------------------------------------------------------------------
-- CONTENT AREA
---------------------------------------------------------------------

local TabsContainer = Create("Frame", {
    Name = "Tabs",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromScale(0.126, 0.164),
    Size = UDim2.fromScale(0.874, 0.836),
}, MainFrame)

---------------------------------------------------------------------
-- DRAGGING
---------------------------------------------------------------------

Library._dragging = false
Library._dragStart = nil
Library._startPosition = nil

TrackConnection(Library, TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Library._dragging = true
        Library._dragStart = input.Position
        Library._startPosition = MainFrame.Position
    end
end))

TrackConnection(Library, TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Library._dragging = false
    end
end))

TrackConnection(Library, UserInputService.InputChanged:Connect(function(input)
    if not Library._dragging or not Library._dragStart or not Library._startPosition then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - Library._dragStart

    MainFrame.Position = UDim2.new(
        Library._startPosition.X.Scale,
        Library._startPosition.X.Offset + delta.X,
        Library._startPosition.Y.Scale,
        Library._startPosition.Y.Offset + delta.Y
    )
end))

TrackConnection(Library, UserInputService.WindowFocusReleased:Connect(function()
    Library._dragging = false
end))

TrackConnection(Library, Close.Activated:Connect(function()
    Library:Destroy()
end))

---------------------------------------------------------------------
-- COMPONENT HELPERS
---------------------------------------------------------------------

local function CreateComponentFrame(parent, name, height)
    local frame = Create("Frame", {
        Name = name or "Component",
        BackgroundColor3 = Library.Config.Colors.Container,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or 55),
    }, parent)

    AddCorner(frame, 0.1)
    AddStroke(frame, Library.Config.Colors.Stroke, 1)

    return frame
end

---------------------------------------------------------------------
-- BUTTON
---------------------------------------------------------------------

local function CreateButton(componentParent, text, callback)
    local object = {
        _connections = {},
    }

    local frame = CreateComponentFrame(componentParent, "Button", 48)
    object.Instance = frame

    local button = Create("TextButton", {
        Name = "Button",
        BackgroundColor3 = Library.Config.Colors.Button,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.05, 0.15),
        Size = UDim2.fromScale(0.9, 0.7),
        AutoButtonColor = false,
        Font = Enum.Font.Nunito,
        Text = tostring(text),
        TextColor3 = Library.Config.Colors.Text,
        TextScaled = true,
        TextWrapped = true,
    }, frame)

    object.Button = button
    AddCorner(button, 0.1)
    AddStroke(button, Library.Config.Colors.ButtonStroke, 1)

    TrackConnection(object, button.MouseEnter:Connect(function()
        Tween(button, {
            BackgroundColor3 = Library.Config.Colors.ButtonHover,
        }, Library.Config.Animation.Fast)
    end))

    TrackConnection(object, button.MouseLeave:Connect(function()
        Tween(button, {
            BackgroundColor3 = Library.Config.Colors.Button,
        }, Library.Config.Animation.Fast)
    end))

    TrackConnection(object, button.Activated:Connect(function()
        if typeof(callback) == "function" then
            task.spawn(callback)
        end
    end))

    function object:SetText(newText)
        button.Text = tostring(newText)
    end

    function object:Destroy()
        DisconnectAll(self)
        if frame then
            frame:Destroy()
        end
    end

    return object
end

---------------------------------------------------------------------
-- LABEL
---------------------------------------------------------------------

local function CreateLabel(componentParent, text)
    local object = {}
    local frame = CreateComponentFrame(componentParent, "Label", 40)

    object.Instance = frame

    local label = Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.05, 0.1),
        Size = UDim2.fromScale(0.9, 0.8),
        Font = Enum.Font.Nunito,
        Text = tostring(text),
        TextColor3 = Library.Config.Colors.SecondaryText,
        TextScaled = true,
        TextWrapped = true,
    }, frame)

    object.Label = label

    function object:SetText(newText)
        label.Text = tostring(newText)
    end

    function object:Destroy()
        frame:Destroy()
    end

    return object
end

---------------------------------------------------------------------
-- TOGGLE
---------------------------------------------------------------------

local function CreateToggle(componentParent, text, default, callback)
    if typeof(default) == "function" then
        callback = default
        default = false
    end

    local object = {
        _connections = {},
        Enabled = default == true,
    }

    local frame = CreateComponentFrame(componentParent, "Toggle", 48)
    object.Instance = frame

    Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.05, 0.1),
        Size = UDim2.fromScale(0.58, 0.8),
        Font = Enum.Font.Nunito,
        Text = tostring(text),
        TextColor3 = Library.Config.Colors.Text,
        TextScaled = true,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local toggler = Create("TextButton", {
        Name = "Toggler",
        BackgroundColor3 = object.Enabled and Library.Config.Colors.ToggleOn or Library.Config.Colors.ToggleOff,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromScale(0.94, 0.5),
        Size = UDim2.fromScale(0.25, 0.62),
        Text = "",
        AutoButtonColor = false,
    }, frame)

    object.Toggle = toggler

    -- Intentional pill-shaped design from the original UI.
    AddCorner(toggler, 0.5)

    local toggleKnob = Create("Frame", {
        Name = "ToggleFrame",
        BackgroundColor3 = Library.Config.Colors.ToggleKnob,
        BorderSizePixel = 0,
        Position = object.Enabled and UDim2.fromScale(0.614, 0.098) or UDim2.fromScale(0.05, 0.098),
        Size = UDim2.fromScale(0.333, 0.784),
    }, toggler)

    AddCorner(toggleKnob, 0.5)

    local function UpdateToggle(newValue, fireCallback)
        object.Enabled = newValue == true

        Tween(toggler, {
            BackgroundColor3 = object.Enabled and Library.Config.Colors.ToggleOn or Library.Config.Colors.ToggleOff,
        }, Library.Config.Animation.Normal)

        Tween(toggleKnob, {
            Position = object.Enabled
                and UDim2.fromScale(0.614, 0.098)
                or UDim2.fromScale(0.05, 0.098),
        }, Library.Config.Animation.Normal)

        if fireCallback and typeof(callback) == "function" then
            task.spawn(callback, object.Enabled)
        end
    end

    TrackConnection(object, toggler.Activated:Connect(function()
        UpdateToggle(not object.Enabled, true)
    end))

    function object:GetValue()
        return object.Enabled
    end

    function object:SetValue(value, fireCallback)
        UpdateToggle(value, fireCallback ~= false)
    end

    function object:Destroy()
        DisconnectAll(self)
        frame:Destroy()
    end

    return object
end

---------------------------------------------------------------------
-- SLIDER
---------------------------------------------------------------------

local function CreateSlider(componentParent, options, callback)
    options = options or {}

    local minimum = tonumber(options.min) or 0
    local maximum = tonumber(options.max) or 100

    if minimum > maximum then
        minimum, maximum = maximum, minimum
    end

    local value = Clamp(
        tonumber(options.default) or minimum,
        minimum,
        maximum
    )

    local object = {
        _connections = {},
    }

    local frame = CreateComponentFrame(componentParent, "Slider", 72)
    object.Instance = frame

    Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.05, 0.05),
        Size = UDim2.fromScale(0.9, 0.32),
        Font = Enum.Font.Nunito,
        Text = tostring(options.text or options.name or "Slider"),
        TextColor3 = Library.Config.Colors.Text,
        TextScaled = true,
        TextWrapped = true,
    }, frame)

    local valueLabel = Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.05, 0.38),
        Size = UDim2.fromScale(0.9, 0.25),
        Font = Enum.Font.Nunito,
        Text = tostring(value),
        TextColor3 = Library.Config.Colors.SecondaryText,
        TextScaled = true,
        TextWrapped = true,
    }, frame)

    local slideBar = Create("Frame", {
        Name = "SlideBar",
        BackgroundColor3 = Library.Config.Colors.SliderBar,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0.73),
        Size = UDim2.fromScale(0.88, 0.11),
    }, frame)

    AddCorner(slideBar, 10)

    local knob = Create("TextButton", {
        Name = "SliderButton",
        BackgroundColor3 = Library.Config.Colors.SliderKnob,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromScale(0.07, 2.2),
        Text = "",
        AutoButtonColor = false,
    }, slideBar)

    AddCorner(knob, 10)

    local dragging = false

    local function ValueToAlpha(currentValue)
        if maximum == minimum then
            return 0
        end

        return (currentValue - minimum) / (maximum - minimum)
    end

    local function AlphaToValue(alpha)
        local raw = minimum + ((maximum - minimum) * alpha)
        return RoundNumber(
            Clamp(raw, minimum, maximum),
            options.decimals or 0
        )
    end

    local function UpdateVisual(currentValue)
        value = Clamp(currentValue, minimum, maximum)

        knob.Position = UDim2.new(
            ValueToAlpha(value),
            0,
            0.5,
            0
        )

        valueLabel.Text = tostring(value)
    end

    local function SetValueFromMouse(mouseX, fireCallback)
        local absoluteX = slideBar.AbsolutePosition.X
        local absoluteWidth = slideBar.AbsoluteSize.X

        if absoluteWidth <= 0 then
            return
        end

        local alpha = Clamp(
            (mouseX - absoluteX) / absoluteWidth,
            0,
            1
        )

        local newValue = AlphaToValue(alpha)
        UpdateVisual(newValue)

        if fireCallback and typeof(callback) == "function" then
            task.spawn(callback, newValue)
        end
    end

    UpdateVisual(value)

    -- Use InputBegan so the InputObject is the source of truth for both mouse and touch.
    TrackConnection(object, knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            SetValueFromMouse(input.Position.X, true)
        end
    end))

    TrackConnection(object, slideBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            SetValueFromMouse(input.Position.X, true)
        end
    end))

    TrackConnection(object, UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            SetValueFromMouse(input.Position.X, true)
        end
    end))

    TrackConnection(object, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end))

    TrackConnection(object, UserInputService.WindowFocusReleased:Connect(function()
        dragging = false
    end))

    function object:GetValue()
        return value
    end

    function object:SetValue(newValue, fireCallback)
        newValue = tonumber(newValue)
        if not newValue then
            return
        end

        UpdateVisual(Clamp(newValue, minimum, maximum))

        if fireCallback ~= false and typeof(callback) == "function" then
            task.spawn(callback, value)
        end
    end

    function object:SetRange(newMin, newMax)
        newMin = tonumber(newMin)
        newMax = tonumber(newMax)

        if not newMin or not newMax then
            return
        end

        minimum = math.min(newMin, newMax)
        maximum = math.max(newMin, newMax)

        UpdateVisual(value)
    end

    function object:Destroy()
        dragging = false
        DisconnectAll(self)
        frame:Destroy()
    end

    return object
end

---------------------------------------------------------------------
-- LIST
---------------------------------------------------------------------

local function CreateList(componentParent, options, callback)
    options = options or {}

    local object = {
        _connections = {},
        Items = {},
    }

    local frame = CreateComponentFrame(componentParent, "List", 55)
    object.Instance = frame

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0.04, 0),
        PaddingRight = UDim.new(0.04, 0),
    }, frame)

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, frame)

    local function UpdateHeight()
        local height = math.max(55, layout.AbsoluteContentSize.Y + 16)
        frame.Size = UDim2.new(1, 0, 0, height)
    end

    TrackConnection(object, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight))

    function object:Add(item, fireCallback)
        local index = #object.Items + 1

        local itemButton = Create("TextButton", {
            Name = "Item_" .. index,
            BackgroundColor3 = Library.Config.Colors.Button,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28),
            AutoButtonColor = false,
            Font = Enum.Font.Nunito,
            Text = tostring(item),
            TextColor3 = Library.Config.Colors.Text,
            TextScaled = true,
            TextWrapped = true,
            LayoutOrder = index,
        }, frame)

        AddCorner(itemButton, 0.1)

        local itemData = {
            Value = item,
            Button = itemButton,
        }

        table.insert(object.Items, itemData)

        itemData.HoverConnection = itemButton.MouseEnter:Connect(function()
            Tween(itemButton, {
                BackgroundColor3 = Library.Config.Colors.ButtonHover,
            }, Library.Config.Animation.Fast)
        end)

        itemData.LeaveConnection = itemButton.MouseLeave:Connect(function()
            Tween(itemButton, {
                BackgroundColor3 = Library.Config.Colors.Button,
            }, Library.Config.Animation.Fast)
        end)

        itemData.ActivatedConnection = itemButton.Activated:Connect(function()
            if typeof(callback) == "function" then
                task.spawn(callback, itemData.Value, table.find(object.Items, itemData))
            end
        end)

        if fireCallback and typeof(callback) == "function" then
            task.spawn(callback, item, index)
        end

        task.defer(UpdateHeight)
        return itemData
    end

    function object:Remove(index)
        local itemData = object.Items[index]
        if not itemData then
            return false
        end

        if itemData.HoverConnection then
            itemData.HoverConnection:Disconnect()
        end
        if itemData.LeaveConnection then
            itemData.LeaveConnection:Disconnect()
        end
        if itemData.ActivatedConnection then
            itemData.ActivatedConnection:Disconnect()
        end

        if itemData.Button then
            itemData.Button:Destroy()
        end

        table.remove(object.Items, index)

        for newIndex, remaining in ipairs(object.Items) do
            remaining.Button.LayoutOrder = newIndex
            remaining.Button.Name = "Item_" .. newIndex
        end

        task.defer(UpdateHeight)
        return true
    end

    function object:Clear()
        for index = #object.Items, 1, -1 do
            object:Remove(index)
        end
    end

    for _, item in ipairs(options.items or {}) do
        object:Add(item, false)
    end

    task.defer(UpdateHeight)

    function object:Destroy()
        self:Clear()
        DisconnectAll(self)
        frame:Destroy()
    end

    return object
end

---------------------------------------------------------------------
-- FRAME OBJECT
---------------------------------------------------------------------

local function BuildFrameObject(tabObject, frameInstance)
    local object = {
        Instance = frameInstance,
        ParentTab = tabObject,
        _connections = {},
    }

    function object:CreateButton(text, callback)
        return CreateButton(frameInstance, text, callback)
    end

    function object:CreateToggle(text, default, callback)
        return CreateToggle(frameInstance, text, default, callback)
    end

    function object:CreateLabel(text)
        return CreateLabel(frameInstance, text)
    end

    function object:CreateSlider(options, callback)
        return CreateSlider(frameInstance, options, callback)
    end

    function object:CreateList(options, callback)
        return CreateList(frameInstance, options, callback)
    end

    function object:SetVisible(visible)
        frameInstance.Visible = visible
    end

    function object:Destroy()
        DisconnectAll(self)
        frameInstance:Destroy()
    end

    return object
end

---------------------------------------------------------------------
-- TAB OBJECT
---------------------------------------------------------------------

local function BuildTabObject(tabName, tabContent, tabButton)
    local object = {
        Name = tabName,
        Instance = tabContent,
        Button = tabButton,
        Frames = {},
        _connections = {},
    }

    local overlay = tabButton:FindFirstChild("Overlay")
    local label = overlay and overlay:FindFirstChild("Label")

    function object:SetAppearance(active, instant)
        local duration = instant and 0 or Library.Config.Animation.Normal

        if active then
            Tween(tabButton, {ImageTransparency = 0}, duration)
            if label then
                Tween(label, {
                    TextColor3 = Library.Config.Colors.Text,
                }, duration)
            end
        else
            Tween(tabButton, {ImageTransparency = 0.3}, duration)
            if label then
                Tween(label, {
                    TextColor3 = Library.Config.Colors.SecondaryText,
                }, duration)
            end
        end
    end

    function object:CreateFrame(frameName)
        local frame = Create("Frame", {
            Name = tostring(frameName or "Frame"),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 65),
        }, tabContent)

        local title = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.03, 0),
            Size = UDim2.fromScale(0.94, 0.18),
            Font = Enum.Font.Nunito,
            Text = tostring(frameName or "Frame"),
            TextColor3 = Library.Config.Colors.Text,
            TextScaled = true,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, frame)

        local componentContainer = Create("Frame", {
            Name = "Components",
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.03, 0.2),
            Size = UDim2.new(0.94, 0, 0, 0),
        }, frame)

        local layout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, componentContainer)

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
        }, componentContainer)

        local frameObject = BuildFrameObject(object, componentContainer)
        frameObject.Root = frame
        frameObject.Title = title
        frameObject.Components = componentContainer

        local function UpdateFrameSize()
            local height = layout.AbsoluteContentSize.Y

            componentContainer.Size = UDim2.new(
                0.94,
                0,
                0,
                height + 5
            )

            frame.Size = UDim2.new(
                1,
                0,
                0,
                math.max(65, height + 60)
            )
        end

        frameObject._layoutConnection = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateFrameSize)
        table.insert(frameObject._connections, frameObject._layoutConnection)

        task.defer(UpdateFrameSize)

        table.insert(object.Frames, frameObject)
        return frameObject
    end

    function object:SetVisible(visible)
        tabContent.Visible = visible
    end

    function object:Destroy()
        DisconnectAll(self)

        local index = table.find(Library.Tabs, self)
        if index then
            table.remove(Library.Tabs, index)
        end

        if self.Button then
            self.Button:Destroy()
        end
        if self.Instance then
            self.Instance:Destroy()
        end

        if Library.CurrentTab == self then
            Library.CurrentTab = nil
        end
    end

    return object
end

---------------------------------------------------------------------
-- CREATE TAB
---------------------------------------------------------------------

function Library:CreateTab(tabName)
    assert(not Library._destroyed, "SkyFi-UI has been destroyed")

    tabName = tostring(tabName or "Tab")

    local tabContent = Create("ScrollingFrame", {
        Name = tabName,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Active = true,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false,
    }, TabsContainer)

    Create("UIPadding", {
        PaddingTop = UDim.new(0.02, 0),
        PaddingBottom = UDim.new(0.03, 0),
        PaddingLeft = UDim.new(0.03, 0),
        PaddingRight = UDim.new(0.03, 0),
    }, tabContent)

    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, tabContent)

    local tabButton = Create("ImageButton", {
        Name = tabName:gsub("%s+", "_"),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.79, 0.086),
        Image = GetTabIcon(tabName),
        AutoButtonColor = false,
        LayoutOrder = #Library.Tabs + 1,
    }, TabButtonScrolling)

    local overlay = Create("Frame", {
        Name = "Overlay",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
    }, tabButton)

    AddCorner(overlay, 0.2)

    Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.12, 0),
        Size = UDim2.fromScale(0.78, 1),
        Font = Enum.Font.Nunito,
        Text = tabName,
        TextColor3 = Library.Config.Colors.SecondaryText,
        TextScaled = true,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, overlay)

    local tabObject = BuildTabObject(tabName, tabContent, tabButton)

    TrackConnection(tabObject, tabButton.MouseEnter:Connect(function()
        if Library.CurrentTab == tabObject then
            return
        end

        Tween(tabButton, {
            ImageTransparency = 0,
        }, Library.Config.Animation.Fast)

        Tween(tabObject.Button.Overlay.Label, {
            TextColor3 = Library.Config.Colors.Text,
        }, Library.Config.Animation.Fast)
    end))

    TrackConnection(tabObject, tabButton.MouseLeave:Connect(function()
        if Library.CurrentTab == tabObject then
            return
        end

        Tween(tabButton, {
            ImageTransparency = 0.3,
        }, Library.Config.Animation.Fast)

        Tween(tabObject.Button.Overlay.Label, {
            TextColor3 = Library.Config.Colors.SecondaryText,
        }, Library.Config.Animation.Fast)
    end))

    TrackConnection(tabObject, tabButton.Activated:Connect(function()
        Library:SelectTab(tabObject)
    end))

    table.insert(Library.Tabs, tabObject)

    if not Library.CurrentTab then
        Library:SelectTab(tabObject, true)
    end

    return tabObject
end

---------------------------------------------------------------------
-- SELECT TAB
---------------------------------------------------------------------

function Library:SelectTab(tab, instant)
    if Library._destroyed or not tab then
        return
    end

    local valid = table.find(Library.Tabs, tab) ~= nil
    if not valid then
        return
    end

    Library.CurrentTab = tab

    for _, otherTab in ipairs(Library.Tabs) do
        local active = otherTab == tab
        otherTab:SetVisible(active)
        otherTab:SetAppearance(active, instant == true)
    end
end

---------------------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------------------

function Library:SetVisible(visible)
    if not Library._destroyed then
        ScreenGui.Enabled = visible == true
    end
end

function Library:Toggle()
    if not Library._destroyed then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end

function Library:SetTitle(text)
    Library.Config.Title = tostring(text)
    if Title and Title.Parent then
        Title.Text = Library.Config.Title
    end
end

function Library:AddTabIcon(keyword, imageId)
    assert(typeof(keyword) == "string", "keyword must be a string")
    assert(typeof(imageId) == "string", "imageId must be a string")

    table.insert(Library.Config.TabIcons, {
        Keyword = keyword,
        Image = imageId,
    })
end

function Library:SetDefaultTabIcon(imageId)
    assert(typeof(imageId) == "string", "imageId must be a string")
    Library.Config.DefaultTabIcon = imageId
end

function Library:Destroy()
    if Library._destroyed then
        return
    end

    Library._destroyed = true
    Library._dragging = false

    for _, tab in ipairs(Library.Tabs) do
        DisconnectAll(tab)
    end

    DisconnectAll(Library)

    if ScreenGui then
        ScreenGui:Destroy()
    end

    table.clear(Library.Tabs)
    Library.CurrentTab = nil
end

return Library
