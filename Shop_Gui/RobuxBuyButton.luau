local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProduct_Data = require(ReplicatedStorage.Shared.Data.DevProduct_Data)
local Open_Gui_Animations = require(ReplicatedStorage.Shared.GUI_TweenModule_Folder.Open_Gui_Animations)
local Debounce = require(ReplicatedStorage.Shared.Utils.Debounce)
local Double_Text = require(ReplicatedStorage.Shared.Utils.Double_Text)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local BuyRequest = RemoteFunctions:WaitForChild("BuyRequest")
local PopUp_GUI_Screen = PlayerGui:WaitForChild("PopUp_GUI_Screen")
local Shop_Container = PopUp_GUI_Screen:WaitForChild("Shop_Container")
local InnerContainer = Shop_Container:WaitForChild("InnerContainer")
local GiftingContainer = InnerContainer:WaitForChild("Gifting_Container")

----------[ Helpers ]----------

----------[ Main ]----------

local RobuxBuyButton = {}

RobuxBuyButton.__index = RobuxBuyButton

function RobuxBuyButton.new(Instance: ImageButton, DevProduckt_ID: number?, Target_Player: Player?)
	assert(Instance, "[RobuxBuyButton].new: no Buy_Button_Container was found ")
	local self = setmetatable({
		_Instance = Instance,
		_GUI_REFS = {},
		_DevProduckt_ID = DevProduckt_ID or nil,
		_Target_Player = Target_Player,
		_DEVPRODUCKT_DATA = DevProduct_Data[DevProduckt_ID],
		_Buy_Connection = nil,
		_ButtonConnections = {} :: { RBXScriptConnection },
	}, RobuxBuyButton)

	self:_Setup()

	return self
end

function RobuxBuyButton:_Create_GUIRefs()
	local Buy_Button = self._Instance
	local MainFrame = Buy_Button:WaitForChild("MainFrame")
	local TextLabel1 = Buy_Button:WaitForChild("TextLabel1")
	local UIGradient1 = TextLabel1:WaitForChild("UIGradient")
	local TextLabel2 = Buy_Button:WaitForChild("TextLabel2")
	local UIGradient2 = TextLabel2:WaitForChild("UIGradient")

	local GUI_REFS = {

		Buy_Button = Buy_Button :: ImageButton,
		MainFrame = MainFrame :: ImageLabel,

		TextLabel1 = TextLabel1 :: TextLabel,
		UIGradient1 = UIGradient1 :: UIGradient,

		TextLabel2 = TextLabel2 :: TextLabel,
		UIGradient2 = UIGradient2 :: UIGradient,
	}

	self._GUI_REFS = GUI_REFS
end

function RobuxBuyButton:_Connect_DevProduckt()
	local Buy_Button = self._GUI_REFS.Buy_Button

	self._ButtonConnections["Buy_Connetion"] = Buy_Button.MouseButton1Up:Connect(function()
		Debounce.new(0.1, "Robux_Shop_Buy", function()
			if not self._Target_Player then
				return
			end
			local Sucsses, Massage = BuyRequest:InvokeServer(self._Target_Player, self._DevProduckt_ID)
			if not Sucsses then
				print(Massage)
				return
			end

			MarketplaceService:PromptProductPurchase(player, self._DevProduckt_ID)
		end)
	end)
end

function RobuxBuyButton:ChangeRobux_Text(Text: string?)
	local TextLabel1 = self._GUI_REFS.TextLabel1
	local TextLabel2 = self._GUI_REFS.TextLabel2

	if not self._DEVPRODUCKT_DATA then
		Double_Text:Set_Text("error", TextLabel1, TextLabel2)
		return
	end

	local FinalText: string = Text or tostring(self._DEVPRODUCKT_DATA.price) .. ""
	Double_Text:Set_Text(FinalText, TextLabel1, TextLabel2)
end

function RobuxBuyButton:_ApplyAnimation()
	local Buy_Button = self._GUI_REFS.Buy_Button
	Open_Gui_Animations:Apply_Animation_On_Button(Buy_Button, self._ButtonConnections)
end

function RobuxBuyButton:_Setup()
	self:_Create_GUIRefs()
	self:_ApplyAnimation()
	self:_Connect_DevProduckt()
	self:ChangeRobux_Text()
end

function RobuxBuyButton:Set_TargetPlayer(TargetPlayer: Player)
	self._Target_Player = TargetPlayer
end

function RobuxBuyButton:Set_DevProducktID(DevProduckt_ID: number)
	self._DevProduckt_ID = DevProduckt_ID
	self._DEVPRODUCKT_DATA = DevProduct_Data[DevProduckt_ID]
	self:ChangeRobux_Text()
end

function RobuxBuyButton:Destroy()
	for _, Conn in pairs(self._ButtonConnections) do
		Conn:Disconnect()
	end

	for key in pairs(self) do
		self[key] = nil
	end
end

return RobuxBuyButton
