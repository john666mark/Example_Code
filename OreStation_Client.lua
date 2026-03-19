local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Item_Data_Folder = ReplicatedStorage.Shared.Data.Item_Data
local OreData = require(Item_Data_Folder.Ore_Data)
local Miner_Order_Map = require(Item_Data_Folder.Miner_Order_Map)
local Pooling_Class = require(ReplicatedStorage.Shared.Pooling_Class)
local Number_Format = require(ReplicatedStorage.Shared.Number_Format)
local Rarity_ColorModule = require(ReplicatedStorage.Shared.Rarity_ColorModule)
local Miner_Class = require(script.Parent.Miner)
local Ore_Station_Fragment_Box = require(script.Parent.Ore_Station_Fragment_Box) -- Addiditional Class
local Miner_Data = require(ReplicatedStorage.Shared.Data.Item_Data.Miner_Data)

----------> [ Variables ] <----------

local OreStation = {}

OreStation.__index = OreStation

local Station_BillboardGui_POOL

OreStation.PLOT_STATION_CLASS_REFS = {}

local local_PLayer = Players.LocalPlayer

local Plots = workspace.Plots

local MINER_POOLING_CLASSES = Miner_Class.POOLING_DICTIONARY

local max_Miner_Index = #Miner_Order_Map

----------> [ Remote_Events ] <----------

local station_ReplFolder = ReplicatedStorage.Remote_events.Ore_Station_events.Client_Replication_Folder
local Add_BillboardGui_event = station_ReplFolder.Add_BillboardGui_event
local Remove_BillboardGui_event = station_ReplFolder.Remove_BillboardGui_event
local upgrade_Station_Client_event = station_ReplFolder.upgrade_Station_Client_event
local Ore_Fragment_Update_event = station_ReplFolder.Ore_Fragment_Update_event
local Collect_Fragment_event = station_ReplFolder.Collect_Fragment_event

--------<--/=( Calculations )=\-->--------

local function Calculate_Ore_Bulk(Station_level: number): number?
	return math.floor(1.2 * (1.05 ^ Station_level))
end

local function Calculate_Upgrade_Price(Station_level: number): number?
	return math.floor(750 * (1.12 ^ Station_level))
end

local function CalculateMoney_From_Fragments(Fragment_amount: number, Price_Per_Fragment: number): number?
	if not Fragment_amount or not Price_Per_Fragment then
		return
	end

	return Fragment_amount * Price_Per_Fragment
end

local function Calculate_Max_Stach_amount(Station_level: number): number?
	return 300 + math.floor(150 * (Station_level ^ 1.08))
end

local function Calculate_Money_Per_Sec(
	Ore_Bulk_Amount: number,
	Price_Per_Fragment: number,
	Ore_bulk_Tick: number
): number?
	if not Ore_Bulk_Amount or not Price_Per_Fragment or not Ore_bulk_Tick then
		return
	end

	local Ore_Bulk_Value = CalculateMoney_From_Fragments(Ore_Bulk_Amount, Price_Per_Fragment)
	if not Ore_Bulk_Value then
		return
	end

	return Ore_Bulk_Value / Ore_bulk_Tick
end

local function Calculate_New_Miner(Level: number): string?
	if not Level then
		return
	end

	if Level < 10 then
		return Miner_Order_Map[1]
	end

	local Map_Index = math.floor((Level / 10) + 1)

	if Map_Index >= max_Miner_Index then
		return Miner_Order_Map[max_Miner_Index]
	end

	return Miner_Order_Map[Map_Index]
end

----------> [ Helper Functions ] <----------

local function Get_SurfaceGui_Containers(Ui_Model: Model): (Frame?, Frame?)
	local UI_Part = Ui_Model:FindFirstChild("UI_Part")
	local UI_Part2 = Ui_Model:FindFirstChild("UI_Part2")

	if not UI_Part or not UI_Part2 then
		return
	end

	local Button_Sreen = UI_Part:FindFirstChild("SurfaceGui")
	local Stat_Sreen = UI_Part2:FindFirstChild("SurfaceGui")

	if not Button_Sreen or not Stat_Sreen then
		return
	end

	local Button_Container = Button_Sreen:FindFirstChild("Container")
	local Stat_Container = Stat_Sreen:FindFirstChild("Container")

	return Button_Container, Stat_Container
