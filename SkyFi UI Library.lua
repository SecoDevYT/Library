-- SkyFi-UI
-- Advanced Roblox UI Library
-- CURRENT VISUAL REBUILD: 2026-08-16
-- VERSION TAG: SKYFI-VISUAL-MATCH-02
-- SECOND VISUAL PASS: SMALLER WINDOW / MORE SPACING / FIXED COMPONENT SIZING
--
-- IMPORTANT CHANGES IN THIS BUILD:
--   * NO global UI title
--   * The tab name is the ONLY title, inside the selected tab
--   * Tab buttons are IMAGE-ONLY and forced to a perfect square
--   * Top/sidebar split gradients use dedicated visible gradient-holder frames
--   * CreateFrame() creates the dark rounded component container, NOT a titled frame
--   * Component controls live INSIDE that container instead of each becoming its own card
--   * Scrolling uses an explicit CanvasSize calculation
--   * Main window keeps a stable aspect ratio and uses a responsive UIScale
--   * Smooth dragging is preserved
--
-- GitHub filename:
-- SkyFi UI Library.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {}

---------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------

Library.Config = {
    Version = "SKYFI-VISUAL-MATCH-02",

    DefaultTabIcon = "rbxassetid://103521649749710",

    -- Ordered entries. The first matching keyword wins.
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

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------

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
        return
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
-- ROOT GUI
---------------------------------------------------------------------

local ScreenGui = Create("ScreenGui", {
    Name = "SkyFi_UI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, PlayerGui)

Library.ScreenGui = ScreenGui

---------------------------------------------------------------------
-- MAIN WINDOW
---------------------------------------------------------------------

local MainFrame = Create("Frame", {
    Name = "Main",
    BackgroundColor3 = Library.Config.Colors.Background,
    BorderSizePixel = 0,

    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),

    -- Stable pixel base size. UIScale below handles screen-size changes.
    Size = UDim2.fromOffset(600, 390),
}, ScreenGui)

Library.MainFrame = MainFrame

-- Slightly smaller than the original outer corner.
AddCorner(MainFrame, 0.055)

Create("UIAspectRatioConstraint", {
    AspectRatio = 1.536,
}, MainFrame)

local UIScale = Create("UIScale", {
    Scale = 1,
}, MainFrame)

local function UpdateUIScale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local referenceWidth = 1600

    -- Keeps the UI compact on fullscreen while remaining usable
    -- in smaller Roblox windows.
    local scale = math.clamp(viewport.X / referenceWidth, 0.80, 1)

    UIScale.Scale = scale
end

UpdateUIScale()

local cameraConnection
local function BindCamera()
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end

    local camera = workspace.CurrentCamera
    if camera then
        cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateUIScale)
        TrackConnection(Library, cameraConnection)
    end
end

BindCamera()

TrackConnection(Library, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    BindCamera()
    UpdateUIScale()
end))

---------------------------------------------------------------------
-- TOP SECTION
---------------------------------------------------------------------

-- This is the invisible drag zone.
local TopBar = Create("Frame", {
    Name = "TopBar",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 0.164),
    Active = true,
}, MainFrame)

-- IMPORTANT:
-- The gradient is on a REAL visible frame, just like the converted GUI.
local TopGradientFrame = Create("Frame", {
    Name = "TopGradient",
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 0.164),
}, MainFrame)

TopGradientFrame.ZIndex = 2

Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39)),
    }),
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 1.00),
        NumberSequenceKeypoint.new(0.96, 1.00),
        NumberSequenceKeypoint.new(0.96, 0.00),
        NumberSequenceKeypoint.new(1.00, 0.00),
    }),
}, TopGradientFrame)

-- Logo. No title.
local Logo = Create("ImageLabel", {
    Name = "Logo",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,

    Position = UDim2.fromScale(0.02045, 0.0266),
    Size = UDim2.fromOffset(28, 27),

    Image = "rbxassetid://88799636029598",
    ScaleType = Enum.ScaleType.Fit,
}, MainFrame)

Logo.ZIndex = 5

-- Close button.
local Close = Create("ImageButton", {
    Name = "Close",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,

    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.fromScale(0.99, 0.018),

    Size = UDim2.fromScale(0.0815, 0.1277),

    Image = "rbxassetid://97652315417935",
    ScaleType = Enum.ScaleType.Fit,

    AutoButtonColor = false,
}, MainFrame)

