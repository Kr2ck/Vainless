if not syn or not protectgui then
    getgenv().protectgui = function()end
end

if not game.GameId == '115797356' then return end

local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
Library:SetWatermark("Vainless.xyz | Debug")

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

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

local ValidTargetParts = {"Head", "HumanoidRootPart"};

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
    
    local PlayerRoot = FindFirstChild(PlayerCharacter, Options.TargetPart.Value) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    
    if not PlayerRoot then return end 
    
    local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
    
    return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
end

local function getClosestPlayer()
    if not Options.TargetPart.Value then return end
    local Closest
    local DistanceToMouse
    for _, Player in next, GetChildren(Players) do
        if Player == LocalPlayer then continue end
        if Toggles.TeamCheck.Value and Player.Team == LocalPlayer.Team then continue end

        local Character = Player.Character
        if not Character then continue end
        
        if Toggles.VisibleCheck.Value and not IsPlayerVisible(Player) then continue end

        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")

        if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end

        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)

        if not OnScreen then continue end

        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or (Toggles.fov_Enabled.Value and Options.Radius.Value) or 2000) then
            Closest = ((Options.TargetPart.Value == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[Options.TargetPart.Value])
            DistanceToMouse = Distance
        end
    end
    return Closest
end

local Window = Library:CreateWindow({
    Title = 'Vainless.xyz',
    Center = true, 
    AutoShow = true,
})

local LegitTab = Window:AddTab("Legit")
local VisualsTab = Window:AddTab("Visuals")
local MiscTab = Window:AddTab("Misc")
local SettingsTab = Window:AddTab("Settings")
local SABOX1 = LegitTab:AddLeftTabbox()
local SABOX = SABOX1:AddTab("Silent Aim")
do
    SABOX:AddToggle("aim_Enabled", {Text = "Enabled"}):AddKeyPicker('AIMKEY', { Default = 'MB1', Mode = "Hold", NoUI = false, Text = 'Aim Keybind' }) 
    SABOX:AddToggle("TeamCheck", {Text = "Team Check"})
    SABOX:AddToggle("VisibleCheck", {Text = "Visible Check"})
    SABOX:AddDropdown("TargetPart", {Text = "Target Part", Default = 1, Values = {
        "Head", "Random"
    }})
end

local AVISBOX = LegitTab:AddRightTabbox()

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.NumSides = 100
fov_circle.Radius = 180
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 1
fov_circle.Color = Color3.fromRGB(54, 57, 241)

local PredictionAmount = 0.165

do
    local Main = AVISBOX:AddTab("FOV")
    Main:AddToggle("fov_Enabled", {Text = "Enabled"})
    Main:AddSlider("Radius", {Text = "Radius", Min = 0, Max = 360, Default = 180, Rounding = 0}):OnChanged(function()
        fov_circle.Radius = Options.Radius.Value
    end)
    Main:AddToggle("Visible", {Text = "Visible"}):AddColorPicker("Color", {Default = Color3.fromRGB(54, 57, 241)}):OnChanged(function()
        fov_circle.Visible = Toggles.Visible.Value
    end)
end

local cbClient = getsenv(game.Players.LocalPlayer.PlayerGui.Client)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MiscBox1 = MiscTab:AddLeftTabbox()
local MiscBox = MiscBox1:AddTab("Misc")
MiscBox:AddDropdown("Teleport", {Text = "Teleport", Default = "Select", Values = {
    "T Spawn", "CT Spawn", "Bombsite A", "Bombsite B", "Select"
}
}):OnChanged(function()
    if Options.Teleport.Value == "T Spawn" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Map.SpawnPoints["BuyArea"].Position + Vector3.new(0, 3, 0))
        Options.Teleport:SetValue("Select")
    elseif Options.Teleport.Value == "CT Spawn" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Map.SpawnPoints["BuyArea2"].Position + Vector3.new(0, 3, 0))
        Options.Teleport:SetValue("Select")
    elseif Options.Teleport.Value == "Bombsite A" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Map.SpawnPoints["C4Plant2"].Position + Vector3.new(0, 3, 0))
        Options.Teleport:SetValue("Select")
    elseif Options.Teleport.Value == "Bombsite B" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Map.SpawnPoints["C4Plant"].Position + Vector3.new(0, 3, 0))
        Options.Teleport:SetValue("Select")
    end
