local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Station_Data_Module = require(ReplicatedStorage.Shared.Data.OreStation_Data)
local Boolean_Request_Gui_ClassModule = require(ReplicatedStorage.Shared.Specific_Gui_Scripts.Boolean_Request_Gui)

local LocalPlayer = Players.LocalPlayer

local Plot_Number
if not Plot_Number then
	LocalPlayer:GetAttributeChangedSignal("Plot"):Wait()
	Plot_Number = LocalPlayer:GetAttribute("Plot")
end

local Plots = workspace.Plots :: Folder
local Players_Plot = Plots:WaitForChild(Plot_Number) :: Folder
local Buy_Station_Folder = Players_Plot:WaitForChild("Buy_Stations") :: Folder
local Buy_Station_event = ReplicatedStorage.Remote_events.Ore_Station_events.Buy_Station_event :: RemoteEvent

----------> [ Main ] <----------

local Buy_Station = {}
local Buy_Station_Class_Table = {}

Buy_Station.__index = Buy_Station

function Buy_Station.new(Buy_Station_Model: Model, Station_Number: number?)
	if not Buy_Station_Model or not Station_Number then
		return
	end

	local self = setmetatable({
		_Buy_Station_Model = Buy_Station_Model,
		_Station_Number = Station_Number,
	}, Buy_Station)

	self._Instance_REFS = self:Get_BuyStationREFS()
	self._Connections = {}
	self._Station_Data = Station_Data_Module[Station_Number]
	self._Gui_Class = nil

	self:Create_Gui()
	self:Connect_Touch_Buy_Request()
	Buy_Station_Class_Table[self._Station_Number] = self

	return self
end

function Buy_Station:Create_Gui()
	if self._Gui_Class then
		return
	end

	local Station_Price = self._Station_Data.Price
	local Questrion_Text = `Buy this Platform For ${Station_Price} ?`
	local False_text = "No Im Broke (._ .)"
	local True_text = "For Sure"

	local True_function = function()
		Buy_Station_event:FireServer(Plot_Number, self._Station_Number)
	end

	self._Gui_Class = Boolean_Request_Gui_ClassModule.new(True_function, nil, Questrion_Text, True_text, False_text)
end

function Buy_Station:Get_BuyStationREFS(): { [string]: Instance }?
	if not self._Buy_Station_Model then
		return
	end

	local Main_Part = self._Buy_Station_Model:WaitForChild("Main_Part")
	if not Main_Part then
		return
	end

	local BillboardGui = Main_Part:WaitForChild("BillboardGui") :: BillboardGui
	if not BillboardGui then
		return
	end

	local Price_Label = BillboardGui:WaitForChild("Price") :: TextLabel
	if not Price_Label then
		return
	end

	local REF_Table = {
		Main_Part = Main_Part,
		BillboardGui = BillboardGui,
		Price_Label = Price_Label,
	}

	return REF_Table
end

function Buy_Station:Connect_Touch_Buy_Request()
	if self._Connections["Touch_Request"] then
		return
	end

	local Main_Part = self._Instance_REFS["Main_Part"]
	local Debounce = false

	self._Connections["Touch_Request"] = Main_Part.Touched:Connect(function(BasePart: BasePart)
		if Debounce then
			return
		end
		Debounce = true

		local Char = BasePart.Parent
		local Player = Players:GetPlayerFromCharacter(Char)
		if not Player or LocalPlayer ~= Player then
			return
		end

		self._Gui_Class:Open()

		task.wait(1)
		Debounce = false
	end)
end

function Buy_Station:Disconnect_Events()
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

function Buy_Station:Destroy()
	self:Disconnect_Events()
	self._Gui_Class:Destroy()

	for Key in pairs(self) do
		self[Key] = nil
	end
end

----------> [ Execution ] <----------

for _, Buy_Station_Model in pairs(Buy_Station_Folder:GetChildren()) do
	local Station_Number = tonumber(Buy_Station_Model.Name)
	Buy_Station.new(Buy_Station_Model, Station_Number)
end

Buy_Station_Folder.ChildAdded:Connect(function(Buy_Station_Model: Model)
	local Station_Number = tonumber(Buy_Station_Model.Name)
	Buy_Station.new(Buy_Station_Model, Station_Number)
end)

Buy_Station_Folder.ChildRemoved:Connect(function(Buy_Station_Model: Model)
	local Station_Number = tonumber(Buy_Station_Model.Name)
	local Class = Buy_Station_Class_Table[Station_Number]
	assert(Class, "BuyStation Client Class not found -> will result in to a memory leak if it still exists")
	Class:Destroy()
end)

return Buy_Station