Close.ZIndex = 6

TrackConnection(Library, Close.MouseEnter:Connect(function()
    Tween(Close, {ImageTransparency = 0.3}, Library.Config.Animation.Fast)
end))

TrackConnection(Library, Close.MouseLeave:Connect(function()
    Tween(Close, {ImageTransparency = 0}, Library.Config.Animation.Fast)
end))

---------------------------------------------------------------------
-- SIDEBAR
---------------------------------------------------------------------

local Sidebar = Create("Frame", {
    Name = "TabButtons",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,

    Position = UDim2.fromScale(0, 0.1642857),
    Size = UDim2.fromScale(0.1255814, 0.8357143),
}, MainFrame)

-- REAL visible gradient-holder frame.
local SidebarGradientFrame = Create("Frame", {
    Name = "SidebarGradient",
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,

    Position = UDim2.fromScale(0, 0.1642857),
    Size = UDim2.fromScale(0.1255814, 0.8357143),
}, MainFrame)

SidebarGradientFrame.ZIndex = 2

Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(39, 39, 39)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 1.00),
        NumberSequenceKeypoint.new(0.96, 1.00),
        NumberSequenceKeypoint.new(0.96, 0.00),
        NumberSequenceKeypoint.new(1.00, 0.00),
    }),
}, SidebarGradientFrame)

local TabButtonScrolling = Create("ScrollingFrame", {
    Name = "TabButtonScrolling",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,

    Size = UDim2.fromScale(1, 1),

    Active = true,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
}, Sidebar)

TabButtonScrolling.ZIndex = 4

Create("UIPadding", {
    PaddingTop = UDim.new(0.0286, 0),
    PaddingBottom = UDim.new(0.02, 0),
    PaddingLeft = UDim.new(0.096, 0),
    PaddingRight = UDim.new(0.096, 0),
}, TabButtonScrolling)

local TabButtonLayout = Create("UIListLayout", {
    Padding = UDim.new(0.02, 0),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, TabButtonScrolling)

TrackConnection(Library, TabButtonLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabButtonScrolling.CanvasSize = UDim2.fromOffset(
        0,
        TabButtonLayout.AbsoluteContentSize.Y + 20
    )
end))

---------------------------------------------------------------------
-- CONTENT AREA
---------------------------------------------------------------------

local TabsContainer = Create("Frame", {
    Name = "Tabs",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,

    Position = UDim2.fromScale(0.1255814, 0.1642857),
    Size = UDim2.fromScale(0.8744186, 0.8321428),
}, MainFrame)

TabsContainer.ZIndex = 3

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

TrackConnection(Library, UserInputService.InputChanged:Connect(function(input)
    if not Library._dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    if not Library._dragStart or not Library._startPosition then
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

TrackConnection(Library, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Library._dragging = false
    end
end))

TrackConnection(Library, UserInputService.WindowFocusReleased:Connect(function()
    Library._dragging = false
end))

TrackConnection(Library, Close.Activated:Connect(function()
    Library:Destroy()
end))

---------------------------------------------------------------------
-- COMPONENT CONTAINER
---------------------------------------------------------------------

-- One CreateFrame() = the dark rounded Tempframe from the source GUI.
-- Components live directly inside it.
local function CreateComponentContainer(parent)
    local frame = Create("Frame", {
        Name = "Tempframe",
        BackgroundColor3 = Library.Config.Colors.Container,
        BorderSizePixel = 0,

        Size = UDim2.new(0.8378, 0, 0, 100),
    }, parent)

    AddCorner(frame, 0.10)
    local stroke = AddStroke(frame, Library.Config.Colors.Stroke, 1)

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, frame)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
    }, frame)

    return frame, layout, stroke
end

local function UpdateContainerHeight(frame, layout)
    local height = layout.AbsoluteContentSize.Y + 28
    frame.Size = UDim2.new(0.8378, 0, 0, math.max(120, height))
end

---------------------------------------------------------------------
-- BUTTON
---------------------------------------------------------------------

