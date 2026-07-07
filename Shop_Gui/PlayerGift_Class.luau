local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.Packages.Signal)
local Gift_UIRefs = require(script.Parent.Gift_UIRefs)
local Spring = require(ReplicatedStorage.Shared.Utils.Spring)
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local PopUp_GUI_Screen = PlayerGui:WaitForChild("PopUp_GUI_Screen")
local Shop_Container = PopUp_GUI_Screen:WaitForChild("Shop_Container")
local InnerContainer = Shop_Container:WaitForChild("InnerContainer")

local GiftingContainer = Gift_UIRefs.Root

----------[ Helpers ]----------

----------[ Main ]----------

local PlayerGift_Class = {}
local IconSpring_Table = {}

PlayerGift_Class.OpenSignal = Signal.new()
PlayerGift_Class.DevProducktID_Signal = Signal.new()

PlayerGift_Class.__index = PlayerGift_Class

function PlayerGift_Class.new(Instance: ImageButton, DevProducktID: number)
	assert(Instance, "[PlayerGift_Class].new: no Gift Instance was found")
	local self = setmetatable({
		_Instance = Instance,
		_GUI_REFS = {},
		_Connetions = {},
		_Springs = {},
		_DevProducktID = DevProducktID,
	}, PlayerGift_Class)

	self:_Init()

	return self
end

function PlayerGift_Class:_Create_GUIRefs()
	local Gift_Button = self._Instance
	local Icon = Gift_Button:WaitForChild("Icon")
	local MainFrame = Gift_Button:WaitForChild("MainFrame")
	local TextLabel1 = Gift_Button:WaitForChild("TextLabel1")
	local TextLabel2 = Gift_Button:WaitForChild("TextLabel2")

	self._GUI_REFS = {

		Gift_Button = Gift_Button :: ImageButton,
		Icon = Icon :: ImageLabel,
		MainFrame = MainFrame :: ImageLabel,

		TextLabel1 = TextLabel1 :: TextLabel,
		TextLabel2 = TextLabel2 :: TextLabel,
	}
end

function PlayerGift_Class:_Init_Animations()
	local Icon = self._GUI_REFS.Icon

	self._Springs.IconSpring = Spring.new(0)
	self._Springs.IconSpring.Speed = 25
	self._Springs.IconSpring.Damper = 0.333

	IconSpring_Table[Icon] = self._Springs.IconSpring
end

function PlayerGift_Class:_Init_HoverEvents()
	self:_Init_Animations()
	local Gift_Button = self._GUI_REFS.Gift_Button
	local IconSpring = self._Springs.IconSpring

	local ROTATION = 16

	local EnterConn = Gift_Button.MouseEnter:Connect(function()
		IconSpring.Target = ROTATION
	end)

	local CklickConn1 = Gift_Button.MouseButton1Up:Connect(function()
		local WillOpen = true
		self.OpenSignal:Fire(WillOpen)
		self.DevProducktID_Signal:Fire(self._DevProducktID)
		IconSpring.Target = ROTATION
	end)

	local CklickConn2 = Gift_Button.MouseButton1Down:Connect(function()
		IconSpring.Target = -ROTATION
	end)

	local LeaveConn = Gift_Button.MouseLeave:Connect(function()
		IconSpring.Target = 0
	end)

	for _, Conn in pairs({ EnterConn, CklickConn1, CklickConn2, LeaveConn }) do
		table.insert(self._Connetions, Conn)
	end
end

function PlayerGift_Class:_Init()
	self:_Create_GUIRefs()
	self:_Init_HoverEvents()
end

function PlayerGift_Class:Destroy()
	if self._Connetions then
		for _, Conn in pairs(self._Connetions) do
			Conn:Disconnect()
		end
	end

	for key in pairs(self) do
		self[key] = nil
	end
end

----------[ runsevice event ]----------

local RunnserviseConnection = nil :: RBXScriptConnection?
function PlayerGift_Class.Connect_Springs()
	if RunnserviseConnection then
		RunnserviseConnection:Disconnect()
	end

	RunnserviseConnection = RunService.RenderStepped:Connect(function(DT)
		for Icon, IconSpring in pairs(IconSpring_Table) do
			Icon.Rotation = IconSpring.Position
		end
	end)
end

function PlayerGift_Class.Disconnect_Springs()
	if RunnserviseConnection then
		RunnserviseConnection:Disconnect()
	end
end

return PlayerGift_Class
