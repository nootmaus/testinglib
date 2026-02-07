local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

local C = {
    Main = Color3.fromRGB(18, 18, 24),
    MainGrad = Color3.fromRGB(24, 24, 32),
    Content = Color3.fromRGB(14, 14, 18),
    Stroke = Color3.fromRGB(35, 35, 45),
    StrokeLight = Color3.fromRGB(50, 50, 65),
    Accent = Color3.fromRGB(255, 100, 180),
    AccentGrad = Color3.fromRGB(200, 80, 220),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(140, 140, 150),
    Element = Color3.fromRGB(28, 28, 36),
    ElementHover = Color3.fromRGB(34, 34, 42),
    Red = Color3.fromRGB(255, 85, 85),
    Yellow = Color3.fromRGB(255, 180, 80),
    Green = Color3.fromRGB(85, 255, 150)
}

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function createGradient(parent, c1, c2, rot)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    }
    grad.Rotation = rot or 45
    grad.Parent = parent
    return grad
end

local function tween(obj, props, info)
    TweenService:Create(obj, info or TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Library.new(config)
    local self = setmetatable({}, Library)
    
    config = config or {}
    self._title = config.Title or "Matcha UI"
    self._width = config.Width or 550
    self._height = config.Height or 400
    self._toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    self._tabs = {}
    self._activeTab = nil
    self._minimized = false
    self._connections = {}
    
    if CoreGui:FindFirstChild("MatchaLibrary") then
        CoreGui.MatchaLibrary:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MatchaLibrary"
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    else
        gui.Parent = CoreGui
    end
    self._gui = gui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, self._width, 0, self._height)
    main.Position = UDim2.new(0.5, -self._width/2, 0.5, -self._height/2)
    main.BackgroundColor3 = C.Main
    main.ClipsDescendants = true
    main.Parent = gui
    
    self._main = main
    self._normalSize = UDim2.new(0, self._width, 0, self._height)
    self._miniSize = UDim2.new(0, self._width, 0, 40)
    
    createCorner(main, 14)
    createStroke(main, C.Stroke, 1.5)
    createGradient(main, C.Main, C.MainGrad, 45)
    
    local dropShadow = Instance.new("ImageLabel")
    dropShadow.Name = "Shadow"
    dropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    dropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    dropShadow.Size = UDim2.new(1, 140, 1, 140)
    dropShadow.BackgroundTransparency = 1
    dropShadow.Image = "rbxassetid://6015897843"
    dropShadow.ImageColor3 = Color3.new(0, 0, 0)
    dropShadow.ImageTransparency = 0.4
    dropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    dropShadow.ScaleType = Enum.ScaleType.Slice
    dropShadow.SliceScale = 1
    dropShadow.ZIndex = -1
    dropShadow.Parent = main
    
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundTransparency = 1
    topBar.Parent = main
    
    local dragging, dragInput, dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            tween(main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, TweenInfo.new(0.1, Enum.EasingStyle.Sine))
        end
    end))
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self._title
    titleLabel.TextColor3 = C.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    local function createWinBtn(icon, color, posOffset, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.Position = UDim2.new(1, posOffset, 0.5, -13)
        btn.BackgroundColor3 = C.Element
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = topBar
        
        createCorner(btn, 13)
        local stk = createStroke(btn, C.StrokeLight, 1)
        
        local ico = Instance.new("ImageLabel")
        ico.Size = UDim2.new(0, 12, 0, 12)
        ico.Position = UDim2.new(0.5, -6, 0.5, -6)
        ico.BackgroundTransparency = 1
        ico.Image = icon
        ico.ImageColor3 = C.TextDim
        ico.Parent = btn
        
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = color})
            tween(stk, {Color = color})
            tween(ico, {ImageColor3 = Color3.new(1,1,1)})
        end)
        
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = C.Element})
            tween(stk, {Color = C.StrokeLight})
            tween(ico, {ImageColor3 = C.TextDim})
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn, ico
    end
    
    createWinBtn("rbxassetid://6031094670", C.Red, -36, function()
        gui:Destroy()
    end)
    
    local minBtn, minIco = createWinBtn("rbxassetid://6031094678", C.Yellow, -70, function()
        self._minimized = not self._minimized
        if self._minimized then
            tween(main, {Size = self._miniSize})
            tween(dropShadow, {ImageTransparency = 1})
            minIco.Image = "rbxassetid://6031094667"
        else
            tween(main, {Size = self._normalSize})
            tween(dropShadow, {ImageTransparency = 0.4})
            minIco.Image = "rbxassetid://6031094678"
        end
    end)
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -24, 1, -56)
    container.Position = UDim2.new(0, 12, 0, 44)
    container.BackgroundColor3 = C.Content
    container.Parent = main
    
    createCorner(container, 10)
    createStroke(container, C.Stroke, 1)
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0, 130, 1, -16)
    tabContainer.Position = UDim2.new(0, 8, 0, 8)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = container
    
    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 6)
    tabList.Parent = tabContainer
    
    self._pagesFolder = Instance.new("Frame")
    self._pagesFolder.Size = UDim2.new(1, -156, 1, -16)
    self._pagesFolder.Position = UDim2.new(0, 148, 0, 8)
    self._pagesFolder.BackgroundTransparency = 1
    self._pagesFolder.Parent = container
    
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self._toggleKey then
            gui.Enabled = not gui.Enabled
        end
    end))
    
    return self
