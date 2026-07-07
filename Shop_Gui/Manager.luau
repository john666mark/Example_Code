local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStore = require(ReplicatedStorage.Shared.DataStore).client
local DevProduct_Data = require(ReplicatedStorage.Shared.Data.DevProduct_Data)
local Gifting_Controller = require(script.Parent.Gifting_Controller)
local Rainbow2 = require(ReplicatedStorage.Shared.Utils.EasyVisuell_Folder.GradientTemplate_Folder.Rainbow2)
local Open_Gui_Animations = require(ReplicatedStorage.Shared.GUI_TweenModule_Folder.Open_Gui_Animations)
local Rarity_ColorModule =
	require(ReplicatedStorage.Shared.GUI_TweenModule_Folder.Rarity_Module_Folder.Rarity_ColorModule)
local EasyVisuals = require(ReplicatedStorage.Shared.Utils.EasyVisuell_Folder.EasyVisuals)
local Shine_EffectHandler = require(ReplicatedStorage.Shared.Utils.Shine_EffectHandler)
local UI_FloatingAnim = require(ReplicatedStorage.Shared.Utils.UI_FloatingAnim)
local PlayerGift_Class = require(script.Parent.PlayerGift_Class)
local RobuxBuyButton = require(script.Parent.RobuxBuyButton)
local ShopGUI_Refs = require(script.Parent.ShopGUI_Refs) -- GuiRefs
local Player = Players.LocalPlayer

warn(ShopGUI_Refs, " <-- |Shop Gui Refs|")

----------[ Data ]----------

local Shop_Items = {
	{ Ref = ShopGUI_Refs.Health_Luck.Health, ProductId = 3606726820 },
	{ Ref = ShopGUI_Refs.Health_Luck.Luck, ProductId = 3606726952 },
	{ Ref = ShopGUI_Refs.Money_Vip.Money, ProductId = 3606726045 },
	{ Ref = ShopGUI_Refs.Money_Vip.VIP, ProductId = 3606726615 },
	{ Ref = ShopGUI_Refs.Moneys.Money1, ProductId = 3606727107 },
	{ Ref = ShopGUI_Refs.Moneys.Money2, ProductId = 3607004026 },
	{ Ref = ShopGUI_Refs.Moneys.Money3, ProductId = 3607004091 },
	{ Ref = ShopGUI_Refs.Moneys.Money4, ProductId = 3607004162 },
}

local StarterBundle_ProductId = 3606723218
local StarterBundle_SubParts = {
	ShopGUI_Refs.StarterBundle.Aura,
	ShopGUI_Refs.StarterBundle.Money,
	ShopGUI_Refs.StarterBundle.Sword,
}

----------[ State ]----------

DataStore:waitForData()
local Open_Signal = Open_Gui_Animations.Signals.Shop_Container
local FloatingClass = UI_FloatingAnim.new()
local ShineHandlerClass = Shine_EffectHandler.new()
local EZV_Connections = {}
local Tween_Connections = {}
local Shop_Manager = {}
local Classes = {
	["BuyButtonClasses"] = {},
	["GiftButtonClasses"] = {},
}

----------[ Helpers ]----------

local function Setup_IconStarburst(Icon: GuiObject, Starburst: GuiObject, OffsetIndex: number, Config)
	local Offset = UI_FloatingAnim.GenerateOffset(OffsetIndex)
	FloatingClass:Add({ Icon }, Config, Offset)
	FloatingClass:Add({ Starburst }, Config, Offset, true)

	local RotTweenConn = Rarity_ColorModule:Apply_InfRotation_With_Refrence(Starburst, 20)
	Tween_Connections[Starburst] = RotTweenConn
end

local function Setup_TitelGroup(Titel1: TextLabel, Titel2: TextLabel, Config)
	local Titel_Clone = Titel1:Clone()
	Titel_Clone.Parent = Titel1.Parent
	local Stroke = Titel_Clone:FindFirstChildWhichIsA("UIStroke")
	if Stroke then
		Stroke:Destroy()
	end

	ShineHandlerClass:Add({ Titel_Clone })
	ShineHandlerClass:SetOffset(Titel_Clone, 0, -1)

	local Offset = UI_FloatingAnim.GenerateOffset()
	FloatingClass:Add({ Titel1, Titel2 }, Config, Offset)
