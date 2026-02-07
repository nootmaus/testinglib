local Library = {}

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Настройки темы
local Theme = {
	Background = Color3.fromRGB(18, 18, 22),
	Sidebar = Color3.fromRGB(25, 25, 30),
	SectionBackground = Color3.fromRGB(22, 22, 26),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(160, 160, 160),
	Accent = Color3.fromRGB(234, 105, 190), -- Твой розовый
	AccentHover = Color3.fromRGB(255, 125, 210),
	ElementBg = Color3.fromRGB(35, 35, 40),
	ElementBorder = Color3.fromRGB(50, 50, 55),
	ToggleOn = Color3.fromRGB(234, 105, 190),
	ToggleOff = Color3.fromRGB(45, 45, 50),
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold
}

-- Утилиты
local Utility = {}

function Utility:Tween(instance, properties, duration, style, direction)
	local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

function Utility:Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		if k == "Parent" then
			-- Parent ставим в конце для оптимизации, но здесь для простоты оставляем как есть
			obj.Parent = v
		else
			obj[k] = v
		end
	end
	return obj
end

function Utility:AddStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.ElementBorder
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency = transparency or 0
	stroke.Parent = parent
	return stroke
end

function Utility:AddCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent
	return corner
end

function Utility:MakeDraggable(frame, handle)
	local dragging, dragInput, dragStart, startPos
	handle = handle or frame

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
			local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			
			-- Добавляем плавность перетаскивания (Lerp)
			Utility:Tween(frame, {Position = targetPos}, 0.05, Enum.EasingStyle.Linear)
		end
	end)
end

