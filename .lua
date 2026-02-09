local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local PinkLib = {}

-- // НАСТРОЙКИ ТЕМЫ //
local Theme = {
    Background = Color3.fromRGB(18, 15, 18),
    Section = Color3.fromRGB(26, 23, 26),
    SectionHover = Color3.fromRGB(32, 29, 32),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 150, 160),
    Pink1 = Color3.fromHex("FCA8FD"),
    Pink2 = Color3.fromHex("FED4FE"),
    Pink3 = Color3.fromHex("E0B5DA"),
    StatusOff = Color3.fromRGB(45, 40, 45),
    StatusOn = Color3.fromHex("FCA8FD")
}

-- // УТИЛИТЫ //
local Gradients = {}

local function ApplyGradient(instance)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Theme.Pink1),
        ColorSequenceKeypoint.new(0.50, Theme.Pink2),
        ColorSequenceKeypoint.new(1.00, Theme.Pink3)
    }
    gradient.Rotation = 45
    gradient.Parent = instance
    table.insert(Gradients, gradient)
    return gradient
end

RunService.RenderStepped:Connect(function()
    local rotation = (os.clock() * 45) % 360
    for _, grad in pairs(Gradients) do
        grad.Rotation = rotation
    end
end)

-- // ГЛАВНАЯ ФУНКЦИЯ СОЗДАНИЯ ОКНА //
function PinkLib:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Title or "Pink Panel"
    local AutoMobileScale = Config.MobileFriendly or true
    local ScaleFactor = Config.Scale or 1.0

    -- Авто-определение мобилки
    if AutoMobileScale and UserInputService.TouchEnabled then
        ScaleFactor = 0.85 -- Уменьшаем для телефонов
    end

    -- Удаление старого UI
    if CoreGui:FindFirstChild("PinkLibUI") then
        CoreGui.PinkLibUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PinkLibUI"
    if syn and syn.protect_gui then 
        syn.protect_gui(ScreenGui) 
        ScreenGui.Parent = CoreGui 
    else 
        ScreenGui.Parent = CoreGui 
    end

    -- // ФРЕЙМ ОКНА //
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 250 * ScaleFactor, 0, 340 * ScaleFactor) 
    MainFrame.Position = UDim2.new(0.5, -125 * ScaleFactor, 0.5, -170 * ScaleFactor)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.6
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Color = Theme.Pink1
    MainStroke.Parent = MainFrame
    ApplyGradient(MainStroke)

    -- // HEADER //
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40 * ScaleFactor)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = Title
    TitleText.Font = Enum.Font.GothamBlack
    TitleText.TextSize = 17 * ScaleFactor
    TitleText.TextColor3 = Theme.Text
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = Header
    ApplyGradient(TitleText)

    -- Кнопка сворачивания
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30 * ScaleFactor, 0, 30 * ScaleFactor)
    MinimizeBtn.Position = UDim2.new(1, -35 * ScaleFactor, 0, 5)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.Font = Enum.Font.GothamBlack
    MinimizeBtn.TextSize = 24 * ScaleFactor
    MinimizeBtn.TextColor3 = Theme.Pink1
    MinimizeBtn.Parent = Header

    -- // МОБИЛЬНЫЙ DRAG SYSTEM //
    local Dragging, DragInput, DragStart, StartPos
    
    local function UpdateDrag(input)
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(
            StartPos.X.Scale, 
            StartPos.X.Offset + Delta.X, 
            StartPos.Y.Scale, 
            StartPos.Y.Offset + Delta.Y
        )
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdateDrag(input)
        end
    end)

    -- // КОНТЕЙНЕР ЭЛЕМЕНТОВ //
    local ScrollContainer = Instance.new("ScrollingFrame")
    ScrollContainer.Size = UDim2.new(1, -10, 1, -40 * ScaleFactor)
    ScrollContainer.Position = UDim2.new(0, 5, 0, 40 * ScaleFactor)
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.BorderSizePixel = 0
    ScrollContainer.ScrollBarThickness = 2
    ScrollContainer.ScrollBarImageColor3 = Theme.Pink2
    ScrollContainer.ClipsDescendants = true
    ScrollContainer.Parent = MainFrame

    local ScrollPadding = Instance.new("UIPadding")
    ScrollPadding.PaddingTop = UDim.new(0, 10)
    ScrollPadding.PaddingBottom = UDim.new(0, 10)
    ScrollPadding.Parent = ScrollContainer

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = ScrollContainer

    -- Логика сворачивания
    local Minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 250 * ScaleFactor, 0, 40 * ScaleFactor)}):Play()
            ScrollContainer.Visible = false
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 250 * ScaleFactor, 0, 340 * ScaleFactor)}):Play()
            task.delay(0.2, function() ScrollContainer.Visible = true end)
        end
    end)

    -- // КОМПОНЕНТЫ ОКНА //
    local Window = {}

    -- [Notification System]
    function Window:Notify(title, text, duration)
        local NotifyGui = ScreenGui:FindFirstChild("Notifications")
        if not NotifyGui then
            NotifyGui = Instance.new("Frame")
            NotifyGui.Name = "Notifications"
            NotifyGui.Size = UDim2.new(0, 200, 1, 0)
            NotifyGui.Position = UDim2.new(1, -210, 0, 0)
            NotifyGui.BackgroundTransparency = 1
            NotifyGui.Parent = ScreenGui
            
            local NList = Instance.new("UIListLayout")
            NList.Padding = UDim.new(0, 5)
            NList.VerticalAlignment = Enum.VerticalAlignment.Bottom
            NList.Parent = NotifyGui
            
            local NPad = Instance.new("UIPadding")
            NPad.PaddingBottom = UDim.new(0, 50) -- Выше на мобилках
            NPad.Parent = NotifyGui
        end

        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 0)
        Card.BackgroundColor3 = Theme.Section
        Card.BorderSizePixel = 0
        Card.ClipsDescendants = true
        Card.Parent = NotifyGui
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Pink1
        Stroke.Thickness = 1.5
        Stroke.Parent = Card
        ApplyGradient(Stroke)

        local TxtTitle = Instance.new("TextLabel")
        TxtTitle.Size = UDim2.new(1, -10, 0, 20)
        TxtTitle.Position = UDim2.new(0, 5, 0, 2)
        TxtTitle.BackgroundTransparency = 1
        TxtTitle.Text = title
        TxtTitle.Font = Enum.Font.GothamBold
        TxtTitle.TextColor3 = Theme.Pink1
        TxtTitle.TextSize = 12
        TxtTitle.TextXAlignment = Enum.TextXAlignment.Left
        TxtTitle.Parent = Card

        local TxtDesc = Instance.new("TextLabel")
        TxtDesc.Size = UDim2.new(1, -10, 0, 30)
        TxtDesc.Position = UDim2.new(0, 5, 0, 18)
        TxtDesc.BackgroundTransparency = 1
        TxtDesc.Text = text
        TxtDesc.Font = Enum.Font.Gotham
        TxtDesc.TextColor3 = Theme.Text
        TxtDesc.TextSize = 11
        TxtDesc.TextWrapped = true
        TxtDesc.TextXAlignment = Enum.TextXAlignment.Left
        TxtDesc.Parent = Card

        TweenService:Create(Card, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 50)}):Play()
        
        task.delay(duration or 3, function()
            TweenService:Create(Card, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}):Play()
            Stroke.Enabled = false
            TxtTitle.TextTransparency = 1
            TxtDesc.TextTransparency = 1
            task.wait(0.3)
            Card:Destroy()
        end)
    end

    -- [Section]
    function Window:Section(text)
        local SecLabel = Instance.new("TextLabel")
        SecLabel.Size = UDim2.new(1, -20, 0, 20 * ScaleFactor)
        SecLabel.BackgroundTransparency = 1
        SecLabel.Text = text
        SecLabel.Font = Enum.Font.GothamBlack
        SecLabel.TextSize = 11 * ScaleFactor
        SecLabel.TextColor3 = Theme.Pink2
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
        SecLabel.Parent = ScrollContainer
    end

    -- [Button]
    function Window:Button(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -12, 0, 32 * ScaleFactor)
        Btn.BackgroundColor3 = Theme.Section
        Btn.AutoButtonColor = false
        Btn.Text = text
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 12 * ScaleFactor
        Btn.TextColor3 = Theme.TextDim
        Btn.Parent = ScrollContainer
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 1
        Stroke.Color = Color3.fromRGB(45, 40, 45)
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Parent = Btn

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SectionHover, TextColor3 = Theme.Text}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Theme.Pink3}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Section, TextColor3 = Theme.TextDim}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 40, 45)}):Play()
        end)
        Btn.MouseButton1Click:Connect(callback)
    end

    -- [Toggle]
    function Window:Toggle(text, default, callback)
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, -12, 0, 38 * ScaleFactor)
        ToggleBtn.BackgroundColor3 = Theme.Section
        ToggleBtn.AutoButtonColor = false
        ToggleBtn.Text = ""
        ToggleBtn.Parent = ScrollContainer
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 1
        Stroke.Color = Color3.fromRGB(45, 40, 45)
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Parent = ToggleBtn

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12 * ScaleFactor
        Label.TextColor3 = Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleBtn

        local StatusFrame = Instance.new("Frame")
        StatusFrame.Size = UDim2.new(0, 40 * ScaleFactor, 0, 22 * ScaleFactor)
        StatusFrame.Position = UDim2.new(1, -50 * ScaleFactor, 0.5, -11 * ScaleFactor)
        StatusFrame.BackgroundColor3 = default and Theme.StatusOn or Theme.StatusOff
        StatusFrame.BorderSizePixel = 0
        StatusFrame.Parent = ToggleBtn
        Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 6)

        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Size = UDim2.new(1, 0, 1, 0)
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.Text = default and "ON" or "OFF"
        StatusLabel.Font = Enum.Font.GothamBlack
        StatusLabel.TextSize = 10 * ScaleFactor
        StatusLabel.TextColor3 = default and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(120, 120, 120)
        StatusLabel.Parent = StatusFrame

        local Enabled = default
        ToggleBtn.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            callback(Enabled)
            if Enabled then
                TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
                TweenService:Create(StatusFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.StatusOn}):Play()
                StatusLabel.Text = "ON"
                StatusLabel.TextColor3 = Color3.fromRGB(20, 20, 25)
            else
                TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
                TweenService:Create(StatusFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.StatusOff}):Play()
                StatusLabel.Text = "OFF"
                StatusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
            end
        end)
    end

    -- [Slider]
    function Window:Slider(text, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -12, 0, 50 * ScaleFactor)
        SliderFrame.BackgroundColor3 = Theme.Section
        SliderFrame.Parent = ScrollContainer
        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 1
        Stroke.Color = Color3.fromRGB(45, 40, 45)
        Stroke.Parent = SliderFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -24, 0, 20 * ScaleFactor)
        Label.Position = UDim2.new(0, 12, 0, 5)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12 * ScaleFactor
        Label.TextColor3 = Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(1, -24, 0, 20 * ScaleFactor)
        ValueLabel.Position = UDim2.new(0, 12, 0, 5)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(default)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 12 * ScaleFactor
        ValueLabel.TextColor3 = Theme.Pink1
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame

        local SliderBarBg = Instance.new("Frame")
        SliderBarBg.Size = UDim2.new(1, -24, 0, 6 * ScaleFactor)
        SliderBarBg.Position = UDim2.new(0, 12, 0, 32 * ScaleFactor)
        SliderBarBg.BackgroundColor3 = Color3.fromRGB(40, 35, 40)
        SliderBarBg.BorderSizePixel = 0
        SliderBarBg.Parent = SliderFrame
        Instance.new("UICorner", SliderBarBg).CornerRadius = UDim.new(1, 0)

        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = Theme.Pink1
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBarBg
        Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
        ApplyGradient(SliderFill)

        local DraggingSlider = false
        local function UpdateSlider(input)
            local SizeX = math.clamp((input.Position.X - SliderBarBg.AbsolutePosition.X) / SliderBarBg.AbsoluteSize.X, 0, 1)
            local NewValue = math.floor(min + ((max - min) * SizeX))
            TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
            ValueLabel.Text = tostring(NewValue)
            callback(NewValue)
        end

        SliderBarBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                DraggingSlider = true
                UpdateSlider(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if DraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                DraggingSlider = false
            end
        end)
    end

    -- [Input]
    function Window:Input(text, placeholder, callback)
        local InputFrame = Instance.new("Frame")
        InputFrame.Size = UDim2.new(1, -12, 0, 50 * ScaleFactor)
        InputFrame.BackgroundColor3 = Theme.Section
        InputFrame.Parent = ScrollContainer
        Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 8)

        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 1
        Stroke.Color = Color3.fromRGB(45, 40, 45)
        Stroke.Parent = InputFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -24, 0, 20 * ScaleFactor)
        Label.Position = UDim2.new(0, 12, 0, 5)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12 * ScaleFactor
        Label.TextColor3 = Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = InputFrame

        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, -24, 0, 20 * ScaleFactor)
        TextBox.Position = UDim2.new(0, 12, 0, 25 * ScaleFactor)
        TextBox.BackgroundTransparency = 1
        TextBox.Text = ""
        TextBox.PlaceholderText = placeholder
        TextBox.PlaceholderColor3 = Color3.fromRGB(80, 75, 80)
        TextBox.Font = Enum.Font.GothamMedium
        TextBox.TextSize = 12 * ScaleFactor
        TextBox.TextColor3 = Theme.Text
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.ClearTextOnFocus = false
        TextBox.Parent = InputFrame

        TextBox.Focused:Connect(function() TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Theme.Pink1}):Play() end)
        TextBox.FocusLost:Connect(function() 
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 40, 45)}):Play()
            callback(TextBox.Text)
        end)
    end

    -- Анимация открытия
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 250 * ScaleFactor, 0, 340 * ScaleFactor)}):Play()

    return Window
end

return PinkLib
