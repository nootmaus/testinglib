local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

local C = {
    BgMain       = Color3.fromRGB(18, 18, 22),
    BgHeader     = Color3.fromRGB(12, 12, 16),
    BgSection    = Color3.fromRGB(28, 28, 34),
    BgElement    = Color3.fromRGB(38, 38, 46),
    BgSlider     = Color3.fromRGB(50, 50, 60),
    BgDropdown   = Color3.fromRGB(30, 30, 38),
    BgDropItem   = Color3.fromRGB(34, 34, 42),
    Accent       = Color3.fromRGB(245, 170, 230),
    AccentDark   = Color3.fromRGB(220, 140, 200),
    AccentDim    = Color3.fromRGB(140, 90, 130),
    TextPrimary  = Color3.fromRGB(235, 235, 235),
    TextSecondary= Color3.fromRGB(170, 170, 180),
    TextDim      = Color3.fromRGB(110, 110, 120),
    ToggleOff    = Color3.fromRGB(50, 50, 60),
    Border       = Color3.fromRGB(48, 48, 58),
    SliderGrad1  = Color3.fromRGB(200, 130, 190),
    SliderGrad2  = Color3.fromRGB(250, 180, 230),
}

local F = {
    Bold   = Enum.Font.GothamBold,
    Medium = Enum.Font.GothamMedium,
    Normal = Enum.Font.Gotham,
}

function Library.new(config)
    local self = setmetatable({}, Library)
    self._conns = {}
    self._tabs = {}
    self._tabBtns = {}
    self._pages = {}
    self._activeTab = nil
    self._activeDropdown = nil

    config = config or {}
    local title = config.Title or "Matcha"
    local subtitle = config.Subtitle or ""
    local width = config.Width or 680
    local height = config.Height or 560
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    self._width = width
    self._height = height

    if CoreGui:FindFirstChild("MatchaLib") then CoreGui.MatchaLib:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "MatchaLib"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 100
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    sg.Parent = CoreGui
    self._sg = sg

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, width, 0, height)
    main.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    main.BackgroundColor3 = C.BgMain
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    main.Parent = sg
    self._main = main
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    local ms = Instance.new("UIStroke", main)
    ms.Color = C.Border
    ms.Thickness = 1

    local hdr = Instance.new("Frame")
    hdr.Name = "Hdr"
    hdr.Size = UDim2.new(1, 0, 0, 32)
    hdr.BackgroundColor3 = C.BgHeader
    hdr.BorderSizePixel = 0
    hdr.Parent = main
    self._header = hdr
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 8)
    local hf = Instance.new("Frame")
    hf.Size = UDim2.new(1, 0, 0, 10)
    hf.Position = UDim2.new(0, 0, 1, -10)
    hf.BackgroundColor3 = C.BgHeader
    hf.BorderSizePixel = 0
    hf.Parent = hdr

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 10, 0.5, -3)
    dot.BackgroundColor3 = C.Accent
    dot.Parent = hdr
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

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

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 20)
    closeBtn.Position = UDim2.new(1, -34, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = C.TextPrimary
    closeBtn.Font = F.Bold
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = hdr
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 20)
    minBtn.Position = UDim2.new(1, -66, 0, 6)
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 220)
    minBtn.Text = "—"
    minBtn.TextColor3 = C.TextPrimary
    minBtn.Font = F.Bold
    minBtn.TextSize = 12
    minBtn.AutoButtonColor = false
    minBtn.Parent = hdr
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

    self._minimized = false
    self._normalSize = UDim2.new(0, width, 0, height)
    self._miniSize = UDim2.new(0, width, 0, 32)

    minBtn.MouseButton1Click:Connect(function()
        self._minimized = not self._minimized
        if self._minimized then
            self._tabBar.Visible = false
            self._content.Visible = false
            main:TweenSize(self._miniSize, "Out", "Quad", 0.25, true)
            minBtn.Text = "+"
        else
            main:TweenSize(self._normalSize, "Out", "Quad", 0.25, true)
            task.delay(0.25, function()
                if not self._minimized then
                    self._tabBar.Visible = true
                    self._content.Visible = true
                    minBtn.Text = "—"
                end
            end)
        end
    end)

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

    local ca = Instance.new("Frame")
    ca.Name = "Content"
    ca.Size = UDim2.new(1, -16, 1, -68)
    ca.Position = UDim2.new(0, 8, 0, 64)
    ca.BackgroundTransparency = 1
    ca.ClipsDescendants = false
    ca.Parent = main
    self._content = ca

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
    Instance.new("UICorner", self._dropList).CornerRadius = UDim.new(0, 4)
    local dls = Instance.new("UIStroke", self._dropList)
    dls.Color = C.Border
    dls.Thickness = 1

    local dll = Instance.new("UIListLayout")
    dll.SortOrder = Enum.SortOrder.LayoutOrder
    dll.Parent = self._dropList

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

    if toggleKey then
        table.insert(self._conns, UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == toggleKey then
                main.Visible = not main.Visible
            end
        end))
    end

    return self