local function CreateButton(componentParent, text, callback)
    local object = {
        _connections = {},
    }

    local button = Create("TextButton", {
        Name = "TempButton",

        BackgroundColor3 = Library.Config.Colors.Button,
        BorderSizePixel = 0,

        Size = UDim2.fromScale(0.5713, 0.1714),
        -- Absolute Y size is controlled by the parent layout.
        AutomaticSize = Enum.AutomaticSize.None,

        AutoButtonColor = false,

        Font = Enum.Font.Nunito,
        Text = tostring(text),
        TextColor3 = Library.Config.Colors.Text,
        TextScaled = true,
        TextWrapped = true,
    }, componentParent)

    -- The source uses a proportional button inside the frame.
    button.Size = UDim2.new(0.5713, 0, 0, 42)
    Create("UISizeConstraint", {
        MaxSize = Vector2.new(285, 42),
        MinSize = Vector2.new(180, 42),
    }, button)

    AddCorner(button, 0.10)
    AddStroke(button, Library.Config.Colors.ButtonStroke, 1)

    object.Button = button
    object.Instance = button

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
        button:Destroy()
    end

    return object
end

---------------------------------------------------------------------
-- LABEL
---------------------------------------------------------------------

local function CreateLabel(componentParent, text)
    local object = {}

    local label = Create("TextLabel", {
        Name = "TempLabel",

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.9969, 0, 0, 44),

        Font = Enum.Font.Nunito,
        Text = tostring(text),
        TextColor3 = Library.Config.Colors.SecondaryText,

        TextScaled = true,
        TextWrapped = true,
    }, componentParent)

    object.Label = label
    object.Instance = label

    function object:SetText(newText)
        label.Text = tostring(newText)
    end

    function object:Destroy()
        label:Destroy()
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

    local holder = Create("Frame", {
        Name = "TempToggle",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.4509, 0, 0, 42),

        -- Keep the toggle compact rather than letting it become a long bar.
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
    }, componentParent)

    local toggler = Create("TextButton", {
        Name = "Toggler",

        BackgroundColor3 = object.Enabled
            and Library.Config.Colors.ToggleOn
            or Library.Config.Colors.ToggleOff,

        BorderSizePixel = 0,

        Size = UDim2.fromScale(1, 1),

        AutoButtonColor = false,
        Text = "",
    }, holder)

    Create("UISizeConstraint", {
        MaxSize = Vector2.new(190, 42),
        MinSize = Vector2.new(150, 42),
    }, toggler
    }, holder)

    AddCorner(toggler, 0.5)

    local knob = Create("Frame", {
        Name = "ToggleFrame",

        BackgroundColor3 = Library.Config.Colors.ToggleKnob,
        BorderSizePixel = 0,

        Position = object.Enabled
            and UDim2.fromScale(0.614, 0.098)
            or UDim2.fromScale(0.05, 0.098),

        Size = UDim2.fromScale(0.333, 0.784),
    }, toggler)

    AddCorner(knob, 0.5)

    object.Toggle = toggler
    object.Instance = holder

    local function UpdateToggle(newValue, fireCallback)
        object.Enabled = newValue == true

        Tween(toggler, {
            BackgroundColor3 = object.Enabled
                and Library.Config.Colors.ToggleOn
                or Library.Config.Colors.ToggleOff,
        })

        Tween(knob, {
            Position = object.Enabled
                and UDim2.fromScale(0.614, 0.098)
                or UDim2.fromScale(0.05, 0.098),
        })

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
        holder:Destroy()
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

    local holder = Create("Frame", {
        Name = "TempSlider",

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.9433, 0, 0, 68),
    }, componentParent)

    local sliderBar = Create("Frame", {
        Name = "SlideBar",

        BackgroundColor3 = Library.Config.Colors.SliderBar,
        BorderSizePixel = 0,

        Position = UDim2.fromScale(0.003, 0.09),
        Size = UDim2.fromScale(0.994, 0.16),
    }, holder)

    AddCorner(sliderBar, 10)

    local knob = Create("TextButton", {
        Name = "SliderButton",

        BackgroundColor3 = Library.Config.Colors.SliderKnob,
        BorderSizePixel = 0,

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.fromScale(0.0991, 2),

        AutoButtonColor = false,
        Text = "",
    }, sliderBar)

    AddCorner(knob, 10)

    local valueLabel = Create("TextLabel", {
        Name = "Label",

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Position = UDim2.fromScale(-0.0214, 0.4164),
        Size = UDim2.fromScale(1.048, 0.5395),

        Font = Enum.Font.Nunito,
        Text = tostring(value),

        TextColor3 = Library.Config.Colors.SecondaryText,
        TextScaled = true,
        TextWrapped = true,
    }, holder)

    object.Instance = holder
    object.Slider = sliderBar

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

    local function SetFromMouse(mouseX, fireCallback)
        local x = sliderBar.AbsolutePosition.X
        local width = sliderBar.AbsoluteSize.X

        if width <= 0 then
            return
        end

        local alpha = Clamp(
            (mouseX - x) / width,
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

    TrackConnection(object, sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            SetFromMouse(input.Position.X, true)
        end
    end))

    TrackConnection(object, knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            SetFromMouse(input.Position.X, true)
        end
    end))

    TrackConnection(object, UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            SetFromMouse(input.Position.X, true)
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
        holder:Destroy()
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

    local frame = Create("Frame", {
        Name = "List",

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.new(0.9, 0, 0, 55),
    }, componentParent)

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, frame)

    local function UpdateHeight()
        frame.Size = UDim2.new(
            0.9,
            0,
            0,
            math.max(34, layout.AbsoluteContentSize.Y)
        )
    end

    TrackConnection(
        object,
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)
    )

    function object:Add(item)
        local index = #object.Items + 1

        local button = Create("TextButton", {
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

        AddCorner(button, 0.1)

        local data = {
            Value = item,
            Button = button,
            _connections = {},
        }

        table.insert(object.Items, data)

        TrackConnection(data, button.MouseEnter:Connect(function()
            Tween(button, {
                BackgroundColor3 = Library.Config.Colors.ButtonHover,
            }, Library.Config.Animation.Fast)
        end))

        TrackConnection(data, button.MouseLeave:Connect(function()
            Tween(button, {
                BackgroundColor3 = Library.Config.Colors.Button,
            }, Library.Config.Animation.Fast)
        end))

        TrackConnection(data, button.Activated:Connect(function()
            if typeof(callback) == "function" then
                task.spawn(
                    callback,
                    data.Value,
                    table.find(object.Items, data)
                )
            end
        end))

        task.defer(UpdateHeight)

        return data
    end

    function object:Remove(index)
        local data = object.Items[index]

        if not data then
            return false
        end

        DisconnectAll(data)

        if data.Button then
            data.Button:Destroy()
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
            self:Remove(index)
        end
    end

    function object:Destroy()
        self:Clear()
        DisconnectAll(self)
        frame:Destroy()
    end

    for _, item in ipairs(options.items or {}) do
        object:Add(item)
    end

    task.defer(UpdateHeight)

    object.Instance = frame
    return object
end

---------------------------------------------------------------------
-- FRAME OBJECT
---------------------------------------------------------------------

local function BuildFrameObject(frame, tabObject)
    local object = {
        Instance = frame,
        ParentTab = tabObject,
        _connections = {},
    }

    function object:CreateButton(text, callback)
        return CreateButton(frame, text, callback)
    end

    function object:CreateLabel(text)
        return CreateLabel(frame, text)
    end

    function object:CreateToggle(text, default, callback)
        return CreateToggle(frame, text, default, callback)
    end

    function object:CreateSlider(options, callback)
        return CreateSlider(frame, options, callback)
    end

    function object:CreateList(options, callback)
        return CreateList(frame, options, callback)
    end

    function object:SetVisible(visible)
        frame.Visible = visible == true
    end

    function object:Destroy()
        DisconnectAll(self)
        frame:Destroy()
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

    function object:SetAppearance(active, instant)
        local duration = instant and 0 or Library.Config.Animation.Normal

        Tween(
            tabButton,
            {
                ImageTransparency = active and 0 or 0.3,
            },
            duration
        )
    end

    -- IMPORTANT:
    -- The tab title is created ONCE here.
    -- CreateFrame() does NOT create a title.
    local tabTitle = Create("TextLabel", {
        Name = "Title",

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Position = UDim2.fromScale(0.0055, 0),
        Size = UDim2.fromScale(0.9969, 0.1432),

        Font = Enum.Font.Nunito,
        Text = tabName,
        TextColor3 = Library.Config.Colors.Text,

        TextScaled = true,
        TextWrapped = true,
    }, tabContent)

    tabTitle.LayoutOrder = 1

    object.Title = tabTitle

    function object:CreateFrame()
        local frame = CreateComponentContainer(tabContent)

        frame.LayoutOrder = #object.Frames + 2

        local layout = frame:FindFirstChildOfClass("UIListLayout")

        local frameObject = BuildFrameObject(frame, object)

        frameObject.Root = frame
        frameObject.Layout = layout

        TrackConnection(
            frameObject,
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                UpdateContainerHeight(frame, layout)
            end)
        )

        task.defer(function()
            UpdateContainerHeight(frame, layout)
        end)

        table.insert(object.Frames, frameObject)

        return frameObject
    end

    function object:SetVisible(visible)
        tabContent.Visible = visible == true
    end

    function object:Destroy()
        DisconnectAll(self)

        local index = table.find(Library.Tabs, self)
        if index then
            table.remove(Library.Tabs, index)
        end

        if Library.CurrentTab == self then
            Library.CurrentTab = nil
        end

        if tabButton then
            tabButton:Destroy()
        end

        if tabContent then
            tabContent:Destroy()
        end
    end

    return object
end

---------------------------------------------------------------------
-- CREATE TAB
---------------------------------------------------------------------

function Library:CreateTab(tabName)
    assert(not Library._destroyed, "SkyFi-UI has already been destroyed")

    tabName = tostring(tabName or "Tab")

    local tabContent = Create("ScrollingFrame", {
        Name = tabName,

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Size = UDim2.fromScale(1, 1),

        Active = true,

        ScrollBarThickness = 0,

        CanvasSize = UDim2.new(0, 0, 0, 0),

        Visible = false,
    }, TabsContainer)

    tabContent.ZIndex = 4

    Create("UIPadding", {
        PaddingTop = UDim.new(0.01, 0),
        PaddingBottom = UDim.new(0.03, 0),
    }, tabContent)

    local contentLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),

        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, tabContent)

    local function UpdateTabCanvas()
        tabContent.CanvasSize = UDim2.fromOffset(
            0,
            contentLayout.AbsoluteContentSize.Y + 16
        )
    end

    TrackConnection(
        Library,
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateTabCanvas)
    )

    local tabButton = Create("ImageButton", {
        Name = tabName:gsub("%s+", "_"),

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        -- Bigger than the previous build while remaining a perfect square.
        Size = UDim2.fromOffset(42, 42),

        Image = GetTabIcon(tabName),

        ScaleType = Enum.ScaleType.Fit,

        AutoButtonColor = false,

        LayoutOrder = #Library.Tabs + 1,
    }, TabButtonScrolling)

    tabButton.ZIndex = 5

    Create("UIAspectRatioConstraint", {
        AspectRatio = 1,
    }, tabButton)

    Create("UISizeConstraint", {
        MaxSize = Vector2.new(48, 48),
        MinSize = Vector2.new(38, 38),
    }, tabButton)

    local tabObject = BuildTabObject(
        tabName,
        tabContent,
        tabButton
    )

    TrackConnection(tabObject, tabButton.MouseEnter:Connect(function()
        if Library.CurrentTab == tabObject then
            return
        end

        Tween(
            tabButton,
            {
                ImageTransparency = 0,
            },
            Library.Config.Animation.Fast
        )
    end))

    TrackConnection(tabObject, tabButton.MouseLeave:Connect(function()
        if Library.CurrentTab == tabObject then
            return
        end

        Tween(
            tabButton,
            {
                ImageTransparency = 0.3,
            },
            Library.Config.Animation.Fast
        )
    end))

    TrackConnection(tabObject, tabButton.Activated:Connect(function()
        Library:SelectTab(tabObject)
    end))

    table.insert(Library.Tabs, tabObject)

    UpdateTabCanvas()

    if not Library.CurrentTab then
        Library:SelectTab(tabObject, true)
    end

    return tabObject
end

---------------------------------------------------------------------
-- TAB SELECTION
---------------------------------------------------------------------

function Library:SelectTab(tab, instant)
    if Library._destroyed or not tab then
        return
    end

    if not table.find(Library.Tabs, tab) then
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