end)

MiscBox:AddButton("Unlock Inventory", function()
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
end)

MiscBox:AddToggle("AntiVote", {
    Text = "Anti-VoteKick",
    Default = false
})

local Events = ReplicatedStorage.Events
local TeleportService = game:GetService("TeleportService")

ReplicatedStorage.Events.SendMsg.OnClientEvent:Connect(function(message)
	if Toggles.AntiVote.Value == true then
		local msg = string.split(message, " ")
		
		if Players:FindFirstChild(msg[1]) and msg[7] == "2" and msg[12] == LocalPlayer.Name then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end
	end
end)

MiscBox:AddToggle("InfAmmo", {
    Text = "Infinite Ammo",
    Default = false
})

Camera.ChildAdded:Connect(function(new)
	if Toggles.InfAmmo.Value == true then
		cbClient.ammocount = 999999 -- primary ammo
		cbClient.primarystored = 999999 -- primary stored
		cbClient.ammocount2 = 999999 -- secondary ammo
		cbClient.secondarystored = 999999 -- secondary stored
	end
end)

MiscBox:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Default = false
}):OnChanged(function()
    if Toggles.InfJump.Value == true then
		JumpHook = game:GetService("UserInputService").JumpRequest:connect(function()
			game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
		end)
	elseif Toggles.InfJump.Value == false and JumpHook then
		JumpHook:Disconnect()
	end
end)

MiscBox:AddToggle("InfStam", {
    Text = "Infinite Stamina",
    Default = false
}):OnChanged(function()
    if Toggles.InfStam.Value == true then
		RunService:BindToRenderStep("Stamina", 100, function()
			if cbClient.crouchcooldown ~= 0 then
				cbClient.crouchcooldown = 0
			end
		end)
	elseif Toggles.InfStam.Value == false then
		RunService:UnbindFromRenderStep("Stamina")
	end
end)

MiscBox:AddToggle("RemoveKillers", {Text = "Remove Killers", Default = false}):OnChanged(function()
	if Toggles.RemoveKillers.Value == true then
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
end)

local AddonBox = MiscTab:AddRightTabbox()
local Addons = AddonBox:AddTab("Gun Mods")

Addons:AddToggle("RR", {Text = "Remove Recoil"}):OnChanged(function()
    if Toggles.RR.Value == true then
        game:GetService("RunService"):BindToRenderStep("NoRecoil", 100, function()
            cbClient.resetaccuracy()
            cbClient.RecoilX = 0
            cbClient.RecoilY = 0
        end)
    else
        game:GetService("RunService"):UnbindFromRenderStep("NoRecoil")
    end
end)

