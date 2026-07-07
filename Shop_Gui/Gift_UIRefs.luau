local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

----------[ Types ]----------

export type BuyButton_Refs = {
	Root: ImageButton,
	MainFrame: ImageLabel,
	Shadow: ImageLabel,
	Star_Left: ImageLabel,
	Star_Right: ImageLabel,
	Stroke: ImageLabel,
	TextLabel1: TextLabel,
	TextLabel2: TextLabel,
}

export type PlayerTemplate_Refs = {
	Root: Frame,
	UIAspectRatioConstraint: UIAspectRatioConstraint,
	Button_Container: Frame,
	Buy_Button: BuyButton_Refs,
	Icon: ImageLabel,
	Icon_Shadow: ImageLabel,
	MainFrame: ImageLabel,
	Stroke: ImageLabel,
	Titel1: TextLabel,
	Titel2: TextLabel,
}

export type GUI_REFS_Type = {
	Root: Frame,
	UIAspectRatioConstraint: UIAspectRatioConstraint,

	Header: {
		Root: Frame,
		UIGradient: UIGradient,
		XButton: ImageButton,
		Icon: ImageLabel,
		TextLabel1: TextLabel,
		TextLabel2: TextLabel,
	},

	ScrollingFrame: ScrollingFrame,
	Player_Template: PlayerTemplate_Refs,

	Shadow: ImageLabel,
	Stroke: ImageLabel,
}

----------[ Helpers ]----------

local function Merge(t: {}, Extra: {}?)
	if Extra then
		for k, v in Extra do
			t[k] = v
		end
	end
	return t
end

----------[ GuiCreators ]----------

local function Create_BuyButton_GUIRefs(Buy_Button: ImageButton, Extra: {}?)
	return Merge({
		Root = Buy_Button :: ImageButton,
		MainFrame = Buy_Button:WaitForChild("MainFrame") :: ImageLabel,
		Shadow = Buy_Button:WaitForChild("Shadow") :: ImageLabel,
		Star_Left = Buy_Button:WaitForChild("Star_Left") :: ImageLabel,
		Star_Right = Buy_Button:WaitForChild("Star_Right") :: ImageLabel,
		Stroke = Buy_Button:WaitForChild("Stroke") :: ImageLabel,
		TextLabel1 = Buy_Button:WaitForChild("TextLabel1") :: TextLabel,
		TextLabel2 = Buy_Button:WaitForChild("TextLabel2") :: TextLabel,
	}, Extra)
end

----------[ Refs ]----------

local PopUp_GUI_Screen = PlayerGui:WaitForChild("PopUp_GUI_Screen")

local Gifting_Container = PopUp_GUI_Screen:WaitForChild("Shop_Container")
	:WaitForChild("InnerContainer")
	:WaitForChild("Gifting_Container") :: Frame

local Header = Gifting_Container:WaitForChild("Header")
local Header_UIGradient = Header:WaitForChild("UIGradient")
local Header_XButton = Header:WaitForChild("XButton")
local Header_Icon = Header:WaitForChild("Icon")
local Header_TextLabel1 = Header:WaitForChild("TextLabel1")
local Header_TextLabel2 = Header:WaitForChild("TextLabel2")

local Main = Gifting_Container:WaitForChild("Main")
local ScrollingFrame = Main:WaitForChild("Scrolling_Container"):WaitForChild("ScrollingFrame")

local GUI_REFS = {
	Root = Gifting_Container :: CanvasGroup,
	UIAspectRatioConstraint = Gifting_Container:WaitForChild("UIAspectRatioConstraint") :: UIAspectRatioConstraint,

	Header = {
		Root = Header :: Frame,
		UIGradient = Header_UIGradient :: UIGradient,
		XButton = Header_XButton :: ImageButton,
		Icon = Header_Icon :: ImageLabel,
		TextLabel1 = Header_TextLabel1 :: TextLabel,
		TextLabel2 = Header_TextLabel2 :: TextLabel,
	},

	ScrollingFrame = ScrollingFrame :: ScrollingFrame,

	Shadow = Gifting_Container:WaitForChild("Shadow") :: ImageLabel,
	Stroke = Gifting_Container:WaitForChild("Stroke") :: ImageLabel,
}

return GUI_REFS
