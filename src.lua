
local assets = {6183930112, 6071575925, 6071579801, 6073763717, 3570695787, 5941353943, 4155801252, 2454009026, 5553946656, 4155801252, 4918373417, 3570695787, 2592362371}
local cprovider = Game:GetService"ContentProvider"
for _, v in next, assets do
	cprovider:Preload("rbxassetid://" .. v)
end

repeat wait() until game:IsLoaded()


-- if you're just looking to get the library for whatever reason, just copy everything from below till you see LIBRARY END

	--LIBRARY START
	--Services
	getgenv().runService = game:GetService"RunService"
	getgenv().textService = game:GetService"TextService"
	getgenv().inputService = game:GetService"UserInputService"
	getgenv().tweenService = game:GetService"TweenService"

	if getgenv().library then
		getgenv().library:Unload()
	end

	local library = {design = getgenv().design == "vainless", tabs = {}, draggable = true, flags = {}, title = "Vainless.xyz", open = false, mousestate = inputService.MouseIconEnabled, popup = nil, instances = {}, connections = {}, options = {}, notifications = {}, tabSize = 0, theme = {}, foldername = "Vainless", fileext = ".vl"}
	getgenv().library = library

	--Locals
	local dragging, dragInput, dragStart, startPos, dragObject

	local blacklistedKeys = { --add or remove keys if you find the need to
		Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Escape
	}
	local whitelistedMouseinputs = { --add or remove mouse inputs if you find the need to
		Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3
	}

	--Functions
	library.round = function(num, bracket)
		if typeof(num) == "Vector2" then
			return Vector2.new(library.round(num.X), library.round(num.Y))
		elseif typeof(num) == "Vector3" then
			return Vector3.new(library.round(num.X), library.round(num.Y), library.round(num.Z))
		elseif typeof(num) == "Color3" then
			return library.round(num.r * 255), library.round(num.g * 255), library.round(num.b * 255)
		else
			return num - num % (bracket or 1);
		end
	end

	--From: https://devforum.roblox.com/t/how-to-create-a-simple-rainbow-effect-using-tweenService/221849/2
	local chromaColor
	spawn(function()
		while library and wait() do
			chromaColor = Color3.fromHSV(tick() % 6 / 6, 1, 1)
		end
	end)

	function library:Create(class, properties)
		properties = properties or {}
		if not class then return end
		local a = class == "Square" or class == "Line" or class == "Text" or class == "Quad" or class == "Circle" or class == "Triangle"
		local t = a and Drawing or Instance
		local inst = t.new(class)
		for property, value in next, properties do
			inst[property] = value
		end
		table.insert(self.instances, {object = inst, method = a})
		return inst
	end

	function library:AddConnection(connection, name, callback)
		callback = type(name) == "function" and name or callback
		connection = connection:connect(callback)
		if name ~= callback then
			self.connections[name] = connection
		else
			table.insert(self.connections, connection)
		end
		return connection
	end

	function library:Unload()
		inputService.MouseIconEnabled = self.mousestate
		for _, c in next, self.connections do
			c:Disconnect()
		end
		for _, i in next, self.instances do
			if i.method then
				pcall(function() i.object:Remove() end)
			else
				i.object:Destroy()
			end
		end
		for _, o in next, self.options do
			if o.type == "toggle" then
				coroutine.resume(coroutine.create(o.SetState, o))
			end
		end
		library = nil
		getgenv().library = nil
	end

	function library:LoadConfig(config)
		if table.find(self:GetConfigs(), config) then
			local Read, Config = pcall(function() return game:GetService"HttpService":JSONDecode(readfile(self.foldername .. "/" .. config .. self.fileext)) end)
			Config = Read and Config or {}
			for _, option in next, self.options do
				if option.hasInit then
					if option.type ~= "button" and option.flag and not option.skipflag then
						if option.type == "toggle" then
							spawn(function() option:SetState(Config[option.flag] == 1) end)
						elseif option.type == "color" then
							if Config[option.flag] then
								spawn(function() option:SetColor(Config[option.flag]) end)
								if option.trans then
									spawn(function() option:SetTrans(Config[option.flag .. " Transparency"]) end)
								end
							end
						elseif option.type == "bind" then
							spawn(function() option:SetKey(Config[option.flag]) end)
						else
							spawn(function() option:SetValue(Config[option.flag]) end)
						end
					end
				end
			end
		end
	end

	function library:SaveConfig(config)
		local Config = {}
		if table.find(self:GetConfigs(), config) then
			Config = game:GetService"HttpService":JSONDecode(readfile(self.foldername .. "/" .. config .. self.fileext))
		end
		for _, option in next, self.options do
			if option.type ~= "button" and option.flag and not option.skipflag then
				if option.type == "toggle" then
					Config[option.flag] = option.state and 1 or 0
				elseif option.type == "color" then
					Config[option.flag] = {option.color.r, option.color.g, option.color.b}
					if option.trans then
						Config[option.flag .. " Transparency"] = option.trans
					end
				elseif option.type == "bind" then
					if option.key ~= "none" then
						Config[option.flag] = option.key
					end
				elseif option.type == "list" then
					Config[option.flag] = option.value
				else
					Config[option.flag] = option.value
				end
			end
		end
		writefile(self.foldername .. "/" .. config .. self.fileext, game:GetService"HttpService":JSONEncode(Config))
	end

	function library:GetConfigs()
		if not isfolder(self.foldername) then
			makefolder(self.foldername)
			return {}
		end
		local files = {}
		local a = 0
		for i,v in next, listfiles(self.foldername) do
			if v:sub(#v - #self.fileext + 1, #v) == self.fileext then
				a = a + 1
				v = v:gsub(self.foldername .. "\\", "")
				v = v:gsub(self.fileext, "")
				table.insert(files, a, v)
			end
		end
		return files
	end

	library.createLabel = function(option, parent)
		option.main = library:Create("TextLabel", {
			LayoutOrder = option.position,
			Position = UDim2.new(0, 6, 0, 0),
			Size = UDim2.new(1, -12, 0, 24),
			BackgroundTransparency = 1,
			TextSize = 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Parent = parent
		})

		setmetatable(option, {__newindex = function(t, i, v)
			if i == "Text" then
				option.main.Text = tostring(v)
				option.main.Size = UDim2.new(1, -12, 0, textService:GetTextSize(option.main.Text, 15, Enum.Font.Code, Vector2.new(option.main.AbsoluteSize.X, 9e9)).Y + 6)
			end
		end})
		option.Text = option.text
	end

	library.createDivider = function(option, parent)
		option.main = library:Create("Frame", {
			LayoutOrder = option.position,
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Parent = parent
		})

		library:Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -24, 0, 1),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			BorderColor3 = Color3.new(),
			Parent = option.main
		})

		option.title = library:Create("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			TextColor3 =  Color3.new(1, 1, 1),
			TextSize = 15,
			Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = option.main
		})

		setmetatable(option, {__newindex = function(t, i, v)
			if i == "Text" then
				if v then
					option.title.Text = tostring(v)
					option.title.Size = UDim2.new(0, textService:GetTextSize(option.title.Text, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X + 12, 0, 20)
					option.main.Size = UDim2.new(1, 0, 0, 18)
				else
					option.title.Text = ""
					option.title.Size = UDim2.new()
					option.main.Size = UDim2.new(1, 0, 0, 6)
				end
			end
		end})
		option.Text = option.text
	end

	library.createToggle = function(option, parent)
		option.hasInit = true

		option.main = library:Create("Frame", {
			LayoutOrder = option.position,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Parent = parent
		})

		local tickbox
		local tickboxOverlay
		if option.style then
			tickbox = library:Create("ImageLabel", {
				Position = UDim2.new(0, 6, 0, 4),
				Size = UDim2.new(0, 12, 0, 12),
				BackgroundTransparency = 1,
				Image = "rbxassetid://3570695787",
				ImageColor3 = Color3.new(),
				Parent = option.main
			})

			library:Create("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -2, 1, -2),
				BackgroundTransparency = 1,
				Image = "rbxassetid://3570695787",
				ImageColor3 = Color3.fromRGB(60, 60, 60),
				Parent = tickbox
			})

			library:Create("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -6, 1, -6),
				BackgroundTransparency = 1,
				Image = "rbxassetid://3570695787",
				ImageColor3 = Color3.fromRGB(40, 40, 40),
				Parent = tickbox
			})

			tickboxOverlay = library:Create("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -6, 1, -6),
				BackgroundTransparency = 1,
				Image = "rbxassetid://3570695787",
				ImageColor3 = library.flags["Menu Accent Color"],
				Visible = option.state,
				Parent = tickbox
			})

			library:Create("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://5941353943",
				ImageTransparency = 0.6,
				Parent = tickbox
			})

			table.insert(library.theme, tickboxOverlay)
		else
			tickbox = library:Create("Frame", {
				Position = UDim2.new(0, 6, 0, 4),
				Size = UDim2.new(0, 12, 0, 12),
				BackgroundColor3 = library.flags["Menu Accent Color"],
				BorderColor3 = Color3.new(),
				Parent = option.main
			})

			tickboxOverlay = library:Create("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = option.state and 1 or 0,
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				BorderColor3 = Color3.new(),
				Image = "rbxassetid://4155801252",
				ImageTransparency = 0.6,
				ImageColor3 = Color3.new(),
				Parent = tickbox
			})

			library:Create("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://2592362371",
				ImageColor3 = Color3.fromRGB(60, 60, 60),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 62, 62),
				Parent = tickbox
			})

			library:Create("ImageLabel", {
				Size = UDim2.new(1, -2, 1, -2),
				Position = UDim2.new(0, 1, 0, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://2592362371",
				ImageColor3 = Color3.new(),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 62, 62),
				Parent = tickbox
			})

			table.insert(library.theme, tickbox)
		end

		option.interest = library:Create("Frame", {
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Parent = option.main
		})

		option.title = library:Create("TextLabel", {
			Position = UDim2.new(0, 24, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = option.text,
			TextColor3 =  option.state and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(180, 180, 180),
			TextSize = 15,
			Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = option.interest
		})

		option.interest.InputBegan:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				option:SetState(not option.state)
			end
			if input.UserInputType.Name == "MouseMovement" then
				if not library.warning and not library.slider then
					if option.style then
						tickbox.ImageColor3 = library.flags["Menu Accent Color"]
						--tweenService:Create(tickbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = library.flags["Menu Accent Color"]}):Play()
					else
						tickbox.BorderColor3 = library.flags["Menu Accent Color"]
						tickboxOverlay.BorderColor3 = library.flags["Menu Accent Color"]
						--tweenService:Create(tickbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = library.flags["Menu Accent Color"]}):Play()
						--tweenService:Create(tickboxOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = library.flags["Menu Accent Color"]}):Play()
					end
				end
				if option.tip then
					library.tooltip.Text = option.tip
					library.tooltip.Size = UDim2.new(0, textService:GetTextSize(option.tip, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 20)
				end
			end
		end)

		option.interest.InputChanged:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if option.tip then
					library.tooltip.Position = UDim2.new(0, input.Position.X + 26, 0, input.Position.Y + 36)
				end
			end
		end)

		option.interest.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if option.style then
					tickbox.ImageColor3 = Color3.new()
					--tweenService:Create(tickbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.new()}):Play()
				else
					tickbox.BorderColor3 = Color3.new()
					tickboxOverlay.BorderColor3 = Color3.new()
					--tweenService:Create(tickbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.new()}):Play()
					--tweenService:Create(tickboxOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.new()}):Play()
				end
				library.tooltip.Position = UDim2.new(2)
			end
		end)

		function option:SetState(state, nocallback)
			state = typeof(state) == "boolean" and state
			state = state or false
			library.flags[self.flag] = state
			self.state = state
			option.title.TextColor3 = state and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(160, 160, 160)
			if option.style then
				tickboxOverlay.Visible = state
			else
				tickboxOverlay.BackgroundTransparency = state and 1 or 0
			end
			if not nocallback then
				self.callback(state)
			end
		end

		if option.state ~= nil then
			delay(1, function()
				if library then
					option.callback(option.state)
				end
			end)
		end

		setmetatable(option, {__newindex = function(t, i, v)
			if i == "Text" then
				option.title.Text = tostring(v)
			end
		end})
	end

	library.createButton = function(option, parent)
		option.hasInit = true

		option.main = library:Create("Frame", {
			LayoutOrder = option.position,
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Parent = parent
		})

		option.title = library:Create("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -5),
			Size = UDim2.new(1, -12, 0, 20),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			BorderColor3 = Color3.new(),
			Text = option.text,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 15,
			Font = Enum.Font.Code,
			Parent = option.main
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.title
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.title
		})

		library:Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(253, 253, 253)),
			}),
			Rotation = -90,
			Parent = option.title
		})

		option.title.InputBegan:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				option.callback()
				if library then
					library.flags[option.flag] = true
				end
				if option.tip then
					library.tooltip.Text = option.tip
					library.tooltip.Size = UDim2.new(0, textService:GetTextSize(option.tip, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 20)
				end
			end
			if input.UserInputType.Name == "MouseMovement" then
				if not library.warning and not library.slider then
					option.title.BorderColor3 = library.flags["Menu Accent Color"]
				end
			end
		end)

		option.title.InputChanged:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if option.tip then
					library.tooltip.Position = UDim2.new(0, input.Position.X + 26, 0, input.Position.Y + 36)
				end
			end
		end)

		option.title.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				option.title.BorderColor3 = Color3.new()
				library.tooltip.Position = UDim2.new(2)
			end
		end)
	end

	library.createBind = function(option, parent)
		option.hasInit = true

		local binding
		local holding
		local Loop

		if option.sub then
			option.main = option:getMain()
		else
			option.main = option.main or library:Create("Frame", {
				LayoutOrder = option.position,
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Parent = parent
			})

			library:Create("TextLabel", {
				Position = UDim2.new(0, 6, 0, 0),
				Size = UDim2.new(1, -12, 1, 0),
				BackgroundTransparency = 1,
				Text = option.text,
				TextSize = 15,
				Font = Enum.Font.Code,
				TextColor3 = Color3.fromRGB(210, 210, 210),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = option.main
			})
		end

		local bindinput = library:Create(option.sub and "TextButton" or "TextLabel", {
			Position = UDim2.new(1, -6 - (option.subpos or 0), 0, option.sub and 2 or 3),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			TextSize = 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.fromRGB(160, 160, 160),
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = option.main
		})

		if option.sub then
			bindinput.AutoButtonColor = false
		end

		local interest = option.sub and bindinput or option.main
		local inContact
		interest.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				binding = true
				bindinput.Text = "[...]"
				bindinput.Size = UDim2.new(0, -textService:GetTextSize(bindinput.Text, 16, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 16)
				bindinput.TextColor3 = library.flags["Menu Accent Color"]
			end
		end)

		library:AddConnection(inputService.InputBegan, function(input)
			if inputService:GetFocusedTextBox() then return end
			if binding then
				local key = (table.find(whitelistedMouseinputs, input.UserInputType) and not option.nomouse) and input.UserInputType
				option:SetKey(key or (not table.find(blacklistedKeys, input.KeyCode)) and input.KeyCode)
			else
				if (input.KeyCode.Name == option.key or input.UserInputType.Name == option.key) and not binding then
					if option.mode == "toggle" then
						library.flags[option.flag] = not library.flags[option.flag]
						option.callback(library.flags[option.flag], 0)
					else
						library.flags[option.flag] = true
						if Loop then Loop:Disconnect() option.callback(true, 0) end
						Loop = library:AddConnection(runService.RenderStepped, function(step)
							if not inputService:GetFocusedTextBox() then
								option.callback(nil, step)
							end
						end)
					end
				end
			end
		end)

		library:AddConnection(inputService.InputEnded, function(input)
			if option.key ~= "none" then
				if input.KeyCode.Name == option.key or input.UserInputType.Name == option.key then
					if Loop then
						Loop:Disconnect()
						library.flags[option.flag] = false
						option.callback(true, 0)
					end
				end
			end
		end)

		function option:SetKey(key)
			binding = false
			bindinput.TextColor3 = Color3.fromRGB(160, 160, 160)
			if Loop then Loop:Disconnect() library.flags[option.flag] = false option.callback(true, 0) end
			self.key = (key and key.Name) or key or self.key
			if self.key == "Backspace" then
				self.key = "none"
				bindinput.Text = "[NONE]"
			else
				local a = self.key
				if self.key:match"Mouse" then
					a = self.key:gsub("Button", ""):gsub("Mouse", "M")
				elseif self.key:match"Shift" or self.key:match"Alt" or self.key:match"Control" then
					a = self.key:gsub("Left", "L"):gsub("Right", "R")
				end
				bindinput.Text = "[" .. a:gsub("Control", "CTRL"):upper() .. "]"
			end
			bindinput.Size = UDim2.new(0, -textService:GetTextSize(bindinput.Text, 16, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 16)
		end
		option:SetKey()
	end

	library.createSlider = function(option, parent)
		option.hasInit = true

		if option.sub then
			option.main = option:getMain()
			option.main.Size = UDim2.new(1, 0, 0, 42)
		else
			option.main = library:Create("Frame", {
				LayoutOrder = option.position,
				Size = UDim2.new(1, 0, 0, option.textpos and 24 or 40),
				BackgroundTransparency = 1,
				Parent = parent
			})
		end

		option.slider = library:Create("Frame", {
			Position = UDim2.new(0, 6, 0, (option.sub and 22 or option.textpos and 4 or 20)),
			Size = UDim2.new(1, -12, 0, 16),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			BorderColor3 = Color3.new(),
			Parent = option.main
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2454009026",
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.8,
			Parent = option.slider
		})

		option.fill = library:Create("Frame", {
			BackgroundColor3 = library.flags["Menu Accent Color"],
			BorderSizePixel = 0,
			Parent = option.slider
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.slider
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.slider
		})

		option.title = library:Create("TextBox", {
			Position = UDim2.new((option.sub or option.textpos) and 0.5 or 0, (option.sub or option.textpos) and 0 or 6, 0, 0),
			Size = UDim2.new(0, 0, 0, (option.sub or option.textpos) and 14 or 18),
			BackgroundTransparency = 1,
			Text = (option.text == "nil" and "" or option.text .. ": ") .. option.value .. option.suffix,
			TextSize = (option.sub or option.textpos) and 14 or 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.fromRGB(210, 210, 210),
			TextXAlignment = Enum.TextXAlignment[(option.sub or option.textpos) and "Center" or "Left"],
			Parent = (option.sub or option.textpos) and option.slider or option.main
		})
		table.insert(library.theme, option.fill)

		library:Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 115, 115)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
			}),
			Rotation = -90,
			Parent = option.fill
		})

		if option.min >= 0 then
			option.fill.Size = UDim2.new((option.value - option.min) / (option.max - option.min), 0, 1, 0)
		else
			option.fill.Position = UDim2.new((0 - option.min) / (option.max - option.min), 0, 0, 0)
			option.fill.Size = UDim2.new(option.value / (option.max - option.min), 0, 1, 0)
		end

		local manualInput
		option.title.Focused:connect(function()
			if not manualInput then
				option.title:ReleaseFocus()
				option.title.Text = (option.text == "nil" and "" or option.text .. ": ") .. option.value .. option.suffix
			end
		end)

		option.title.FocusLost:connect(function()
			option.slider.BorderColor3 = Color3.new()
			if manualInput then
				if tonumber(option.title.Text) then
					option:SetValue(tonumber(option.title.Text))
				else
					option.title.Text = (option.text == "nil" and "" or option.text .. ": ") .. option.value .. option.suffix
				end
			end
			manualInput = false
		end)

		local interest = (option.sub or option.textpos) and option.slider or option.main
		interest.InputBegan:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				if inputService:IsKeyDown(Enum.KeyCode.LeftControl) or inputService:IsKeyDown(Enum.KeyCode.RightControl) then
					manualInput = true
					option.title:CaptureFocus()
				else
					library.slider = option
					option.slider.BorderColor3 = library.flags["Menu Accent Color"]
					option:SetValue(option.min + ((input.Position.X - option.slider.AbsolutePosition.X) / option.slider.AbsoluteSize.X) * (option.max - option.min))
				end
			end
			if input.UserInputType.Name == "MouseMovement" then
				if not library.warning and not library.slider then
					option.slider.BorderColor3 = library.flags["Menu Accent Color"]
				end
				if option.tip then
					library.tooltip.Text = option.tip
					library.tooltip.Size = UDim2.new(0, textService:GetTextSize(option.tip, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 20)
				end
			end
		end)

		interest.InputChanged:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if option.tip then
					library.tooltip.Position = UDim2.new(0, input.Position.X + 26, 0, input.Position.Y + 36)
				end
			end
		end)

		interest.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				library.tooltip.Position = UDim2.new(2)
				if option ~= library.slider then
					option.slider.BorderColor3 = Color3.new()
					--option.fill.BorderColor3 = Color3.new()
				end
			end
		end)

		function option:SetValue(value, nocallback)
			if typeof(value) ~= "number" then value = 0 end
			value = library.round(value, option.float)
			value = math.clamp(value, self.min, self.max)
			if self.min >= 0 then
				option.fill:TweenSize(UDim2.new((value - self.min) / (self.max - self.min), 0, 1, 0), "Out", "Quad", 0.05, true)
			else
				option.fill:TweenPosition(UDim2.new((0 - self.min) / (self.max - self.min), 0, 0, 0), "Out", "Quad", 0.05, true)
				option.fill:TweenSize(UDim2.new(value / (self.max - self.min), 0, 1, 0), "Out", "Quad", 0.1, true)
			end
			library.flags[self.flag] = value
			self.value = value
			option.title.Text = (option.text == "nil" and "" or option.text .. ": ") .. option.value .. option.suffix
			if not nocallback then
				self.callback(value)
			end
		end
		delay(1, function()
			if library then
				option:SetValue(option.value)
			end
		end)
	end

	library.createList = function(option, parent)
		option.hasInit = true

		if option.sub then
			option.main = option:getMain()
			option.main.Size = UDim2.new(1, 0, 0, 48)
		else
			option.main = library:Create("Frame", {
				LayoutOrder = option.position,
				Size = UDim2.new(1, 0, 0, option.text == "nil" and 30 or 48),
				BackgroundTransparency = 1,
				Parent = parent
			})

			if option.text ~= "nil" then
				library:Create("TextLabel", {
					Position = UDim2.new(0, 6, 0, 0),
					Size = UDim2.new(1, -12, 0, 18),
					BackgroundTransparency = 1,
					Text = option.text,
					TextSize = 15,
					Font = Enum.Font.Code,
					TextColor3 = Color3.fromRGB(210, 210, 210),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = option.main
				})
			end
		end

		local function getMultiText()
			local s = ""
			for _, value in next, option.values do
				s = s .. (option.value[value] and (tostring(value) .. ", ") or "")
			end
			return string.sub(s, 1, #s - 2)
		end

		option.listvalue = library:Create("TextLabel", {
			Position = UDim2.new(0, 6, 0, (option.text == "nil" and not option.sub) and 4 or 22),
			Size = UDim2.new(1, -12, 0, 22),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			BorderColor3 = Color3.new(),
			Text = " " .. (typeof(option.value) == "string" and option.value or getMultiText()),
			TextSize = 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = option.main
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2454009026",
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.8,
			Parent = option.listvalue
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.listvalue
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.listvalue
		})

		option.arrow = library:Create("ImageLabel", {
			Position = UDim2.new(1, -16, 0, 7),
			Size = UDim2.new(0, 8, 0, 8),
			Rotation = 90,
			BackgroundTransparency = 1,
			Image = "rbxassetid://4918373417",
			ImageColor3 = Color3.new(1, 1, 1),
			ScaleType = Enum.ScaleType.Fit,
			ImageTransparency = 0.4,
			Parent = option.listvalue
		})

		option.holder = library:Create("TextButton", {
			ZIndex = 4,
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			BorderColor3 = Color3.new(),
			Text = "",
			AutoButtonColor = false,
			Visible = false,
			Parent = library.base
		})

		option.content = library:Create("ScrollingFrame", {
			ZIndex = 4,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarImageColor3 = Color3.new(),
			ScrollBarThickness = 3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			Parent = option.holder
		})

		library:Create("ImageLabel", {
			ZIndex = 4,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.holder
		})

		library:Create("ImageLabel", {
			ZIndex = 4,
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.holder
		})

		local layout = library:Create("UIListLayout", {
			Padding = UDim.new(0, 2),
			Parent = option.content
		})

		library:Create("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			Parent = option.content
		})

		local valueCount = 0
		layout.Changed:connect(function()
			option.holder.Size = UDim2.new(0, option.listvalue.AbsoluteSize.X, 0, 8 + (valueCount > option.max and (-2 + (option.max * 22)) or layout.AbsoluteContentSize.Y))
			option.content.CanvasSize = UDim2.new(0, 0, 0, 8 + layout.AbsoluteContentSize.Y)
		end)
		local interest = option.sub and option.listvalue or option.main

		option.listvalue.InputBegan:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				if library.popup == option then library.popup:Close() return end
				if library.popup then
					library.popup:Close()
				end
				option.arrow.Rotation = -90
				option.open = true
				option.holder.Visible = true
				local pos = option.main.AbsolutePosition
				option.holder.Position = UDim2.new(0, pos.X + 6, 0, pos.Y + ((option.text == "nil" and not option.sub) and 66 or 84))
				library.popup = option
				option.listvalue.BorderColor3 = library.flags["Menu Accent Color"]
			end
			if input.UserInputType.Name == "MouseMovement" then
				if not library.warning and not library.slider then
					option.listvalue.BorderColor3 = library.flags["Menu Accent Color"]
				end
			end
		end)

		option.listvalue.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if not option.open then
					option.listvalue.BorderColor3 = Color3.new()
				end
			end
		end)

		interest.InputBegan:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if option.tip then
					library.tooltip.Text = option.tip
					library.tooltip.Size = UDim2.new(0, textService:GetTextSize(option.tip, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 20)
				end
			end
		end)

		interest.InputChanged:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if option.tip then
					library.tooltip.Position = UDim2.new(0, input.Position.X + 26, 0, input.Position.Y + 36)
				end
			end
		end)

		interest.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				library.tooltip.Position = UDim2.new(2)
			end
		end)

		local selected
		function option:AddValue(value, state)
			if self.labels[value] then return end
			valueCount = valueCount + 1

			if self.multiselect then
				self.values[value] = state
			else
				if not table.find(self.values, value) then
					table.insert(self.values, value)
				end
			end

			local label = library:Create("TextLabel", {
				ZIndex = 4,
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = value,
				TextSize = 15,
				Font = Enum.Font.Code,
				TextTransparency = self.multiselect and (self.value[value] and 1 or 0) or self.value == value and 1 or 0,
				TextColor3 = Color3.fromRGB(210, 210, 210),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = option.content
			})
			self.labels[value] = label

			local labelOverlay = library:Create("TextLabel", {
				ZIndex = 4,	
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 0.8,
				Text = " " ..value,
				TextSize = 15,
				Font = Enum.Font.Code,
				TextColor3 = library.flags["Menu Accent Color"],
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = self.multiselect and self.value[value] or self.value == value,
				Parent = label
			})
			selected = selected or self.value == value and labelOverlay
			table.insert(library.theme, labelOverlay)

			label.InputBegan:connect(function(input)
				if input.UserInputType.Name == "MouseButton1" then
					if self.multiselect then
						self.value[value] = not self.value[value]
						self:SetValue(self.value)
					else
						self:SetValue(value)
						self:Close()
					end
				end
			end)
		end

		for i, value in next, option.values do
			option:AddValue(tostring(typeof(i) == "number" and value or i))
		end

		function option:RemoveValue(value)
			local label = self.labels[value]
			if label then
				label:Destroy()
				self.labels[value] = nil
				valueCount = valueCount - 1
				if self.multiselect then
					self.values[value] = nil
					self:SetValue(self.value)
				else
					table.remove(self.values, table.find(self.values, value))
					if self.value == value then
						selected = nil
						self:SetValue(self.values[1] or "")
					end
				end
			end
		end

		function option:SetValue(value, nocallback)
			if self.multiselect and typeof(value) ~= "table" then
				value = {}
				for i,v in next, self.values do
					value[v] = false
				end
			end
			self.value = typeof(value) == "table" and value or tostring(table.find(self.values, value) and value or self.values[1])
			library.flags[self.flag] = self.value
			option.listvalue.Text = " " .. (self.multiselect and getMultiText() or self.value)
			if self.multiselect then
				for name, label in next, self.labels do
					label.TextTransparency = self.value[name] and 1 or 0
					if label:FindFirstChild"TextLabel" then
						label.TextLabel.Visible = self.value[name]
					end
				end
			else
				if selected then
					selected.TextTransparency = 0
					if selected:FindFirstChild"TextLabel" then
						selected.TextLabel.Visible = false
					end
				end
				if self.labels[self.value] then
					selected = self.labels[self.value]
					selected.TextTransparency = 1
					if selected:FindFirstChild"TextLabel" then
						selected.TextLabel.Visible = true
					end
				end
			end
			if not nocallback then
				self.callback(self.value)
			end
		end
		delay(1, function()
			if library then
				option:SetValue(option.value)
			end
		end)

		function option:Close()
			library.popup = nil
			option.arrow.Rotation = 90
			self.open = false
			option.holder.Visible = false
			option.listvalue.BorderColor3 = Color3.new()
		end

		return option
	end

	library.createBox = function(option, parent)
		option.hasInit = true

		option.main = library:Create("Frame", {
			LayoutOrder = option.position,
			Size = UDim2.new(1, 0, 0, option.text == "nil" and 28 or 44),
			BackgroundTransparency = 1,
			Parent = parent
		})

		if option.text ~= "nil" then
			option.title = library:Create("TextLabel", {
				Position = UDim2.new(0, 6, 0, 0),
				Size = UDim2.new(1, -12, 0, 18),
				BackgroundTransparency = 1,
				Text = option.text,
				TextSize = 15,
				Font = Enum.Font.Code,
				TextColor3 = Color3.fromRGB(210, 210, 210),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = option.main
			})
		end

		option.holder = library:Create("Frame", {
			Position = UDim2.new(0, 6, 0, option.text == "nil" and 4 or 20),
			Size = UDim2.new(1, -12, 0, 20),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			BorderColor3 = Color3.new(),
			Parent = option.main
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2454009026",
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.8,
			Parent = option.holder
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.holder
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.holder
		})

		local inputvalue = library:Create("TextBox", {
			Position = UDim2.new(0, 4, 0, 0),
			Size = UDim2.new(1, -4, 1, 0),
			BackgroundTransparency = 1,
			Text = "  " .. option.value,
			TextSize = 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ClearTextOnFocus = false,
			Parent = option.holder
		})

		inputvalue.FocusLost:connect(function(enter)
			option.holder.BorderColor3 = Color3.new()
			option:SetValue(inputvalue.Text, enter)
		end)

		inputvalue.Focused:connect(function()
			option.holder.BorderColor3 = library.flags["Menu Accent Color"]
		end)

		inputvalue.InputBegan:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				inputvalue.Text = ""
			end
			if input.UserInputType.Name == "MouseMovement" then
				if not library.warning and not library.slider then
					option.holder.BorderColor3 = library.flags["Menu Accent Color"]
				end
				if option.tip then
					library.tooltip.Text = option.tip
					library.tooltip.Size = UDim2.new(0, textService:GetTextSize(option.tip, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 20)
				end
			end
		end)

		inputvalue.InputChanged:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if option.tip then
					library.tooltip.Position = UDim2.new(0, input.Position.X + 26, 0, input.Position.Y + 36)
				end
			end
		end)

		inputvalue.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if not inputvalue:IsFocused() then
					option.holder.BorderColor3 = Color3.new()
				end
				library.tooltip.Position = UDim2.new(2)
			end
		end)

		function option:SetValue(value, enter)
			if tostring(value) == "" then
				inputvalue.Text = self.value
			else
				library.flags[self.flag] = tostring(value)
				self.value = tostring(value)
				inputvalue.Text = self.value
				self.callback(value, enter)
			end
		end
		delay(1, function()
			if library then
				option:SetValue(option.value)
			end
		end)
	end

	library.createColorPickerWindow = function(option)
		option.mainHolder = library:Create("TextButton", {
			ZIndex = 4,
			--Position = UDim2.new(1, -184, 1, 6),
			Size = UDim2.new(0, option.trans and 200 or 184, 0, 264),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			BorderColor3 = Color3.new(),
			AutoButtonColor = false,
			Visible = false,
			Parent = library.base
		})

		option.rgbBox = library:Create("Frame", {
			Position = UDim2.new(0, 6, 0, 214),
			Size = UDim2.new(0, (option.mainHolder.AbsoluteSize.X - 12), 0, 20),
			BackgroundColor3 = Color3.fromRGB(57, 57, 57),
			BorderColor3 = Color3.new(),
			ZIndex = 5;
			Parent = option.mainHolder
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2454009026",
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.8,
			ZIndex = 6;
			Parent = option.rgbBox
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			ZIndex = 6;
			Parent = option.rgbBox
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			ZIndex = 6;
			Parent = option.rgbBox
		})

		option.rgbInput = library:Create("TextBox", {
			Position = UDim2.new(0, 4, 0, 0),
			Size = UDim2.new(1, -4, 1, 0),
			BackgroundTransparency = 1,
			Text = tostring(option.color),
			TextSize = 14,
			Font = Enum.Font.Code,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextWrapped = true,
			ClearTextOnFocus = false,
			ZIndex = 6;
			Parent = option.rgbBox
		})

		option.hexBox = option.rgbBox:Clone()
		option.hexBox.Position = UDim2.new(0, 6, 0, 238)
		-- option.hexBox.Size = UDim2.new(0, (option.mainHolder.AbsoluteSize.X/2 - 10), 0, 20)
		option.hexBox.Parent = option.mainHolder
		option.hexInput = option.hexBox.TextBox;

		library:Create("ImageLabel", {
			ZIndex = 4,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.mainHolder
		})

		library:Create("ImageLabel", {
			ZIndex = 4,
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.mainHolder
		})

		local hue, sat, val = Color3.toHSV(option.color)
		hue, sat, val = hue == 0 and 1 or hue, sat + 0.005, val - 0.005
		local editinghue
		local editingsatval
		local editingtrans

		local transMain
		if option.trans then
			transMain = library:Create("ImageLabel", {
				ZIndex = 5,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://2454009026",
				ImageColor3 = Color3.fromHSV(hue, 1, 1),
				Rotation = 180,
				Parent = library:Create("ImageLabel", {
					ZIndex = 4,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -6, 0, 6),
					Size = UDim2.new(0, 10, 1, -60),
					BorderColor3 = Color3.new(),
					Image = "rbxassetid://4632082392",
					ScaleType = Enum.ScaleType.Tile,
					TileSize = UDim2.new(0, 5, 0, 5),
					Parent = option.mainHolder
				})
			})

			option.transSlider = library:Create("Frame", {
				ZIndex = 5,
				Position = UDim2.new(0, 0, option.trans, 0),
				Size = UDim2.new(1, 0, 0, 2),
				BackgroundColor3 = Color3.fromRGB(38, 41, 65),
				BorderColor3 = Color3.fromRGB(255, 255, 255),
				Parent = transMain
			})

			transMain.InputBegan:connect(function(Input)
				if Input.UserInputType.Name == "MouseButton1" then
					editingtrans = true
					option:SetTrans(1 - ((Input.Position.Y - transMain.AbsolutePosition.Y) / transMain.AbsoluteSize.Y))
				end
			end)

			transMain.InputEnded:connect(function(Input)
				if Input.UserInputType.Name == "MouseButton1" then
					editingtrans = false
				end
			end)
		end

		local hueMain = library:Create("Frame", {
			ZIndex = 4,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 6, 1, -54),
			Size = UDim2.new(1, option.trans and -28 or -12, 0, 10),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(),
			Parent = option.mainHolder
		})

		local Gradient = library:Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
			}),
			Parent = hueMain
		})

		local hueSlider = library:Create("Frame", {
			ZIndex = 4,
			Position = UDim2.new(1 - hue, 0, 0, 0),
			Size = UDim2.new(0, 2, 1, 0),
			BackgroundColor3 = Color3.fromRGB(38, 41, 65),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			Parent = hueMain
		})

		hueMain.InputBegan:connect(function(Input)
			if Input.UserInputType.Name == "MouseButton1" then
				editinghue = true
				X = (hueMain.AbsolutePosition.X + hueMain.AbsoluteSize.X) - hueMain.AbsolutePosition.X
				X = math.clamp((Input.Position.X - hueMain.AbsolutePosition.X) / X, 0, 0.995)
				option:SetColor(Color3.fromHSV(1 - X, sat, val))
			end
		end)

		hueMain.InputEnded:connect(function(Input)
			if Input.UserInputType.Name == "MouseButton1" then
				editinghue = false
			end
		end)

		local satval = library:Create("ImageLabel", {
			ZIndex = 4,
			Position = UDim2.new(0, 6, 0, 6),
			Size = UDim2.new(1, option.trans and -28 or -12, 1, -74),
			BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
			BorderColor3 = Color3.new(),
			Image = "rbxassetid://4155801252",
			ClipsDescendants = true,
			Parent = option.mainHolder
		})

		local satvalSlider = library:Create("Frame", {
			ZIndex = 4,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(sat, 0, 1 - val, 0),
			Size = UDim2.new(0, 4, 0, 4),
			Rotation = 45,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = satval
		})

		satval.InputBegan:connect(function(Input)
			if Input.UserInputType.Name == "MouseButton1" then
				editingsatval = true
				X = (satval.AbsolutePosition.X + satval.AbsoluteSize.X) - satval.AbsolutePosition.X
				Y = (satval.AbsolutePosition.Y + satval.AbsoluteSize.Y) - satval.AbsolutePosition.Y
				X = math.clamp((Input.Position.X - satval.AbsolutePosition.X) / X, 0.005, 1)
				Y = math.clamp((Input.Position.Y - satval.AbsolutePosition.Y) / Y, 0, 0.995)
				option:SetColor(Color3.fromHSV(hue, X, 1 - Y))
			end
		end)

		library:AddConnection(inputService.InputChanged, function(Input)
			if Input.UserInputType.Name == "MouseMovement" then
				if editingsatval then
					X = (satval.AbsolutePosition.X + satval.AbsoluteSize.X) - satval.AbsolutePosition.X
					Y = (satval.AbsolutePosition.Y + satval.AbsoluteSize.Y) - satval.AbsolutePosition.Y
					X = math.clamp((Input.Position.X - satval.AbsolutePosition.X) / X, 0.005, 1)
					Y = math.clamp((Input.Position.Y - satval.AbsolutePosition.Y) / Y, 0, 0.995)
					option:SetColor(Color3.fromHSV(hue, X, 1 - Y))
				elseif editinghue then
					X = (hueMain.AbsolutePosition.X + hueMain.AbsoluteSize.X) - hueMain.AbsolutePosition.X
					X = math.clamp((Input.Position.X - hueMain.AbsolutePosition.X) / X, 0, 0.995)
					option:SetColor(Color3.fromHSV(1 - X, sat, val))
				elseif editingtrans then
					option:SetTrans(1 - ((Input.Position.Y - transMain.AbsolutePosition.Y) / transMain.AbsoluteSize.Y))
				end
			end
		end)

		satval.InputEnded:connect(function(Input)
			if Input.UserInputType.Name == "MouseButton1" then
				editingsatval = false
			end
		end)

		local r, g, b = library.round(option.color)
		option.hexInput.Text = string.format("#%02x%02x%02x", r, g, b)
		option.rgbInput.Text = table.concat({r, g, b}, ",")

		option.rgbInput.FocusLost:connect(function()
			local r, g, b = option.rgbInput.Text:gsub("%s+", ""):match("(%d+),(%d+),(%d+)")
			if r and g and b then
				local color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
				return option:SetColor(color)
			end

			local r, g, b = library.round(option.color)
			option.rgbInput.Text = table.concat({r, g, b}, ",")
		end)

		option.hexInput.FocusLost:connect(function()
			local r, g, b = option.hexInput.Text:match("#?(..)(..)(..)")
			if r and g and b then
				local color = Color3.fromRGB(tonumber("0x"..r), tonumber("0x"..g), tonumber("0x"..b))
				return option:SetColor(color)
			end

			local r, g, b = library.round(option.color)
			option.hexInput.Text = string.format("#%02x%02x%02x", r, g, b)
		end)

		function option:updateVisuals(Color)
			hue, sat, val = Color3.toHSV(Color)
			hue = hue == 0 and 1 or hue
			satval.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			if option.trans then
				transMain.ImageColor3 = Color3.fromHSV(hue, 1, 1)
			end
			hueSlider.Position = UDim2.new(1 - hue, 0, 0, 0)
			satvalSlider.Position = UDim2.new(sat, 0, 1 - val, 0)

			local r, g, b = library.round(Color3.fromHSV(hue, sat, val))

			option.hexInput.Text = string.format("#%02x%02x%02x", r, g, b)
			option.rgbInput.Text = table.concat({r, g, b}, ",")
		end

		return option
	end

	library.createColor = function(option, parent)
		option.hasInit = true

		if option.sub then
			option.main = option:getMain()
		else
			option.main = library:Create("Frame", {
				LayoutOrder = option.position,
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Parent = parent
			})

			option.title = library:Create("TextLabel", {
				Position = UDim2.new(0, 6, 0, 0),
				Size = UDim2.new(1, -12, 1, 0),
				BackgroundTransparency = 1,
				Text = option.text,
				TextSize = 15,
				Font = Enum.Font.Code,
				TextColor3 = Color3.fromRGB(210, 210, 210),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = option.main
			})
		end

		option.visualize = library:Create(option.sub and "TextButton" or "Frame", {
			Position = UDim2.new(1, -(option.subpos or 0) - 24, 0, 4),
			Size = UDim2.new(0, 18, 0, 12),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundColor3 = option.color,
			BorderColor3 = Color3.new(),
			Parent = option.main
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2454009026",
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.6,
			Parent = option.visualize
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.visualize
		})

		library:Create("ImageLabel", {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = option.visualize
		})

		local interest = option.sub and option.visualize or option.main

		if option.sub then
			option.visualize.Text = ""
			option.visualize.AutoButtonColor = false
		end

		interest.InputBegan:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				if not option.mainHolder then library.createColorPickerWindow(option) end
				if library.popup == option then library.popup:Close() return end
				if library.popup then library.popup:Close() end
				option.open = true
				local pos = option.main.AbsolutePosition
				option.mainHolder.Position = UDim2.new(0, pos.X + 36 + (option.trans and -16 or 0), 0, pos.Y + 56)
				option.mainHolder.Visible = true
				library.popup = option
				option.visualize.BorderColor3 = library.flags["Menu Accent Color"]
			end
			if input.UserInputType.Name == "MouseMovement" then
				if not library.warning and not library.slider then
					option.visualize.BorderColor3 = library.flags["Menu Accent Color"]
				end
				if option.tip then
					library.tooltip.Text = option.tip
					library.tooltip.Size = UDim2.new(0, textService:GetTextSize(option.tip, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X, 0, 20)
				end
			end
		end)

		interest.InputChanged:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if option.tip then
					library.tooltip.Position = UDim2.new(0, input.Position.X + 26, 0, input.Position.Y + 36)
				end
			end
		end)

		interest.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseMovement" then
				if not option.open then
					option.visualize.BorderColor3 = Color3.new()
				end
				library.tooltip.Position = UDim2.new(2)
			end
		end)

		function option:SetColor(newColor, nocallback)
			if typeof(newColor) == "table" then
				newColor = Color3.new(newColor[1], newColor[2], newColor[3])
			end
			newColor = newColor or Color3.new(1, 1, 1)
			if self.mainHolder then
				self:updateVisuals(newColor)
			end
			option.visualize.BackgroundColor3 = newColor
			library.flags[self.flag] = newColor
			self.color = newColor
			if not nocallback then
				self.callback(newColor)
			end
		end

		if option.trans then
			function option:SetTrans(value, manual)
				value = math.clamp(tonumber(value) or 0, 0, 1)
				if self.transSlider then
					self.transSlider.Position = UDim2.new(0, 0, value, 0)
				end
				self.trans = value
				library.flags[self.flag .. " Transparency"] = 1 - value
				self.calltrans(value)
			end
			option:SetTrans(option.trans)
		end

		delay(1, function()
			if library then
				option:SetColor(option.color)
			end
		end)

		function option:Close()
			library.popup = nil
			self.open = false
			self.mainHolder.Visible = false
			option.visualize.BorderColor3 = Color3.new()
		end
	end

	function library:AddTab(title, pos)
		local tab = {canInit = true, tabs = {}, columns = {}, title = tostring(title)}
		table.insert(self.tabs, pos or #self.tabs + 1, tab)

		function tab:AddColumn()
			local column = {sections = {}, position = #self.columns, canInit = true, tab = self}
			table.insert(self.columns, column)

			function column:AddSection(title)
				local section = {title = tostring(title), options = {}, canInit = true, column = self}
				table.insert(self.sections, section)

				function section:AddLabel(text)
					local option = {text = text}
					option.section = self
					option.type = "label"
					option.position = #self.options
					option.canInit = true
					table.insert(self.options, option)

					if library.hasInit and self.hasInit then
						library.createLabel(option, self.content)
					else
						option.Init = library.createLabel
					end

					return option
				end

				function section:AddDivider(text)
					local option = {text = text}
					option.section = self
					option.type = "divider"
					option.position = #self.options
					option.canInit = true
					table.insert(self.options, option)

					if library.hasInit and self.hasInit then
						library.createDivider(option, self.content)
					else
						option.Init = library.createDivider
					end

					return option
				end

				function section:AddToggle(option)
					option = typeof(option) == "table" and option or {}
					option.section = self
					option.text = tostring(option.text)
					option.state = option.state == nil and nil or (typeof(option.state) == "boolean" and option.state or false)
					option.callback = typeof(option.callback) == "function" and option.callback or function() end
					option.type = "toggle"
					option.position = #self.options
					option.flag = (library.flagprefix and library.flagprefix .. " " or "") .. (option.flag or option.text)
					option.subcount = 0
					option.canInit = (option.canInit ~= nil and option.canInit) or true
					option.tip = option.tip and tostring(option.tip)
					option.style = option.style == 2
					library.flags[option.flag] = option.state
					table.insert(self.options, option)
					library.options[option.flag] = option

					function option:AddColor(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddColor(subOption)
					end

					function option:AddBind(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddBind(subOption)
					end

					function option:AddList(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddList(subOption)
					end

					function option:AddSlider(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddSlider(subOption)
					end

					if library.hasInit and self.hasInit then
						library.createToggle(option, self.content)
					else
						option.Init = library.createToggle
					end

					return option
				end

				function section:AddButton(option)
					option = typeof(option) == "table" and option or {}
					option.section = self
					option.text = tostring(option.text)
					option.callback = typeof(option.callback) == "function" and option.callback or function() end
					option.type = "button"
					option.position = #self.options
					option.flag = (library.flagprefix and library.flagprefix .. " " or "") .. (option.flag or option.text)
					option.subcount = 0
					option.canInit = (option.canInit ~= nil and option.canInit) or true
					option.tip = option.tip and tostring(option.tip)
					table.insert(self.options, option)
					library.options[option.flag] = option

					function option:AddBind(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() option.main.Size = UDim2.new(1, 0, 0, 40) return option.main end
						self.subcount = self.subcount + 1
						return section:AddBind(subOption)
					end

					function option:AddColor(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() option.main.Size = UDim2.new(1, 0, 0, 40) return option.main end
						self.subcount = self.subcount + 1
						return section:AddColor(subOption)
					end

					if library.hasInit and self.hasInit then
						library.createButton(option, self.content)
					else
						option.Init = library.createButton
					end

					return option
				end

				function section:AddBind(option)
					option = typeof(option) == "table" and option or {}
					option.section = self
					option.text = tostring(option.text)
					option.key = (option.key and option.key.Name) or option.key or "none"
					option.nomouse = typeof(option.nomouse) == "boolean" and option.nomouse or false
					option.mode = typeof(option.mode) == "string" and (option.mode == "toggle" or option.mode == "hold" and option.mode) or "toggle"
					option.callback = typeof(option.callback) == "function" and option.callback or function() end
					option.type = "bind"
					option.position = #self.options
					option.flag = (library.flagprefix and library.flagprefix .. " " or "") .. (option.flag or option.text)
					option.canInit = (option.canInit ~= nil and option.canInit) or true
					option.tip = option.tip and tostring(option.tip)
					table.insert(self.options, option)
					library.options[option.flag] = option

					if library.hasInit and self.hasInit then
						library.createBind(option, self.content)
					else
						option.Init = library.createBind
					end

					return option
				end

				function section:AddSlider(option)
					option = typeof(option) == "table" and option or {}
					option.section = self
					option.text = tostring(option.text)
					option.min = typeof(option.min) == "number" and option.min or 0
					option.max = typeof(option.max) == "number" and option.max or 0
					option.value = option.min < 0 and 0 or math.clamp(typeof(option.value) == "number" and option.value or option.min, option.min, option.max)
					option.callback = typeof(option.callback) == "function" and option.callback or function() end
					option.float = typeof(option.value) == "number" and option.float or 1
					option.suffix = option.suffix and tostring(option.suffix) or ""
					option.textpos = option.textpos == 2
					option.type = "slider"
					option.position = #self.options
					option.flag = (library.flagprefix and library.flagprefix .. " " or "") .. (option.flag or option.text)
					option.subcount = 0
					option.canInit = (option.canInit ~= nil and option.canInit) or true
					option.tip = option.tip and tostring(option.tip)
					library.flags[option.flag] = option.value
					table.insert(self.options, option)
					library.options[option.flag] = option

					function option:AddColor(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddColor(subOption)
					end

					function option:AddBind(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddBind(subOption)
					end

					if library.hasInit and self.hasInit then
						library.createSlider(option, self.content)
					else
						option.Init = library.createSlider
					end

					return option
				end

				function section:AddList(option)
					option = typeof(option) == "table" and option or {}
					option.section = self
					option.text = tostring(option.text)
					option.values = typeof(option.values) == "table" and option.values or {}
					option.callback = typeof(option.callback) == "function" and option.callback or function() end
					option.multiselect = typeof(option.multiselect) == "boolean" and option.multiselect or false
					--option.groupbox = (not option.multiselect) and (typeof(option.groupbox) == "boolean" and option.groupbox or false)
					option.value = option.multiselect and (typeof(option.value) == "table" and option.value or {}) or tostring(option.value or option.values[1] or "")
					if option.multiselect then
						for i,v in next, option.values do
							option.value[v] = false
						end
					end
					option.max = option.max or 4
					option.open = false
					option.type = "list"
					option.position = #self.options
					option.labels = {}
					option.flag = (library.flagprefix and library.flagprefix .. " " or "") .. (option.flag or option.text)
					option.subcount = 0
					option.canInit = (option.canInit ~= nil and option.canInit) or true
					option.tip = option.tip and tostring(option.tip)
					library.flags[option.flag] = option.value
					table.insert(self.options, option)
					library.options[option.flag] = option

					function option:AddValue(value, state)
						if self.multiselect then
							self.values[value] = state
						else
							table.insert(self.values, value)
						end
					end

					function option:AddColor(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddColor(subOption)
					end

					function option:AddBind(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddBind(subOption)
					end

					if library.hasInit and self.hasInit then
						library.createList(option, self.content)
					else
						option.Init = library.createList
					end

					return option
				end

				function section:AddBox(option)
					option = typeof(option) == "table" and option or {}
					option.section = self
					option.text = tostring(option.text)
					option.value = tostring(option.value or "")
					option.callback = typeof(option.callback) == "function" and option.callback or function() end
					option.type = "box"
					option.position = #self.options
					option.flag = (library.flagprefix and library.flagprefix .. " " or "") .. (option.flag or option.text)
					option.canInit = (option.canInit ~= nil and option.canInit) or true
					option.tip = option.tip and tostring(option.tip)
					library.flags[option.flag] = option.value
					table.insert(self.options, option)
					library.options[option.flag] = option

					if library.hasInit and self.hasInit then
						library.createBox(option, self.content)
					else
						option.Init = library.createBox
					end

					return option
				end

				function section:AddColor(option)
					option = typeof(option) == "table" and option or {}
					option.section = self
					option.text = tostring(option.text)
					option.color = typeof(option.color) == "table" and Color3.new(option.color[1], option.color[2], option.color[3]) or option.color or Color3.new(1, 1, 1)
					option.callback = typeof(option.callback) == "function" and option.callback or function() end
					option.calltrans = typeof(option.calltrans) == "function" and option.calltrans or (option.calltrans == 1 and option.callback) or function() end
					option.open = false
					option.trans = tonumber(option.trans)
					option.subcount = 1
					option.type = "color"
					option.position = #self.options
					option.flag = (library.flagprefix and library.flagprefix .. " " or "") .. (option.flag or option.text)
					option.canInit = (option.canInit ~= nil and option.canInit) or true
					option.tip = option.tip and tostring(option.tip)
					library.flags[option.flag] = option.color
					table.insert(self.options, option)
					library.options[option.flag] = option

					function option:AddColor(subOption)
						subOption = typeof(subOption) == "table" and subOption or {}
						subOption.sub = true
						subOption.subpos = self.subcount * 24
						function subOption:getMain() return option.main end
						self.subcount = self.subcount + 1
						return section:AddColor(subOption)
					end

					if option.trans then
						library.flags[option.flag .. " Transparency"] = option.trans
					end

					if library.hasInit and self.hasInit then
						library.createColor(option, self.content)
					else
						option.Init = library.createColor
					end

					return option
				end

				function section:SetTitle(newTitle)
					self.title = tostring(newTitle)
					if self.titleText then
						self.titleText.Text = tostring(newTitle)
					end
				end

				function section:Init()
					if self.hasInit then return end
					self.hasInit = true

					self.main = library:Create("Frame", {
						BackgroundColor3 = Color3.fromRGB(30, 30, 30),
						BorderColor3 = Color3.new(),
						Parent = column.main
					})

					self.content = library:Create("Frame", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(30, 30, 30),
						BorderColor3 = Color3.fromRGB(60, 60, 60),
						BorderMode = Enum.BorderMode.Inset,
						Parent = self.main
					})

					library:Create("ImageLabel", {
						Size = UDim2.new(1, -2, 1, -2),
						Position = UDim2.new(0, 1, 0, 1),
						BackgroundTransparency = 1,
						Image = "rbxassetid://2592362371",
						ImageColor3 = Color3.new(),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 62, 62),
						Parent = self.main
					})

					table.insert(library.theme, library:Create("Frame", {
						Size = UDim2.new(1, 0, 0, 1),
						BackgroundColor3 = library.flags["Menu Accent Color"],
						BorderSizePixel = 0,
						BorderMode = Enum.BorderMode.Inset,
						Parent = self.main
					}))

					local layout = library:Create("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 2),
						Parent = self.content
					})

					library:Create("UIPadding", {
						PaddingTop = UDim.new(0, 12),
						Parent = self.content
					})

					self.titleText = library:Create("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 12, 0, 0),
						Size = UDim2.new(0, textService:GetTextSize(self.title, 15, Enum.Font.Code, Vector2.new(9e9, 9e9)).X + 10, 0, 3),
						BackgroundColor3 = Color3.fromRGB(30, 30, 30),
						BorderSizePixel = 0,
						Text = self.title,
						TextSize = 15,
						Font = Enum.Font.Code,
						TextColor3 = Color3.new(1, 1, 1),
						Parent = self.main
					})

					layout.Changed:connect(function()
						self.main.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 16)
					end)

					for _, option in next, self.options do
						if option.canInit then
							option.Init(option, self.content)
						end
					end
				end

				if library.hasInit and self.hasInit then
					section:Init()
				end

				return section
			end

			function column:Init()
				if self.hasInit then return end
				self.hasInit = true

				self.main = library:Create("ScrollingFrame", {
					ZIndex = 2,
					Position = UDim2.new(0, 6 + (self.position * 239), 0, 2),
					Size = UDim2.new(0, 233, 1, -4),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarImageColor3 = Color3.fromRGB(),
					ScrollBarThickness = 4,	
					VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					Visible = false,
					Parent = library.columnHolder
				})

				local layout = library:Create("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 12),
					Parent = self.main
				})

				library:Create("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					Parent = self.main
				})

				layout.Changed:connect(function()
					self.main.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
				end)

				for _, section in next, self.sections do
					if section.canInit and #section.options > 0 then
						section:Init()
					end
				end
			end

			if library.hasInit and self.hasInit then
				column:Init()
			end

			return column
		end

		function tab:Init()
			if self.hasInit then return end
			self.hasInit = true
			local size = textService:GetTextSize(self.title, 18, Enum.Font.Code, Vector2.new(9e9, 9e9)).X + 10

			self.button = library:Create("TextLabel", {
				Position = UDim2.new(0, library.tabSize, 0, 22),
				Size = UDim2.new(0, size, 0, 30),
				BackgroundTransparency = 1,
				Text = self.title,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 15,
				Font = Enum.Font.Code,
				TextWrapped = true,
				ClipsDescendants = true,
				Parent = library.main
			})
			library.tabSize = library.tabSize + size

			self.button.InputBegan:connect(function(input)
				if input.UserInputType.Name == "MouseButton1" then
					library:selectTab(self)
				end
			end)

			for _, column in next, self.columns do
				if column.canInit then
					column:Init()
				end
			end
		end

		if self.hasInit then
			tab:Init()
		end

		return tab
	end

	function library:AddWarning(warning)
		warning = typeof(warning) == "table" and warning or {}
		warning.text = tostring(warning.text) 
		warning.type = warning.type == "confirm" and "confirm" or ""

		local answer
		function warning:Show()
			library.warning = warning
			if warning.main and warning.type == "" then return end
			if library.popup then library.popup:Close() end
			if not warning.main then
				warning.main = library:Create("TextButton", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 0.6,
					BackgroundColor3 = Color3.new(),
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					Parent = library.main
				})

				warning.message = library:Create("TextLabel", {
					ZIndex = 2,
					Position = UDim2.new(0, 20, 0.5, -60),
					Size = UDim2.new(1, -40, 0, 40),
					BackgroundTransparency = 1,
					TextSize = 16,
					Font = Enum.Font.Code,
					TextColor3 = Color3.new(1, 1, 1),
					TextWrapped = true,
					RichText = true,
					Parent = warning.main
				})

				if warning.type == "confirm" then
					local button = library:Create("TextLabel", {
						ZIndex = 2,
						Position = UDim2.new(0.5, -105, 0.5, -10),
						Size = UDim2.new(0, 100, 0, 20),
						BackgroundColor3 = Color3.fromRGB(40, 40, 40),
						BorderColor3 = Color3.new(),
						Text = "Yes",
						TextSize = 16,
						Font = Enum.Font.Code,
						TextColor3 = Color3.new(1, 1, 1),
						Parent = warning.main
					})

					library:Create("ImageLabel", {
						ZIndex = 2,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://2454009026",
						ImageColor3 = Color3.new(),
						ImageTransparency = 0.8,
						Parent = button
					})

					library:Create("ImageLabel", {
						ZIndex = 2,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://2592362371",
						ImageColor3 = Color3.fromRGB(60, 60, 60),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 62, 62),
						Parent = button
					})

					local button1 = library:Create("TextLabel", {
						ZIndex = 2,
						Position = UDim2.new(0.5, 5, 0.5, -10),
						Size = UDim2.new(0, 100, 0, 20),
						BackgroundColor3 = Color3.fromRGB(40, 40, 40),
						BorderColor3 = Color3.new(),
						Text = "No",
						TextSize = 16,
						Font = Enum.Font.Code,
						TextColor3 = Color3.new(1, 1, 1),
						Parent = warning.main
					})

					library:Create("ImageLabel", {
						ZIndex = 2,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://2454009026",
						ImageColor3 = Color3.new(),
						ImageTransparency = 0.8,
						Parent = button1
					})

					library:Create("ImageLabel", {
						ZIndex = 2,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://2592362371",
						ImageColor3 = Color3.fromRGB(60, 60, 60),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 62, 62),
						Parent = button1
					})

					button.InputBegan:connect(function(input)
						if input.UserInputType.Name == "MouseButton1" then
							answer = true
						end
					end)

					button1.InputBegan:connect(function(input)
						if input.UserInputType.Name == "MouseButton1" then
							answer = false
						end
					end)
				else
					local button = library:Create("TextLabel", {
						ZIndex = 2,
						Position = UDim2.new(0.5, -50, 0.5, -10),
						Size = UDim2.new(0, 100, 0, 20),
						BackgroundColor3 = Color3.fromRGB(30, 30, 30),
						BorderColor3 = Color3.new(),
						Text = "OK",
						TextSize = 16,
						Font = Enum.Font.Code,
						TextColor3 = Color3.new(1, 1, 1),
						Parent = warning.main
					})

					library:Create("ImageLabel", {
						ZIndex = 2,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://2454009026",
						ImageColor3 = Color3.new(),
						ImageTransparency = 0.8,
						Parent = button
					})

					library:Create("ImageLabel", {
						ZIndex = 2,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, -2, 1, -2),
						BackgroundTransparency = 1,
						Image = "rbxassetid://3570695787",
						ImageColor3 = Color3.fromRGB(50, 50, 50),
						Parent = button
					})

					button.InputBegan:connect(function(input)
						if input.UserInputType.Name == "MouseButton1" then
							answer = true
						end
					end)
				end
			end
			warning.main.Visible = true
			warning.message.Text = warning.text

			repeat wait()
			until answer ~= nil
			spawn(warning.Close)
			library.warning = nil
			return answer
		end

		function warning:Close()
			answer = nil
			if not warning.main then return end
			warning.main.Visible = false
		end

		return warning
	end

	function library:Close()
		self.open = not self.open
		if self.open then
			inputService.MouseIconEnabled = false
		else
			inputService.MouseIconEnabled = self.mousestate
		end
		if self.main then
			if self.popup then
				self.popup:Close()
			end
			self.main.Visible = self.open
			self.cursor.Visible  = self.open
			self.cursor1.Visible  = self.open
		end
	end

	function library:Init()
		if self.hasInit then return end
		self.hasInit = true

		self.base = library:Create("ScreenGui", {IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Global})
		if runService:IsStudio() then
			self.base.Parent = script.Parent.Parent
		elseif syn then
			pcall(function() syn.protect_gui(self.base) end)
			self.base.Parent = game:GetService"CoreGui"
		end

		self.main = self:Create("ImageButton", {
			AutoButtonColor = false,
			Position = UDim2.new(0, 100, 0, 46),
			Size = UDim2.new(0, 500, 0, 600),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Tile,
			Modal = true,
			Visible = false,
			Parent = self.base
		})

		self.top = self:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.new(),
			Parent = self.main
		})

		self:Create("TextLabel", {
			Position = UDim2.new(0, 6, 0, -1),
			Size = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = tostring(self.title),
			Font = Enum.Font.Code,
			TextSize = 18,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.main
		})

		table.insert(library.theme, self:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0, 24),
			BackgroundColor3 = library.flags["Menu Accent Color"],
			BorderSizePixel = 0,
			Parent = self.main
		}))

		library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2454009026",
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.4,
			Parent = top
		})

		self.tabHighlight = self:Create("Frame", {
			BackgroundColor3 = library.flags["Menu Accent Color"],
			BorderSizePixel = 0,
			Parent = self.main
		})
		table.insert(library.theme, self.tabHighlight)

		self.columnHolder = self:Create("Frame", {
			Position = UDim2.new(0, 5, 0, 55),
			Size = UDim2.new(1, -10, 1, -60),
			BackgroundTransparency = 1,
			Parent = self.main
		})

		self.cursor = self:Create("Triangle", {
			Color = Color3.fromRGB(180, 180, 180),
			Transparency = 0.6,
		})
		self.cursor1 = self:Create("Triangle", {
			Color = Color3.fromRGB(240, 240, 240),
			Transparency = 0.6,
		})

		self.tooltip = self:Create("TextLabel", {
			ZIndex = 2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextSize = 15,
			Font = Enum.Font.Code,
			TextColor3 = Color3.new(1, 1, 1),
			Visible = true,
			Parent = self.base
		})

		self:Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 10, 1, 0),
			Style = Enum.FrameStyle.RobloxRound,
			Parent = self.tooltip
		})

		self:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.fromRGB(60, 60, 60),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = self.main
		})

		self:Create("ImageLabel", {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.new(0, 1, 0, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2592362371",
			ImageColor3 = Color3.new(),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 62, 62),
			Parent = self.main
		})

		self.top.InputBegan:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				dragObject = self.main
				dragging = true
				dragStart = input.Position
				startPos = dragObject.Position
				if library.popup then library.popup:Close() end
			end
		end)
		self.top.InputChanged:connect(function(input)
			if dragging and input.UserInputType.Name == "MouseMovement" then
				dragInput = input
			end
		end)
		self.top.InputEnded:connect(function(input)
			if input.UserInputType.Name == "MouseButton1" then
				dragging = false
			end
		end)

		function self:selectTab(tab)
			if self.currentTab == tab then return end
			if library.popup then library.popup:Close() end
			if self.currentTab then
				self.currentTab.button.TextColor3 = Color3.fromRGB(255, 255, 255)
				for _, column in next, self.currentTab.columns do
					column.main.Visible = false
				end
			end
			self.main.Size = UDim2.new(0, 16 + ((#tab.columns < 2 and 2 or #tab.columns) * 239), 0, 600)
			self.currentTab = tab
			tab.button.TextColor3 = library.flags["Menu Accent Color"]
			self.tabHighlight:TweenPosition(UDim2.new(0, tab.button.Position.X.Offset, 0, 50), "Out", "Quad", 0.2, true)
			self.tabHighlight:TweenSize(UDim2.new(0, tab.button.AbsoluteSize.X, 0, -1), "Out", "Quad", 0.1, true)
			for _, column in next, tab.columns do
				column.main.Visible = true
			end
		end

		spawn(function()
			while library do
				wait(1)
				local Configs = self:GetConfigs()
				for _, config in next, Configs do
					if not table.find(self.options["Config List"].values, config) then
						self.options["Config List"]:AddValue(config)
					end
				end
				for _, config in next, self.options["Config List"].values do
					if not table.find(Configs, config) then
						self.options["Config List"]:RemoveValue(config)
					end
				end
			end
		end)

		for _, tab in next, self.tabs do
			if tab.canInit then
				tab:Init()
				self:selectTab(tab)
			end
		end

		self:AddConnection(inputService.InputEnded, function(input)
			if input.UserInputType.Name == "MouseButton1" and self.slider then
				self.slider.slider.BorderColor3 = Color3.new()
				self.slider = nil
			end
		end)

		self:AddConnection(inputService.InputChanged, function(input)
			if not self.open then return end
			
			if input.UserInputType.Name == "MouseMovement" then
				if self.cursor then
					local mouse = inputService:GetMouseLocation()
					local MousePos = Vector2.new(mouse.X, mouse.Y)
					self.cursor.PointA = MousePos
					self.cursor.PointB = MousePos + Vector2.new(12, 12)
					self.cursor.PointC = MousePos + Vector2.new(12, 12)
					self.cursor1.PointA = MousePos
					self.cursor1.PointB = MousePos + Vector2.new(11, 11)
					self.cursor1.PointC = MousePos + Vector2.new(11, 11)
				end
				if self.slider then
					self.slider:SetValue(self.slider.min + ((input.Position.X - self.slider.slider.AbsolutePosition.X) / self.slider.slider.AbsoluteSize.X) * (self.slider.max - self.slider.min))
				end
			end
			if input == dragInput and dragging and library.draggable then
				local delta = input.Position - dragStart
				local yPos = (startPos.Y.Offset + delta.Y) < -36 and -36 or startPos.Y.Offset + delta.Y
				dragObject:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos), "Out", "Quint", 0.1, true)
			end
		end)

		local Old_index
		Old_index = hookmetamethod(game, "__index", function(t, i)
			if checkcaller() then return Old_index(t, i) end

			if library and i == "MouseIconEnabled" then
				return library.mousestate
			end

			return Old_index(t, i)
		end)

		local Old_new
		Old_new = hookmetamethod(game, "__newindex", function(t, i, v)
			if checkcaller() then return Old_new(t, i, v) end

			if library and i == "MouseIconEnabled" then
				library.mousestate = v
				if library.open then return end
			end

			return Old_new(t, i, v)
		end)

		if not getgenv().silent then
			delay(1, function() self:Close() end)
		end
	end

	library.configTab = library:AddTab("Settings", 100)
	library.SettingsColumn = library.configTab:AddColumn()
	library.SettingsColumn1 = library.configTab:AddColumn()

	library.SettingsMain = library.SettingsColumn:AddSection"Main"
	library.SettingsMain:AddButton({text = "Unload Cheat", nomouse = true, callback = function()
		library:Unload()
		getgenv().vainless = nil
	end})
	library.SettingsMain:AddBind({text = "Panic Key", callback = library.options["Unload Cheat"].callback})

	library.SettingsMenu = library.SettingsColumn:AddSection"Menu"
	library.SettingsMenu:AddBind({text = "Open / Close", flag = "UI Toggle", nomouse = true, key = "Insert", callback = function() library:Close() end})
	library.SettingsMenu:AddColor({text = "Accent Color", flag = "Menu Accent Color", color = Color3.fromRGB(255,255,255), callback = function(Color)
		if library.currentTab then
			library.currentTab.button.TextColor3 = Color
		end
		for _, obj in next, library.theme do
			obj[(obj.ClassName == "TextLabel" and "TextColor3") or (obj.ClassName == "ImageLabel" and "ImageColor3") or "BackgroundColor3"] = Color
		end
	end})
	local Backgrounds = {
		["Floral"] = 5553946656,
		["Flowers"] = 6071575925,
		["Circles"] = 6071579801,
		["Hearts"] = 6073763717,
		["Polka dots"] = 6214418014,
		["Mountains"] = 6214412460,
		["Zigzag"] = 6214416834,
		["Zigzag 2"] = 6214375242,
		["Tartan"] = 6214404863,
		["Roses"] = 6214374619,
		["Hexagons"] = 6214320051,
		["Leopard print"] = 6214318622
	}
	library.SettingsMenu:AddList({text = "Background", flag = "UI Background", max = 6, values = {"Floral", "Flowers", "Circles", "Hearts", "Polka dots", "Mountains", "Zigzag", "Zigzag 2", "Tartan", "Roses", "Hexagons", "Leopard print"}, callback = function(Value)
		if Backgrounds[Value] then
			library.main.Image = "rbxassetid://" .. Backgrounds[Value]
		end
	end}):AddColor({flag = "Menu Background Color", color = Color3.fromRGB(172,171,171), callback = function(Color)
		library.main.ImageColor3 = Color
	end, trans = 1, calltrans = function(Value)
		library.main.ImageTransparency = 1 - Value
	end})
	library.SettingsMenu:AddSlider({text = "Tile Size", value = 90, min = 50, max = 500, callback = function(Value)
		library.main.TileSize = UDim2.new(0, Value, 0, Value)
	end})
	library.SettingsMenu:AddSlider({text = "Menu X Offset", value = 500, min = 0, max = 1000})
	library.SettingsMenu:AddSlider({text = "Menu Y Offset", value = 600, min = 0, max = 1000})
	game:GetService("RunService").RenderStepped:Connect(function()
		for i,v in pairs(game.CoreGui:GetChildren()) do
			if v.Name == "ScreenGui" and v:FindFirstChild("ImageButton") and v.ImageButton then
				a = v.ImageButton
				if a then
					a.Size = UDim2.new(0, library.flags["Menu X Offset"], 0, library.flags["Menu Y Offset"])
				end
			end
		end
	end)
	library.SettingsMenu:AddBox({text = "Custom NAME", callback = function(selected)
		NChanger = selected
	end})
	library.SettingsMenu:AddList({text = "Custom FONT", values = {"Code", "Arcade", "Bangers", "Creepster", "GothamBlack", "LuckiestGuy", "Michroma", "PermanentMarker", "Sarpanch", "SpecialElite"}, callback = function(selected)
		FChanger = selected
	end})
	library.SettingsMenu:AddButton({text = "Change Name/Font", callback = function()
		for i,v in pairs(game.CoreGui:GetChildren()) do
			if v.Name == "ScreenGui" and v:FindFirstChild("ImageButton") and v.ImageButton:FindFirstChild("TextLabel") then
				a = v.ImageButton.TextLabel
			elseif v:FindFirstChild("TextLabel") and v.TextLabel.Text:find(game.Players.LocalPlayer.Name) then
				b = v.TextLabel
			end
		end
	
	if a then
	a.Text = NChanger
	a.Font = FChanger
	end
	if b then
	b:GetPropertyChangedSignal("Text"):Connect(function()
		b.Text = b.Text:gsub("cuteware", NChanger)
		b.Font = FChanger
		b.TextSize = "9"
	end)
	end
	end})
library.SettingsMenu:AddToggle({text = "Spectators List", callback = function(val)
	if val then
local SpectatorsList = Instance.new("ScreenGui")
local Spectators = Instance.new("Frame")
local Container = Instance.new("Frame")
local Text = Instance.new("TextLabel")
local Players = Instance.new("TextLabel")
local Background = Instance.new("Frame")
local Color = Instance.new("Frame")

SpectatorsList.Parent = game.CoreGui
SpectatorsList.Name = "SpectatorsList"
SpectatorsList.Enabled = true

Spectators.Name = "Spectators"
Spectators.Parent = SpectatorsList
Spectators.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Spectators.BackgroundTransparency = 1.000
Spectators.BorderColor3 = Color3.fromRGB(255, 255, 255)
Spectators.Position = UDim2.new(0.00800000038, 0, 0.400000006, 49)
Spectators.Size = UDim2.new(0, 155, 0, 24)

Container.Name = "Container"
Container.Parent = Spectators
Container.BackgroundTransparency = 1.000
Container.BorderSizePixel = 0
Container.Position = UDim2.new(0, 0, 0, 4)
Container.Size = UDim2.new(1, 0, 0, 14)
Container.ZIndex = 3

Text.Name = "Text"
Text.Parent = Container
Text.BackgroundTransparency = 1.000
Text.Size = UDim2.new(1, 0.001, 1, 0)
Text.ZIndex = 4
Text.Font = Enum.Font.Fantasy
Text.Text = "Spectators"
Text.TextColor3 = Color3.fromRGB(65025, 65025, 65025)
Text.TextSize = 13.500
Text.TextStrokeTransparency = 0.000

Players.Name = "Players"
Players.Parent = Container
Players.BackgroundTransparency = 1.000
Players.Position = UDim2.new(0.0196080022, 0, 1.44285719, 0)
Players.Size = UDim2.new(0.980391979, 0, 1.14285719, 0)
Players.ZIndex = 4
Players.Font = Enum.Font.Fantasy
Players.Text = "loading"
Players.TextColor3 = Color3.fromRGB(65025, 65025, 65025)
Players.TextSize = 12.000
Players.TextStrokeTransparency = 0.000
Players.TextYAlignment = Enum.TextYAlignment.Top

Background.Name = "Background"
Background.Parent = Spectators
Background.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Background.BorderColor3 = library.flags["SpecColor"]
Background.Size = UDim2.new(1, 0, 1, 0)

Color.Name = "Color"
Color.Parent = Spectators
Color.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Color.BorderSizePixel = 0
Color.Size = UDim2.new(1, 0, 0, 2)
Color.ZIndex = 2

function GetSpectators()
	local CurrentSpectators = ""
	for i,v in pairs(game.Players:GetChildren()) do 
		pcall(function()
			if v ~= game.Players.LocalPlayer then
				if not v.Character then 
					if (v.CameraCF.Value.p - game.Workspace.CurrentCamera.CFrame.p).Magnitude < 10 then 
						if CurrentSpectators == "" then
								CurrentSpectators = v.Name
							else
								CurrentSpectators = CurrentSpectators.. "\n" ..v.Name
							end
						end
					end
				end
			end)
		end
	return CurrentSpectators
end

spawn(function()
	while wait(0.1) do
		if SpectatorsList.Enabled then
			Players.Text = GetSpectators()
		end
	end
end)

local function SCUAM_fake_script() -- Spectators.LocalScript 
	local script = Instance.new('LocalScript', Spectators)
	local gui = script.Parent
	gui.Draggable = true
	gui.Active = true
end
coroutine.wrap(SCUAM_fake_script)()
else
	for i,v in pairs(game.CoreGui:GetChildren()) do
		if v.Name == "SpectatorsList" then
			v:Destroy()
		end
	end
end
end}):AddColor({flag = "SpecColor", color = Color3.fromRGB(255, 255, 255), callback = function(color)
	for i,v in pairs(game.CoreGui:GetChildren()) do
		if v.Name == "SpectatorsList" then
			v.Spectators.Background.BorderColor3 = color
		end
	end
end})

	library.ConfigSection = library.SettingsColumn1:AddSection"Configs"
	library.ConfigSection:AddBox({text = "Config Name", skipflag = true})
	library.ConfigSection:AddButton({text = "Create", callback = function()
		library:GetConfigs()
		writefile(library.foldername .. "/" .. library.flags["Config Name"] .. library.fileext, "{}")
		library.options["Config List"]:AddValue(library.flags["Config Name"])
	end})
	library.ConfigWarning = library:AddWarning({type = "confirm"})
	library.ConfigSection:AddList({text = "Configs", skipflag = true, value = "", flag = "Config List", values = library:GetConfigs()})
	library.ConfigSection:AddButton({text = "Save", callback = function()
		local r, g, b = library.round(library.flags["Menu Accent Color"])
		library.ConfigWarning.text = "Are you sure you want to save the current settings to config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?"
		if library.ConfigWarning:Show() then
			library:SaveConfig(library.flags["Config List"])
		end
	end})
	library.ConfigSection:AddButton({text = "Load", callback = function()
		local r, g, b = library.round(library.flags["Menu Accent Color"])
		library.ConfigWarning.text = "Are you sure you want to load config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?"
		if library.ConfigWarning:Show() then
			library:LoadConfig(library.flags["Config List"])
		end
	end})
	library.ConfigSection:AddButton({text = "Delete", callback = function()
		local r, g, b = library.round(library.flags["Menu Accent Color"])
		library.ConfigWarning.text = "Are you sure you want to delete config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?"
		if ConfigWarning:Show() then
			local Config = library.flags["Config List"]
			if table.find(library:GetConfigs(), Config) and isfile(library.foldername .. "/" .. Config .. library.fileext) then
				library.options["Config List"]:RemoveValue(Config)
				delfile(library.foldername .. "/" .. Config .. library.fileext)
			end
		end
	end})
	--LIBRARY END
	
	--custom notification thing, library required for this to work
	local LastNotification = 0
	function library:SendNotification(duration, message)
		LastNotification = LastNotification + tick()
		if LastNotification < 0.2 or not library.base then return end
		LastNotification = 0
		if duration then
			duration = tonumber(duration) or 2
			duration = duration < 2 and 2 or duration
		else
			duration = message
		end
		message = message and tostring(message) or "Empty"

		--create the thing
		local notification = library:Create("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Size = UDim2.new(0, 0, 0, 80),
			Position = UDim2.new(1, -5, 1, -5),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(20, 20, 20),
			Parent = library.base
		})
		tweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 80), BackgroundTransparency = 0}):Play()

		tweenService:Create(library:Create("TextLabel", {
			Position = UDim2.new(0, 5, 0, 25),
			Size = UDim2.new(1, -10, 0, 40),
			BackgroundTransparency = 1,
			Text = tostring(message),
			Font = Enum.Font.SourceSans,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 18,
			TextTransparency = 1,
			TextWrapped = true,
			Parent = notification
		}), TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3), {TextTransparency = 0}):Play()

		--bump existing notifications
		for _,notification in next, library.notifications do
			notification:TweenPosition(UDim2.new(1, -5, 1, notification.Position.Y.Offset - 85), "Out", "Quad", 0.2)
		end
		library.notifications[notification] = notification

		wait(0.4)

		--create other things
		library:Create("Frame", {
			Position = UDim2.new(0, 0, 0, 20),
			Size = UDim2.new(0, 0, 0, 1),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BorderSizePixel = 0,
			Parent = notification
		}):TweenSize(UDim2.new(1, 0, 0, 1), "Out", "Linear", duration)

		tweenService:Create(library:Create("TextLabel", {
			Position = UDim2.new(0, 4, 0, 0),
			Size = UDim2.new(0, 70, 0, 16),
			BackgroundTransparency = 1,
			Text = "                                  Vainless",
			Font = Enum.Font.Gotham,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = 16,
			TextTransparency = 1,
			Parent = notification
		}), TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

		--remove
		delay(duration, function()
			if not library then return end
			library.notifications[notification] = nil
			--bump existing notifications down
			for _,otherNotif in next, library.notifications do
				if otherNotif.Position.Y.Offset < notification.Position.Y.Offset then
					otherNotif:TweenPosition(UDim2.new(1, -5, 1, otherNotif.Position.Y.Offset + 85), "Out", "Quad", 0.2)
				end
			end
			notification:Destroy()
		end)
	end
	local Camera = workspace.CurrentCamera
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local GuiService = game:GetService("GuiService")
	local UserInputService = game:GetService("UserInputService")
	local cbClient = getsenv(game.Players.LocalPlayer.PlayerGui.Client)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
	local LocalPlayer = Players.LocalPlayer
	local Mouse = LocalPlayer:GetMouse()
	
	local GetChildren = game.GetChildren
	local WorldToScreen = Camera.WorldToScreenPoint
	local WorldToViewportPoint = Camera.WorldToViewportPoint
	local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
	local FindFirstChild = game.FindFirstChild
	local RenderStepped = RunService.RenderStepped
	local GuiInset = GuiService.GetGuiInset
	
	local resume = coroutine.resume 
	local create = coroutine.create
	
	local ValidTargetParts = {"Head", "UpperTorso", "HumanoidRootPart"};
	
	local function IsAlive(plr)
		if plr and plr.Character and plr.Character.FindFirstChild(plr.Character, "Humanoid") and plr.Character.Humanoid.Health > 0 then
			return true
		end
	
		return false
	end
	
	local function getPositionOnScreen(Vector)
		local Vec3, OnScreen = WorldToScreen(Camera, Vector)
		return Vector2.new(Vec3.X, Vec3.Y), OnScreen
	end
	
	local function ValidateArguments(Args, RayMethod)
		local Matches = 0
		if #Args < RayMethod.ArgCountRequired then
			return false
		end
		for Pos, Argument in next, Args do
			if typeof(Argument) == RayMethod.Args[Pos] then
				Matches = Matches + 1
			end
		end
		return Matches >= RayMethod.ArgCountRequired
	end
	
	local function getDirection(Origin, Position)
		return (Position - Origin).Unit * 1000
	end
	
	local function getMousePosition()
		return Vector2.new(Mouse.X, Mouse.Y)
	end
	
	local function IsPlayerVisible(Player)
		local PlayerCharacter = Player.Character
		local LocalPlayerCharacter = LocalPlayer.Character
		
		if not (PlayerCharacter or LocalPlayerCharacter) then return end 
		
		local PlayerRoot = FindFirstChild(PlayerCharacter, library.flags["TargetPart"]) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
		
		if not PlayerRoot then return end 
		
		local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
		local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
		
		return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
	end
	
	local function getClosestPlayer()
		if not library.flags["TargetPart"] then return end
		local Closest
		local DistanceToMouse
		for _, Player in next, GetChildren(Players) do
			if Player == LocalPlayer then continue end
			if library.flags["TeamCheck"] and Player.Team == LocalPlayer.Team then continue end
	
			local Character = Player.Character
			if not Character then continue end
			
			if library.flags["VisibleCheck"] and not IsPlayerVisible(Player) then continue end
	
			local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
			local Humanoid = FindFirstChild(Character, "Humanoid")
	
			if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end
	
			local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
	
			if not OnScreen then continue end
	
			local Distance = (getMousePosition() - ScreenPosition).Magnitude
			if Distance <= (DistanceToMouse or (library.flags["fov_Enabled"] and library.flags["fov_Radius"]) or 2000) then
				Closest = ((library.flags["TargetPart"] == "Closest" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[library.flags["TargetPart"]])
				DistanceToMouse = Distance
			end
		end
		return Closest
	end
	
	
	
		local LegitTab = library:AddTab("Legit")
		local VisualsTab = library:AddTab("Visuals")
		local MiscTab = library:AddTab("Misc")
		local SkinTab = library:AddTab("Skins")
		local LuaTab = library:AddTab("Lua")
		local LuaColumn1 = LuaTab:AddColumn()
		local LuaColumn2 = LuaTab:AddColumn()
		local LuaSection = LuaColumn1:AddSection"Lua"
	
		local LegitColumn = LegitTab:AddColumn()
		local LegitColumn1 = LegitTab:AddColumn()
	
		local SilentSection = LegitColumn:AddSection"Silent Aim"



		SilentSection:AddToggle({text = "Enabled", flag = "Aimbot", callback = function() end})
	SilentSection:AddToggle({text = "Team Check", flag = "TeamCheck"})
    SilentSection:AddToggle({text = "Visible Check", flag = "VisibleCheck"})
    SilentSection:AddList({text = "Target Part", flag = "TargetPart", values = {
        "Head", "UpperTorso", "Closest"
    }})

	local ExpectedArguments = {
		FindPartOnRayWithIgnoreList = {
			ArgCountRequired = 3,
			Args = {
				"Instance", "Ray", "table", "boolean", "boolean"
			}
		}
	}
	
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(...)
		local Method = getnamecallmethod()
        local callingscript = getcallingscript()
		local Arguments = {...}
		local self = Arguments[1]

		if library.flags["Aimbot"] and self == workspace then
			if Method == "FindPartOnRayWithIgnoreList" then
				if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
					local A_Ray = Arguments[2]
	
					local HitPart = getClosestPlayer()
					if HitPart then
						local Origin = A_Ray.Origin
						local Direction = getDirection(Origin, HitPart.Position)
						Arguments[2] = Ray.new(Origin, Direction)
	
						return oldNamecall(unpack(Arguments))
					end
				end
			end
		end
        if Method == "FireServer" then
        if self.Name == "FallDamage" and library.flags["No Fall Damage"] then
            return
        end
        if self.Name == "BURNME" and library.flags["No Fire Damage"] then
            return
        end
        end
		return oldNamecall(...)
	end)
	
	

local AimFOV = LegitColumn1:AddSection"FOV"


local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.NumSides = 100
fov_circle.Radius = 180
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 1
fov_circle.Color = Color3.fromRGB(54, 57, 241)

AimFOV:AddToggle({text = "Enabled", flag = "fov_Enabled"})
AimFOV:AddSlider({text = "Radius", flag = "fov_Radius", min = 0, max = 360, callback = function(val) 
	fov_circle.Radius = val
end}):AddColor({flag = "fov_Color", color = Color3.fromRGB(54, 57, 241)})

AimFOV:AddToggle({text = "Visible", flag = "fov_Visible", callback = function(val) 
	fov_circle.Visible = val
end})

resume(create(function()
    RenderStepped:Connect(function()
    if library.flags["fov_Enabled"] then 
            fov_circle.Visible = library.flags["fov_Visible"]
            fov_circle.Color = library.flags["fov_Color"]
            fov_circle.Position = getMousePosition() + Vector2.new(0, 36)
        end
    end)
end))


local Settings = {
	ESP = {
		Enabled = false,
		Box = false,
		Name = false,
        Gun = false,
		Tracers = false,
		Chams = false,
		Font = 3,
		Teammates = false,
		VisibleOnly = false,
		UnlockTracers = false,
		TextSize = 16,
	}
}

local VisualColumn = VisualsTab:AddColumn()
local VisualColumn1 = VisualsTab:AddColumn()

local PlayerESPTab = VisualColumn:AddSection"Players"

PlayerESPTab:AddToggle({text = "Enabled", flag = "esp_enabled"})
PlayerESPTab:AddToggle({text = "Boxes", flag = "box_enabled"}):AddColor({flag = "box_color", color = Color3.fromRGB(255, 255, 255)})
PlayerESPTab:AddToggle({text = "Names", flag = "name_enabled"}):AddColor({flag = "name_color", color = Color3.fromRGB(255, 255, 255)})
PlayerESPTab:AddToggle({text = "Health Bar", flag = "health_enabled"}):AddColor({flag = "health_color", color = Color3.fromRGB(0, 255, 26)})
PlayerESPTab:AddToggle({text = "Weapon", flag = "weapon_enabled"}):AddColor({flag = "weapon1_color", color = Color3.fromRGB(255, 255, 255)})
PlayerESPTab:AddToggle({text = "Out Of FOV", flag = "OOF_enabled"}):AddColor({flag = "OOF_color", color = Color3.fromRGB(255, 255, 255)})


local PlayerDrawings = {}
local Utility        = {}

Utility.Settings = {
    Line = {
        Thickness = 1,
        Color = Color3.fromRGB(0, 255, 0)
    },
    Text = {
        Size = 13,
        Center = true,
        Outline = true,
        Font = Drawing.Fonts.Plex,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Square = {
        Thickness = 1,
        Color = library.flags["box_color"],
        Filled = false,
    },
    Triangle = {
        Color = Color3.fromRGB(255, 255, 255),
        Filled = true,
        Visible = false,
        Thickness = 1,
    }
}
function Utility.New(Type, Outline, Name)
    local drawing = Drawing.new(Type)
    for i, v in pairs(Utility.Settings[Type]) do
        drawing[i] = v
    end
    if Outline then
        drawing.Color = Color3.new(0,0,0)
        drawing.Thickness = 3
    end
    return drawing
end
function Utility.Add(Player)
    if not PlayerDrawings[Player] then
        PlayerDrawings[Player] = {
            Offscreen = Utility.New("Triangle", nil, "Offscreen"),
            Name = Utility.New("Text", nil, "Name"),
            Tool = Utility.New("Text", nil, "Tool"),
            BoxOutline = Utility.New("Square", true, "BoxOutline"),
            Box = Utility.New("Square", nil, "Box"),
            HealthOutline = Utility.New("Line", true, "HealthOutline"),
            Health = Utility.New("Line", nil, "Health")
        }
    end
end

for _,Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        Utility.Add(Player)
    end
end
Players.PlayerAdded:Connect(Utility.Add)
Players.PlayerRemoving:Connect(function(Player)
    if PlayerDrawings[Player] then
        for i,v in pairs(PlayerDrawings[Player]) do
            if v then
                v:Remove()
            end
        end

        PlayerDrawings[Player] = nil
    end
end)



local ESPLoop = game:GetService("RunService").RenderStepped:Connect(function()
    for _,Player in pairs (Players:GetPlayers()) do
        local PlayerDrawing = PlayerDrawings[Player]
        if not PlayerDrawing then continue end

        for _,Drawing in pairs (PlayerDrawing) do
            Drawing.Visible = false
        end

        if not library.flags["esp_enabled"] then continue end

        local Character = Player.Character
        local RootPart, Humanoid = Character and Character:FindFirstChild("HumanoidRootPart"), Character and Character:FindFirstChildOfClass("Humanoid")
        if not Character or not RootPart or not Humanoid then continue end

        local DistanceFromCharacter = (Camera.CFrame.Position - RootPart.Position).Magnitude
        if 1000 < DistanceFromCharacter then continue end

        local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
        if not OnScreen then
            if not library.flags["OOF_enabled"] then continue end
            if Player.Team == LocalPlayer.Team then continue end

            local RootPos = RootPart.Position
            local CameraVector = Camera.CFrame.Position
            local LookVector = Camera.CFrame.LookVector

            local Dot = LookVector:Dot(RootPart.Position - Camera.CFrame.Position)
            if Dot <= 0 then
                RootPos = (CameraVector + ((RootPos - CameraVector) - ((LookVector * Dot) * 1.01)))
            end

            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(RootPos)
            if not OnScreen then
                local Drawing = PlayerDrawing.Offscreen
                local FOV     = 800 - 400
                local Size    = 15

                local Center = (Camera.ViewportSize / 2)
                local Direction = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Unit
                local Radian = math.atan2(Direction.X, Direction.Y)
                local Angle = (((math.pi * 2) / FOV) * Radian)
                local ClampedPosition = (Center + (Direction * math.min(math.abs(((Center.Y - FOV) / math.sin(Angle)) * FOV), math.abs((Center.X - FOV) / (math.cos(Angle)) / 2))))
                local Point = Vector2.new(math.floor(ClampedPosition.X - (Size / 2)), math.floor((ClampedPosition.Y - (Size / 2) - 15)))

                local function Rotate(point, center, angle)
                    angle = math.rad(angle)
                    local rotatedX = math.cos(angle) * (point.X - center.X) - math.sin(angle) * (point.Y - center.Y) + center.X
                    local rotatedY = math.sin(angle) * (point.X - center.X) + math.cos(angle) * (point.Y - center.Y) + center.Y

                    return Vector2.new(math.floor(rotatedX), math.floor(rotatedY))
                end

                local Rotation = math.floor(-math.deg(Radian)) - 47
                Drawing.PointA = Rotate(Point + Vector2.new(Size, Size), Point, Rotation)
                Drawing.PointB = Rotate(Point + Vector2.new(-Size, -Size), Point, Rotation)
                Drawing.PointC = Rotate(Point + Vector2.new(-Size, Size), Point, Rotation)
                Drawing.Color = library.flags["OOF_color"]

                Drawing.Filled = false
                Drawing.Transparency = 1

                Drawing.Visible = true
            end
        else
            if Player.Team == LocalPlayer.Team then continue end

            local Size           = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
            local BoxSize        = Vector2.new(math.floor(Size * 1.5), math.floor(Size * 1.9))
            local BoxPos         = Vector2.new(math.floor(Pos.X - Size * 1.5 / 2), math.floor(Pos.Y - Size * 1.6 / 2))

            local Name           = PlayerDrawing.Name
            local Tool           = PlayerDrawing.Tool
            local Distance       = PlayerDrawing.Distance
            local Box            = PlayerDrawing.Box
            local BoxOutline     = PlayerDrawing.BoxOutline
            local Health         = PlayerDrawing.Health
            local HealthOutline  = PlayerDrawing.HealthOutline

            if library.flags["box_enabled"] then
                Box.Size = BoxSize
                Box.Position = BoxPos
                Box.Visible = true
                Box.Color = library.flags["box_color"]
                BoxOutline.Size = BoxSize
                BoxOutline.Position = BoxPos
                BoxOutline.Visible = true
            end

            if library.flags["health_enabled"] then
                Health.From = Vector2.new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
                Health.To = Vector2.new(Health.From.X, Health.From.Y - (Humanoid.Health / Humanoid.MaxHealth) * BoxSize.Y)
                Health.Color = library.flags["health_color"]
                Health.Visible = true

                HealthOutline.From = Vector2.new(Health.From.X, BoxPos.Y + BoxSize.Y + 1)
                HealthOutline.To = Vector2.new(Health.From.X, (Health.From.Y - 1 * BoxSize.Y) -1)
                HealthOutline.Visible = true
            end

            local function SurroundString(String, Add)
                local Left = ""
                local Right = ""

                local Remove = false
                if Add == "[]" then
                    String = string.gsub(String, "%[", "")
                    String = string.gsub(String, "%[", "")

                    Left = "["
                    Right = "]"
                elseif Add == "--" then
                    Left = "-"
                    Right = "-"
                    Remove = true
                elseif Add == "<>" then
                    Left = "<"
                    Right = ">"
                    Remove = true
                end
                if Remove then
                    String = string.gsub(String, Left, "")
                    String = string.gsub(String, Right, "")
                end

                return Left..String..Right
            end

            if library.flags["name_enabled"] then
                Name.Text = SurroundString(Player.Name, "<>")
                Name.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
                Name.Color = library.flags["name_color"]
                Name.Font = Drawing.Fonts["UI"]
                Name.Visible = true
            end

            if library.flags["weapon_enabled"] then
                local BottomOffset = BoxSize.Y + BoxPos.Y + 1
                local Equipped = tostring(Player.Character.EquippedTool.Value)
                Equipped = SurroundString(Equipped, "<>")
                Tool.Text = Equipped
                Tool.Position = Vector2.new(BoxSize.X/2 + BoxPos.X, BottomOffset)
                Tool.Color = library.flags["weapon1_color"]
                Tool.Font = Drawing.Fonts["UI"]
                Tool.Visible = true
                BottomOffset = BottomOffset + 15
            end
        end
    end
end)


local ap = Instance.new("Folder", game.CoreGui)
function chams(aq)
    pcall(
        function()
            if aq.Character then
                for B, C in next, aq.Character:GetChildren() do
                    if C:IsA "BasePart" and C.Name ~= "HumanoidRootPart" then
                        local ar = Instance.new("BoxHandleAdornment")
                        ar.Size = C.Size + Vector3.new(0.1, 0.1, 0.1)
                        ar.Transparency = library.flags["chams_trans"] / 100
                        ar.ZIndex = 0
                        ar.AlwaysOnTop = true
                        ar.Visible = true
                        ar.Parent = ap
                        ar.Adornee = C
                        ar.Color3 = library.flags["chams_color"]
                        if aq.Character:FindFirstChild("HumanoidRootPart") then
                            aq.Character.HumanoidRootPart.AncestryChanged:connect(
                                function()
                                    ar:Destroy()
                                end
                            )
                        end
                    end
                end
            end
        end
    )
end
local ap = Instance.new("Folder", game.CoreGui)
function chams(aq)
    pcall(
        function()
            if aq.Character then
                for B, C in next, aq.Character:GetChildren() do
                    if C:IsA "BasePart" and C.Name ~= "HumanoidRootPart" then
                        local ar = Instance.new("BoxHandleAdornment")
                        ar.Size = C.Size + Vector3.new(0.1, 0.1, 0.1)
                        ar.Transparency = library.flags["chams_trans"] / 100
                        ar.ZIndex = 0
                        ar.AlwaysOnTop = true
                        ar.Visible = true
                        ar.Parent = ap
                        ar.Adornee = C
                        ar.Color3 = library.flags["chams_color"]
                        if aq.Character:FindFirstChild("HumanoidRootPart") then
                            aq.Character.HumanoidRootPart.AncestryChanged:connect(
                                function()
                                    ar:Destroy()
                                end
                            )
                        end
                    end
                end
            end
        end
    )
end

PlayerESPTab:AddToggle({text = "Chams", flag = "chams_enabled", callback = function(val)
	if val == true then
        for B, C in next, Players:GetPlayers() do
            if C ~= LocalPlayer and C.Team ~= LocalPlayer.Team and C.Character and C.Character.PrimaryPart then
                chams(C)
            end
        end
    else
        ap:ClearAllChildren()
    end
end}):AddColor({text = "Color", flag = "chams_color", callback = function(val)
	for B, C in next, ap:GetChildren() do
		C.Color3 = val
	end
end})
PlayerESPTab:AddSlider({text = "Transparency", flag = "chams_trans", min = 0, max = 100, value = 50, callback = function(val) 
	for B, C in next, ap:GetChildren() do
        C.Transparency = 0 + val / 100
    end
end})

for B, C in next, Players:GetPlayers() do
    C.CharacterAdded:Connect(
        function(aq)
            wait(1)
            if C ~= LocalPlayer and LocalPlayer.Team ~= C.Team and library.flags["chams_enabled"] == true then
                chams(C)
            end
        end
    )
end
Players.PlayerAdded:Connect(
    function(C)
        C.CharacterAdded:Connect(
            function(aq)
                wait(1)
                if C ~= LocalPlayer and C.Team ~= LocalPlayer.Team and library.flags["chams_enabled"] == true then
                    chams(C)
                end
            end
        )
    end
)
for B, C in next, game.Teams:GetChildren() do
    C.PlayerAdded:connect(
        function(aq)
            if aq == LocalPlayer then
                ap:ClearAllChildren()
                wait(0.5)
                if library.flags["chams_enabled"] == true then
                    for B, C in next, Players:GetPlayers() do
                        if
                            C ~= LocalPlayer and C.Team ~= LocalPlayer.Team and C.Character and C.Character:FindFirstChild("Humanoid") and
                                C.Character.Humanoid.Health > 0
                         then
                            chams(C)
                        end
                    end
                end
            end
        end
    )
end

local VisualSection = VisualColumn1:AddSection"Visuals"
VisualSection:AddToggle({text = "No Flash", flag = "noflash", callback = function(val) 
if val then
	game.Players.LocalPlayer.PlayerGui.Blnd.Enabled = false
else
	game.Players.LocalPlayer.PlayerGui.Blnd.Enabled = true
end
end})

VisualSection:AddToggle({text = "No Smoke", flag = "nosmoke", callback = function(val)
if val then
	game:GetService("RunService"):BindToRenderStep("NoSmokes", 100, function()
		for i,v in pairs(game.Workspace["Ray_Ignore"].Smokes:GetChildren()) do
			if v:IsA("Part") then
				v:Destroy()
			end
		end
	end)
else
	game:GetService("RunService"):UnbindFromRenderStep("NoSmokes")
end
end})

VisualSection:AddToggle({text = "No Scope", flag = "noscope", callback = function(val)
	if val then
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.ImageTransparency = 1
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.ImageTransparency = 1
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.Size = UDim2.new(2,0,2,0)
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.Position = UDim2.new(-0.5,0,-0.5,0)
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.Blur.ImageTransparency = 1
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.Blur.Blur.ImageTransparency = 1
	LocalPlayer.PlayerGui.GUI.Crosshairs.Frame1.Transparency = 1
	LocalPlayer.PlayerGui.GUI.Crosshairs.Frame2.Transparency = 1
	LocalPlayer.PlayerGui.GUI.Crosshairs.Frame3.Transparency = 1
	LocalPlayer.PlayerGui.GUI.Crosshairs.Frame4.Transparency = 1
else
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.ImageTransparency = 0
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.ImageTransparency = 0
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.Size = UDim2.new(1,0,1,0)
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.Position = UDim2.new(0,0,0,0)
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.Blur.ImageTransparency = 0
	LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Scope.Blur.Blur.ImageTransparency = 0
	LocalPlayer.PlayerGui.GUI.Crosshairs.Frame1.Transparency = 0
	LocalPlayer.PlayerGui.GUI.Crosshairs.Frame2.Transparency = 0
	LocalPlayer.PlayerGui.GUI.Crosshairs.Frame3.Transparency = 0
	LocalPlayer.PlayerGui.GUI.Crosshairs.Frame4.Transparency = 0
	end
end})

VisualSection:AddToggle({text = "Force Crosshair", flag = "forcecrosshair"})

local cworld = Instance.new("ColorCorrectionEffect", workspace.CurrentCamera)
VisualSection:AddToggle({text = "Colorful World", flag = "colorfulworld", callback = function(val)
	if val then
        cworld.Saturation = 1.2
    else
        cworld.Saturation = 0
    end
end})
local correction = Instance.new("ColorCorrectionEffect", game.Lighting)
VisualSection:AddToggle({text = "Night Mode", flag = "nightmode", callback = function(val)
if val then
	correction.Brightness = -0.15
	game.Lighting.Brightness = 0
else
	correction.Brightness = 0
	game.Lighting.Brightness = 1
	end
end})
game:GetService("RunService").Stepped:connect(function()
	pcall(
            function()
                if game.Lighting:FindFirstChild("SunRays") then
                    game.Lighting.SunRays.Intensity = library.flags["nightmode"] and 0 or 0.11
                end
                game.Lighting.TimeOfDay = library.flags["nightmode"] and 17 or 14
			end)
end)
oldNewIndex = hookfunc(getrawmetatable(game.Players.LocalPlayer.PlayerGui.Client).__newindex, newcclosure(function(self, idx, val)
	if not checkcaller() then
			if self.Name == "Crosshair" and idx == "Visible" and val == false and LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Visible == false and library.flags["forcecrosshair"] == true then
			val = true
	end
	end
    return oldNewIndex(self, idx, val)
end))




function hasProperty(ins,pro)
    return pcall(function() _=ins[pro] end)
end

function updateViewmodel()
    if Camera:FindFirstChild("Arms") then
        local arms = Camera.Arms
        for i,v in next, arms:GetChildren() do
            if library.flags["weapon_chams"] then
                if (v:IsA("MeshPart") or v.Name == "Part") and v.Transparency ~= 1 then
                    if v.Name == "StatClock" then v:ClearAllChildren() end
                    v.Color = library.flags["weapon_color"]
                    v.Transparency = library.flags["weapon_trans"]/100
                    v.Material = library.flags["weapon_material"]
                    if hasProperty(v,"TextureID") then v.TextureID = "" end
				end
			end
					if v:IsA"Model" then
						for _i,_v in next, v:GetDescendants() do
							if library.flags["remove_sleeves"] and _v.Name == "Sleeve" then
								_v:Destroy()
							end
							if library.flags["arm_chams"] then
								if hasProperty(_v,"CastShadow") then _v.CastShadow = false end
								if _v:IsA"SpecialMesh" then
									local clr = library.flags["arm_color"]
									_v.VertexColor = Vector3.new(clr.R,clr.G,clr.B)
								end
								if _v:IsA"Part" then
									_v.Material = library.flags["arm_material"]
									_v.Transparency = library.flags["arm_trans"]/100
									_v.Color = library.flags["arm_color"]
									if _v.Transparency == 1 then continue end
						end
					end
				end
			end
		end
	end
end

VisualSection:AddToggle({text = "Weapon Chams", flag = "weapon_chams", callback = updateViewmodel}):AddColor({flag = "weapon_color", callback = updateViewmodel})
VisualSection:AddSlider({text = "Weapon Chams Transparency", flag = "weapon_trans", min = 0, max = 100, callback = updateViewmodel})
VisualSection:AddList({text = "Weapon Material", flag = "weapon_material", values = {"SmoothPlastic", "Neon", "ForceField", "Glass"}, callback = updateViewmodel})

VisualSection:AddToggle({text = "Remove Sleeves", flag = "remove_sleeves", callback = updateViewmodel})
VisualSection:AddToggle({text = "Arm Chams", flag = "arm_chams", callback = updateViewmodel}):AddColor({flag = "arm_color", callback = updateViewmodel})
VisualSection:AddSlider({text = "Arm Chams Transparency", flag = "arm_trans", min = 0, max = 100, callback = updateViewmodel})
VisualSection:AddList({text = "Arm Material", flag = "arm_material", values = {"SmoothPlastic", "Neon", "ForceField", "Glass"}, callback = updateViewmodel})


Camera.ChildAdded:Connect(function()
    updateViewmodel()
end)






local Old_call
	Old_call= hookmetamethod(game, "__namecall", function(self, ...)
		if checkcaller() or not library then return Old_call(self, ...) end

		local Args = {...}
		local Method = getnamecallmethod()

		if Method == "SetPrimaryPartCFrame" then
				if self.Name == "Arms" then
					if library.flags["Viewmodel Changer"] then
						if library.flags["Flip Z"] then
							Args[1] = Args[1] * CFrame.new(1, 1, 1, 0, 0, 1, 0)
						end
						if library.flags["Flip Y"] then
							Args[1] = Args[1] * CFrame.new(1, 1, 1, 0.5, 0, 0, 0)
						end
						local X = library.flags["X Offset"] * 120 / 500
						local Y = library.flags["Y Offset"] * 120 / 500
						local dl = library.flags["Z Offset"] * 120 / 500
						Args[1] = Args[1] * CFrame.new(X, Y, library.flags["Flip Y"] and dl * 2 or dl)
					end
				end
		end

		return Old_call(self, unpack(Args))
	end)

	local ViewModelSection = VisualColumn:AddSection"Viewmodel"

	ViewModelSection:AddToggle({text = "Viewmodel Changer"})
	ViewModelSection:AddSlider({text = "X Offset", value = 0, min = -20, max = 20, float = 0.1})
	ViewModelSection:AddSlider({text = "Y Offset", value = 0, min = -20, max = 20, float = 0.1})
	ViewModelSection:AddSlider({text = "Z Offset", value = 0, min = -20, max = 20, float = 0.1})
	ViewModelSection:AddToggle({text = "Flip Y"})
	ViewModelSection:AddToggle({text = "Flip Z"})

	
	

local MiscColumn = MiscTab:AddColumn()
local MiscColumn1 = MiscTab:AddColumn()

local MiscSection = MiscColumn:AddSection"Misc"



MiscSection:AddToggle({text = "Anti-VoteKick"})

local Events = ReplicatedStorage.Events
local TeleportService = game:GetService("TeleportService")

ReplicatedStorage.Events.SendMsg.OnClientEvent:Connect(function(message)
	if library.flags["Anti-VoteKick"] then
		local msg = string.split(message, " ")
		
		if Players:FindFirstChild(msg[1]) and msg[7] == "2" and msg[12] == LocalPlayer.Name then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end
	end
end)

MiscSection:AddToggle({text = "Remove Head", callback = function(val)
	if val then
		if LocalPlayer.Character:FindFirstChild("FakeHead") then
			LocalPlayer.Character.FakeHead:Destroy()
		end
		if LocalPlayer.Character:FindFirstChild("HeadHB") then
			LocalPlayer.Character.HeadHB:Destroy()
		end
	end
end})


MiscSection:AddToggle({text = "Infinite Ammo"})

Camera.ChildAdded:Connect(function(new)
	if library.flags["Infinite Ammo"] == true then
		cbClient.ammocount = 999999 -- primary ammo
		cbClient.primarystored = 999999 -- primary stored
		cbClient.ammocount2 = 999999 -- secondary ammo
		cbClient.secondarystored = 999999 -- secondary stored
	end
end)

MiscSection:AddToggle({text = "Infinite Jump", callback = function(val)
    if val then
		JumpHook = game:GetService("UserInputService").JumpRequest:connect(function()
			game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
		end)
	elseif val == false and JumpHook then
		JumpHook:Disconnect()
	end
end})

MiscSection:AddToggle({text = "Infinite Stamina", callback = function(val)
    if val then
		RunService:BindToRenderStep("Stamina", 100, function()
			if cbClient.crouchcooldown ~= 0 then
				cbClient.crouchcooldown = 0
			end
		end)
	else
		RunService:UnbindFromRenderStep("Stamina")
	end
end})

MiscSection:AddToggle({text = "Remove Killers", callback = function(val)
	if val then
		if workspace:FindFirstChild("Map") and workspace:FindFirstChild("Map"):FindFirstChild("Killers") then
			local clone = workspace:FindFirstChild("Map"):FindFirstChild("Killers"):Clone()
			clone.Name = "KillersClone"
			clone.Parent = workspace:FindFirstChild("Map")

			workspace:FindFirstChild("Map"):FindFirstChild("Killers"):Destroy()
		end
	else
		if workspace:FindFirstChild("Map") and workspace:FindFirstChild("Map"):FindFirstChild("KillersClone") then
			workspace:FindFirstChild("Map"):FindFirstChild("KillersClone").Name = "Killers"
		end
	end
end})

local Addons = MiscColumn1:AddSection"Gun Mods"

Addons:AddToggle({text = "Remove Recoil", callback = function(val)
    if val then
        game:GetService("RunService"):BindToRenderStep("NoRecoil", 100, function()
            cbClient.resetaccuracy()
            cbClient.RecoilX = 0
            cbClient.RecoilY = 0
        end)
    else
        game:GetService("RunService"):UnbindFromRenderStep("NoRecoil")
    end
end})

Addons:AddToggle({text = "Remove Spread"})
Addons:AddToggle({text = "Full Auto"})
Addons:AddToggle({text = "Rapid Fire"})
Addons:AddToggle({text = "Instant Reload"})
Addons:AddToggle({text = "Instant Equip"})
Addons:AddToggle({text = "Infinite Penetration"})
Addons:AddToggle({text = "Infinite Range"})





local getrawmetatable = getrawmetatable or false
local mousemove = mousemove or mousemoverel or mouse_move or false
local getsenv = getsenv or false
local listfiles = listfiles or listdir or syn_io_listdir or false
local isfolder = isfolder or false
local hookfunc = hookfunc or hookfunction or replaceclosure or false

local mt = getrawmetatable(game)

local Old_call
	Old_call= hookmetamethod(game, "__namecall", function(self, ...)
		if checkcaller()  then return Old_call(self, ...) end

		local Args = {...}
		local Method = getnamecallmethod()
		if Method == "FindPartOnRayWithIgnoreList" then
				if #Args[2] > 10 then
					if library.flags["Infinite Penetration"] == true then
						Args[2][#Args[2] + 1] = workspace.Map
					end
				end
			end


		return Old_call(self, unpack(Args))
	end)
    oldIndex = hookfunc(getrawmetatable(LocalPlayer.PlayerGui.Client).__index, newcclosure(function(self, idx)
        if idx == "Value" then
            if self.Name == "Auto" and library.flags["Full Auto"] == true then
                return true
            elseif self.Name == "FireRate" and library.flags["Rapid Fire"] == true then
                return 0.001
            elseif self.Name == "ReloadTime" and library.flags["Instant Reload"] == true then
                return 0.001
            elseif self.Name == "EquipTime" and library.flags["Instant Equip"] == true then
                return 0.001
            elseif self.Name == "Penetration" and library.flags["Infinite Penetration"] == true then
                return 99999999999
            elseif self.Name == "Range" and library.flags["Infinite Range"] == true then
                return 9999
            elseif self.Name == "RangeModifier" and library.flags["Infinite Range"] == true then
                return 100
            elseif (self.Name == "Spread" or self.Parent.Name == "Spread") and library.flags["Remove Spread"] == true then
                return 0
            elseif (self.Name == "AccuracyDivisor" or self.Name == "AccuracyOffset") and library.flags["Remove Spread"] == true then
                return 0.001
            end
        end
        return oldIndex(self, idx)
    end))
MiscSection:AddToggle({text = "Anti-Spectator"})
MiscSection:AddToggle({text = "No Fire Damage"})
MiscSection:AddToggle({text = "No Fall Damage"})
MiscSection:AddToggle({text = "Hitmarker"}):AddColor({color = Color3.fromRGB(255, 255, 255), flag = "hitmarker_color"})







LocalPlayer.Additionals.TotalDamage:GetPropertyChangedSignal("Value"):Connect(function(current)
    if current == 0 then return end
    coroutine.wrap(function()
        if library.flags["Hitmarker"] then
            local Line = Drawing.new("Line")
            local Line2 = Drawing.new("Line")
            local Line3 = Drawing.new("Line")
            local Line4 = Drawing.new("Line")

            local x, y = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2

            Line.From = Vector2.new(x + 4, y + 4)
            Line.To = Vector2.new(x + 10, y + 10)
            Line.Color = library.flags["hitmarker_color"]
            Line.Visible = true 

            Line2.From = Vector2.new(x + 4, y - 4)
            Line2.To = Vector2.new(x + 10, y - 10)
            Line2.Color = library.flags["hitmarker_color"]
            Line2.Visible = true 

            Line3.From = Vector2.new(x - 4, y - 4)
            Line3.To = Vector2.new(x - 10, y - 10)
            Line3.Color = library.flags["hitmarker_color"]
            Line3.Visible = true 

            Line4.From = Vector2.new(x - 4, y + 4)
            Line4.To = Vector2.new(x - 10, y + 10)
            Line4.Color = library.flags["hitmarker_color"]
            Line4.Visible = true

            Line.Transparency = 1
            Line2.Transparency = 1
            Line3.Transparency = 1
            Line4.Transparency = 1

            Line.Thickness = 1
            Line2.Thickness = 1
            Line3.Thickness = 1
            Line4.Thickness = 1

            wait(0.3)
            for i = 1,0,-0.1 do
                wait()
                Line.Transparency = i 
                Line2.Transparency = i
                Line3.Transparency = i
                Line4.Transparency = i
            end
            Line:Remove()
            Line2:Remove()
            Line3:Remove()
            Line4:Remove()
        end
    end)()
end)



MiscSection:AddToggle({text = "Freeze Clip"}):AddBind({flag = "Freeze Clip Key", mode = "Toggle", key = "T", callback = function()
	if library.flags["Freeze Clip"] == true then
		if library.flags["Freeze Clip Key"] == true then
			local Freto = Instance.new("Part")
			Freto.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity
			Freto.CanCollide = false

			Freto.BottomSurface = Enum.SurfaceType.Smooth
			Freto.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
			Freto.Name = "Freto"
			Freto.Size = Vector3.new(30, 1, 30)
			Freto.TopSurface = Enum.SurfaceType.Smooth
			Freto.Parent = game:GetService("Workspace")
			Freto.Transparency = 1

			local Part = Instance.new("Part")
			Part.CanCollide = false
			Part.Anchored = true
			Part.BottomSurface = Enum.SurfaceType.Smooth
			Part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
			Part.Material = Enum.Material.ForceField
			Part.Shape = Enum.PartType.Ball
			Part.Size = Vector3.new(2, 2, 2)
			Part.TopSurface = Enum.SurfaceType.Smooth
			Part.Transparency = 0.3
			Part.Parent = Freto
			Part.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

			local Weld = Instance.new("Weld", Freto)
			Weld.Parent = Freto
			Weld.Part0 = Freto
			Weld.Part1 = game.Players.LocalPlayer.Character.HumanoidRootPart
			library:SendNotification(5, "Enabled Freeze Clip")
		else
			game.Workspace.Freto:Destroy()
			library:SendNotification(5, "Disabled Freeze Clip")
		end
	end
end})



local PlayerSection = MiscColumn:AddSection"Players"

local loopkillplr = {}
			
local Players = game:GetService("Players")
	
function update() 
	local CurrentPlayer = 0 
	for i,v in next, Players:GetPlayers() do 
		if v == LocalPlayer then continue end
		CurrentPlayer = CurrentPlayer + 1 
		table.insert(loopkillplr, v.Name)
	end
end
			
Players.PlayerAdded:connect(update) 
Players.PlayerRemoving:connect(update)
update()

PlayerSection:AddList({text = "Players", values = loopkillplr})

PlayerSection:AddToggle({text = "Loop Kill", callback = function()
	if library.flags["Loop Kill"] and LocalPlayer.Character:FindFirstChild("Gun") then
		_G.DisableLoopKill = false
		local loopkill
		loopkill = game:GetService("RunService").Heartbeat:Connect(function()
			if _G.DisableLoopKill then 
				loopkill:Disconnect() 
				return 
			end
			if Players[library.flags["Players"]].Character and Players[library.flags["Players"]].Team ~= LocalPlayer.Team and Players[library.flags["Players"]].Character:FindFirstChild("UpperTorso") and LocalPlayer.Character:FindFirstChild("UpperTorso") then
				local Arguments = {      
					[1] = Players[library.flags["Players"]].Character.Head,      
					[2] = Players[library.flags["Players"]].Character.Head.Position,      
					[3] = cbClient.gun.Name,      
					[4] = 4096,      
					[5] = cbClient.gun, 
					[6] = Vector3.new(),
					[7] = Vector3.new(),
					[8] = 10,      
					[9] = false,      
					[10] = true,      
					[11] = Vector3.new(),      
					[12] = 16868,      
					[13] = Vector3.new()      
				}  
				for i = 1, 1, 1 do 
					game:GetService("ReplicatedStorage").Events.HitPart:FireServer(unpack(Arguments))
				end
			end
		end)
	else
		_G.DisableLoopKill = true
	end
end})


PlayerSection:AddToggle({text = "Kill All"})
game:GetService("RunService").RenderStepped:Connect(function()
	if library.flags["Kill All"] == true and LocalPlayer.Character:FindFirstChild("UpperTorso") and LocalPlayer.Character:FindFirstChild("Gun") then
		for _,Player in pairs(Players:GetPlayers()) do
			if Player.Character and Player.Team ~= LocalPlayer.Team and Player.Character:FindFirstChild("UpperTorso") then
				local oh1 = Player.Character.Head
				local oh2 = Player.Character.Head.CFrame.p
				local oh3 = "Butterfly Knife"
				local oh4 = 16000
				local oh5 = LocalPlayer.Character.Gun
				local oh8 = math.random(160,99999)
				local oh9 = false
				local oh10 = true
				local oh11 = Vector3.new(0,0,0)
				local oh12 = 16000
				local oh13 = Vector3.new(0, 0, 0)
				game:GetService("ReplicatedStorage").Events.HitPart:FireServer(oh1, oh2, oh3, oh4, oh5, oh6, oh7, oh8, oh9, oh10, oh11, oh12, oh13)
			end
		end
	end
end)
PlayerSection:AddButton({text = "Refresh List", callback = update})



	MiscSection:AddToggle({text = "Bunny Hop",flag = "bunny_hop",callback = function()
		while library.flags["bunny_hop"] do RunService.RenderStepped:Wait()--wait()
			if IsAlive(LocalPlayer) and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				LocalPlayer.Character.Humanoid.Jump = true
				local speed = library.flags["bhop_speed"]
				local dir = Camera.CFrame.LookVector * Vector3.new(1,0,1)
				local move = Vector3.new()
				move = UserInputService:IsKeyDown(Enum.KeyCode.W) and move + dir or move
				move = UserInputService:IsKeyDown(Enum.KeyCode.S) and move - dir or move
				move = UserInputService:IsKeyDown(Enum.KeyCode.D) and move + Vector3.new(-dir.Z,0,dir.X) or move
				move = UserInputService:IsKeyDown(Enum.KeyCode.A) and move + Vector3.new(dir.Z,0,-dir.X) or move
				if move.Unit.X == move.Unit.X then
					move = move.Unit
					LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(move.X*speed,LocalPlayer.Character.HumanoidRootPart.Velocity.Y,move.Z*speed)
				end
			end
		end
	end})

	MiscSection:AddSlider({text = "Bhop Speed", flag = "bhop_speed", min = 1, max = 50, value = 15})

	local AddonSection = MiscColumn1:AddSection"Addons"
	

	AddonSection:AddButton({text = "Godmode", callback = function()
		pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage");
			local ApplyGun = ReplicatedStorage.Events.ApplyGun;
			ApplyGun:FireServer({
				Model = ReplicatedStorage.Hostage.Hostage,
				Name = "USP"
			}, game.Players.LocalPlayer);
		end)
	end})


	


	AddonSection:AddButton({text = "Crash Server", callback = function()
		crash = true
		while crash == true do
			pcall(function()
				game:GetService("RunService").RenderStepped:Wait()
				for i = 1,100,1 do	
					game:GetService("ReplicatedStorage").Events.DropMag:FireServer(LocalPlayer.Character.Gun.Mag)
				end
			end)
		end  
	end})

	AddonSection:AddButton({text = "Fake RAC Ban", callback = function()
		local time = {

			"20999999",
			"365",
			"2099999811",
			"209999999997",
			"209999999790",
		
		}
		
		local reason = {
		
			"Invalid Weapon",
			"team insta kill",
			"Money Spoofing.",
			"Kill-All.",
			"Stealing Candy!",
		
		}
		
		game.Players.LocalPlayer:Kick("\nYou've Been Banned By: RAC\nFor The Reason of: "..reason[math.random(1,table.getn(reason))].."\n"..time[math.random(1,table.getn(time))].." Days Remaining Until Unban")
	end})


	

AddonSection:AddButton({text = "Unlock Inventory", callback = function()
    if not invunlocked then
        invunlocked = true
        
	local allSkins = {
		{'AK47_Ace'},
		{'AK47_Bloodboom'},
		{'AK47_Clown'},
		{'AK47_Code Orange'},
		{'AK47_Eve'},
		{'AK47_Gifted'},
		{'AK47_Glo'},
		{'AK47_Godess'},
		{'AK47_Hallows'},
		{'AK47_Halo'},
		{'AK47_Hypersonic'},
		{'AK47_Inversion'},
		{'AK47_Jester'},
		{'AK47_Maker'},
		{'AK47_Mean Green'},
		{'AK47_Outlaws'},
		{'AK47_Outrunner'},
		{'AK47_Patch'},
		{'AK47_Plated'},
		{'AK47_Precision'},
		{'AK47_Quantum'},
		{'AK47_Quicktime'},
		{'AK47_Scapter'},
		{'AK47_Secret Santa'},
		{'AK47_Shooting Star'},
		{'AK47_Skin Committee'},
		{'AK47_Survivor'},
		{'AK47_Ugly Sweater'},
		{'AK47_VAV'},
		{'AK47_Variant Camo'},
		{'AK47_Yltude'},
		{'AUG_Chilly Night'},
		{'AUG_Dream Hound'},
		{'AUG_Enlisted'},
		{'AUG_Graffiti'},
		{'AUG_Homestead'},
		{'AUG_Maker'},
		{'AUG_NightHawk'},
		{'AUG_Phoenix'},
		{'AUG_Sunsthetic'},
		{'AWP_Abaddon'},
		{'AWP_Autumness'},
		{'AWP_Blastech'},
		{'AWP_Bloodborne'},
		{'AWP_Coffin Biter'},
		{'AWP_Desert Camo'},
		{'AWP_Difference'},
		{'AWP_Dragon'},
		{'AWP_Forever'},
		{'AWP_Grepkin'},
		{'AWP_Hika'},
		{'AWP_Illusion'},
		{'AWP_Instinct'},
		{'AWP_JTF2'},
		{'AWP_Lunar'},
		{'AWP_Nerf'},
		{'AWP_Northern Lights'},
		{'AWP_Pear Tree'},
		{'AWP_Pink Vision'},
		{'AWP_Pinkie'},
		{'AWP_Quicktime'},
		{'AWP_Racer'},
		{'AWP_Regina'},
		{'AWP_Retroactive'},
		{'AWP_Scapter'},
		{'AWP_Silence'},
		{'AWP_Venomus'},
		{'AWP_Weeb'},
		{'Banana_Stock'},
		{'Bayonet_Aequalis'},
		{'Bayonet_Banner'},
		{'Bayonet_Candy Cane'},
		{'Bayonet_Consumed'},
		{'Bayonet_Cosmos'},
		{'Bayonet_Crimson Tiger'},
		{'Bayonet_Crow'},
		{'Bayonet_Delinquent'},
		{'Bayonet_Digital'},
		{'Bayonet_Easy-Bake'},
		{'Bayonet_Egg Shell'},
		{'Bayonet_Festive'},
		{'Bayonet_Frozen Dream'},
		{'Bayonet_Geo Blade'},
		{'Bayonet_Ghastly'},
		{'Bayonet_Goo'},
		{'Bayonet_Hallows'},
		{'Bayonet_Intertwine'},
		{'Bayonet_Marbleized'},
		{'Bayonet_Mariposa'},
		{'Bayonet_Naval'},
		{'Bayonet_Neonic'},
		{'Bayonet_RSL'},
		{'Bayonet_Racer'},
		{'Bayonet_Sapphire'},
		{'Bayonet_Silent Night'},
		{'Bayonet_Splattered'},
		{'Bayonet_Stock'},
		{'Bayonet_Topaz'},
		{'Bayonet_Tropical'},
		{'Bayonet_Twitch'},
		{'Bayonet_UFO'},
		{'Bayonet_Wetland'},
		{'Bayonet_Worn'},
		{'Bayonet_Wrapped'},
		{'Bearded Axe_Beast'},
		{'Bearded Axe_Splattered'},
		{'Bizon_Autumic'},
		{'Bizon_Festive'},
		{'Bizon_Oblivion'},
		{'Bizon_Saint Nick'},
		{'Bizon_Sergeant'},
		{'Bizon_Shattered'},
		{'Butterfly Knife_Aurora'},
		{'Butterfly Knife_Bloodwidow'},
		{'Butterfly Knife_Consumed'},
		{'Butterfly Knife_Cosmos'},
		{'Butterfly Knife_Crimson Tiger'},
		{'Butterfly Knife_Crippled Fade'},
		{'Butterfly Knife_Digital'},
		{'Butterfly Knife_Egg Shell'},
		{'Butterfly Knife_Freedom'},
		{'Butterfly Knife_Frozen Dream'},
		{'Butterfly Knife_Goo'},
		{'Butterfly Knife_Hallows'},
		{'Butterfly Knife_Icicle'},
		{'Butterfly Knife_Inversion'},
		{'Butterfly Knife_Jade Dream'},
		{'Butterfly Knife_Marbleized'},
		{'Butterfly Knife_Naval'},
		{'Butterfly Knife_Neonic'},
		{'Butterfly Knife_Reaper'},
		{'Butterfly Knife_Ruby'},
		{'Butterfly Knife_Scapter'},
		{'Butterfly Knife_Splattered'},
		{'Butterfly Knife_Stock'},
		{'Butterfly Knife_Topaz'},
		{'Butterfly Knife_Tropical'},
		{'Butterfly Knife_Twitch'},
		{'Butterfly Knife_Wetland'},
		{'Butterfly Knife_White Boss'},
		{'Butterfly Knife_Worn'},
		{'Butterfly Knife_Wrapped'},
		{'CZ_Designed'},
		{'CZ_Festive'},
		{'CZ_Holidays'},
		{'CZ_Lightning'},
		{'CZ_Orange Web'},
		{'CZ_Spectre'},
		{'Cleaver_Spider'},
		{'Cleaver_Splattered'},
		{'DesertEagle_Cold Truth'},
		{'DesertEagle_Cool Blue'},
		{'DesertEagle_DropX'},
		{'DesertEagle_Glittery'},
		{'DesertEagle_Grim'},
		{'DesertEagle_Heat'},
		{'DesertEagle_Honor-bound'},
		{'DesertEagle_Independence'},
		{'DesertEagle_Krystallos'},
		{'DesertEagle_Pumpkin Buster'},
		{'DesertEagle_ROLVe'},
		{'DesertEagle_Cringe'},
		{'DesertEagle_Racer'},
		{'DesertEagle_Scapter'},
		{'DesertEagle_Skin Committee'},
		{'DesertEagle_Survivor'},
		{'DesertEagle_Weeb'},
		{'DesertEagle_Xmas'},
		{'DualBerettas_Carbonized'},
		{'DualBerettas_Dusty Manor'},
		{'DualBerettas_Floral'},
		{'DualBerettas_Hexline'},
		{'DualBerettas_Neon web'},
		{'DualBerettas_Old Fashioned'},
		{'DualBerettas_Xmas'},
		{'Falchion Knife_Bloodwidow'},
		{'Falchion Knife_Chosen'},
		{'Falchion Knife_Coal'},
		{'Falchion Knife_Consumed'},
		{'Falchion Knife_Cosmos'},
		{'Falchion Knife_Crimson Tiger'},
		{'Falchion Knife_Crippled Fade'},
		{'Falchion Knife_Digital'},
		{'Falchion Knife_Egg Shell'},
		{'Falchion Knife_Festive'},
		{'Falchion Knife_Freedom'},
		{'Falchion Knife_Frozen Dream'},
		{'Falchion Knife_Goo'},
		{'Falchion Knife_Hallows'},
		{'Falchion Knife_Inversion'},
		{'Falchion Knife_Late Night'},
		{'Falchion Knife_Marbleized'},
		{'Falchion Knife_Naval'},
		{'Falchion Knife_Neonic'},
		{'Falchion Knife_Racer'},
		{'Falchion Knife_Ruby'},
		{'Falchion Knife_Splattered'},
		{'Falchion Knife_Stock'},
		{'Falchion Knife_Topaz'},
		{'Falchion Knife_Tropical'},
		{'Falchion Knife_Wetland'},
		{'Falchion Knife_Worn'},
		{'Falchion Knife_Wrapped'},
		{'Falchion Knife_Zombie'},
		{'Famas_Abstract'},
		{'Famas_Centipede'},
		{'Famas_Cogged'},
		{'Famas_Goliath'},
		{'Famas_Haunted Forest'},
		{'Famas_KugaX'},
		{'Famas_MK11'},
		{'Famas_Medic'},
		{'Famas_Redux'},
		{'Famas_Shocker'},
		{'Famas_Toxic Rain'},
		{'FiveSeven_Autumn Fade'},
		{'FiveSeven_Danjo'},
		{'FiveSeven_Fluid'},
		{'FiveSeven_Gifted'},
		{'FiveSeven_Midnight Ride'},
		{'FiveSeven_Mr. Anatomy'},
		{'FiveSeven_Stigma'},
		{'FiveSeven_Sub Zero'},
		{'FiveSeven_Summer'},
		{'Flip Knife_Stock'},
		{'G3SG1_Amethyst'},
		{'G3SG1_Autumn'},
		{'G3SG1_Foliage'},
		{'G3SG1_Hex'},
		{'G3SG1_Holly Bound'},
		{'G3SG1_Mahogany'},
		{'Galil_Frosted'},
		{'Galil_Hardware 2'},
		{'Galil_Hardware'},
		{'Galil_Toxicity'},
		{'Galil_Worn'},
		{'Glock_Angler'},
		{'Glock_Anubis'},
		{'Glock_Biotrip'},
		{'Glock_Day Dreamer'},
		{'Glock_Desert Camo'},
		{'Glock_Gravestomper'},
		{'Glock_Midnight Tiger'},
		{'Glock_Money Maker'},
		{'Glock_RSL'},
		{'Glock_Rush'},
		{'Glock_Scapter'},
		{'Glock_Spacedust'},
		{'Glock_Tarnish'},
		{'Glock_Underwater'},
		{'Glock_Wetland'},
		{'Glock_White Sauce'},
		{'Gut Knife_Banner'},
		{'Gut Knife_Bloodwidow'},
		{'Gut Knife_Consumed'},
		{'Gut Knife_Cosmos'},
		{'Gut Knife_Crimson Tiger'},
		{'Gut Knife_Crippled Fade'},
		{'Gut Knife_Digital'},
		{'Gut Knife_Egg Shell'},
		{'Gut Knife_Frozen Dream'},
		{'Gut Knife_Geo Blade'},
		{'Gut Knife_Goo'},
		{'Gut Knife_Hallows'},
		{'Gut Knife_Lurker'},
		{'Gut Knife_Marbleized'},
		{'Gut Knife_Naval'},
		{'Gut Knife_Neonic'},
		{'Gut Knife_Present'},
		{'Gut Knife_Ruby'},
		{'Gut Knife_Rusty'},
		{'Gut Knife_Splattered'},
		{'Gut Knife_Topaz'},
		{'Gut Knife_Tropical'},
		{'Gut Knife_Wetland'},
		{'Gut Knife_Worn'},
		{'Gut Knife_Wrapped'},
		{'Huntsman Knife_Aurora'},
		{'Huntsman Knife_Bloodwidow'},
		{'Huntsman Knife_Consumed'},
		{'Huntsman Knife_Cosmos'},
		{'Huntsman Knife_Cozy'},
		{'Huntsman Knife_Crimson Tiger'},
		{'Huntsman Knife_Crippled Fade'},
		{'Huntsman Knife_Digital'},
		{'Huntsman Knife_Egg Shell'},
		{'Huntsman Knife_Frozen Dream'},
		{'Huntsman Knife_Geo Blade'},
		{'Huntsman Knife_Goo'},
		{'Huntsman Knife_Hallows'},
		{'Huntsman Knife_Honor Fade'},
		{'Huntsman Knife_Marbleized'},
		{'Huntsman Knife_Monster'},
		{'Huntsman Knife_Naval'},
		{'Huntsman Knife_Ruby'},
		{'Huntsman Knife_Splattered'},
		{'Huntsman Knife_Stock'},
		{'Huntsman Knife_Tropical'},
		{'Huntsman Knife_Twitch'},
		{'Huntsman Knife_Wetland'},
		{'Huntsman Knife_Worn'},
		{'Huntsman Knife_Wrapped'},
		{'Karambit_Bloodwidow'},
		{'Karambit_Consumed'},
		{'Karambit_Cosmos'},
		{'Karambit_Crimson Tiger'},
		{'Karambit_Crippled Fade'},
		{'Karambit_Death Wish'},
		{'Karambit_Digital'},
		{'Karambit_Egg Shell'},
		{'Karambit_Festive'},
		{'Karambit_Frozen Dream'},
		{'Karambit_Glossed'},
		{'Karambit_Gold'},
		{'Karambit_Goo'},
		{'Karambit_Hallows'},
		{'Karambit_Jade Dream'},
		{'Karambit_Jester'},
		{'Karambit_Lantern'},
		{'Karambit_Liberty Camo'},
		{'Karambit_Marbleized'},
		{'Karambit_Naval'},
		{'Karambit_Neonic'},
		{'Karambit_Pizza'},
		{'Karambit_Quicktime'},
		{'Karambit_Racer'},
		{'Karambit_Ruby'},
		{'Karambit_Scapter'},
		{'Karambit_Splattered'},
		{'Karambit_Stock'},
		{'Karambit_Topaz'},
		{'Karambit_Tropical'},
		{'Karambit_Twitch'},
		{'Karambit_Wetland'},
		{'Karambit_Worn'},
		{'M249_Aggressor'},
		{'M249_P2020'},
		{'M249_Spooky'},
		{'M249_Wolf'},
		{'M4A1_Animatic'},
		{'M4A1_Burning'},
		{'M4A1_Desert Camo'},
		{'M4A1_Heavens Gate'},
		{'M4A1_Impulse'},
		{'M4A1_Jester'},
		{'M4A1_Lunar'},
		{'M4A1_Necropolis'},
		{'M4A1_Tecnician'},
		{'M4A1_Toucan'},
		{'M4A1_Wastelander'},
		{'M4A4_BOT[S]'},
		{'M4A4_Candyskull'},
		{'M4A4_Delinquent'},
		{'M4A4_Desert Camo'},
		{'M4A4_Devil'},
		{'M4A4_Endline'},
		{'M4A4_Flashy Ride'},
		{'M4A4_Ice Cap'},
		{'M4A4_Jester'},
		{'M4A4_King'},
		{'M4A4_Mistletoe'},
		{'M4A4_Pinkie'},
		{'M4A4_Pinkvision'},
		{'M4A4_Pondside'},
		{'M4A4_Precision'},
		{'M4A4_Quicktime'},
		{'M4A4_Racer'},
		{'M4A4_RayTrack'},
		{'M4A4_Scapter'},
		{'M4A4_Stardust'},
		{'M4A4_Toy Soldier'},
		{'MAC10_Artists Intent'},
		{'MAC10_Blaze'},
		{'MAC10_Golden Rings'},
		{'MAC10_Pimpin'},
		{'MAC10_Skeleboney'},
		{'MAC10_Toxic'},
		{'MAC10_Turbo'},
		{'MAC10_Wetland'},
		{'MAG7_Bombshell'},
		{'MAG7_C4UTION'},
		{'MAG7_Frosty'},
		{'MAG7_Molten'},
		{'MAG7_Outbreak'},
		{'MAG7_Striped'},
		{'MP7_Calaxian'},
		{'MP7_Cogged'},
		{'MP7_Goo'},
		{'MP7_Holiday'},
		{'MP7_Industrial'},
		{'MP7_Reindeer'},
		{'MP7_Silent Ops'},
		{'MP7_Sunshot'},
		{'MP9_Blueroyal'},
		{'MP9_Cob Web'},
		{'MP9_Cookie Man'},
		{'MP9_Decked Halls'},
		{'MP9_SnowTime'},
		{'MP9_Vaporwave'},
		{'MP9_Velvita'},
		{'MP9_Wilderness'},
		{'Negev_Default'},
		{'Negev_Midnightbones'},
		{'Negev_Quazar'},
		{'Negev_Striped'},
		{'Negev_Wetland'},
		{'Negev_Winterfell'},
		{'Nova_Black Ice'},
		{'Nova_Cookie'},
		{'Nova_Paradise'},
		{'Nova_Sharkesh'},
		{'Nova_Starry Night'},
		{'Nova_Terraformer'},
		{'Nova_Tiger'},
		{'P2000_Apathy'},
		{'P2000_Camo Dipped'},
		{'P2000_Candycorn'},
		{'P2000_Comet'},
		{'P2000_Dark Beast'},
		{'P2000_Golden Age'},
		{'P2000_Lunar'},
		{'P2000_Pinkie'},
		{'P2000_Ruby'},
		{'P2000_Silence'},
		{'P250_Amber'},
		{'P250_Bomber'},
		{'P250_Equinox'},
		{'P250_Frosted'},
		{'P250_Goldish'},
		{'P250_Green Web'},
		{'P250_Shark'},
		{'P250_Solstice'},
		{'P250_TC250'},
		{'P90_Demon Within'},
		{'P90_Elegant'},
		{'P90_Krampus'},
		{'P90_Northern Lights'},
		{'P90_P-Chan'},
		{'P90_Pine'},
		{'P90_Redcopy'},
		{'P90_Skulls'},
		{'R8_Exquisite'},
		{'R8_Hunter'},
		{'R8_Spades'},
		{'R8_TG'},
		{'R8_Violet'},
		{'SG_DropX'},
		{'SG_Dummy'},
		{'SG_Kitty Cat'},
		{'SG_Knighthood'},
		{'SG_Magma'},
		{'SG_Variant Camo'},
		{'SG_Yltude'},
		{'SawedOff_Casino'},
		{'SawedOff_Colorboom'},
		{'SawedOff_Executioner'},
		{'SawedOff_Opal'},
		{'SawedOff_Spooky'},
		{'SawedOff_Sullys Blacklight'},
		{'Scout_Coffin Biter'},
		{'Scout_Flowing Mists'},
		{'Scout_Hellborn'},
		{'Scout_Hot Cocoa'},
		{'Scout_Monstruo'},
		{'Scout_Neon Regulation'},
		{'Scout_Posh'},
		{'Scout_Pulse'},
		{'Scout_Railgun'},
		{'Scout_Theory'},
		{'Scout_Xmas'},
		{'Sickle_Mummy'},
		{'Sickle_Splattered'},
		{'Tec9_Charger'},
		{'Tec9_Gift Wrapped'},
		{'Tec9_Ironline'},
		{'Tec9_Performer'},
		{'Tec9_Phol'},
		{'Tec9_Samurai'},
		{'Tec9_Skintech'},
		{'Tec9_Stocking Stuffer'},
		{'UMP_Death Grip'},
		{'UMP_Gum Drop'},
		{'UMP_Magma'},
		{'UMP_Militia Camo'},
		{'UMP_Molten'},
		{'UMP_Redline'},
		{'USP_Crimson'},
		{'USP_Dizzy'},
		{'USP_Frostbite'},
		{'USP_Holiday'},
		{'USP_Jade Dream'},
		{'USP_Kraken'},
		{'USP_Nighttown'},
		{'USP_Paradise'},
		{'USP_Racing'},
		{'USP_Skull'},
		{'USP_Unseen'},
		{'USP_Worlds Away'},
		{'USP_Yellowbelly'},
		{'XM_Artic'},
		{'XM_Atomic'},
		{'XM_Campfire'},
		{'XM_Endless Night'},
		{'XM_MK11'},
		{'XM_Predator'},
		{'XM_Red'},
		{'XM_Spectrum'},
		{'Handwraps_Wraps'},
		{'Sports Glove_Hazard'},
		{'Sports Glove_Hallows'},
		{'Sports Glove_Majesty'},
		{'Strapped Glove_Racer'},
		{'Strapped Glove_Grim'},
		{'Strapped Glove_Wisk'},
		{'Fingerless Glove_Scapter'},
		{'Fingerless Glove_Digital'},
		{'Fingerless Glove_Patch'},
		{'Handwraps_Guts'},
		{'Handwraps_Wetland'},
		{'Strapped Glove_Molten'},
		{'Fingerless Glove_Crystal'},
		{'Sports Glove_Royal'},
		{'Strapped Glove_Kringle'},
		{'Handwraps_MMA'},
		{'Sports Glove_Weeb'},
		{'Sports Glove_CottonTail'},
		{'Sports Glove_RSL'},
		{'Handwraps_Ghoul Hex'},
		{'Handwraps_Phantom Hex'},
		{'Handwraps_Spector Hex'},
		{'Handwraps_Orange Hex'},
		{'Handwraps_Purple Hex'},
		{'Handwraps_Green Hex'},
	 }
	  
	 local isUnlocked
	  
	 local mt = getrawmetatable(game)
	 local oldNamecall = mt.__namecall
	 setreadonly(mt, false)
	  
	 local isUnlocked
	  
	 mt.__namecall = newcclosure(function(self, ...)
		local args = {...}
		if getnamecallmethod() == "InvokeServer" and tostring(self) == "Hugh" then
			return
		end
		if getnamecallmethod() == "FireServer" then
			if args[1] == LocalPlayer.UserId then
				return
			end
			if string.len(tostring(self)) == 38 then
				if not isUnlocked then
					isUnlocked = true
					for i,v in pairs(allSkins) do
						local doSkip
						for i2,v2 in pairs(args[1]) do
							if v[1] == v2[1] then
								doSkip = true
							end
						end
						if not doSkip then
							table.insert(args[1], v)
						end
					end
				end
				return
			end
			if tostring(self) == "DataEvent" and args[1][4] then
				local currentSkin = string.split(args[1][4][1], "_")[2]
				if args[1][2] == "Both" then
					LocalPlayer["SkinFolder"]["CTFolder"][args[1][3]].Value = currentSkin
					LocalPlayer["SkinFolder"]["TFolder"][args[1][3]].Value = currentSkin
				else
					LocalPlayer["SkinFolder"][args[1][2] .. "Folder"][args[1][3]].Value = currentSkin
				end
			end
		end
		return oldNamecall(self, ...)
	 end)
		
	 setreadonly(mt, true)
	  
	 cbClient.CurrentInventory = allSkins
	  
	 local TClone, CTClone = LocalPlayer.SkinFolder.TFolder:Clone(), game.Players.LocalPlayer.SkinFolder.CTFolder:Clone()
	 LocalPlayer.SkinFolder.TFolder:Destroy()
	 LocalPlayer.SkinFolder.CTFolder:Destroy()
	 TClone.Parent = LocalPlayer.SkinFolder
	 CTClone.Parent = LocalPlayer.SkinFolder
	 end
end})


	AddonSection:AddButton({text = "Rejoin Server", callback = function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end})

	
	AddonSection:AddButton({text = "Copy Roblox Game Invite", callback = function()
		setclipboard("Roblox.GameLauncher.joinGameInstance("..game.PlaceId..", '"..game.JobId.."')")
	end})



	getgenv().vainless = {}
	function vainless:AddScript(title, side)
		if side == "left" then
		return LuaColumn1:AddSection(title)
		elseif side == "right" then
		return LuaColumn2:AddSection(title)
		end
	end
	function vainless:AddButton(section1,options)
		return section1:AddButton(options)
	end
	function vainless:AddToggle(section1,options)
		return section1:AddToggle(options)
	end
	function vainless:AddSlider(section1,options)
		return section1:AddSlider(options)
	end
	function vainless:AddList(section1,options)
		return section1:AddList(options)
	end


	makefolder("Vainless/lua")     
	local allluas = {}  

	for _,lua in pairs(listfiles("Vainless/lua")) do  
		local luaname = string.gsub(lua, "Vainless/lua\\", "")  
		table.insert(allluas, luaname)  
	end     

	LuaSection:AddList({text = "Luas", values = allluas})
	LuaSection:AddButton({text = "Run Lua", callback = function()
		loadstring(readfile("Vainless/lua\\"..library.flags["Luas"]))()  
	end})
	LuaSection:AddDivider("Scripts:")






MiscSection:AddList({text = "Teleport Point", flag = "teleportpoint", skipflag = true, values = {"CT Spawn", "T Spawn", "Bombsite A", "Bombsite B"}, callback = function(val)
	if val == "T Spawn" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Map.SpawnPoints["BuyArea"].Position + Vector3.new(0, 3, 0))
    elseif val == "CT Spawn" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Map.SpawnPoints["BuyArea2"].Position + Vector3.new(0, 3, 0))
    elseif val == "Bombsite A" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Map.SpawnPoints["C4Plant2"].Position + Vector3.new(0, 3, 0))
    elseif val == "Bombsite B" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Map.SpawnPoints["C4Plant"].Position + Vector3.new(0, 3, 0))
    end
end})




        library:Init()

        delay(1, function() library:LoadConfig(tostring(getgenv().autoload)) end)
    
        if not getgenv().silent then
            if not Loaded then
                library:SendNotification(5, "Successfully Loaded Vainless")
                end
        end
    
        if not library:GetConfigs()[1] then
            writefile(library.foldername .. "/Default" .. library.fileext, loadstring(game:HttpGet("https://raw.githubusercontent.com/VainIess/Vainless/main/Default.vl", true))())
            library.options["Config List"]:AddValue"Default"
            library:LoadConfig"Default"
        end
