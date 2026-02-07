local Library = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Theme = {
	Background = Color3.fromRGB(15, 15, 15),
	Section = Color3.fromRGB(35, 35, 35),
	Text = Color3.fromRGB(230, 230, 230),
	TextDark = Color3.fromRGB(140, 140, 140),
	MainColor = Color3.fromRGB(60, 170, 255),
	Border = Color3.fromRGB(50, 50, 50),
	Font = Enum.Font.Gotham
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

local function AddBorderGradient(parent)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	}
	gradient.Rotation = 45
	gradient.Parent = parent
	return gradient
end

-- ИЗМЕНЕНО: Добавлен аргумент size
function Library:CreateWindow(title, size)
	local ScreenGui = Create("ScreenGui", {
		Name = "MatchaLib",
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

	-- ИЗМЕНЕНО: Если размер не указан, ставим стандартный 460x400
	local windowSize = size or UDim2.new(0, 460, 0, 400)

	local Window = Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2), -- Центрируем по размеру
		Size = windowSize,
		ClipsDescendants = true
	})
	
	Create("UICorner", {Parent = Window, CornerRadius = UDim.new(0, 6)})
	
	local Stroke = Create("UIStroke", {
		Parent = Window, 
		Color = Theme.MainColor, 
		Thickness = 2,
		Transparency = 0
	})
	AddBorderGradient(Stroke)
	
	local TopBar = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		Name = "TopBar",
		ZIndex = 2
	})
	
	Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -70, 1, 0),
		Font = Theme.Font,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local CloseBtn = Create("TextButton", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -25, 0, 0),
		Size = UDim2.new(0, 25, 1, 0),
		Font = Theme.Font,
		Text = "X",
		TextColor3 = Theme.TextDark,
		TextSize = 13
	})

	local MinBtn = Create("TextButton", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -50, 0, 0),
		Size = UDim2.new(0, 25, 1, 0),
		Font = Theme.Font,
		Text = "–",
		TextColor3 = Theme.TextDark,
		TextSize = 16
	})
	
	MakeDraggable(Window, TopBar)

	local TabHolder = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 32),
		Size = UDim2.new(1, -20, 0, 22)
	})

	local TabLayout = Create("UIListLayout", {
		Parent = TabHolder,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local ContentHolder = Create("Frame", {
		Parent = Window,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 60),
		Size = UDim2.new(1, -20, 1, -65),
		ClipsDescendants = true
	})

	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	local minimized = false
	local originalSize = Window.Size

	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			ContentHolder.Visible = false
			Window:TweenSize(UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30), "Out", "Quad", 0.3, true)
		else
			Window:TweenSize(originalSize, "Out", "Quad", 0.3, true, function()
				ContentHolder.Visible = true
			end)
		end
	end)

	for _, btn in pairs({CloseBtn, MinBtn}) do
		btn.MouseEnter:Connect(function() btn.TextColor3 = Theme.MainColor end)
		btn.MouseLeave:Connect(function() btn.TextColor3 = Theme.TextDark end)
	end
	
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
			TextSize = 12,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0)
		})

		local TabPage = Create("ScrollingFrame", {
			Parent = ContentHolder,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.MainColor,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			BorderSizePixel = 0
		})
		
		local LeftColFrame = Create("Frame", {
			Parent = TabPage,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.48, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0)
		})
		
		local RightColFrame = Create("Frame", {
			Parent = TabPage,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.48, 0, 1, 0),
			Position = UDim2.new(0.52, 0, 0, 0)
		})
		
		local L_Layout = Create("UIListLayout", {Parent = LeftColFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
		local R_Layout = Create("UIListLayout", {Parent = RightColFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})

		local function UpdateCanvas()
			local max = math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y)
			TabPage.CanvasSize = UDim2.new(0, 0, 0, max + 20)
		end
		L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
		R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(Tabs) do
				t.Btn.TextColor3 = Theme.TextDark
				t.Page.Visible = false
			end
			TabBtn.TextColor3 = Theme.MainColor
			TabPage.Visible = true
		end)

		if #Tabs == 0 then
			TabBtn.TextColor3 = Theme.MainColor
			TabPage.Visible = true
		end

		table.insert(Tabs, {Btn = TabBtn, Page = TabPage})

		local function CreateItemFunctions(parent)
			local ItemFuncs = {}

			function ItemFuncs:AddSection(text)
				Create("TextLabel", {
					Parent = parent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					Font = Theme.Font,
					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			end

			function ItemFuncs:AddToggle(text, default, callback)
				local ToggleFrame = Create("TextButton", {
					Parent = parent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					Text = ""
				})
				
				local Indicator = Create("Frame", {
					Parent = ToggleFrame,
					BackgroundColor3 = default and Theme.MainColor or Theme.Section,
					Size = UDim2.new(0, 10, 0, 10),
					Position = UDim2.new(0, 1, 0.5, -5)
				})
				Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(0, 2)})
				Create("UIStroke", {Parent = Indicator, Color = Theme.Border, Thickness = 1})
				
				local Label = Create("TextLabel", {
					Parent = ToggleFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 18, 0, 0),
					Size = UDim2.new(1, -18, 1, 0),
					Font = Theme.Font,
					Text = text,
					TextColor3 = Theme.TextDark,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local toggled = default
				ToggleFrame.MouseButton1Click:Connect(function()
					toggled = not toggled
					Indicator.BackgroundColor3 = toggled and Theme.MainColor or Theme.Section
					Label.TextColor3 = toggled and Theme.Text or Theme.TextDark
					if callback then callback(toggled) end
				end)
			end

			function ItemFuncs:AddSlider(text, min, max, default, callback)
				local SliderFrame = Create("Frame", {
					Parent = parent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 38)
				})
				Create("TextLabel", {
					Parent = SliderFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 15),
					Font = Theme.Font,
					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local Bar = Create("Frame", {
					Parent = SliderFrame,
					BackgroundColor3 = Theme.Section,
					Size = UDim2.new(1, 0, 0, 12),
					Position = UDim2.new(0, 0, 0, 18)
				})
				Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(0, 4)})
				Create("UIStroke", {Parent = Bar, Color = Theme.Border, Thickness = 1})
				local Fill = Create("Frame", {
					Parent = Bar,
					BackgroundColor3 = Theme.MainColor,
					Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
				})
				Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(0, 4)})
				local ValueLabel = Create("TextLabel", {
					Parent = Bar,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Font = Theme.Font,
					Text = string.format("%.2f/%.2f", default, max),
					TextColor3 = Color3.new(1,1,1),
					TextSize = 10,
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
				local DropFrame = Create("Frame", {
					Parent = parent,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 40),
					ZIndex = 5
				})
				Create("TextLabel", {
					Parent = DropFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 15),
					Font = Theme.Font,
					Text = text,
					TextColor3 = Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local Box = Create("TextButton", {
					Parent = DropFrame,
					BackgroundColor3 = Theme.Section,
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 0, 0, 18),
					Text = "",
					AutoButtonColor = false
				})
				Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0, 4)})
				Create("UIStroke", {Parent = Box, Color = Theme.Border, Thickness = 1})
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
					TextColor3 = Theme.Text,
					TextSize = 9
				})
				local List = Create("ScrollingFrame", {
					Parent = Box,
					BackgroundColor3 = Theme.Section,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 1, 2),
					Size = UDim2.new(1, 0, 0, 0),
					Visible = false,
					ZIndex = 10,
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = Theme.MainColor
				})
				Create("UIStroke", {Parent = List, Color = Theme.Border, Thickness = 1})
				Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})
				local open = false
				for _, opt in ipairs(options) do
					local OptBtn = Create("TextButton", {
						Parent = List,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 20),
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
					local height = math.min(#options * 20, 100)
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
			Left = CreateItemFunctions(LeftColFrame),
			Right = CreateItemFunctions(RightColFrame)
		}
	end

	return WindowFunctions
end

return Library
