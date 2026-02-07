local Players, UIS, Tween, Run, Core = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("CoreGui")

local Library = {}
Library.__index = Library

local C = {
	BgMain = Color3.fromRGB(18, 18, 22), BgHeader = Color3.fromRGB(12, 12, 16),
	BgSection = Color3.fromRGB(28, 28, 34), BgElement = Color3.fromRGB(38, 38, 46),
	BgSlider = Color3.fromRGB(50, 50, 60), BgDropdown = Color3.fromRGB(30, 30, 38),
	BgDropItem = Color3.fromRGB(34, 34, 42), Accent = Color3.fromRGB(245, 170, 230),
	TextPrimary = Color3.fromRGB(235, 235, 235), TextSecondary = Color3.fromRGB(170, 170, 180),
	TextDim = Color3.fromRGB(110, 110, 120), ToggleOff = Color3.fromRGB(50, 50, 60),
	Border = Color3.fromRGB(48, 48, 58), Red = Color3.fromRGB(210, 60, 60)
}

local F = { Bold = Enum.Font.GothamBold, Medium = Enum.Font.GothamMedium, Normal = Enum.Font.Gotham }

-- Функция для быстрого создания объектов (экономит место)
local function create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, child in pairs(children or {}) do child.Parent = inst end
	return inst
end

function Library.new(cfg)
	local self = setmetatable({}, Library)
	cfg = cfg or {}
	self._conns, self._tabs, self._tabBtns, self._pages = {}, {}, {}, {}
	self._width, self._height = cfg.Width or 680, cfg.Height or 560
	local title, subtitle = cfg.Title or "Matcha", cfg.Subtitle or ""

	if Core:FindFirstChild("MatchaLib") then Core.MatchaLib:Destroy() end
	self._sg = create("ScreenGui", {Name = "MatchaLib", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100, Parent = Core})
	
	-- Основное окно
	self._main = create("Frame", {
		Name = "Main", Size = UDim2.new(0, self._width, 0, self._height), Position = UDim2.new(0.5, -self._width/2, 0.5, -self._height/2),
		BackgroundColor3 = C.BgMain, BorderSizePixel = 0, Active = true, ClipsDescendants = true, Parent = self._sg
	}, {create("UICorner", {CornerRadius = UDim.new(0, 8)}), create("UIStroke", {Color = C.Border, Thickness = 1})})

	-- Хедер
	self._header = create("Frame", {
		Name = "Hdr", Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.BgHeader, BorderSizePixel = 0, Parent = self._main
	}, {
		create("UICorner", {CornerRadius = UDim.new(0, 8)}),
		create("Frame", {Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = C.BgHeader, BorderSizePixel = 0}),
		create("Frame", {Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 10, 0.5, -3), BackgroundColor3 = C.Accent}, {create("UICorner", {CornerRadius = UDim.new(1, 0)})}),
		create("TextLabel", {Size = UDim2.new(0.5, -80, 1, 0), Position = UDim2.new(0, 22, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = C.TextSecondary, Font = F.Medium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}),
		create("TextLabel", {Size = UDim2.new(0.5, -80, 1, 0), Position = UDim2.new(0.5, 10, 0, 0), BackgroundTransparency = 1, Text = subtitle, TextColor3 = C.TextDim, Font = F.Normal, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right})
	})

	-- Новые кнопки (Закрыть и Свернуть)
	local btnContainer = create("Frame", {Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(1, -65, 0, 0), BackgroundTransparency = 1, Parent = self._header})
	local layout = create("UIListLayout", {Parent = btnContainer, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
	
	local function mkBtn(txt, col, cb)
		local b = create("TextButton", {Size = UDim2.new(0, 24, 0, 24), BackgroundColor3 = C.BgElement, Text = txt, TextColor3 = C.TextPrimary, Font = F.Bold, TextSize = 14, AutoButtonColor = false, Parent = btnContainer}, {create("UICorner", {CornerRadius = UDim.new(0, 6)})})
		b.MouseEnter:Connect(function() Tween:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play() end)
		b.MouseLeave:Connect(function() Tween:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = C.BgElement}):Play() end)
		b.MouseButton1Click:Connect(cb)
		return b
	end

	-- Кнопка свернуть (-)
	self._minimized, self._normSize, self._miniSize = false, UDim2.new(0, self._width, 0, self._height), UDim2.new(0, self._width, 0, 32)
	mkBtn("-", C.Accent, function()
		self._minimized = not self._minimized
		if self._minimized then
			self._tabBar.Visible, self._content.Visible = false, false
			self._main:TweenSize(self._miniSize, "Out", "Quad", 0.25, true)
		else
			self._main:TweenSize(self._normSize, "Out", "Quad", 0.25, true)
			task.delay(0.25, function() if not self._minimized then self._tabBar.Visible, self._content.Visible = true, true end end)
		end
	end)

	-- Кнопка закрыть (x)
	mkBtn("×", C.Red, function() self:Destroy() end)
	create("UIPadding", {Parent = btnContainer, PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 0)})

	-- Таб бар и контент
	self._tabBar = create("Frame", {Name = "TabBar", Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 32), BackgroundColor3 = C.BgHeader, BorderSizePixel = 0, Parent = self._main}, 
		{create("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = C.Border, BorderSizePixel = 0}), create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder})})
	self._content = create("Frame", {Name = "Content", Size = UDim2.new(1, -16, 1, -68), Position = UDim2.new(0, 8, 0, 64), BackgroundTransparency = 1, ClipsDescendants = false, Parent = self._main})

	-- Дропдауны
	self._dropOverlay = create("Frame", {Name = "DropOverlay", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 50, Visible = false, Parent = self._main})
	create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 50, Parent = self._dropOverlay}).MouseButton1Click:Connect(function() self:_closeDropdown() end)
	self._dropList = create("Frame", {Name = "DropList", BackgroundColor3 = C.BgDropdown, BorderSizePixel = 0, ZIndex = 55, Visible = false, Parent = self._dropOverlay}, 
		{create("UICorner", {CornerRadius = UDim.new(0, 4)}), create("UIStroke", {Color = C.Border, Thickness = 1}), create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})})

	-- Перетаскивание (Drag)
	local dragging, dragStart, startPos
	self._header.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, inp.Position, self._main.Position end end)
	table.insert(self._conns, UIS.InputChanged:Connect(function(inp) 
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then 
			local d = inp.Position - dragStart
			self._main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) 
		end 
	end))
	table.insert(self._conns, UIS.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))

	-- Тоггл клавиша
	if cfg.ToggleKey then
		table.insert(self._conns, UIS.InputBegan:Connect(function(inp, gpe) if not gpe and inp.KeyCode == cfg.ToggleKey then self._main.Visible = not self._main.Visible end end))
	end
	return self
