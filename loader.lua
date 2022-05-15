local loader = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local Frame_2 = Instance.new("Frame")
local TextLabel_2 = Instance.new("TextLabel")
local UIGradient = Instance.new("UIGradient")
local TextButton = Instance.new("TextButton")
local Frame_3 = Instance.new("Frame")
local TextLabel_3 = Instance.new("TextLabel")
local UIGradient_2 = Instance.new("UIGradient")
local TextButton_2 = Instance.new("TextButton")
local Frame_4 = Instance.new("Frame")
local TextLabel_4 = Instance.new("TextLabel")
local TextLabel_5 = Instance.new("TextLabel")
local TextLabel_6 = Instance.new("TextLabel")
local TextLabel_7 = Instance.new("TextLabel")
local ImageLabel = Instance.new("ImageLabel")
local Frame_5 = Instance.new("Frame")
local TextLabel_8 = Instance.new("TextLabel")

loader.Name = "loader"
loader.Parent = game.CoreGui
loader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = loader
Frame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
Frame.BorderColor3 = Color3.fromRGB(114, 171, 255)
Frame.BorderSizePixel = 2
Frame.Position = UDim2.new(0.335703015, 0, 0.328257203, 0)
Frame.Size = UDim2.new(0, 446, 0, 245)

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(47, 47, 47)
TextLabel.BorderColor3 = Color3.fromRGB(114, 171, 255)
TextLabel.BorderSizePixel = 2
TextLabel.Position = UDim2.new(0.0212728046, 0, 0.0277655162, 0)
TextLabel.Size = UDim2.new(0, 428, 0, 21)
TextLabel.Font = Enum.Font.Code
TextLabel.Text = "Vainless.xyz Loader $$$"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 14.000

Frame_2.Parent = Frame
Frame_2.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
Frame_2.BorderColor3 = Color3.fromRGB(114, 171, 255)
Frame_2.BorderSizePixel = 0
Frame_2.Position = UDim2.new(0.0593893975, 0, 0.73106724, 0)
Frame_2.Size = UDim2.new(0, 384, 0, 53)

TextLabel_2.Parent = Frame_2
TextLabel_2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel_2.Position = UDim2.new(0.0312499963, 0, 0.150943398, 0)
TextLabel_2.Size = UDim2.new(0.467944294, -12, 0.339622647, 18)
TextLabel_2.Font = Enum.Font.Code
TextLabel_2.Text = "Load"
TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.TextSize = 14.000

UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(90, 90, 90)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
UIGradient.Parent = TextLabel_2

TextButton.Parent = TextLabel_2
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BackgroundTransparency = 1.000
TextButton.Size = UDim2.new(0, 167, 0, 36)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = ""
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextSize = 14.000

Frame_3.Parent = Frame_2
Frame_3.BackgroundColor3 = Color3.fromRGB(114, 171, 255)
Frame_3.BackgroundTransparency = -0.010
Frame_3.BorderColor3 = Color3.fromRGB(114, 171, 255)
Frame_3.Size = UDim2.new(0, 384, 0, 0)

TextLabel_3.Parent = Frame_2
TextLabel_3.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel_3.Position = UDim2.new(0.53124994, 0, 0.150943398, 0)
TextLabel_3.Size = UDim2.new(0.467944294, -12, 0.339622647, 18)
TextLabel_3.Font = Enum.Font.Code
TextLabel_3.Text = "Exit"
TextLabel_3.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_3.TextSize = 14.000

UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(90, 90, 90)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
UIGradient_2.Parent = TextLabel_3

TextButton_2.Parent = TextLabel_3
TextButton_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton_2.BackgroundTransparency = 1.000
TextButton_2.Size = UDim2.new(0, 167, 0, 36)
TextButton_2.Font = Enum.Font.SourceSans
TextButton_2.Text = ""
TextButton_2.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton_2.TextSize = 14.000