end

local function Get_Station_Model(Plot_Number: number, Stattion_Number: number): Model?
	local Plot = Plots:FindFirstChild(Plot_Number)
	if not Plot then
		return
	end

	return Plot.Ore_Station:FindFirstChild(Stattion_Number)
end

----------> [Main_Script] <----------

function OreStation.Init()
	----------> [Plot_Station_Refrences] <----------

	local function Create_Plot_Station_Ref_table()
		for _, Plot_Folder in ipairs(Plots:GetChildren()) do
			local Plot_Number = tonumber(Plot_Folder.Name)

			OreStation.PLOT_STATION_CLASS_REFS[Plot_Number] = {}
			local Plot_Ref = OreStation.PLOT_STATION_CLASS_REFS[Plot_Number]

			local Ore_Station_Folder = Plot_Folder:WaitForChild("Ore_Station") :: Folder

			for _, OreStation in ipairs(Ore_Station_Folder:GetChildren()) do
				local Ore_Station_Number = tonumber(OreStation.Name)
				Plot_Ref[Ore_Station_Number] = {}
			end
		end
	end

	Create_Plot_Station_Ref_table()
	print(OreStation.PLOT_STATION_CLASS_REFS)

	----------> [ Pooling Classes ] <----------

	local Station_BillboardGui_BluePrint = ReplicatedStorage.Assets.GUI_Folder.Gui_BluePrints.Station_BillboardGui

	local function On_Free(Objekt: Instance)
		Objekt.Parent = nil
	end

	Station_BillboardGui_POOL = Pooling_Class.new(
		Station_BillboardGui_BluePrint,
		1,
		function() end,
		function() end,
		On_Free
	)
end

OreStation.Init()

function OreStation.Get_Station_Ref(Plot_number: number, Station_number: number): { [string]: any }?
	local PLOT_REF = OreStation.PLOT_STATION_CLASS_REFS[Plot_number]
	if not PLOT_REF then
		return
	end

	local STATION_REF = PLOT_REF[Station_number]

	return STATION_REF
end

---@param Owner Player
---@param Plot_Number number
---@param Station_Number number
---@param Ore_ID string
---@param Ore_Name string
---@param Mutations any
function OreStation.new(
	Owner: Player,
	Plot_Number: number,
	Station_Number: number,
	Station_Level: number,
	Ore_ID: string?,
	Ore_Name: string?,
	Mutations: { [string]: boolean }?
)
	if not Owner or not Plot_Number or not Station_Number then
		return
	end

	local self = setmetatable({}, OreStation)

	-- basic station variables
	self._Owner = Owner
	self._Plot_Number = Plot_Number
	self._Station_Number = Station_Number
	self._Station_Model = Get_Station_Model(Plot_Number, Station_Number)
	self._Station_Level = Station_Level or 1
	self._Stach_Amount_Max = Calculate_Max_Stach_amount(self._Station_Level)
	self._Ore_Bulk = Calculate_Ore_Bulk(self._Station_Level)
	self._Upgrade_Price = Calculate_Upgrade_Price(self._Station_Level)

	-- collecting_touch_event
	self._Touch_Collection_event = nil :: RBXScriptConnection?
	self._Toucheble = true

	-- EZV connections
	self._Station_BillboardGui_Connections = {}
	self._Station_BillboardGui = nil

	-- Parts
	self._Ore_SpawnPart = nil :: BasePart?
	self._Miner_SpawnPart = nil :: BasePart?

	-- Ore data
	self._Ore_Name = Ore_Name or nil
	self._Ore_ID = Ore_ID or nil
	self._Ore_Mutations = Mutations or {} :: { [string]: boolean }
	self._Ore_Data = nil
	self._Ore_Rarity = nil
	self._Ore_fragment_Price = nil
	self._Ore_Model = nil

	self._Ore_Fragments_Count = 0

	-- Miner
	self._Miner_Model = nil :: Model?
	self._Miner_Attack_thread = nil :: thread?

	self:Get_SpawnParts_From_Station_Model()
	self:SetUp_ore(self._Ore_Model, self._Ore_ID, self._Ore_Mutations)
	self:SetUp_Billboard_Gui()
	self:Update_SurfaceGuis()

	-- Ore_Station_Fragment_Box
	self._Fragment_Box = Ore_Station_Fragment_Box.new(self._Owner, self._Ore_SpawnPart, self._Ore_Rarity or "Rare")

	-- Miner Setup
	self:Swap_Miner()

	-- Refrence to Plot_Table
	self.PLOT_STATION_CLASS_REFS[self._Plot_Number][self._Station_Number] = self

	return self