end

function Library:_closeDropdown()
	self._dropOverlay.Visible, self._dropList.Visible, self._activeDropdown = false, false, nil
	for _, c in pairs(self._dropList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
end

function Library:_openDropdown(btn, options, selected, cb)
	self:_closeDropdown()
	local absPos, absSize, mainPos = btn.AbsolutePosition, btn.AbsoluteSize, self._main.AbsolutePosition
	local x, y, w = absPos.X - mainPos.X, absPos.Y - mainPos.Y + absSize.Y + 2, absSize.X
	local totalH = math.min(#options * 24, self._main.AbsoluteSize.Y - 10 - y)
	
	self._dropList.Position, self._dropList.Size, self._dropList.Visible, self._dropOverlay.Visible = UDim2.new(0, x, 0, y), UDim2.new(0, w, 0, totalH), true, true
	for i, opt in ipairs(options) do
		local ob = create("TextButton", {Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = C.BgDropItem, Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 56, Parent = self._dropList})
		create("TextLabel", {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = opt, TextColor3 = (opt==selected and C.Accent or C.TextSecondary), Font = F.Normal, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 57, Parent = ob})
		ob.MouseEnter:Connect(function() ob.BackgroundColor3 = C.BgElement end)
		ob.MouseLeave:Connect(function() ob.BackgroundColor3 = C.BgDropItem end)
		ob.MouseButton1Click:Connect(function() cb(opt); self:_closeDropdown() end)
	end
end

function Library:AddTab(name)
	local tab = {Name = name, _lib = self, _columns = {}}
	table.insert(self._tabs, tab)
	local btn = create("TextButton", {Name = "T_"..name, Size = UDim2.new(0, math.max(#name*7.5+16, 55), 1, 0), BackgroundTransparency = 1, Text = name, Font = F.Medium, TextSize = 11, AutoButtonColor = false, LayoutOrder = #self._tabs, TextColor3 = C.TextDim, Parent = self._tabBar})
	self._tabBtns[name] = btn
	tab._page = create("Frame", {Name = "P_"..name, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = self._content})
	self._pages[name] = tab._page

	btn.MouseButton1Click:Connect(function() self:_switchTab(name) end)
	btn.MouseEnter:Connect(function() if self._activeTab~=name then Tween:Create(btn, TweenInfo.new(0.12), {TextColor3 = C.TextPrimary}):Play() end end)
	btn.MouseLeave:Connect(function() if self._activeTab~=name then Tween:Create(btn, TweenInfo.new(0.12), {TextColor3 = C.TextDim}):Play() end end)
	if #self._tabs == 1 then self:_switchTab(name) end

	function tab:AddColumn()
		local col, colCount = {_lib = self._lib, _elements = {}}, #self._columns
		local colW = math.floor((self._lib._width - 32) / 2)
		local scroll = create("ScrollingFrame", {Size = UDim2.new(0, colW-4, 1, 0), Position = UDim2.new(0, colCount*(colW+8), 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = tab._page},
			{create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}), create("UIPadding", {PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})})
		col._scroll = scroll
		table.insert(self._columns, col)

		function col:AddSection(text)
			create("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = #self._elements, Parent = self._scroll}, 
				{create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.TextPrimary, Font = F.Bold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})})
			table.insert(self._elements, {})
		end
		function col:AddSpacer(h)
			create("Frame", {Size = UDim2.new(1, 0, 0, h or 6), BackgroundTransparency = 1, LayoutOrder = #self._elements, Parent = self._scroll})
			table.insert(self._elements, {})
		end
		function col:AddToggle(cfg)
			local state, ct = cfg.Default or false, create("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = #self._elements, Parent = self._scroll})
			local cir = create("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 4, 0.5, -7), BackgroundColor3 = state and C.Accent or C.ToggleOff, Parent = ct}, {create("UICorner", {CornerRadius = UDim.new(1, 0)})})
			local cs = create("UIStroke", {Color = state and C.Accent or C.Border, Thickness = 1, Parent = cir})
			local inner = create("Frame", {Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0.5, -3, 0.5, -3), BackgroundColor3 = C.Accent, BackgroundTransparency = state and 0 or 1, Parent = cir}, {create("UICorner", {CornerRadius = UDim.new(1, 0)})})
			create("TextLabel", {Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 26, 0, 0), BackgroundTransparency = 1, Text = (cfg.Text or "Toggle")..(cfg.Help and " (?)" or ""), TextColor3 = C.TextSecondary, Font = F.Normal, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = ct})
			if cfg.Keybind then create("TextLabel", {Size = UDim2.new(0, math.max(#cfg.Keybind*6+12, 30), 0, 16), Position = UDim2.new(1, -(math.max(#cfg.Keybind*6+12, 30)+4), 0.5, -8), BackgroundColor3 = C.BgElement, TextColor3 = C.TextDim, Font = F.Normal, TextSize = 10, Text = cfg.Keybind, Parent = ct}, {create("UICorner", {CornerRadius = UDim.new(0, 4)})}) end
			
			local function toggle(v)
				state = v
				Tween:Create(cir, TweenInfo.new(0.12), {BackgroundColor3 = v and C.Accent or C.ToggleOff}):Play()
				Tween:Create(cs, TweenInfo.new(0.12), {Color = v and C.Accent or C.Border}):Play()
				Tween:Create(inner, TweenInfo.new(0.12), {BackgroundTransparency = v and 0 or 1}):Play()
				if cfg.Callback then cfg.Callback(v) end
			end
			create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = ct}).MouseButton1Click:Connect(function() toggle(not state) end)
			table.insert(self._elements, ct)
			return {Set = function(_, v) toggle(v) end, Get = function() return state end}
		end
		function col:AddSlider(cfg)
			local val, min, max, dec = cfg.Default or cfg.Min or 0, cfg.Min or 0, cfg.Max or 100, cfg.Decimals or 2
			local ct = create("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = #self._elements, Parent = self._scroll})
			create("TextLabel", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = cfg.Text or "Slider", TextColor3 = C.TextSecondary, Font = F.Normal, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = ct})
			local sbg = create("Frame", {Size = UDim2.new(1, -4, 0, 16), Position = UDim2.new(0, 2, 0, 18), BackgroundColor3 = C.BgSlider, Parent = ct}, {create("UICorner", {CornerRadius = UDim.new(0, 4)})})
			local sf = create("Frame", {Size = UDim2.new(math.clamp((val-min)/(max-min), 0, 1), 0, 1, 0), BackgroundColor3 = C.Accent, BorderSizePixel = 0, Parent = sbg}, {create("UICorner", {CornerRadius = UDim.new(0, 4)}), create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.Accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))})})})
			local vl = create("TextLabel", {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = string.format("%."..dec.."f/%."..dec.."f", val, max), TextColor3 = C.TextPrimary, Font = F.Medium, TextSize = 10, ZIndex = 3, Parent = sbg})
			local function upd(inp)
				local p = math.clamp((inp.Position.X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
				val = min + (max - min) * p
				sf.Size = UDim2.new(p, 0, 1, 0)
				vl.Text = string.format("%."..dec.."f/%."..dec.."f", val, max)
				if cfg.Callback then cfg.Callback(val) end
			end
			local sdrag, ib = false, create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 4, Parent = sbg})
			ib.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sdrag, upd(i) end end)
			table.insert(self._lib._conns, UIS.InputChanged:Connect(function(i) if sdrag and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end end))
			table.insert(self._lib._conns, UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sdrag = false end end))
			table.insert(self._elements, ct)
			return {Get = function() return val end}
		end
		function col:AddDropdown(cfg)
			local sel, options = cfg.Default or cfg.Options[1], cfg.Options or {"None"}
			local ct = create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, LayoutOrder = #self._elements, Parent = self._scroll})
			create("TextLabel", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = cfg.Text or "Drop", TextColor3 = C.TextSecondary, Font = F.Normal, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = ct})
			local db = create("TextButton", {Size = UDim2.new(1, -4, 0, 22), Position = UDim2.new(0, 2, 0, 16), BackgroundColor3 = C.BgDropdown, Text = "", AutoButtonColor = false, Parent = ct}, {create("UICorner", {CornerRadius = UDim.new(0, 4)}), create("UIStroke", {Color = C.Border, Thickness = 1})})
			local sl = create("TextLabel", {Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = sel, TextColor3 = C.TextPrimary, Font = F.Normal, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = db})
			create("TextLabel", {Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Text = "▼", TextColor3 = C.TextDim, Font = F.Normal, TextSize = 9, Parent = db})
			db.MouseButton1Click:Connect(function() self._lib:_openDropdown(db, options, sel, function(o) sel, sl.Text = o, o; if cfg.Callback then cfg.Callback(o) end end) end)
			table.insert(self._elements, ct)
			return {Get = function() return sel end, SetOptions = function(_, o) options = o end}
		end
		return col
	end
	return tab
end

function Library:_switchTab(name)
	for n, p in pairs(self._pages) do p.Visible = (n == name) end
	for n, b in pairs(self._tabBtns) do b.TextColor3 = (n == name) and C.Accent or C.TextDim end
	self._activeTab = name
	self:_closeDropdown()
end

function Library:Destroy()
	for _, c in pairs(self._conns) do c:Disconnect() end
	if self._sg then self._sg:Destroy() end
end

return Library
