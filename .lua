-- =============================================
-- MATCHA UI LIBRARY - OPTIMIZED & FORMATTED
-- =============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

-- =============================================
-- COLOR SCHEME
-- =============================================
local C = {
    BgMain = Color3.fromRGB(18, 18, 22),
    BgHeader = Color3.fromRGB(12, 12, 16),
    BgSection = Color3.fromRGB(28, 28, 34),
    BgElement = Color3.fromRGB(38, 38, 46),
    BgSlider = Color3.fromRGB(50, 50, 60),
    BgDropdown = Color3.fromRGB(30, 30, 38),
    BgDropItem = Color3.fromRGB(34, 34, 42),
    Accent = Color3.fromRGB(245, 170, 230),
    AccentDark = Color3.fromRGB(220, 140, 200),
    AccentDim = Color3.fromRGB(140, 90, 130),
    TextPrimary = Color3.fromRGB(235, 235, 235),
    TextSecondary = Color3.fromRGB(170, 170, 180),
    TextDim = Color3.fromRGB(110, 110, 120),
    ToggleOff = Color3.fromRGB(50, 50, 60),
    Border = Color3.fromRGB(48, 48, 58),
    SliderGrad1 = Color3.fromRGB(200, 130, 190),
    SliderGrad2 = Color3.fromRGB(250, 180, 230),
    Close = Color3.fromRGB(235, 87, 87),
    CloseHover = Color3.fromRGB(255, 107, 107),
    Minimize = Color3.fromRGB(87, 166, 235),
    MinimizeHover = Color3.fromRGB(107, 186, 255),
}

local F = {
    Bold = Enum.Font.GothamBold,
    Medium = Enum.Font.GothamMedium,
    Normal = Enum.Font.Gotham,
}

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function tween(object, properties, duration)
    TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), properties):Play()
end

