local loader = Instance.new("ScreenGui")
local main = Instance.new("Frame")
local titleframe = Instance.new("Frame")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local mainframe = Instance.new("Frame")
local welcome = Instance.new("TextLabel")
local desc = Instance.new("TextLabel")
local gamelabel = Instance.new("TextLabel")
local build = Instance.new("TextLabel")
local loadbutton = Instance.new("TextButton")

loader.Name = "loader"
loader.Parent = game.CoreGui
loader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

main.Name = "main"
main.Parent = loader
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderColor3 = Color3.fromRGB(255, 255, 255)
main.BorderSizePixel = 2
main.Position = UDim2.new(0.387045801, 0, 0.394247055, 0)
main.Size = UDim2.new(0, 429, 0, 223)

titleframe.Name = "titleframe"
titleframe.Parent = main
titleframe.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleframe.BorderColor3 = Color3.fromRGB(255, 255, 255)
titleframe.BorderSizePixel = 2
titleframe.Position = UDim2.new(0, 0, -0.134529144, 0)
titleframe.Size = UDim2.new(0, 429, 0, 21)

Frame.Parent = titleframe
Frame.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
Frame.Position = UDim2.new(0.0209790207, 0, 0.142857149, 0)
Frame.Size = UDim2.new(0, 411, 0, 15)

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.Position = UDim2.new(0.255474448, 0, -1.20000005, 0)
TextLabel.Size = UDim2.new(0, 200, 0, 50)
TextLabel.Font = Enum.Font.Code
TextLabel.Text = "Vainless.xyz Loader $$$"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 14.000

mainframe.Name = "mainframe"
mainframe.Parent = main
mainframe.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
mainframe.Position = UDim2.new(0.0209790207, 0, 0.0531710647, 0)
mainframe.Size = UDim2.new(0, 411, 0, 200)

welcome.Name = "welcome"
welcome.Parent = mainframe
welcome.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
welcome.BackgroundTransparency = 1.000
welcome.Position = UDim2.new(0.255474448, 0, -0.0600000024, 0)
welcome.Size = UDim2.new(0, 208, 0, 72)
welcome.Font = Enum.Font.Code
welcome.Text = "Welcome To Vainless!"
welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
welcome.TextSize = 30.000

desc.Name = "desc"
desc.Parent = mainframe
desc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
desc.BackgroundTransparency = 1.000
desc.Position = UDim2.new(0.248175174, 0, 0.099999994, 0)
desc.Size = UDim2.new(0, 208, 0, 72)
desc.Font = Enum.Font.Code
desc.Text = "A Legit-Based Counter Blox Script"
desc.TextColor3 = Color3.fromRGB(255, 255, 255)
desc.TextSize = 20.000

gamelabel.Name = "gamelabel"
gamelabel.Parent = mainframe
gamelabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gamelabel.BackgroundTransparency = 1.000
gamelabel.Position = UDim2.new(0.255474448, 0, 0.460000008, 0)
gamelabel.Size = UDim2.new(0, 208, 0, 44)
gamelabel.Font = Enum.Font.Code
gamelabel.Text = "Game: Counter Blox"
gamelabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gamelabel.TextSize = 20.000

build.Name = "build"
build.Parent = mainframe
build.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
build.BackgroundTransparency = 1.000
build.Position = UDim2.new(0.255474448, 0, 0.594999969, 0)
build.Size = UDim2.new(0, 208, 0, 44)
build.Font = Enum.Font.Code
build.Text = "Build Version: Beta 0.1"
build.TextColor3 = Color3.fromRGB(255, 255, 255)
build.TextSize = 20.000

loadbutton.Name = "loadbutton"
loadbutton.Parent = mainframe
loadbutton.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
loadbutton.BorderColor3 = Color3.fromRGB(255, 255, 255)
loadbutton.BorderSizePixel = 2
loadbutton.Position = UDim2.new(0.0291970801, 0, 0.814999998, 0)
loadbutton.Size = UDim2.new(0, 389, 0, 31)
loadbutton.Font = Enum.Font.Code
loadbutton.Text = "Load"
loadbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
loadbutton.TextSize = 20.000

local function load_script()
	local script = Instance.new('LocalScript', loadbutton)

	local button = script.Parent
	
	local function onButtonActivated()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/VainIess/Vainless/main/src.lua'))()
		main:Destroy()
	end
	
	button.Activated:Connect(onButtonActivated)
end
coroutine.wrap(load_script)()
