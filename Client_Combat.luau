local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Combat_Data = require(script.Parent.Combat_Data)
local Player_Inputs = require(ReplicatedStorage.Shared.Player_Inputs)
local Combat_Types = require(script.Parent.Combat_Types)

local RemoteEvents = ReplicatedStorage.RemoteEvents
local CombatKeyInfo = RemoteEvents.CombatKeyInfo
local Animation_event = RemoteEvents.Animation_event :: RemoteEvent

local Client_Combat = {}

local GLOBALM1COULDOWN = 0.2

----------[ Helper Functions ]----------

----------[ Construcktor ]----------

local Combat_InputKeys = Player_Inputs.Combat

Client_Combat.__index = Client_Combat

function Client_Combat.new(Player: Player, CombatStyle: string): Combat_Types.ClientCombatConstructorType
	local self = setmetatable({
		_Player = Player,
	}, Client_Combat)

	self.CharackterData = nil :: Combat_Types.CharackterData_Table?
	self._Input_Connection = nil :: RBXScriptConnection?

	self.Combat_States = {
		Aktiv_FightingStyle = nil,
		Aktiv_Ability = false,
		LastM1 = nil :: number?,
	}

	self:InitCharData(Player)
	self:Get_Combat_Style(CombatStyle)
	self:StartInputListener()

	print(self.CombatStyle)

	return self
end

----------[ MetaMethods ]----------

function Client_Combat:InitCharData(Player: Player)
	if not Player then
		return
	end

	local Charackter = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Charackter:WaitForChild("Humanoid")
	local Animator = Humanoid:WaitForChild("Animator")

	local CharackterData_Table = {
		Charackter = Charackter,
		Humanoid = Humanoid,
		Animator = Animator,
	}

	self.CharackterData = CharackterData_Table :: Combat_Types.CharackterData_Table
end

function Client_Combat:StartInputListener()
	if self._Input_Connection then
		return
	end

	local Debounce = false

	self._Input_Connection = UserInputService.InputBegan:Connect(function(input, Interuped)
		if Interuped or Debounce then
			return
		end
		Debounce = true

		local Combat_Input = Combat_InputKeys[input.KeyCode.Name]
		if Combat_Input then
			CombatKeyInfo:FireServer(Combat_Input)
			Debounce = false
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			CombatKeyInfo:FireServer("M1")
		end

		Debounce = false
	end)
end

function Client_Combat:Get_Combat_Style(Combat_style: string)
	if not Combat_style then
		--- set to basic combatstyle
		return
	end

	self.CombatStyle = Combat_Data[Combat_style]
	if not self.CombatStyle then
		return
	end
end

----------[ Remote_Events ]----------

Animation_event.OnClientEvent:Connect(function(Owner: Player, FightingStyle_Name: string, Ability_Name: string)
	local character = Owner.Character
	if not character then
		return
	end

	local Data = Combat_Data[FightingStyle_Name]
	if not Data then
		return
	end

	local Ability_Data = Data.Abilitys[Ability_Name]
	if not Ability_Data then
		return
	end

	local Init_Function = Ability_Data.Clinet_Init
	if not Init_Function then
		return
	end

	Init_Function(Ability_Data, character)
end)

return Client_Combat
