local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

----------[ Types ]----------

export type BundleReward_Refs = {
	Root: Frame,
	Icon: ImageLabel,
	Star1: ImageLabel,
	Star2: ImageLabel,
	Starburst: ImageLabel,
	Titel1: TextLabel,
	Titel2: TextLabel,
}

export type Gamepass_Refs = {
	Root: Frame,
	Button_Container: Frame,
	Buy_Button: ImageButton,
	Gift_Button: ImageButton,
	Icon: ImageLabel,
	MainFrame: ImageLabel,
	Starburst: ImageLabel,
	Description1: TextLabel,
	Description2: TextLabel,
	Titel1: TextLabel,
	Titel2: TextLabel,
}

export type Money_Refs = {
	Root: Frame,
	Button_Container: Frame,
	Buy_Button: ImageButton,
	Gift_Button: ImageButton,
	Icon: ImageLabel,
	MainFrame: ImageLabel,
	Starburst: ImageLabel,
	Text_Shadow: TextLabel,
	Titel1: TextLabel,
	Titel2: TextLabel,
}

export type StarterBundle_Refs = {
	Root: Frame,
	Button_Container: Frame,
	Buy_Button: ImageButton,
	Gift_Button: ImageButton,
	Rewards_Container: Frame,
	MainFrame: ImageLabel,
	MainFrame_Grey: ImageLabel,
	Description1: TextLabel,
	Description2: TextLabel,
	Titel1: TextLabel,
	Titel2: TextLabel,
	Aura: BundleReward_Refs,
	Money: BundleReward_Refs,
	Sword: BundleReward_Refs,
}

