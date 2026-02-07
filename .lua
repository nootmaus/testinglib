local Library = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Твоя тема (Темная + Розовый акцент)
local Theme = {
	Background = Color3.fromRGB(18, 18, 22),
	Section = Color3.fromRGB(24, 24, 28),
	Text = Color3.fromRGB(240, 240, 240),
	TextDark = Color3.fromRGB(160, 160, 160),
	Accent = Color3.fromRGB(234, 105, 190), 
	Border = Color3.fromRGB(40, 40, 45),
	BindBg = Color3.fromRGB(35, 35, 40),
	Font = Enum.Font.GothamMedium
}

local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

local function MakeDraggable(frame, dragHandle)
	local dragging, dragInput, dragStart, startPos
	local handle = dragHandle or frame

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function Library:CreateWindow(title, size)
	local ScreenGui = Create("ScreenGui", {
		Name = "MatchaLib_Single",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	if gethui then
		ScreenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = CoreGui
	elseif CoreGui:FindFirstChild("RobloxGui") then
		ScreenGui.Parent = CoreGui
	else
		ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Размер по умолчанию, если не указан
	local windowSize = size or UDim2.new(0, 350, 0, 450)

	local Window = Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
		Size = windowSize,
		ClipsDescendants = true
	})
	
	Create("UICorner", {Parent = Window, CornerRadius = UDim.new(0, 6)})
	
	-- Шапка
	local TopBar = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 35),
		Name = "TopBar",
		ZIndex = 2
	})
	
	Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(1, -100, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local CloseBtn = Create("TextButton", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -30, 0, 0),
		Size = UDim2.new(0, 30, 1, 0),
		Font = Theme.Font,
		Text = "×",
		TextColor3 = Theme.TextDark,
		TextSize = 20
	})

	local MinBtn = Create("TextButton", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -60, 0, 0),
		Size = UDim2.new(0, 30, 1, 0),
		Font = Theme.Font,
		Text = "-",
		TextColor3 = Theme.TextDark,
		TextSize = 20
	})
	
	MakeDraggable(Window, TopBar)

	-- Контейнер для кнопок вкладок
	local TabHolder = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 40),
		Size = UDim2.new(1, -30, 0, 25)
	})

	local TabLayout = Create("UIListLayout", {
		Parent = TabHolder,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 15),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	-- Основной контейнер контента
	local ContentHolder = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 70),
		Size = UDim2.new(1, 0, 1, -70),
		ClipsDescendants = true
	})

	-- Розовая линия (теперь горизонтальная, отделяет шапку)
	local Separator = Create("Frame", {
		Parent = Window,
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1), 
		Position = UDim2.new(0, 0, 0, 69),
		ZIndex = 5
	})
	Create("UIGradient", {
		Parent = Separator,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.Background),
			ColorSequenceKeypoint.new(0.5, Theme.Accent),
			ColorSequenceKeypoint.new(1, Theme.Background)
		}
	})

	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	local minimized = false
	local originalSize = Window.Size

	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			ContentHolder.Visible = false
			Separator.Visible = false
			Window:TweenSize(UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 35), "Out", "Quad", 0.3, true)
		else
			Window:TweenSize(originalSize, "Out", "Quad", 0.3, true, function()
				ContentHolder.Visible = true
				Separator.Visible = true
			end)
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Insert then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end)

	local Tabs = {}
	local WindowFunctions = {}

	function WindowFunctions:AddTab(name)
		local TabBtn = Create("TextButton", {
			Parent = TabHolder,
			BackgroundTransparency = 1,
			Font = Theme.Font,
			Text = name,
			TextColor3 = Theme.TextDark,
			TextSize = 13,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0)
		})

		-- Единый скролл-фрейм для всей вкладки (1 колонка)
		local TabPage = Create("ScrollingFrame", {
			Parent = ContentHolder,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 1, 0), -- Чуть меньше ширины для скроллбара
			Position = UDim2.new(0, 5, 0, 0),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			BorderSizePixel = 0
		})
		
		-- Лайаут для списка элементов (одна колонка)
		local ListLayout = Create("UIListLayout", {
			Parent = TabPage, 
			SortOrder = Enum.SortOrder.LayoutOrder, 
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center -- Центрируем элементы
		})

		-- Паддинг, чтобы элементы не прилипали к краям
		local Padding = Create("UIPadding", {
			Parent = TabPage,
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10)
		})

		-- Авто-ресайз скролла
		ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabPage.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
		end)

		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(Tabs) do
				t.Btn.TextColor3 = Theme.TextDark
				t.Page.Visible = false
			end
			TabBtn.TextColor3 = Theme.Accent
			TabPage.Visible = true
		end)

		if #Tabs == 0 then
			TabBtn.TextColor3 = Theme.Accent
			TabPage.Visible = true
		end

		table.insert(Tabs, {Btn = TabBtn, Page = TabPage})

		-- Функции добавления элементов (теперь напрямую в TabPage)
		local ItemFuncs = {}

		function ItemFuncs:AddSection(text)
			Create("TextLabel", {
				Parent = TabPage,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 25),
				Font = Enum.Font.GothamBold,
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		end

		function ItemFuncs:AddToggle(text, default, callback)
			local ToggleFrame = Create("TextButton", {
				Parent = TabPage,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 28),
				Text = ""
			})
			
			local Indicator = Create("Frame", {
				Parent = ToggleFrame,
				BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50,50,55),
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 0, 0.5, -8)
			})
			Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
			
			local Label = Create("TextLabel", {
				Parent = ToggleFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 25, 0, 0),
				Size = UDim2.new(1, -80, 1, 0),
				Font = Theme.Font,
				Text = text,
				TextColor3 = Theme.TextDark,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local BindBtn = Create("TextButton", {
				Parent = ToggleFrame,
				BackgroundColor3 = Theme.BindBg,
				Position = UDim2.new(1, -50, 0.5, -9),
				Size = UDim2.new(0, 50, 0, 18),
				Font = Enum.Font.Gotham,
				Text = "Bind",
				TextColor3 = Color3.fromRGB(150,150,150),
				TextSize = 10,
				AutoButtonColor = false
			})
			Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})

			local toggled = default
			local bindKey = nil

			local function UpdateState(state)
				toggled = state
				if toggled then
					TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
					Label.TextColor3 = Theme.Text
				else
					TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,50,55)}):Play()
					Label.TextColor3 = Theme.TextDark
				end
				if callback then callback(toggled) end
			end

			ToggleFrame.MouseButton1Click:Connect(function()
				UpdateState(not toggled)
			end)

			BindBtn.MouseButton1Click:Connect(function()
				BindBtn.Text = "..."
				BindBtn.TextColor3 = Theme.Accent
				local inputConnection
				inputConnection = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						bindKey = input.KeyCode
						BindBtn.Text = bindKey.Name
						BindBtn.TextColor3 = Color3.fromRGB(200,200,200)
						inputConnection:Disconnect()
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
						BindBtn.Text = "Bind"
						bindKey = nil
						BindBtn.TextColor3 = Color3.fromRGB(150,150,150)
						inputConnection:Disconnect()
					end
				end)
			end)

			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if not gameProcessed and bindKey and input.KeyCode == bindKey then
					UpdateState(not toggled)
				end
			end)
		end

		function ItemFuncs:AddSlider(text, min, max, default, callback)
			local SliderFrame = Create("Frame", {
				Parent = TabPage,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 45)
			})
			Create("TextLabel", {
				Parent = SliderFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				Font = Theme.Font,
				Text = text,
				TextColor3 = Theme.TextDark,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			local Bar = Create("Frame", {
				Parent = SliderFrame,
				BackgroundColor3 = Theme.BindBg,
				Size = UDim2.new(1, 0, 0, 18),
				Position = UDim2.new(0, 0, 0, 22)
			})
			Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(0, 4)})
			
			local Fill = Create("Frame", {
				Parent = Bar,
				BackgroundColor3 = Theme.Accent,
				Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
			})
			Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(0, 4)})
			
			local ValueLabel = Create("TextLabel", {
				Parent = Bar,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = string.format("%.2f/%s", default, max),
				TextColor3 = Color3.new(1,1,1),
				TextSize = 11,
				ZIndex = 2
			})
			
			local dragging = false
			local function Update(input)
				local sizeX = Bar.AbsoluteSize.X
				local posX = Bar.AbsolutePosition.X
				local percent = math.clamp((input.Position.X - posX) / sizeX, 0, 1)
				local value = min + (max - min) * percent
				Fill.Size = UDim2.new(percent, 0, 1, 0)
				ValueLabel.Text = string.format("%.2f/%s", value, max)
				if callback then callback(value) end
			end
			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					Update(input)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					Update(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
		end

		function ItemFuncs:AddDropdown(text, options, default, callback)
			local DropFrame = Create("Frame", {
				Parent = TabPage,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 45),
				ZIndex = 5
			})
			Create("TextLabel", {
				Parent = DropFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Theme.Font,
				Text = text,
				TextColor3 = Theme.TextDark,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			local Box = Create("TextButton", {
				Parent = DropFrame,
				BackgroundColor3 = Theme.BindBg,
				Size = UDim2.new(1, 0, 0, 24),
				Position = UDim2.new(0, 0, 0, 20),
				Text = "",
				AutoButtonColor = false
			})
			Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0, 4)})
			
			local CurrentText = Create("TextLabel", {
				Parent = Box,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 0, 0),
				Size = UDim2.new(1, -25, 1, 0),
				Font = Theme.Font,
				Text = default or options[1],
				TextColor3 = Theme.Text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			Create("TextLabel", {
				Parent = Box,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -15, 0, 0),
				Size = UDim2.new(0, 15, 1, 0),
				Font = Theme.Font,
				Text = "▼",
				TextColor3 = Theme.TextDark,
				TextSize = 9
			})
			
			local List = Create("ScrollingFrame", {
				Parent = Box,
				BackgroundColor3 = Theme.BindBg,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, 2),
				Size = UDim2.new(1, 0, 0, 0),
				Visible = false,
				ZIndex = 10,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = Theme.Accent
			})
			Create("UICorner", {Parent = List, CornerRadius = UDim.new(0, 4)})
			Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})
			
			local open = false
			for _, opt in ipairs(options) do
				local OptBtn = Create("TextButton", {
					Parent = List,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 24),
					Font = Theme.Font,
					Text = "  " .. opt,
					TextColor3 = Theme.TextDark,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11
				})
				OptBtn.MouseButton1Click:Connect(function()
					CurrentText.Text = opt
					open = false
					List.Visible = false
					List:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
					if callback then callback(opt) end
				end)
			end
			Box.MouseButton1Click:Connect(function()
				open = not open
				List.Visible = true
				local height = math.min(#options * 24, 140)
				if open then
					List:TweenSize(UDim2.new(1, 0, 0, height), "Out", "Quad", 0.2, true)
				else
					List:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true, function() List.Visible = false end)
				end
			end)
		end

		return ItemFuncs 
	end

	return WindowFunctions
end

return Library