end

function Library:AddTab(name, icon)
    local tab = {}
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 32)
    button.BackgroundColor3 = Color3.new(1,1,1)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = self._tabContainer
    
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, 0, 1, 0)
    btnFrame.BackgroundColor3 = C.Element
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = button
    
    createCorner(btnFrame, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.TextDim
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btnFrame
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = C.StrokeLight
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = self._pagesFolder
    
    local pageList = Instance.new("UIListLayout")
    pageList.SortOrder = Enum.SortOrder.LayoutOrder
    pageList.Padding = UDim.new(0, 8)
    pageList.Parent = page
    
    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingRight = UDim.new(0, 4)
    pagePad.PaddingBottom = UDim.new(0, 4)
    pagePad.Parent = page
    
    button.Parent = self._gui.Main.Container.Frame 
    
    button.MouseButton1Click:Connect(function()
        for _, t in pairs(self._tabs) do
            tween(t.BtnFrame, {BackgroundTransparency = 1})
            tween(t.Label, {TextColor3 = C.TextDim, Position = UDim2.new(0, 12, 0, 0)})
            t.Page.Visible = false
        end
        tween(btnFrame, {BackgroundTransparency = 0})
        tween(lbl, {TextColor3 = C.Accent, Position = UDim2.new(0, 16, 0, 0)})
        page.Visible = true
    end)
    
    if #self._tabs == 0 then
        tween(btnFrame, {BackgroundTransparency = 0})
        tween(lbl, {TextColor3 = C.Accent, Position = UDim2.new(0, 16, 0, 0)})
        page.Visible = true
    end
    
    table.insert(self._tabs, {BtnFrame = btnFrame, Label = lbl, Page = page})
    
    function tab:AddSection(text)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 24)
        section.BackgroundTransparency = 1
        section.Parent = page
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = C.TextDim
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 11
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.TextTransparency = 0.4
        txt.Parent = section
    end
    
    function tab:AddButton(text, callback)
        local cb = callback or function() end
        local btnObj = Instance.new("TextButton")
        btnObj.Size = UDim2.new(1, 0, 0, 36)
        btnObj.BackgroundColor3 = C.Element
        btnObj.Text = ""
        btnObj.AutoButtonColor = false
        btnObj.Parent = page
        
        createCorner(btnObj, 8)
        local str = createStroke(btnObj, C.Stroke, 1)
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = C.Text
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 12
        txt.Parent = btnObj
        
        btnObj.MouseEnter:Connect(function()
            tween(btnObj, {BackgroundColor3 = C.ElementHover})
            tween(str, {Color = C.StrokeLight})
        end)
        
        btnObj.MouseLeave:Connect(function()
            tween(btnObj, {BackgroundColor3 = C.Element})
            tween(str, {Color = C.Stroke})
        end)
        
        btnObj.MouseButton1Click:Connect(function()
            tween(btnObj, {BackgroundColor3 = C.Accent})
            tween(txt, {TextColor3 = C.Main})
            task.wait(0.1)
            tween(btnObj, {BackgroundColor3 = C.ElementHover})
            tween(txt, {TextColor3 = C.Text})
            cb()
        end)
    end
    
    function tab:AddToggle(text, default, callback)
        local cb = callback or function() end
        local toggled = default or false
        
        local togFrame = Instance.new("TextButton")
        togFrame.Size = UDim2.new(1, 0, 0, 36)
        togFrame.BackgroundColor3 = C.Element
        togFrame.Text = ""
        togFrame.AutoButtonColor = false
        togFrame.Parent = page
        
        createCorner(togFrame, 8)
        local str = createStroke(togFrame, C.Stroke, 1)
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, -50, 1, 0)
        txt.Position = UDim2.new(0, 12, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = C.Text
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 12
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = togFrame
        
        local checkBg = Instance.new("Frame")
        checkBg.Size = UDim2.new(0, 42, 0, 22)
        checkBg.Position = UDim2.new(1, -54, 0.5, -11)
        checkBg.BackgroundColor3 = toggled and C.Accent or C.Main
        checkBg.Parent = togFrame
        
        createCorner(checkBg, 11)
        local checkStr = createStroke(checkBg, toggled and C.Accent or C.StrokeLight, 1)
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        dot.BackgroundColor3 = C.Text
        dot.Parent = checkBg
        createCorner(dot, 8)
        
        local function update()
            local targetColor = toggled and C.Accent or C.Main
            local targetPos = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local targetStroke = toggled and C.Accent or C.StrokeLight
            
            tween(checkBg, {BackgroundColor3 = targetColor})
            tween(dot, {Position = targetPos})
            tween(checkStr, {Color = targetStroke})
            cb(toggled)
        end
        
        togFrame.MouseEnter:Connect(function()
            tween(togFrame, {BackgroundColor3 = C.ElementHover})
            tween(str, {Color = C.StrokeLight})
        end)
        
        togFrame.MouseLeave:Connect(function()
            tween(togFrame, {BackgroundColor3 = C.Element})
            tween(str, {Color = C.Stroke})
        end)
        
        togFrame.MouseButton1Click:Connect(function()
            toggled = not toggled
            update()
        end)
    end
    
    function tab:AddSlider(text, options, callback)
        local cb = callback or function() end
        local min = options.Min or 0
        local max = options.Max or 100
        local default = options.Default or min
        local value = default
        
        local slideFrame = Instance.new("Frame")
        slideFrame.Size = UDim2.new(1, 0, 0, 50)
        slideFrame.BackgroundColor3 = C.Element
        slideFrame.Parent = page
        
        createCorner(slideFrame, 8)
        local str = createStroke(slideFrame, C.Stroke, 1)
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, -12, 0, 20)
        txt.Position = UDim2.new(0, 12, 0, 6)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = C.Text
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 12
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = slideFrame
        
        local valTxt = Instance.new("TextLabel")
        valTxt.Size = UDim2.new(0, 60, 0, 20)
        valTxt.Position = UDim2.new(1, -72, 0, 6)
        valTxt.BackgroundTransparency = 1
        valTxt.Text = tostring(value)
        valTxt.TextColor3 = C.TextDim
        valTxt.Font = Enum.Font.Gotham
        valTxt.TextSize = 11
        valTxt.TextXAlignment = Enum.TextXAlignment.Right
        valTxt.Parent = slideFrame
        
        local barBg = Instance.new("TextButton")
        barBg.Size = UDim2.new(1, -24, 0, 6)
        barBg.Position = UDim2.new(0, 12, 0, 32)
        barBg.BackgroundColor3 = C.Main
        barBg.Text = ""
        barBg.AutoButtonColor = false
        barBg.Parent = slideFrame
        
        createCorner(barBg, 3)
        
        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0)
        barFill.BackgroundColor3 = C.Accent
        barFill.BorderSizePixel = 0
        barFill.Parent = barBg
        
        createCorner(barFill, 3)
        createGradient(barFill, C.Accent, C.AccentGrad)
        
        local dragging = false
        
        local function update(input)
            local sizeX = barBg.AbsoluteSize.X
            local posX = barBg.AbsolutePosition.X
            local percent = math.clamp((input.Position.X - posX) / sizeX, 0, 1)
            value = math.floor(min + (max - min) * percent)
            
            tween(barFill, {Size = UDim2.new(percent, 0, 1, 0)}, TweenInfo.new(0.05))
            valTxt.Text = tostring(value)
            cb(value)
        end
        
        barBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
    end
    
    return tab
end

return Library