end

function Library:_closeDropdown()
    self._dropOverlay.Visible = false
    self._dropList.Visible = false
    for _, c in pairs(self._dropList:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UICorner") and not c:IsA("UIStroke") then
            c:Destroy()
        end
    end
    self._activeDropdown = nil
end

function Library:_openDropdown(btnFrame, options, selected, callback)
    self:_closeDropdown()

    local absPos = btnFrame.AbsolutePosition
    local absSize = btnFrame.AbsoluteSize
    local mainPos = self._main.AbsolutePosition

    local x = absPos.X - mainPos.X
    local y = absPos.Y - mainPos.Y + absSize.Y + 2
    local w = absSize.X
    local itemH = 24
    local totalH = #options * itemH

    local maxY = self._main.AbsoluteSize.Y - 10
    if y + totalH > maxY then
        totalH = math.min(totalH, maxY - y)
    end

    self._dropList.Position = UDim2.new(0, x, 0, y)
    self._dropList.Size = UDim2.new(0, w, 0, totalH)
    self._dropList.Visible = true
    self._dropOverlay.Visible = true

    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, 0, 0, itemH)
        ob.BackgroundColor3 = C.BgDropItem
        ob.BackgroundTransparency = 0
        ob.Text = ""
        ob.AutoButtonColor = false
        ob.LayoutOrder = i
        ob.ZIndex = 56
        ob.Parent = self._dropList

        local ol = Instance.new("TextLabel")
        ol.Size = UDim2.new(1, -16, 1, 0)
        ol.Position = UDim2.new(0, 8, 0, 0)
        ol.BackgroundTransparency = 1
        ol.Text = opt
        ol.TextColor3 = (opt == selected) and C.Accent or C.TextSecondary
        ol.Font = F.Normal
        ol.TextSize = 11
        ol.TextXAlignment = Enum.TextXAlignment.Left
        ol.ZIndex = 57
        ol.Parent = ob

        ob.MouseEnter:Connect(function()
            ob.BackgroundColor3 = C.BgElement
        end)
        ob.MouseLeave:Connect(function()
            ob.BackgroundColor3 = C.BgDropItem
        end)
        ob.MouseButton1Click:Connect(function()
            callback(opt)
            self:_closeDropdown()
        end)
    end
end