-- Основная логика
function Library:CreateWindow(title, size)
	local ScreenGui = Utility:Create("ScreenGui", {
		Name = "MatchaLib_Refined",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	-- Защита GUI
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

	local windowSize = size or UDim2.new(0, 600, 0, 450)

	-- Основной фрейм
	local MainFrame = Utility:Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
		Size = windowSize,
		ClipsDescendants = false -- Чтобы тень была видна, если добавить
	})
	
	Utility:AddCorner(MainFrame, 8)
	Utility:AddStroke(MainFrame, Color3.fromRGB(60, 60, 65), 1.5)

	-- Верхняя панель
	local TopBar = Utility:Create("Frame", {
		Parent = MainFrame,
		BackgroundColor3 = Theme.Sidebar,
		Size = UDim2.new(1, 0, 0, 40),
		BorderSizePixel = 0,
		Name = "TopBar"
	})
	Utility:AddCorner(TopBar, 8)
	
	-- Исправление углов снизу для TopBar (чтобы не были круглыми внизу)
	local TopBarFiller = Utility:Create("Frame", {
		Parent = TopBar,
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 1, -10),
		ZIndex = 1
	})

	local TitleLabel = Utility:Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(1, -100, 1, 0),
		Font = Theme.FontBold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2
	})

	-- Кнопки управления окном
	local function CreateWinButton(text, posOffset, callback)
		local btn = Utility:Create("TextButton", {
			Parent = TopBar,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, posOffset, 0, 0),
			Size = UDim2.new(0, 40, 1, 0),
			Font = Theme.Font,
			Text = text,
			TextColor3 = Theme.TextDim,
			TextSize = 18,
			ZIndex = 2
		})
		
		btn.MouseEnter:Connect(function() Utility:Tween(btn, {TextColor3 = Theme.Text}, 0.2) end)
		btn.MouseLeave:Connect(function() Utility:Tween(btn, {TextColor3 = Theme.TextDim}, 0.2) end)
		btn.MouseButton1Click:Connect(callback)
	end

	CreateWinButton("×", -40, function() ScreenGui:Destroy() end)
	
	local Minimized = false
	local OldSize = MainFrame.Size
	local Container -- Forward declaration
	
	CreateWinButton("−", -80, function()
		Minimized = not Minimized
		if Minimized then
			OldSize = MainFrame.Size
			Utility:Tween(MainFrame, {Size = UDim2.new(0, OldSize.X.Offset, 0, 40)}, 0.3, Enum.EasingStyle.Quart)
			if Container then Container.Visible = false end
			TopBarFiller.Visible = false
			Utility:AddCorner(TopBar, 8) -- Вернуть круглые углы
		else
			Utility:Tween(MainFrame, {Size = OldSize}, 0.3, Enum.EasingStyle.Quart)
			task.delay(0.2, function() 
				if Container then Container.Visible = true end 
				TopBarFiller.Visible = true
			end)
		end
	end)

	Utility:MakeDraggable(MainFrame, TopBar)

	-- Контейнер для вкладок и контента
	Container = Utility:Create("Frame", {
		Parent = MainFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 1, -40),
		ClipsDescendants = true
	})

	local TabContainer = Utility:Create("ScrollingFrame", {
		Parent = Container,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(1, -20, 0, 30),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.X
	})
	
	local TabLayout = Utility:Create("UIListLayout", {
		Parent = TabContainer,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local ContentContainer = Utility:Create("Frame", {
		Parent = Container,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 1, -55)
	})

	local WindowFuncs = {}
	local Tabs = {}
	local FirstTab = true

	function WindowFuncs:AddTab(name)
		-- Кнопка вкладки
		local TabBtn = Utility:Create("TextButton", {
			Parent = TabContainer,
			BackgroundColor3 = Theme.ElementBg,
			BackgroundTransparency = 1,
			Text = name,
			Font = Theme.Font,
			TextColor3 = Theme.TextDim,
			TextSize = 14,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
		})
		
		-- Паддинг для текста внутри кнопки
		local TabPadding = Utility:Create("UIPadding", {
			Parent = TabBtn,
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12)
		})
		
		local TabIndicator = Utility:Create("Frame", {
			Parent = TabBtn,
			BackgroundColor3 = Theme.Accent,
			Size = UDim2.new(0, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2),
			BorderSizePixel = 0,
			BackgroundTransparency = 1
		})

		-- Страница контента
		local TabPage = Utility:Create("ScrollingFrame", {
			Parent = ContentContainer,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Accent,
			BorderSizePixel = 0
		})
		
		-- Колонки (Левая и Правая)
		local LeftCol = Utility:Create("Frame", {
			Parent = TabPage,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.48, 0, 1, 0),
			Position = UDim2.new(0, 10, 0, 0)
		})
		local RightCol = Utility:Create("Frame", {
			Parent = TabPage,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.48, 0, 1, 0),
			Position = UDim2.new(0.52, -10, 0, 0)
		})

		local L_Layout = Utility:Create("UIListLayout", {Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
		local R_Layout = Utility:Create("UIListLayout", {Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

		-- Авто-ресайз скролла
		local function UpdateCanvas()
			local contentHeight = math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y)
			TabPage.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
		end
		L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
		R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

		-- Логика переключения
		local function Activate()
			for _, t in pairs(Tabs) do
				Utility:Tween(t.Btn, {TextColor3 = Theme.TextDim}, 0.2)
				Utility:Tween(t.Indicator, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0.2)
				t.Page.Visible = false
			end
			
			Utility:Tween(TabBtn, {TextColor3 = Theme.Text}, 0.2)
			Utility:Tween(TabIndicator, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.2)
			TabPage.Visible = true
		end

		TabBtn.MouseButton1Click:Connect(Activate)

		table.insert(Tabs, {Btn = TabBtn, Indicator = TabIndicator, Page = TabPage})

		if FirstTab then
			Activate()
			FirstTab = false
		end

		-- Функции для добавления элементов
		local function CreateElements(parent)
			local Items = {}

			function Items:AddSection(text)
				local Section = Utility:Create("TextLabel", {
					Parent = parent,
					BackgroundTransparency = 1,
					Text = text,
					Font = Theme.FontBold,
					TextColor3 = Theme.Accent,
					TextSize = 12,
					Size = UDim2.new(1, 0, 0, 20),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom
				})
				Utility:Create("UIPadding", {Parent = Section, PaddingLeft = UDim.new(0, 2)})
			end

			function Items:AddButton(text, callback)
				local Button = Utility:Create("TextButton", {
					Parent = parent,
					BackgroundColor3 = Theme.ElementBg,
					Text = "",
					Size = UDim2.new(1, 0, 0, 32),
					AutoButtonColor = false
				})
				Utility:AddCorner(Button, 6)
				local Stroke = Utility:AddStroke(Button, Theme.ElementBorder, 1)

				local Label = Utility:Create("TextLabel", {
					Parent = Button,
					BackgroundTransparency = 1,
					Text = text,
					Font = Theme.Font,
					TextColor3 = Theme.Text,
					TextSize = 13,
					Size = UDim2.new(1, 0, 1, 0)
				})

				Button.MouseEnter:Connect(function()
					Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}, 0.2)
					Utility:Tween(Stroke, {Color = Theme.Accent}, 0.2)
				end)

				Button.MouseLeave:Connect(function()
					Utility:Tween(Button, {BackgroundColor3 = Theme.ElementBg}, 0.2)
					Utility:Tween(Stroke, {Color = Theme.ElementBorder}, 0.2)
				end)

				Button.MouseButton1Click:Connect(function()
					Utility:Tween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)
					task.wait(0.1)
					Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}, 0.2)
					if callback then callback() end
				end)
			end

			function Items:AddToggle(text, default, callback)
				local ToggleFrame = Utility:Create("Frame", {
					Parent = parent,
					BackgroundColor3 = Theme.ElementBg,
					Size = UDim2.new(1, 0, 0, 32)
				})
				Utility:AddCorner(ToggleFrame, 6)
				local Stroke = Utility:AddStroke(ToggleFrame, Theme.ElementBorder, 1)

				local Label = Utility:Create("TextLabel", {
					Parent = ToggleFrame,
					BackgroundTransparency = 1,
					Text = text,
					Font = Theme.Font,
					TextColor3 = Theme.Text,
					TextSize = 13,
					Size = UDim2.new(1, -70, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local SwitchBase = Utility:Create("Frame", {
					Parent = ToggleFrame,
					BackgroundColor3 = Theme.ToggleOff,
					Size = UDim2.new(0, 40, 0, 20),
					Position = UDim2.new(1, -50, 0.5, -10)
				})
				Utility:AddCorner(SwitchBase, 10)
				
				local SwitchKnob = Utility:Create("Frame", {
					Parent = SwitchBase,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(0, 2, 0.5, -8)
				})
				Utility:AddCorner(SwitchKnob, 8)

				local Trigger = Utility:Create("TextButton", {
					Parent = ToggleFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})

				local Toggled = default
				local function Update(val)
					Toggled = val
					if Toggled then
						Utility:Tween(SwitchBase, {BackgroundColor3 = Theme.ToggleOn}, 0.2)
						Utility:Tween(SwitchKnob, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
						Utility:Tween(Stroke, {Color = Theme.Accent}, 0.2)
					else
						Utility:Tween(SwitchBase, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
						Utility:Tween(SwitchKnob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
						Utility:Tween(Stroke, {Color = Theme.ElementBorder}, 0.2)
					end
					if callback then callback(Toggled) end
				end
				
				Trigger.MouseEnter:Connect(function()
					if not Toggled then Utility:Tween(Stroke, {Color = Color3.fromRGB(80,80,85)}, 0.2) end
				end)
				Trigger.MouseLeave:Connect(function()
					if not Toggled then Utility:Tween(Stroke, {Color = Theme.ElementBorder}, 0.2) end
				end)
				Trigger.MouseButton1Click:Connect(function() Update(not Toggled) end)
				
				Update(default)
				
				-- Возвращаем объект для добавления кейбинда
				local ToggleObj = {}
				function ToggleObj:AddKeybind(defaultKey)
					local Key = defaultKey
					local KeyBtn = Utility:Create("TextButton", {
						Parent = ToggleFrame,
						BackgroundColor3 = Theme.Background,
						Size = UDim2.new(0, 30, 0, 18),
						Position = UDim2.new(1, -90, 0.5, -9),
						Font = Theme.FontBold,
						Text = Key and Key.Name or "NONE",
						TextColor3 = Theme.TextDim,
						TextSize = 10
					})
					Utility:AddCorner(KeyBtn, 4)
					Utility:AddStroke(KeyBtn, Theme.ElementBorder, 1)

					local BindConnection
					local Listening = false

					KeyBtn.MouseButton1Click:Connect(function()
						Listening = true
						KeyBtn.Text = "..."
						KeyBtn.TextColor3 = Theme.Accent
						
						if BindConnection then BindConnection:Disconnect() end
						BindConnection = UserInputService.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.Keyboard then
								Key = input.KeyCode
								KeyBtn.Text = Key.Name
								KeyBtn.TextColor3 = Theme.TextDim
								Listening = false
								BindConnection:Disconnect()
							elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
								-- Отмена
								KeyBtn.Text = Key and Key.Name or "NONE"
								KeyBtn.TextColor3 = Theme.TextDim
								Listening = false
								BindConnection:Disconnect()
							end
						end)
					end)

					UserInputService.InputBegan:Connect(function(input, gp)
						if not gp and not Listening and Key and input.KeyCode == Key then
							Update(not Toggled)
						end
					end)
				end
				return ToggleObj
			end

			function Items:AddSlider(text, min, max, default, callback)
				local SliderFrame = Utility:Create("Frame", {
					Parent = parent,
					BackgroundColor3 = Theme.ElementBg,
					Size = UDim2.new(1, 0, 0, 45)
				})
				Utility:AddCorner(SliderFrame, 6)
				local Stroke = Utility:AddStroke(SliderFrame, Theme.ElementBorder, 1)

				Utility:Create("TextLabel", {
					Parent = SliderFrame,
					BackgroundTransparency = 1,
					Text = text,
					Font = Theme.Font,
					TextColor3 = Theme.Text,
					TextSize = 13,
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 10, 0, 2),
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local ValueBox = Utility:Create("TextBox", {
					Parent = SliderFrame,
					BackgroundTransparency = 1,
					Text = tostring(default),
					Font = Theme.FontBold,
					TextColor3 = Theme.Text,
					TextSize = 13,
					Size = UDim2.new(0, 50, 0, 20),
					Position = UDim2.new(1, -60, 0, 2),
					TextXAlignment = Enum.TextXAlignment.Right
				})

				local Track = Utility:Create("Frame", {
					Parent = SliderFrame,
					BackgroundColor3 = Theme.Background,
					Size = UDim2.new(1, -20, 0, 6),
					Position = UDim2.new(0, 10, 0, 28)
				})
				Utility:AddCorner(Track, 10)

				local Fill = Utility:Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Theme.Accent,
					Size = UDim2.new(0, 0, 1, 0)
				})
				Utility:AddCorner(Fill, 10)

				local function Update(val)
					local percent = math.clamp((val - min) / (max - min), 0, 1)
					local value = math.floor((min + (max - min) * percent) * 100) / 100 -- округление до 2 знаков
					
					ValueBox.Text = value
					Utility:Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
					if callback then callback(value) end
				end
				
				local Dragging = false
				
				local function Move(input)
					local pos = input.Position.X
					local trackAbs = Track.AbsolutePosition.X
					local trackSize = Track.AbsoluteSize.X
					local percent = math.clamp((pos - trackAbs) / trackSize, 0, 1)
					local val = min + (max - min) * percent
					Update(val)
				end

				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
						Move(input)
						Utility:Tween(Stroke, {Color = Theme.Accent}, 0.2)
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						Move(input)
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
						Utility:Tween(Stroke, {Color = Theme.ElementBorder}, 0.2)
					end
				end)
				
				ValueBox.FocusLost:Connect(function()
					local num = tonumber(ValueBox.Text)
					if num then
						Update(math.clamp(num, min, max))
					else
						ValueBox.Text = tostring(min) -- сброс если не число
					end
				end)

				Update(default)
			end

			function Items:AddDropdown(text, options, default, callback)
				local DropdownFrame = Utility:Create("Frame", {
					Parent = parent,
					BackgroundColor3 = Theme.ElementBg,
					Size = UDim2.new(1, 0, 0, 32), -- Начальный размер
					ClipsDescendants = true
				})
				Utility:AddCorner(DropdownFrame, 6)
				local Stroke = Utility:AddStroke(DropdownFrame, Theme.ElementBorder, 1)

				local Header = Utility:Create("TextButton", {
					Parent = DropdownFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32),
					Text = ""
				})

				local Label = Utility:Create("TextLabel", {
					Parent = Header,
					BackgroundTransparency = 1,
					Text = text .. ": " .. (default or "..."),
					Font = Theme.Font,
					TextColor3 = Theme.Text,
					TextSize = 13,
					Size = UDim2.new(1, -30, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Arrow = Utility:Create("TextLabel", {
					Parent = Header,
					BackgroundTransparency = 1,
					Text = "▼",
					Font = Theme.Font,
					TextColor3 = Theme.TextDim,
					TextSize = 12,
					Size = UDim2.new(0, 30, 1, 0),
					Position = UDim2.new(1, -30, 0, 0)
				})

				local OptionContainer = Utility:Create("Frame", {
					Parent = DropdownFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 32)
				})
				
				local OptLayout = Utility:Create("UIListLayout", {
					Parent = OptionContainer,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2)
				})
				
				Utility:Create("UIPadding", {Parent = OptionContainer, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})

				local Open = false
				local DropHeight = 0
				
				for _, opt in ipairs(options) do
					local OptBtn = Utility:Create("TextButton", {
						Parent = OptionContainer,
						BackgroundColor3 = Theme.Background,
						Text = opt,
						Font = Theme.Font,
						TextColor3 = Theme.TextDim,
						TextSize = 12,
						Size = UDim2.new(1, 0, 0, 24),
						AutoButtonColor = false
					})
					Utility:AddCorner(OptBtn, 4)
					
					OptBtn.MouseEnter:Connect(function() 
						Utility:Tween(OptBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(1,1,1)}, 0.15) 
					end)
					OptBtn.MouseLeave:Connect(function() 
						Utility:Tween(OptBtn, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextDim}, 0.15) 
					end)
					
					OptBtn.MouseButton1Click:Connect(function()
						Open = false
						Label.Text = text .. ": " .. opt
						Utility:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
						Utility:Tween(Arrow, {Rotation = 0}, 0.2)
						Utility:Tween(Stroke, {Color = Theme.ElementBorder}, 0.2)
						if callback then callback(opt) end
					end)
					
					DropHeight = DropHeight + 26
				end

				Header.MouseButton1Click:Connect(function()
					Open = not Open
					if Open then
						Utility:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 32 + DropHeight + 10)}, 0.2)
						Utility:Tween(Arrow, {Rotation = 180}, 0.2)
						Utility:Tween(Stroke, {Color = Theme.Accent}, 0.2)
					else
						Utility:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
						Utility:Tween(Arrow, {Rotation = 0}, 0.2)
						Utility:Tween(Stroke, {Color = Theme.ElementBorder}, 0.2)
					end
				end)
			end

			return Items
		end

		return {
			Left = CreateElements(LeftCol),
			Right = CreateElements(RightCol)
		}
	end

	return WindowFuncs
end

return Library