end

function OreStation:SetUp_ore(Ore_name, Ore_ID: string, Mutations: { [string]: boolean }): ()
	if not Ore_name or not Ore_ID then
		return
	end

	self._Ore_ID = Ore_ID

	-- From Ore Data --
	self._Ore_Data = OreData[Ore_name]

	if not self._Ore_Data then
		return
	end

	self._Ore_Rarity = self._Ore_Data.Rarity
	self._Ore_fragment_Price = self._Ore_Data.fragment_Price

	-- From Player Data --
	self._Ore_Name = Ore_name
	self._Ore_Mutations = Mutations or {}
	self._Ore_Fragments_Count = 0

	--print(self, "Clientsadaisjdiasidaiosjdioasd", self.PLOT_STATION_CLASS_REFS)
end

function OreStation:Get_OreModel_FromSpawnPart()
	if not self._Ore_SpawnPart then
		return
	end

	self._Ore_Model = self._Ore_SpawnPart:FindFirstChildOfClass("Model")
end

function OreStation:SetUp_Billboard_Gui(): ()
	if not self._Ore_Model or not self._Ore_ID then
		return
	end

	-- Get a the billboardgui
	if not self._Station_BillboardGui then
		self._Station_BillboardGui = Station_BillboardGui_POOL:Get()
	end

	-- Update_Textes and give textlabes back that needs to be colored
	local Name_TextLabel, Mutation_TextLabel = self:Update_Billboard_Gui()
	if not Name_TextLabel or not Mutation_TextLabel then
		return
	end

	-----< GUI Coloring >-----
	local Name_Collor_Connnection = Rarity_ColorModule:CreateApply_Gradient_Or_EZVeffect_With_Refrence(
		Name_TextLabel,
		Rarity_ColorModule:Get_ColorSequence_By_Rarity(self._Ore_Rarity)
	)

	local Mutation_Color_Connnection
	if #self._Ore_Mutations == 1 then
		Mutation_Color_Connnection = Rarity_ColorModule:CreateApply_Gradient_Or_EZVeffect_With_Refrence(
			Mutation_TextLabel,
			Rarity_ColorModule:Get_ColorSequence_By_Mutation(self._Ore_Mutations[1])
		)
	end

	if Mutation_Color_Connnection then
		self._Station_BillboardGui_Connections["Mutation_TextLabel_Color"] = Name_Collor_Connnection
	end

	if Name_Collor_Connnection then
		self._Station_BillboardGui_Connections["Name_TextLabel_Color"] = Name_Collor_Connnection
	end

	self._Station_BillboardGui.Parent = self._Ore_Model.PrimaryPart

	self:Start_Attack_Loop()
end

function OreStation:Remove_BillboardGui()
	if not self._Station_BillboardGui then
		return
	end

	-- Remove EZV Connections
	for _, EZV_Ref in pairs(self._Station_BillboardGui_Connections) do
		EZV_Ref:Destroy()
	end
	self._Station_BillboardGui_Connections = {}

	-- Return BillboardGui to Pool
	Station_BillboardGui_POOL:free(self._Station_BillboardGui)
	self._Station_BillboardGui = nil

	self:Stop_Attack_Loop()
end

