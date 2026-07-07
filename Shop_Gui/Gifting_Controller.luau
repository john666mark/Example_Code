local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local DevProduct_Data = require(ReplicatedStorage.Shared.Data.DevProduct_Data)
local Open_Gui_Animations = require(ReplicatedStorage.Shared.GUI_TweenModule_Folder.Open_Gui_Animations)
local Number_Format = require(ReplicatedStorage.Shared.Utils.Number_Format)
local Gift_UIRefs = require(script.Parent.Gift_UIRefs)
local PlayerGiftCard_Class = require(script.Parent.PlayerGiftCard_Class)
local PlayerGift_Class = require(script.Parent.PlayerGift_Class)
local Spring = require(ReplicatedStorage.Shared.Utils.Spring)

local PlayerGiftCard_Template = ReplicatedStorage:WaitForChild("Assets")
	:WaitForChild("Gui")
	:WaitForChild("BluePrints")
	:WaitForChild("PlayerGiftCard_Template")

local PopUp_GUI_Screen = PlayerGui:WaitForChild("PopUp_GUI_Screen")
local Shop_Container = PopUp_GUI_Screen:WaitForChild("Shop_Container")
local InnerContainer = Shop_Container:WaitForChild("InnerContainer")
local GiftingContainer = Gift_UIRefs.Root

----------[ ShowcasePlayerData ]----------

local ShowcasePlayerData = {
	651972115, -- vns
	1798347881, --Astra
	226026806, -- lance
	9065833342, -- Auva
	2268550872, --David
	72621170, -- Zaja
	4307463775, --Angel
	447292829, -- Gokkan
	1864738177, -- silver
	1330398284, -- Uno
	2597128291, -- K
	10730988495, -- Go Brother
	4393737048, -- Daryl
	1044032395, -- Windwolf
	98428299, -- sloth
	2800094276, --Luci
	2320752109, -- Baran
	1009599947, -- Dyno
}

----------[ Constants ]----------

local AKTIV_PRODUCKT_ID = nil :: number?
local NUMBERVALUE_INSTANCE = Instance.new("NumberValue")
local TWEENIFO_NUM = TweenInfo.new(0.25, Enum.EasingStyle.Exponential)

----------[ Setup_Springs ]----------

local GIFTINGPOS_SPRING = Spring.new(Vector2.new(InnerContainer.Size.X.Scale - GiftingContainer.Size.X.Scale, 0.5))
GIFTINGPOS_SPRING.Damper = 0.6
GIFTINGPOS_SPRING.Speed = 17.5

local GIFTING_TRANSPARENCY_SPRING = Spring.new(1)
GIFTING_TRANSPARENCY_SPRING.Damper = 0.85
GIFTING_TRANSPARENCY_SPRING.Speed = 17.5

local GIFTING_ROTATION_SPRING = Spring.new(-20)
GIFTING_ROTATION_SPRING.Damper = 0.75
GIFTING_ROTATION_SPRING.Speed = 17.5

local SHOPPOS_SPRING = Spring.new(Vector2.new(0.5, 0.5))
SHOPPOS_SPRING.Damper = 0.6
SHOPPOS_SPRING.Speed = 17.5

local SpringTBL = {
	["Position_GiftingContainer"] = {
		Spring = GIFTINGPOS_SPRING,
		CallBack = function()
			GiftingContainer.Position = UDim2.fromScale(GIFTINGPOS_SPRING.Position.X, GIFTINGPOS_SPRING.Position.Y)
		end,
	},
	["Transparency_GiftingContainer"] = {
		Spring = GIFTING_TRANSPARENCY_SPRING,
		CallBack = function()
			GiftingContainer.GroupTransparency = GIFTING_TRANSPARENCY_SPRING.Position
		end,
	},
	["Rotation_GiftingContainer"] = {
		Spring = GIFTING_ROTATION_SPRING,
		CallBack = function()
			GiftingContainer.Rotation = GIFTING_ROTATION_SPRING.Position
		end,
	},
	["Position_InnerContainer"] = {
		Spring = SHOPPOS_SPRING,
		CallBack = function()
			InnerContainer.Position = UDim2.fromScale(SHOPPOS_SPRING.Position.X, SHOPPOS_SPRING.Position.Y)
		end,
	},
}

----------[ Helpers ]----------

local function Reposition_Shop(Aktiv: boolean): Vector2
	if not Aktiv then
		return Vector2.new(0.5, 0.5)
	end

	local New_X_Pos = (Shop_Container.Size.X.Scale + (GiftingContainer.Size.X.Scale - 1.015))
		+ Shop_Container.AnchorPoint.X

	return Vector2.new(New_X_Pos, 0.5)
end