export type GUI_REFS_Type = {
	Shop_Container: Frame,
	UIAspectRatioConstraint: UIAspectRatioConstraint,
	UIScale: UIScale,

	Header: {
		Root: Frame,
		UIGradient: UIGradient,
		XButton: ImageButton,
		Icon: ImageLabel,
		Starburst: ImageLabel,
		TextLabel1: TextLabel,
		TextLabel2: TextLabel,
	},

	ScrollingFrame: ScrollingFrame,

	Health_Luck: {
		Root: Frame,
		Health: Gamepass_Refs,
		Luck: Gamepass_Refs,
	},

	Money_Vip: {
		Root: Frame,
		Money: Gamepass_Refs,
		VIP: Gamepass_Refs,
	},

	Moneys: {
		Root: Frame,
		Money1: Money_Refs,
		Money2: Money_Refs,
		Money3: Money_Refs,
		Money4: Money_Refs,
	},

	StarterBundle: StarterBundle_Refs,
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

local function Create_Gamepass_GUIRefs(GamePass_Container: Frame, Extra: {}?)
	return Merge({
		Root = GamePass_Container :: Frame,
		Owned = GamePass_Container:WaitForChild("Owned"),
		Button_Container = GamePass_Container:WaitForChild("Button_Container") :: Frame,
		Buy_Button = GamePass_Container:WaitForChild("Button_Container"):WaitForChild("Buy_Button") :: ImageButton,
		Gift_Button = GamePass_Container:WaitForChild("Button_Container"):WaitForChild("Gift") :: ImageButton,
		Icon = GamePass_Container:WaitForChild("Icon") :: ImageLabel,
		MainFrame = GamePass_Container:WaitForChild("MainFrame") :: ImageLabel,
		Starburst = GamePass_Container:WaitForChild("Starburst") :: ImageLabel,
		Description1 = GamePass_Container:WaitForChild("Description1") :: TextLabel,
		Description2 = GamePass_Container:WaitForChild("Description2") :: TextLabel,
		Titel1 = GamePass_Container:WaitForChild("Titel1") :: TextLabel,
		Titel2 = GamePass_Container:WaitForChild("Titel2") :: TextLabel,
	}, Extra)
end

local function Create_Money_GUIRefs(Money_Container: Frame, Extra: {}?)
	return Merge({
		Root = Money_Container :: Frame,
		Button_Container = Money_Container:WaitForChild("Button_Container") :: Frame,
		Buy_Button = Money_Container:WaitForChild("Button_Container"):WaitForChild("Buy_Button") :: ImageButton,
		Gift_Button = Money_Container:WaitForChild("Button_Container"):WaitForChild("Gift") :: ImageButton,
		Icon = Money_Container:WaitForChild("Icon") :: ImageLabel,
		MainFrame = Money_Container:WaitForChild("MainFrame") :: ImageLabel,
		Starburst = Money_Container:WaitForChild("Starburst") :: ImageLabel,
		Text_Shadow = Money_Container:WaitForChild("Text_Shadow") :: TextLabel,
		Titel1 = Money_Container:WaitForChild("Titel1") :: TextLabel,
		Titel2 = Money_Container:WaitForChild("Titel2") :: TextLabel,
	}, Extra)
end

local function Create_BundleReward_GUIRefs(Reward: GuiObject, Extra: {}?)
	return Merge({
		Root = Reward :: Frame,
		Star1 = Reward:WaitForChild("Star1") :: ImageLabel,
		Star2 = Reward:WaitForChild("Star2") :: ImageLabel,
		Starburst = Reward:WaitForChild("Starburst") :: ImageLabel,
		Titel1 = Reward:WaitForChild("Titel1") :: TextLabel,
		Titel2 = Reward:WaitForChild("Titel2") :: TextLabel,
	}, Extra)
end

local function Create_StarterBundle_GUIRefs(Bundle: GuiObject, Extra: {}?)
	local Rewards = Bundle:WaitForChild("Rewards_Container")
	return Merge({
		Root = Bundle :: Frame,
		Owned = Bundle:WaitForChild("Owned"),
		Button_Container = Bundle:WaitForChild("Button_Container") :: Frame,
		Buy_Button = Bundle:WaitForChild("Button_Container"):WaitForChild("Buy_Button") :: ImageButton,
		Gift_Button = Bundle:WaitForChild("Button_Container"):WaitForChild("Gift") :: ImageButton,
		Rewards_Container = Rewards :: Frame,
		MainFrame = Bundle:WaitForChild("MainFrame") :: ImageLabel,
		MainFrame_Grey = Bundle:WaitForChild("MainFrame_Grey") :: ImageLabel,
		Description1 = Bundle:WaitForChild("Description1") :: TextLabel,
		Description2 = Bundle:WaitForChild("Description2") :: TextLabel,
		Titel1 = Bundle:WaitForChild("Titel1") :: TextLabel,
		Titel2 = Bundle:WaitForChild("Titel2") :: TextLabel,
	}, Extra)
end

----------[ Refs ]----------

local PopUp_GUI_Screen = PlayerGui:WaitForChild("PopUp_GUI_Screen")

local Shop_Container = PopUp_GUI_Screen:WaitForChild("Shop_Container"):WaitForChild("InnerContainer") :: Frame

local Header = Shop_Container:WaitForChild("Header")
local Header_UIGradient = Header:WaitForChild("UIGradient")
local Header_XButton = Header:WaitForChild("XButton")
local Header_Icon = Header:WaitForChild("Icon")
local Header_Starburst = Header:WaitForChild("Starburst")
local Header_TextLabel1 = Header:WaitForChild("TextLabel1")
local Header_TextLabel2 = Header:WaitForChild("TextLabel2")

local Main = Shop_Container:WaitForChild("Main")
local ScrollingFrame = Main:WaitForChild("Scrolling_Container"):WaitForChild("ScrollingFrame")

local Health_Luck = ScrollingFrame:WaitForChild("Health_Luck")
local Health_Container = Health_Luck:WaitForChild("Health_Container")
local Luck_Container = Health_Luck:WaitForChild("Luck_Container")

local Money_Vip = ScrollingFrame:WaitForChild("Money_Vip")
local Money_Container = Money_Vip:WaitForChild("Money_Container")
local VIP_Container = Money_Vip:WaitForChild("VIP_Container")

local Moneys = ScrollingFrame:WaitForChild("Moneys")
local Moneys_1 = Moneys:WaitForChild("1")
local Moneys_2 = Moneys:WaitForChild("2")
local Moneys_3 = Moneys:WaitForChild("3")
local Moneys_4 = Moneys:WaitForChild("4")

local StarterBundle = ScrollingFrame:WaitForChild("StarterBundle")
local StarterBundle_Rewards = StarterBundle:WaitForChild("Rewards_Container")

local GUI_REFS = {
	Shop_Container = Shop_Container :: Frame,

	Header = {
		Root = Header :: Frame,
		UIGradient = Header_UIGradient :: UIGradient,
		XButton = Header_XButton :: ImageButton,
		Icon = Header_Icon :: ImageLabel,
		Starburst = Header_Starburst :: ImageLabel,
		TextLabel1 = Header_TextLabel1 :: TextLabel,
		TextLabel2 = Header_TextLabel2 :: TextLabel,
	},

	ScrollingFrame = ScrollingFrame :: ScrollingFrame,

	Health_Luck = {
		Root = Health_Luck :: Frame,

		Health = Create_Gamepass_GUIRefs(Health_Container),
		Luck = Create_Gamepass_GUIRefs(Luck_Container),
	},

	Money_Vip = {
		Root = Money_Vip :: Frame,

		Money = Create_Gamepass_GUIRefs(Money_Container),
		VIP = Create_Gamepass_GUIRefs(VIP_Container),
	},

	Moneys = {
		Root = Moneys :: Frame,
		Money1 = Create_Money_GUIRefs(Moneys_1),
		Money2 = Create_Money_GUIRefs(Moneys_2),
		Money3 = Create_Money_GUIRefs(Moneys_3),
		Money4 = Create_Money_GUIRefs(Moneys_4),
	},

	StarterBundle = Create_StarterBundle_GUIRefs(StarterBundle, {
		Aura = Create_BundleReward_GUIRefs(StarterBundle_Rewards:WaitForChild("Aura"), {
			Icon = StarterBundle_Rewards:WaitForChild("Aura"):WaitForChild("Icon") :: ImageLabel,
		}),

		Money = Create_BundleReward_GUIRefs(StarterBundle_Rewards:WaitForChild("Money"), {
			Icon = StarterBundle_Rewards:WaitForChild("Money"):WaitForChild("Icon") :: ImageLabel,
		}),

		Sword = Create_BundleReward_GUIRefs(StarterBundle_Rewards:WaitForChild("Sword"), {
			Icon = StarterBundle_Rewards:WaitForChild("Sword"):WaitForChild("Icon") :: ImageLabel,
		}),
	}),
}

return GUI_REFS
