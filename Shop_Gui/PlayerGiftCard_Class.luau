local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Double_Text = require(ReplicatedStorage.Shared.Utils.Double_Text)
local RobuxBuyButton = require(script.Parent.RobuxBuyButton)

----------[ Helpers ]----------

----------[ Main ]----------

local PlayerGiftCard_Class = {}

PlayerGiftCard_Class.__index = PlayerGiftCard_Class

function PlayerGiftCard_Class.new(Instance: GuiObject, Target_Player: Player?, ProducktId: number?)
	local self = setmetatable({
		_Instance = Instance,
		_Target_Player = Target_Player,
		_UserID = Target_Player and Target_Player.UserId,
		_DevProducktID = ProducktId,
		_DevProduckt_Data = nil,
		_GUI_REFS = {},
		_BuyButtonClass = nil,
	}, PlayerGiftCard_Class)

	self:_Setup()

	return self
end

function PlayerGiftCard_Class:_InitGuiRefs()
	local Template = self._Instance

	local GUI_REFS = {
		Root = Template :: Frame,
		Button_Container = Template:WaitForChild("Button_Container") :: Frame,
		Buy_Button = Template:WaitForChild("Button_Container"):WaitForChild("Buy_Button") :: ImageButton,
		Icon = Template:WaitForChild("Icon") :: ImageLabel,
		MainFrame = Template:WaitForChild("MainFrame") :: ImageLabel,
		Titel1 = Template:WaitForChild("Titel1") :: TextLabel,
		Titel2 = Template:WaitForChild("Titel2") :: TextLabel,
	}

	self._GUI_REFS = GUI_REFS
end

function PlayerGiftCard_Class:_Set_BuyButtonClass()
	if self._BuyButtonClass then
		return
	end

	self._BuyButtonClass = RobuxBuyButton.new(self._GUI_REFS.Buy_Button, self._DevProducktID, self._Target_Player)
end

function PlayerGiftCard_Class:_SetIcon()
	if not self._UserID then
		return
	end
	local Icon = self._GUI_REFS.Icon

	local Sucsses, content = pcall(function()
		return Players:GetUserThumbnailAsync(self._UserID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
	end)
	if not Sucsses then
		return
	end

	Icon.Image = content
end

function PlayerGiftCard_Class:_SetPlayerName()
	if not self._UserID then
		return
	end

	local Titel1 = self._GUI_REFS.Titel1
	local Titel2 = self._GUI_REFS.Titel2

	local Sucsses, name = pcall(function()
		return Players:GetNameFromUserIdAsync(self._UserID)
	end)
	if not Sucsses then
		return
	end

	Double_Text:Set_Text(name, Titel1, Titel2)
end

function PlayerGiftCard_Class:_SetRobuxAmmount() end

function PlayerGiftCard_Class:_Set_Animations() end

function PlayerGiftCard_Class:_Setup()
	self:_InitGuiRefs()
	self:_Set_BuyButtonClass()
	self:_Set_Animations()
	self:Set_DevProducktID(self._DevProducktID)
	self:Update_gui()
end

----------[ MetaMethods ]----------

function PlayerGiftCard_Class:Set_TargetPlayer(Player: Player)
	self._Target_Player = Player
	self._UserID = Player and Player.UserId
	self._BuyButtonClass:Set_TargetPlayer(Player)
end

function PlayerGiftCard_Class:Set_TargetPlayerID(UserID: number)
	self._UserID = UserID
end

function PlayerGiftCard_Class:Set_DevProducktID(DevProducktID: number)
	self._DevProducktID = DevProducktID
	self._BuyButtonClass:Set_DevProducktID(DevProducktID)
end

function PlayerGiftCard_Class:Set_RobuxText(Text: string)
	if not Text then
		return
	end

	self._BuyButtonClass:ChangeRobux_Text(Text)
end

function PlayerGiftCard_Class:Update_gui()
	self:_SetIcon()
	self:_SetPlayerName()
	self:_SetRobuxAmmount()
end

function PlayerGiftCard_Class:Destroy()
	if self._BuyButtonClass and self._BuyButtonClass.Destroy then
		self._BuyButtonClass:Destroy()
	end

	if self._Instance then
		self._Instance:Destroy()
	end

	for key in pairs(self) do
		self[key] = nil
	end
end

return PlayerGiftCard_Class