end

----------[ Main ]----------

function Shop_Manager:_Setup_animations()
	local Config = FloatingClass.Configs.Smooth
	local Config2 = FloatingClass.Configs.Wobble_Light

	local Buttons_ToAnimate = { ShopGUI_Refs.Header.XButton }
	for i, Item in Shop_Items do
		table.insert(Buttons_ToAnimate, Item.Ref.Gift_Button)
		local Ref = Item.Ref

		Setup_IconStarburst(Ref.Icon, Ref.Starburst, i + 1, Config)
		Setup_TitelGroup(Ref.Titel1, Ref.Titel2, Config2)

		Classes.BuyButtonClasses[Item.ProductId] = RobuxBuyButton.new(Ref.Buy_Button, Item.ProductId, Player)
		Classes.GiftButtonClasses[Item.ProductId] = PlayerGift_Class.new(Ref.Gift_Button, Item.ProductId)
	end
	Open_Gui_Animations:Apply_ButtonAnimation_on_Table(Buttons_ToAnimate)

	Setup_IconStarburst(ShopGUI_Refs.Header.Icon, ShopGUI_Refs.Header.Starburst, 1, Config)
	Setup_TitelGroup(ShopGUI_Refs.Header.TextLabel1, ShopGUI_Refs.Header.TextLabel2, Config2)
	Setup_TitelGroup(ShopGUI_Refs.StarterBundle.Titel1, ShopGUI_Refs.StarterBundle.Titel2, Config2)

	for i, SubPart in StarterBundle_SubParts do
		Setup_IconStarburst(SubPart.Icon, SubPart.Starburst, #Shop_Items + 1 + i, Config)
		Setup_TitelGroup(SubPart.Titel1, SubPart.Titel2, Config2)
	end

	Classes.BuyButtonClasses[StarterBundle_ProductId] =
		RobuxBuyButton.new(ShopGUI_Refs.StarterBundle.Buy_Button, StarterBundle_ProductId, Player)
	Classes.GiftButtonClasses[StarterBundle_ProductId] =
		PlayerGift_Class.new(ShopGUI_Refs.StarterBundle.Gift_Button, StarterBundle_ProductId)

	-- Rainbow Header --

	local New_Gradient = Rainbow2() :: UIGradient
	local ROTATION = -5
	local ACC = 1
	local ACC_OFFSET = -0.15

	local Background_Gradient = EasyVisuals.Gradient.new(ShopGUI_Refs.Header.Root, New_Gradient.Color, 0)
	Background_Gradient:SetRotation(ROTATION, 1)
	Background_Gradient:SetOffsetSpeed(ACC_OFFSET, ACC)

	EZV_Connections[ShopGUI_Refs.Header.Root] = Background_Gradient
end

function Shop_Manager:Init()
	self:_Setup_animations()
end

Shop_Manager:Init()

----------[ Signals ]----------

Open_Signal:Connect(function(Open: boolean)
	if Open then
		Gifting_Controller.Connect_Springs()
		PlayerGift_Class.Connect_Springs()
		FloatingClass:Start()
		ShineHandlerClass:Start()
		Rarity_ColorModule:Resume_EZV(EZV_Connections)
		Rarity_ColorModule:Resume_InfRotation(Tween_Connections)
	else
		Gifting_Controller.Disconnect_Springs()
		PlayerGift_Class.Disconnect_Springs()
		FloatingClass:Stop()
		ShineHandlerClass:Stop()
		Rarity_ColorModule:Pause_EZV(EZV_Connections)
		Rarity_ColorModule:Pause_InfRotation(Tween_Connections)
	end
end)

DataStore:getIndexChangedSignal({ "DevProduckts" }):Connect(function(ProducktID, NewValue)
	local Prod_Data = DevProduct_Data[ProducktID]
	if not Prod_Data then
		return
	end

	if Prod_Data.repeatable then
		return
	end

	local Buy_ButtonClass = Classes.BuyButtonClasses[ProducktID]
	if not Buy_ButtonClass then
		return
	end

	Buy_ButtonClass:ChangeRobux_Text("Owned")
end)

return Shop_Manager