function Library:AddTab(name)
    local tab = {Name = name, _lib = self, _columns = {}}
    table.insert(self._tabs, tab)

    local btn = Instance.new("TextButton")
    btn.Name = "T_" .. name
    btn.Size = UDim2.new(0, math.max(#name * 7.5 + 16, 55), 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = F.Medium
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.LayoutOrder = #self._tabs
    btn.Parent = self._tabBar
    self._tabBtns[name] = btn

    local page = Instance.new("Frame")
    page.Name = "P_" .. name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self._content
    self._pages[name] = page
    tab._page = page

    btn.TextColor3 = C.TextDim

    btn.MouseButton1Click:Connect(function()
        self:_switchTab(name)
    end)
    btn.MouseEnter:Connect(function()
        if self._activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.12), {TextColor3 = C.TextPrimary}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.12), {TextColor3 = C.TextDim}):Play()
        end
    end)

    if #self._tabs == 1 then
        self:_switchTab(name)
    end

    function tab:AddColumn()
        local colCount = #self._columns
        local totalW = self._lib._width - 32
        local colW
        if colCount == 0 then
            colW = math.floor(totalW / 2)
        else
            colW = math.floor(totalW / 2)
        end

        local col = {_lib = self._lib, _elements = {}}

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(0, colW - 4, 1, 0)
        scroll.Position = UDim2.new(0, colCount * (colW + 8), 0, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = C.Accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = self._page
        col._scroll = scroll

        local lay = Instance.new("UIListLayout")
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Padding = UDim.new(0, 2)
        lay.Parent = scroll

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 2)
        pad.PaddingRight = UDim.new(0, 2)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 4)
        pad.Parent = scroll

        table.insert(self._columns, col)

        function col:AddSection(text)
            local s = Instance.new("Frame")
            s.Size = UDim2.new(1, 0, 0, 20)
            s.BackgroundTransparency = 1
            s.LayoutOrder = #self._elements
            s.Parent = self._scroll
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = C.TextPrimary
            l.Font = F.Bold
            l.TextSize = 13
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = s
            table.insert(self._elements, s)
        end

        function col:AddSpacer(h)
            local s = Instance.new("Frame")
            s.Size = UDim2.new(1, 0, 0, h or 6)
            s.BackgroundTransparency = 1
            s.LayoutOrder = #self._elements
            s.Parent = self._scroll
            table.insert(self._elements, s)
        end

        function col:AddToggle(config)
            local text = config.Text or "Toggle"
            local default = config.Default or false
            local helpText = config.Help
            local keybind = config.Keybind
            local cb = config.Callback or function() end

            local state = default
            local ct = Instance.new("Frame")
            ct.Size = UDim2.new(1, 0, 0, 22)
            ct.BackgroundTransparency = 1
            ct.LayoutOrder = #self._elements
            ct.Parent = self._scroll

            local cir = Instance.new("Frame")
            cir.Size = UDim2.new(0, 14, 0, 14)
            cir.Position = UDim2.new(0, 4, 0.5, -7)
            cir.BackgroundColor3 = state and C.Accent or C.ToggleOff
            cir.Parent = ct
            Instance.new("UICorner", cir).CornerRadius = UDim.new(1, 0)
            local cs = Instance.new("UIStroke", cir)
            cs.Color = state and C.Accent or C.Border
            cs.Thickness = 1

            local inner = Instance.new("Frame")
            inner.Size = UDim2.new(0, 6, 0, 6)
            inner.Position = UDim2.new(0.5, -3, 0.5, -3)
            inner.BackgroundColor3 = C.Accent
            inner.BackgroundTransparency = state and 0 or 1
            inner.Parent = cir
            Instance.new("UICorner", inner).CornerRadius = UDim.new(1, 0)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -30, 1, 0)
            lbl.Position = UDim2.new(0, 26, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text .. (helpText and "  (?)" or "")
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
                Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 4)
            end

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(keybind and 0.7 or 1, 0, 1, 0)
            b.BackgroundTransparency = 1
            b.Text = ""
            b.Parent = ct

            b.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(cir, TweenInfo.new(0.12), {BackgroundColor3 = state and C.Accent or C.ToggleOff}):Play()
                TweenService:Create(cs, TweenInfo.new(0.12), {Color = state and C.Accent or C.Border}):Play()
                TweenService:Create(inner, TweenInfo.new(0.12), {BackgroundTransparency = state and 0 or 1}):Play()
                cb(state)
            end)

            table.insert(self._elements, ct)
            return {Set = function(_, v) state = v; cir.BackgroundColor3 = v and C.Accent or C.ToggleOff; cs.Color = v and C.Accent or C.Border; inner.BackgroundTransparency = v and 0 or 1; cb(v) end, Get = function() return state end}
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
            Instance.new("UICorner", sbg).CornerRadius = UDim.new(0, 4)

            local sf = Instance.new("Frame")
            sf.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0)
            sf.BackgroundColor3 = C.Accent
            sf.BorderSizePixel = 0
            sf.Parent = sbg
            Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 4)

            local fg = Instance.new("UIGradient")
            fg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.SliderGrad1), ColorSequenceKeypoint.new(1, C.SliderGrad2)})
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
            Instance.new("UICorner", db).CornerRadius = UDim.new(0, 4)
            local dbs = Instance.new("UIStroke", db)
            dbs.Color = C.Border
            dbs.Thickness = 1

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
            return {Get = function() return selected end, SetOptions = function(_, opts) options = opts end}
        end

        function col:AddColorPickers()
            local ct = Instance.new("Frame")
            ct.Size = UDim2.new(1, 0, 0, 20)
            ct.BackgroundTransparency = 1
            ct.LayoutOrder = #self._elements
            ct.Parent = self._scroll

            local b1 = Instance.new("Frame")
            b1.Size = UDim2.new(0, 16, 0, 16)
            b1.Position = UDim2.new(1, -40, 0.5, -8)
            b1.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            b1.Parent = ct
            Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 3)
            Instance.new("UIStroke", b1).Color = C.Border

            local b2 = Instance.new("Frame")
            b2.Size = UDim2.new(0, 16, 0, 16)
            b2.Position = UDim2.new(1, -20, 0.5, -8)
            b2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            b2.Parent = ct
            Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 3)
            Instance.new("UIStroke", b2).Color = C.Border

            table.insert(self._elements, ct)
        end

        return col
    end

    return tab
end

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