Addons:AddToggle("NoSpread", {Text = "Remove Spread"})
Addons:AddToggle("FullAuto", {Text = "Full Auto"})
Addons:AddToggle("RapidFire", {Text = "Rapid Fire"})
Addons:AddToggle("InstantReload", {Text = "Instant Reload"})
Addons:AddToggle("InstantEquip", {Text = "Instant Equip"})
Addons:AddToggle("InfPen", {Text = "Infinite Penetration"})
Addons:AddToggle("InfRange", {Text = "Infinite Range"})


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
					if Toggles.InfPen.Value == true then
						Args[2][#Args[2] + 1] = workspace.Map
					end
				end
			end


		return Old_call(self, unpack(Args))
	end)

	MiscBox:AddToggle("Bunny", {
		Text = "Bunny Hop",
		Default = false
	})

	MiscBox:AddSlider("BSpeed", {Text = "Bhop Speed", Min = 1, Max = 30, Default = 8, Rounding = 0})

	local BodyVelocity = Instance.new("BodyVelocity")
	local function YRotation(cframe)
		local x, y, z = cframe:ToOrientation()
		return CFrame.new(cframe.Position) * CFrame.Angles(0,y,0)
	end
	local function XYRotation(cframe)
		local x, y, z = cframe:ToOrientation()
		return CFrame.new(cframe.Position) * CFrame.Angles(x,y,0)
	end
	local BunnyHopDirect = "directional"
    game:GetService("RunService").RenderStepped:Connect(function()
		BodyVelocity:Destroy()
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(math.huge,0,math.huge)
		
		local CamCFrame = Camera.CFrame
			if UserInputService:IsKeyDown("Space") and Toggles.Bunny.Value == true and IsAlive(LocalPlayer) then
				local add = 0
				local Root = LocalPlayer.Character.HumanoidRootPart
				if BunnyHopDirect == "directional" then
					if UserInputService:IsKeyDown("A") then add = 90 end
					if UserInputService:IsKeyDown("S") then add = 190 end
					if UserInputService:IsKeyDown("D") then add = 280 end
					if UserInputService:IsKeyDown("A") and UserInputService:IsKeyDown("W") then add = 55 end
					if UserInputService:IsKeyDown("D") and UserInputService:IsKeyDown("W") then add = 325 end
					if UserInputService:IsKeyDown("D") and UserInputService:IsKeyDown("S") then add = 235 end
					if UserInputService:IsKeyDown("A") and UserInputService:IsKeyDown("S") then add = 155 end
				end
				local rot = YRotation(CamCFrame) * CFrame.Angles(0,math.rad(add),0)
				BodyVelocity.Parent = LocalPlayer.Character.UpperTorso
				LocalPlayer.Character.Humanoid.Jump = true
				BodyVelocity.Velocity = Vector3.new(rot.LookVector.X,0,rot.LookVector.Z) * (Options.BSpeed.Value * 2)
				if add == 0 and BunnyHopDirect == "directional" and not UserInputService:IsKeyDown("W") then
					BodyVelocity:Destroy()
				end
			end
	end)

	MiscBox:AddButton("Godmode", function()
		pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage");
			local ApplyGun = ReplicatedStorage.Events.ApplyGun;
			ApplyGun:FireServer({
				Model = ReplicatedStorage.Hostage.Hostage,
				Name = "USP"
			}, game.Players.LocalPlayer);
		end)
	end)
	


	MiscBox:AddButton("Crash Server", function()
		crash = true
		while crash == true do
			pcall(function()
				game:GetService("RunService").RenderStepped:Wait()
				for i = 1,100,1 do	
					game:GetService("ReplicatedStorage").Events.DropMag:FireServer(LocalPlayer.Character.Gun.Mag)
				end
			end)
		end  
	end)


oldIndex = hookfunc(getrawmetatable(LocalPlayer.PlayerGui.Client).__index, newcclosure(function(self, idx)
	if idx == "Value" then
		if self.Name == "Auto" and Toggles.FullAuto.Value == true then
			return true
		elseif self.Name == "FireRate" and Toggles.RapidFire.Value == true then
			return 0.001
		elseif self.Name == "ReloadTime" and Toggles.InstantReload.Value == true then
			return 0.001
		elseif self.Name == "EquipTime" and Toggles.InstantEquip.Value == true then
			return 0.001
		elseif self.Name == "Penetration" and Toggles.InfPen.Value == true then
			return 99999999999
		elseif self.Name == "Range" and Toggles.InfRange.Value == true then
			return 9999
		elseif self.Name == "RangeModifier" and Toggles.InfRange.Value == true then
			return 100
		elseif (self.Name == "Spread" or self.Parent.Name == "Spread") and Toggles.NoSpread.Value == true then
			return 0
		elseif (self.Name == "AccuracyDivisor" or self.Name == "AccuracyOffset") and Toggles.NoSpread.Value == true then
			return 0.001
        end
    end

    return oldIndex(self, idx)
end))






resume(create(function()
    RenderStepped:Connect(function()
    if Toggles.Visible.Value then 
            fov_circle.Visible = Toggles.Visible.Value
            fov_circle.Color = Options.Color.Value
            fov_circle.Position = getMousePosition() + Vector2.new(0, 36)
        end
    end)
end))

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
    local Arguments = {...}
    local self = Arguments[1]

    local Method = "FindPartOnRayWithIgnoreList"

    if Toggles.aim_Enabled.Value and self == workspace then
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
    return oldNamecall(...)
