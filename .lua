local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library
Library.Flags = {} -- Здесь хранятся значения для сохранения
Library.ConfigFolder = "MatchaConfigs"

-- // Настройки цветов (Theme)
local C = {
    BgMain       = Color3.fromRGB(20, 20, 25),
    BgHeader     = Color3.fromRGB(25, 25, 30),
    BgContent    = Color3.fromRGB(20, 20, 25),
    BgSection    = Color3.fromRGB(30, 30, 36),
    BgElement    = Color3.fromRGB(35, 35, 42),
    BgHover      = Color3.fromRGB(45, 45, 52),
    
    Accent       = Color3.fromRGB(160, 100, 220), -- Фиолетовый акцент
    AccentHover  = Color3.fromRGB(180, 120, 240),
    
    TextPrimary  = Color3.fromRGB(240, 240, 240),
    TextSecondary= Color3.fromRGB(160, 160, 170),
    TextDim      = Color3.fromRGB(100, 100, 110),
    
    Border       = Color3.fromRGB(50, 50, 60),
    Outline      = Color3.fromRGB(25, 25, 30),
    
    Success      = Color3.fromRGB(60, 200, 100),
    Danger       = Color3.fromRGB(200, 60, 60),
    Warning      = Color3.fromRGB(220, 180, 60),
}

local F = {
    Bold   = Enum.Font.GothamBold,
    Medium = Enum.Font.GothamMedium,
    Normal = Enum.Font.Gotham,
}

-- // Утилиты
local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local newPos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.15), {Position = newPos}):Play()
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

local function SaveConfig(name)
    if not writefile then return end
    local json = HttpService:JSONEncode(Library.Flags)
    if not isfolder(Library.ConfigFolder) then makefolder(Library.ConfigFolder) end
    writefile(Library.ConfigFolder .. "/" .. name .. ".json", json)
end

local function LoadConfig(name)
    if not readfile or not isfile(Library.ConfigFolder .. "/" .. name .. ".json") then return end
    local json = readfile(Library.ConfigFolder .. "/" .. name .. ".json")
    local data = HttpService:JSONDecode(json)
    for i, v in pairs(data) do
        Library.Flags[i] = v
        -- Примечание: Здесь нужна логика для обновления визуальной части, 
        -- но для простоты мы просто загружаем данные в Flags. 
        -- В идеале callback функции должны проверять Flags.
    end
end

-- // Основной класс
function Library.new(config)
    local self = setmetatable({}, Library)
    self._conns = {}
    self._tabs = {}
    self._activeTab = nil
    
    config = config or {}
    local title = config.Title or "Matcha Script"
    local width = config.Width or 600
    local height = config.Height or 450
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    -- Удаляем старый GUI
    if CoreGui:FindFirstChild("MatchaLib") then CoreGui.MatchaLib:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "MatchaLib"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if syn and syn.protect_gui then syn.protect_gui(sg) end
    sg.Parent = CoreGui
    self._sg = sg

    -- Main Container
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, width, 0, height)
    main.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    main.BackgroundColor3 = C.BgMain
    main.BorderSizePixel = 0
    main.Parent = sg
    self._main = main
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.ZIndex = 0
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceScale = 1
    shadow.Parent = main

    -- Stroke
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = C.Border
    stroke.Thickness = 1

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = C.BgHeader
    header.BorderSizePixel = 0
    header.Parent = main
    
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 6)
    
    -- Fix bottom corners of header to be square
    local headerCover = Instance.new("Frame")
    headerCover.BorderSizePixel = 0
    headerCover.BackgroundColor3 = C.BgHeader
    headerCover.Size = UDim2.new(1, 0, 0, 10)
    headerCover.Position = UDim2.new(0, 0, 1, -10)
    headerCover.Parent = header

    -- Header Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = F.Bold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = C.TextPrimary
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    -- Control Buttons (Close / Minimize)
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0, 60, 1, 0)
    btnContainer.Position = UDim2.new(1, -64, 0, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = header
    
    local function createHeaderBtn(symbol, color, posOffset)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 24, 0, 24)
        btn.Position = UDim2.new(0, posOffset, 0.5, -12)
        btn.BackgroundColor3 = C.BgElement
        btn.Text = symbol
        btn.TextColor3 = C.TextSecondary
        btn.Font = F.Medium
        btn.TextSize = 14
        btn.AutoButtonColor = false
        btn.Parent = btnContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color, TextColor3 = Color3.new(1,1,1)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.BgElement, TextColor3 = C.TextSecondary}):Play()
        end)
        return btn
    end

    local minBtn = createHeaderBtn("-", C.Warning, 0)
    local closeBtn = createHeaderBtn("×", C.Danger, 30)

    closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)
    
    self._minimized = false
    minBtn.MouseButton1Click:Connect(function()
        self._minimized = not self._minimized
        if self._minimized then
            main:TweenSize(UDim2.new(0, width, 0, 40), "Out", "Quad", 0.3, true)
            for _, c in pairs(self._contentFrame:GetChildren()) do if c:IsA("Frame") then c.Visible = false end end
            self._tabContainer.Visible = false
        else
            main:TweenSize(UDim2.new(0, width, 0, height), "Out", "Quad", 0.3, true)
            task.delay(0.3, function()
                if not self._minimized then
                    self._tabContainer.Visible = true
                    for _, c in pairs(self._contentFrame:GetChildren()) do 
                        if c.Name == "Page_" .. (self._activeTab or "") then c.Visible = true end 
                    end
                end
            end)
        end
    end)

    MakeDraggable(header, main)

    -- Tab Container (Sidebar or Topbar) - Let's do Sidebar for a pro look
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "Tabs"
    tabContainer.Size = UDim2.new(0, 140, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = C.BgContent
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 2
    tabContainer.Parent = main
    self._tabContainer = tabContainer

    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 4)
    tabList.Parent = tabContainer

    local tabPad = Instance.new("UIPadding")
    tabPad.PaddingTop = UDim.new(0, 10)
    tabPad.PaddingLeft = UDim.new(0, 10)
    tabPad.Parent = tabContainer

    -- Separator
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0, 1, 1, -40)
    sep.Position = UDim2.new(0, 140, 0, 40)
    sep.BackgroundColor3 = C.Border
    sep.BorderSizePixel = 0
    sep.Parent = main

    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -150, 1, -50)
    contentFrame.Position = UDim2.new(0, 145, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = main
    self._contentFrame = contentFrame

    -- Toggle Key Logic
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == toggleKey then
            main.Visible = not main.Visible
        end
    end)

    return self