function OreStation:Get_SpawnParts_From_Station_Model(): (BasePart?, BasePart?)
	if not self._Station_Model then
		return
	end

	self._Ore_SpawnPart = self._Station_Model:FindFirstChild("Ore_Spawner"):WaitForChild("Hitbox")
	self._Miner_SpawnPart = self._Station_Model:FindFirstChild("Miner_Spawner"):WaitForChild("Spawn_Part")

	assert(self._Ore_SpawnPart, "No Ore_SpawnPart Found")
	assert(self._Miner_SpawnPart, "No Miner_SpawnPart Found")

	return self._Ore_SpawnPart, self._Miner_SpawnPart
end

function OreStation:Update_Billboard_Gui(): (TextLabel?, TextLabel?)
	if not self._Ore_Model or not self._Ore_ID or not self._Station_BillboardGui then
		return
	end

	local Container = self._Station_BillboardGui:FindFirstChild("Container")
	if not Container then
		return
	end

	-- Get all TextLabes
	local Money_TextLabel = Container:FindFirstChild("Money_TextLabel") :: TextLabel
	local Mutation_TextLabel = Container:FindFirstChild("Mutation_TextLabel") :: TextLabel
	local Name_TextLabel = Container:FindFirstChild("Name_TextLabel") :: TextLabel
	local Stach_TextLabel = Container:FindFirstChild("Stach_TextLabel") :: TextLabel

	if not Money_TextLabel or not Mutation_TextLabel or not Name_TextLabel or not Stach_TextLabel then
		return
	end

	-----< Update all Textes >-----

	local Owned_Frgmnets = Number_Format:formatInteger(self._Ore_Fragments_Count)
	local Max_stach_amount = Number_Format:formatInteger(self._Stach_Amount_Max)

	Name_TextLabel.Text = self._Ore_Name
	Stach_TextLabel.Text = Owned_Frgmnets .. "/" .. Max_stach_amount

	-- "$" Current_Money_output "(" Money/second " " MoneyRebith Multiplier ")"

	--<--/=( Calculations )=\-->--
	local Current_Money_output = CalculateMoney_From_Fragments(self._Ore_Fragments_Count, self._Ore_fragment_Price)
	local MoneyPsec = Calculate_Money_Per_Sec(self._Ore_Bulk, self._Ore_fragment_Price, 5)

	local Text_Current_Money_output = Number_Format:formatNumber(Current_Money_output)
	local Text_MoneyPsec = Number_Format:formatNumber(MoneyPsec)

	Money_TextLabel.Text = "$" .. Text_Current_Money_output .. " ($" .. Text_MoneyPsec .. "/s " .. "x1" .. ")"

	if #self._Ore_Mutations ~= 0 then
		Mutation_TextLabel.Text = table.concat(self._Ore_Mutations, "-")
		Mutation_TextLabel.Visible = true
	else
		Mutation_TextLabel.Visible = false
	end

	return Name_TextLabel, Mutation_TextLabel
end

function OreStation:Update_SurfaceGuis()
	if not self._Station_Model or not self._Station_Level then
		return
	end

	local Ui_Model = self._Station_Model:FindFirstChild("Ui_Model") :: Model
	if not Ui_Model then
		return
	end

	local Button_Container, Stat_Container = Get_SurfaceGui_Containers(Ui_Model)
	if not Button_Container or not Stat_Container then
		return
	end

	local TextLabel_Folder = Button_Container:FindFirstChild("Plot_Button")
		:FindFirstChild("Container")
		:FindFirstChild("TextLabel_Folder") :: TextLabel
	if not TextLabel_Folder then
		return
	end

	local Level_Textlabel = TextLabel_Folder:FindFirstChild("Level")
	local Upgrade_Cost_Textlabel = TextLabel_Folder:FindFirstChild("Money")
	local Ore_Bulk_Textlabel = Stat_Container:FindFirstChild("Fragments")
		:FindFirstChild("TextLabel_Folder")
		:FindFirstChild("TextLabel") :: TextLabel
	local Inventory_Space_Textlabel = Stat_Container:FindFirstChild("Inventory")
		:FindFirstChild("TextLabel_Folder")
		:FindFirstChild("TextLabel") :: TextLabel

	if not Ore_Bulk_Textlabel or not Inventory_Space_Textlabel or not Level_Textlabel or not Upgrade_Cost_Textlabel then
		return
	end

	-----< Update all Textes >-----

	local NEXT_Ore_Bulk = Calculate_Ore_Bulk(self._Station_Level + 1)
	local NEXT_Satch_max_amount = Calculate_Max_Stach_amount(self._Station_Level + 1)
	local Upgrade_price = Number_Format:formatNumber(self._Upgrade_Price)
	local Satch_max_amount = Number_Format:formatInteger(self._Stach_Amount_Max)
	local NEXT_Ore_Bulk_Text = Number_Format:formatInteger(NEXT_Ore_Bulk)
	local Ore_Bulk_Text = Number_Format:formatInteger(self._Ore_Bulk)
	local NEXT_Satch_max_amount_Text = Number_Format:formatInteger(NEXT_Satch_max_amount)

	Upgrade_Cost_Textlabel.Text = Upgrade_price .. " $"

	Level_Textlabel.Text = "Lvl " .. self._Station_Level .. " -> " .. "Lvl " .. self._Station_Level + 1

	Ore_Bulk_Textlabel.Text = Ore_Bulk_Text .. " -> " .. NEXT_Ore_Bulk_Text

	Inventory_Space_Textlabel.Text = Satch_max_amount .. " -> " .. NEXT_Satch_max_amount_Text
