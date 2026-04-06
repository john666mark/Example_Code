local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OpenGui_Animations = require(ReplicatedStorage.Shared.GUI_TweenModule_Folder.Open_Gui_Animations)
local LocalPlayer = Players.LocalPlayer

----------> [GUI-Refs] <----------
local PlayerGUI = LocalPlayer.PlayerGui
local PopUp_GUI_Screen = PlayerGUI:WaitForChild("PopUp_GUI_Screen")
local Boolean_Request_Gui_BluePrint =
	ReplicatedStorage.Assets.GUI_Folder.Gui_BluePrints:FindFirstChild("Boolean_Request_Gui")

----------> [Helper Functions] <----------

local function empty() end

----------> [Main] <----------

local Boolean_Request_Gui = {}

Boolean_Request_Gui.__index = Boolean_Request_Gui

function Boolean_Request_Gui.new(
	True_function,
	False_function,
	Questrion: string,
	True_Text: string?,
	False_Text: string?
)
	if not Questrion then
		return
	end

	local self = setmetatable({
		_True_function = True_function or empty,
		_False_function = False_function or empty,
		_Text = {
			Questrion = Questrion,
			True_Text = True_Text or "Yes",
			False_Text = False_Text or "No",
		},
	}, Boolean_Request_Gui)

	self._Gui_Instance = Boolean_Request_Gui_BluePrint:Clone() :: Frame
	self._GUI_REFS = {}
	self._Connections = {}

	self:Initialize_GUI_REFS()
	self:Update_Gui_Text()
	self:Connect_Buttons()

	return self
end

function Boolean_Request_Gui:Initialize_GUI_REFS()
	if not self._Gui_Instance then
		return
	end

	self._Gui_Instance.Parent = PopUp_GUI_Screen

	local Question_TextLabel = self._Gui_Instance:WaitForChild("Question_TextLabel")
	local List_Container = self._Gui_Instance:WaitForChild("List_Container")
	local False_Button = List_Container:WaitForChild("False_Button")
	local True_Button = List_Container:WaitForChild("True_Button")

	local True_TextLabel = True_Button:WaitForChild("Container"):WaitForChild("TextLabel")
	local False_TextLabel = False_Button:WaitForChild("Container"):WaitForChild("TextLabel")

	self._GUI_REFS = {
		Question_TextLabel = Question_TextLabel :: TextLabel,
		List_Container = List_Container :: Frame,
		True_Button = True_Button :: GuiButton,
		False_Button = False_Button :: GuiButton,
		True_TextLabel = True_TextLabel :: TextLabel,
		False_TextLabel = False_TextLabel :: TextLabel,
	}
end

function Boolean_Request_Gui:Update_Gui_Text()
	if not self._Gui_Instance then
		return
	end

	local Question_TextLabel = self._GUI_REFS.Question_TextLabel
	local True_TextLabel = self._GUI_REFS.True_TextLabel
	local False_TextLabel = self._GUI_REFS.False_TextLabel

	Question_TextLabel.Text = self._Text.Questrion
	True_TextLabel.Text = self._Text.True_Text
	False_TextLabel.Text = self._Text.False_Text
end

function Boolean_Request_Gui:Connect_Buttons()
	local True_Button = self._GUI_REFS.True_Button
	local False_Button = self._GUI_REFS.False_Button
	local List_Container = self._GUI_REFS.List_Container

	OpenGui_Animations:Apply_ButtonAnimation_on_Table(List_Container, self._Connections)

	self._Connections["True_Button"] = True_Button.MouseButton1Click:Connect(function()
		self._True_function()
	end)

	self._Connections["False_Button"] = False_Button.MouseButton1Click:Connect(function()
		self._False_function()
	end)

	OpenGui_Animations:Disable_Button_Setup(True_Button, self._Gui_Instance, self._Connections)
	OpenGui_Animations:Disable_Button_Setup(False_Button, self._Gui_Instance, self._Connections)
end

function Boolean_Request_Gui:Open()
	OpenGui_Animations:Open_Simple_Screen(self._Gui_Instance)
end

function Boolean_Request_Gui:Disconnect_Events()
	if not self._Connections then
		return
	end

	for _, Connection: RBXScriptConnection in pairs(self._Connections) do
		if not Connection then
			continue
		end
		Connection:Disconnect()
	end

	self._Connections = {}
end

function Boolean_Request_Gui:Destroy()
	self:Disconnect_Events()
	self._Gui_Instance:Destroy()

	for Key in pairs(self) do
		self[Key] = nil
	end
end

return Boolean_Request_Gui