end

function Library:AddTab(name)
    local tab = {Name = name, _lib = self}
    
    -- Tab Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = F.Medium
    btn.TextSize = 12
    btn.TextColor3 = C.TextDim
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = self._tabContainer
    
    local btnPad = Instance.new("UIPadding", btn)
    btnPad.PaddingLeft = UDim.new(0, 12)
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    -- Tab Page
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = C.Accent
    page.Visible = false
    page.Parent = self._contentFrame
    
    local pageList = Instance.new("UIListLayout", page)
    pageList.SortOrder = Enum.SortOrder.LayoutOrder
    pageList.Padding = UDim.new(0, 6)
    
    local pagePad = Instance.new("UIPadding", page)
    pagePad.PaddingRight = UDim.new(0, 6)

    -- Switch Tab Logic
    btn.MouseButton1Click:Connect(function()
        for _, c in pairs(self._contentFrame:GetChildren()) do
            c.Visible = false
        end
        for _, t in pairs(self._tabContainer:GetChildren()) do
            if t:IsA("TextButton") then
                TweenService:Create(t, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = C.TextDim}):Play()
            end
        end
        
        page.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = C.BgElement, TextColor3 = C.Accent}):Play()
        self._activeTab = name
    end)

    -- Select first tab
    if not self._activeTab then
        self._activeTab = name
        page.Visible = true
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = C.BgElement
        btn.TextColor3 = C.Accent
    end

    function tab:AddSection(text)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 24)
        section.BackgroundTransparency = 1
        section.Parent = page
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = F.Bold
        label.TextColor3 = C.TextSecondary
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = section
        
        local p = Instance.new("UIPadding", label)
        p.PaddingLeft = UDim.new(0, 2)
        p.PaddingTop = UDim.new(0, 8)
    end

    function tab:AddToggle(config)
        local text = config.Text or "Toggle"
        local flag = config.Flag or text
        local default = config.Default or false
        local callback = config.Callback or function() end
        
        Library.Flags[flag] = default

        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 36)
        toggleFrame.BackgroundColor3 = C.BgElement
        toggleFrame.Parent = page
        Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 4)
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(1, 0, 1, 0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""
        toggleBtn.Parent = toggleFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = F.Medium
        label.TextColor3 = C.TextPrimary
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame

        -- Switch Visual
        local switchBg = Instance.new("Frame")
        switchBg.Size = UDim2.new(0, 36, 0, 20)
        switchBg.AnchorPoint = Vector2.new(1, 0.5)
        switchBg.Position = UDim2.new(1, -10, 0.5, 0)
        switchBg.BackgroundColor3 = default and C.Accent or C.BgMain
        switchBg.Parent = toggleFrame
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
        
        local switchCircle = Instance.new("Frame")
        switchCircle.Size = UDim2.new(0, 16, 0, 16)
        switchCircle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        switchCircle.BackgroundColor3 = C.TextPrimary
        switchCircle.Parent = switchBg
        Instance.new("UICorner", switchCircle).CornerRadius = UDim.new(1, 0)

        -- Keybind Visual
        local bindBtn = Instance.new("TextButton")
        bindBtn.Size = UDim2.new(0, 80, 0, 20) -- Place before switch
        bindBtn.AnchorPoint = Vector2.new(1, 0.5)
        bindBtn.Position = UDim2.new(1, -55, 0.5, 0)
        bindBtn.BackgroundColor3 = C.BgMain
        bindBtn.Text = "NONE"
        bindBtn.Font = F.Normal
        bindBtn.TextSize = 10
        bindBtn.TextColor3 = C.TextDim
        bindBtn.Parent = toggleFrame
        Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)

        -- Toggle Function
        local toggled = default
        local function updateToggle()
            toggled = not toggled
            Library.Flags[flag] = toggled
            
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = toggled and C.Accent or C.BgMain}):Play()
            TweenService:Create(switchCircle, TweenInfo.new(0.2), {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            
            callback(toggled)
        end

        toggleBtn.MouseButton1Click:Connect(updateToggle)

        -- Keybind Function
        local binding = nil
        bindBtn.MouseButton1Click:Connect(function()
            bindBtn.Text = "..."
            bindBtn.TextColor3 = C.Accent
            
            local inputWait
            inputWait = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = input.KeyCode
                    if binding == Enum.KeyCode.Backspace then
                        binding = nil
                        bindBtn.Text = "NONE"
                    else
                        bindBtn.Text = binding.Name
                    end
                    bindBtn.TextColor3 = C.TextDim
                    inputWait:Disconnect()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    bindBtn.TextColor3 = C.TextDim
                    bindBtn.Text = binding and binding.Name or "NONE"
                    inputWait:Disconnect()
                end
            end)
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and binding and input.KeyCode == binding then
                updateToggle()
            end
        end)
    end
    
    function tab:AddSlider(config)
        local text = config.Text or "Slider"
        local flag = config.Flag or text
        local min = config.Min or 0
        local max = config.Max or 100
        local default = config.Default or min
        local callback = config.Callback or function() end

        Library.Flags[flag] = default

        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 42)
        sliderFrame.BackgroundColor3 = C.BgElement
        sliderFrame.Parent = page
        Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 4)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = F.Medium
        label.TextColor3 = C.TextPrimary
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 40, 0, 20)
        valueLabel.Position = UDim2.new(1, -50, 0, 4)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.Font = F.Bold
        valueLabel.TextColor3 = C.Accent
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = sliderFrame

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -20, 0, 4)
        sliderBg.Position = UDim2.new(0, 10, 0, 28)
        sliderBg.BackgroundColor3 = C.BgMain
        sliderBg.Parent = sliderFrame
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = C.Accent
        sliderFill.Parent = sliderBg
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
        
        local trigger = Instance.new("TextButton")
        trigger.Size = UDim2.new(1, 0, 1, 0)
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        trigger.Parent = sliderBg

        local dragging = false
        local function slide(input)
            local pos = UDim2.new(math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1), 0, 1, 0)
            TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = pos}):Play()
            
            local val = math.floor(min + ((max - min) * pos.X.Scale))
            valueLabel.Text = tostring(val)
            Library.Flags[flag] = val
            callback(val)
        end

        trigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                slide(input)
                TweenService:Create(sliderFill, TweenInfo.new(0.2), {BackgroundColor3 = C.AccentHover}):Play()
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                TweenService:Create(sliderFill, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent}):Play()
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                slide(input)
            end
        end)
    end
    
    function tab:AddButton(config)
        local text = config.Text or "Button"
        local callback = config.Callback or function() end
        
        local btnFrame = Instance.new("Frame")
        btnFrame.Size = UDim2.new(1, 0, 0, 32)
        btnFrame.BackgroundColor3 = C.BgElement
        btnFrame.Parent = page
        Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 4)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.Font = F.Medium
        btn.TextColor3 = C.TextPrimary
        btn.TextSize = 12
        btn.Parent = btnFrame
        
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btnFrame, TweenInfo.new(0.1), {BackgroundColor3 = C.AccentDim}):Play()
            task.wait(0.1)
            TweenService:Create(btnFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.BgElement}):Play()
            callback()
        end)
    end
    
    function tab:AddConfigSystem()
        self:AddSection("Configuration")
        
        local configName = ""
        local nameBox = Instance.new("TextBox")
        nameBox.Size = UDim2.new(1, 0, 0, 30)
        nameBox.BackgroundColor3 = C.BgMain
        nameBox.Text = "Config Name"
        nameBox.TextColor3 = C.TextSecondary
        nameBox.Font = F.Normal
        nameBox.TextSize = 12
        nameBox.Parent = page
        Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 4)
        
        nameBox:GetPropertyChangedSignal("Text"):Connect(function()
            configName = nameBox.Text
        end)
        
        self:AddButton({
            Text = "Save Config",
            Callback = function()
                if configName ~= "" then SaveConfig(configName) end
            end
        })
        
        self:AddButton({
            Text = "Load Config",
            Callback = function()
                if configName ~= "" then LoadConfig(configName) end
            end
        })
    end

    return tab
end

function Library:Destroy()
    if self._sg then self._sg:Destroy() end
    for _, c in pairs(self._conns) do c:Disconnect() end
end

return Library