end)

local Settings = {
	ESP = {
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




local VisBox1 = VisualsTab:AddLeftTabbox()
local VisBox = VisBox1:AddTab("Players")

VisBox:AddToggle("BoxESP", {Text = "Boxes", Default = false}):AddColorPicker("BoxColor", {Text = "Box Color", Default = Color3.fromRGB(255,255,255)})

Options.BoxColor:OnChanged(function()
	BoxColour = Options.BoxColor.Value
end)

Toggles.BoxESP:OnChanged(function()
    Settings.ESP.Box = Toggles.BoxESP.Value
end)

VisBox:AddToggle("ShowNames", {Text = "Show Names", Default = false}):OnChanged(function()
    Settings.ESP.Name = Toggles.ShowNames.Value
end)

VisBox:AddToggle("ShowWeapons", {Text = "Show Weapons", Default = false}):OnChanged(function()
    Settings.ESP.Gun = Toggles.ShowWeapons.Value
end)

VisBox:AddToggle("ChamsOn", {Text = "Chams", Default = false}):AddColorPicker("CColor", {Default = Color3.fromRGB(255,255,255)})

VisBox:AddSlider("Transparency", {Text = "Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 2})

Toggles.ChamsOn:OnChanged(function()
	Settings.ESP.Chams = Toggles.ChamsOn.Value
	if Settings.ESP.Chams == true then
        function chamgui(name,parent,face)
            local SG = Instance.new("SurfaceGui",parent)
            SG.Parent = parent
            SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            SG.Face = Enum.NormalId[face]
            SG.LightInfluence = 0
            SG.ResetOnSpawn = false
            SG.Name = name
            SG.AlwaysOnTop = true
            local Frame = Instance.new("Frame", SG)
            Frame.BackgroundColor3 = Options.CColor.Value
            Frame.Size = UDim2.new(1,0,1,0)
            Frame.Transparency = Options.Transparency.Value
        end
        local players = game:GetService('Players')
        local player = players.LocalPlayer
        while wait(1) do
            for i,v in pairs (game:GetService("Players"):GetPlayers()) do
                if v ~= game:GetService("Players").LocalPlayer and v.Character ~= nil and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("cham") == nil and v.TeamColor ~= player.TeamColor then --Change these later maybe if you want
                    for i,v in pairs (v.Character:GetChildren()) do
                        if v:IsA("MeshPart") or v.Name == "Head" then
                            chamgui("cham",v,"Back")
                            chamgui("cham",v,"Front")
                            chamgui("cham",v,"Left")
                            chamgui("cham",v,"Right")
                            chamgui("cham",v,"Top")
                            chamgui("cham",v,"Bottom")
                        end
                    end
                end
            end
        end

    end
end)




local function amogazenzESP(v)
    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Color = Color3.new(0,0,0)
    BoxOutline.Thickness = 3
    BoxOutline.Transparency = 1
    BoxOutline.Filled = false

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1,1,1)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    local HealthBarOutline = Drawing.new("Square")
    HealthBarOutline.Thickness = 3
    HealthBarOutline.Filled = false
    HealthBarOutline.Color = Color3.new(0,0,0)
    HealthBarOutline.Transparency = 1
    HealthBarOutline.Visible = false

    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = false
    HealthBar.Transparency = 1
    HealthBar.Visible = false

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.new(1,1,1)
    Tracer.Thickness = 1
    Tracer.Transparency = 1

    local Name = Drawing.new("Text")
    Name.Transparency = 1
    Name.Visible = false
    Name.Color = Color3.new(1,1,1)
    Name.Size = 12
    Name.Center = true
    Name.Outline = true


    local Gun = Drawing.new("Text")
    Gun.Transparency = 1
    Gun.Visible = false
    Gun.Color = Color3.new(1,1,1)
    Gun.Size = 12
    Gun.Center = true
    Gun.Outline = true


    game:GetService("RunService").RenderStepped:Connect(function()
        if v.Character ~= nil and v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil and v ~= LocalPlayer and v.Character.Humanoid.Health > 0 then
            local Vector, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Camera.CFrame.p - v.Character.HumanoidRootPart.Position).Magnitude
            local RootPart = v.Character.HumanoidRootPart
            local Head = v.Character.Head
            local RootPosition, RootVis = WorldToViewportPoint(Camera, RootPart.Position)
            local HeadPosition = WorldToViewportPoint(Camera, Head.Position + Vector3.new(0,0.5,0))
            local LegPosition = WorldToViewportPoint(Camera, RootPart.Position - Vector3.new(0,3,0))

            if onScreen then
                if Settings.ESP.Box then
                    BoxOutline.Size = Vector2.new(2500 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                    BoxOutline.Position = Vector2.new(RootPosition.X - BoxOutline.Size.X / 2, RootPosition.Y - BoxOutline.Size.Y / 2)
                    BoxOutline.Visible = true

                    Box.Size = Vector2.new(2500 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                    Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                    Box.Color = BoxColour
                    Box.Visible = true

                    HealthBarOutline.Size = Vector2.new(2, HeadPosition.Y - LegPosition.Y)
                    HealthBarOutline.Position = BoxOutline.Position - Vector2.new(6,0)
                    HealthBarOutline.Visible = true

                    HealthBar.Size = Vector2.new(2, (HeadPosition.Y - LegPosition.Y) / (v.Character.Humanoid.MaxHealth / math.clamp(v.Character.Humanoid.Health, 0,v.Character.Humanoid.MaxHealth)))
                    HealthBar.Position = Vector2.new(Box.Position.X - 6, Box.Position.Y + (1 / HealthBar.Size.Y))
                    HealthBar.Color = Color3.fromRGB(255 - 255 / (v.Character.Humanoid.MaxHealth / v.Character.Humanoid.Health), 255 / (v.Character.Humanoid.MaxHealth / v.Character.Humanoid.Health), 0)
                    HealthBar.Visible = true

                    if v.Team == game.Players.LocalPlayer.Team then
                        HealthBarOutline.Visible = false
                        BoxOutline.Visible = false
                        Box.Visible = false
                        HealthBar.Visible = false
                    end
                else
                    BoxOutline.Visible = false
                    Box.Visible = false
                    HealthBarOutline.Visible = false
                    HealthBar.Visible = false
                end

                if Settings.ESP.Tracers then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1)

                    Tracer.Color = Color3.new(1,1,1)
                    Tracer.To = Vector2.new(Vector.X, Vector.Y)
                    Tracer.Visible = true

                    if v.Team == game.Players.LocalPlayer.Team then
                        Tracer.Visible = false
                    end
                else
                    Tracer.Visible = false
                end
				if Settings.ESP.Gun then 
					Gun.Font = 3
                    Gun.Size = 16
                    Gun.Text = tostring(v.Character.EquippedTool.Value)
                    Gun.Position = Vector2.new(LegPosition.X, LegPosition.Y + 10)
                    Gun.Color = Color3.new(1,1,1)
                    Gun.Visible = true

                    if v.Team == game.Players.LocalPlayer.Team then
                        Gun.Visible = false
                    end
				else
                    Gun.Visible = false
                end

                if Settings.ESP.Name then
                    Name.Text = tostring(v.Name)
                    Name.Position = Vector2.new(workspace.Camera:WorldToViewportPoint(v.Character.Head.Position).X, workspace.Camera:WorldToViewportPoint(v.Character.Head.Position).Y - 30)
                    Name.Visible = true
                    Name.Size = 16
                    Name.Color = Color3.new(1,1,1)
                    Name.Font = 3

                    if v.Team == game.Players.LocalPlayer.Team then
                        Name.Visible = false
                    end
                else
                    Name.Visible = false
                end
            else
                BoxOutline.Visible = false
                Box.Visible = false
                HealthBarOutline.Visible = false
                HealthBar.Visible = false
                Tracer.Visible = false
                Name.Visible = false
                Gun.Visible = false
            end
        else
            BoxOutline.Visible = false
            Box.Visible = false
            HealthBarOutline.Visible = false
            HealthBar.Visible = false
            Tracer.Visible = false
            Name.Visible = false
            Gun.Visible = false
        end
    end)
end
for i,v in pairs(game.Players:GetChildren()) do
    amogazenzESP(v)
end

game.Players.PlayerAdded:Connect(function(v)
    amogazenzESP(v)
end)



local ViewmodelBox = VisualsTab:AddLeftTabbox()
local VBox = ViewmodelBox:AddTab("Viewmodel")
local ViewmodelOffset

VBox:AddToggle("ViewOn", {Text = "Enable Viewmodel", Default = false}):OnChanged(function()
ViewmodelEnabled = Toggles.ViewOn.Value
end)

VBox:AddSlider("XView", {Text = "Viewmodel X", Default = 0, Min = 0, Max = 360, Rounding = 0}):OnChanged(function()
	ViewmodelX = Options.XView.Value
end)

VBox:AddSlider("YView", {Text = "Viewmodel Y", Default = 0, Min = 0, Max = 360, Rounding = 0}):OnChanged(function()
	ViewmodelY = Options.YView.Value
end)

VBox:AddSlider("ZView", {Text = "Viewmodel Z", Default = 0, Min = 0, Max = 360, Rounding = 0}):OnChanged(function()
	ViewmodelZ = Options.ZView.Value
end)

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)


mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local callingscript = getcallingscript()
    local args = {...}
	
	if not checkcaller() then
		if method == "SetPrimaryPartCFrame" and self.Name == "Arms" and ViewmodelEnabled == true then
			args[1] = args[1] * CFrame.new(Vector3.new(math.rad(ViewmodelX-180), math.rad(ViewmodelY-180), math.rad(ViewmodelZ-180)))
		end
	end
    
    return oldNamecall(self, unpack(args))
end)






local VissBox1 = VisualsTab:AddRightTabbox()
local VissBox = VissBox1:AddTab("Visuals")

VissBox:AddToggle("NoFlash", {Text = "Remove Flash", Default = false}):OnChanged(function()
	if Toggles.NoFlash.Value == true then
		game.Players.LocalPlayer.PlayerGui.Blnd.Enabled = false
else
game.Players.LocalPlayer.PlayerGui.Blnd.Enabled = true
end
end)

VissBox:AddToggle("NoSmoke", {Text = "Remove Smoke", Default = false}):OnChanged(function()
	if Toggles.NoSmoke.Value == true then
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
end)

VissBox:AddToggle("RemoveScope", {Text = "Remove Scope", Default = false}):OnChanged(function()
	if Toggles.RemoveScope.Value == true then
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
end)

VissBox:AddToggle("ForceCH", {Text = "Force CrossHair", Default = false})

oldNewIndex = hookfunc(getrawmetatable(game.Players.LocalPlayer.PlayerGui.Client).__newindex, newcclosure(function(self, idx, val)
	if not checkcaller() then
			if self.Name == "Crosshair" and idx == "Visible" and val == false and LocalPlayer.PlayerGui.GUI.Crosshairs.Scope.Visible == false and Toggles.ForceCH.Value == true then
			val = true
	end
	end
    return oldNewIndex(self, idx, val)
end))


--keybind enabled function
local function KeybindsVisible(value)
	if value == true then
		Library.KeybindFrame.Visible = true
	else
		Library.KeybindFrame.Visible = false
	end
end

KeybindsVisible(false)

Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = SettingsTab:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Insert', NoUI = true, Text = 'Menu keybind' }) 
MenuGroup:AddToggle('MarkEnabled', { Default = true, Text = 'Watermark' }):OnChanged(function()
    Library.SetWatermarkVisibility = Toggles.MarkEnabled.Value
end)
MenuGroup:AddToggle('ListEnabled', { Text = 'Keybind List', Default = false }):OnChanged(function()
	KeybindsVisible(Toggles.ListEnabled.Value)
end)

Library.ToggleKeybind = Options.MenuKeybind 

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

ThemeManager:SetFolder('Vainless/Themes')
SaveManager:SetFolder('Vainless/CBRO')

SaveManager:BuildConfigSection(SettingsTab) 

ThemeManager:ApplyToTab(SettingsTab)
