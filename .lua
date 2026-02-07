local Library = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Настройки темы (Темная + Розовый + Фреймы)
local Theme = {
	Background = Color3.fromRGB(15, 15, 18), -- Основной фон
	SectionText = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(220, 220, 220),
	TextDark = Color3.fromRGB(140, 140, 140),
	Accent = Color3.fromRGB(234, 105, 190), -- Твой розовый
	ElementBg = Color3.fromRGB(25, 25, 30), -- Фон для кнопок/слайдеров
	ElementBorder = Color3.fromRGB(45, 45, 50), -- Обводка элементов
	ToggleOff = Color3.fromRGB(45, 45, 50),
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold
}

local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

-- Функция для добавления обводки (Stroke) к элементам
local function AddStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.ElementBorder
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
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
		Name = "MatchaLib_Pro",
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

	local windowSize = size or UDim2.new(0, 580, 0, 500)

	local Window = Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
		Size = windowSize,
		ClipsDescendants = true
	})
	
	Create("UICorner", {Parent = Window, CornerRadius = UDim.new(0, 8)})
	-- Обводка всего окна
	AddStroke(Window, Color3.fromRGB(60, 60, 65), 1.5) 
	
	local TopBar = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		Name = "TopBar",
		ZIndex = 2
	})
	
	Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(1, -100, 1, 0),
		Font = Theme.FontBold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local CloseBtn = Create("TextButton", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -35, 0, 0),
		Size = UDim2.new(0, 35, 1, 0),
		Font = Theme.Font,
		Text = "×",
		TextColor3 = Theme.TextDark,
		TextSize = 24
	})

	local MinBtn = Create("TextButton", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -70, 0, 0),
		Size = UDim2.new(0, 35, 1, 0),
		Font = Theme.Font,
		Text = "-",
		TextColor3 = Theme.TextDark,
		TextSize = 24
	})
	
	MakeDraggable(Window, TopBar)

	local TabHolder = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 45),
		Size = UDim2.new(1, -30, 0, 25)
	})

	local TabLayout = Create("UIListLayout", {
		Parent = TabHolder,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 15),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local ContentHolder = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 80),
		Size = UDim2.new(1, 0, 1, -80),
		ClipsDescendants = true
	})

	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	local minimized = false
	local originalSize = Window.Size

	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			ContentHolder.Visible = false
			Window:TweenSize(UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 45), "Out", "Quad", 0.3, true)
		else
			Window:TweenSize(originalSize, "Out", "Quad", 0.3, true, function()
				ContentHolder.Visible = true
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

		local TabPage = Create("ScrollingFrame", {
			Parent = ContentHolder,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			BorderSizePixel = 0
		})
		
		-- Вертикальная розовая линия
		local Divider = Create("Frame", {
			Parent = TabPage,
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 2, 1, -20), 
			Position = UDim2.new(0.5, -1, 0, 10),
			ZIndex = 5
		})
		Create("UIGradient", {
			Parent = Divider,
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Theme.Accent),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 50, 120))
			},
			Rotation = 90
		})
		
		local LeftCol = Create("Frame", {
			Parent = TabPage,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.46, 0, 1, 0),
			Position = UDim2.new(0, 12, 0, 0)
		})
		
		local RightCol = Create("Frame", {
			Parent = TabPage,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.46, 0, 1, 0),
			Position = UDim2.new(0.54, -12, 0, 0)
		})
		
		local L_Layout = Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
		local R_Layout = Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

		local function UpdateCanvas()
			local max = math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y)
			TabPage.CanvasSize = UDim2.new(0, 0, 0, max + 40)
			Divider.Size = UDim2.new(0, 2, 0, max + 20)
		end
		L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
		R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

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

		local function CreateItemFunctions(parent)
			local ItemFuncs = {}

			function ItemFuncs:AddSection(text)
				Create("TextLabel", {
					Parent = parent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 25),
					Font = Theme.FontBold,
					Text = text,
					TextColor3 = Theme.SectionText,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			end

			function ItemFuncs:AddToggle(text, default, callback)
				local ToggleContainer = Create("Frame", {
					Parent = parent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 26)
				})
				
				-- Круглый индикатор
				local Indicator = Create("Frame", {
					Parent = ToggleContainer,
					BackgroundColor3 = default and Theme.Accent or Theme.ToggleOff,
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 0, 0.5, -9)
				})
				Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
				-- Обводка для индикатора
				-- AddStroke(Indicator, Theme.ElementBorder, 1)

				local Label = Create("TextLabel", {
					Parent = ToggleContainer,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 26, 0, 0),
					Size = UDim2.new(1, -85, 1, 0),
					Font = Theme.Font,
					Text = text,
					TextColor3 = Theme.TextDark,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				-- Кнопка Бинда (В ФРЕЙМЕ)
				local BindBtn = Create("TextButton", {
					Parent = ToggleContainer,
					BackgroundColor3 = Theme.ElementBg, -- Фон
					Position = UDim2.new(1, -50, 0.5, -9),
					Size = UDim2.new(0, 50, 0, 18),
					Font = Theme.Font,
					Text = "Bind",
					TextColor3 = Theme.TextDark,
					TextSize = 11,
					AutoButtonColor = false
				})
				Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
				AddStroke(BindBtn, Theme.ElementBorder, 1) -- Обводка

				local ClickBtn = Create("TextButton", {
					Parent = ToggleContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -60, 1, 0),
					Text = ""
				})

				local toggled = default
				local bindKey = nil

				local function UpdateState(state)
					toggled = state
					if toggled then
						TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
						Label.TextColor3 = Theme.Text
					else
						TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOff}):Play()
						Label.TextColor3 = Theme.TextDark
					end
					if callback then callback(toggled) end
				end

				ClickBtn.MouseButton1Click:Connect(function()
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
							BindBtn.TextColor3 = Theme.Text
							inputConnection:Disconnect()
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							BindBtn.Text = "Bind"
							bindKey = nil
							BindBtn.TextColor3 = Theme.TextDark
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
				local SliderContainer = Create("Frame", {
					Parent = parent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 45)
				})
				
				Create("TextLabel", {
					Parent = SliderContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					Font = Theme.Font,
					Text = text,
					TextColor3 = Theme.TextDark,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				-- Бар теперь с фоном и обводкой
				local Bar = Create("Frame", {
					Parent = SliderContainer,
					BackgroundColor3 = Theme.ElementBg, -- Фон
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 0, 0, 22)
				})
				Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(0, 4)})
				AddStroke(Bar, Theme.ElementBorder, 1) -- Обводка

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
					Font = Theme.FontBold,
					Text = string.format("%.2f/%.2f", default, max),
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
					ValueLabel.Text = string.format("%.2f/%.2f", value, max)
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
				local DropContainer = Create("Frame", {
					Parent = parent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 48),
					ZIndex = 5
				})
				
				Create("TextLabel", {
					Parent = DropContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					Font = Theme.Font,
					Text = text,
					TextColor3 = Theme.TextDark,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				-- Кнопка списка с фоном и обводкой
				local Box = Create("TextButton", {
					Parent = DropContainer,
					BackgroundColor3 = Theme.ElementBg, -- Фон
					Size = UDim2.new(1, 0, 0, 24),
					Position = UDim2.new(0, 0, 0, 22),
					Text = "",
					AutoButtonColor = false
				})
				Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0, 4)})
				AddStroke(Box, Theme.ElementBorder, 1) -- Обводка
				
				local CurrentText = Create("TextLabel", {
					Parent = Box,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
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
					Position = UDim2.new(1, -20, 0, 0),
					Size = UDim2.new(0, 20, 1, 0),
					Font = Theme.Font,
					Text = "▼",
					TextColor3 = Theme.TextDark,
					TextSize = 9
				})
				
				local List = Create("ScrollingFrame", {
					Parent = Box,
					BackgroundColor3 = Theme.ElementBg,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 1, 4),
					Size = UDim2.new(1, 0, 0, 0),
					Visible = false,
					ZIndex = 10,
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = Theme.Accent
				})
				Create("UICorner", {Parent = List, CornerRadius = UDim.new(0, 4)})
				AddStroke(List, Theme.ElementBorder, 1)
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
					local height = math.min(#options * 24, 120)
					if open then
						List:TweenSize(UDim2.new(1, 0, 0, height), "Out", "Quad", 0.2, true)
					else
						List:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true, function() List.Visible = false end)
					end
				end)
			end

			return ItemFuncs
		end

		return {
			Left = CreateItemFunctions(LeftCol),
			Right = CreateItemFunctions(RightCol)
		}
	end

	return WindowFunctions
end

return Library