Frame_4.Parent = Frame
Frame_4.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
Frame_4.BorderColor3 = Color3.fromRGB(114, 171, 255)
Frame_4.BorderSizePixel = 0
Frame_4.Position = UDim2.new(0.0459364802, 0, 0.159638628, 0)
Frame_4.Size = UDim2.new(0, 407, 0, 128)

TextLabel_4.Parent = Frame_4
TextLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_4.BackgroundTransparency = 1.000
TextLabel_4.Position = UDim2.new(0.284634769, 0, 0.3828125, 0)
TextLabel_4.Size = UDim2.new(0, 139, 0, 28)
TextLabel_4.Font = Enum.Font.Code
TextLabel_4.Text = "Game: Counter Blox"
TextLabel_4.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_4.TextSize = 14.000

TextLabel_5.Parent = Frame_4
TextLabel_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_5.BackgroundTransparency = 1.000
TextLabel_5.Position = UDim2.new(0.284634769, 0, 0.539062381, 0)
TextLabel_5.Size = UDim2.new(0, 97, 0, 28)
TextLabel_5.Font = Enum.Font.Code
TextLabel_5.Text = "Version: 0.1"
TextLabel_5.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_5.TextSize = 14.000

TextLabel_6.Parent = Frame_4
TextLabel_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_6.BackgroundTransparency = 1.000
TextLabel_6.Position = UDim2.new(0.301833689, 0, 0.7109375, 0)
TextLabel_6.Size = UDim2.new(0, 188, 0, 28)
TextLabel_6.Font = Enum.Font.Code
TextLabel_6.Text = "Updated on: 5/15/2022"
TextLabel_6.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_6.TextSize = 14.000
TextLabel_6.TextXAlignment = Enum.TextXAlignment.Left

TextLabel_7.Parent = Frame_4
TextLabel_7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_7.BackgroundTransparency = 1.000
TextLabel_7.Position = UDim2.new(0.284634769, 0, 0.21875, 0)
TextLabel_7.Size = UDim2.new(0, 200, 0, 28)
TextLabel_7.Font = Enum.Font.Code
TextLabel_7.Text = "Welcome to Vainless, "..game.Players.LocalPlayer.Name.."!"
TextLabel_7.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_7.TextSize = 14.000

ImageLabel.Parent = Frame_4
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.Position = UDim2.new(0.01511335, 0, 0.225027561, 0)
ImageLabel.Size = UDim2.new(0, 100, 0, 91)
ImageLabel.Image = "rbxassetid://7885626884"

Frame_5.Parent = Frame_4
Frame_5.BackgroundColor3 = Color3.fromRGB(114, 171, 255)
Frame_5.BackgroundTransparency = -0.010
Frame_5.BorderColor3 = Color3.fromRGB(114, 171, 255)
Frame_5.Position = UDim2.new(0, 0, -1.1920929e-07, 0)
Frame_5.Size = UDim2.new(0, 407, 0, 0)

TextLabel_8.Parent = Frame_4
TextLabel_8.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_8.BackgroundTransparency = 1.000
TextLabel_8.Position = UDim2.new(-0.0277078077, 0, -0.0562224165, 0)
TextLabel_8.Size = UDim2.new(0, 62, 0, 36)
TextLabel_8.Font = Enum.Font.Code
TextLabel_8.Text = "Info"
TextLabel_8.TextColor3 = Color3.fromRGB(206, 206, 206)
TextLabel_8.TextSize = 14.000


local function load_script()
	local script = Instance.new('LocalScript', TextButton)

	local button = script.Parent
	
	local function onButtonActivated()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/VainIess/Vainless/main/src.lua'))()
		Frame:Destroy()
	end
	
	button.Activated:Connect(onButtonActivated)
end
coroutine.wrap(load_script)()

local function exit_script()
	local script = Instance.new('LocalScript', TextButton_2)

	local button = script.Parent
	
	local function onButtonActivated()
		Frame:Destroy()
	end
	
	button.Activated:Connect(onButtonActivated)
end
coroutine.wrap(exit_script)()