-- =============================================
-- MAIN LIBRARY
-- =============================================
function Library.new(config)
    local self = setmetatable({}, Library)
    
    -- Initialize
    config = config or {}
    self._conns = {}
    self._tabs = {}
    self._tabBtns = {}
    self._pages = {}
    self._activeTab = nil
    self._activeDropdown = nil
    self._width = config.Width or 680
    self._height = config.Height or 560
    
    local title = config.Title or "Matcha"
    local subtitle = config.Subtitle or ""
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    -- Cleanup existing
    if CoreGui:FindFirstChild("MatchaLib") then
        CoreGui.MatchaLib:Destroy()
    end
    
    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "MatchaLib"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 100
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    sg.Parent = CoreGui
    self._sg = sg
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, self._width, 0, self._height)
    main.Position = UDim2.new(0.5, -self._width/2, 0.5, -self._height/2)
    main.BackgroundColor3 = C.BgMain
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    main.Parent = sg
    self._main = main
    createCorner(main, 8)
    createStroke(main, C.Border, 1)
    
    -- Header
    local hdr = Instance.new("Frame")
    hdr.Name = "Header"
    hdr.Size = UDim2.new(1, 0, 0, 32)
    hdr.BackgroundColor3 = C.BgHeader
    hdr.BorderSizePixel = 0
    hdr.Parent = main
    self._header = hdr
    createCorner(hdr, 8)
    
    local hf = Instance.new("Frame")
    hf.Size = UDim2.new(1, 0, 0, 10)
    hf.Position = UDim2.new(0, 0, 1, -10)
    hf.BackgroundColor3 = C.BgHeader
    hf.BorderSizePixel = 0
    hf.Parent = hdr
    
    -- Accent Dot
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 10, 0.5, -3)
    dot.BackgroundColor3 = C.Accent
    dot.Parent = hdr
    createCorner(dot, 10)
    
    -- Title
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0.5, -80, 1, 0)
    tl.Position = UDim2.new(0, 22, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = C.TextSecondary
    tl.Font = F.Medium
    tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = hdr
    
    -- Subtitle
    local tr = Instance.new("TextLabel")
    tr.Size = UDim2.new(0.5, -80, 1, 0)
    tr.Position = UDim2.new(0.5, 10, 0, 0)
    tr.BackgroundTransparency = 1
    tr.Text = subtitle
    tr.TextColor3 = C.TextDim
    tr.Font = F.Normal
    tr.TextSize = 11
    tr.TextXAlignment = Enum.TextXAlignment.Right
    tr.Parent = hdr
    
    -- =============================================
    -- MODERN CLOSE BUTTON
    -- =============================================
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -26, 0, 6)
    closeBtn.BackgroundColor3 = C.Close
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = hdr
    createCorner(closeBtn, 10)
    
    -- Close Icon (X)
    local closeIcon = Instance.new("TextLabel")
    closeIcon.Size = UDim2.new(1, 0, 1, 0)
    closeIcon.BackgroundTransparency = 1
    closeIcon.Text = "✕"
    closeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeIcon.Font = F.Bold
    closeIcon.TextSize = 11
    closeIcon.Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundColor3 = C.CloseHover, Size = UDim2.new(0, 22, 0, 22)}, 0.15)
        tween(closeIcon, {TextSize = 12}, 0.15)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundColor3 = C.Close, Size = UDim2.new(0, 20, 0, 20)}, 0.15)
        tween(closeIcon, {TextSize = 11}, 0.15)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(200, 50, 50), Size = UDim2.new(0, 18, 0, 18)}, 0.1)
        task.wait(0.1)
        self:Destroy()
    end)
    
    -- =============================================
    -- MODERN MINIMIZE BUTTON
    -- =============================================
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 20, 0, 20)
    minBtn.Position = UDim2.new(1, -50, 0, 6)
    minBtn.BackgroundColor3 = C.Minimize
    minBtn.BorderSizePixel = 0
    minBtn.Text = ""
    minBtn.AutoButtonColor = false
    minBtn.Parent = hdr
    createCorner(minBtn, 10)
    
    -- Minimize Icon (-)
    local minIcon = Instance.new("Frame")
    minIcon.Size = UDim2.new(0, 10, 0, 2)
    minIcon.Position = UDim2.new(0.5, -5, 0.5, -1)
    minIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minIcon.BorderSizePixel = 0
    minIcon.Parent = minBtn
    createCorner(minIcon, 2)
    
    self._minimized = false
    self._normalSize = UDim2.new(0, self._width, 0, self._height)
    self._miniSize = UDim2.new(0, self._width, 0, 32)
    
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, {BackgroundColor3 = C.MinimizeHover, Size = UDim2.new(0, 22, 0, 22)}, 0.15)
        tween(minIcon, {Size = UDim2.new(0, 11, 0, 2)}, 0.15)
    end)
    
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, {BackgroundColor3 = C.Minimize, Size = UDim2.new(0, 20, 0, 20)}, 0.15)
        tween(minIcon, {Size = UDim2.new(0, 10, 0, 2)}, 0.15)
    end)
    
    minBtn.MouseButton1Click:Connect(function()
        self._minimized = not self._minimized
        
        if self._minimized then
            -- Minimize animation
            tween(main, {Size = self._miniSize}, 0.25)
            tween(minIcon, {Rotation = 180}, 0.25)
            
            task.wait(0.1)
            self._tabBar.Visible = false
            self._content.Visible = false
        else
            -- Restore animation
            self._tabBar.Visible = true
            self._content.Visible = true
            
            tween(main, {Size = self._normalSize}, 0.25)
            tween(minIcon, {Rotation = 0}, 0.25)
        end
    end)
    
    -- TabBar
    local tb = Instance.new("Frame")
    tb.Name = "TabBar"
    tb.Size = UDim2.new(1, 0, 0, 28)
    tb.Position = UDim2.new(0, 0, 0, 32)
    tb.BackgroundColor3 = C.BgHeader
    tb.BorderSizePixel = 0
    tb.Parent = main
    self._tabBar = tb
    
    local tbl = Instance.new("Frame")
    tbl.Size = UDim2.new(1, 0, 0, 1)
    tbl.Position = UDim2.new(0, 0, 1, -1)
    tbl.BackgroundColor3 = C.Border
    tbl.BorderSizePixel = 0
    tbl.Parent = tb
    
    local tlay = Instance.new("UIListLayout")
    tlay.FillDirection = Enum.FillDirection.Horizontal
    tlay.SortOrder = Enum.SortOrder.LayoutOrder
    tlay.Parent = tb
    
    -- Content Area
    local ca = Instance.new("Frame")
    ca.Name = "Content"
    ca.Size = UDim2.new(1, -16, 1, -68)
    ca.Position = UDim2.new(0, 8, 0, 64)
    ca.BackgroundTransparency = 1
    ca.ClipsDescendants = false
    ca.Parent = main
    self._content = ca
    
    -- Dropdown Overlay
    local dropOverlay = Instance.new("Frame")
    dropOverlay.Name = "DropOverlay"
    dropOverlay.Size = UDim2.new(1, 0, 1, 0)
    dropOverlay.BackgroundTransparency = 1
    dropOverlay.ZIndex = 50
    dropOverlay.Visible = false
    dropOverlay.Parent = main
    self._dropOverlay = dropOverlay
    
    local dropCatch = Instance.new("TextButton")
    dropCatch.Size = UDim2.new(1, 0, 1, 0)
    dropCatch.BackgroundTransparency = 1
    dropCatch.Text = ""
    dropCatch.ZIndex = 50
    dropCatch.Parent = dropOverlay
    dropCatch.MouseButton1Click:Connect(function()
        self:_closeDropdown()
    end)
    
    self._dropList = Instance.new("Frame")
    self._dropList.Name = "DropList"
    self._dropList.BackgroundColor3 = C.BgDropdown
    self._dropList.BorderSizePixel = 0
    self._dropList.ZIndex = 55
    self._dropList.Visible = false
    self._dropList.Parent = dropOverlay
    createCorner(self._dropList, 4)
    createStroke(self._dropList, C.Border, 1)
    
    local dll = Instance.new("UIListLayout")
    dll.SortOrder = Enum.SortOrder.LayoutOrder
    dll.Parent = self._dropList
    
    -- Dragging
    local dragging, dragStart, startPos
    hdr.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    table.insert(self._conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    
    table.insert(self._conns, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    
    -- Toggle Key
    table.insert(self._conns, UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == toggleKey then
            sg.Enabled = not sg.Enabled
        end
    end))
    
    return self
end

-- =============================================
-- DROPDOWN METHODS
-- =============================================
function Library:_openDropdown(btn, options, current, cb)
    if self._activeDropdown == btn then
        self:_closeDropdown()
        return
    end
    
    self:_closeDropdown()
    self._activeDropdown = btn
    
    for _, c in pairs(self._dropList:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    
    for i, opt in ipairs(options) do
        local di = Instance.new("Frame")
        di.Size = UDim2.new(1, 0, 0, 24)
        di.BackgroundColor3 = C.BgDropItem
        di.BorderSizePixel = 0
        di.LayoutOrder = i
        di.Parent = self._dropList
        
        local db = Instance.new("TextButton")
        db.Size = UDim2.new(1, 0, 1, 0)
        db.BackgroundTransparency = 1
        db.Text = opt
        db.TextColor3 = (opt == current) and C.Accent or C.TextSecondary
        db.Font = F.Normal
        db.TextSize = 11
        db.AutoButtonColor = false
        db.Parent = di
        
        db.MouseEnter:Connect(function()
            tween(di, {BackgroundColor3 = C.BgElement})
        end)
        
        db.MouseLeave:Connect(function()
            tween(di, {BackgroundColor3 = C.BgDropItem})
        end)
        
        db.MouseButton1Click:Connect(function()
            cb(opt)
            self:_closeDropdown()
        end)
    end
    
    local h = math.min(#options * 24, 200)
    self._dropList.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, h)
    local absPos = btn.AbsolutePosition
    local mainPos = self._main.AbsolutePosition
    self._dropList.Position = UDim2.new(0, absPos.X - mainPos.X, 0, absPos.Y - mainPos.Y + btn.AbsoluteSize.Y + 4)
    
    self._dropList.Visible = true
    self._dropOverlay.Visible = true
end

function Library:_closeDropdown()
    if self._activeDropdown then
        self._activeDropdown = nil
        self._dropList.Visible = false
        self._dropOverlay.Visible = false
    end
end

-- =============================================
-- TAB CREATION
-- =============================================
function Library:AddTab(name)
    local tab = {}
    tab._lib = self
    tab._sections = {}
    
    local tbtn = Instance.new("TextButton")
    tbtn.Size = UDim2.new(0, 100, 1, 0)
    tbtn.BackgroundTransparency = 1
    tbtn.Text = name
    tbtn.TextColor3 = C.TextDim
    tbtn.Font = F.Medium
    tbtn.TextSize = 12
    tbtn.AutoButtonColor = false
    tbtn.Parent = self._tabBar
    self._tabBtns[name] = tbtn
    
    tbtn.MouseButton1Click:Connect(function()
        self:_switchTab(name)
    end)
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self._content
    self._pages[name] = page
    tab._page = page
    
    local lay = Instance.new("UIListLayout")
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 8)
    lay.Parent = page
    
    function tab:AddColumn()
        local col = {}
        col._lib = self._lib
        col._elements = {}
        
        local colf = Instance.new("Frame")
        colf.Size = UDim2.new(0.5, -4, 1, 0)
        colf.BackgroundTransparency = 1
        colf.LayoutOrder = #self._sections
        colf.Parent = self._page
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = C.Accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = colf
        col._scroll = scroll
        
        local lay = Instance.new("UIListLayout")
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Padding = UDim.new(0, 6)
        lay.Parent = scroll
        
        function col:AddSection(text)
            local sf = Instance.new("Frame")
            sf.Size = UDim2.new(1, 0, 0, 28)
            sf.BackgroundColor3 = C.BgSection
            sf.BorderSizePixel = 0
            sf.LayoutOrder = #self._elements
            sf.Parent = self._scroll
            createCorner(sf, 6)
            
            local sl = Instance.new("TextLabel")
            sl.Size = UDim2.new(1, -12, 1, 0)
            sl.Position = UDim2.new(0, 6, 0, 0)
            sl.BackgroundTransparency = 1
            sl.Text = text
            sl.TextColor3 = C.TextPrimary
            sl.Font = F.Bold
            sl.TextSize = 12
            sl.TextXAlignment = Enum.TextXAlignment.Left
            sl.Parent = sf
            
            table.insert(self._elements, sf)
        end
        
        function col:AddButton(config)
            local text = config.Text or "Button"
            local cb = config.Callback or function() end
            
            local ct = Instance.new("Frame")
            ct.Size = UDim2.new(1, 0, 0, 30)
            ct.BackgroundTransparency = 1
            ct.LayoutOrder = #self._elements
            ct.Parent = self._scroll
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundColor3 = C.BgElement
            btn.Text = text
            btn.TextColor3 = C.TextPrimary
            btn.Font = F.Medium
            btn.TextSize = 12
            btn.AutoButtonColor = false
            btn.Parent = ct
            createCorner(btn, 5)
            createStroke(btn, C.Border, 1)
            
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundColor3 = C.BgSlider})
            end)
            
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundColor3 = C.BgElement})
            end)
            
            btn.MouseButton1Click:Connect(function()
                tween(btn, {BackgroundColor3 = C.Accent}, 0.1)
                task.wait(0.1)
                tween(btn, {BackgroundColor3 = C.BgElement}, 0.1)
                cb()
            end)
            
            table.insert(self._elements, ct)
        end
        
        function col:AddToggle(config)
            local text = config.Text or "Toggle"
            local default = config.Default or false
            local keybind = config.Keybind
            local cb = config.Callback or function() end
            
            local state = default
            
            local ct = Instance.new("Frame")
            ct.Size = UDim2.new(1, 0, 0, 32)
            ct.BackgroundTransparency = 1
            ct.LayoutOrder = #self._elements
            ct.Parent = self._scroll
            
            local cir = Instance.new("Frame")
            cir.Size = UDim2.new(0, 18, 0, 18)
            cir.Position = UDim2.new(0, 4, 0.5, -9)
            cir.BackgroundColor3 = state and C.Accent or C.ToggleOff
            cir.Parent = ct
            createCorner(cir, 9)
            local cs = createStroke(cir, state and C.Accent or C.Border, 2)
            
            local inner = Instance.new("Frame")
            inner.Size = UDim2.new(0, 8, 0, 8)
            inner.Position = UDim2.new(0.5, -4, 0.5, -4)
            inner.BackgroundColor3 = C.TextPrimary
            inner.BackgroundTransparency = state and 0 or 1
            inner.Parent = cir
            createCorner(inner, 4)
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -70, 1, 0)
            lbl.Position = UDim2.new(0, 28, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = C.TextSecondary
            lbl.Font = F.Normal
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = ct
            
            if keybind then
                local kb = Instance.new("TextLabel")
                kb.Size = UDim2.new(0, math.max(#keybind * 6 + 12, 30), 0, 16)
                kb.Position = UDim2.new(1, -(math.max(#keybind * 6 + 12, 30) + 4), 0.5, -8)
                kb.BackgroundColor3 = C.BgElement
                kb.TextColor3 = C.TextDim
                kb.Font = F.Normal
                kb.TextSize = 10
                kb.Text = keybind
                kb.Parent = ct
                createCorner(kb, 4)
            end
            
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(keybind and 0.7 or 1, 0, 1, 0)
            b.BackgroundTransparency = 1
            b.Text = ""
            b.Parent = ct
            
            b.MouseButton1Click:Connect(function()
                state = not state
                tween(cir, {BackgroundColor3 = state and C.Accent or C.ToggleOff}, 0.12)
                tween(cs, {Color = state and C.Accent or C.Border}, 0.12)
                tween(inner, {BackgroundTransparency = state and 0 or 1}, 0.12)
                cb(state)
            end)
            
            table.insert(self._elements, ct)
            return {
                Set = function(_, v)
                    state = v
                    cir.BackgroundColor3 = v and C.Accent or C.ToggleOff
                    cs.Color = v and C.Accent or C.Border
                    inner.BackgroundTransparency = v and 0 or 1
                    cb(v)
                end,
                Get = function() return state end
            }
        end
        
        function col:AddSlider(config)
            local text = config.Text or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local dec = config.Decimals or 2
            local cb = config.Callback or function() end
            
            local value = default
            
            local ct = Instance.new("Frame")
            ct.Size = UDim2.new(1, 0, 0, 36)
            ct.BackgroundTransparency = 1
            ct.LayoutOrder = #self._elements
            ct.Parent = self._scroll
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 14)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = C.TextSecondary
            lbl.Font = F.Normal
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = ct
            
            local sbg = Instance.new("Frame")
            sbg.Size = UDim2.new(1, -4, 0, 16)
            sbg.Position = UDim2.new(0, 2, 0, 18)
            sbg.BackgroundColor3 = C.BgSlider
            sbg.Parent = ct
            createCorner(sbg, 4)
            
            local sf = Instance.new("Frame")
            sf.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0)
            sf.BackgroundColor3 = C.Accent
            sf.BorderSizePixel = 0
            sf.Parent = sbg
            createCorner(sf, 4)
            
            local fg = Instance.new("UIGradient")
            fg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, C.SliderGrad1),
                ColorSequenceKeypoint.new(1, C.SliderGrad2)
            })
            fg.Parent = sf
            
            local fmt = "%." .. dec .. "f"
            local vl = Instance.new("TextLabel")
            vl.Size = UDim2.new(1, -4, 1, 0)
            vl.Position = UDim2.new(0, 2, 0, 0)
            vl.BackgroundTransparency = 1
            vl.Text = string.format(fmt .. "/" .. fmt, value, max)
            vl.TextColor3 = C.TextPrimary
            vl.Font = F.Medium
            vl.TextSize = 10
            vl.ZIndex = 3
            vl.Parent = sbg
            
            local sdrag = false
            local ib = Instance.new("TextButton")
            ib.Size = UDim2.new(1, 0, 1, 0)
            ib.BackgroundTransparency = 1
            ib.Text = ""
            ib.ZIndex = 4
            ib.Parent = sbg
            
            local function upd(input)
                local p = math.clamp((input.Position.X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
                value = min + (max - min) * p
                sf.Size = UDim2.new(p, 0, 1, 0)
                vl.Text = string.format(fmt .. "/" .. fmt, value, max)
                cb(value)
            end
            
            ib.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sdrag = true
                    upd(input)
                end
            end)
            
            table.insert(self._lib._conns, UserInputService.InputChanged:Connect(function(input)
                if sdrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    upd(input)
                end
            end))
            
            table.insert(self._lib._conns, UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sdrag = false
                end
            end))
            
            table.insert(self._elements, ct)
            return {Get = function() return value end}
        end
        
        function col:AddDropdown(config)
            local text = config.Text or "Dropdown"
            local options = config.Options or {"None"}
            local default = config.Default or options[1]
            local cb = config.Callback or function() end
            
            local selected = default
            
            local ct = Instance.new("Frame")
            ct.Size = UDim2.new(1, 0, 0, 40)
            ct.BackgroundTransparency = 1
            ct.LayoutOrder = #self._elements
            ct.Parent = self._scroll
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 14)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = C.TextSecondary
            lbl.Font = F.Normal
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = ct
            
            local db = Instance.new("TextButton")
            db.Size = UDim2.new(1, -4, 0, 22)
            db.Position = UDim2.new(0, 2, 0, 16)
            db.BackgroundColor3 = C.BgDropdown
            db.Text = ""
            db.AutoButtonColor = false
            db.Parent = ct
            createCorner(db, 4)
            createStroke(db, C.Border, 1)
            
            local sl = Instance.new("TextLabel")
            sl.Size = UDim2.new(1, -24, 1, 0)
            sl.Position = UDim2.new(0, 8, 0, 0)
            sl.BackgroundTransparency = 1
            sl.Text = selected
            sl.TextColor3 = C.TextPrimary
            sl.Font = F.Normal
            sl.TextSize = 11
            sl.TextXAlignment = Enum.TextXAlignment.Left
            sl.Parent = db
            
            local ar = Instance.new("TextLabel")
            ar.Size = UDim2.new(0, 16, 1, 0)
            ar.Position = UDim2.new(1, -20, 0, 0)
            ar.BackgroundTransparency = 1
            ar.Text = "▼"
            ar.TextColor3 = C.TextDim
            ar.Font = F.Normal
            ar.TextSize = 9
            ar.Parent = db
            
            db.MouseButton1Click:Connect(function()
                self._lib:_openDropdown(db, options, selected, function(opt)
                    selected = opt
                    sl.Text = opt
                    cb(opt)
                end)
            end)
            
            table.insert(self._elements, ct)
            return {
                Get = function() return selected end,
                SetOptions = function(_, opts) options = opts end
            }
        end
        
        table.insert(self._sections, col)
        return col
    end
    
    self._tabs[name] = tab
    
    if not self._activeTab then
        self:_switchTab(name)
    end
    
    return tab
end

-- =============================================
-- UTILITY METHODS
-- =============================================
function Library:_switchTab(name)
    for n, p in pairs(self._pages) do
        p.Visible = (n == name)
    end
    for n, b in pairs(self._tabBtns) do
        b.TextColor3 = (n == name) and C.Accent or C.TextDim
    end
    self._activeTab = name
    self:_closeDropdown()
end

function Library:Destroy()
    for _, c in pairs(self._conns) do
        if c then c:Disconnect() end
    end
    self._conns = {}
    if self._sg then self._sg:Destroy() end
end

return Library