end

function OreStation:Upgrade_Station(Player: Player, Station_Level: number)
	-- make sure the requested player is also the owner of the Plot
	if not Player or not self._Owner then
		return
	end

	if not self._Station_Level then
		return
	end

	self._Station_Level = Station_Level
	self._Stach_Amount_Max = Calculate_Max_Stach_amount(self._Station_Level)
	self._Ore_Bulk = Calculate_Ore_Bulk(self._Station_Level)
	self._Upgrade_Price = Calculate_Upgrade_Price(self._Station_Level)

	self:Update_SurfaceGuis()
	self:Update_Billboard_Gui()
	self:Swap_Miner()
end

function OreStation:Get_Fragments()
	-- Validate required fields
	if not self._Owner then
		return
	end
	if not self._Ore_Bulk then
		return
	end
	if not self._Ore_fragment_Price then
		return
	end
	if not self._Ore_ID then
		return
	end

	local currentCount = self._Ore_Fragments_Count or 0
	local bulk = self._Ore_Bulk or 0
	local maxAmount = self._Stach_Amount_Max or 0

	local newStackAmount = currentCount + bulk
	local clampedAmount = math.clamp(newStackAmount, 0, maxAmount)

	self._Ore_Fragments_Count = clampedAmount

	self:Update_Billboard_Gui()

	return self._Ore_Fragments_Count
end

function OreStation:Collect_Ore_Fragments()
	if not self._Ore_ID then
		return
	end
	if not self._Ore_Fragments_Count then
		return
	end
	if not self._Station_Model then
		return
	end

	local Orb_Count = math.clamp(self._Ore_Fragments_Count, 1, 30)

	self._Ore_Fragments_Count = 0

	self:Update_Billboard_Gui()

	self._Fragment_Box:Spawn_Fragments(Orb_Count, 3000)
end

-----< Miner Setup >-----

function OreStation:Free_Miner()
	if not self._Miner_Model then
		return
	end

	local Miner_Pool = MINER_POOLING_CLASSES[self._Miner_Model.Name]
	if not Miner_Pool then
		return
	end

	Miner_Pool:free(self._Miner_Model)
	self._Miner_Model = nil

	-- stop animation
end

function OreStation:Get_New_Miner_From_Pool(Miner_Name: string)
	if self._Miner_Model then
		return
	end

	local Miner_Pool = MINER_POOLING_CLASSES[Miner_Name]
	if not Miner_Pool then
		return
	end

	self._Miner_Model = Miner_Pool:Get()
end