function Create_PlayerGiftCardClass(Player: Player?)
	if Player == LocalPlayer then
		return
	end

	local Template = PlayerGiftCard_Template:Clone()
	Template.Parent = Gift_UIRefs.ScrollingFrame
	local GiftCard_Class = PlayerGiftCard_Class.new(Template, Player, AKTIV_PRODUCKT_ID)

	return GiftCard_Class
end

----------[ Main ]----------

local Gifting_Controller = {}

function Gifting_Controller:_ConnectClosingAnimation()
	local XButton = Gift_UIRefs.Header.XButton

	Open_Gui_Animations:Apply_Animation_On_Button(XButton)

	XButton.MouseButton1Up:Connect(function()
		PlayerGift_Class.OpenSignal:Fire(false)
	end)
end

function Gifting_Controller:_Init()
	self:_ConnectClosingAnimation()
end

Gifting_Controller:_Init() -- init Module

----------[ RUNSERVISE Connections ]----------

local RunnserviseConnection = nil :: RBXScriptConnection?

function Gifting_Controller.Connect_Springs()
	if RunnserviseConnection then
		RunnserviseConnection:Disconnect()
	end

	RunnserviseConnection = RunService.RenderStepped:Connect(function(DT)
		for _, SpringData in pairs(SpringTBL) do
			SpringData.CallBack()
		end
	end)
end

function Gifting_Controller.Disconnect_Springs()
	if RunnserviseConnection then
		RunnserviseConnection:Disconnect()
	end
end

----------[ Player Managment ]----------

Gifting_Controller.Classes = {} -- saves Players GiftClass

for _, Player: Player in pairs(Players:GetPlayers()) do
	task.spawn(function()
		local GiftCard_Class = Create_PlayerGiftCardClass(Player)
		Gifting_Controller.Classes[Player] = GiftCard_Class
	end)
end

for _, UserID: number in pairs(ShowcasePlayerData) do
	task.spawn(function()
		local GiftCard_Class = Create_PlayerGiftCardClass()

		GiftCard_Class:Set_TargetPlayerID(UserID)
		GiftCard_Class:Update_gui()
		Gifting_Controller.Classes[UserID] = GiftCard_Class
	end)
end

Players.PlayerAdded:Connect(function(Player)
	local GiftCard_Class = Create_PlayerGiftCardClass(Player)
	Gifting_Controller.Classes[Player] = GiftCard_Class
end)

Players.PlayerRemoving:Connect(function(Player)
	local GiftCard_Class = Gifting_Controller.Classes[Player]
	if not GiftCard_Class then
		return
	end

	if GiftCard_Class.Destroy then
		warn("Destroy")
		GiftCard_Class:Destroy()
	end
end)

----------[ Signals ]----------

PlayerGift_Class.OpenSignal:Connect(function(Aktiv: boolean)
	if Aktiv then
		GIFTINGPOS_SPRING.Target = Vector2.new(1.015, 0.5)
		GIFTING_TRANSPARENCY_SPRING.Target = 0
		GIFTING_ROTATION_SPRING.Target = 0
		SHOPPOS_SPRING.Target = Reposition_Shop(Aktiv)
	else
		GIFTINGPOS_SPRING.Target = Vector2.new(InnerContainer.Size.X.Scale - GiftingContainer.Size.X.Scale, 0.5)
		GIFTING_TRANSPARENCY_SPRING.Target = 1
		GIFTING_ROTATION_SPRING.Target = -20
		SHOPPOS_SPRING.Target = Reposition_Shop(Aktiv)
	end
end)

local NUM_Tween = nil :: Tween?
PlayerGift_Class.DevProducktID_Signal:Connect(function(DevProducktID: number)
	if not DevProducktID then
		return
	end
	if NUM_Tween then
		NUM_Tween:Cancel()
	end

	local Produckt_Data = DevProduct_Data[DevProducktID]
	if not Produckt_Data then
		return
	end

	NUM_Tween = TweenService:Create(NUMBERVALUE_INSTANCE, TWEENIFO_NUM, { Value = Produckt_Data.price })

	for _, PlayerGiftCardClass in pairs(Gifting_Controller.Classes) do
		PlayerGiftCardClass:Set_DevProducktID(DevProducktID)
	end

	NUM_Tween:Play()
end)

----------[ NumberAnimation ]----------

NUMBERVALUE_INSTANCE.Changed:Connect(function(value)
	if not value then
		return
	end

	local Text = `{Number_Format:formatNumber(value)}`

	for _, PlayerGiftCardClass in pairs(Gifting_Controller.Classes) do
		PlayerGiftCardClass:Set_RobuxText(Text)
	end
end)

return Gifting_Controller
