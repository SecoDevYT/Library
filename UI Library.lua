Library = {}

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