function OreStation:Swap_Miner()
	if not self._Station_Level then
		return
	end

	if not self._Miner_SpawnPart then
		return
	end

	-- check if its the same miner
	local New_Miner_Name = Calculate_New_Miner(self._Station_Level)
	if self._Miner_Model and New_Miner_Name == self._Miner_Model.Name or not New_Miner_Name then
		return
	end

	-- switch OreModel
	if self._Miner_Model then
		self:Free_Miner(self._Miner_Model)
		self:Get_New_Miner_From_Pool(New_Miner_Name)
	else
		self:Get_New_Miner_From_Pool(New_Miner_Name)
	end

	-- place miner on Miner_Spawner
	-- Play Idle Animation | pickaxe Animation in a new Task

	self._Miner_Model:PivotTo(self._Miner_SpawnPart.CFrame - Vector3.new(0, self._Miner_SpawnPart.Size.Y / 2, 0))
	self._Miner_Model.Parent = self._Miner_SpawnPart

	local Spec_Miner_Data = Miner_Data[New_Miner_Name]
	if not Spec_Miner_Data then
		warn("No minerdata found")
		return
	end

	Spec_Miner_Data.Setup_function(self._Miner_Model)
	self:Start_Attack_Loop()
end

function OreStation:Start_Attack_Loop() --self._Miner_Attack_thread
	if self._Miner_Attack_thread then
		self:Stop_Attack_Loop()
	end

	if not self._Ore_Model then
		return
	end

	self._Miner_Attack_thread = coroutine.create(function()
		while true do
			task.wait(math.random(200, 300) / 100)
		end
	end)

	coroutine.resume(self._Miner_Attack_thread)
end

function OreStation:Stop_Attack_Loop() --self._Miner_Attack_thread
	if not self._Miner_Attack_thread then
		return
	end

	coroutine.close(self._Miner_Attack_thread)
end

function OreStation:Destroy()
	-- additional Pooling and destroing functions
	self._Fragment_Box:Destroy()
	self:Stop_Attack_Loop()
	self:Remove_BillboardGui()
	self:Free_Miner()
	--self:Destroy_Ore() resets the ore data
	for key in pairs(self) do
		self[key] = nil
	end
	setmetatable(self, nil)
end

-----< Remote_Event_Handeling >-----

Add_BillboardGui_event.OnClientEvent:Connect(
	function(
		Plot_Number: number,
		Station_number: number,
		Ore_name: string,
		Mutations: { [string]: boolean },
		Ore_ID: string
	)
		local Player_OreStation = OreStation.Get_Station_Ref(Plot_Number, Station_number)
		if not Player_OreStation then
			warn("OreStation_REF not Found")
			return
		end

		-- will be Wrapt later
		Player_OreStation:Get_OreModel_FromSpawnPart()
		Player_OreStation:SetUp_ore(Ore_name, Ore_ID, Mutations)
		Player_OreStation:Update_SurfaceGuis()
		Player_OreStation:SetUp_Billboard_Gui()
	end
)

upgrade_Station_Client_event.OnClientEvent:Connect(
	function(Plot_Number: number, Station_number: number, Station_Level: number)
		local Player_OreStation = OreStation.Get_Station_Ref(Plot_Number, Station_number)
		if not Player_OreStation then
			warn("OreStation_REF not Found")
			return
		end

		Player_OreStation:Upgrade_Station(local_PLayer, Station_Level)
	end
)

Remove_BillboardGui_event.OnClientEvent:Connect(function(Plot_Number: number, Station_number: number)
	local Player_OreStation = OreStation.Get_Station_Ref(Plot_Number, Station_number)
	if not Player_OreStation then
		warn("OreStation_REF not Found")
		return
	end

	Player_OreStation:Remove_BillboardGui() 
end)

Collect_Fragment_event.OnClientEvent:Connect(function(Plot_Number: number, Station_number: number)
	local Player_OreStation = OreStation.Get_Station_Ref(Plot_Number, Station_number)
	if not Player_OreStation then
		warn("OreStation_REF not Found")
		return
	end

	if type(Player_OreStation.Collect_Ore_Fragments) ~= "function" then
		return
	end

	Player_OreStation:Collect_Ore_Fragments()
end)

Ore_Fragment_Update_event.OnClientEvent:Connect(function()
	for _, Plot_Station_Table in pairs(OreStation.PLOT_STATION_CLASS_REFS) do
		for _, Station_Class in pairs(Plot_Station_Table) do
			if type(Station_Class.Get_Fragments) == "function" then
				Station_Class:Get_Fragments()
			end
		end
	end
end)

return OreStation
